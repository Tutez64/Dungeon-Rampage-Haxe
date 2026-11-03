package box2D.common.math;

import box2dcompat.As3Array;

class B2Math {
	public static var MIN_VALUE:Float = Math.NaN;

	public static var MAX_VALUE:Float = Math.NaN;

	public static var b2Vec2_zero:B2Vec2 = new B2Vec2(0, 0);

	public static var b2Mat22_identity:B2Mat22 = B2Mat22.fromVV(new B2Vec2(1, 0), new B2Vec2(0, 1));

	public static var b2Transform_identity:B2Transform = new B2Transform(B2Math.b2Vec2_zero, B2Math.b2Mat22_identity);

	public function new() {}

	public static function isValid(x:Float):Bool {
		if (Math.isNaN(x) || x == Math.NEGATIVE_INFINITY || x == Math.POSITIVE_INFINITY) {
			return false;
		}
		return true;
	}

	public static function dot(a:B2Vec2, b:B2Vec2):Float {
		return a.x * b.x + a.y * b.y;
	}

	public static function crossVV(a:B2Vec2, b:B2Vec2):Float {
		return a.x * b.y - a.y * b.x;
	}

	public static function crossVF(a:B2Vec2, s:Float):B2Vec2 {
		return new B2Vec2(s * a.y, -s * a.x);
	}

	public static function crossFV(s:Float, a:B2Vec2):B2Vec2 {
		return new B2Vec2(-s * a.y, s * a.x);
	}

	public static function mulMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return new B2Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y);
	}

	public static function mulTMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return new B2Vec2(B2Math.dot(v, A.col1), B2Math.dot(v, A.col2));
	}

	public static function mulX(T:B2Transform, v:B2Vec2):B2Vec2 {
		var _loc3_ = B2Math.mulMV(T.R, v);
		_loc3_.x += T.position.x;
		_loc3_.y += T.position.y;
		return _loc3_;
	}

	public static function mulXT(T:B2Transform, v:B2Vec2):B2Vec2 {
		var _loc3_ = B2Math.subtractVV(v, T.position);
		var _loc4_ = _loc3_.x * T.R.col1.x + _loc3_.y * T.R.col1.y;
		_loc3_.y = _loc3_.x * T.R.col2.x + _loc3_.y * T.R.col2.y;
		_loc3_.x = _loc4_;
		return _loc3_;
	}

	public static function addVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(a.x + b.x, a.y + b.y);
	}

	public static function subtractVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(a.x - b.x, a.y - b.y);
	}

	public static function distance(a:B2Vec2, b:B2Vec2):Float {
		var _loc3_ = a.x - b.x;
		var _loc4_ = a.y - b.y;
		return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
	}

	public static function distanceSquared(a:B2Vec2, b:B2Vec2):Float {
		var _loc3_ = a.x - b.x;
		var _loc4_ = a.y - b.y;
		return _loc3_ * _loc3_ + _loc4_ * _loc4_;
	}

	public static function mulFV(s:Float, a:B2Vec2):B2Vec2 {
		return new B2Vec2(s * a.x, s * a.y);
	}

	public static function addMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Mat22.fromVV(B2Math.addVV(A.col1, B.col1), B2Math.addVV(A.col2, B.col2));
	}

	public static function mulMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Mat22.fromVV(B2Math.mulMV(A, B.col1), B2Math.mulMV(A, B.col2));
	}

	public static function mulTMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		var _loc3_ = new B2Vec2(B2Math.dot(A.col1, B.col1), B2Math.dot(A.col2, B.col1));
		var _loc4_ = new B2Vec2(B2Math.dot(A.col1, B.col2), B2Math.dot(A.col2, B.col2));
		return B2Mat22.fromVV(_loc3_, _loc4_);
	}

	public static function abs(a:Float):Float {
		if (a > 0) {
			return a;
		}
		return -a;
	}

	public static function absV(a:B2Vec2):B2Vec2 {
		return new B2Vec2(B2Math.abs(a.x), B2Math.abs(a.y));
	}

	public static function absM(A:B2Mat22):B2Mat22 {
		return B2Mat22.fromVV(B2Math.absV(A.col1), B2Math.absV(A.col2));
	}

	public static function min(a:Float, b:Float):Float {
		if (a < b) {
			return a;
		}
		return b;
	}

	public static function minV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(B2Math.min(a.x, b.x), B2Math.min(a.y, b.y));
	}

	public static function max(a:Float, b:Float):Float {
		if (a > b) {
			return a;
		}
		return b;
	}

	public static function maxV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return new B2Vec2(B2Math.max(a.x, b.x), B2Math.max(a.y, b.y));
	}

	public static function clamp(a:Float, low:Float, high:Float):Float {
		if (a < low) {
			return low;
		}
		if (a > high) {
			return high;
		}
		return a;
	}

	public static function clampV(a:B2Vec2, low:B2Vec2, high:B2Vec2):B2Vec2 {
		return B2Math.maxV(low, B2Math.minV(a, high));
	}

	public static function swap(a:Array<ASAny>, b:Array<ASAny>) {
		var _loc3_:ASAny = a[0];
		a[0] = b[0];
		b[0] = _loc3_;
	}

	public static function random():Float {
		return Math.random() * 2 - 1;
	}

	public static function randomRange(lo:Float, hi:Float):Float {
		var _loc3_ = Math.random();
		return (hi - lo) * _loc3_ + lo;
	}

	public static function nextPowerOfTwo(x:Int):Int {
		x = x | (x >> 1 & 0x7FFFFFFF);
		x = x | (x >> 2 & 0x3FFFFFFF);
		x = x | (x >> 4 & 0x0FFFFFFF);
		x = x | (x >> 8 & 0xFFFFFF);
		x = x | (x >> 16 & 0xFFFF);
		return x + 1;
	}

	public static function isPowerOfTwo(x:Int):Bool {
		return x > 0 && (x & x - 1) == 0;
	}

	public static function get_MIN_VALUE():Float {
		return ASCompat.MIN_FLOAT;
	}

	public static function get_MAX_VALUE():Float {
		return ASCompat.MAX_FLOAT;
	}

	public static function IsValid(x:Float):Bool {
		return B2Math.isValid(x);
	}

	public static function Dot(a:B2Vec2, b:B2Vec2):Float {
		return B2Math.dot(a, b);
	}

	public static function CrossVV(a:B2Vec2, b:B2Vec2):Float {
		return B2Math.crossVV(a, b);
	}

	public static function CrossVF(a:B2Vec2, s:Float):B2Vec2 {
		return B2Math.crossVF(a, s);
	}

	public static function CrossFV(s:Float, a:B2Vec2):B2Vec2 {
		return B2Math.crossFV(s, a);
	}

	public static function MulMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return B2Math.mulMV(A, v);
	}

	public static function MulTMV(A:B2Mat22, v:B2Vec2):B2Vec2 {
		return B2Math.mulTMV(A, v);
	}

	public static function MulX(T:B2Transform, v:B2Vec2):B2Vec2 {
		return B2Math.mulX(T, v);
	}

	public static function MulXT(T:B2Transform, v:B2Vec2):B2Vec2 {
		return B2Math.mulXT(T, v);
	}

	public static function AddVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return B2Math.addVV(a, b);
	}

	public static function SubtractVV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return B2Math.subtractVV(a, b);
	}

	public static function Distance(a:B2Vec2, b:B2Vec2):Float {
		return B2Math.distance(a, b);
	}

	public static function DistanceSquared(a:B2Vec2, b:B2Vec2):Float {
		return B2Math.distanceSquared(a, b);
	}

	public static function MulFV(s:Float, a:B2Vec2):B2Vec2 {
		return B2Math.mulFV(s, a);
	}

	public static function AddMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Math.addMM(A, B);
	}

	public static function MulMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Math.mulMM(A, B);
	}

	public static function MulTMM(A:B2Mat22, B:B2Mat22):B2Mat22 {
		return B2Math.mulTMM(A, B);
	}

	public static function Abs(a:Float):Float {
		return B2Math.abs(a);
	}

	public static function AbsV(a:B2Vec2):B2Vec2 {
		return B2Math.absV(a);
	}

	public static function AbsM(A:B2Mat22):B2Mat22 {
		return B2Math.absM(A);
	}

	public static function Min(a:Float, b:Float):Float {
		return B2Math.min(a, b);
	}

	public static function MinV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return B2Math.minV(a, b);
	}

	public static function Max(a:Float, b:Float):Float {
		return B2Math.max(a, b);
	}

	public static function MaxV(a:B2Vec2, b:B2Vec2):B2Vec2 {
		return B2Math.maxV(a, b);
	}

	public static function Clamp(a:Float, low:Float, high:Float):Float {
		return B2Math.clamp(a, low, high);
	}

	public static function ClampV(a:B2Vec2, low:B2Vec2, high:B2Vec2):B2Vec2 {
		return B2Math.clampV(a, low, high);
	}

	public static function Swap(a:ASAny, b:ASAny) {
		B2Math.swap(As3Array.of(a), As3Array.of(b));
	}

	public static function Random():Float {
		return B2Math.random();
	}

	public static function RandomRange(lo:Float, hi:Float):Float {
		return B2Math.randomRange(lo, hi);
	}

	public static function NextPowerOfTwo(x:Int):Int {
		return B2Math.nextPowerOfTwo(x);
	}

	public static function IsPowerOfTwo(x:Int):Bool {
		return B2Math.isPowerOfTwo(x);
	}
}
