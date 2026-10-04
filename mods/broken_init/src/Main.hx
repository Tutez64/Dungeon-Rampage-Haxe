package mods.broken_init;

import mods.api.Mod;
import mods.api.Context;
import openfl.display.Sprite;

/** Fails in `init` after subscribing and drawing. The host must silence both. */
class Main extends Mod {
	var ctx:Context;

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		ctx.onTownEnter(function() ctx.log("FAIL a silenced mod received townEnter"));
		var square = new Sprite();
		square.graphics.beginFill(0xFF0000);
		square.graphics.drawRect(0, 0, 64, 64);
		square.graphics.endFill();
		square.x = 460;
		square.y = 8;
		ctx.overlay.addChild(square);
		throw "thrown on purpose";
	}

	override public function ready(ctx:Context):Void {
		ctx.log("FAIL ready reached a mod whose init threw");
	}

	override public function dispose():Void {
		ctx.log("ok   dispose still runs after a failed init");
	}
}
