#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: $0 <pid> [output_csv] [interval_seconds]" >&2
  exit 1
fi

PID="$1"
OUT_FILE="${2:-profiling/$(date +%Y%m%d_%H%M%S)/memory.csv}"
INTERVAL="${3:-0.5}"

mkdir -p "$(dirname "$OUT_FILE")"

if ! kill -0 "$PID" 2>/dev/null; then
  echo "Process $PID is not running" >&2
  exit 1
fi

echo "timestamp_sec,rss_kb,vm_size_kb,vm_data_kb,private_dirty_kb,shared_dirty_kb,pss_kb" > "$OUT_FILE"

while kill -0 "$PID" 2>/dev/null; do
  NOW="$(date +%s.%3N)"
  RSS="$(awk '/^VmRSS:/ {print $2}' "/proc/$PID/status" 2>/dev/null || echo 0)"
  VM_SIZE="$(awk '/^VmSize:/ {print $2}' "/proc/$PID/status" 2>/dev/null || echo 0)"
  VM_DATA="$(awk '/^VmData:/ {print $2}' "/proc/$PID/status" 2>/dev/null || echo 0)"
  if [[ -r "/proc/$PID/smaps_rollup" ]]; then
    PSS="$(awk '/^Pss:/ {print $2}' "/proc/$PID/smaps_rollup" 2>/dev/null || echo 0)"
    PRIVATE_DIRTY="$(awk '/^Private_Dirty:/ {print $2}' "/proc/$PID/smaps_rollup" 2>/dev/null || echo 0)"
    SHARED_DIRTY="$(awk '/^Shared_Dirty:/ {print $2}' "/proc/$PID/smaps_rollup" 2>/dev/null || echo 0)"
  else
    PSS=0
    PRIVATE_DIRTY=0
    SHARED_DIRTY=0
  fi

  echo "$NOW,$RSS,$VM_SIZE,$VM_DATA,$PRIVATE_DIRTY,$SHARED_DIRTY,$PSS" >> "$OUT_FILE"
  sleep "$INTERVAL"
done
