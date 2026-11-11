#!/usr/bin/env bash
# record.sh <name> [minutes] : you play, the bot only records, with a heap census each minute (a stall of
# about 0.2 s). The game is killed after the minutes (30). BIN names the executable.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
name="$1"
minutes="${2:-30}"
script=""
for i in $(seq -w 1 "$minutes"); do script="$script;wait:60;census:m$i"; done
export DRH_PERF_SCRIPT="${script#;}"
BIN="$BIN" MAXTIME=$((minutes * 60 + 90)) "$BENCH/run.sh" "$name" > "$RUNS/$name.out" 2>&1
python3 "$BENCH/record_summ.py" "$RUNS/$name"
