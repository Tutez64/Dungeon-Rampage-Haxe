package box2dcompat;

class As3Array {
	public function new() {}

	public static function of(v:ASAny):Array<ASAny> {
		var _loc6_ = 0;
		if (v == null || Std.isOfType(v, Array)) {
			return ASCompat.coerce(v, Array);
		}
		var _loc2_ = ASCompat.toInt(v.length);
		var _loc3_:Array<ASAny> = [];
		var _loc4_ = 0;
		var _loc5_ = _loc2_;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc3_[_loc6_] = v[_loc6_];
		}
		return _loc3_;
	}
}
