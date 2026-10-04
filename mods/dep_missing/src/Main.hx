package mods.dep_missing;

import mods.api.Mod;
import mods.api.Context;

/** Depends on a mod that is not installed: the host must fail it before it loads. */
class Main extends Mod {
	override public function init(ctx:Context):Void {
		ctx.log("FAIL init reached a mod whose dependency failed");
	}
}
