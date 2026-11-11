#!/usr/bin/env python3
"""summ.py <run dir>... : one line per phase with FPS, frame times, memory."""
import sys, re, os, csv

def load(run):
    ev = open(os.path.join(run, 'events.log')).read().splitlines() if os.path.exists(os.path.join(run, 'events.log')) else []
    sess = dict(l.split('=', 1) for l in open(os.path.join(run, 'session.txt')).read().splitlines() if '=' in l)
    bot_start = float(sess.get('bot_start', '0').replace(',', '.'))
    mem = []
    mp = os.path.join(run, 'mem.csv')
    if os.path.exists(mp):
        for r in csv.DictReader(open(mp)):
            try:
                mem.append((float(r['epoch']), int(r['rss_kb']), int(r['anon_kb']), int(r['file_kb']), int(r['vram_kb']), int(r['gtt_kb'])))
            except Exception:
                pass
    phases = []
    start = {}
    for l in ev:
        t, _, rest = l.partition(' ')
        if rest.startswith('step phase:'):
            start[rest.split(':')[1]] = float(t)
        if rest.startswith('PHASE '):
            d = dict(kv.split('=') for kv in rest.split()[2:])
            name = rest.split()[1]
            d['name'] = name
            t0, t1 = start.get(name, 0) + bot_start, float(t) + bot_start
            m = [x for x in mem if t0 <= x[0] <= t1 + 1]
            if m:
                d['rss'] = max(x[1] for x in m) / 1024
                d['anon'] = max(x[2] for x in m) / 1024
                d['vram'] = max(x[4] for x in m) / 1024
            phases.append(d)
    other = [l for l in ev if re.search(r'TIMEOUT|ABORT|CHEAT| gc ', l)]
    peak = (max(x[1] for x in mem) / 1024, max(x[4] for x in mem) / 1024) if mem else (0, 0)
    gc = {}
    gl = os.path.join(run, 'game.log')
    if os.path.exists(gl):
        for l in open(gl, errors='replace'):
            m = re.match(r'\s*(Total time|Collecting time|Max Stall time|Fraction)\s*:\s*([\d.]+)', l)
            if m:
                gc[m.group(1)] = float(m.group(2))
    return phases, other, peak, gc

if __name__ == '__main__':
    for run in sys.argv[1:]:
        phases, other, peak, gc = load(run)
        print('== %s  peak rss %.0f MiB, peak vram %.0f MiB, gc %s' % (os.path.basename(run.rstrip('/')), peak[0], peak[1],
              ' '.join('%s=%s' % (k.split()[0].lower(), v) for k, v in gc.items())))
        for d in phases:
            print('  %-6s fps %6s  p50 %6s p99 %6s p999 %6s max %7s  >16ms %3s >33 %2s  draws %5s  gc %6s/%6s large %6s  rss %5.0f anon %5.0f vram %5.0f  clk %s' % (
                d['name'], d['fps'], d['p50'], d['p99'], d['p999'], d['max'], d['over16'], d['over33'], d['draws'],
                d['gc_used'], d['gc_reserved'], d['gc_large'], d.get('rss', 0), d.get('anon', 0), d.get('vram', 0), d['orig_clock_ratio_max']))
        for l in other:
            print('  ' + l)
