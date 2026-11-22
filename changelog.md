Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.


### Added

- 
### Fixed

- HUD: it no longer switches at random to its slower fallback when about 2 GB of video memory is in use on the whole system, which mods made more likely.
- Training: the stat buttons show their `+` (#56).
- Shop: the crown of a tab whose items are all bought has its colours, where parts of it were black (#35).
- Training, shop and storage: the hero icons fit their frames, where they were drawn larger (#36).
- Shop: the panel of a tab whose items are all bought is shaded as in DR, darker under the crown, where it was almost flat (#38).
- Logs: an error the game did not catch is written with its name and message, as in `UncaughtError: HudFatalError: Required HUD bake failed`, where the line ended after `UncaughtError:`.
- Controllers: the HUD shows the game's own button glyphs for the controller in use, as in DR, where it showed Steam's flat ones (#53).

### Improved

- Mods: reading or writing a field of one of the game's objects costs a mod about a third less: with nineteen mods, a frame of a fight took 3.9 ms and takes 3.7 ms on the test machine.

### Internal

- 
