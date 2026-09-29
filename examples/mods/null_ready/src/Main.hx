package mods.null_ready;

import modding.Mod;
import modding.ModContext;
import modding.ModSubscription;

/** Dereferences null in `onReady`. The game must keep running and the mod must be silenced. */
class Main extends Mod {
	var ctx:ModContext;

	override public function onInit(ctx:ModContext):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a silenced mod received townEnter"));
	}

	override public function onReady(ctx:ModContext):Void {
		// A method call on null segfaulted compiled code before HXCPP_CHECK_POINTER.
		var missing:ModSubscription = null;
		missing.cancel();
		ctx.log("FAIL a null dereference did not throw");
	}

	override public function onDispose():Void {
		ctx.log("ok   onDispose still runs after a failed onReady");
	}
}
