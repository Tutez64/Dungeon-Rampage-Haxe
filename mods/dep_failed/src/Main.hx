package mods.dep_failed;

import modding.Mod;
import modding.ModContext;

/** Depends on a mod whose `onInit` throws: the host must fail it before its own `onInit`. */
class Main extends Mod {
	override public function onInit(ctx:ModContext):Void {
		ctx.log("FAIL onInit reached a mod whose dependency failed");
	}
}
