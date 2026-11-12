#!/usr/bin/env bash
# refocus.sh <pid> : gives the focus to another window, then back to the window of <pid> (KWin).
# Steam hands a controller to a game once it has seen its window take the focus, which it misses
# when the window is focused before the game has told Steam it runs.
pid="$1"
command -v qdbus6 > /dev/null || { echo "refocus.sh: no qdbus6, the game may not get the controller" >&2; exit 0; }
dir=$(mktemp -d)
run() {
  echo "$1" > "$dir/s.js"
  local name="drhfocus$RANDOM"
  local id
  id=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$dir/s.js" "$name")
  qdbus6 org.kde.KWin "/Scripting/Script$id" org.kde.kwin.Script.run > /dev/null
  sleep 0.3
  qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$name" > /dev/null
}
run "var l = workspace.windowList(); for (var i = 0; i < l.length; i++) { if (l[i].pid != $pid && l[i].normalWindow && !l[i].minimized && !l[i].skipTaskbar) { workspace.activeWindow = l[i]; break; } }"
sleep 1.5
run "var l = workspace.windowList(); for (var i = 0; i < l.length; i++) { if (l[i].pid == $pid) { workspace.activeWindow = l[i]; } }"
rm -rf "$dir"
