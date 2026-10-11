Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.

### Added

- Mods can load through hxScript when the launcher passes `--mods-dir`. The
  game reads `enabled.json`, compiles every enabled mod in one world, and runs
  their startup and shutdown hooks. A mod that fails, or whose dependency
  fails, is silenced without stopping the others. The session writes
  `mods/last-run.json`. `replace` is not available yet.
- Mods build on the official `api` mod, released on its own: players in a
  dungeon (hero, level, weapons), the account (currencies, trophies, and its
  inventory: weapons, pets and consumables in storage, and its heroes with
  what they carry), the game's portraits, weapon icons and tooltips, adding a
  player as a friend, blocking or reporting them, and events for heroes,
  floors, town and key presses.
- `docs/making-a-mod.md` gives a modder's steps, from the
  [DRH-Mod-Template](https://github.com/Tutez64/DRH-Mod-Template) repository
  to testing the mod in the game.
- `mods/` holds an example mod that uses the whole `api` mod and checks it as
  it runs, plus test mods for load, runtime and dependency failures. Run the
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
- Text outlines are thicker, closer to the original game's, instead of barely
  visible. Outlined text is now rendered on the GPU rather than blurred on the
  CPU each time it changes, which also makes menus (a lot) and dungeons (a bit?)
  smoother (#3).
- The town's "what's new" popup opens when the server sends news: walking an
  untyped array with `for each` or `for … in` did nothing. The official server
  never sends any, so this only showed on other servers (#44).
- Converted code follows AS3 where it silently differed: a NaN or out-of-range
  Number converted to `int` gives 0 or wraps, an untyped value of the wrong
  type assigned to a typed variable throws a `TypeError` (logged, the game
  keeps running) instead of becoming `null`, and `undefined` assigned to a
  String is `null`, not `"undefined"`. None of these showed up in play.
- Internal: the preprocessing of the SWF files no longer occasionally fails
  with `std@sys_create_dir`, as Lime now creates the shared SWF directory
  once before the parallel handlers.
- Internal: `refresh.cmd continue` replays the rest of the edits stack after
  a conflict instead of dropping it.

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
- Internal: the ax4 converter drops redundant conversions from the generated
  code (inferred locals, already numeric expressions) and the compat layer
  takes faster paths for dynamic property access and typed conversions. The
  Linux executable is about 3.5 MB smaller; no CPU gain was measurable in a dungeon.
