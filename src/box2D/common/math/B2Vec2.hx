package box2D.common.math;

class B2Vec2 {
	public var x:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public function new(x_:Float = 0, y_:Float = 0) {
		this.x = x_;
		this.y = y_;
	}

	public static function Make(x_:Float, y_:Float):B2Vec2 {
		return new B2Vec2(x_, y_);
	}

	public function SetZero() {
		this.x = 0;
		this.y = 0;
	}

	public function Set(x_:Float = 0, y_:Float = 0) {
		this.x = x_;
		this.y = y_;
	}

	public function SetV(v:B2Vec2) {
		this.x = v.x;
		this.y = v.y;
	}

	public function GetNegative():B2Vec2 {
		return new B2Vec2(-this.x, -this.y);
	}

	public function NegativeSelf() {
		this.x = -this.x;
		this.y = -this.y;
	}

	public function Copy():B2Vec2 {
		return new B2Vec2(this.x, this.y);
	}

	public function Add(v:B2Vec2) {
		this.x += v.x;
		this.y += v.y;
	}

	public function Subtract(v:B2Vec2) {
		this.x -= v.x;
		this.y -= v.y;
	}

	public function Multiply(a:Float) {
		this.x *= a;
		this.y *= a;
	}

	public function MulM(A:B2Mat22) {
		var _loc2_ = this.x;
		this.x = A.col1.x * _loc2_ + A.col2.x * this.y;
		this.y = A.col1.y * _loc2_ + A.col2.y * this.y;
	}

	public function MulTM(A:B2Mat22) {
		var _loc2_ = B2Math.Dot(this, A.col1);
		this.y = B2Math.Dot(this, A.col2);
		this.x = _loc2_;
	}

	public function CrossVF(s:Float) {
		var _loc2_ = this.x;
		this.x = s * this.y;
		this.y = -s * _loc2_;
	}

	public function CrossFV(s:Float) {
		var _loc2_ = this.x;
		this.x = -s * this.y;
		this.y = s * _loc2_;
	}

	public function MinV(b:B2Vec2) {
		this.x = this.x < b.x ? this.x : b.x;
		this.y = this.y < b.y ? this.y : b.y;
	}

	public function MaxV(b:B2Vec2) {
		this.x = this.x > b.x ? this.x : b.x;
		this.y = this.y > b.y ? this.y : b.y;
	}

	public function Abs() {
		if (this.x < 0) {
			this.x = -this.x;
		}
		if (this.y < 0) {
			this.y = -this.y;
		}
	}

	public function Length():Float {
		return Math.sqrt(this.x * this.x + this.y * this.y);
	}

	public function LengthSquared():Float {
		return this.x * this.x + this.y * this.y;
	}

	public function Normalize():Float {
		var _loc1_ = Math.sqrt(this.x * this.x + this.y * this.y);
		if (_loc1_ < ASCompat.MIN_FLOAT) {
			return 0;
		}
		var _loc2_ = 1 / _loc1_;
		this.x *= _loc2_;
		this.y *= _loc2_;
		return _loc1_;
	}

	public function IsValid():Bool {
		return B2Math.IsValid(this.x) && B2Math.IsValid(this.y);
	}
}
