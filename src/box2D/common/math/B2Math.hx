package box2D.common.math;

class B2Math {
	public static final b2Vec2_zero:B2Vec2 = new B2Vec2(0, 0);

	public static final b2Mat22_identity:B2Mat22 = B2Mat22.FromVV(new B2Vec2(1, 0), new B2Vec2(0, 1));

	public static final b2Transform_identity:B2Transform = new B2Transform(b2Vec2_zero, b2Mat22_identity);

	public function new() {}

	public static function IsValid(x:Float):Bool {
		return Math.isFinite(x);
	}

	public static function Dot(a:B2Vec2, b:B2Vec2):Float {
		return a.x * b.x + a.y * b.y;
	}

	public static function CrossVV(a:B2Vec2, b:B2Vec2):Float {
		return a.x * b.y - a.y * b.x;
	}

	public static function CrossVF(a:B2Vec2, s:Float):B2Vec2 {
		return new B2Vec2(s * a.y, -s * a.x);
	}

	public static function CrossFV(s:Float, a:B2Vec2):B2Vec2 {
		return new B2Vec2(-s * a.y, s * a.x);
	}

	public static function MulMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return new B2Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y);
	}

	public static function MulTMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return new B2Vec2(Dot(v, A.col1), Dot(v, A.col2));
	}

	public static function MulX(T:B2Transform, v:B2Vec2):B2Vec2 {
		var _loc3_:B2Vec2 = null;
		_loc3_ = MulMV(T.R, v);
		_loc3_.x += T.position.x;
		_loc3_.y += T.position.y;
		return _loc3_;
	}

	public static function MulXT(T:B2Transform, v:B2Vec2):B2Vec2 {
		var _loc3_:B2Vec2 = null;
		var _loc4_ = Math.NaN;
		_loc3_ = SubtractVV(v, T.position);
		_loc4_ = _loc3_.x * T.R.col1.x + _loc3_.y * T.R.col1.y;
		_loc3_.y = _loc3_.x * T.R.col2.x + _loc3_.y * T.R.col2.y;
		_loc3_.x = _loc4_;
		return _loc3_;
	}

	public static function AddVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(a.x + b.x, a.y + b.y);
	}

	public static function SubtractVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(a.x - b.x, a.y - b.y);
	}

	public static function Distance(a:B2Vec2, b:B2Vec2):Float {
		var _loc3_ = a.x - b.x;
		var _loc4_ = a.y - b.y;
		return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
	}

	public static function DistanceSquared(a:B2Vec2, b:B2Vec2):Float {
		var _loc3_ = a.x - b.x;
		var _loc4_ = a.y - b.y;
		return _loc3_ * _loc3_ + _loc4_ * _loc4_;
	}

	public static function MulFV(s:Float, a:B2Vec2):B2Vec2 {
		return new B2Vec2(s * a.x, s * a.y);
	}

	public static function AddMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Mat22.FromVV(AddVV(A.col1, B.col1), AddVV(A.col2, B.col2));
	}

	public static function MulMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Mat22.FromVV(MulMV(A, B.col1), MulMV(A, B.col2));
	}

	public static function MulTMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		var _loc3_ = new B2Vec2(Dot(A.col1, B.col1), Dot(A.col2, B.col1));
		var _loc4_ = new B2Vec2(Dot(A.col1, B.col2), Dot(A.col2, B.col2));
		return B2Mat22.FromVV(_loc3_, _loc4_);
	}

	public static function Abs(a:Float):Float {
		return a > 0 ? a : -a;
	}

	public static function AbsV(a:B2Vec2):B2Vec2 {
		return new B2Vec2(Abs(a.x), Abs(a.y));
	}

	public static function AbsM(A:B2Mat22):B2Mat22 {
		return B2Mat22.FromVV(AbsV(A.col1), AbsV(A.col2));
	}

	public static function Min(a:Float, b:Float):Float {
		return a < b ? a : b;
	}

	public static function MinV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(Min(a.x, b.x), Min(a.y, b.y));
	}

	public static function Max(a:Float, b:Float):Float {
		return a > b ? a : b;
	}

	public static function MaxV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(Max(a.x, b.x), Max(a.y, b.y));
	}

	public static function Clamp(a:Float, low:Float, high:Float):Float {
		return a < low ? low : (a > high ? high : a);
	}

	public static function ClampV(a:B2Vec2, low:B2Vec2, high:B2Vec2):B2Vec2 {
		return MaxV(low, MinV(a, high));
	}

	public static function Swap(a:Array<ASAny>, b:Array<ASAny>) {
		var _loc3_:ASAny = a[0];
		a[0] = b[0];
		b[0] = _loc3_;
	}

	public static function Random():Float {
		return Math.random() * 2 - 1;
	}

	public static function RandomRange(lo:Float, hi:Float):Float {
		var _loc3_ = Math.random();
		return (hi - lo) * _loc3_ + lo;
	}

	public static function NextPowerOfTwo(x:UInt):UInt {
		x = ((x | ((x : Int) >> 1 & 0x7FFFFFFF : UInt) : UInt) : UInt);
		x = ((x | ((x : Int) >> 2 & 0x3FFFFFFF : UInt) : UInt) : UInt);
		x = ((x | ((x : Int) >> 4 & 0x0FFFFFFF : UInt) : UInt) : UInt);
		x = ((x | ((x : Int) >> 8 & 0xFFFFFF : UInt) : UInt) : UInt);
		x = ((x | ((x : Int) >> 16 & 0xFFFF : UInt) : UInt) : UInt);
		return x + 1;
	}

	public static function IsPowerOfTwo(x:UInt):Bool {
		return x > 0 && ((x : Int) & (x - 1 : Int)) == 0;
	}
}
