package starling.filters;

import starling.rendering.FilterEffect;
import starling.utils.Color;
import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import flash.errors.ArgumentError;

class ColorMatrixFilter extends FragmentFilter {
	static inline final LUMA_R:Float = 0.299;

	static inline final LUMA_G:Float = 0.587;

	static inline final LUMA_B:Float = 0.114;

	static var sMatrix:Vector<Float> = new Vector((0 : UInt));

	public function new(matrix:Vector<Float> = null) {
		super();
		if (matrix != null) {
			colorEffect.matrix = matrix;
		}
	}

	override function createEffect():FilterEffect {
		return new ColorMatrixEffect();
	}

	public function invert() {
		concatValues(-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0);
	}

	public function adjustSaturation(sat:Float) {
		sat += 1;
		var _loc3_ = 1 - sat;
		var _loc4_ = _loc3_ * 0.299;
		var _loc2_ = _loc3_ * 0.587;
		var _loc5_ = _loc3_ * 0.114;
		concatValues(_loc4_ + sat, _loc2_, _loc5_, 0, 0, _loc4_, _loc2_ + sat, _loc5_, 0, 0, _loc4_, _loc2_, _loc5_ + sat, 0, 0, 0, 0, 0, 1, 0);
	}

	public function adjustContrast(value:Float) {
		var _loc2_ = value + 1;
		var _loc3_ = 128 * (1 - _loc2_);
		concatValues(_loc2_, 0, 0, 0, _loc3_, 0, _loc2_, 0, 0, _loc3_, 0, 0, _loc2_, 0, _loc3_, 0, 0, 0, 1, 0);
	}

	public function adjustBrightness(value:Float) {
		value *= 255;
		concatValues(1, 0, 0, 0, value, 0, 1, 0, 0, value, 0, 0, 1, 0, value, 0, 0, 0, 1, 0);
	}

	public function adjustHue(value:Float) {
		value *= 3.141592653589793;
		var _loc2_ = Math.cos(value);
		var _loc3_ = Math.sin(value);
		concatValues(0.299
			+ _loc2_ * (1 - 0.299)
			+ _loc3_ * -0.299, 0.587
			+ _loc2_ * -0.587
			+ _loc3_ * -0.587,
			0.114
			+ _loc2_ * -0.114
			+ _loc3_ * (1 - 0.114), 0, 0, 0.299
			+ _loc2_ * -0.299
			+ _loc3_ * 0.143, 0.587
			+ _loc2_ * (1 - 0.587)
			+ _loc3_ * 0.14,
			0.114
			+ _loc2_ * -0.114
			+ _loc3_ * -0.283, 0, 0, 0.299
			+ _loc2_ * -0.299
			+ _loc3_ * -0.7010000000000001, 0.587
			+ _loc2_ * -0.587
			+ _loc3_ * 0.587,
			0.114
			+ _loc2_ * (1 - 0.114)
			+ _loc3_ * 0.114, 0, 0, 0, 0, 0, 1, 0);
	}

	public function tint(color:UInt, amount:Float = 1) {
		var _loc4_ = Color.getRed(color) / 255;
		var _loc6_ = Color.getGreen(color) / 255;
		var _loc5_ = Color.getBlue(color) / 255;
		var _loc3_ = 1 - amount;
		var _loc8_ = amount * _loc4_;
		var _loc7_ = amount * _loc6_;
		var _loc9_ = amount * _loc5_;
		concatValues(_loc3_
			+ _loc8_ * 0.299, _loc8_ * 0.587, _loc8_ * 0.114, 0, 0, _loc7_ * 0.299, _loc3_
			+ _loc7_ * 0.587, _loc7_ * 0.114, 0, 0,
			_loc9_ * 0.299, _loc9_ * 0.587, _loc3_
			+ _loc9_ * 0.114, 0, 0, 0, 0, 0, 1, 0);
	}

	public function reset() {
		matrix = null;
	}

	public function concat(matrix:Vector<Float>) {
		colorEffect.concat(matrix);
		setRequiresRedraw();
	}

	public function concatValues(m0:Float, m1:Float, m2:Float, m3:Float, m4:Float, m5:Float, m6:Float, m7:Float, m8:Float, m9:Float, m10:Float, m11:Float,
			m12:Float, m13:Float, m14:Float, m15:Float, m16:Float, m17:Float, m18:Float, m19:Float) {
		sMatrix.length = 0;
		ASCompat.ASArray.pushMultiple(sMatrix, m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19);
		concat(sMatrix);
	}

	@:isVar public var matrix(get, set):Vector<Float>;

	public function get_matrix():Vector<Float> {
		return colorEffect.matrix;
	}

	function set_matrix(value:Vector<Float>):Vector<Float> {
		colorEffect.matrix = value;
		setRequiresRedraw();
		return value;
	}

	@:isVar var colorEffect(get, never):ColorMatrixEffect;

	function get_colorEffect():ColorMatrixEffect {
		return ASCompat.reinterpretAs(this.effect, ColorMatrixEffect);
	}
}

private class ColorMatrixEffect extends FilterEffect {
	static final MIN_COLOR:Vector<Float> = Vector.ofArray(([0, 0, 0, 0.0001] : Array<Float>));

	static var IDENTITY:Array<ASAny>;

	static var sMatrix:Vector<Float> = new Vector((20 : UInt), true);

	var _userMatrix:Vector<Float>;

	var _shaderMatrix:Vector<Float>;

	public function new() {
		super();
		_userMatrix = new Vector<Float>((0 : UInt));
		_shaderMatrix = new Vector<Float>((0 : UInt));
		this.matrix = null;
	}

	override function createProgram():Program {
		var _loc1_ = "m44 op, va0, vc0 \nmov v0, va1";
		var _loc2_ = [
			FilterEffect.tex("ft0", "v0", 0, texture),
			"max ft0, ft0, fc5              ",
			"div ft0.xyz, ft0.xyz, ft0.www  ",
			"m44 ft0, ft0, fc0              ",
			"add ft0, ft0, fc4              ",
			"mul ft0.xyz, ft0.xyz, ft0.www  ",
			"mov oc, ft0                    "
		].join("\n");
		return Program.fromSource(_loc1_, _loc2_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		context.setProgramConstantsFromVector("fragment", 0, _shaderMatrix);
		context.setProgramConstantsFromVector("fragment", 5, MIN_COLOR);
	}

	public function reset() {
		matrix = null;
	}

	public function concat(matrix:Vector<Float>) {
		var _loc4_ = 0;
		var _loc2_ = 0;
		var _loc3_ = 0;
		_loc4_ = 0;
		while (_loc4_ < 4) {
			_loc2_ = 0;
			while (_loc2_ < 5) {
				sMatrix[_loc3_ + _loc2_] = matrix[_loc3_] * _userMatrix[_loc2_]
					+ matrix[_loc3_ + 1] * _userMatrix[_loc2_ + 5] + matrix[_loc3_ + 2] * _userMatrix[_loc2_ + 10] + matrix[_loc3_ + 3] * _userMatrix[_loc2_
						+ 15] + (_loc2_ == 4 ? matrix[_loc3_ + 4] : 0);
				_loc2_++;
			}
			_loc3_ += 5;
			_loc4_++;
		}
		copyMatrix(sMatrix, _userMatrix);
		updateShaderMatrix();
	}

	function copyMatrix(from:Vector<Float>, to:Vector<Float>) {
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < 20) {
			to[_loc3_] = from[_loc3_];
			_loc3_++;
		}
	}

	function updateShaderMatrix() {
		_shaderMatrix.length = 0;
		ASCompat.ASArray.pushMultiple(_shaderMatrix, _userMatrix[0], _userMatrix[1], _userMatrix[2], _userMatrix[3], _userMatrix[5], _userMatrix[6],
			_userMatrix[7], _userMatrix[8], _userMatrix[10], _userMatrix[11], _userMatrix[12], _userMatrix[13], _userMatrix[15], _userMatrix[16],
			_userMatrix[17], _userMatrix[18], _userMatrix[4] / 255, _userMatrix[9] / 255, _userMatrix[14] / 255, _userMatrix[19] / 255);
	}

	@:isVar public var matrix(get, set):Vector<Float>;

	public function get_matrix():Vector<Float> {
		return _userMatrix;
	}

	function set_matrix(value:Vector<Float>):Vector<Float> {
		if (value != null && value.length != 20) {
			throw new ArgumentError("Invalid matrix length: must be 20");
		}
		if (value == null) {
			_userMatrix.length = 0;
			ASCompat.ASVector.pushAll(_userMatrix, IDENTITY);
		} else {
			copyMatrix(value, _userMatrix);
		}
		updateShaderMatrix();
		return value;
	}

	static function __init__() {
		IDENTITY = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
	}
}
