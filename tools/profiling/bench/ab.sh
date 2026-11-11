#!/usr/bin/env bash
# ab.sh <name> : a level, 12 s idle with the mouse moving, 50 s of the first attack with it moving, 8 s idle
# with it still. Prints the mean frame time of each phase. BIN names the executable; other variables reach the game.
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
export DRH_PERF_SCRIPT="state:TownState:90;wait:14;$ENTER_LEVEL;wait:12;wiggle:1500:600;phase:idlew:12;keydown:J;phase:fightJ:50;keyup:J;wiggle:off;phase:idle:8;quit"
DRH_PERF_LONG=25 MAXTIME=300 BIN="$BIN" "$BENCH/run.sh" "$1" > "$RUNS/$1.out" 2>&1
python3 "$BENCH/compare.py" --run "$1"
grep -q TIMEOUT "$RUNS/$1/session.txt" && echo "$1: killed after the timeout"
exit 0
