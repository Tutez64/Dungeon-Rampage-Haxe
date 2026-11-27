package starling.textures;

import starling.errors.AbstractClassError;

class TextureSmoothing {
	public static inline final NONE = "none";

	public static inline final BILINEAR = "bilinear";

	public static inline final TRILINEAR = "trilinear";

	public function new() {
		throw new AbstractClassError();
	}

	public static function isValid(smoothing:String):Bool {
		return smoothing == "none" || smoothing == "bilinear" || smoothing == "trilinear";
	}
}
