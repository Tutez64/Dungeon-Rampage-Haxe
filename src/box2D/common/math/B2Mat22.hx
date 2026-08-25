package box2D.common.math;

class B2Mat22 {
	public var col1:B2Vec2 = new B2Vec2();

	public var col2:B2Vec2 = new B2Vec2();

	public function new() {
		this.col1.x = this.col2.y = 1;
	}

	public static function FromAngle(angle:Float):B2Mat22 {
		var _loc2_ = new B2Mat22();
		_loc2_.Set(angle);
		return _loc2_;
	}

	public static function FromVV(c1:B2Vec2, c2:B2Vec2):B2Mat22 {
		var _loc3_ = new B2Mat22();
		_loc3_.SetVV(c1, c2);
		return _loc3_;
	}

	public function Set(angle:Float) {
		var _loc2_ = Math.NaN;
		_loc2_ = Math.cos(angle);
		var _loc3_ = Math.sin(angle);
		this.col1.x = _loc2_;
		this.col2.x = -_loc3_;
		this.col1.y = _loc3_;
		this.col2.y = _loc2_;
	}

	public function SetVV(c1:B2Vec2, c2:B2Vec2) {
		this.col1.SetV(c1);
		this.col2.SetV(c2);
	}

	public function Copy():B2Mat22 {
		var _loc1_ = new B2Mat22();
		_loc1_.SetM(this);
		return _loc1_;
	}

	public function SetM(m:B2Mat22) {
		this.col1.SetV(m.col1);
		this.col2.SetV(m.col2);
	}

	public function AddM(m:B2Mat22) {
		this.col1.x += m.col1.x;
		this.col1.y += m.col1.y;
		this.col2.x += m.col2.x;
		this.col2.y += m.col2.y;
	}

	public function SetIdentity() {
		this.col1.x = 1;
		this.col2.x = 0;
		this.col1.y = 0;
		this.col2.y = 1;
	}

	public function SetZero() {
		this.col1.x = 0;
		this.col2.x = 0;
		this.col1.y = 0;
		this.col2.y = 0;
	}

	public function GetAngle():Float {
		return Math.atan2(this.col1.y, this.col1.x);
	}

	public function GetInverse(out:B2Mat22):B2Mat22 {
		var _loc3_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc2_ = this.col1.x;
		_loc3_ = this.col2.x;
		var _loc4_ = this.col1.y;
		var _loc5_ = this.col2.y;
		_loc6_ = _loc2_ * _loc5_ - _loc3_ * _loc4_;
		if (_loc6_ != 0) {
			_loc6_ = 1 / _loc6_;
		}
		out.col1.x = _loc6_ * _loc5_;
		out.col2.x = -_loc6_ * _loc3_;
		out.col1.y = -_loc6_ * _loc4_;
		out.col2.y = _loc6_ * _loc2_;
		return out;
	}

	public function Solve(out:B2Vec2, bX:Float, bY:Float):B2Vec2 {
		var _loc4_ = this.col1.x;
		var _loc5_ = this.col2.x;
		var _loc6_ = this.col1.y;
		var _loc7_ = this.col2.y;
		var _loc8_ = _loc4_ * _loc7_ - _loc5_ * _loc6_;
		if (_loc8_ != 0) {
			_loc8_ = 1 / _loc8_;
		}
		out.x = _loc8_ * (_loc7_ * bX - _loc5_ * bY);
		out.y = _loc8_ * (_loc4_ * bY - _loc6_ * bX);
		return out;
	}

	public function Abs() {
		this.col1.Abs();
		this.col2.Abs();
	}
}
