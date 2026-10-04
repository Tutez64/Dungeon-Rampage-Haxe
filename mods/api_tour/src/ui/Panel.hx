package mods.api_tour.ui;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/** Top-left readout. Composes OpenFL display objects rather than extending them, so the mod needs no `extends`. */
class Panel {
	public var root(default, null):Sprite;

	var text:TextField;

	public function new() {
		root = new Sprite();
		root.x = 8;
		root.y = 8;
		root.mouseEnabled = false;
		root.mouseChildren = false;

		text = new TextField();
		text.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFF66);
		text.selectable = false;
		text.width = 420;
		text.height = 90;
		text.x = 6;
		text.y = 4;
		root.addChild(text);
		show(["api_tour"]);
	}

	public function show(lines:Array<String>):Void {
		text.text = lines.join("\n");
		root.graphics.clear();
		root.graphics.beginFill(0x000000, 0.6);
		root.graphics.drawRect(0, 0, 432, 98);
		root.graphics.endFill();
	}
}
