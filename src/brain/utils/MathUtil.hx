package brain.utils;

import flash.display.DisplayObject;
import flash.geom.Point;

class MathUtil {
	static var spare:Float = Math.NaN;

	static var spareReady:Bool = false;

	public function new() {}

	public static function rand(min:Float, max:Float):Float {
		return min + (max - min) * Math.random();
	}

	public static function rad2deg(rad:Float):Float {
		return rad * 180 / 3.141592653589793;
	}

	public static function deg2rad(deg:Float):Float {
		return deg * 3.141592653589793 / 180;
	}

	public static function degreesBetweenPoints(fromPoint:Point, toPoint:Point):Float {
		return Math.atan2(toPoint.y - fromPoint.y, toPoint.x - fromPoint.x) * 180 / 3.141592653589793;
	}

	public static function degreesToFaceObject(fromObj:DisplayObject, toObj:DisplayObject):Float {
		return Math.atan2(toObj.y - fromObj.y, toObj.x - fromObj.x) * 180 / 3.141592653589793;
	}

	public static function getGaussian(mean:Float, stdDev:Float):Float {
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc3_ = Math.NaN;
		if (spareReady) {
			spareReady = false;
			return spare * stdDev + mean;
		}
		do {
			_loc4_ = Math.random() * 2 - 1;
			_loc5_ = Math.random() * 2 - 1;
			_loc3_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
		} while (_loc3_ >= 1 || _loc3_ == 0);
		spare = _loc5_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
		spareReady = true;
		return mean + stdDev * _loc4_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
	}
}
