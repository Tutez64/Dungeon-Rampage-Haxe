package mods.dep_ready;

import mods.api.Mod;
import mods.api.Context;

/** Loaded before `null_ready`, which it depends on and which throws in `ready`: it must go quiet afterwards anyway. */
class Main extends Mod {
	var ctx:Context;

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a mod whose dependency failed received townEnter"));
	}

	override public function dispose():Void {
		ctx.log("ok   dispose still runs after a dependency failed");
	}
}
