#!/usr/bin/env python3
"""perf script -i perf.data --tid <main thread> -F time,ip,sym | record_stacks.py <run dir> <samples a second>

Sorts the main thread's samples of a recording (record.sh with PERF=1, a FP=1 build) into the FPS
groups of record_summ.py, by the second each one fell in, dungeon seconds only. Writes

- stacks_<group>.txt: up to 60000 stacks of each group, evenly thinned, for callers.py,
  callees.py and under.py;
- stacks_bands.txt (printed too): per function, the milliseconds of the main thread's CPU a
  frame spends in it (inclusive, then self) in each group, sorted by what the slowest group adds
  over the fastest;
- stacks_long.txt: the stacks sampled inside the dungeon frames of 25 ms or more (frames.csv
  says when each frame ran), each under the name of what it was doing, and a table of where the
  time of those frames went (printed, and at the end of stacks_bands.txt)."""
import bisect, collections, os, re, sys
import record_summ as summ

LIMIT = 60000
ENOUGH = 1500  # samples for a group to be compared
LONG = 25.0  # milliseconds from which a frame is a long one

# What a sample inside a long frame was doing: the first line with a name found anywhere in its stack
LONG_WORK = [
    ('collection asked by a mod (Gc.run)', ['Gc_objrun', 'Gc_obj::run']),
    ('collection', ['GlobalAllocator', 'InternalCollect', 'hx::Mark', 'BlockDataInfo']),
    ('sound decoding', ['drmp3', 'stb_vorbis', 'ov_read']),
    ('floor tiles and props built', ['buildTiles', 'DungeonFloorFactory', 'TileFactory']),
    ('new actors: assets and animations', ['ActorRenderer_obj::load', 'queueStarlingAssets', 'AnimationAtlas_obj::createAnimation', 'NPCGameObject_obj::init',
                                           'ActorGameObject_obj::init', 'InformParentOfNewObject', 'newNetworkChild']),
    ('assets loaded: files, images, atlases', ['SwfAssetLoader', 'SwfAsset_obj', 'AnimateLibrary', 'AnimationAtlasFactory', 'AssetManager', 'inflate', 'png_', 'jpeg_',
                                               'vfs_read', 'filemap_read']),
    ('text and bitmap bakes, cached bitmaps', ['FlashBaker', '_hx___updateCacheBitmap', 'cairo', 'pixman', 'TT_RunIns', 'FT_', 'StackBlur', 'TextEngine',
                                               'bakeString', 'BakedPages']),
    ('other network messages', ['ProcessMoreSocketData']),
    ('mods (other)', ['Cppia']),
    ('Starling render', ['Starling_obj::render']),
    ('OpenFL display list', ['Stage_obj::_hx___render']),
    ('animations', ['Juggler_obj::advanceTime']),
    ('memory given back or faulted in', ['madvise', 'page_fault']),
]


def short(symbol):
    symbol = re.sub(r'\(.*', '', symbol).replace('_obj::', '.').replace('::', '.')
    return symbol[-72:]


def file_name(band):
    return summ.band_name(band).replace('>=', 'ge').replace('<', 'lt')


def main(run, hz):
    rows = [row for row in summ.load_seconds(run)]
    mono = None
    for line in open(os.path.join(run, 'events.log'), errors='replace'):
        match = re.search(r' start steps=.* mono=([\d.]+)', line)
        if match:
            mono = float(match.group(1))
            break
    if mono is None:
        sys.exit('record_stacks.py: no mono= in the start line of events.log')
    ends = [mono + row['t'] for row in rows]
    frames = collections.Counter()
    expected = collections.Counter()
    for row in rows:
        if row['state'] == summ.DUNGEON:
            band = summ.band_of(row['fps'])
            frames[band] += summ.number(row, 'frames')
            expected[band] += summ.number(row, 'main_cpu_ms') * hz / 1000
    every = {band: max(1, int(expected[band] / LIMIT) + 1) for band in summ.BANDS}
    # frames.csv: the end of each frame in ms since the start, and its length
    frame_ends, frame_lengths = [], []
    path = os.path.join(run, 'frames.csv')
    if os.path.exists(path):
        for line in open(path):
            parts = line.split(',')
            try:
                frame_ends.append(mono + float(parts[0]) / 1000)
                frame_lengths.append(float(parts[1]))
            except (ValueError, IndexError):
                pass
    long_file = open(os.path.join(run, 'stacks_long.txt'), 'w')
    long_work = collections.defaultdict(collections.Counter)
    files = {}
    samples = collections.Counter()
    inclusive = {band: collections.Counter() for band in summ.BANDS}
    alone = {band: collections.Counter() for band in summ.BANDS}
    outside = 0

    def flush(header, stack):
        nonlocal outside
        match = re.search(r'(\d+\.\d+):', header)
        if not match or not stack:
            return
        index = bisect.bisect_left(ends, float(match.group(1)))
        if index >= len(rows) or rows[index]['state'] != summ.DUNGEON or float(match.group(1)) < ends[index] - rows[index]['dt']:
            outside += 1
            return
        frame = bisect.bisect_left(frame_ends, float(match.group(1)))
        if frame < len(frame_ends) and frame_lengths[frame] >= LONG and float(match.group(1)) >= frame_ends[frame] - frame_lengths[frame] / 1000:
            text = '\n'.join(stack)
            work = 'other'
            for name, keys in LONG_WORK:
                if any(key in text for key in keys):
                    work = name
                    break
            long_work[frame][work] += 1
            long_file.write('main %s\n' % work + ''.join('\t0 %s\n' % entry for entry in stack) + '\n')
        band = summ.band_of(rows[index]['fps'])
        samples[band] += 1
        names = [short(frame) for frame in stack]
        alone[band][names[0]] += 1
        for name in set(names):
            inclusive[band][name] += 1
        if samples[band] % every[band] == 0:
            if band not in files:
                files[band] = open(os.path.join(run, 'stacks_%s.txt' % file_name(band)), 'w')
            files[band].write('main %s\n' % match.group(1) + ''.join('\t0 %s\n' % frame for frame in stack) + '\n')

    header, stack = None, []
    for line in sys.stdin:
        if not line.strip():
            if header is not None:
                flush(header, stack)
            header, stack = None, []
        elif header is None:
            header = line
        else:
            text = line.strip()
            stack.append(text.split(' ', 1)[1] if ' ' in text else text)
    if header is not None:
        flush(header, stack)
    for file in files.values():
        file.close()

    long_file.close()
    bands = [band for band in summ.BANDS if samples[band] >= ENOUGH and frames[band] > 0]
    out = open(os.path.join(run, 'stacks_bands.txt'), 'w')

    def say(text=''):
        print(text)
        out.write(text + '\n')

    def long_frames():
        if not long_work:
            return
        per_sample = 1000.0 / hz
        total = collections.Counter()
        largest = collections.Counter()
        largest_ms = collections.Counter()
        length = 0.0
        for frame, works in long_work.items():
            for work, count in works.items():
                total[work] += count * per_sample
            total['(not on a CPU: waiting)'] += max(0.0, frame_lengths[frame] - sum(works.values()) * per_sample)
            work = works.most_common(1)[0][0]
            largest[work] += 1
            largest_ms[work] += frame_lengths[frame]
            length += frame_lengths[frame]
        dungeon = sum(row['dt'] for row in rows if row['state'] == summ.DUNGEON)
        say()
        say('%d dungeon frames of %.0f ms or more, %.1f s in all: one every %.1f s, %.1f%% of the time' % (
            len(long_work), LONG, length / 1000, dungeon / len(long_work), 100 * length / 1000 / dungeon if dungeon else 0))
        say('%-44s %8s %7s   %s' % ('where their time went', 'seconds', 'share', 'frames it is the largest part of'))
        for work, ms in total.most_common():
            say('%-44s %8.2f %6.0f%%   %s' % (work, ms / 1000, 100 * ms / length,
                                              '%d of %.0f ms' % (largest[work], largest_ms[work] / largest[work]) if largest[work] else ''))

    say()
    say('main thread samples in a dungeon: ' + '  '.join('%s %d' % (summ.band_name(band), samples[band]) for band in summ.BANDS if samples[band])
        + '  (%d elsewhere)' % outside)
    if not bands:
        say('No group has %d samples.' % ENOUGH)
        long_frames()
        return
    per_sample = 1000.0 / hz

    def table(title, counts, rows_shown):
        def ms(band, name):
            return counts[band][name] * per_sample / frames[band]
        names = set()
        for band in bands:
            names.update(name for name, _ in counts[band].most_common(400))
        slow, fast = bands[0], bands[-1]
        ordered = sorted(names, key=lambda name: ms(slow, name) - ms(fast, name) if slow != fast else ms(slow, name), reverse=True)
        say()
        say('%-74s' % title + ''.join('%9s' % summ.band_name(band) for band in bands) + ('%9s' % 'added' if slow != fast else ''))
        for name in ordered[:rows_shown]:
            say('%-74s' % name + ''.join('%9.3f' % ms(band, name) for band in bands) + ('%9.3f' % (ms(slow, name) - ms(fast, name)) if slow != fast else ''))

    say('CPU of the main thread, ms a frame: ' + '  '.join('%s %.3f' % (summ.band_name(band), samples[band] * per_sample / frames[band]) for band in bands))
    table('inclusive, ms a frame', inclusive, 70)
    table('self, ms a frame', alone, 40)
    long_frames()
    out.close()


if __name__ == '__main__':
    main(sys.argv[1], float(sys.argv[2]))
