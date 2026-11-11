# Performance bench

A bot that plays a scenario by injecting window events, and measures: frame times, draw calls,
collector and process memory, video memory, a heap census, timers around chosen functions. It is
compiled over the game by `build.sh` only and is not part of a release. Linux; results go to
`profiling/bench/` (ignored by git).

## Build

`./build.sh [suffix]` builds `bin/linux/bin/Dungeon Rampage Haxe.<suffix>` (`bench` by default)
and puts back the executable that was there. It compiles the game with one more classpath,
`bin/bench-overlay`, that `make_overlay.py` writes: `overlay/` (`PerfBot`, `PerfProbe`) and the
game's `Facade` with three hooks. The script stops if a hook no longer finds its line: update it
there after a conversion that changes `Facade.mainLoop`.

Do not start a build while the game runs: its first step rewrites `lime.ndll` and the game dies
of a bus error.

`FP=1 ./build.sh fp` builds with frame pointers, for call graphs (below). Its objects live in
`bin/linux/obj/obj/linux64-fp`, swapped in for the time of the build: the first one compiles
everything.

## The clock

`Facade.mainLoop` compares the game clock with `Date.now().getTime()` truncated each frame. On
hxcpp that time has a fraction, so about half a millisecond is lost per frame and above 180 FPS
the game reports the account as a speed hacker (`LogCheater`, `testing_speed_hack_probable`). A
bench build floors the time first, and stops the game rather than let a third suspicious second
go by. A build without the overlay must stay under 180 FPS until `src/` is converted with ax4
e858f06 or later; that conversion changes the line the hook looks for.

## Run

`./run.sh <name>` launches the executable `BIN` names (`Dungeon Rampage Haxe.bench`), plays
`DRH_PERF_SCRIPT` (by default: town, world map, Proving Grounds, walk up, fight, quit), samples
the process each second and prints a line per phase (`summ.py`). `profiling/bench/<name>/` gets
`events.log` (steps, a `PHASE` line per phase), `seconds.csv`, `mem.csv`, `game.log` and one file
of frame times per phase.

Steps, separated by `;`: `state:<name>[:timeout]`, `wait:<s>`, `click:<x>:<y>` (on a 2560x1440
reference), `move:<x>:<y>`, `wiggle:<x>:<y>[:<n>]` (moves the mouse around that point n times on
every frame until `wiggle:off`), `keydown:<name>`, `keyup:<name>`, `phase:<name>:<s>`,
`shot:<name>` (a screenshot by `spectacle`, cropped to `DRH_BENCH_SHOT_CROP` if set), `gc`,
`census:<name>`, `mallinfo`, `trim`, `tex`, `bmp`, `quit`.

Environment: `MAXTIME` (seconds before the game is killed, 360), `WRAP` (a command to run the
game under), `DRH_PERF_LONG=<ms>` (the frame time logged as `LONGFRAME`, 25), `DRH_PERF_IDLE=<s>`
(overrides `AnimateLibrary.hardwareBitmapIdleTime`), `DRH_BENCH_RUNS` (another results folder).

`seconds.csv` has, per second, the frames, the draw calls, the collector's heap, the large
allocations in MB (`large_alloc_mb`), the frames where the large heap fell (`large_drops`), what
the game's bake budget reads as GPU memory (`gpu_total_mb`, system wide and wrapped above 2 GiB)
and the HUD converter's error count. A level only shows what the mouse costs with it moving
(`wiggle`): Starling then hit tests the native overlay on every frame.

`python3 smaps.py <pid>` and `python3 anonmaps.py <pid>` break a running game's memory down by
mapping.

## Comparing two builds

`./ab.sh <name>` plays a level (12 s idle with the mouse moving, 50 s of the first attack, 8 s
idle with the mouse still) and prints the mean frame time of each phase. Alternate the builds,
four runs each, named `<prefix>_<variant>_<n>`; `python3 compare.py <prefix> <variant>...` then
gives each variant against the first. One run differs from the next by about 3% and two builds
of the same code by up to 2%, so a gain under 2% does not show.

For a finer measure, time the function itself with `PerfProbe`, called from the game's code for
the time of the measure: `var t = PerfProbe.start(); ...; PerfProbe.stop(0, t);`, or
`PerfProbe.add(1)` to count. Each `PHASE` line then gives the microseconds and the calls per
frame of every probe used. `PerfProbe.mode` reads `DRH_PROBE_MODE`, so one build can hold the
old code and the new, a run picks one, and a third mode can run both and count the differences.

## Call graphs

`BIN="Dungeon Rampage Haxe.fp" ./prof.sh <name> "--call-graph fp"` records every thread during
40 s of the attack and writes `profiling/bench/<name>/stacks.txt`. Then, with shares of the main
thread:

- `python3 callers.py <stacks> <function>...`: who calls a function;
- `python3 callees.py <stacks> 1 <function>...`: what it calls, one level down;
- `python3 under.py <stacks> <function> [rows]`: everything under it, inclusive and self.

Without perf arguments, `prof.sh` prints the functions by self time: DWARF stacks lose the
caller of most frames in a release build.

## Heap census and collection log

`census:<name>` writes `census_<name>.csv`: the live objects per class (`__hxcpp_gc_census`, in
the fork's libhxcpp). `../patches/hxcpp_gc_log_and_census.patch` (over libhxcpp 30c28f95, to
apply for the build and remove after) adds:

- rows `~held by <class>`: the allocations that are not objects (array storage, strings, hash
  nodes) by the class of the object holding them, `Array[<element size>]` for arrays;
- rows `^<owner> > <class>`: the generic objects (arrays, anonymous objects, maps, strings) and
  their allocations by the nearest class above them that is not generic, a class's statics
  counting as that class;
- the roots by kind (`(root set)`, `(stacks)`, `(roots)` for the rest, weak map values among
  them), and with `HXCPP_GC_CENSUS_TRACK=<class>,<class>` those classes counted by owner too;
- with `HXCPP_GC_LOG=1`, a `GCLOG` line per collection in `game.log`: what started it (`why`),
  minor or full mark, its length, the heap sizes and the figures the collector decides the next
  mode from. `python3 gclog.py profiling/bench/<name> [-v]` lines them up with the steps.

A full mark comes when the rows in use reach 75% of the blocks (`after` in the log), or when the
large allocations since the last one exceed the heap (`largeSinceMB` over `budgetMB`).

`./record.sh <name> [minutes]` launches the game with a bot that only records while you play: a
census each minute (a stall of about 0.15 s), no input. It kills the game after the minutes (30)
and prints, per census, the `RectangleTexture` objects, their growth a second, the heap after the
census's full collection and its growth a minute (`python3 record_summ.py profiling/bench/<name>`
prints it again).

## Texture census

The `tex` step lists the textures by class, size and format. It needs
`../patches/openfl_texture_registry.patch` on `submodules/openfl` and
`./build.sh tex --haxeflag="-D perf_tex"`. The registry keeps every texture alive, so video
memory reads about 500 MB too high in such a build.
