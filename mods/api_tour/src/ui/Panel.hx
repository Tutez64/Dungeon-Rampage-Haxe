package mods.api_tour.ui;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/** Top-left readout. */
class Panel extends Sprite {
	var text:TextField;

	public function new() {
		super();
		x = 8;
		y = 8;
		mouseEnabled = false;
		mouseChildren = false;

		text = new TextField();
		text.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFF66);
		text.selectable = false;
		text.width = 420;
		text.height = 90;
		text.x = 6;
		text.y = 4;
		addChild(text);
		show(["api_tour"]);
	}

	public function show(lines:Array<String>):Void {
		text.text = lines.join("\n");
		graphics.clear();
		graphics.beginFill(0x000000, 0.6);
		graphics.drawRect(0, 0, 432, 98);
		graphics.endFill();
	}
}
