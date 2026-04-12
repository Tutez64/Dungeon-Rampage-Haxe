#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  package_macos_zip.sh <app.bundle> [output.zip]

Examples:
  package_macos_zip.sh bin/macos/bin/DungeonBustersProject.app
  package_macos_zip.sh bin/macos/bin/DungeonBustersProject.app "bin/macos/bin/Dungeon Rampage Haxe macOS.zip"

Notes:
  - Uses `ditto` because it is the safest way to archive a macOS app bundle.
  - The ZIP contains a `Dungeon Rampage Haxe/` folder with the app and a `README.txt`.
  - macOS metadata is preserved so the app signature remains valid after extraction.
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 1
fi

APP_PATH="$1"
OUTPUT_ZIP="${2:-}"
PACKAGE_DIR_NAME="Dungeon Rampage Haxe"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 1
fi

if [[ -z "$OUTPUT_ZIP" ]]; then
  APP_DIR="$(cd "$(dirname "$APP_PATH")" && pwd)"
  OUTPUT_ZIP="$APP_DIR/Dungeon Rampage Haxe macOS.zip"
fi

APP_NAME="$(basename "$APP_PATH")"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dungeon-rampage-macos-package.XXXXXX")"
STAGING_DIR="$TMP_DIR/$PACKAGE_DIR_NAME"
README_PATH="$STAGING_DIR/README.txt"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/$APP_NAME"
find "$STAGING_DIR" -name '._*' -type f -delete

cat > "$README_PATH" <<EOF
For the first launch only, open the app using right click -> Open, then click Open again in the dialog.

macOS shows this warning because verified Apple app distribution requires a paid developer account, and this project is not distributed that way.

If macOS still blocks the app:
1. Open System Settings -> Privacy & Security
2. Click Open Anyway for $APP_NAME

If needed, you can also remove the quarantine flag manually:
xattr -dr com.apple.quarantine "$APP_NAME"
EOF

echo "Creating ZIP: $OUTPUT_ZIP"
rm -f "$OUTPUT_ZIP"
ditto -c -k --keepParent "$STAGING_DIR" "$OUTPUT_ZIP"

echo "Done: $OUTPUT_ZIP"
