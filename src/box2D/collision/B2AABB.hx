package box2D.collision;

import box2D.common.math.B2Vec2;

class B2AABB {
	public var lowerBound:B2Vec2 = new B2Vec2();

	public var upperBound:B2Vec2 = new B2Vec2();

	public function new() {}

	public static function Combine(aabb1:B2AABB, aabb2:B2AABB):B2AABB {
		var _loc3_ = new B2AABB();
		_loc3_._Combine(aabb1, aabb2);
		return _loc3_;
	}

	public function IsValid():Bool {
		var _loc1_ = this.upperBound.x - this.lowerBound.x;
		var _loc2_ = this.upperBound.y - this.lowerBound.y;
		var _loc3_ = _loc1_ >= 0 && _loc2_ >= 0;
		return _loc3_ && this.lowerBound.IsValid() && this.upperBound.IsValid();
	}

	public function GetCenter():B2Vec2 {
		return new B2Vec2((this.lowerBound.x + this.upperBound.x) / 2, (this.lowerBound.y + this.upperBound.y) / 2);
	}

	public function GetExtents():B2Vec2 {
		return new B2Vec2((this.upperBound.x - this.lowerBound.x) / 2, (this.upperBound.y - this.lowerBound.y) / 2);
	}

	public function Contains(aabb:B2AABB):Bool {
		var _loc2_ = true;
		_loc2_ = _loc2_ && this.lowerBound.x <= aabb.lowerBound.x;
		_loc2_ = _loc2_ && this.lowerBound.y <= aabb.lowerBound.y;
		_loc2_ = _loc2_ && aabb.upperBound.x <= this.upperBound.x;
		return _loc2_ && aabb.upperBound.y <= this.upperBound.y;
	}

	public function RayCast(output:B2RayCastOutput, input:B2RayCastInput):Bool {
		var _loc11_:B2Vec2 = null;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc3_ = -ASCompat.MAX_FLOAT;
		var _loc4_:Float = ASCompat.MAX_FLOAT;
		var _loc5_ = input.p1.x;
		var _loc6_ = input.p1.y;
		var _loc7_ = input.p2.x - input.p1.x;
		var _loc8_ = input.p2.y - input.p1.y;
		var _loc9_ = Math.abs(_loc7_);
		var _loc10_ = Math.abs(_loc8_);
		_loc11_ = output.normal;
		if (_loc9_ < ASCompat.MIN_FLOAT) {
			if (_loc5_ < this.lowerBound.x || this.upperBound.x < _loc5_) {
				return false;
			}
		} else {
			_loc12_ = 1 / _loc7_;
			_loc13_ = (this.lowerBound.x - _loc5_) * _loc12_;
			_loc14_ = (this.upperBound.x - _loc5_) * _loc12_;
			_loc16_ = -1;
			if (_loc13_ > _loc14_) {
				_loc15_ = _loc13_;
				_loc13_ = _loc14_;
				_loc14_ = _loc15_;
				_loc16_ = 1;
			}
			if (_loc13_ > _loc3_) {
				_loc11_.x = _loc16_;
				_loc11_.y = 0;
				_loc3_ = _loc13_;
			}
			_loc4_ = Math.min(_loc4_, _loc14_);
			if (_loc3_ > _loc4_) {
				return false;
			}
		}
		if (_loc10_ < ASCompat.MIN_FLOAT) {
			if (_loc6_ < this.lowerBound.y || this.upperBound.y < _loc6_) {
				return false;
			}
		} else {
			_loc12_ = 1 / _loc8_;
			_loc13_ = (this.lowerBound.y - _loc6_) * _loc12_;
			_loc14_ = (this.upperBound.y - _loc6_) * _loc12_;
			_loc16_ = -1;
			if (_loc13_ > _loc14_) {
				_loc15_ = _loc13_;
				_loc13_ = _loc14_;
				_loc14_ = _loc15_;
				_loc16_ = 1;
			}
			if (_loc13_ > _loc3_) {
				_loc11_.y = _loc16_;
				_loc11_.x = 0;
				_loc3_ = _loc13_;
			}
			_loc4_ = Math.min(_loc4_, _loc14_);
			if (_loc3_ > _loc4_) {
				return false;
			}
		}
		output.fraction = _loc3_;
		return true;
	}

	public function TestOverlap(other:B2AABB):Bool {
		var _loc2_ = other.lowerBound.x - this.upperBound.x;
		var _loc3_ = other.lowerBound.y - this.upperBound.y;
		var _loc4_ = this.lowerBound.x - other.upperBound.x;
		var _loc5_ = this.lowerBound.y - other.upperBound.y;
		if (_loc2_ > 0 || _loc3_ > 0) {
			return false;
		}
		if (_loc4_ > 0 || _loc5_ > 0) {
			return false;
		}
		return true;
	}

	public function _Combine /*renamed*/ (aabb1:B2AABB, aabb2:B2AABB) {
		this.lowerBound.x = Math.min(aabb1.lowerBound.x, aabb2.lowerBound.x);
		this.lowerBound.y = Math.min(aabb1.lowerBound.y, aabb2.lowerBound.y);
		this.upperBound.x = Math.max(aabb1.upperBound.x, aabb2.upperBound.x);
		this.upperBound.y = Math.max(aabb1.upperBound.y, aabb2.upperBound.y);
	}
}
