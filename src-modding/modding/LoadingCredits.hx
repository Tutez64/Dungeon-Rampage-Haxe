package modding;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * What the loading screen shows under its bar: this build's release, the mods that run and those
 * that do not, and a button to the community's Discord server. `modding.Hooks` has `DBFacade.init`
 * call `show` once the screen's clip is made.
 */
class LoadingCredits {
	static inline final DISCORD = "discord.gg/VvWbNspZrQ";

	static inline final FONT = "Fat Rhino PB";

	static inline final RED = 0xFF0000;

	static inline final BUTTON = 0x5865F2;

	static inline final BUTTON_OVER = 0x7983F5;

	/** The block's width before its scale; every line is centred in it. */
	static inline final WIDTH = 500;

	/** As many ids of mods that do not run as fit in this many characters, then how many more. */
	static inline final STOPPED_CHARACTERS = 28;

	/** `DRH V18`, or `DRH dev` for a build that no release tag was given to. */
	public static function release():String {
		return "DRH " + (Version.TAG == "0" ? "dev" : "V" + Version.TAG);
	}

	/** `12 mods active`, with `, 2 failed` when some do not run; null without an enabled mod. */
	public static function modsLine(running:Int, stopped:Int):Null<String> {
		if (running + stopped == 0)
			return null;
		return running + (running == 1 ? " mod" : " mods") + " active" + (stopped > 0 ? ", " + stopped + " failed" : "");
	}

	/** `Failed: a, b, +3 more`, null when every mod runs. */
	public static function stoppedLine(ids:Array<String>):Null<String> {
		if (ids.length == 0)
			return null;
		var shown:Array<String> = [];
		var length = 0;
		for (id in ids) {
			if (shown.length > 0 && length + id.length > STOPPED_CHARACTERS)
				break;
			shown.push(id);
			length += id.length + 2;
		}
		if (shown.length < ids.length)
			shown.push("+" + (ids.length - shown.length) + " more");
		return "Failed: " + shown.join(", ");
	}

	/** Adds the block to the loading screen's clip, in the font of its `LOADING...`. */
	public static function show(screen:MovieClip):Void {
		if (screen == null)
			return;
		var block = new Sprite();
		var y = 40.0;
		y = line(block, release() + " by Tutez", 30, y);
		var stopped = Host.stoppedMods();
		var mods = modsLine(Host.runningMods(), stopped.length);
		if (mods != null)
			y = line(block, mods, 22, y);
		var failed = stoppedLine(stopped);
		if (failed != null)
			y = line(block, failed, 17, y);
		button(block, "Join the Discord server", "https://" + DISCORD, 26, y + 8);
		// On the clip's 1920x1080 stage, right of the studio's logo
		block.x = 1000;
		block.y = 600;
		block.scaleX = block.scaleY = 1.68;
		screen.addChild(block);
	}

	/** One centred line at `y`; returns where the next one goes. */
	static function line(block:Sprite, text:String, size:Int, y:Float):Float {
		var field = label(text, size, RED);
		field.y = y;
		block.addChild(field);
		return y + Math.fround(size * 1.3);
	}

	static function label(text:String, size:Int, color:Int):TextField {
		var field = new TextField();
		// The clip has registered the fonts its SWF exports before it reaches here
		field.embedFonts = true;
		var format = new TextFormat(FONT, size, color);
		format.align = TextFormatAlign.CENTER;
		field.defaultTextFormat = format;
		field.selectable = false;
		field.mouseEnabled = false;
		field.width = WIDTH;
		field.height = size * 1.5;
		field.text = text;
		return field;
	}

	/** A centred button at `y` that opens `url` in the browser. */
	static function button(block:Sprite, text:String, url:String, size:Int, y:Float):Void {
		var field = label(text, size, 0xFFFFFF);
		var width = field.textWidth + size * 1.4;
		var height = size * 1.5;
		var button = new Sprite();
		function draw(color:Int):Void {
			button.graphics.clear();
			button.graphics.beginFill(color);
			button.graphics.drawRoundRect((WIDTH - width) / 2, 0, width, height, height, height);
			button.graphics.endFill();
		}
		draw(BUTTON);
		field.y = (height - field.textHeight) / 2 - 2;
		button.addChild(field);
		button.y = y;
		button.buttonMode = true;
		button.mouseChildren = false;
		button.addEventListener(MouseEvent.ROLL_OVER, function(_) draw(BUTTON_OVER));
		button.addEventListener(MouseEvent.ROLL_OUT, function(_) draw(BUTTON));
		button.addEventListener(MouseEvent.CLICK, function(_) openfl.Lib.navigateToURL(new URLRequest(url)));
		block.addChild(button);
	}
}
