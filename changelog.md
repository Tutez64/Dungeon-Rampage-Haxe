Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.

Dungeon Rampage 1.0 changed a lot under the hood: the official game now renders through Starling, on the GPU,
and part of it is compiled from Haxe. Following it took many changes, in DRH and in the libraries it is built
on (ax4, OpenFL, Lime, the SWF library, hxScript, libhxcpp). This version may therefore show some
visual problems or regressions. Please report them.

### Added

- 

### Fixed

- Performance: the large frame drops caused by some effects rendered by the CPU, such as fire spawns, are gone,
  as everything in the town and dungeons is now rendered on the GPU (#28).
- Windows: F11 now switches to a window that fits the screen. On a 1920x1080 resolution and lower, the game
  looked like it was still fullscreen, or zoomed in (#34).
- Mods: an array literal stored as a typed array, or a `Dynamic` array passed where a typed one is expected,
  no longer closes the game, and a map entry written by index (`map[key] = value`) no longer stops the mod
  from loading.
- Mods: a call such as `push` or `indexOf` on a null `Array<Dynamic>` throws an error the mod can catch,
  instead of closing the game.

### Improved

- Performance: expect better FPS. Among the changes: meshes from several atlases drawn in one draw
  call, faster type checks and dictionary lookups in the converted game code, text no longer looking for a missing font file on each update, loops over vectors
  without allocations, and on Linux faster access to the garbage collector's thread data.
- Internal: the conversion also covers the classes the official game now compiles from Haxe, with their types
  taken from its bytecode.
- Logs: an uncaught error such as a null access is described in the logs, instead of `Unknown error`, which
  makes bug reports more useful.
- Internal: the IntelliJ project uses the Haxe plugin v2, and `Execute` runs `lime test` on `project.xml`. The
  build steps register libhxcpp under its own name too, as the plugin looks for it: run
  `haxelib dev libhxcpp submodules/libhxcpp` once.
