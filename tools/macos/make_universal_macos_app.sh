#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  make_universal_macos_app.sh [--no-sign] <x86_64.app> <arm64.app> [output.app]

Examples:
  make_universal_macos_app.sh \
    bin/macos/bin/DungeonBustersProject-x86_64.app \
    bin/macos/bin/DungeonBustersProject-arm64.app \
    bin/macos/bin/DungeonBustersProject.app

  make_universal_macos_app.sh --no-sign \
    bin/macos/bin/DungeonBustersProject-x86_64.app \
    bin/macos/bin/DungeonBustersProject-arm64.app

Notes:
  - The output bundle is copied from the arm64 app, then Mach-O files present in both bundles
    are merged with lipo.
  - By default the script removes inherited signatures, then ad-hoc signs the merged `.app`
    bundle and verifies it. This is suitable for local testing only.
  - Use `--no-sign` if you want the merged app left unsigned.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

warn() {
  echo "Warning: $*" >&2
}

strip_inherited_signatures() {
  local app_path="$1"

  find "$app_path" -name _CodeSignature -type d -prune -exec rm -rf {} +
}

is_macho() {
  local path="$1"
  file -b "$path" | grep -q "Mach-O"
}

archs_for() {
  lipo -archs "$1" 2>/dev/null || true
}

default_output_path() {
  local arm_app="$1"
  local output="$arm_app"

  output="${output%-arm64.app}.app"
  output="${output%-aarch64.app}.app"
  output="${output%-x86_64.app}.app"

  printf '%s\n' "$output"
}

DO_SIGN=1
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-sign)
      DO_SIGN=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL[@]}"

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage >&2
  exit 1
fi

X86_APP="$1"
ARM_APP="$2"
OUTPUT_APP="${3:-$(default_output_path "$ARM_APP")}"

require_cmd ditto
require_cmd file
require_cmd lipo

if [[ $DO_SIGN -eq 1 ]]; then
  require_cmd codesign
fi

if [[ ! -d "$X86_APP" ]]; then
  echo "x86_64 app not found: $X86_APP" >&2
  exit 1
fi

if [[ ! -d "$ARM_APP" ]]; then
  echo "arm64 app not found: $ARM_APP" >&2
  exit 1
fi

echo "Creating output bundle: $OUTPUT_APP"
rm -rf "$OUTPUT_APP"
ditto "$ARM_APP" "$OUTPUT_APP"
strip_inherited_signatures "$OUTPUT_APP"

while IFS= read -r relative_path; do
  x86_file="$X86_APP/$relative_path"
  arm_file="$ARM_APP/$relative_path"
  out_file="$OUTPUT_APP/$relative_path"

  if [[ ! -f "$arm_file" ]]; then
    echo "Skipping missing counterpart: $relative_path"
    continue
  fi

  if ! is_macho "$x86_file" || ! is_macho "$arm_file"; then
    continue
  fi

  x86_arches="$(archs_for "$x86_file")"
  arm_arches="$(archs_for "$arm_file")"

  if [[ -z "$x86_arches" || -z "$arm_arches" ]]; then
    continue
  fi

  if [[ "$x86_arches" == "$arm_arches" ]]; then
    continue
  fi

  echo "Merging $relative_path"
  lipo -create "$x86_file" "$arm_file" -output "$out_file"
done < <(cd "$X86_APP" && find Contents -type f | sort)

if [[ $DO_SIGN -eq 1 ]]; then
  echo "Ad-hoc signing bundle"
  codesign --force --deep --sign - "$OUTPUT_APP"
  codesign --verify --deep --strict --verbose=2 "$OUTPUT_APP"
fi

echo
echo "Universal app ready: $OUTPUT_APP"
echo "Architecture summary:"
find "$OUTPUT_APP/Contents" -type f | while IFS= read -r path; do
  if is_macho "$path"; then
    printf '  %s -> %s\n' "${path#$OUTPUT_APP/}" "$(archs_for "$path")"
  fi
done
