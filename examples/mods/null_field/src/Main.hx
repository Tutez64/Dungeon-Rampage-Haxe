package mods.null_field;

import modding.Mod;
import modding.ModContext;

/** Reads a field of the floor in `onInit`, where there is none yet. The mod must fail and go quiet. */
class Main extends Mod {
	var ctx:ModContext;

	override public function onInit(ctx:ModContext):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a silenced mod received townEnter"));
		// A field read on null answered null, compiled and interpreted, before hxScript raised on it.
		ctx.log("floor " + ctx.state.floor.number);
		ctx.log("FAIL a field read on null did not throw");
	}

	override public function onDispose():Void {
		ctx.log("ok   onDispose still runs after a failed onInit");
	}
}
