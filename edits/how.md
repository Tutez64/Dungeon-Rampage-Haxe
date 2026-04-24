### Note that this is only a minimal explanation, not currently intended for anyone to redo everything.

Decompile the game using [JPEXS](https://github.com/jindrapetrik/jpexs-decompiler). \
Fix the errors to make the AS3 code work. \
Convert it to Haxe using [ax4](https://github.com/Tutez64/ax4):
```JSON
{
  "src": "../DungeonRampageRecompiled/src",
  "hxout": "../DungeonRampageHaxe/src",
  "copy": [
    {"unit": "compat", "to": "../DungeonRampageHaxe/compat"}
  ],
  "swc": [
    "test-game/lib/airglobal.swc",
    "test-game/lib/FRESteamWorks.swc"
  ],
  "packagePartRenames": {
    "floor": "dr_floor"
  },
  "settings": {
    "checkNullIteratee": true
    }
}
```
Add/replace the Haxe files with the one in ./src
SteamEvent.hx is needed for AIR target, the others are for native targets.

These changes that can be done in either the AS3 or Haxe code:

Needed for AIR target:
- `PlayEffectTimelineAction` & `PlayEffectAttackTimelineAction`: replace the last three `= ""` by `= null ` in constructors
- `DungeonBustersProject`: add `stage.align = "";`

Needed for C++ target (these changes don't seem to make any difference in AIR):
- `View`: delete `rotationX`/`rotationY`/`rotationZ` lines 142-170
- `EffectManager`:
	- delete `rotationX`/`rotationY`/`rotationZ` lines 89-91
	- delete `scaleZ` lines 53;87
- `MovieClipCutsceneRenderer`: delete soundTransform lines 165;170
- `MainPanel`: delete "Security.showSettings(...)" line 1160 (it doesn't do anything in AIR, it's only for Flash)
- `CommandLine`: delete `setPropertyIsEnumerable` line 208 (not available in OpenFL, possible to implement but not urgent)

Lastly, you can apply patches from ./patches