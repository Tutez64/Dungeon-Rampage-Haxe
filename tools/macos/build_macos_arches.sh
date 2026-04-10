#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  build_macos_arches.sh [--project <project.xml>] [--openfl <command>] [--target <macos>] [--build-app <app>] [--x86-app <app>] [--arm-app <app>] [--] [extra openfl args...]

Examples:
  build_macos_arches.sh
  build_macos_arches.sh -- -debug
  build_macos_arches.sh -- -Dfinal
  build_macos_arches.sh --project project.xml --openfl openfl

Notes:
  - Builds both x86_64 and arm64 variants.
  - Renames the generated app after each build so both variants can coexist.
  - Extra args after `--` are forwarded to each `openfl build` invocation.
EOF
}

PROJECT_FILE="project.xml"
OPENFL_BIN="${OPENFL_BIN:-openfl}"
TARGET_NAME="macos"
BUILD_APP="bin/macos/bin/DungeonBustersProject.app"
X86_APP=""
ARM_APP=""
EXTRA_ARGS=()

resolve_openfl_cmd() {
  if command -v "$OPENFL_BIN" >/dev/null 2>&1; then
    OPENFL_CMD=("$OPENFL_BIN")
    return
  fi

  if [[ "$OPENFL_BIN" == "openfl" ]] && command -v haxelib >/dev/null 2>&1; then
    OPENFL_CMD=(haxelib run openfl)
    return
  fi

  echo "OpenFL command not found: $OPENFL_BIN" >&2
  echo "Install the alias with 'haxelib run openfl setup -alias -y' or pass --openfl <command>." >&2
  exit 1
}

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
    --build-app)
      BUILD_APP="${2:-}"
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

if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "Project file not found: $PROJECT_FILE" >&2
  exit 1
fi

resolve_openfl_cmd

if [[ -z "$X86_APP" || -z "$ARM_APP" ]]; then
  BUILD_DIR="$(dirname "$BUILD_APP")"
  BUILD_NAME="$(basename "$BUILD_APP")"
  BUILD_STEM="${BUILD_NAME%.app}"

  if [[ -z "$X86_APP" ]]; then
    X86_APP="$BUILD_DIR/$BUILD_STEM-x86_64.app"
  fi

  if [[ -z "$ARM_APP" ]]; then
    ARM_APP="$BUILD_DIR/$BUILD_STEM-arm64.app"
  fi
fi

move_built_app() {
  local source_app="$1"
  local target_app="$2"

  if [[ ! -d "$source_app" ]]; then
    echo "Built app not found: $source_app" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_app")"
  rm -rf "$target_app"
  mv "$source_app" "$target_app"
}

echo "Building macOS x86_64"
rm -rf "$BUILD_APP"
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  "${OPENFL_CMD[@]}" build "$PROJECT_FILE" "$TARGET_NAME" -x86_64 "${EXTRA_ARGS[@]}"
else
  "${OPENFL_CMD[@]}" build "$PROJECT_FILE" "$TARGET_NAME" -x86_64
fi
move_built_app "$BUILD_APP" "$X86_APP"
echo "Saved x86_64 app to $X86_APP"

echo
echo "Building macOS arm64"
rm -rf "$BUILD_APP"
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  "${OPENFL_CMD[@]}" build "$PROJECT_FILE" "$TARGET_NAME" -arm64 "${EXTRA_ARGS[@]}"
else
  "${OPENFL_CMD[@]}" build "$PROJECT_FILE" "$TARGET_NAME" -arm64
fi
move_built_app "$BUILD_APP" "$ARM_APP"
echo "Saved arm64 app to $ARM_APP"

echo
echo "Builds completed"
