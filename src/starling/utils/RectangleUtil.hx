package starling.utils;

import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.errors.AbstractClassError;
import flash.errors.ArgumentError;

class RectangleUtil {
	static final sPoint:Point = new Point();

	static final sPoint3D:Vector3D = new Vector3D();

	static final sPositions:Vector<Point> = Vector.ofArray([new Point(), new Point(), new Point(), new Point()]);

	public function new() {
		throw new AbstractClassError();
	}

	public static function intersect(rect1:Rectangle, rect2:Rectangle, out:Rectangle = null):Rectangle {
		if (out == null) {
			out = new Rectangle();
		}
		var _loc5_ = rect1.x > rect2.x ? rect1.x : rect2.x;
		var _loc7_ = rect1.right < rect2.right ? rect1.right : rect2.right;
		var _loc4_ = rect1.y > rect2.y ? rect1.y : rect2.y;
		var _loc6_ = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;
		if (_loc5_ > _loc7_ || _loc4_ > _loc6_) {
			out.setEmpty();
		} else {
			out.setTo(_loc5_, _loc4_, _loc7_ - _loc5_, _loc6_ - _loc4_);
		}
		return out;
	}

	public static function fit(rectangle:Rectangle, into:Rectangle, scaleMode:String = "showAll", pixelPerfect:Bool = false, out:Rectangle = null):Rectangle {
		if (!ScaleMode.isValid(scaleMode)) {
			throw new ArgumentError("Invalid scaleMode: " + scaleMode);
		}
		if (out == null) {
			out = new Rectangle();
		}
		var _loc8_ = rectangle.width;
		var _loc10_ = rectangle.height;
		var _loc7_ = into.width / _loc8_;
		var _loc6_ = into.height / _loc10_;
		var _loc9_:Float = 1;
		if (scaleMode == "showAll") {
			_loc9_ = _loc7_ < _loc6_ ? _loc7_ : _loc6_;
			if (pixelPerfect) {
				_loc9_ = nextSuitableScaleFactor(_loc9_, false);
			}
		} else if (scaleMode == "noBorder") {
			_loc9_ = _loc7_ > _loc6_ ? _loc7_ : _loc6_;
			if (pixelPerfect) {
				_loc9_ = nextSuitableScaleFactor(_loc9_, true);
			}
		}
		_loc8_ *= _loc9_;
		_loc10_ *= _loc9_;
		out.setTo(into.x + (into.width - _loc8_) / 2, into.y + (into.height - _loc10_) / 2, _loc8_, _loc10_);
		return out;
	}

	static function nextSuitableScaleFactor(factor:Float, up:Bool):Float {
		var _loc3_:Float = 1;
		if (up) {
			if (factor >= 0.5) {
				return Math.fceil(factor);
			}
			while (1 / (_loc3_ + 1) > factor) {
				_loc3_++;
			}
		} else {
			if (factor >= 1) {
				return Math.ffloor(factor);
			}
			while (1 / _loc3_ > factor) {
				_loc3_++;
			}
		}
		return 1 / _loc3_;
	}

	public static function normalize(rect:Rectangle) {
		if (rect.width < 0) {
			rect.width = -rect.width;
			rect.x -= rect.width;
		}
		if (rect.height < 0) {
			rect.height = -rect.height;
			rect.y -= rect.height;
		}
	}

	public static function extend(rect:Rectangle, left:Float = 0, right:Float = 0, top:Float = 0, bottom:Float = 0) {
		rect.x -= left;
		rect.y -= top;
		rect.width += left + right;
		rect.height += top + bottom;
	}

	public static function extendToWholePixels(rect:Rectangle, scaleFactor:Float = 1) {
		var _loc4_ = Math.ffloor(rect.x * scaleFactor) / scaleFactor;
		var _loc3_ = Math.ffloor(rect.y * scaleFactor) / scaleFactor;
		var _loc6_ = Math.fceil(rect.right * scaleFactor) / scaleFactor;
		var _loc5_ = Math.fceil(rect.bottom * scaleFactor) / scaleFactor;
		rect.setTo(_loc4_, _loc3_, _loc6_ - _loc4_, _loc5_ - _loc3_);
	}

	public static function getBounds(rectangle:Rectangle, matrix:Matrix, out:Rectangle = null):Rectangle {
		var _loc8_ = 0;
		if (out == null) {
			out = new Rectangle();
		}
		var _loc5_:Float = 1.7976931348623157e+308;
		var _loc7_:Float = -1.7976931348623157e+308;
		var _loc4_:Float = 1.7976931348623157e+308;
		var _loc6_:Float = -1.7976931348623157e+308;
		var _loc9_ = getPositions(rectangle, sPositions);
		_loc8_ = 0;
		while (_loc8_ < 4) {
			MatrixUtil.transformCoords(matrix, _loc9_[_loc8_].x, _loc9_[_loc8_].y, sPoint);
			if (_loc5_ > sPoint.x) {
				_loc5_ = sPoint.x;
			}
			if (_loc7_ < sPoint.x) {
				_loc7_ = sPoint.x;
			}
			if (_loc4_ > sPoint.y) {
				_loc4_ = sPoint.y;
			}
			if (_loc6_ < sPoint.y) {
				_loc6_ = sPoint.y;
			}
			_loc8_++;
		}
		out.setTo(_loc5_, _loc4_, _loc7_ - _loc5_, _loc6_ - _loc4_);
		return out;
	}

	public static function getBoundsProjected(rectangle:Rectangle, matrix:Matrix3D, camPos:Vector3D, out:Rectangle = null):Rectangle {
		var _loc9_ = 0;
		var _loc11_:Point = null;
		if (out == null) {
			out = new Rectangle();
		}
		if (camPos == null) {
			throw new ArgumentError("camPos must not be null");
		}
		var _loc6_:Float = 1.7976931348623157e+308;
		var _loc8_:Float = -1.7976931348623157e+308;
		var _loc5_:Float = 1.7976931348623157e+308;
		var _loc7_:Float = -1.7976931348623157e+308;
		var _loc10_ = getPositions(rectangle, sPositions);
		_loc9_ = 0;
		while (_loc9_ < 4) {
			_loc11_ = _loc10_[_loc9_];
			if (matrix != null) {
				MatrixUtil.transformCoords3D(matrix, _loc11_.x, _loc11_.y, 0, sPoint3D);
			} else {
				sPoint3D.setTo(_loc11_.x, _loc11_.y, 0);
			}
			MathUtil.intersectLineWithXYPlane(camPos, sPoint3D, sPoint);
			if (_loc6_ > sPoint.x) {
				_loc6_ = sPoint.x;
			}
			if (_loc8_ < sPoint.x) {
				_loc8_ = sPoint.x;
			}
			if (_loc5_ > sPoint.y) {
				_loc5_ = sPoint.y;
			}
			if (_loc7_ < sPoint.y) {
				_loc7_ = sPoint.y;
			}
			_loc9_++;
		}
		out.setTo(_loc6_, _loc5_, _loc8_ - _loc6_, _loc7_ - _loc5_);
		return out;
	}

	public static function getPositions(rectangle:Rectangle, out:Vector<Point> = null):Vector<Point> {
		var _loc3_ = 0;
		if (out == null) {
			out = new Vector<Point>((4 : UInt), true);
		}
		_loc3_ = 0;
		while (_loc3_ < 4) {
			if (out[_loc3_] == null) {
				out[_loc3_] = new Point();
			}
			_loc3_++;
		}
		out[0].x = rectangle.left;
		out[0].y = rectangle.top;
		out[1].x = rectangle.right;
		out[1].y = rectangle.top;
		out[2].x = rectangle.left;
		out[2].y = rectangle.bottom;
		out[3].x = rectangle.right;
		out[3].y = rectangle.bottom;
		return out;
	}

	public static function compare(r1:Rectangle, r2:Rectangle, e:Float = 0.0001):Bool {
		if (r1 == null) {
			return r2 == null;
		}
		if (r2 == null) {
			return false;
		}
		return r1.x > r2.x - e && r1.x < r2.x + e && r1.y > r2.y - e && r1.y < r2.y + e && r1.width > r2.width - e && r1.width < r2.width + e
			&& r1.height > r2.height - e && r1.height < r2.height + e;
	}
}
