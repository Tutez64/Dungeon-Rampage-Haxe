Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.


### Added

- Loading screen: a button opens the invite to the Discord server, where its address was written, and a line says how many mods are active, with the ones that failed.

### Fixed

- HUD: it is no longer missing for a whole session, when about 2 GB of video memory is in use on the whole system.
- Training: the stat buttons show their `+` (#56).
- Shop: the crown of a tab whose items are all bought has its colours, where parts of it were black (#35).
- Training, shop and storage: the hero icons fit their frames, where they were drawn larger (#36).
- Shop: the panel of a tab whose items are all bought is shaded as in DR, darker under the crown, where it was almost flat (#38).
- Logs: an error the game did not catch is written with its name and message, as in `UncaughtError: HudFatalError: Required HUD bake failed`, where the line ended after `UncaughtError:`.
- Controllers: the HUD shows the game's own button glyphs for the controller in use, as in DR, where it showed Steam's flat ones (#53).
- Windows: the texts use the game's fonts when the game is installed under a path with a character such as `ł`, as in a Windows user name, where they all fell back to another font.
- Steam: the game logs in when started while Steam is not logged on to its servers yet, as just after the computer starts, where it stayed on `WAITING FOR STEAM...` forever.
- Startup: the game no longer stays on `WAITING FOR STEAM...` forever when its files take longer to load, as on the first launch after the computer starts, where it never asked Steam for the login.
- Attacks: an attack that zooms the camera, such as a charged attack of the long sword or the monster axe, no longer stalls the game twice for about a tenth of a second, as it did at high frame rates.
- Death: the dungeon turns grey while your hero is dead, as in DR before its 1.0. It stayed in colour.
- Windows: the mouse and the keys act at once when the game runs below its frame rate, where the aim followed the mouse seconds late (#58).

### Improved

- Mods: reading or writing a field of one of the game's objects costs a mod about a third less: with nineteen mods, a frame of a fight took 3.9 ms and takes 3.7 ms on the test machine.
- Rendering: the game uses several processor cores, where it used one: three more threads prepare the world and the HUD while the main one draws. A frame of a fight took 2.3 ms and takes 2.0 ms on the test machine (430 to 510 FPS without a limit), for about a quarter of a core more. The launch argument `--render-threads 0` turns it off, and `--render-threads <n>` sets another number of threads.
- Filters: a glow, a blur or a drop shadow is drawn in fewer steps, for the same image: a frame of a fight had 104 draws and has 64 on the test machine, and took 1.96 ms where it takes 1.68 ms (510 to 596 FPS without a limit).
- Filters: an effect that grows or shrinks keeps its textures, where they were made again at each step of 64 pixels, the game stalling a tenth of a millisecond each time: a frame of a fight with such an effect took 1.97 ms and takes 1.77 ms on the test machine (507 to 566 FPS without a limit).
- Rendering: the hidden objects of the interface, about 1,300 of them in a dungeon, are no longer gone through on every frame: with three other players and nineteen mods, a frame of a dungeon took 3.9 ms and takes 3.6 ms on the test machine (257 to 277 FPS without a limit).
- Rendering: the characters and props of a dungeon are put in drawing order with less work, a buff's tint is applied when it has visibly changed, where it was on every frame, and an animation reads its frames faster: with the next line, a frame of a dungeon with three other players and nineteen mods took 4.9 ms and takes 4.7 ms on the test machine (204 to 212 FPS without a limit).
- HUD: a text or a name tag that changes is drawn in 1.6 ms, where it took 3.6 ms. With a mod that writes a timer, a frame of 8 to 13 ms came every second.
- Rendering: a name tag is no longer drawn again as a whole each time its character's health changes: with three other players and nineteen mods, a frame of a dungeon took 3.5 ms and takes 3.4 ms on the test machine (283 to 297 FPS without a limit).

### Internal

- Loading screen: the lines that name the release are written by the code from the release's tag, where `assets.swf` was edited for each release. A build made without a tag shows `DRH dev`.
