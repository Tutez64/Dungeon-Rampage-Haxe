package modding;

import openfl.display.MovieClip;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * The lines the loading screen shows under its bar: this build's release and where to find its
 * community. `modding.Hooks` has `DBFacade.init` call `show` once the screen's clip is made.
 */
class LoadingCredits {
	static inline final DISCORD = "discord.gg/VvWbNspZrQ";

	/** `DRH V18`, or `DRH dev` for a build that no release tag was given to. */
	public static function release():String {
		return "DRH " + (Version.TAG == "0" ? "dev" : "V" + Version.TAG);
	}

	/** Adds the lines to the loading screen's clip, in the font of its `LOADING...`. */
	public static function show(screen:MovieClip):Void {
		if (screen == null)
			return;
		var field = new TextField();
		// The clip has registered the fonts its SWF exports before it reaches here
		field.embedFonts = true;
		var format = new TextFormat("Fat Rhino PB", 30, 0xFF0000);
		format.align = TextFormatAlign.CENTER;
		format.leading = -2;
		field.defaultTextFormat = format;
		field.multiline = true;
		field.wordWrap = true;
		field.width = 500;
		field.height = 250;
		field.text = "\n" + release() + " by Tutez\nJoin the Discord server:\n" + DISCORD;
		// On the clip's 1920x1080 stage, right of the studio's logo
		field.x = 1000;
		field.y = 600;
		field.scaleX = field.scaleY = 1.68;
		screen.addChild(field);
	}
}
