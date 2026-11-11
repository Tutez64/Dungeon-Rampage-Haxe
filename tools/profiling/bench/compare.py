#!/usr/bin/env python3
"""compare.py <prefix> <variant>... : the mean frame time of each phase over the runs named
<prefix>_<variant>_<n>, and each variant against the first.
compare.py --run <name>... : the same figures for single runs."""
import collections, csv, glob, os, statistics, sys

RUNS = os.environ.get('DRH_BENCH_RUNS') or os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../profiling/bench')


def phases(run):
    """Mean frame time in ms per phase, without each phase's first and last second."""
    events = os.path.join(run, 'events.log')
    if not os.path.exists(events) or ' quit' not in open(events).read():
        return None
    frames = collections.OrderedDict()
    for row in csv.DictReader(open(os.path.join(run, 'seconds.csv'))):
        if row['phase']:
            frames.setdefault(row['phase'], []).append(int(row['frames']))
    result = collections.OrderedDict()
    for phase, counts in frames.items():
        counts = counts[1:-1] if len(counts) > 4 else counts
        result[phase] = 1000.0 * len(counts) / sum(counts)
    return result


if sys.argv[1] == '--run':
    for name in sys.argv[2:]:
        result = phases(os.path.join(RUNS, name))
        print(name.ljust(12), 'did not finish' if result is None else ' | '.join('%s %.3f ms (%.0f fps)' % (k, v, 1000 / v) for k, v in result.items()))
    sys.exit(0)

prefix, variants = sys.argv[1], sys.argv[2:]
times = {}
for variant in variants:
    for run in sorted(glob.glob(os.path.join(RUNS, '%s_%s_*' % (prefix, variant)) + os.sep)):
        result = phases(run)
        if result is None:
            continue
        for phase, value in result.items():
            times.setdefault(variant, collections.OrderedDict()).setdefault(phase, []).append(value)
for variant in variants:
    if variant not in times:
        continue
    cells = []
    for phase, values in times[variant].items():
        mean = statistics.mean(values)
        base = statistics.mean(times[variants[0]][phase])
        cells.append('%s %.3f ms (%+.1f%%) [%s]' % (phase, mean, 100 * (mean - base) / base, ' '.join('%.3f' % v for v in values)))
    print(variant.ljust(6), ' | '.join(cells))
