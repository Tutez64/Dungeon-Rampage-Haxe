package box2D.common.math;

class B2Sweep {
	public var t0:Float = Math.NaN;

	public var localCenter:B2Vec2;

	public var c0:B2Vec2;

	public var c:B2Vec2;

	public var a0:Float = Math.NaN;

	public var a:Float = Math.NaN;

	public function new() {
		localCenter = new B2Vec2();
		c0 = new B2Vec2();
		c = new B2Vec2();
	}

	public function set(other:B2Sweep) {
		Set(other);
	}

	public function getTransform(xf:B2Transform, alpha:Float) {
		GetTransform(xf, alpha);
	}

	public function copy():B2Sweep {
		return Copy();
	}

	public function advance(t:Float) {
		Advance(t);
	}

	public function Set(other:B2Sweep) {
		localCenter.setV(other.localCenter);
		c0.setV(other.c0);
		c.setV(other.c);
		a0 = other.a0;
		a = other.a;
		t0 = other.t0;
	}

	public function GetTransform(xf:B2Transform, alpha:Float) {
		xf.position.x = (1 - alpha) * c0.x + alpha * c.x;
		xf.position.y = (1 - alpha) * c0.y + alpha * c.y;
		var _loc3_ = (1 - alpha) * a0 + alpha * a;
		xf.R.set(_loc3_);
		var _loc4_ = xf.R;
		xf.position.x -= _loc4_.col1.x * localCenter.x + _loc4_.col2.x * localCenter.y;
		xf.position.y -= _loc4_.col1.y * localCenter.x + _loc4_.col2.y * localCenter.y;
	}

	public function Copy():B2Sweep {
		var _loc1_ = new B2Sweep();
		_loc1_.localCenter.setV(localCenter);
		_loc1_.c0.setV(c0);
		_loc1_.c.setV(c);
		_loc1_.a0 = a0;
		_loc1_.a = a;
		_loc1_.t0 = t0;
		return _loc1_;
	}

	public function Advance(t:Float) {
		var _loc2_ = Math.NaN;
		if (t0 < t && 1 - t0 > ASCompat.MIN_FLOAT) {
			_loc2_ = (t - t0) / (1 - t0);
			c0.x = (1 - _loc2_) * c0.x + _loc2_ * c.x;
			c0.y = (1 - _loc2_) * c0.y + _loc2_ * c.y;
			a0 = (1 - _loc2_) * a0 + _loc2_ * a;
			t0 = t;
		}
	}
}
