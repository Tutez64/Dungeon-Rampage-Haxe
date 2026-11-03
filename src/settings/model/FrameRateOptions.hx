package settings.model;

class FrameRateOptions {
	public static inline final DEFAULT:Float = 60;

	public static inline final UNLIMITED:Float = 1000;

	static var DIVISORS:Array<ASAny>;

	var mChoices:Vector<SettingChoice> = new Vector();

	public function new() {
		remember(24);
		remember(30);
		remember(60);
		remember(1000);
	}

	public static function coerce(raw:ASAny):Float {
		if (!Std.isOfType(raw, Float) && !Std.isOfType(raw, String)) {
			return 60;
		}
		var _loc2_ = ASCompat.toNumber(raw);
		return Math.isFinite(_loc2_) && _loc2_ >= 0.01 && _loc2_ <= 1000 ? _loc2_ : 60;
	}

	static function compareRates(a:SettingChoice, b:SettingChoice):Float {
		return ASCompat.toNumber(a.value) - ASCompat.toNumber(b.value);
	}

	@:isVar public var choices(get, never):Vector<SettingChoice>;

	public function get_choices():Vector<SettingChoice> {
		return mChoices;
	}

	public function remember(value:Float):Bool {
		if (!Math.isFinite(value) || value < 0.01 || value > 1000) {
			return false;
		}
		var _loc2_:SettingChoice;
		final __ax4_iter_471 = mChoices;
		if (checkNullIteratee(__ax4_iter_471))
			for (_tmp_ in __ax4_iter_471) {
				_loc2_ = _tmp_;
				if (ASCompat.toNumberField(_loc2_, "value") == value) {
					return false;
				}
			}
		mChoices.push(new SettingChoice(value, value == 1000 ? "SETTING_FPS_UNLIMITED" : null));
		ASCompat.ASVector.sort(mChoices, compareRates);
		return true;
	}

	public function rememberMonitor(hz:Float):Bool {
		var _loc4_ = Math.NaN;
		if (!Math.isFinite(hz) || hz <= 0) {
			return false;
		}
		var _loc6_ = remember(hz);
		var _loc5_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc2_:Int;
		final __ax4_iter_472 = DIVISORS;
		if (checkNullIteratee(__ax4_iter_472))
			for (_tmp_ in __ax4_iter_472) {
				_loc2_ = ASCompat.toInt(_tmp_);
				_loc4_ = hz / _loc2_;
				if (!(_loc4_ < 44 || _loc4_ > 93)) {
					if (_loc4_ != 60
						&& (Math.isNaN(_loc5_)
							|| Math.abs(_loc4_ - 60) < Math.abs(_loc5_ - 60)
							|| Math.abs(_loc4_ - 60) == Math.abs(_loc5_ - 60)
							&& _loc4_ < _loc5_)) {
						_loc5_ = _loc4_;
					}
					if (Math.isNaN(_loc3_) || _loc4_ > _loc3_) {
						_loc3_ = _loc4_;
					}
				}
			}
		if (remember(_loc5_)) {
			_loc6_ = true;
		}
		if (remember(_loc3_)) {
			_loc6_ = true;
		}
		return _loc6_;
	}

	static function __init__() {
		DIVISORS = [2, 3, 4, 5, 6, 8, 10];
	}
}
