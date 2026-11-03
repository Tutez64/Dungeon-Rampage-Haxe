package starling.display;

import starling.core.Starling;
import flash.errors.ArgumentError;

class BlendMode {
	static var sBlendModes:ASObject;

	public static inline final AUTO = "auto";

	public static inline final NONE = "none";

	public static inline final NORMAL = "normal";

	public static inline final ADD = "add";

	public static inline final MULTIPLY = "multiply";

	public static inline final SCREEN = "screen";

	public static inline final ERASE = "erase";

	public static inline final MASK = "mask";

	public static inline final BELOW = "below";

	var _name:String;

	var _sourceFactor:String;

	var _destinationFactor:String;

	public function new(name:String, sourceFactor:String, destinationFactor:String) {
		_name = name;
		_sourceFactor = sourceFactor;
		_destinationFactor = destinationFactor;
	}

	public static function get(modeName:String):BlendMode {
		if (sBlendModes == null) {
			registerDefaults();
		}
		if (sBlendModes.hasOwnProperty(modeName)) {
			return ASCompat.coerce(sBlendModes[modeName], BlendMode);
		}
		throw new ArgumentError("Blend mode not found: " + modeName);
		return null;
	}

	public static function register(name:String, srcFactor:String, dstFactor:String):BlendMode {
		if (sBlendModes == null) {
			registerDefaults();
		}
		var _loc4_ = new BlendMode(name, srcFactor, dstFactor);
		sBlendModes[name] = _loc4_;
		return _loc4_;
	}

	static function registerDefaults() {
		if (ASCompat.toBool(sBlendModes)) {
			return;
		}
		sBlendModes = {};
		register("none", "one", "zero");
		register("normal", "one", "oneMinusSourceAlpha");
		register("add", "one", "one");
		register("multiply", "destinationColor", "oneMinusSourceAlpha");
		register("screen", "one", "oneMinusSourceColor");
		register("erase", "zero", "oneMinusSourceAlpha");
		register("mask", "zero", "sourceAlpha");
		register("below", "oneMinusDestinationAlpha", "destinationAlpha");
	}

	public static function getAll(out:Array<ASAny> = null):Array<ASAny> {
		if (out == null) {
			out = [];
		}
		if (sBlendModes == null) {
			registerDefaults();
		}
		var _loc2_:BlendMode;
		final __ax4_iter_416:ASObject = sBlendModes;
		if (checkNullIteratee(__ax4_iter_416))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_416)) {
				_loc2_ = ASCompat.coerce(_tmp_, BlendMode);
				out.insert(0, _loc2_);
			}
		return out;
	}

	public static function isRegistered(modeName:String):Bool {
		if (sBlendModes == null) {
			registerDefaults();
		}
		return sBlendModes.hasOwnProperty(modeName);
	}

	public function activate() {
		Starling.context.setBlendFactors(_sourceFactor, _destinationFactor);
	}

	public function toString():String {
		return _name;
	}

	@:isVar public var sourceFactor(get, never):String;

	public function get_sourceFactor():String {
		return _sourceFactor;
	}

	@:isVar public var destinationFactor(get, never):String;

	public function get_destinationFactor():String {
		return _destinationFactor;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return _name;
	}
}
