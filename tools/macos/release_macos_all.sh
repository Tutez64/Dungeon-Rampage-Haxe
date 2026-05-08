#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  release_macos_all.sh [--project <project.xml>] [--openfl <command>] [--target <macos>] [--output-app <app>] [--output-zip <zip>] [--no-sign] [--] [extra openfl args...]

Examples:
  release_macos_all.sh
  release_macos_all.sh -- -Dfinal
  release_macos_all.sh --no-sign -- -debug

Pipeline:
  1. Build x86_64 app
  2. Build arm64 app
  3. Merge both into one universal app
  4. Package the universal app into a ZIP

Notes:
  - By default the merged `.app` is ad-hoc signed and verified.
  - Use `--no-sign` if you want the merged app left unsigned.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="project.xml"
OPENFL_BIN="${OPENFL_BIN:-openfl}"
TARGET_NAME="macos"
OUTPUT_APP="bin/macos/bin/Dungeon Rampage Haxe.app"
OUTPUT_ZIP="bin/macos/bin/Dungeon Rampage Haxe macOS.zip"
X86_APP=""
ARM_APP=""
DO_SIGN=1
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_FILE="${2:-}"
      shift 2
      ;;
    --openfl)
      OPENFL_BIN="${2:-}"
      shift 2
      ;;
    --target)
      TARGET_NAME="${2:-}"
      shift 2
      ;;
    --output-app)
      OUTPUT_APP="${2:-}"
      shift 2
      ;;
    --output-zip)
      OUTPUT_ZIP="${2:-}"
      shift 2
      ;;
    --x86-app)
      X86_APP="${2:-}"
      shift 2
      ;;
    --arm-app)
      ARM_APP="${2:-}"
      shift 2
      ;;
    --no-sign)
      DO_SIGN=0
      shift
      ;;
    --)
      shift
      EXTRA_ARGS=("$@")
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$X86_APP" || -z "$ARM_APP" ]]; then
  OUTPUT_DIR="$(dirname "$OUTPUT_APP")"
  OUTPUT_NAME="$(basename "$OUTPUT_APP")"
  OUTPUT_STEM="${OUTPUT_NAME%.app}"

  if [[ -z "$X86_APP" ]]; then
    X86_APP="$OUTPUT_DIR/$OUTPUT_STEM-x86_64.app"
  fi

  if [[ -z "$ARM_APP" ]]; then
    ARM_APP="$OUTPUT_DIR/$OUTPUT_STEM-arm64.app"
  fi
fi

if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  "$SCRIPT_DIR/build_macos_arches.sh" \
    --project "$PROJECT_FILE" \
    --openfl "$OPENFL_BIN" \
    --target "$TARGET_NAME" \
    --build-app "$OUTPUT_APP" \
    --x86-app "$X86_APP" \
    --arm-app "$ARM_APP" \
    -- "${EXTRA_ARGS[@]}"
else
  "$SCRIPT_DIR/build_macos_arches.sh" \
    --project "$PROJECT_FILE" \
    --openfl "$OPENFL_BIN" \
    --target "$TARGET_NAME" \
    --build-app "$OUTPUT_APP" \
    --x86-app "$X86_APP" \
    --arm-app "$ARM_APP"
fi

UNIVERSAL_ARGS=(
  "$X86_APP"
  "$ARM_APP"
  "$OUTPUT_APP"
)

if [[ $DO_SIGN -eq 0 ]]; then
  "$SCRIPT_DIR/make_universal_macos_app.sh" --no-sign "${UNIVERSAL_ARGS[@]}"
else
  "$SCRIPT_DIR/make_universal_macos_app.sh" "${UNIVERSAL_ARGS[@]}"
fi

"$SCRIPT_DIR/package_macos_zip.sh" "$OUTPUT_APP" "$OUTPUT_ZIP"

echo
echo "Release artifacts ready:"
echo "  App: $OUTPUT_APP"
echo "  ZIP: $OUTPUT_ZIP"
