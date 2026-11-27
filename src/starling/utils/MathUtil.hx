package starling.utils;

import flash.geom.Point;
import flash.geom.Vector3D;
import starling.errors.AbstractClassError;

class MathUtil {
	static inline final TWO_PI:Float = 6.283185307179586;

	public function new() {
		throw new AbstractClassError();
	}

	public static function intersectLineWithXYPlane(pointA:Vector3D, pointB:Vector3D, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		var _loc7_ = pointB.x - pointA.x;
		var _loc5_ = pointB.y - pointA.y;
		var _loc6_ = pointB.z - pointA.z;
		var _loc4_ = -pointA.z / _loc6_;
		out.x = pointA.x + _loc4_ * _loc7_;
		out.y = pointA.y + _loc4_ * _loc5_;
		return out;
	}

	public static function isPointInTriangle(p:Point, a:Point, b:Point, c:Point):Bool {
		var _loc15_ = c.x - a.x;
		var _loc13_ = c.y - a.y;
		var _loc8_ = b.x - a.x;
		var _loc16_ = b.y - a.y;
		var _loc12_ = p.x - a.x;
		var _loc9_ = p.y - a.y;
		var _loc10_ = _loc15_ * _loc15_ + _loc13_ * _loc13_;
		var _loc17_ = _loc15_ * _loc8_ + _loc13_ * _loc16_;
		var _loc14_ = _loc15_ * _loc12_ + _loc13_ * _loc9_;
		var _loc11_ = _loc8_ * _loc8_ + _loc16_ * _loc16_;
		var _loc18_ = _loc8_ * _loc12_ + _loc16_ * _loc9_;
		var _loc5_ = 1 / (_loc10_ * _loc11_ - _loc17_ * _loc17_);
		var _loc6_ = (_loc11_ * _loc14_ - _loc17_ * _loc18_) * _loc5_;
		var _loc7_ = (_loc10_ * _loc18_ - _loc17_ * _loc14_) * _loc5_;
		return _loc6_ >= 0 && _loc7_ >= 0 && _loc6_ + _loc7_ < 1;
	}

	public static function normalizeAngle(angle:Float):Float {
		angle %= 6.283185307179586;
		if (angle < -3.141592653589793) {
			angle += 6.283185307179586;
		}
		if (angle > 3.141592653589793) {
			angle -= 6.283185307179586;
		}
		return angle;
	}

	public static function getNextPowerOfTwo(number:Float):Int {
		var _loc2_ = 0;
		if (Std.isOfType(number, Int) && number > 0 && (ASCompat.floatToInt(number) & ASCompat.floatToInt(number - 1)) == 0) {
			return ASCompat.floatToInt(number);
		}
		_loc2_ = 1;
		number -= 1e-9;
		while (_loc2_ < number) {
			_loc2_ = _loc2_ << 1;
		}
		return _loc2_;
	}

	public static function isEquivalent(a:Float, b:Float, epsilon:Float = 0.0001):Bool {
		return a - epsilon < b && a + epsilon > b;
	}

	public static function max(a:Float, b:Float):Float {
		return a > b ? a : b;
	}

	public static function min(a:Float, b:Float):Float {
		return a < b ? a : b;
	}

	public static function clamp(value:Float, min:Float, max:Float):Float {
		return value < min ? min : (value > max ? max : value);
	}
}
