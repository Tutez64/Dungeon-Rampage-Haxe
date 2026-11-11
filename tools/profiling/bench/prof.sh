#!/usr/bin/env bash
# prof.sh <name> [perf arguments] : a level with the first attack held and the mouse moving for 60 s, every
# thread recorded for 40 s of it into profiling/bench/<name>/perf.data. BIN names the executable.
# With a FP=1 build and "--call-graph fp", writes the stacks callers.py, callees.py and under.py read.
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
name="$1"
export DRH_PERF_SCRIPT="state:TownState:90;wait:14;$ENTER_LEVEL;wait:12;wiggle:1500:600;keydown:J;phase:fightJ:60;keyup:J;wiggle:off;quit"
(DRH_PERF_LONG=25 MAXTIME=300 BIN="$BIN" "$BENCH/run.sh" "$name" > "$RUNS/$name.out" 2>&1 &)
for i in $(seq 1 200); do grep -q "step phase:fightJ" "$RUNS/$name/events.log" 2>/dev/null && break; sleep 1; done
sleep 5
pid=$(pgrep -n -f "^./Dungeon Rampage Haxe")
perf record -F 1999 ${2:-} -p "$pid" -o "$RUNS/$name/perf.data" -- sleep 40 > /dev/null 2>&1
for i in $(seq 1 60); do pgrep -f "^./Dungeon Rampage Haxe" > /dev/null || break; sleep 1; done
grep -E "^  fightJ" "$RUNS/$name.out" | cut -c1-150
if [ -n "${2:-}" ]; then
  perf script -i "$RUNS/$name/perf.data" --comm "Dungeon Rampage" -F comm,ip,sym > "$RUNS/$name/stacks.txt" 2>/dev/null
  echo "$RUNS/$name/stacks.txt"
else
  perf report -i "$RUNS/$name/perf.data" --comm "Dungeon Rampage" --no-children --sort symbol 2>/dev/null | grep -v "^#" | grep -v "^$" | head -40 | cut -c1-150
fi
