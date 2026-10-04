package mods.dep_chain;

import modding.Mod;
import modding.ModContext;

/** Depends on `dep_failed`, which only fails through its own dependency: failure carries through. */
class Main extends Mod {
	override public function onInit(ctx:ModContext):Void {
		ctx.log("FAIL onInit reached a mod whose dependency failed");
	}
}
