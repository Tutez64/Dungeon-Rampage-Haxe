package starling.extensions.animate;

import starling.errors.AbstractClassError;
import flash.errors.ArgumentError;

/*internal*/
class LoopMode {
	public static inline final LOOP = "loop";

	public static inline final PLAY_ONCE = "playonce";

	public static inline final SINGLE_FRAME = "singleframe";

	public function new() {
		throw new AbstractClassError();
	}

	public static function isValid(value:String):Bool {
		return value == "loop" || value == "playonce" || value == "singleframe";
	}

	public static function parse(value:String):String {
		switch (value) {
			case "LP" | "loop":

			case "PO" | "playonce":
				return "playonce";
			case "SF" | "singleframe":
				return "singleframe";
			default:
				throw new ArgumentError("Invalid loop mode: " + value);
		}
		return "loop";
	}
}
