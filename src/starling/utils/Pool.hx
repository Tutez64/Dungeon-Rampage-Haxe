package starling.utils;

import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.errors.AbstractClassError;

class Pool {
	static var sPoints:Vector<Point> = new Vector((0 : UInt));

	static var sPoints3D:Vector<Vector3D> = new Vector((0 : UInt));

	static var sMatrices:Vector<Matrix> = new Vector((0 : UInt));

	static var sMatrices3D:Vector<Matrix3D> = new Vector((0 : UInt));

	static var sRectangles:Vector<Rectangle> = new Vector((0 : UInt));

	static var sArrays:Vector<Array<ASAny>> = new Vector((0 : UInt));

	public function new() {
		throw new AbstractClassError();
	}

	public static function getPoint(x:Float = 0, y:Float = 0):Point {
		var _loc3_:Point = null;
		if (sPoints.length == 0) {
			return new Point(x, y);
		}
		_loc3_ = sPoints.pop();
		_loc3_.x = x;
		_loc3_.y = y;
		return _loc3_;
	}

	public static function putPoint(point:Point) {
		if (point != null) {
			sPoints[sPoints.length] = point;
		}
	}

	public static function getPoint3D(x:Float = 0, y:Float = 0, z:Float = 0):Vector3D {
		var _loc4_:Vector3D = null;
		if (sPoints3D.length == 0) {
			return new Vector3D(x, y, z);
		}
		_loc4_ = sPoints3D.pop();
		_loc4_.x = x;
		_loc4_.y = y;
		_loc4_.z = z;
		return _loc4_;
	}

	public static function putPoint3D(point:Vector3D) {
		if (point != null) {
			sPoints3D[sPoints3D.length] = point;
		}
	}

	public static function getMatrix(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0):Matrix {
		var _loc7_:Matrix = null;
		if (sMatrices.length == 0) {
			return new Matrix(a, b, c, d, tx, ty);
		}
		_loc7_ = sMatrices.pop();
		_loc7_.setTo(a, b, c, d, tx, ty);
		return _loc7_;
	}

	public static function putMatrix(matrix:Matrix) {
		if (matrix != null) {
			sMatrices[sMatrices.length] = matrix;
		}
	}

	public static function getMatrix3D(identity:Bool = true):Matrix3D {
		var _loc2_:Matrix3D = null;
		if (sMatrices3D.length == 0) {
			return new Matrix3D();
		}
		_loc2_ = sMatrices3D.pop();
		if (identity) {
			_loc2_.identity();
		}
		return _loc2_;
	}

	public static function putMatrix3D(matrix:Matrix3D) {
		if (matrix != null) {
			sMatrices3D[sMatrices3D.length] = matrix;
		}
	}

	public static function getRectangle(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):Rectangle {
		var _loc5_:Rectangle = null;
		if (sRectangles.length == 0) {
			return new Rectangle(x, y, width, height);
		}
		_loc5_ = sRectangles.pop();
		_loc5_.setTo(x, y, width, height);
		return _loc5_;
	}

	public static function putRectangle(rectangle:Rectangle) {
		if (rectangle != null) {
			sRectangles[sRectangles.length] = rectangle;
		}
	}

	public static function getArray():Array<ASAny> {
		if (sArrays.length == 0) {
			return [];
		}
		return sArrays.pop();
	}

	public static function putArray(array:Array<ASAny>) {
		array.resize(0);
		sArrays[sArrays.length] = array;
	}
}
