#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <perf_data> [focus_regex]" >&2
  exit 1
fi

PERF_DATA="$1"
FOCUS_REGEX="${2:-SwfAsset|ASCompat|Animate|AssetLoader|MovieClip|BitmapData|lime|openfl|swf}"

if [[ ! -f "$PERF_DATA" ]]; then
  echo "Perf data file not found: $PERF_DATA" >&2
  exit 1
fi

echo "== Top hotspots =="
perf report --stdio --no-children --sort comm,dso,symbol --percent-limit 0.5 --input "$PERF_DATA" | sed -n '1,120p'
echo
echo "== Focused symbols =="
perf report --stdio --sort symbol --percent-limit 0.1 --input "$PERF_DATA" | rg -i "$FOCUS_REGEX" | sed -n '1,160p'
