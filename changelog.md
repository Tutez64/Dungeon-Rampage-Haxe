Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.


### Added

- 

### Fixed

- Mods: an untyped array stored where a mod declares a typed one, such as `Array<String>`, no longer crashes the game when read back.
- Mods: all of OpenFL's enumerations, such as `TextFieldAutoSize` or `StageQuality`, can be used, where only four could.

### Improved

- Mods: a module the game cannot compile no longer makes other mods' modules, the API's included, run interpreted, which is slower and often does not work.
