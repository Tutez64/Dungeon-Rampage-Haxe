#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
resources_root="$project_root/Resources"
output_path="$project_root/generated_swf_libraries.xml"
preload_rules_path="$script_dir/swf_preload.txt"
generate_rules_path="$script_dir/swf_generate.txt"

read_rules() {
	local path="$1"

	if [[ ! -f "$path" ]]; then
		return 0
	fi

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line#"${line%%[![:space:]]*}"}"
		line="${line%"${line##*[![:space:]]}"}"

		if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
			printf '%s\n' "$line"
		fi
	done < "$path"
}

matches_rule() {
	local relative_path="$1"
	shift || true

	local rule
	for rule in "$@"; do
		if [[ "$relative_path" == $rule ]]; then
			return 0
		fi
	done

	return 1
}

get_library_id() {
	local relative_path="$1"
	python3 - "$relative_path" <<'PY'
import re
import sys

path = sys.argv[1].replace("\\", "/")
if path.startswith("./"):
    path = path[2:]

identifier = "ax4_swf_" + re.sub(r"[^a-z0-9]", "_", path.lower())
identifier = re.sub(r"_+", "_", identifier).rstrip("_")
print(identifier)
PY
}

mapfile -t preload_rules < <(read_rules "$preload_rules_path")
mapfile -t generate_rules < <(read_rules "$generate_rules_path")

declare -a lines
lines+=('<?xml version="1.0" encoding="utf-8"?>')
lines+=('<project>')

count=0
while IFS= read -r swf_path; do
	relative_path="${swf_path#"$project_root"/}"
	relative_path="${relative_path//\\//}"

	preload_value="false"
	if matches_rule "$relative_path" "${preload_rules[@]}"; then
		preload_value="true"
	fi

	generate_value="false"
	if matches_rule "$relative_path" "${generate_rules[@]}"; then
		generate_value="true"
	fi

	library_id="$(get_library_id "$relative_path")"
	lines+=($'\t'"<library path=\"$relative_path\" id=\"$library_id\" preload=\"$preload_value\" generate=\"$generate_value\" />")
	count=$((count + 1))
done < <(find "$resources_root" -type f \( -name '*.swf' -o -name '*.SWF' \) | LC_ALL=C sort)

lines+=('</project>')

printf '%s\n' "${lines[@]}" > "$output_path"
printf 'Generated %d SWF libraries in %s\n' "$count" "$output_path"
