#!/usr/bin/env python3
"""record_summ.py <run dir> : what a recording of record.sh holds.

Per state and per dungeon floor: the time spent, FPS, draws, actors. Then the seconds in a dungeon
grouped by FPS, with where a frame's time goes in each group and what the scene held, the
correlation of the frame time with each count, the long frames, and the censuses if any."""
import bisect, collections, csv, glob, json, math, os, re, sys

BANDS = [(0, 100), (100, 150), (150, 200), (200, 300), (300, 1e9)]
DUNGEON = 'RunState'
IN_EVENTS = ['realwork', 'logical', 'physics', 'prerender', 'views', 'layers', 'advance', 'render']
COUNTS = ['draws', 'passes', 'filters', 'heroes', 'npcs', 'projectiles', 'effects_live', 'effects', 'objects', 'sl_objects', 'sl_shown', 'sl_meshes',
          'sl_filters', 'juggler', 'nat_objects', 'nat_shown', 'nat_text', 'nat_filters', 'nat_under_hidden', 'nat_cache_renders']


def band_name(band):
    low, high = band
    return '<%d' % high if low == 0 else ('>=%d' % low if high > 1e8 else '%d-%d' % (low, high))


def band_of(fps):
    for band in BANDS:
        if band[0] <= fps < band[1]:
            return band
    return BANDS[-1]


def number(row, key):
    try:
        return float(row.get(key) or 0)
    except ValueError:
        return 0.0


def load_seconds(run):
    """The rows of seconds.csv, each with dt (its length in seconds) and fps."""
    rows = []
    previous = 0.0
    for row in csv.DictReader(open(os.path.join(run, 'seconds.csv'))):
        try:
            t = float(row['t'])
        except (ValueError, TypeError, KeyError):
            continue
        row['dt'] = t - previous if rows else 1.0
        previous = t
        if row['dt'] <= 0:
            continue
        row['t'] = t
        row['fps'] = number(row, 'frames') / row['dt']
        rows.append(row)
    return rows


class Group:
    """Seconds added up: per frame times and time weighted counts."""

    def __init__(self):
        self.seconds = 0.0
        self.frames = 0.0
        self.sums = collections.Counter()
        self.weighted = collections.Counter()
        self.peak = collections.Counter()

    def add(self, row):
        self.seconds += row['dt']
        self.frames += number(row, 'frames')
        for key in row:
            if key.startswith('b_') or key in ('main_cpu_ms', 'proc_cpu_ms', 'slow10', 'slow16') or re.match(r'p\d+_(us|calls)$', key):
                self.sums[key] += number(row, key)
        for key in COUNTS:
            if key in ('draws', 'passes', 'filters'):
                self.weighted[key] += number(row, key) * number(row, 'frames')
            else:
                self.weighted[key] += number(row, key) * row['dt']
                self.peak[key] = max(self.peak[key], number(row, key))

    def per_frame(self, key):
        return self.sums[key] / self.frames if self.frames else 0.0

    def mean(self, key):
        if key in ('draws', 'passes', 'filters'):
            return self.weighted[key] / self.frames if self.frames else 0.0
        return self.weighted[key] / self.seconds if self.seconds else 0.0

    def fps(self):
        return self.frames / self.seconds if self.seconds else 0.0


def frame_times(run):
    path = os.path.join(run, 'frames.csv')
    times, values = [], []
    if os.path.exists(path):
        for row in csv.reader(open(path)):
            try:
                times.append(float(row[0]) / 1000)
                values.append(float(row[1]))
            except (ValueError, IndexError):
                pass
    return times, values


def percentile(values, share):
    if not values:
        return 0.0
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int(share * len(ordered)))]


def correlation(xs, ys):
    n = len(xs)
    if n < 3:
        return 0.0
    mx, my = sum(xs) / n, sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    if sxx == 0 or syy == 0:
        return 0.0
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / math.sqrt(sxx * syy)


def print_table(title, columns, lines):
    """lines: (label, [text per column]) or None for a blank line."""
    print()
    print('%-30s' % title + ''.join('%10s' % c for c in columns))
    for line in lines:
        if line is None:
            print()
        else:
            print('%-30s' % line[0] + ''.join('%10s' % v for v in line[1]))


def main(run):
    rows = load_seconds(run)
    if not rows:
        sys.exit('record_summ.py: no seconds in %s' % run)
    events = open(os.path.join(run, 'events.log'), errors='replace').read().splitlines() if os.path.exists(os.path.join(run, 'events.log')) else []
    print('== %s : %.0f s recorded' % (os.path.basename(run.rstrip('/')), rows[-1]['t']))
    for line in events:
        if ' start steps=' in line:
            print('  ' + line.split(' ', 1)[1])
        if re.search(r'ABORT|CHEATCOUNT|WORLD error|HUDERROR| FLOOR ', line):
            print('  ' + line)
    mods = os.path.join(run, 'mods.json')
    if os.path.exists(mods):
        ids = [mod.get('id', '?') for mod in json.load(open(mods)).get('mods', [])]
        print('  %d mods: %s' % (len(ids), ' '.join(ids)))
    log = os.path.join(run, 'game.log')
    if os.path.exists(log):
        reports = [l.strip() for l in open(log, errors='replace') if re.search(r'speed_hack|LogCheater', l)]
        for line in reports[:3]:
            print('  ' + line[:150])

    states = collections.OrderedDict()
    for row in rows:
        states.setdefault(row['state'], Group()).add(row)
    print_table('state', ['s', 'fps', 'draws', 'passes'],
                [(name or '(none)', ['%.0f' % g.seconds, '%.0f' % g.fps(), '%.0f' % g.mean('draws'), '%.0f' % g.mean('passes')]) for name, g in states.items()])

    alternated(rows)
    dungeon = [row for row in rows if row['state'] == DUNGEON]
    if not dungeon:
        print('\nNo second in %s.' % DUNGEON)
        return
    times, values = frame_times(run)

    # Floors: consecutive dungeon seconds with the same floor
    floors = []
    for row in dungeon:
        key = row.get('floor') or '?'
        if not floors or floors[-1][0] != key or row['t'] - floors[-1][2] > 30:
            floors.append([key, row['t'] - row['dt'], row['t'], Group(), []])
        floors[-1][2] = row['t']
        floors[-1][3].add(row)
        floors[-1][4].append(row['fps'])
    lines = []
    for key, start, end, group, fps in floors:
        ms = values[bisect.bisect_left(times, start):bisect.bisect_right(times, end)]
        low = percentile(ms, 0.99)
        lines.append(('%-12s at %5.0f s' % (key, start), ['%.0f' % group.seconds, '%.0f' % group.fps(), '%.0f' % (1000 / low if low else 0), '%.0f' % min(fps),
                                                        '%.0f' % group.mean('draws'), '%.0f' % group.mean('passes'), '%.0f' % group.peak['heroes'],
                                                        '%.0f' % group.mean('npcs'), '%.0f' % group.peak['npcs'], '%.0f' % group.mean('sl_meshes')]))
    print_table('floor (map node/number)', ['s', 'fps', '1% low', 'worst s', 'draws', 'passes', 'heroes', 'npcs', 'npcs max', 'meshes'], lines)

    groups = collections.OrderedDict((band, Group()) for band in BANDS)
    everything = Group()
    for row in dungeon:
        groups[band_of(row['fps'])].add(row)
        everything.add(row)
    shown = [(band_name(band), group) for band, group in groups.items() if group.seconds > 0] + [('all', everything)]
    columns = [name for name, _ in shown]

    def line(label, value, form='%.3f'):
        return (label, [form % value(group) for _, group in shown])

    def other(group):
        return group.per_frame('b_events') - sum(group.per_frame('b_' + name) for name in IN_EVENTS)

    lines = [
        line('seconds', lambda g: g.seconds, '%.0f'),
        line('share of the time, %', lambda g: 100 * g.seconds / everything.seconds, '%.1f'),
        line('fps', lambda g: g.fps(), '%.0f'),
        line('frame, ms', lambda g: 1000 * g.seconds / g.frames if g.frames else 0),
        None,
        line('update', lambda g: g.per_frame('b_update')),
        line('events (enterFrame)', lambda g: g.per_frame('b_events')),
    ]
    lines += [line('  ' + name, lambda g, name=name: g.per_frame('b_' + name)) for name in IN_EVENTS]
    lines += [
        line('  other listeners', other),
        line('openfl (its display list)', lambda g: g.per_frame('b_openfl')),
        line('swap, polling, limiter', lambda g: g.per_frame('b_swap')),
        line('network (inside another)', lambda g: g.per_frame('b_network')),
        None,
        line('main thread on a CPU, ms', lambda g: g.per_frame('main_cpu_ms')),
        line('main thread on a CPU, %', lambda g: g.sums['main_cpu_ms'] / (10 * g.seconds) if g.seconds else 0, '%.0f'),
        line('process, CPUs', lambda g: g.sums['proc_cpu_ms'] / (1000 * g.seconds) if g.seconds else 0, '%.2f'),
        line('frames over 10 ms, %', lambda g: 100 * g.sums['slow10'] / g.frames if g.frames else 0, '%.2f'),
        line('frames over 16.7 ms, %', lambda g: 100 * g.sums['slow16'] / g.frames if g.frames else 0, '%.2f'),
        None,
    ]
    lines += [line(name, lambda g, name=name: g.mean(name), '%.1f') for name in COUNTS]
    print_table('dungeon seconds by fps, ms a frame', columns, lines)

    frame_ms = [1000 * row['dt'] / number(row, 'frames') for row in dungeon if number(row, 'frames') > 0]
    kept = [row for row in dungeon if number(row, 'frames') > 0]
    print('\ncorrelation of a second\'s mean frame time with:')
    pairs = [(correlation([number(row, name) for row in kept], frame_ms), name) for name in COUNTS]
    print('  ' + '  '.join('%s %.2f' % (name, r) for r, name in sorted(pairs, reverse=True)))

    longs = collections.Counter()
    worst = []
    for text in events:
        match = re.match(r'(\S+) LONGFRAME ms=([\d.]+) at=\S+(?: state=(\S*))?(.*)', text)
        if match:
            longs[match.group(3) or '?'] += 1
            if match.group(3) == DUNGEON:
                worst.append((float(match.group(2)), float(match.group(1)), match.group(4).strip()))
    if longs:
        print('\nlong frames by state: ' + '  '.join('%s %d' % item for item in longs.most_common()))
        for ms, t, rest in sorted(worst, reverse=True)[:12]:
            print('  %7.1f ms at %6.0f s  %s' % (ms, t, rest))
    census(run, events)


def alternated(rows):
    """With DRH_PERF_ALT: per state, the variants side by side, then what each changes against variant 0."""
    by_state = collections.OrderedDict()
    for row in rows:
        if (row.get('alt') or '').isdigit():
            by_state.setdefault(row['state'], {}).setdefault(int(row['alt']), Group()).add(row)
    for state, groups in by_state.items():
        variants = sorted(k for k, g in groups.items() if g.seconds >= 15 and g.frames)
        if len(variants) < 2 or variants[0] != 0:
            continue
        lines = [
            ('seconds', lambda g: g.seconds, '%.0f'),
            ('fps', lambda g: g.fps(), '%.0f'),
            ('frame, ms', lambda g: 1000 * g.seconds / g.frames, '%.3f'),
            ('main thread on a CPU, ms', lambda g: g.per_frame('main_cpu_ms'), '%.3f'),
            ('update', lambda g: g.per_frame('b_update'), '%.3f'),
            ('events (enterFrame)', lambda g: g.per_frame('b_events'), '%.3f'),
        ]
        lines += [('  ' + name, lambda g, name=name: g.per_frame('b_' + name), '%.3f') for name in IN_EVENTS]
        lines += [
            ('  other listeners', lambda g: g.per_frame('b_events') - sum(g.per_frame('b_' + name) for name in IN_EVENTS), '%.3f'),
            ('openfl (its display list)', lambda g: g.per_frame('b_openfl'), '%.3f'),
            ('swap, polling, limiter', lambda g: g.per_frame('b_swap'), '%.3f'),
        ]
        probes = sorted(set(int(key[1:-3]) for g in groups.values() for key in g.sums if re.match(r'p\d+_us$', key) and g.sums[key]))
        for probe in probes:
            lines.append(('probe %d, us a frame' % probe, lambda g, probe=probe: g.per_frame('p%d_us' % probe), '%.2f'))
            lines.append(('probe %d, calls a frame' % probe, lambda g, probe=probe: g.per_frame('p%d_calls' % probe), '%.2f'))
        lines += [
            ('draws', lambda g: g.mean('draws'), '%.1f'),
            ('sl_shown', lambda g: g.mean('sl_shown'), '%.0f'),
            ('nat_objects', lambda g: g.mean('nat_objects'), '%.0f'),
        ]
        print_table('%s, variants in turn' % (state or '(none)'), [str(k) for k in variants],
                    [(label, [form % value(groups[k]) for k in variants]) for label, value, form in lines])
        base = groups[0]

        def change(value, k):
            x, y = value(base), value(groups[k])
            return '%+.1f%%' % (100 * (y - x) / x) if x else ''

        print_table('  change against variant 0', [str(k) for k in variants[1:]],
                    [(label, [change(value, k) for k in variants[1:]]) for label, value, form in lines[1:-3]])
        paired(rows, state, variants, lines[2:-3])


def paired(rows, state, variants, lines):
    """Each turn of the variants gives one difference with the variant 0 of the same turn: their mean,
    and its standard error, say what a change does better than the means of the whole game."""
    turns = []
    current = None
    for row in rows:
        alt = row.get('alt') or ''
        if row['state'] != state or not alt.isdigit() or number(row, 'frames') <= 0:
            current = None
            continue
        alt = int(alt)
        if current is None or current[0] != alt:
            if alt == 0 or not turns:
                turns.append({})
            current = (alt, Group())
            turns[-1][alt] = current[1]
        current[1].add(row)
    table = []
    for label, value, form in lines:
        cells = []
        for k in variants[1:]:
            differences = [value(turn[k]) - value(turn[0]) for turn in turns
                           if 0 in turn and k in turn and turn[0].seconds >= 3 and turn[k].seconds >= 3 and turn[0].frames and turn[k].frames]
            if len(differences) < 5:
                cells.append('')
                continue
            mean = sum(differences) / len(differences)
            error = math.sqrt(sum((d - mean) ** 2 for d in differences) / (len(differences) - 1) / len(differences))
            cells.append((form + ' ±' + form) % (mean, error))
        table.append((label, cells))
    turns_used = sum(1 for turn in turns if 0 in turn and len(turn) > 1)
    print()
    print('%-30s' % ('  per turn (%d), difference ± standard error' % turns_used) + ''.join('%16s' % k for k in variants[1:]))
    for label, cells in table:
        print('%-30s' % label + ''.join('%16s' % c for c in cells))


def census(run, events):
    """Per census: the texture objects and the heap, and their growth a minute."""
    paths = sorted(glob.glob(os.path.join(run, 'census_*.csv')))
    if not paths:
        return
    notes = {}
    for text in events:
        t, _, rest = text.partition(' ')
        m = re.match(r'census (\S+) rows=\d+ used=([\d.]+) large=([\d.]+)', rest)
        if m:
            notes.setdefault(m.group(1), [0, 0, 0, ''])[:3] = [float(t), float(m.group(2)), float(m.group(3))]
        m = re.match(r'step census:(\S+) state=(\S*)', rest)
        if m:
            notes.setdefault(m.group(1), [0, 0, 0, ''])[3] = m.group(2)
    print('\n%-5s %7s %-12s %10s %9s %9s %9s %10s' % ('name', 'time', 'state', 'textures', '/s', 'heap MB', 'MB/min', 'objects'))
    prev = None
    for path in paths:
        name = os.path.basename(path)[7:-4]
        rows = {r['name']: int(r['count']) for r in csv.DictReader(open(path))}
        textures = rows.get('openfl.display3D.textures.RectangleTexture', 0)
        objects = sum(v for k, v in rows.items() if k[:1] not in '~^')
        t, used, large, state = notes.get(name, [0, 0, 0, ''])
        rate = growth = ''
        if prev:
            dt = t - prev[0]
            if dt > 0:
                rate = '%.0f' % ((textures - prev[1]) / dt)
                growth = '%+.1f' % ((used - prev[2]) * 60 / dt)
        print('%-5s %7.0f %-12s %10d %9s %9.1f %9s %10d' % (name, t, state, textures, rate, used, growth, objects))
        prev = (t, textures, used)


if __name__ == '__main__':
    main(sys.argv[1])
