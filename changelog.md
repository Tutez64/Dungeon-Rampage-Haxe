Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.

### Added

- Mods can load through hxScript when the launcher passes `--mods-dir`. The
  game reads `enabled.json`, compiles every enabled mod in one world, and
  runs `onInit` / `onReady` / `onDispose`. Gameplay hooks cover hero spawn,
  dungeon floors, town, and key presses. Mods can read the players in a
  dungeon (hero, level, weapons), show the game's portraits, weapon icons and
  weapon tooltips, and add a player as a friend, block or report them. The
  session writes `mods/last-run.json`. `replace` is not available yet.
- `mods/` holds an example mod that uses the whole modding API and
  checks it as it runs, plus test mods for load and runtime failures. Run the
  game with `--mods-dir` pointing at it.
- Release manifests now include the official Steam BuildID this version was
  converted from, so DRH Launcher can warn when official Dungeon Rampage has
  moved on.

### Fixed

- A null object reference inside the game loop no longer crashes the game. It
  is logged as an `UncaughtError` and the game keeps running, as the official
  client does. This costs about 7-8% more CPU.
- Closing the window and choosing **Quit** now both run Steam cleanup.
  Lime treats the window-manager quit (`SDL_QUIT`) as a close request on every
  open window; the in-game Quit popup and the connection-error dialog dispatch
  `exiting` before `exit()` instead of skipping it. Steam dispose only runs once
  if that event fires twice.
- Internal: the preprocessing of the SWF files no longer occasionally fails
  with `std@sys_create_dir`, as Lime now creates the shared SWF directory
  once before the parallel handlers.

### Improved

- Internal: Lime, OpenFL, and hxcpp were fixed for the upcoming hxScript
  host. I forked hxScript to improve and fix it (`submodules/hxscript`,
  [Tutez64/hxscript](https://github.com/Tutez64/hxscript)), and added
  the cppia host and hxScript flags to `project.xml`.
- Internal: package builds cache native libraries, preprocessed SWFs, and
  C++ objects. A game file or one SWF change reuses the rest. A compiler,
  Lime, or `project.xml` change does not.
- Internal: Link-time optimization is removed: it now resulted in bigger
  executables, while tripling compile time.
- Internal: Lime, OpenFL, swf, hxcpp, SteamWrap, and hxScript are resolved
  with `haxelib dev` on the submodules. `project.xml` no longer passes
  `path=`.
