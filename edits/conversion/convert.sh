#!/usr/bin/env bash
# Export FRESteamWorks ANE scripts, then convert AS3 to Haxe with ax4.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/config.json"
TMP_DIR="$SCRIPT_DIR/.tmp"
ANE_SRC="$TMP_DIR/ane-src"
ANE_EXPORT="$TMP_DIR/ane-export"
RUNTIME_CONFIG="$TMP_DIR/config.json"
AIRGLOBAL_TMP="$TMP_DIR/airglobal.swc"
LIBRARY_SWF="$TMP_DIR/library.swf"

AX4_DIR="${AX4_DIR:-}"
DECOMPILED_DIR="${DECOMPILED_DIR:-}"
FFDEC="${FFDEC_HOME:-}"
AIR_SDK="${AIR_SDK:-}"
ANE_PATH=""
KEEP_TMP=0
PREPARE_ONLY=0
BUILD_AX4=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  --ax4 DIR           ax4 checkout (or set AX4_DIR). Default: ../ax4
  --decompiled DIR    Dungeon-Rampage-Decompiled checkout (or set DECOMPILED_DIR).
                      Default: ../Dungeon-Rampage-Decompiled
  --ffdec PATH        ffdec, ffdec.sh, or ffdec.jar (or set FFDEC_HOME)
  --air-sdk DIR       HARMAN AIR SDK (or set AIR_SDK). Used to find airglobal.swc
  --ane PATH          FRESteamWorks.ane, or a directory containing library.swf
  --no-build-ax4      Use ax4's existing converter.jar instead of rebuilding it
  --prepare-only      Export ANE scripts and write the runtime config, then stop
  --keep-tmp          Keep edits/conversion/.tmp after a successful run
  -h, --help          Show this help

Sibling layout expected by the committed config.json:

  ax4/
  Dungeon-Rampage-Decompiled/
  Dungeon-Rampage-Haxe/
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ax4) AX4_DIR="$2"; shift 2 ;;
    --decompiled) DECOMPILED_DIR="$2"; shift 2 ;;
    --ffdec) FFDEC="$2"; shift 2 ;;
    --air-sdk) AIR_SDK="$2"; shift 2 ;;
    --ane) ANE_PATH="$2"; shift 2 ;;
    --no-build-ax4) BUILD_AX4=0; shift ;;
    --prepare-only) PREPARE_ONLY=1; shift ;;
    --keep-tmp) KEEP_TMP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

die() {
  echo "error: $*" >&2
  exit 1
}

relpath() {
  local target="$1"
  local base="$2"
  if command -v realpath >/dev/null 2>&1; then
    if realpath --relative-to="$base" "$target" 2>/dev/null; then
      return 0
    fi
  fi
  local source dest common result forward
  source="$(cd "$base" && pwd)"
  if [[ -d "$target" ]]; then
    dest="$(cd "$target" && pwd)"
  else
    dest="$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"
  fi
  if [[ "$source" == "$dest" ]]; then
    echo "."
    return 0
  fi
  common="$source"
  result=""
  while [[ "$dest" != "$common" && "$dest" != "$common"/* ]]; do
    common="$(dirname "$common")"
    result="../$result"
  done
  if [[ "$common" == "/" ]]; then
    forward="${dest#/}"
  else
    forward="${dest#"$common"/}"
  fi
  printf '%s%s\n' "$result" "$forward"
}

find_sibling() {
  local name="$1"
  local dir="$ROOT/../$name"
  if [[ -d "$dir" ]]; then
    (cd "$dir" && pwd)
    return 0
  fi
  return 1
}

find_ax4_dir() {
  if [[ -n "$AX4_DIR" ]]; then
    [[ -d "$AX4_DIR" ]] || die "ax4 directory not found: $AX4_DIR"
    (cd "$AX4_DIR" && pwd)
    return 0
  fi
  find_sibling ax4 || die "ax4 not found. Pass --ax4 / AX4_DIR."
}

find_decompiled_dir() {
  if [[ -n "$DECOMPILED_DIR" ]]; then
    [[ -d "$DECOMPILED_DIR" ]] || die "Decompiled directory not found: $DECOMPILED_DIR"
    (cd "$DECOMPILED_DIR" && pwd)
    return 0
  fi
  find_sibling Dungeon-Rampage-Decompiled || die "Dungeon-Rampage-Decompiled not found. Pass --decompiled / DECOMPILED_DIR."
}

find_ffdec() {
  local files=()
  if [[ -n "$FFDEC" ]]; then
    if [[ -f "$FFDEC" ]]; then
      files+=("$FFDEC")
    else
      files+=(
        "$FFDEC/ffdec.sh"
        "$FFDEC/ffdec"
        "$FFDEC/dist/ffdec.jar"
        "$FFDEC/dist/ffdec-cli.jar"
        "$FFDEC/ffdec.jar"
      )
    fi
  fi
  local jpexs
  if jpexs="$(find_sibling jpexs-decompiler)"; then
    files+=(
      "$jpexs/dist/ffdec.jar"
      "$jpexs/dist/ffdec-cli.jar"
      "$jpexs/resources/ffdec.sh"
    )
  fi
  local cmd
  for cmd in ffdec ffdec.sh; do
    if command -v "$cmd" >/dev/null 2>&1; then
      files+=("$(command -v "$cmd")")
    fi
  done
  files+=(
    /usr/share/ffdec/ffdec.sh
    /usr/bin/ffdec
    /opt/ffdec/ffdec.sh
    "$HOME/FFDec/ffdec.sh"
  )
  local file
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      readlink -f "$file" 2>/dev/null || realpath "$file" 2>/dev/null || echo "$file"
      return 0
    fi
  done
  die "JPEXS FFDec not found. Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler. Pass --ffdec / FFDEC_HOME."
}

run_ffdec() {
  local ffdec_path="$1"
  shift
  export FFDEC_MEMORY="${FFDEC_MEMORY:-2048m}"
  if [[ "$ffdec_path" == *.jar ]]; then
    command -v java >/dev/null 2>&1 || die "java is required to run ffdec.jar"
    java -Xmx2048m -jar "$ffdec_path" "$@"
  else
    "$ffdec_path" "$@"
  fi
}

find_airglobal() {
  local sdk="$AIR_SDK"
  if [[ -z "$sdk" ]] && command -v haxelib >/dev/null 2>&1; then
    sdk="$(haxelib run lime config AIR_SDK 2>/dev/null || true)"
  fi
  local file=""
  if [[ -n "$sdk" ]]; then
    file="$sdk/frameworks/libs/air/airglobal.swc"
  fi
  if [[ -n "$file" && -f "$file" ]]; then
    readlink -f "$file" 2>/dev/null || realpath "$file" 2>/dev/null || echo "$file"
    return 0
  fi
  die "airglobal.swc not found. Pass --air-sdk / AIR_SDK, or set lime config AIR_SDK."
}

find_ane() {
  if [[ -n "$ANE_PATH" ]]; then
    [[ -e "$ANE_PATH" ]] || die "ANE path not found: $ANE_PATH"
    readlink -f "$ANE_PATH" 2>/dev/null || realpath "$ANE_PATH" 2>/dev/null || echo "$ANE_PATH"
    return 0
  fi
  local ane="$DECOMPILED_ABS/extensions/FRESteamWorks.ane"
  if [[ -e "$ane" ]]; then
    readlink -f "$ane" 2>/dev/null || realpath "$ane" 2>/dev/null || echo "$ane"
    return 0
  fi
  die "FRESteamWorks.ane not found in $DECOMPILED_ABS/extensions. Run the decompiled repo sync, or pass --ane."
}

normalize_copied() {
  local root="$1"
  if [[ -f "$root" ]]; then
    chmod a-x "$root"
    case "$root" in
      *.as|*.hx|*.xml|*.json|*.txt|*.md) sed -i 's/\r$//' "$root" ;;
    esac
    return
  fi
  [[ -d "$root" ]] || return 0
  find "$root" -type f -exec chmod a-x {} +
  find "$root" -type f \( -name '*.as' -o -name '*.hx' -o -name '*.xml' -o -name '*.json' -o -name '*.txt' -o -name '*.md' \) \
    -exec sed -i 's/\r$//' {} +
}

unpack_ane_to() {
  local ane="$1"
  local dest="$2"
  mkdir -p "$dest"
  if [[ -d "$ane" ]]; then
    cp -a "$ane"/. "$dest"/
    return 0
  fi
  if command -v unzip >/dev/null 2>&1; then
    unzip -qq -o "$ane" -d "$dest"
  else
    (cd "$dest" && jar xf "$ane")
  fi
}

# Same payload check as Dungeon-Rampage-Decompiled/tools/sync-from-official.sh
ane_trees_match() {
  local a="$1"
  local b="$2"
  local fa fb rel
  fa="$(cd "$a" && find . -type f ! -name mimetype | sort)"
  fb="$(cd "$b" && find . -type f ! -name mimetype | sort)"
  [[ "$fa" == "$fb" ]] || return 1
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    cmp -s "$a/$rel" "$b/$rel" || return 1
  done <<< "$fa"
  return 0
}

ane_payloads_match() {
  local src="$1"
  local dest="$2"
  [[ -e "$dest" ]] || return 1
  if [[ -f "$src" && -f "$dest" ]] && cmp -s "$src" "$dest"; then
    return 0
  fi
  local src_stage dest_stage
  src_stage="$(mktemp -d "${TMPDIR:-/tmp}/drh-ane-src.XXXXXX")"
  dest_stage="$(mktemp -d "${TMPDIR:-/tmp}/drh-ane-dst.XXXXXX")"
  unpack_ane_to "$src" "$src_stage"
  unpack_ane_to "$dest" "$dest_stage"
  local ok=0
  ane_trees_match "$src_stage" "$dest_stage" || ok=1
  rm -rf "$src_stage" "$dest_stage"
  return "$ok"
}

trees_match() {
  local a="$1"
  local b="$2"
  local fa fb rel
  fa="$(cd "$a" && find . -type f | sort)"
  fb="$(cd "$b" && find . -type f | sort)"
  [[ "$fa" == "$fb" ]] || return 1
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    cmp -s "$a/$rel" "$b/$rel" || return 1
  done <<< "$fa"
  return 0
}

install_official_tree() {
  local from="$1"
  local to="$2"
  local label="$3"
  [[ -d "$from" ]] || die "Decompiled $label not found: $from"
  if [[ -d "$to" ]] && trees_match "$from" "$to"; then
    echo "$label unchanged, keeping $to"
    return 0
  fi
  rm -rf "$to"
  cp -a "$from" "$to"
  normalize_copied "$to"
  echo "Updated $label"
}

install_game_data() {
  install_official_tree "$DECOMPILED_ABS/data/DbConfiguration" "$ROOT/DbConfiguration" "DbConfiguration"
  install_official_tree "$DECOMPILED_ABS/data/Resources" "$ROOT/Resources" "Resources"
}

install_ane() {
  local ane="$1"
  local packed="$ROOT/extensions/FRESteamWorks.ane"
  local unpacked="$ROOT/extensions/adl/FRESteamWorks.Unpacked.ane"
  if ane_payloads_match "$ane" "$packed"; then
    echo "ANE payloads unchanged, keeping $packed"
    if [[ ! -d "$unpacked" ]]; then
      mkdir -p "$unpacked"
      unpack_ane_to "$packed" "$unpacked"
      normalize_copied "$unpacked"
    fi
    return 0
  fi
  mkdir -p "$ROOT/extensions/adl"
  rm -rf "$unpacked"
  if [[ -d "$ane" ]]; then
    cp -a "$ane" "$unpacked"
    normalize_copied "$unpacked"
    return 0
  fi
  local src_abs dest_abs
  src_abs="$(readlink -f "$ane" 2>/dev/null || realpath "$ane" 2>/dev/null || echo "$ane")"
  dest_abs="$(readlink -f "$packed" 2>/dev/null || realpath "$packed" 2>/dev/null || echo "$packed")"
  if [[ "$src_abs" != "$dest_abs" ]]; then
    cp -a "$ane" "$packed"
  fi
  chmod a-x "$packed"
  mkdir -p "$unpacked"
  unpack_ane_to "$ane" "$unpacked"
  normalize_copied "$unpacked"
}

extract_library_swf() {
  local ane="$1"
  local dest="$2"
  if [[ -d "$ane" ]]; then
    [[ -f "$ane/library.swf" ]] || die "library.swf not found in $ane"
    cp -a "$ane/library.swf" "$dest"
    return 0
  fi
  local name=""
  if command -v unzip >/dev/null 2>&1; then
    name="$(unzip -Z -1 "$ane" | grep -E '(^|/)library\.swf$' | head -n 1 || true)"
    [[ -n "$name" ]] || die "no library.swf in $ane"
    unzip -p "$ane" "$name" > "$dest"
    return 0
  fi
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/drh-ane.XXXXXX")"
  (
    cd "$tmp"
    jar xf "$ane" library.swf >/dev/null 2>&1 || jar xf "$ane" >/dev/null
    if [[ -f library.swf ]]; then
      cp -a library.swf "$dest"
    else
      name="$(find . -name library.swf -print -quit || true)"
      [[ -n "$name" ]] || die "no library.swf in $ane"
      cp -a "$name" "$dest"
    fi
  )
  rm -rf "$tmp"
}

install_as_tree() {
  local export_dir="$1"
  local dest="$2"
  local scripts="$export_dir/scripts"
  [[ -d "$scripts" ]] || scripts="$export_dir"
  rm -rf "$dest"
  mkdir -p "$dest"
  local found=0
  local f rel
  while IFS= read -r -d '' f; do
    found=1
    rel="${f#"$scripts"/}"
    mkdir -p "$dest/$(dirname "$rel")"
    cp -a "$f" "$dest/$rel"
  done < <(find "$scripts" -type f -name '*.as' -print0)
  [[ "$found" -eq 1 ]] || die "FFDec produced no ActionScript files under $export_dir"
}

write_runtime_config() {
  [[ -f "$TEMPLATE" ]] || die "missing $TEMPLATE"
  # Same as convert.ps1: keep committed flags, rewrite only path fields.
  export DRH_GAME_SRC DRH_ANE_SRC DRH_COMPAT DRH_AIRGLOBAL
  DRH_GAME_SRC="$(relpath "$DECOMPILED_ABS/src" "$ROOT")"
  DRH_ANE_SRC="$(relpath "$ANE_SRC" "$ROOT")"
  DRH_COMPAT="$(relpath "$AX4_ABS/compat" "$ROOT")"
  DRH_AIRGLOBAL="$(relpath "$AIRGLOBAL_TMP" "$ROOT")"
  awk '
    function esc(s, t) {
      t = s
      gsub(/\\/, "\\\\", t)
      gsub(/"/, "\\\"", t)
      return t
    }
    BEGIN {
      game = esc(ENVIRON["DRH_GAME_SRC"])
      ane = esc(ENVIRON["DRH_ANE_SRC"])
      compat = esc(ENVIRON["DRH_COMPAT"])
      air = esc(ENVIRON["DRH_AIRGLOBAL"])
    }
    {
      if ($0 ~ /"hxout"/) {
        sub(/:[[:space:]]*"[^"]*"/, ": \"src\"")
        print
        next
      }
      if ($0 ~ /"src"[[:space:]]*:/) {
        print "  \"src\": ["
        print "    \"" game "\","
        print "    \"" ane "\""
        print "  ],"
        skip_src = 1
        next
      }
      if (skip_src) {
        if ($0 ~ /]/) skip_src = 0
        next
      }
      if ($0 ~ /"unit"/) {
        sub(/:[[:space:]]*"[^"]*"/, ": \"" compat "\"")
        print
        next
      }
      if ($0 ~ /"swc"[[:space:]]*:/) { in_swc = 1; print; next }
      if (in_swc && $0 ~ /"[^"]*"/ && $0 !~ /"swc"/) {
        sub(/"[^"]*"/, "\"" air "\"")
        in_swc = 0
        print
        next
      }
      print
    }
  ' "$TEMPLATE" > "$RUNTIME_CONFIG"
}

AX4_ABS="$(find_ax4_dir)"
DECOMPILED_ABS="$(find_decompiled_dir)"
FFDEC_PATH="$(find_ffdec)"
ANE_ABS="$(find_ane)"
AIRGLOBAL_ABS="$(find_airglobal)"
JAR="$AX4_ABS/converter.jar"

command -v java >/dev/null 2>&1 || die "java is required to run ax4"

mkdir -p "$TMP_DIR"
cp -a "$AIRGLOBAL_ABS" "$AIRGLOBAL_TMP"

echo "ax4:        $AX4_ABS"
echo "Decompiled: $DECOMPILED_ABS"
echo "FFDec:      $FFDEC_PATH"
echo "ANE:        $ANE_ABS"
echo "airglobal:  $AIRGLOBAL_ABS"

echo "Updating extensions/ ..."
install_ane "$ANE_ABS"

echo "Updating DbConfiguration/ and Resources/ ..."
install_game_data

echo "Extracting library.swf ..."
extract_library_swf "$ANE_ABS" "$LIBRARY_SWF"

rm -rf "$ANE_EXPORT"
mkdir -p "$ANE_EXPORT"
echo "Decompiling ANE library.swf ..."
run_ffdec "$FFDEC_PATH" \
  -config paramNamesEnable=true \
  -exportTimeout 1800 \
  -export script \
  "$ANE_EXPORT" \
  "$LIBRARY_SWF"

install_as_tree "$ANE_EXPORT" "$ANE_SRC"
write_runtime_config
echo "Wrote $RUNTIME_CONFIG"

if [[ "$PREPARE_ONLY" -eq 1 ]]; then
  echo "Prepare-only: stopping before ax4."
  if [[ "$KEEP_TMP" -eq 0 ]]; then
    rm -rf "$TMP_DIR"
  fi
  exit 0
fi

# ax4 does not track converter.jar: build it so it matches the ax4 commit the stamp records.
if [[ "$BUILD_AX4" -eq 1 ]]; then
  [[ -f "$AX4_ABS/build.hxml" ]] || die "ax4 build.hxml not found in $AX4_ABS"
  echo "Building ax4 ..."
  (cd "$AX4_ABS" && npx haxe build.hxml)
fi
[[ -f "$JAR" ]] || die "converter.jar not found in $AX4_ABS. Drop --no-build-ax4."

echo "Converting with ax4 ..."
(
  cd "$ROOT"
  java -jar "$JAR" "$(relpath "$RUNTIME_CONFIG" "$ROOT")"
)

echo "Moving com.amanitadesign to src-steam ..."
mkdir -p "$ROOT/src-steam/com"
rm -rf "$ROOT/src-steam/com/amanitadesign"
[[ -d "$ROOT/src/com/amanitadesign" ]] || die "conversion did not produce src/com/amanitadesign"
mv "$ROOT/src/com/amanitadesign" "$ROOT/src-steam/com/"
normalize_copied "$ROOT/src-steam/com/amanitadesign"

if [[ "$KEEP_TMP" -eq 0 ]]; then
  rm -rf "$TMP_DIR"
fi

echo "Done."
