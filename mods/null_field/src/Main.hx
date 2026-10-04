package mods.null_field;

import mods.api.Mod;
import mods.api.Context;

/** Reads a field of the floor in `init`, where there is none yet. The mod must fail and go quiet. */
class Main extends Mod {
	var ctx:Context;

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a silenced mod received townEnter"));
		// A field read on null answered null, compiled and interpreted, before hxScript raised on it.
		ctx.log("floor " + ctx.state.floor.number);
		ctx.log("FAIL a field read on null did not throw");
	}

	override public function dispose():Void {
		ctx.log("ok   dispose still runs after a failed init");
	}
}
