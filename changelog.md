Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.

### Added

- 

### Fixed

- Windows: F11 now switches to a window that fits the screen. On a 1920x1080 resolution and lower, the game
  looked like it was still fullscreen, or zoomed in (#34).
- Mods: an array literal stored as a typed array, or a `Dynamic` array passed where a typed one is expected,
  no longer closes the game, and a map entry written by index (`map[key] = value`) no longer stops the mod
  from loading.
- Mods: a call such as `push` or `indexOf` on a null `Array<Dynamic>` throws an error the mod can catch,
  instead of closing the game.

### Improved

- 