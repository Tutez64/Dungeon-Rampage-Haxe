package starling.animation;

import starling.errors.AbstractClassError;

class Transitions {
	public static inline final LINEAR = "linear";

	public static inline final EASE_IN = "easeIn";

	public static inline final EASE_OUT = "easeOut";

	public static inline final EASE_IN_OUT = "easeInOut";

	public static inline final EASE_OUT_IN = "easeOutIn";

	public static inline final EASE_IN_BACK = "easeInBack";

	public static inline final EASE_OUT_BACK = "easeOutBack";

	public static inline final EASE_IN_OUT_BACK = "easeInOutBack";

	public static inline final EASE_OUT_IN_BACK = "easeOutInBack";

	public static inline final EASE_IN_ELASTIC = "easeInElastic";

	public static inline final EASE_OUT_ELASTIC = "easeOutElastic";

	public static inline final EASE_IN_OUT_ELASTIC = "easeInOutElastic";

	public static inline final EASE_OUT_IN_ELASTIC = "easeOutInElastic";

	public static inline final EASE_IN_BOUNCE = "easeInBounce";

	public static inline final EASE_OUT_BOUNCE = "easeOutBounce";

	public static inline final EASE_IN_OUT_BOUNCE = "easeInOutBounce";

	public static inline final EASE_OUT_IN_BOUNCE = "easeOutInBounce";

	static var sTransitions:ASDictionary<ASAny, ASAny>;

	public function new() {
		throw new AbstractClassError();
	}

	public static function getTransition(name:String):ASFunction {
		if (sTransitions == null) {
			registerDefaults();
		}
		return ASCompat.coerceFunction(ASDictionary.getString(sTransitions, name));
	}

	public static function register(name:String, func:ASFunction) {
		if (sTransitions == null) {
			registerDefaults();
		}
		sTransitions[name] = func;
	}

	static function registerDefaults() {
		sTransitions = new ASDictionary<ASAny, ASAny>();
		register("linear", linear);
		register("easeIn", easeIn);
		register("easeOut", easeOut);
		register("easeInOut", easeInOut);
		register("easeOutIn", easeOutIn);
		register("easeInBack", easeInBack);
		register("easeOutBack", easeOutBack);
		register("easeInOutBack", easeInOutBack);
		register("easeOutInBack", easeOutInBack);
		register("easeInElastic", easeInElastic);
		register("easeOutElastic", easeOutElastic);
		register("easeInOutElastic", easeInOutElastic);
		register("easeOutInElastic", easeOutInElastic);
		register("easeInBounce", easeInBounce);
		register("easeOutBounce", easeOutBounce);
		register("easeInOutBounce", easeInOutBounce);
		register("easeOutInBounce", easeOutInBounce);
	}

	static function linear(ratio:Float):Float {
		return ratio;
	}

	static function easeIn(ratio:Float):Float {
		return ratio * ratio * ratio;
	}

	static function easeOut(ratio:Float):Float {
		var _loc2_ = ratio - 1;
		return _loc2_ * _loc2_ * _loc2_ + 1;
	}

	static function easeInOut(ratio:Float):Float {
		return easeCombined(easeIn, easeOut, ratio);
	}

	static function easeOutIn(ratio:Float):Float {
		return easeCombined(easeOut, easeIn, ratio);
	}

	static function easeInBack(ratio:Float):Float {
		var _loc2_:Float = 1.70158;
		return Math.pow(ratio, 2) * ((_loc2_ + 1) * ratio - _loc2_);
	}

	static function easeOutBack(ratio:Float):Float {
		var _loc3_ = ratio - 1;
		var _loc2_:Float = 1.70158;
		return Math.pow(_loc3_, 2) * ((_loc2_ + 1) * _loc3_ + _loc2_) + 1;
	}

	static function easeInOutBack(ratio:Float):Float {
		return easeCombined(easeInBack, easeOutBack, ratio);
	}

	static function easeOutInBack(ratio:Float):Float {
		return easeCombined(easeOutBack, easeInBack, ratio);
	}

	static function easeInElastic(ratio:Float):Float {
		var _loc2_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc4_ = Math.NaN;
		if (ratio == 0 || ratio == 1) {
			return ratio;
		}
		_loc2_ = 0.3;
		_loc3_ = _loc2_ / 4;
		_loc4_ = ratio - 1;
		return -1 * Math.pow(2, 10 * _loc4_) * Math.sin((_loc4_ - _loc3_) * (2 * 3.141592653589793) / _loc2_);
	}

	static function easeOutElastic(ratio:Float):Float {
		var _loc2_ = Math.NaN;
		var _loc3_ = Math.NaN;
		if (ratio == 0 || ratio == 1) {
			return ratio;
		}
		_loc2_ = 0.3;
		_loc3_ = _loc2_ / 4;
		return Math.pow(2, -10 * ratio) * Math.sin((ratio - _loc3_) * (2 * 3.141592653589793) / _loc2_) + 1;
	}

	static function easeInOutElastic(ratio:Float):Float {
		return easeCombined(easeInElastic, easeOutElastic, ratio);
	}

	static function easeOutInElastic(ratio:Float):Float {
		return easeCombined(easeOutElastic, easeInElastic, ratio);
	}

	static function easeInBounce(ratio:Float):Float {
		return 1 - easeOutBounce(1 - ratio);
	}

	static function easeOutBounce(ratio:Float):Float {
		var _loc4_ = Math.NaN;
		var _loc3_:Float = 7.5625;
		var _loc2_:Float = 2.75;
		if (ratio < 1 / _loc2_) {
			_loc4_ = _loc3_ * Math.pow(ratio, 2);
		} else if (ratio < 2 / _loc2_) {
			ratio -= 1.5 / _loc2_;
			_loc4_ = _loc3_ * Math.pow(ratio, 2) + 0.75;
		} else if (ratio < 2.5 / _loc2_) {
			ratio -= 2.25 / _loc2_;
			_loc4_ = _loc3_ * Math.pow(ratio, 2) + 0.9375;
		} else {
			ratio -= 2.625 / _loc2_;
			_loc4_ = _loc3_ * Math.pow(ratio, 2) + 0.984375;
		}
		return _loc4_;
	}

	static function easeInOutBounce(ratio:Float):Float {
		return easeCombined(easeInBounce, easeOutBounce, ratio);
	}

	static function easeOutInBounce(ratio:Float):Float {
		return easeCombined(easeOutBounce, easeInBounce, ratio);
	}

	static function easeCombined(startFunc:ASFunction, endFunc:ASFunction, ratio:Float):Float {
		if (ratio < 0.5) {
			return 0.5 * ASCompat.toNumber(startFunc(ratio * 2));
		}
		return 0.5 * ASCompat.toNumber(endFunc((ratio - 0.5) * 2)) + 0.5;
	}
}
