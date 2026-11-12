#!/usr/bin/env bash
# run.sh <name> : plays DRH_PERF_SCRIPT (town, Proving Grounds, walk, fight by default) and prints a line per phase.
# BIN names the executable in bin/linux/bin, MAXTIME the seconds after which the game is killed (360),
# WRAP a command to run it under, ARGS its arguments, PAD (still or stick) a virtual controller to
# plug in with Steam Input on. Results go to profiling/bench/<name>.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"
name="$1"
out="$RUNS/$name"
rm -rf "$out"; mkdir -p "$out/shots"
: "${DRH_PERF_SCRIPT:=state:TownState:90;wait:10;shot:town;gc;phase:town:10;$ENTER_LEVEL;wait:12;shot:dungeon;gc;phase:idle:10;keydown:UP;phase:walk:5;keyup:UP;phase:fight:30;shot:end;gc;phase:after:10;quit}"
export DRH_PERF_OUT="$out" DRH_PERF_SCRIPT STEAM_APP_ID=3053950
[ -x "$BIN_DIR/$BIN" ] || { echo "No $BIN_DIR/$BIN: build it with build.sh, or name another with BIN." >&2; exit 1; }
cd "$BIN_DIR"
inhibit=""
command -v kde-inhibit > /dev/null && inhibit="kde-inhibit --power --screenSaver"
padpid=""
if [ -n "${PAD:-}" ]; then
  python3 -I "$BENCH/vpad.py" "$PAD" > "$out/pad.log" 2>&1 &
  padpid=$!
  sleep 4
  ARGS="${ARGS:-} --experimental-use-steam-input true"
fi
launch() {
  $inhibit ${WRAP:-} "./$BIN" ${ARGS:-} > "$out/game.log" 2>&1 &
  sleep 1
  pid=$(pgrep -n -f "^./Dungeon Rampage Haxe" || true)
  echo "pid=$pid" > "$out/session.txt"
  start=$(date +%s)
}
launch
launches=1
echo "epoch,rss_kb,anon_kb,file_kb,vram_kb,gtt_kb" > "$out/mem.csv"
shots_done=0
while [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; do
  now=$(date +%s)
  # Steam sometimes never gives the login ticket: the bot has not started and the game says it waits
  if [ ! -f "$out/events.log" ] && [ $((now - start)) -gt 40 ] && [ "$launches" -lt 3 ] && grep -q "Steam login ticket not received" "$out/game.log"; then
    kill "$pid"; sleep 3; kill -9 "$pid" 2>/dev/null
    launches=$((launches + 1))
    launch
    continue
  fi
  if [ $((now - start)) -gt "${MAXTIME:-360}" ]; then echo "TIMEOUT kill" >> "$out/session.txt"; kill "$pid"; sleep 3; kill -9 "$pid" 2>/dev/null; break; fi
  st=$(awk '/^VmRSS:/{r=$2} /^RssAnon:/{a=$2} /^RssFile:/{f=$2} END{printf "%d,%d,%d", r,a,f}' /proc/$pid/status 2>/dev/null)
  gpu=$(cat /proc/$pid/fdinfo/* 2>/dev/null | awk '/^drm-client-id:/{id=$2} /^drm-memory-vram:/{v[id]=$2} /^drm-memory-gtt:/{g[id]=$2} END{for(i in v){sv+=v[i]; sg+=g[i]} printf "%d,%d", sv, sg}')
  echo "$(date +%s.%N | cut -c1-14),$st,$gpu" >> "$out/mem.csv"
  if [ -f "$out/events.log" ]; then
    if ! grep -q bot_start "$out/session.txt"; then
      echo "bot_start=$(stat -c %.3Y "$out/events.log" | tr , .)" >> "$out/session.txt"
      [ -n "$padpid" ] && "$BENCH/refocus.sh" "$pid"
    fi
    n=$(grep -c " SHOT " "$out/events.log")
    if [ "$n" -gt "$shots_done" ] && command -v spectacle > /dev/null; then
      shots_done=$n
      sname=$(grep " SHOT " "$out/events.log" | tail -1 | awk '{print $3}')
      (sleep 0.7; spectacle -b -n -f -o "$out/shots/$sname.png" >/dev/null 2>&1; [ -n "${DRH_BENCH_SHOT_CROP:-}" ] && convert "$out/shots/$sname.png" -crop "$DRH_BENCH_SHOT_CROP" +repage "$out/shots/$sname.png" 2>/dev/null) &
    fi
  fi
  sleep 1
done
[ -n "$padpid" ] && kill "$padpid" 2>/dev/null
wait
echo "duration=$(( $(date +%s) - start ))" >> "$out/session.txt"
python3 "$BENCH/summ.py" "$out"
grep -E "speed_hack|LogCheater" "$out/game.log" | head -3
tail -4 "$out/game.log" | cut -c1-120
