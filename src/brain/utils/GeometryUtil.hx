package brain.utils;

import brain.logger.Logger;
import flash.geom.Point;
import flash.geom.Vector3D;

class GeometryUtil {
	public function new() {}

	public static function Vector3DBetweenPoints(a:Point, b:Point):Vector3D {
		return new Vector3D(b.x - a.x, b.y - a.y);
	}

	public static function truncateVector3D(v:Vector3D, maxLen:Float):Bool {
		var _loc3_ = v.length;
		if (_loc3_ > maxLen) {
			v.scaleBy(maxLen / _loc3_);
			return true;
		}
		return false;
	}

	public static function DoLineSegmentsIntersect(a:Point, b:Point, d:Point, c:Point):Bool {
		var _loc6_ = b.subtract(a);
		var _loc7_ = d.subtract(c);
		var _loc5_ = new Point(-_loc6_.y, _loc6_.x);
		var _loc9_ = a.subtract(c);
		var _loc8_ = dotProduct(_loc9_, _loc5_) / dotProduct(_loc7_, _loc5_);
		if (_loc8_ <= 1 && _loc8_ >= 0) {
			Logger.debug(Std.string(_loc8_));
			return true;
		}
		Logger.debug("A: " + a + " B: " + b + " C: " + c + " D: " + d);
		return false;
	}

	public static function crossProduct(vector1:Point, vector2:Point):Float {
		return vector1.x * vector2.y - vector1.y * vector2.x;
	}

	public static function dotProduct(point1:Point, point2:Point):Float {
		return point1.x * point2.x + point1.y * point2.y;
	}

	public static function dotProduct2D(vector1:Vector3D, vector2:Vector3D):Float {
		return vector1.x * vector2.x + vector1.y * vector2.y;
	}

	public static function do_Lines_Intersect(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float):Bool {
		var _loc17_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		_loc17_ = y2 - y1;
		_loc15_ = x1 - x2;
		_loc14_ = x2 * y1 - x1 * y2;
		_loc10_ = _loc17_ * x3 + _loc15_ * y3 + _loc14_;
		_loc11_ = _loc17_ * x4 + _loc15_ * y4 + _loc14_;
		if (_loc10_ != 0 && _loc11_ != 0 && sameSigns(_loc10_, _loc11_)) {
			return false;
		}
		_loc19_ = y4 - y3;
		_loc18_ = x3 - x4;
		_loc16_ = x4 * y3 - x3 * y4;
		_loc21_ = _loc19_ * x1 + _loc18_ * y1 + _loc16_;
		_loc9_ = _loc19_ * x2 + _loc18_ * y2 + _loc16_;
		if (_loc21_ != 0 && _loc9_ != 0 && sameSigns(_loc21_, _loc9_)) {
			return false;
		}
		_loc20_ = _loc17_ * _loc18_ - _loc19_ * _loc15_;
		if (_loc20_ == 0) {
			return true;
		}
		_loc12_ = _loc20_ < 0 ? -_loc20_ / 2 : _loc20_ / 2;
		return true;
	}

	static function sameSigns(num1:Float, num2:Float):Bool {
		if (num1 <= 0 && num2 <= 0 || num1 >= 0 && num2 >= 0) {
			return true;
		}
		return false;
	}
}
