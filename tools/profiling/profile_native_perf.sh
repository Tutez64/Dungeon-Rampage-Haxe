#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <pid> [output_dir]" >&2
  exit 1
fi

PID="$1"
OUT_DIR="${2:-profiling/$(date +%Y%m%d_%H%M%S)}"
PERF_DATA="$OUT_DIR/perf.data"
META_FILE="$OUT_DIR/session.txt"

mkdir -p "$OUT_DIR"

if ! kill -0 "$PID" 2>/dev/null; then
  echo "Process $PID is not running" >&2
  exit 1
fi

echo "pid=$PID" > "$META_FILE"
echo "started_at=$(date --iso-8601=seconds)" >> "$META_FILE"
echo "hostname=$(hostname)" >> "$META_FILE"
echo "cwd=$(pwd)" >> "$META_FILE"

echo "Recording perf data for pid $PID"
echo "Output: $PERF_DATA"
echo "Press Ctrl+C when the reproduction is finished"

perf record \
  --freq 999 \
  --call-graph dwarf,16384 \
  --pid "$PID" \
  --output "$PERF_DATA"

echo "finished_at=$(date --iso-8601=seconds)" >> "$META_FILE"
echo "Perf capture complete"
