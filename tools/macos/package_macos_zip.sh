#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  package_macos_zip.sh <app.bundle> [output.zip]

Examples:
  package_macos_zip.sh bin/macos/bin/DungeonBustersProject.app
  package_macos_zip.sh bin/macos/bin/DungeonBustersProject.app bin/macos/bin/DungeonBustersProject-macos-universal.zip

Notes:
  - Uses `ditto` because it is the safest way to archive a macOS app bundle.
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 1
fi

APP_PATH="$1"
OUTPUT_ZIP="${2:-}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 1
fi

if [[ -z "$OUTPUT_ZIP" ]]; then
  APP_DIR="$(cd "$(dirname "$APP_PATH")" && pwd)"
  APP_NAME="$(basename "$APP_PATH")"
  APP_STEM="${APP_NAME%.app}"
  OUTPUT_ZIP="$APP_DIR/$APP_STEM.zip"
fi

echo "Creating ZIP: $OUTPUT_ZIP"
rm -f "$OUTPUT_ZIP"
ditto -c -k --keepParent "$APP_PATH" "$OUTPUT_ZIP"

echo "Done: $OUTPUT_ZIP"
