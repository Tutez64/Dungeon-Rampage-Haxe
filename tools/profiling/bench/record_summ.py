# record_summ.py <run dir> : per census of record.sh, the texture objects and the heap, and their growth a minute
import csv, glob, os, re, sys
run = sys.argv[1]
notes = {}
for line in open(os.path.join(run, 'events.log')):
    t, text = line.rstrip('\n').split(' ', 1)
    m = re.match(r'census (\S+) rows=\d+ used=([\d.]+) large=([\d.]+)', text)
    if m: notes.setdefault(m.group(1), [0, 0, 0, ''])[:3] = [float(t), float(m.group(2)), float(m.group(3))]
    m = re.match(r'step census:(\S+) state=(\S*)', text)
    if m: notes.setdefault(m.group(1), [0, 0, 0, ''])[3] = m.group(2)
print('%-5s %7s %-12s %10s %9s %9s %9s %10s' % ('name', 'time', 'state', 'textures', '/s', 'heap MB', 'MB/min', 'objects'))
prev = None
for path in sorted(glob.glob(os.path.join(run, 'census_*.csv'))):
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
