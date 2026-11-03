package starling.extensions.animate;

import starling.errors.AbstractClassError;
import flash.errors.ArgumentError;

/*internal*/
class SymbolType {
	public static inline final GRAPHIC = "graphic";

	public static inline final MOVIE_CLIP = "movieclip";

	public static inline final BUTTON = "button";

	public function new() {
		throw new AbstractClassError();
	}

	public static function isValid(value:String):Bool {
		return value == "graphic" || value == "movieclip" || value == "button";
	}

	public static function parse(value:String):String {
		switch (value) {
			case "G" | "graphic":

			case "MC" | "movieclip":
				return "movieclip";
			case "B" | "button":
				return "button";
			default:
				throw new ArgumentError("Invalid symbol type: " + value);
		}
		return "graphic";
	}
}
