#!/usr/bin/env bash
# build.sh [suffix] [lime arguments] : builds the game with the overlay as
# "Dungeon Rampage Haxe.<suffix>" (bench) and puts back the executable that was there.
# FP=1 builds with frame pointers, from objects of their own (bin/linux/obj/obj/linux64-fp).
set -u
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
suffix="${1:-bench}"
[ $# -gt 0 ] && shift
exe="$BIN_DIR/Dungeon Rampage Haxe"
log="$RUNS/build_$suffix.log"
obj="$ROOT/bin/linux/obj/obj"

if pgrep -f "^./Dungeon Rampage Haxe" > /dev/null; then
  echo "The game is running: a build rewrites lime.ndll under it and it dies of a bus error." >&2
  exit 1
fi
python3 "$BENCH/make_overlay.py" "$ROOT" "$ROOT/bin/bench-overlay" || exit 1

restore() {
  [ -f "$exe.before-bench" ] && mv -f "$exe.before-bench" "$exe"
  if [ "${FP:-0}" = 1 ] && [ -d "$obj/linux64-no-fp" ]; then
    mv "$obj/linux64" "$obj/linux64-fp" && mv "$obj/linux64-no-fp" "$obj/linux64"
  fi
}
trap restore EXIT

[ -f "$exe" ] && cp -p "$exe" "$exe.before-bench"
if [ "${FP:-0}" = 1 ]; then
  # hxcpp does not recompile an object when the compiler's flags change
  mkdir -p "$obj/linux64-fp"
  mv "$obj/linux64" "$obj/linux64-no-fp" && mv "$obj/linux64-fp" "$obj/linux64" || exit 1
  export CXX="$BENCH/gxx-fp"
fi

cd "$ROOT"
if haxelib run lime build project.xml linux --haxeflag="-cp $ROOT/bin/bench-overlay" "$@" > "$log" 2>&1; then
  mv -f "$exe" "$exe.$suffix"
  echo "$exe.$suffix"
else
  echo "The build failed, see $log" >&2
  grep -n -E "^[^ ].*: (characters|lines) |error:" "$log" | head -20 >&2
  exit 1
fi
