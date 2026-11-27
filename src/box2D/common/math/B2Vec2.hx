package box2D.common.math;

class B2Vec2 {
	public var y:Float = Math.NaN;

	public var x:Float = Math.NaN;

	public function new(x_:Float = 0, y_:Float = 0) {
		x = x_;
		y = y_;
	}

	public static function make(x_:Float, y_:Float):B2Vec2 {
		return new B2Vec2(x_, y_);
	}

	public static function Make(x_:Float, y_:Float):B2Vec2 {
		return B2Vec2.make(x_, y_);
	}

	public function subtract(v:B2Vec2) {
		Subtract(v);
	}

	public function setZero() {
		SetZero();
	}

	public function setV(v:B2Vec2) {
		SetV(v);
	}

	public function set(x_:Float = 0, y_:Float = 0) {
		Set(x_, y_);
	}

	public function normalize():Float {
		return Normalize();
	}

	public function negativeSelf() {
		NegativeSelf();
	}

	public function multiply(a:Float) {
		Multiply(a);
	}

	public function mulTM(A:B2Mat22) {
		MulTM(A);
	}

	public function mulM(A:B2Mat22) {
		MulM(A);
	}

	public function minV(b:B2Vec2) {
		MinV(b);
	}

	public function maxV(b:B2Vec2) {
		MaxV(b);
	}

	public function lengthSquared():Float {
		return LengthSquared();
	}

	public function length():Float {
		return Length();
	}

	public function isValid():Bool {
		return IsValid();
	}

	public function getNegative():B2Vec2 {
		return GetNegative();
	}

	public function crossVF(s:Float) {
		CrossVF(s);
	}

	public function crossFV(s:Float) {
		CrossFV(s);
	}

	public function copy():B2Vec2 {
		return Copy();
	}

	public function add(v:B2Vec2) {
		Add(v);
	}

	public function abs() {
		Abs();
	}

	public function Subtract(v:B2Vec2) {
		x -= v.x;
		y -= v.y;
	}

	public function SetZero() {
		x = 0;
		y = 0;
	}

	public function SetV(v:B2Vec2) {
		x = v.x;
		y = v.y;
	}

	public function Set(x_:Float = 0, y_:Float = 0) {
		x = x_;
		y = y_;
	}

	public function Normalize():Float {
		var _loc1_ = Math.sqrt(x * x + y * y);
		if (_loc1_ < ASCompat.MIN_FLOAT) {
			return 0;
		}
		var _loc2_ = 1 / _loc1_;
		x *= _loc2_;
		y *= _loc2_;
		return _loc1_;
	}

	public function NegativeSelf() {
		x = -x;
		y = -y;
	}

	public function Multiply(a:Float) {
		x *= a;
		y *= a;
	}

	public function MulTM(A:B2Mat22) {
		var _loc2_ = B2Math.dot(this, A.col1);
		y = B2Math.dot(this, A.col2);
		x = _loc2_;
	}

	public function MulM(A:B2Mat22) {
		var _loc2_ = x;
		x = A.col1.x * _loc2_ + A.col2.x * y;
		y = A.col1.y * _loc2_ + A.col2.y * y;
	}

	public function MinV(b:B2Vec2) {
		x = x < b.x ? x : b.x;
		y = y < b.y ? y : b.y;
	}

	public function MaxV(b:B2Vec2) {
		x = x > b.x ? x : b.x;
		y = y > b.y ? y : b.y;
	}

	public function LengthSquared():Float {
		return x * x + y * y;
	}

	public function Length():Float {
		return Math.sqrt(x * x + y * y);
	}

	public function IsValid():Bool {
		if (B2Math.isValid(x)) {
			return B2Math.isValid(y);
		}
		return false;
	}

	public function GetNegative():B2Vec2 {
		return new B2Vec2(-x, -y);
	}

	public function CrossVF(s:Float) {
		var _loc2_ = x;
		x = s * y;
		y = -s * _loc2_;
	}

	public function CrossFV(s:Float) {
		var _loc2_ = x;
		x = -s * y;
		y = s * _loc2_;
	}

	public function Copy():B2Vec2 {
		return new B2Vec2(x, y);
	}

	public function Add(v:B2Vec2) {
		x += v.x;
		y += v.y;
	}

	public function Abs() {
		if (x < 0) {
			x = -x;
		}
		if (y < 0) {
			y = -y;
		}
	}
}
