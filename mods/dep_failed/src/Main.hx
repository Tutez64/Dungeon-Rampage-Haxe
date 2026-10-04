package mods.dep_failed;

import mods.api.Mod;
import mods.api.Context;

/** Depends on a mod whose `init` throws: the host must fail it before its own `init`. */
class Main extends Mod {
	override public function init(ctx:Context):Void {
		ctx.log("FAIL init reached a mod whose dependency failed");
	}
}
