package mods.dep_missing;

import modding.Mod;
import modding.ModContext;

/** Depends on a mod that is not installed: the host must fail it before it loads. */
class Main extends Mod {
	override public function onInit(ctx:ModContext):Void {
		ctx.log("FAIL onInit reached a mod whose dependency failed");
	}
}
