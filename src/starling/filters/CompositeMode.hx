package starling.filters;

import starling.errors.AbstractClassError;

class CompositeMode {
	public static inline final NORMAL = "normal";

	public static inline final INSIDE = "inside";

	public static inline final OUTSIDE = "outside";

	public static inline final INSIDE_KNOCKOUT = "insideKnockout";

	public static inline final OUTSIDE_KNOCKOUT = "outsideKnockout";

	static var allModes:Array<ASAny>;

	public function new() {
		throw new AbstractClassError();
	}

	public static function getIndex(mode:String):Int {
		return allModes.indexOf(mode);
	}

	static function __init__() {
		allModes = ["normal", "inside", "insideKnockout", "outside", "outsideKnockout"];
	}
}
