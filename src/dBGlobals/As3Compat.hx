package dBGlobals;

class As3Compat {
	public function new() {}

	public static function isNaN(f:Float):Bool {
		return f != f;
	}

	public static function get_NAN():Float {
		return Math.NaN;
	}

	public static function truthy(v:ASAny):Bool {
		var _loc2_ = Math.NaN;
		if (v == null) {
			return false;
		}
		if (Std.isOfType(v, Bool)) {
			return ASCompat.toBool(v);
		}
		if (Std.isOfType(v, Int) || Std.isOfType(v, Float)) {
			_loc2_ = ASCompat.toNumber(v);
			if (_loc2_ != 0) {
				return _loc2_ == _loc2_;
			}
			return false;
		}
		if (Std.isOfType(v, String)) {
			return ASCompat.toNumberField(v, "length") > 0;
		}
		return true;
	}

	public static function truthyString(s:String):Bool {
		if (s != null) {
			return s.length > 0;
		}
		return false;
	}

	public static function toFloat(v:ASAny):Float {
		var _loc2_ = ASCompat.asString(null);
		if (v == null) {
			return 0;
		}
		if (Std.isOfType(v, String)) {
			_loc2_ = StringTools.trim(v);
			if (ASCompat.toNumberField(_loc2_, "length") == 0) {
				return 0;
			}
			return Std.parseFloat(_loc2_);
		}
		if (Std.isOfType(v, Bool)) {
			if (ASCompat.toBool(v)) {
				return 1;
			}
			return 0;
		}
		return ASCompat.toNumber(v);
	}

	public static function parseHex(s:String):Float {
		if (s == null) {
			return Math.NaN;
		}
		var _loc2_ = StringTools.trim(s);
		if (_loc2_.length == 0) {
			return Math.NaN;
		}
		return ASCompat.parseInt(_loc2_, 16);
	}

	public static function toUInt(v:ASAny):UInt {
		var _loc2_ = Math.NaN;
		if (v == null) {
			return (0 : UInt);
		}
		if (Std.isOfType(v, String)) {
			_loc2_ = ASCompat.parseInt(v);
			if (_loc2_ != _loc2_) {
				return (0 : UInt);
			}
			return (ASCompat.floatToInt(_loc2_) : UInt);
		}
		if (Std.isOfType(v, Bool)) {
			if (ASCompat.toBool(v)) {
				return (1 : UInt);
			}
			return (0 : UInt);
		}
		_loc2_ = ASCompat.toNumber(v);
		if (_loc2_ != _loc2_) {
			return (0 : UInt);
		}
		return (ASCompat.floatToInt(_loc2_) : UInt);
	}

	public static function values(o:ASAny):Array<ASAny> {
		var _loc5_:ASAny = ASCompat.asString(null);
		var _loc2_:Array<ASAny> = [];
		if (o == null) {
			return _loc2_;
		}
		if (Std.isOfType(o, Array)) {
			return ASCompat.coerce(o, Array);
		}
		var _loc3_ = 0;
		var _loc4_ = Reflect.fields(o);
		while (_loc3_ < _loc4_.length) {
			_loc5_ = _loc4_[_loc3_];
			_loc3_++;
			_loc2_.push(Reflect.field(o, _loc5_));
		}
		return _loc2_;
	}
}
