Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.

### Added

- Release manifests now include the official Steam BuildID this version was
  converted from, so DRH Launcher can warn when official Dungeon Rampage has
  moved on.

### Fixed

- Closing the window and choosing **Quit** now both run Steam cleanup.
  Lime treats the window-manager quit (`SDL_QUIT`) as a close request on every
  open window; the in-game Quit popup and the connection-error dialog dispatch
  `exiting` before `exit()` instead of skipping it. Steam dispose only runs once
  if that event fires twice.

### Improved

- Internal: Lime, OpenFL, and hxcpp were fixed for the upcoming hxScript
  host. I forked hxScript to improve and fix it (`submodules/hxscript`,
  [Tutez64/hxscript](https://github.com/Tutez64/hxscript)).
- Internal: Lime, OpenFL, swf, hxcpp, SteamWrap, and hxScript are resolved
  with `haxelib dev` on the submodules. `project.xml` no longer passes
  `path=`.
