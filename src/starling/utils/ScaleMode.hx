package starling.utils;

import starling.errors.AbstractClassError;

class ScaleMode {
	public static inline final NONE = "none";

	public static inline final NO_BORDER = "noBorder";

	public static inline final SHOW_ALL = "showAll";

	public function new() {
		throw new AbstractClassError();
	}

	public static function isValid(scaleMode:String):Bool {
		return scaleMode == "none" || scaleMode == "noBorder" || scaleMode == "showAll";
	}
}
