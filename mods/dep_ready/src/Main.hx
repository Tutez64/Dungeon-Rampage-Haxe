package mods.dep_ready;

import modding.Mod;
import modding.ModContext;

/** Loaded before `null_ready`, which it depends on and which throws in `onReady`: it must go quiet afterwards anyway. */
class Main extends Mod {
	var ctx:ModContext;

	override public function onInit(ctx:ModContext):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a mod whose dependency failed received townEnter"));
	}

	override public function onDispose():Void {
		ctx.log("ok   onDispose still runs after a dependency failed");
	}
}
