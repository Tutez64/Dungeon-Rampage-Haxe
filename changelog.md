Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.


### Added

- 

### Fixed

- Mods: an untyped array stored where a mod declares a typed one, such as `Array<String>`, no longer crashes the game when read back.
- Mods: all of OpenFL's enumerations, such as `TextFieldAutoSize` or `StageQuality`, can be used, where only four could.
- Mods: a mod importing or declaring a class named like a standard type, such as the game's `collections.Map`, no longer makes other mods fail with `Null Function`.

### Improved

- Mods: a module the game cannot compile no longer makes other mods' modules, the API's included, run interpreted, which is slower and often does not work.
- Linux: the game uses about 500 MB less memory in a dungeon, where memory freed after a loading stayed with the game instead of going back to the system.
- The game uses about 200 MB less memory: the images of screens that have not been opened are no longer decoded.
- The game uses less video memory, about 430 MB less in a dungeon: the images of a screen are released a minute after it was last shown, and loaded again when it is shown again.
- High frame rates: moving the mouse no longer makes the game freeze for a moment (about a tenth of a second, longer on a slower processor), which happened every 5 to 10 seconds at 500 FPS in a dungeon and about every 100 seconds at 60 FPS.
