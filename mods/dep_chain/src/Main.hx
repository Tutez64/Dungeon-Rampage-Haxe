package mods.dep_chain;

import mods.api.Mod;
import mods.api.Context;

/** Depends on `dep_failed`, which only fails through its own dependency: failure carries through. */
class Main extends Mod {
	override public function init(ctx:Context):Void {
		ctx.log("FAIL init reached a mod whose dependency failed");
	}
}
