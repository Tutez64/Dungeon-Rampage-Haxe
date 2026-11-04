package starling.utils;

import starling.errors.AbstractClassError;

final class Align {
	public static inline final LEFT = "left";

	public static inline final RIGHT = "right";

	public static inline final TOP = "top";

	public static inline final BOTTOM = "bottom";

	public static inline final CENTER = "center";

	public function new() {
		throw new AbstractClassError();
	}

	public static function isValid(align:String):Bool {
		return align == "left" || align == "right" || align == "center" || align == "top" || align == "bottom";
	}

	public static function isValidHorizontal(align:String):Bool {
		return align == "left" || align == "center" || align == "right";
	}

	public static function isValidVertical(align:String):Bool {
		return align == "top" || align == "center" || align == "bottom";
	}
}
