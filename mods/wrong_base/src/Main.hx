package mods.wrong_base;

import modding.ModContext;

/** Its entry extends the core's `modding.Mod` rather than `mods.api.Mod`: the host must refuse it. */
class Main extends modding.Mod {
	override public function onInit(ctx:ModContext):Void {
		ctx.log("FAIL init reached an entry that does not extend mods.api.Mod");
	}
}
