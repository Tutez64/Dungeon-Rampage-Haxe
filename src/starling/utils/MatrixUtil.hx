package starling.utils;

import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import starling.errors.AbstractClassError;

class MatrixUtil {
	static var sRawData:Vector<Float> = Vector.ofArray(([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1] : Array<Float>));

	static var sRawData2:Vector<Float> = new Vector((16 : UInt), true);

	static var sPoint3D:Vector3D = new Vector3D();

	static var sMatrixData:Vector<Float> = Vector.ofArray(([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] : Array<Float>));

	public function new() {
		throw new AbstractClassError();
	}

	public static function convertTo3D(matrix:Matrix, out:Matrix3D = null):Matrix3D {
		if (out == null) {
			out = new Matrix3D();
		}
		sRawData[0] = matrix.a;
		sRawData[1] = matrix.b;
		sRawData[4] = matrix.c;
		sRawData[5] = matrix.d;
		sRawData[12] = matrix.tx;
		sRawData[13] = matrix.ty;
		out.copyRawDataFrom(sRawData);
		return out;
	}

	public static function convertTo2D(matrix3D:Matrix3D, out:Matrix = null):Matrix {
		if (out == null) {
			out = new Matrix();
		}
		matrix3D.copyRawDataTo(sRawData2);
		out.a = sRawData2[0];
		out.b = sRawData2[1];
		out.c = sRawData2[4];
		out.d = sRawData2[5];
		out.tx = sRawData2[12];
		out.ty = sRawData2[13];
		return out;
	}

	public static function isIdentity(matrix:Matrix):Bool {
		return matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1 && matrix.tx == 0 && matrix.ty == 0;
	}

	public static function isIdentity3D(matrix:Matrix3D):Bool {
		var _loc2_ = sRawData2;
		matrix.copyRawDataTo(_loc2_);
		return _loc2_[0] == 1 && _loc2_[1] == 0 && _loc2_[2] == 0 && _loc2_[3] == 0 && _loc2_[4] == 0 && _loc2_[5] == 1 && _loc2_[6] == 0 && _loc2_[7] == 0
			&& _loc2_[8] == 0 && _loc2_[9] == 0 && _loc2_[10] == 1 && _loc2_[11] == 0 && _loc2_[12] == 0 && _loc2_[13] == 0 && _loc2_[14] == 0
			&& _loc2_[15] == 1;
	}

	public static function transformPoint(matrix:Matrix, point:Point, out:Point = null):Point {
		return transformCoords(matrix, point.x, point.y, out);
	}

	public static function transformPoint3D(matrix:Matrix3D, point:Vector3D, out:Vector3D = null):Vector3D {
		return transformCoords3D(matrix, point.x, point.y, point.z, out);
	}

	public static function transformCoords(matrix:Matrix, x:Float, y:Float, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		out.x = matrix.a * x + matrix.c * y + matrix.tx;
		out.y = matrix.d * y + matrix.b * x + matrix.ty;
		return out;
	}

	public static function transformCoords3D(matrix:Matrix3D, x:Float, y:Float, z:Float, out:Vector3D = null):Vector3D {
		if (out == null) {
			out = new Vector3D();
		}
		matrix.copyRawDataTo(sRawData2);
		out.x = x * sRawData2[0] + y * sRawData2[4] + z * sRawData2[8] + sRawData2[12];
		out.y = x * sRawData2[1] + y * sRawData2[5] + z * sRawData2[9] + sRawData2[13];
		out.z = x * sRawData2[2] + y * sRawData2[6] + z * sRawData2[10] + sRawData2[14];
		out.w = x * sRawData2[3] + y * sRawData2[7] + z * sRawData2[11] + sRawData2[15];
		return out;
	}

	public static function skew(matrix:Matrix, skewX:Float, skewY:Float) {
		var _loc5_ = Math.sin(skewX);
		var _loc7_ = Math.cos(skewX);
		var _loc4_ = Math.sin(skewY);
		var _loc6_ = Math.cos(skewY);
		matrix.setTo(matrix.a * _loc6_
			- matrix.b * _loc5_, matrix.a * _loc4_
			+ matrix.b * _loc7_, matrix.c * _loc6_
			- matrix.d * _loc5_,
			matrix.c * _loc4_
			+ matrix.d * _loc7_, matrix.tx * _loc6_
			- matrix.ty * _loc5_, matrix.tx * _loc4_
			+ matrix.ty * _loc7_);
	}

	public static function prependMatrix(base:Matrix, prep:Matrix) {
		base.setTo(base.a * prep.a
			+ base.c * prep.b, base.b * prep.a
			+ base.d * prep.b, base.a * prep.c
			+ base.c * prep.d, base.b * prep.c
			+ base.d * prep.d,
			base.tx
			+ base.a * prep.tx
			+ base.c * prep.ty, base.ty
			+ base.b * prep.tx
			+ base.d * prep.ty);
	}

	public static function prependTranslation(matrix:Matrix, tx:Float, ty:Float) {
		matrix.tx += matrix.a * tx + matrix.c * ty;
		matrix.ty += matrix.b * tx + matrix.d * ty;
	}

	public static function prependScale(matrix:Matrix, sx:Float, sy:Float) {
		matrix.setTo(matrix.a * sx, matrix.b * sx, matrix.c * sy, matrix.d * sy, matrix.tx, matrix.ty);
	}

	public static function prependRotation(matrix:Matrix, angle:Float) {
		var _loc4_ = Math.sin(angle);
		var _loc3_ = Math.cos(angle);
		matrix.setTo(matrix.a * _loc3_
			+ matrix.c * _loc4_, matrix.b * _loc3_
			+ matrix.d * _loc4_, matrix.c * _loc3_
			- matrix.a * _loc4_,
			matrix.d * _loc3_
			- matrix.b * _loc4_, matrix.tx, matrix.ty);
	}

	public static function prependSkew(matrix:Matrix, skewX:Float, skewY:Float) {
		var _loc5_ = Math.sin(skewX);
		var _loc7_ = Math.cos(skewX);
		var _loc4_ = Math.sin(skewY);
		var _loc6_ = Math.cos(skewY);
		matrix.setTo(matrix.a * _loc6_
			+ matrix.c * _loc4_, matrix.b * _loc6_
			+ matrix.d * _loc4_, matrix.c * _loc7_
			- matrix.a * _loc5_,
			matrix.d * _loc7_
			- matrix.b * _loc5_, matrix.tx, matrix.ty);
	}

	public static function toString3D(matrix:Matrix3D, transpose:Bool = true, precision:Int = 3):String {
		if (transpose) {
			matrix.transpose();
		}
		matrix.copyRawDataTo(sRawData2);
		if (transpose) {
			matrix.transpose();
		}
		return "[Matrix3D rawData=\n" + formatRawData(sRawData2, 4, 4, precision) + "\n]";
	}

	public static function toString_static /*renamed*/ (matrix:Matrix, precision:Int = 3):String {
		sRawData2[0] = matrix.a;
		sRawData2[1] = matrix.c;
		sRawData2[2] = matrix.tx;
		sRawData2[3] = matrix.b;
		sRawData2[4] = matrix.d;
		sRawData2[5] = matrix.ty;
		return "[Matrix rawData=\n" + formatRawData(sRawData2, 3, 2, precision) + "\n]";
	}

	static function formatRawData(data:Vector<Float>, numCols:Int, numRows:Int, precision:Int, indent:String = "  "):String {
		var _loc10_:String = null;
		var _loc14_ = Math.NaN;
		var _loc6_ = 0;
		var _loc12_ = 0;
		var _loc11_ = 0;
		var _loc9_ = indent;
		var _loc7_ = numCols * numRows;
		var _loc13_:Float = 0;
		_loc6_ = 0;
		while (_loc6_ < _loc7_) {
			_loc14_ = Math.abs(data[_loc6_]);
			if (_loc14_ > _loc13_) {
				_loc13_ = _loc14_;
			}
			_loc6_++;
		}
		var _loc8_ = ASCompat.toFixed(_loc13_, (precision : UInt)).length + 1;
		_loc12_ = 0;
		while (_loc12_ < numRows) {
			_loc11_ = 0;
			while (_loc11_ < numCols) {
				_loc14_ = data[numCols * _loc12_ + _loc11_];
				_loc10_ = ASCompat.toFixed(_loc14_, (precision : UInt));
				while (_loc10_.length < _loc8_) {
					_loc10_ = " " + _loc10_;
				}
				_loc9_ += _loc10_;
				if (_loc11_ != numCols - 1) {
					_loc9_ += ", ";
				}
				_loc11_++;
			}
			if (_loc12_ != numRows - 1) {
				_loc9_ += "\n" + indent;
			}
			_loc12_++;
		}
		return _loc9_;
	}

	public static function snapToPixels(matrix:Matrix, pixelSize:Float) {
		var _loc6_ = Math.NaN;
		_loc6_ = 0.0001;
		var _loc4_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc7_ = false;
		if (matrix.b + 0.0001 > 0 && matrix.b - 0.0001 < 0 && matrix.c + 0.0001 > 0 && matrix.c - 0.0001 < 0) {
			_loc8_ = matrix.a * matrix.a;
			_loc5_ = matrix.d * matrix.d;
			_loc7_ = _loc8_ + 0.0001 > 1 && _loc8_ - 0.0001 < 1 && _loc5_ + 0.0001 > 1 && _loc5_ - 0.0001 < 1;
		} else if (matrix.a + 0.0001 > 0 && matrix.a - 0.0001 < 0 && matrix.d + 0.0001 > 0 && matrix.d - 0.0001 < 0) {
			_loc4_ = matrix.b * matrix.b;
			_loc3_ = matrix.c * matrix.c;
			_loc7_ = _loc4_ + 0.0001 > 1 && _loc4_ - 0.0001 < 1 && _loc3_ + 0.0001 > 1 && _loc3_ - 0.0001 < 1;
		}
		if (_loc7_) {
			matrix.tx = Math.fround(matrix.tx / pixelSize) * pixelSize;
			matrix.ty = Math.fround(matrix.ty / pixelSize) * pixelSize;
		}
	}

	public static function createPerspectiveProjectionMatrix(x:Float, y:Float, width:Float, height:Float, stageWidth:Float = 0, stageHeight:Float = 0,
			cameraPos:Vector3D = null, out:Matrix3D = null):Matrix3D {
		var _loc14_ = Math.NaN;
		_loc14_ = 1;
		if (out == null) {
			out = new Matrix3D();
		}
		if (stageWidth <= 0) {
			stageWidth = width;
		}
		if (stageHeight <= 0) {
			stageHeight = height;
		}
		if (cameraPos == null) {
			cameraPos = sPoint3D;
			cameraPos.setTo(stageWidth / 2, stageHeight / 2, stageWidth / Math.tan(0.5) * 0.5);
		}
		var _loc15_ = Math.abs(cameraPos.z);
		var _loc9_ = cameraPos.x - stageWidth / 2;
		var _loc12_ = cameraPos.y - stageHeight / 2;
		var _loc13_ = _loc15_ * 20;
		var _loc10_ = stageWidth / width;
		var _loc11_ = stageHeight / height;
		sMatrixData[0] = 2 * _loc15_ / stageWidth;
		sMatrixData[5] = -2 * _loc15_ / stageHeight;
		sMatrixData[10] = _loc13_ / (_loc13_ - 1);
		sMatrixData[14] = -_loc13_ * 1 / (_loc13_ - 1);
		sMatrixData[11] = 1;
		sMatrixData[0] *= _loc10_;
		sMatrixData[5] *= _loc11_;
		sMatrixData[8] = _loc10_ - 1 - 2 * _loc10_ * (x - _loc9_) / stageWidth;
		sMatrixData[9] = -_loc11_ + 1 + 2 * _loc11_ * (y - _loc12_) / stageHeight;
		out.copyRawDataFrom(sMatrixData);
		out.prependTranslation(-stageWidth / 2 - _loc9_, -stageHeight / 2 - _loc12_, _loc15_);
		return out;
	}

	public static function createOrthographicProjectionMatrix(x:Float, y:Float, width:Float, height:Float, out:Matrix = null):Matrix {
		if (out == null) {
			out = new Matrix();
		}
		out.setTo(2 / width, 0, 0, -2 / height, -(2 * x + width) / width, (2 * y + height) / height);
		return out;
	}
}
