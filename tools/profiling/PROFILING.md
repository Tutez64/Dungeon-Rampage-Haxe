# Memory and GC diagnostics

Three complementary parts:

- **Linux / GC builds** (next sections): hxcpp timeline, census and retention
  traces (`tools/run_gc_session.sh`, `bin/gc-*` builds).
- **Windows / freezes** (end of the file): in-process `StallProfiler`, Working
  Set sampler, PDB + LocalDumps for the access violations that follow a GC
  spiral.
- **Linux / FPS and memory per scenario**: a bot that plays a scene and
  measures frame times, draws, heap, VRAM and call graphs, in
  [`bench/README.md`](bench/README.md).

## hxcpp prerequisite

The instrumentation (`HXCPP_GC_TIMELINE`, `HXCPP_GC_CENSUS`,
`HXCPP_GC_RETENTION_TRACE` and variants) is **not** in the hxcpp tip of the
releases. It lives in a one-off patch:

```text
tools/profiling/patches/hxcpp_gc_timeline_census_retention.patch
```

Apply it from the project root, for a diagnostic build only:

```bash
git -C submodules/libhxcpp apply \
  ../../tools/profiling/patches/hxcpp_gc_timeline_census_retention.patch
```

Then remove the patch (clean release tip):

```bash
git -C submodules/libhxcpp apply -R \
  ../../tools/profiling/patches/hxcpp_gc_timeline_census_retention.patch
# or: git -C submodules/libhxcpp checkout -- .
```

The patch targets the hxcpp commit DRH pointed to when it was written
(`c4487bf3`). After a submodule update, check
`git -C submodules/libhxcpp apply --check …` and regenerate the patch if
needed.

These defines must never be enabled in the release's `project.xml`. Without
the patch, a build that asks for them does not compile or does not emit the
expected CSV lines.

## StallProfiler prerequisite (game)

The in-process profiler (`--profile-stalls`, marks, `alloc-spike`) is **not**
in the release code. It lives in:

```text
tools/profiling/patches/stall_profiler.patch
```

Apply it from the root (game working tree) for a diagnostic build:

```bash
git apply tools/profiling/patches/stall_profiler.patch
```

Remove it:

```bash
git apply -R tools/profiling/patches/stall_profiler.patch
```

The patch adds `src/brain/utils/StallProfiler.hx`, the CLI hooks and marks
(chat, floor, swf, input), SWF stats helpers in `SwfAsset`, and the
`clearBitmapCaches` / `getBitmapCacheCounts` instrumentation in
`submodules/swf/.../AnimateLibrary.hx`.

On Windows, if `git apply` fails on line endings:

```bash
git apply --ignore-whitespace tools/profiling/patches/stall_profiler.patch
```

## Long realistic session

The `bin/gc-diagnostics` build enables `HXCPP_GC_TIMELINE` and
`HXCPP_GC_CENSUS` on top of the release's options. This instrumentation keeps
the non-generational collector and its parallel marking. It writes one line
per collection with:

- the pause and the interval since the previous collection;
- the live, current and reserved heap before and after the collection;
- the large allocations, the fragmentation and the target working size;
- how the time splits between synchronisation, marking, reclaiming, large
  allocations, defragmentation and resuming the threads.

On full scans only, it also counts the classes of live objects, the raw
buffers by size and the native memory declared to the GC. This census is
deliberately infrequent: it identifies the families that stay alive without
recording every allocation.

This build is for attributing memory growth, not for comparing pauses with a
release: the full scans include the cost of the census.

Start the session from the project root:

```bash
tools/run_gc_session.sh
```

While playing, type short markers in the terminal, for example:

```text
initial town
dungeon 1 start
floor 2
back in town
first visible GC stutters
```

Markers are optional for state changes and for floors being entered and
destroyed: the analyzer also extracts those from the game's logs.

Close the game normally so that `HXCPP_GC_SUMMARY` is written too. The
`profiling/gc-YYYYMMDD_HHMMSS` folder will hold:

- `game.log`: the game's logs, the detailed GC timeline and the final summary;
- `memory.csv`: RSS/PSS, anonymous memory, swap, page faults, descriptors,
  CPU, VRAM/GTT of the process and of the GPU;
- `events.csv`: the markers typed while playing;
- `game_events.csv`: the transitions and floors detected automatically;
- `gc_timeline.csv`: the extracted GC timeline;
- `gc_census_*.csv`: the censuses of survivors on full scans;
- `analysis.md`: the automatic numeric summary;
- `timeline.svg`: the memory/GC graph.

To analyze a session again:

```bash
python3 tools/analyze_gc_session.py profiling/gc-YYYYMMDD_HHMMSS
```

## Targeted retention trace

The `bin/gc-retention-raw` build looks for the chains that keep the large raw
buffers of 144,000,000 bytes and 26,796,760 bytes. It traces them at
collections 16 and 31 respectively, then goes back to the normal behaviour.
In the sessions observed, these collections come during the first minutes of
play.

Identical paths are grouped. The tracer remembers at most 512 distinct paths
and prints the 100 most frequent, to avoid a log of tens of thousands of
lines.

Start from the project root:

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-retention-raw/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

Those two collections are slower than usual, because marking temporarily keeps
the full path from each root. After the one-off freezes, finish the game
normally. The analyzer writes the results to `gc_retention_summary.csv`,
`gc_retention_paths.csv` and the `Trace de rétention` section of
`analysis.md`. A five-minute session is enough; a long run is not needed.

## Animate retention trace

The `bin/gc-retention-animate` build traces four families that dominate the
small live graph once bitmaps are hardware-cached:

- collection 16: `swf.exporters.animate.AnimateFrameObject`;
- collection 31: `swf.exporters.animate.AnimateFrame`;
- collection 46: `swf.exporters.animate._AnimateTimeline.FrameSymbolInstance`;
- collection 61: `openfl.display.Graphics`.

Start from the project root:

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-retention-animate/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

The four targeted collections can freeze the game for several seconds. Joining
a dungeon and playing until collection 61 is recorded is enough, usually five
to seven minutes. The session does not need to be comparable with an earlier
run: it identifies who owns the survivors, it does not measure pauses.

## Live graph retention trace

The `bin/gc-retention-graph` build compares the paths that keep the generic
containers whose population grows during a dungeon:

- collection 16: `Array`, before the dungeon;
- collection 31: `Dynamic`, at the start of the dungeon;
- collection 61: `Array`, during the dungeon;
- collection 91: `brain.workLoop.LogicalWorkComponent`, towards the end;
- collection 106: `Array`, towards the end;
- first explicit collection after collection 31: `Array` and a census of the
  survivors, normally when the dungeon is destroyed.

Start from the project root:

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-retention-graph/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

Play a normal game, go back to town, then wait a few seconds before closing
the game normally. The last capture does not depend on a fixed collection
number: it is triggered by the explicit collection that normally comes with
the dungeon's destruction.

The targeted collections walk and record a great many paths. They can
therefore cause long freezes and distort the GC pauses heavily. This session
is only for attributing the growth of the live graph; its times must not be
compared with earlier builds.

## Comparison without the text measurement cache (lead set aside)

The `bin/gc-text-no-cache` build enables the OpenFL define
`openfl_disable_text_measurement_cache`. It keeps the GC timeline and census,
but not the retention tracer.

Session `gc-20260727_054912` confirms that the define removes the
`ShapeCache` objects entirely, with no visual difference. It does not reduce
the number of `GlyphPosition` objects, however, which mostly belong to the
active `TextLayoutGroup.positions`, and brings no measurable memory or GC
gain. This optimisation must therefore not be kept.

## Independent copy-on-write of the graphics commands

The `bin/gc-draw-command-cow` build changes `DrawCommandBuffer` to detach only
the arrays each command writes. A simple command therefore no longer
materialises the seven internal arrays of each `Graphics`.

Start from the project root:

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-draw-command-cow/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

Play a few minutes over several floors, go back to town, then close normally.
Check how fills, strokes and gradients render. The censuses are mostly for
comparing the number of surviving `Array` objects; GC times alone are likely
to stay within natural variance.

Session `gc-20260727_062859` (6 floors, 210 s of actual play) shows no visual
regression. The best immediate reference is `gc-20260727_053411`: it uses the
normal text measurement cache and does not have the independent COW. Its
build does trace retention on some collections, though. Leaving out
collection 31, deliberately slowed by that tracer, the GC cost during floors
goes from 7.63 to 6.52 ms/s and the volume reclaimed from 16.63 to
15.39 MiB/s, about -15% and -7% respectively. The runs are not perfectly
controlled; these figures are a consistent signal, not an isolated measure to
present as guaranteed. The unit tests and the dedicated repro establish the
structural gain separately: only the streams actually written are detached.

## hxcpp generational collector

The `bin/gc-generational` build enables `HXCPP_GC_GENERATIONAL` on top of the
GC timeline and census. The timeline tells generational collections (`gen`)
from full scans (`std`) and records the size of the remembered set at the
start of each generational collection. The report has a `Modes de collecte`
section that compares them separately.

Start from the project root:

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-generational/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

Preferably replay the static dungeon used as the reference, with a comparable
character and equipment. Check the rendering on each floor, go back to town,
then close the game normally. The first goal is to check stability and how the
cost of both modes evolves; a longer session is only useful if this first test
shows neither a regression nor a clear enough signal.

This build contains a workaround, limited to the generated C++ sources, for a
problem of the Haxe 4.3.6 generator with `cpp.Function` fields and the
generational write barrier. A full Lime rebuild regenerates those files and
fails as long as the Haxe generator is not fixed. A minimal repro is in
`../repros/hxcpp-generational-cpp-function`.

## Targeted CPU capture

`perf` is best for a short reproduction around an area that became slow, not
for a whole two-hour game:

```bash
tools/profiling/profile_native_perf.sh <pid> profiling/perf-run
tools/profiling/report_native_perf.sh profiling/perf-run/perf.data
```

`--profile-stalls` also works on Linux, and is mostly used to compare the
memory slope and the absence of long stalls with Windows.

---

## Windows: stalls, Working Set and dumps

Goal: correlate the Windows freezes (often several seconds to several tens of
seconds, `cause=none`) with the growth of the hxcpp heap and of the OS Working
Set, then capture a native dump if the session ends in `0xc0000005`.

The shorter freezes on focus, chat or another screen remain useful as
indicators; the underlying target is the GC spiral, not the final crash.

### StallProfiler (in-process)

The profiler is only active through the CLI (almost free otherwise):

```bat
Dungeon Rampage Haxe.exe --profile-stalls --fps=auto
```

Options:

- `--profile-stalls`: 50 ms threshold
- `--profile-stalls=80`: custom threshold in ms
- `--profile-memory-interval=5`: hxcpp memory sample every N seconds (default 5)
- `--profile-alloc-spike=100`: log sudden jumps of `gcUsage` / `gcLarge` (MB, default 100)

Useful lines in the logs:

```text
[StallProfiler] enabled threshold=50ms memoryInterval=5s allocSpike=100MB
[StallProfiler] memory reason=periodic gcUsageMB=... gcCurrentMB=... gcReservedMB=... gcLargeMB=... swfLibs=... hwBmp=... readableBmp=...
[StallProfiler] stall#12 frame=173ms cause=mouse-leave recent=[floor-new,swf-load:...] gcUsageMB=...
[StallProfiler] alloc-spike#3 dUsageMB=+412.5 dLargeMB=+380.1 over=16ms cause=swf-load:... recent=[floor-destroy,floor-new,swf-load:...] ...
[StallProfiler] large-bitmap BitmapData:16384x16384=1024MB stack=...
[StallProfiler] win-resize 1920x1080
[StallProfiler] stage-resize 1920x1080
```

`cause=none` is a stall without a recent hint (typically a GC pause or heavy
work outside leave/focus/chat). `recent=[...]` keeps the last breadcrumbs
(floor, swf-load, focus, chat, resize, …) even if the immediate hint has
expired. Time spent in the background after alt-tab is **not** counted as a
stall.

The `alloc-spike` lines are the main lead for a memory trigger: hundreds of
MB or 1 GiB more in one or a few frames, with `recent=` to name the path. A
solved example: SDL codes (bit `0x40000000`) leaking into
`KeyboardEvent.keyCode`, which made a Flash-style `Vector` of length 256 grow
to about 1 GiB. `noteLargeBitmap` is still there to instrument a suspect
allocator by hand.

### OS memory sampler (Working Set / Private)

In another PowerShell terminal, while the game runs:

```powershell
$proc = Get-Process -Name "Dungeon Rampage Haxe" | Select-Object -First 1
.\tools\profiling\profile_native_memory.ps1 -ProcessId $proc.Id -OutputCsv profiling\win1\memory.csv -IntervalSeconds 0.5
```

CSV:

```text
timestamp_sec,rss_kb,private_kb,virtual_kb
```

Cross the stalls' clock (`Logger`) with `private_kb` / `rss_kb`. Task Manager
can show sharp drops of the Working Set during a large GC (sometimes down to a
few tens of MB, then back up): a noisy signal, to confirm with the sampler and
the StallProfiler's `gcUsageMB`.

### Build with PDB + LocalDumps

For a usable native stack after an access violation:

```bat
haxelib run openfl build project.xml cpp -D HXCPP_DEBUG_LINK
```

Copy the exe **and** the `.pdb` side by side (for example into the launcher's
`current` folder).

LocalDumps (current example):

```reg
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\Dungeon Rampage Haxe.exe]
"DumpFolder"="F:\\DungeonRampageHaxe\\dumps"
"DumpCount"=dword:0000000a
"DumpType"=dword:00000002
```

`DumpType=2` is a full dump: it needs enough disk space (several GiB). A
minidump (`DumpType=1`) is often enough with the PDB for the stack.

Analyze with `cdb` / WinDbg, pointing to the PDB of the same build.

### Session scenario

1. Start the local build (PDB) with `--profile-stalls`
2. Start the memory sampler
3. Chain dungeons and floors without restarting the process
4. When the long stalls appear, note the time and `gcLargeMB` / `hwBmp` /
   `swfLibs`
5. On a crash: collect the `.dmp` and the launcher's `.zst` log

Typical reading observed: the heap and `gcLargeMB` climb, frames of 5 to 60+ s
with `cause=none`, sometimes about 1 GiB reclaimed and then recovery; without
that reclaim, degradation and then an access violation. The native crash under
load is a consequence; the cause to treat is the spiral before it.
