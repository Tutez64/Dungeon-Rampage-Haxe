# Sourced by the bench scripts: where the repository, the executables and the results are.
BENCH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$BENCH/../../.." && pwd)"
RUNS="${DRH_BENCH_RUNS:-$ROOT/profiling/bench}"
BIN_DIR="${DRH_BENCH_BIN_DIR:-$ROOT/bin/linux/bin}"
BIN="${BIN:-Dungeon Rampage Haxe.bench}"
# The way into Proving Grounds from the town: world map, its back arrow four times to reach the
# first of its five pages (the map opens on the last one unlocked), the level, its intro.
ENTER_LEVEL="click:1300:500;wait:4;click:830:1130;wait:2;click:830:1130;wait:2;click:830:1130;wait:2;click:830:1130;wait:3;click:400:900;wait:3;click:1500:1000;wait:6;click:2500:200;state:RunState:90"
mkdir -p "$RUNS"
export DRH_BENCH_RUNS="$RUNS"
