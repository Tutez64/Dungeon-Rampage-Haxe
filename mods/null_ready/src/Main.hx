package mods.null_ready;

import mods.api.Mod;
import mods.api.Context;
import mods.api.Subscription;

/** Dereferences null in `ready`. The game must keep running and the mod must be silenced. */
class Main extends Mod {
	var ctx:Context;

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a silenced mod received townEnter"));
	}

	override public function ready(ctx:Context):Void {
		// A method call on null segfaulted compiled code before HXCPP_CHECK_POINTER.
		var missing:Subscription = null;
		missing.cancel();
		ctx.log("FAIL a null dereference did not throw");
	}

	override public function dispose():Void {
		ctx.log("ok   dispose still runs after a failed ready");
	}
}
