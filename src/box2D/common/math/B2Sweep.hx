package box2D.common.math;

class B2Sweep {
	public var localCenter:B2Vec2 = new B2Vec2();

	public var c0:B2Vec2 = new B2Vec2();

	public var c:B2Vec2 = new B2Vec2();

	public var a0:Float = Math.NaN;

	public var a:Float = Math.NaN;

	public var t0:Float = Math.NaN;

	public function new() {}

	public function Set(other:B2Sweep) {
		this.localCenter.SetV(other.localCenter);
		this.c0.SetV(other.c0);
		this.c.SetV(other.c);
		this.a0 = other.a0;
		this.a = other.a;
		this.t0 = other.t0;
	}

	public function Copy():B2Sweep {
		var _loc1_ = new B2Sweep();
		_loc1_.localCenter.SetV(this.localCenter);
		_loc1_.c0.SetV(this.c0);
		_loc1_.c.SetV(this.c);
		_loc1_.a0 = this.a0;
		_loc1_.a = this.a;
		_loc1_.t0 = this.t0;
		return _loc1_;
	}

	public function GetTransform(xf:B2Transform, alpha:Float) {
		xf.position.x = (1 - alpha) * this.c0.x + alpha * this.c.x;
		xf.position.y = (1 - alpha) * this.c0.y + alpha * this.c.y;
		var _loc3_ = (1 - alpha) * this.a0 + alpha * this.a;
		xf.R.Set(_loc3_);
		var _loc4_ = xf.R;
		xf.position.x -= _loc4_.col1.x * this.localCenter.x + _loc4_.col2.x * this.localCenter.y;
		xf.position.y -= _loc4_.col1.y * this.localCenter.x + _loc4_.col2.y * this.localCenter.y;
	}

	public function Advance(t:Float) {
		var _loc2_ = Math.NaN;
		if (this.t0 < t && 1 - this.t0 > ASCompat.MIN_FLOAT) {
			_loc2_ = (t - this.t0) / (1 - this.t0);
			this.c0.x = (1 - _loc2_) * this.c0.x + _loc2_ * this.c.x;
			this.c0.y = (1 - _loc2_) * this.c0.y + _loc2_ * this.c.y;
			this.a0 = (1 - _loc2_) * this.a0 + _loc2_ * this.a;
			this.t0 = t;
		}
	}
}
