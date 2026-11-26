#!/usr/bin/env bash
# record.sh <name> [minutes] : you play, the bot only records and sends no input. Quit the game to end the
# recording; it is killed after the minutes (120). BIN names the executable. Prints record_summ.py's tables.
# MODS=1 loads the mods the launcher has enabled, MODS=<folder> those of another mods folder.
# DRH_PERF_ALT=<seconds> has two variants of some code take turns (README); the summary compares them.
# CENSUS=1 adds a heap census each minute (a stall of about 0.15 s and a full collection each time).
# PERF=1 samples the game's threads with perf for the whole session (PERF_HZ, 499 a second); with a FP=1 build
# record_stacks.py then says which functions take more of a frame when the game is slow.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
name="$1"
minutes="${2:-120}"
out="$RUNS/$name"
if [ -z "${DRH_PERF_SCRIPT:-}" ]; then
  # run.sh plays its own scenario when the script is empty
  script="wait:1"
  if [ "${CENSUS:-0}" = 1 ]; then
    for i in $(seq -w 1 "$minutes"); do script="$script;wait:60;census:m$i"; done
  fi
  export DRH_PERF_SCRIPT="$script"
fi
export DRH_PERF_RECORD=1
mods="${MODS:-}"
[ "$mods" = 1 ] && mods="${XDG_DATA_HOME:-$HOME/.local/share}/drhlauncher/mods"
[ -n "$mods" ] && export ARGS="${ARGS:-} --mods-dir $mods"
BIN="$BIN" MAXTIME=$((minutes * 60 + 90)) "$BENCH/run.sh" "$name" > "$RUNS/$name.out" 2>&1 &
runner=$!
if [ "${PERF:-0}" = 1 ]; then
  hz="${PERF_HZ:-499}"
  # run.sh empties the folder, and may launch the game again when Steam gives no ticket: the bot's log tells
  # the game that stays
  for i in $(seq 1 180); do
    kill -0 "$runner" 2>/dev/null || break
    [ -f "$out/events.log" ] && grep -q "^pid=" "$out/session.txt" 2>/dev/null && break
    sleep 1
  done
  pid=$(pgrep -n -f "^./Dungeon Rampage Haxe" || true)
  if [ -n "$pid" ] && [ -f "$out/events.log" ]; then
    echo "$pid $hz" > "$out/perf.txt"
    perf record -F "$hz" --call-graph fp -k CLOCK_MONOTONIC -p "$pid" -o "$out/perf.data" > "$out/perf.log" 2>&1
  else
    echo "record.sh: the game did not start, nothing sampled" >&2
  fi
fi
wait "$runner"
[ -n "$mods" ] && cp "$mods/enabled.json" "$out/mods.json" 2> /dev/null
python3 "$BENCH/record_summ.py" "$out"
if [ -f "$out/perf.data" ]; then
  read -r pid hz < "$out/perf.txt"
  perf script -i "$out/perf.data" --tid "$pid" -F time,ip,sym 2> /dev/null | python3 "$BENCH/record_stacks.py" "$out" "$hz"
fi
