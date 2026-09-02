#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

FEATURE_FLAGS_FILE="$PROJECT_ROOT/src/brain/utils/FeatureFlags.hx"
PROJECT_FILE="$PROJECT_ROOT/project.xml"
OPTIONS_FILE="$SCRIPT_DIR/launch_options.tsv"
STAMP_FILE="$PROJECT_ROOT/edits/conversion/stamp"
DEFAULT_DIST_DIR="$PROJECT_ROOT/dist"

usage() {
  cat <<'EOF'
Usage:
  tools/release/generate_manifest.sh [VERSION] [DIST_DIR]
  tools/release/generate_manifest.sh [DIST_DIR]

Example:
  tools/release/generate_manifest.sh
  tools/release/generate_manifest.sh V3 release-dist
  tools/release/generate_manifest.sh release-dist

Expected archives in DIST_DIR:
  Dungeon.Rampage.Haxe.VERSION.Linux.tar.gz
  Dungeon.Rampage.Haxe.VERSION.Windows.zip
  Dungeon.Rampage.Haxe.VERSION.macOS.zip

The script derives frame-rate metadata from src/DungeonBustersProject.hx
and keeps tools/release/launch_options.tsv synchronized with
src/brain/utils/FeatureFlags.hx:
  - removed options are removed from launch_options.tsv
  - flag names, config keys and default values are refreshed from source
  - recommended values are preserved unless they matched the previous default
  - new flags are added and, in an interactive terminal, the script asks for
    the recommended value

steam_buildid is copied from edits/conversion/stamp (the official Steam
BuildID this src/ was converted from). DRH Launcher compares it to the
live public branch so it can warn when official Dungeon Rampage has moved on.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

VERSION=""
DIST_DIR="$DEFAULT_DIST_DIR"

if [[ $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

if [[ $# -eq 1 ]]; then
  if [[ -d "$1" ]]; then
    DIST_DIR="$1"
  else
    VERSION="$1"
  fi
elif [[ $# -eq 2 ]]; then
  VERSION="$1"
  DIST_DIR="$2"
fi

DIST_DIR="$(cd -- "$DIST_DIR" && pwd)"

infer_version() {
  local versions=()
  local path archive version

  shopt -s nullglob
  for path in "$DIST_DIR"/Dungeon.Rampage.Haxe.*.Linux.tar.gz; do
    archive="$(basename -- "$path")"
    version="${archive#Dungeon.Rampage.Haxe.}"
    version="${version%.Linux.tar.gz}"
    if [[ -f "$DIST_DIR/Dungeon.Rampage.Haxe.$version.Windows.zip" \
      && -f "$DIST_DIR/Dungeon.Rampage.Haxe.$version.macOS.zip" ]]; then
      versions+=("$version")
    fi
  done
  shopt -u nullglob

  case "${#versions[@]}" in
    0)
      printf 'Could not infer release version from %s. Expected the Linux, Windows and macOS archives for one version.\n' "$DIST_DIR" >&2
      exit 1
      ;;
    1)
      printf '%s\n' "${versions[0]}"
      ;;
    *)
      printf 'Multiple complete releases found in %s: %s\n' "$DIST_DIR" "${versions[*]}" >&2
      printf 'Pass the version explicitly, for example: tools/release/generate_manifest.sh %s %s\n' "${versions[0]}" "$DIST_DIR" >&2
      exit 1
      ;;
  esac
}

if [[ -z "$VERSION" ]]; then
  VERSION="$(infer_version)"
  printf 'Inferred release version: %s\n' "$VERSION" >&2
fi

OUTPUT="$DIST_DIR/Dungeon.Rampage.Haxe.$VERSION.manifest.json"

platform_archive() {
  local platform="$1"
  case "$platform" in
    linux-x64) printf 'Dungeon.Rampage.Haxe.%s.Linux.tar.gz\n' "$VERSION" ;;
    windows-x64) printf 'Dungeon.Rampage.Haxe.%s.Windows.zip\n' "$VERSION" ;;
    macos-universal) printf 'Dungeon.Rampage.Haxe.%s.macOS.zip\n' "$VERSION" ;;
    *) printf 'unknown platform: %s\n' "$platform" >&2; return 1 ;;
  esac
}

parse_feature_flags() {
  perl -0ne '
    while (/addFeatureFlag\(\s*"([^"]+)"\s*,\s*(true|false)(?:\s*,\s*(null|"[^"]+"))?(?:\s*,\s*(null|"[^"]+"))?\s*\)/ig) {
      my ($name, $default, $cli, $config) = ($1, lc($2), $3, $4);
      $cli = (!defined($cli) || $cli eq "null") ? "--$name" : substr($cli, 1, -1);
      $config = (!defined($config) || $config eq "null") ? "$name" : substr($config, 1, -1);
      print "$name\t$cli\t$default\t$config\n";
    }
  ' "$FEATURE_FLAGS_FILE"
}

previous_option_for() {
  local name="$1"
  awk -F '\t' -v name="$name" '
    $0 !~ /^#/ && NF >= 5 && $1 == name { print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5; found = 1; exit }
    END { if (!found) exit 1 }
  ' "$OPTIONS_FILE" 2>/dev/null || true
}

parsed_option_exists() {
  local parsed_options_file="$1"
  local name="$2"
  awk -F '\t' -v name="$name" '
    $1 == name { found = 1; exit }
    END { exit found ? 0 : 1 }
  ' "$parsed_options_file"
}

ask_recommended() {
  local name="$1"
  local flag="$2"
  local default="$3"
  local answer=""

  while true; do
    read -r -p "Recommended value for $flag ($name), default $default [true/false, Enter=$default]: " answer
    answer="${answer:-$default}"
    case "$answer" in
      true|false) printf '%s\n' "$answer"; return 0 ;;
      *) printf 'Please answer true or false.\n' >&2 ;;
    esac
  done
}

sync_launch_options() {
  local parsed tmp
  parsed="$(mktemp)"
  tmp="$(mktemp)"
  parse_feature_flags > "$parsed"
  printf '# name\tflag\tdefault\tconfig_key\trecommended\n' > "$tmp"

  local had_new=0
  while IFS=$'\t' read -r name flag default config_key; do
    [[ -n "$name" ]] || continue

    local previous old_name old_flag old_default old_config_key recommended
    previous="$(previous_option_for "$name")"
    if [[ -n "$previous" ]]; then
      IFS=$'\t' read -r old_name old_flag old_default old_config_key recommended <<< "$previous"
      if [[ "$old_default" != "$default" && "$recommended" == "$old_default" ]]; then
        recommended="$default"
        printf 'Updated %s default %s -> %s and moved recommended with it.\n' "$name" "$old_default" "$default" >&2
      elif [[ "$old_default" != "$default" ]]; then
        printf 'Updated %s default %s -> %s and preserved recommended=%s.\n' "$name" "$old_default" "$default" "$recommended" >&2
      fi
    else
      had_new=1
      if [[ -t 0 ]]; then
        recommended="$(ask_recommended "$name" "$flag" "$default")"
      else
        recommended="$default"
        printf 'Added %s with recommended=%s. Review %s before release.\n' "$name" "$recommended" "$OPTIONS_FILE" >&2
      fi
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$flag" "$default" "$config_key" "$recommended" >> "$tmp"
  done < "$parsed"

  if [[ -f "$OPTIONS_FILE" ]]; then
    while IFS=$'\t' read -r name _; do
      [[ -n "$name" && "$name" != \#* ]] || continue
      if ! parsed_option_exists "$parsed" "$name"; then
        printf 'Removed %s from %s because it is no longer declared in FeatureFlags.hx.\n' "$name" "$OPTIONS_FILE" >&2
      fi
    done < "$OPTIONS_FILE"
  fi

  if ! cmp -s "$tmp" "$OPTIONS_FILE"; then
    mv "$tmp" "$OPTIONS_FILE"
    printf 'Updated %s\n' "$OPTIONS_FILE" >&2
  else
    rm "$tmp"
  fi
  rm "$parsed"

  if [[ "$had_new" == 1 && ! -t 0 ]]; then
    printf 'New launch options were added non-interactively. Review recommendations and rerun.\n' >&2
    exit 1
  fi
}

require_archive() {
  local archive="$1"
  local path="$DIST_DIR/$archive"
  if [[ ! -f "$path" ]]; then
    printf 'Missing release archive: %s\n' "$path" >&2
    exit 1
  fi
}

sync_launch_options

for platform in linux-x64 windows-x64 macos-universal; do
  require_archive "$(platform_archive "$platform")"
done

python3 - "$VERSION" "$DIST_DIR" "$OPTIONS_FILE" "$PROJECT_FILE" "$OUTPUT" "$STAMP_FILE" <<'PY'
import csv
import hashlib
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

version = sys.argv[1]
dist_dir = Path(sys.argv[2])
options_file = Path(sys.argv[3])
project_file = Path(sys.argv[4])
output = Path(sys.argv[5])
stamp_file = Path(sys.argv[6])


def read_steam_buildid(path: Path) -> int:
    if not path.is_file():
        raise SystemExit(
            f"Could not read official Steam BuildID from {path}. "
            "The conversion stamp is required to write steam_buildid into the release manifest."
        )
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("buildid="):
            value = line.split("=", 1)[1].strip()
            if value.isdigit() and int(value) > 0:
                return int(value)
            raise SystemExit(f"Invalid buildid in {path}: {value!r}")
    raise SystemExit(f"No buildid= line in {path}")


steam_buildid = read_steam_buildid(stamp_file)

archive_names = {
    "linux-x64": f"Dungeon.Rampage.Haxe.{version}.Linux.tar.gz",
    "windows-x64": f"Dungeon.Rampage.Haxe.{version}.Windows.zip",
    "macos-universal": f"Dungeon.Rampage.Haxe.{version}.macOS.zip",
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


platforms = {}
for platform, archive in archive_names.items():
    path = dist_dir / archive
    platforms[platform] = {
        "archive": archive,
        "sha256": sha256_file(path),
        "size": path.stat().st_size,
    }

game_arguments = []
with options_file.open(newline="", encoding="utf-8") as file:
    for row in csv.reader((line for line in file if not line.startswith("#")), delimiter="\t"):
        if len(row) != 5:
            continue
        name, flag, default, config_key, recommended_value = row
        default_bool = default == "true"
        recommended_bool = recommended_value == "true"
        argument = {
            "name": name,
            "flag": flag,
            "default": default_bool,
        }
        if config_key != name:
            argument["config_key"] = config_key
        if recommended_bool != default_bool:
            argument["recommended"] = recommended_bool
        game_arguments.append(argument)

source_file = project_file.parent / "src" / "DungeonBustersProject.hx"
source = source_file.read_text(encoding="utf-8")


def float_constant(name: str) -> int:
    match = re.search(
        rf"static\s+inline\s+final\s+{name}:Float\s*=\s*([0-9]+);",
        source,
    )
    if match is None:
        raise SystemExit(f"Could not read {name} from {source_file}")
    return int(match.group(1))


flag_match = re.search(
    r'static\s+inline\s+final\s+FRAME_RATE_ARGUMENT:String\s*=\s*"([^"]+)";',
    source,
)
if flag_match is None:
    raise SystemExit(f"Could not read FRAME_RATE_ARGUMENT from {source_file}")

flag = flag_match.group(1)
custom_min = float_constant("MIN_FRAME_RATE")
custom_max = float_constant("MAX_FRAME_RATE")
auto_fallback = float_constant("AUTO_FRAME_RATE_FALLBACK")
auto_step = float_constant("AUTO_FRAME_RATE_STEP")
auto_maximum = float_constant("AUTO_FRAME_RATE_MAXIMUM")
if not flag.startswith("--") or len(flag) <= 2:
    raise SystemExit(f"Invalid FRAME_RATE_ARGUMENT in {source_file}: {flag!r}")
if custom_min <= 0 or custom_max < custom_min:
    raise SystemExit(f"Invalid custom frame-rate range in {source_file}")
if auto_step <= 0 or auto_maximum < auto_step or auto_maximum % auto_step != 0:
    raise SystemExit(f"Invalid automatic frame-rate policy in {source_file}")
if (
    auto_fallback < auto_step
    or auto_fallback > auto_maximum
    or auto_fallback % auto_step != 0
):
    raise SystemExit(f"Automatic frame-rate fallback must be one of the generated presets in {source_file}")
if auto_step < custom_min or auto_maximum > custom_max:
    raise SystemExit(f"Frame-rate presets must fit inside the custom range in {source_file}")

frame_rate = {
    "flag": flag,
    "auto": {
        "fallback": auto_fallback,
        "step": auto_step,
        "maximum": auto_maximum,
    },
    "custom_min": custom_min,
    "custom_max": custom_max,
}

window = ET.parse(project_file).getroot().find("window")
project_default = None if window is None else window.get("fps")
if project_default != str(auto_fallback):
    raise SystemExit(
        f"AUTO_FRAME_RATE_FALLBACK in {source_file} ({auto_fallback}) does not match "
        f"{project_file} ({project_default!r})"
    )

manifest = {
    "version": version,
    "steam_buildid": steam_buildid,
    "platforms": platforms,
    "launch_options": {
        "frame_rate": frame_rate,
        "game_arguments": game_arguments,
    },
}

output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(output)
print(f"steam_buildid={steam_buildid}", file=sys.stderr)
PY
