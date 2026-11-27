package actor;

final class ActorMousePick {
	public static inline final STRIDE = 4;

	public function new() {}

	public static function nearest(px:Float, py:Float, rects:Vector<Float>, count:Int, keep:Int = -1):Int {
		var _loc8_ = 0;
		var _loc11_ = 0;
		var _loc14_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc9_ = -1;
		var _loc16_ = Math.POSITIVE_INFINITY;
		_loc8_ = 0;
		while (_loc8_ < count) {
			_loc11_ = _loc8_ * 4;
			_loc14_ = rects[_loc11_];
			_loc12_ = rects[_loc11_ + 1];
			_loc10_ = rects[_loc11_ + 2];
			_loc7_ = rects[_loc11_ + 3];
			if (!(px < _loc14_ || px > _loc10_ || py < _loc12_ || py > _loc7_)) {
				_loc13_ = (_loc14_ + _loc10_) * 0.5 - px;
				_loc15_ = (_loc12_ + _loc7_) * 0.5 - py;
				_loc6_ = _loc13_ * _loc13_ + _loc15_ * _loc15_;
				if (_loc6_ < _loc16_ || _loc6_ == _loc16_ && _loc8_ == keep) {
					_loc9_ = _loc8_;
					_loc16_ = _loc6_;
				}
			}
			_loc8_++;
		}
		return _loc9_;
	}
}
