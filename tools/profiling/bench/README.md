# Performance bench

A bot that plays a scenario by injecting window events, and measures: frame times, draw calls,
collector and process memory, video memory, a heap census, timers around chosen functions. It is
compiled over the game by `build.sh` only and is not part of a release. Linux; results go to
`profiling/bench/` (ignored by git).

## Build

`./build.sh [suffix]` builds `bin/linux/bin/Dungeon Rampage Haxe.<suffix>` (`bench` by default)
and puts back the executable that was there. It compiles the game with one more classpath,
`bin/bench-overlay`, that `make_overlay.py` writes: `overlay/` (`PerfBot`, `PerfProbe`) and five
files with hooks, four of the game's (`Facade`, `Starling`, `FragmentFilter`, `DcSocket`) and
OpenFL's `DisplayObjectRenderer`; the list and what each hook does are at the top of the script. The script stops if a hook no longer finds its
line: update it there after a conversion that changes that code. A hook only adds statements to a
function's body: a new member would have hxcpp recompile every file that includes the class.

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
every frame until `wiggle:off`), `keydown:<name>`, `keyup:<name>`,
`zoom:<factor>:<in>:<hold>:<out>[:<shot>]` (tweens the camera as an attack's zoom action does, in
seconds, with a screenshot of that name during the hold), `phase:<name>:<s>`,
`shot:<name>` (a screenshot by `spectacle`, cropped to `DRH_BENCH_SHOT_CROP` if set),
`saturate:<percent>` (greys the layers as the revive state does: 25 when the hero dies, 100 back), `gc`,
`census:<name>`, `mallinfo`, `trim`, `tex`, `bmp`, `quit`.

Environment: `MAXTIME` (seconds before the game is killed, 360), `WRAP` (a command to run the
game under), `ARGS` (its arguments), `PAD` (below), `DRH_PERF_LONG=<ms>` (the frame time logged as `LONGFRAME`, 25), `DRH_PERF_IDLE=<s>`
(overrides `AnimateLibrary.hardwareBitmapIdleTime`), `DRH_BENCH_RUNS` (another results folder).

`seconds.csv` has, per second, the frames, the draw calls, the collector's heap, the large
allocations in MB (`large_alloc_mb`), the frames where the large heap fell (`large_drops`), what
the game's bake budget reads as GPU memory (`gpu_total_mb`, system wide and wrapped above 2 GiB)
and the HUD converter's error count. Then the filter passes and the filters that ran some, per
frame (`passes`, `filters`), the frames over 10 and 16.7 ms, the CPU time of the main thread and
of the whole process (`main_cpu_ms`, `proc_cpu_ms`), and where the second's wall time went, in
milliseconds (`b_*`). Four blocks split the whole frame:

- `b_update`: Lime's update (the pending mouse event, timers);
- `b_events`: the `enterFrame` broadcast. In it, the game's loop is `b_realwork`, `b_logical`,
  `b_physics`, `b_prerender` (a work manager each, the middle three once per 24 Hz tick),
  `b_views` (the views interpolated) and `b_layers` (cull, sort, bake), and Starling's is
  `b_advance` (juggler, animations) and `b_render`; the rest is the other listeners;
- `b_openfl`: OpenFL's own display list, the native overlay;
- `b_swap`: the buffer swap, the event polling, the frame limiter's sleep.

`b_network` is the handling of received data, inside whichever block the socket's event fell in.
The main thread's CPU time under the wall time is time spent waiting (driver, workers, limiter). A level only shows what the mouse costs with it moving
(`wiggle`): Starling then hit tests the native overlay on every frame.

`PAD=still` (or `stick`, which turns the left stick) plugs a virtual Xbox 360 controller in for
the run (`vpad.py`: python3-evdev and write access to `/dev/uinput`) and turns Steam Input on.
Steam hands a controller to a game once it has seen its window take the focus, and misses it
when the window is focused before the game has told Steam it runs: `refocus.sh` gives the focus
to another window and back when the bot starts (KWin only). `Glyph origin` lines in `game.log`
show the game got the controller.

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

## Recording a real game

`BIN="Dungeon Rampage Haxe.<suffix>" ./record.sh <name> [minutes]` launches the game with a bot
that sends no input: you play, with other players, and quit the game to end the recording (it is
killed after the minutes, 120). `MODS=1` loads the mods the launcher has enabled, `MODS=<folder>`
those of another mods folder; without it the game runs without mods. On top of `seconds.csv`, the run's folder gets
`frames.csv` (each frame's time, draws and filter passes) and `objects.csv` (each second, the game
objects by class), and `seconds.csv` gets the dungeon floor (`map node/floor number`), the heroes,
NPCs, projectiles and effects (`effects_live`: those in use, `effects`: with the pooled ones),
Starling's display tree (`sl_objects`, those shown, the meshes and filters shown), its juggler,
and OpenFL's own display list (`nat_objects`, those shown, the text fields and the filtered
objects shown, the objects below an invisible container, the cached bitmaps drawn again in the
second). `cache.csv` says which objects those were, by branch, class, filters and why (the
letters are explained in `PerfBot.whyText`), with
`native.csv`'s samples. `native.csv` has that list every fifth second, by branch (three levels of names
under the stage, a mod's overlay being `ModOverlay/mod:<id>`) and class.
`events.log` has a `FLOOR` line per floor and a `LONGFRAME` line for each frame over
`DRH_PERF_LONG`, with the blocks of that frame, the game objects made or gone during it
(`objects=`) and what the collector's heap lost when a collection ran (`collected_mb=`).

It then prints (`python3 record_summ.py profiling/bench/<name>` prints it again): the time and
FPS per state and per floor, the dungeon seconds grouped by FPS with a frame's blocks and the
scene's counts in each group, the correlation of the frame time with each count, and the worst
frames. The groups show what grows when the game is slow.

`DRH_PERF_ALT=<seconds>` compares variants of some code inside one game: they take turns, each
for that many seconds, so all meet the same content, which two games never do. Variant 0 is the
code as it is; variant k, from 1 to `DRH_PERF_VARIANTS` (1), turns change k on alone, and
`DRH_PERF_ON=<k>,<k>` keeps changes on in every variant, and `DRH_PERF_ALL=<n>` compares none with
changes 1 to n together. A change is written
`if (PerfBot.on(k)) new else old`; one in a library has a switch of its own that
`PerfBot.applyAlt` sets. `seconds.csv` says which variant each second ran (`alt`) and what each
`PerfProbe` measured (`p<n>_us`, `p<n>_calls`), and the summary puts the variants side by side,
per state, then gives per turn of the variants the difference of each with variant 0 and its
standard error: a difference under twice its error is not shown by the game.

Changes under test in `src/` stay out of the working tree: `DRH_BENCH_PATCHES=<folder>` has
`build.sh` apply the folder's patches (`git diff` of files under `src/`) to the overlay's copies.

`CENSUS=1` adds a heap census each minute (above). Each one stalls the game about 0.15 s and runs
a full collection, which hides the collector's own full marks: leave it out to measure frame
times.

`PERF=1` with a `FP=1` build samples the game with perf for the whole session (`PERF_HZ`, 499 a
second, about 0.3 GB of `perf.data` per half hour). `record_stacks.py` then sorts the main
thread's samples into the same FPS groups and prints, per function, the milliseconds a frame
spends in it in each group, sorted by what the slowest group adds (`stacks_bands.txt`). It also
writes `stacks_<group>.txt` for `callers.py`, `callees.py` and `under.py`, and
`stacks_long.txt`, the stacks sampled inside the frames of 25 ms or more, with a table of where the
time of those frames went (collections, new actors, assets loaded, bakes, sound decoding).

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

`CENSUS=1 ./record.sh <name> [minutes]` (below) takes a census each minute of a game you play
and prints, per census, the `RectangleTexture` objects, their growth a second, the heap after the
census's full collection and its growth a minute.

## Texture census

The `tex` step lists the textures by class, size and format. It needs
`../patches/openfl_texture_registry.patch` on `submodules/openfl` and
`./build.sh tex --haxeflag="-D perf_tex"`. The registry keeps every texture alive, so video
memory reads about 500 MB too high in such a build.
