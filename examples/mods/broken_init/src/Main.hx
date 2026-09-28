package mods.broken_init;

import modding.Mod;
import modding.ModContext;
import openfl.display.Sprite;

/** Fails in `onInit` after subscribing and drawing. The host must silence both. */
class Main extends Mod {
	var ctx:ModContext;

	override public function onInit(ctx:ModContext):Void {
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

	override public function onReady(ctx:ModContext):Void {
		ctx.log("FAIL onReady reached a mod whose onInit threw");
	}

	override public function onDispose():Void {
		ctx.log("ok   onDispose still runs after a failed onInit");
	}
}
