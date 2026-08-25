package brain.utils;

import flash.filters.ColorMatrixFilter;

class ColorMatrix {
	static inline final LUMA_R:Float = 0.212671;

	static inline final LUMA_G:Float = 0.71516;

	static inline final LUMA_B:Float = 0.072169;

	static inline final LUMA_R2:Float = 0.3086;

	static inline final LUMA_G2:Float = 0.6094;

	static inline final LUMA_B2:Float = 0.082;

	static inline final ONETHIRD:Float = 0.3333333333333333;

	static inline final RAD:Float = 0.017453292519943295;

	public static final COLOR_DEFICIENCY_TYPES:Array<ASAny> = [
		"Protanopia",
		"Protanomaly",
		"Deuteranopia",
		"Deuteranomaly",
		"Tritanopia",
		"Tritanomaly",
		"Achromatopsia",
		"Achromatomaly"
	];

	static final IDENTITY:Array<ASAny> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

	public var matrix:Array<ASAny>;

	var preHue:ColorMatrix;

	var postHue:ColorMatrix;

	var hueInitialized:Bool = false;

	public function new(mat:ASObject = null) {
		if (Std.isOfType(mat, ColorMatrix)) {
			matrix = ASCompat.dynamicAs(ASCompat.dynConcat(mat.matrix), Array);
		} else if (Std.isOfType(mat, Array)) {
			matrix = ASCompat.dynamicAs(ASCompat.dynConcat(mat), Array);
		} else {
			reset();
		}
	}

	public function reset() {
		matrix = IDENTITY.copy();
	}

	public function clone():ColorMatrix {
		return new ColorMatrix(matrix);
	}

	public function invert() {
		concat([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]);
	}

	public function adjustSaturation(s:Float) {
		var _loc3_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		_loc3_ = 1 - s;
		_loc2_ = _loc3_ * 0.212671;
		_loc4_ = _loc3_ * 0.71516;
		_loc5_ = _loc3_ * 0.072169;
		concat([
			_loc2_ + s,
			_loc4_,
			_loc5_,
			0,
			0,
			_loc2_,
			_loc4_ + s,
			_loc5_,
			0,
			0,
			_loc2_,
			_loc4_,
			_loc5_ + s,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		]);
	}

	public function adjustContrast(r:Float, g:Float = null, b:Float = null) {
		if (g == null)
			g = Math.NaN;
		if (b == null)
			b = Math.NaN;
		if (Math.isNaN(g)) {
			g = r;
		}
		if (Math.isNaN(b)) {
			b = r;
		}
		r += 1;
		g += 1;
		b += 1;
		concat([
			r,
			0,
			0,
			0,
			128 * (1 - r),
			0,
			g,
			0,
			0,
			128 * (1 - g),
			0,
			0,
			b,
			0,
			128 * (1 - b),
			0,
			0,
			0,
			1,
			0
		]);
	}

	public function adjustBrightness(r:Float, g:Float = null, b:Float = null) {
		if (g == null)
			g = Math.NaN;
		if (b == null)
			b = Math.NaN;
		if (Math.isNaN(g)) {
			g = r;
		}
		if (Math.isNaN(b)) {
			b = r;
		}
		concat([1, 0, 0, 0, r, 0, 1, 0, 0, g, 0, 0, 1, 0, b, 0, 0, 0, 1, 0]);
	}

	public function adjustHue(degrees:Float) {
		degrees *= 0.017453292519943295;
		var _loc2_ = Math.cos(degrees);
		var _loc3_ = Math.sin(degrees);
		concat([
			0.212671 + _loc2_ * (1 - 0.212671) + _loc3_ * -0.212671,
			0.71516 + _loc2_ * -0.71516 + _loc3_ * -0.71516,
			0.072169 + _loc2_ * -0.072169 + _loc3_ * (1 - 0.072169),
			0,
			0,
			0.212671 + _loc2_ * -0.212671 + _loc3_ * 0.143,
			0.71516 + _loc2_ * (1 - 0.71516) + _loc3_ * 0.14,
			0.072169 + _loc2_ * -0.072169 + _loc3_ * -0.283,
			0,
			0,
			0.212671 + _loc2_ * -0.212671 + _loc3_ * -0.787329,
			0.71516 + _loc2_ * -0.71516 + _loc3_ * 0.71516,
			0.072169 + _loc2_ * (1 - 0.072169) + _loc3_ * 0.072169,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		]);
	}

	public function rotateHue(degrees:Float) {
		initHue();
		concat(preHue.matrix);
		rotateBlue(degrees);
		concat(postHue.matrix);
	}

	public function luminance2Alpha() {
		concat([
			0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0.212671, 0.71516, 0.072169, 0, 0
		]);
	}

	public function adjustAlphaContrast(amount:Float) {
		amount += 1;
		concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, amount, 128 * (1 - amount)]);
	}

	public function colorize(rgb:Int, amount:Float = 1) {
		var _loc3_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc6_ = Math.NaN;
		_loc3_ = (rgb >> 16 & 0xFF) / 255;
		_loc5_ = (rgb >> 8 & 0xFF) / 255;
		_loc4_ = (rgb & 0xFF) / 255;
		_loc6_ = 1 - amount;
		concat([
			_loc6_ + amount * _loc3_ * 0.212671,
			amount * _loc3_ * 0.71516,
			amount * _loc3_ * 0.072169,
			0,
			0,
			amount * _loc5_ * 0.212671,
			_loc6_ + amount * _loc5_ * 0.71516,
			amount * _loc5_ * 0.072169,
			0,
			0,
			amount * _loc4_ * 0.212671,
			amount * _loc4_ * 0.71516,
			_loc6_ + amount * _loc4_ * 0.072169,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		]);
	}

	public function setChannels(r:Int = 1, g:Int = 2, b:Int = 4, a:Int = 8) {
		var _loc5_:Float = ASCompat.floatAsBool((ASCompat.floatAsBool(((r & 1) == 1 ? 1 : (ASCompat.floatAsBool(0 + ASCompat.toNumber(((r & 2) == 2))) ? 1 : 0))
			+ ASCompat.toNumber(((r & 4) == 4))) ? 1 : 0)
			+ ASCompat.toNumber(((r & 8) == 8))) ? 1 : 0;
		if (_loc5_ > 0) {
			_loc5_ = 1 / _loc5_;
		}
		var _loc8_:Float = ASCompat.floatAsBool((ASCompat.floatAsBool(((g & 1) == 1 ? 1 : (ASCompat.floatAsBool(0 + ASCompat.toNumber(((g & 2) == 2))) ? 1 : 0))
			+ ASCompat.toNumber(((g & 4) == 4))) ? 1 : 0)
			+ ASCompat.toNumber(((g & 8) == 8))) ? 1 : 0;
		if (_loc8_ > 0) {
			_loc8_ = 1 / _loc8_;
		}
		var _loc6_:Float = ASCompat.floatAsBool((ASCompat.floatAsBool(((b & 1) == 1 ? 1 : (ASCompat.floatAsBool(0 + ASCompat.toNumber(((b & 2) == 2))) ? 1 : 0))
			+ ASCompat.toNumber(((b & 4) == 4))) ? 1 : 0)
			+ ASCompat.toNumber(((b & 8) == 8))) ? 1 : 0;
		if (_loc6_ > 0) {
			_loc6_ = 1 / _loc6_;
		}
		var _loc7_:Float = ASCompat.floatAsBool((ASCompat.floatAsBool(((a & 1) == 1 ? 1 : (ASCompat.floatAsBool(0 + ASCompat.toNumber(((a & 2) == 2))) ? 1 : 0))
			+ ASCompat.toNumber(((a & 4) == 4))) ? 1 : 0)
			+ ASCompat.toNumber(((a & 8) == 8))) ? 1 : 0;
		if (_loc7_ > 0) {
			_loc7_ = 1 / _loc7_;
		}
		concat([
			(r & 1) == 1 ? _loc5_ : 0,
			(r & 2) == 2 ? _loc5_ : 0,
			(r & 4) == 4 ? _loc5_ : 0,
			(r & 8) == 8 ? _loc5_ : 0,
			0,
			(g & 1) == 1 ? _loc8_ : 0,
			(g & 2) == 2 ? _loc8_ : 0,
			(g & 4) == 4 ? _loc8_ : 0,
			(g & 8) == 8 ? _loc8_ : 0,
			0,
			(b & 1) == 1 ? _loc6_ : 0,
			(b & 2) == 2 ? _loc6_ : 0,
			(b & 4) == 4 ? _loc6_ : 0,
			(b & 8) == 8 ? _loc6_ : 0,
			0,
			(a & 1) == 1 ? _loc7_ : 0,
			(a & 2) == 2 ? _loc7_ : 0,
			(a & 4) == 4 ? _loc7_ : 0,
			(a & 8) == 8 ? _loc7_ : 0,
			0
		]);
	}

	public function blend(mat:ColorMatrix, amount:Float) {
		var _loc4_ = 1 - amount;
		var _loc3_ = 0;
		while (_loc3_ < 20) {
			matrix[_loc3_] = _loc4_ * ASCompat.toNumber(matrix[_loc3_]) + amount * ASCompat.toNumber(mat.matrix[_loc3_]);
			_loc3_++;
		}
	}

	public function average(r:Float = 0.3333333333333333, g:Float = 0.3333333333333333, b:Float = 0.3333333333333333) {
		concat([r, g, b, 0, 0, r, g, b, 0, 0, r, g, b, 0, 0, 0, 0, 0, 1, 0]);
	}

	public function threshold(threshold:Float, factor:Float = 256) {
		concat([
			0.212671 * factor,
			0.71516 * factor,
			0.072169 * factor,
			0,
			-factor * threshold,
			0.212671 * factor,
			0.71516 * factor,
			0.072169 * factor,
			0,
			-factor * threshold,
			0.212671 * factor,
			0.71516 * factor,
			0.072169 * factor,
			0,
			-factor * threshold,
			0,
			0,
			0,
			1,
			0
		]);
	}

	public function desaturate() {
		concat([
			0.212671, 0.71516, 0.072169, 0, 0, 0.212671, 0.71516, 0.072169, 0, 0, 0.212671, 0.71516, 0.072169, 0, 0, 0, 0, 0, 1, 0
		]);
	}

	public function randomize(amount:Float = 1) {
		var _loc13_ = 1 - amount;
		var _loc14_ = _loc13_ + amount * (Math.random() - Math.random());
		var _loc7_ = amount * (Math.random() - Math.random());
		var _loc10_ = amount * (Math.random() - Math.random());
		var _loc4_ = amount * 255 * (Math.random() - Math.random());
		var _loc2_ = amount * (Math.random() - Math.random());
		var _loc8_ = _loc13_ + amount * (Math.random() - Math.random());
		var _loc11_ = amount * (Math.random() - Math.random());
		var _loc5_ = amount * 255 * (Math.random() - Math.random());
		var _loc3_ = amount * (Math.random() - Math.random());
		var _loc9_ = amount * (Math.random() - Math.random());
		var _loc12_ = _loc13_ + amount * (Math.random() - Math.random());
		var _loc6_ = amount * 255 * (Math.random() - Math.random());
		concat([
			_loc14_, _loc7_, _loc10_, 0, _loc4_, _loc2_, _loc8_, _loc11_, 0, _loc5_, _loc3_, _loc9_, _loc12_, 0, _loc6_, 0, 0, 0, 1, 0
		]);
	}

	public function setMultiplicators(red:Float = 1, green:Float = 1, blue:Float = 1, alpha:Float = 1) {
		var _loc5_:Array<ASAny> = [red, 0, 0, 0, 0, 0, green, 0, 0, 0, 0, 0, blue, 0, 0, 0, 0, 0, alpha, 0];
		concat(_loc5_);
	}

	public function clearChannels(red:Bool = false, green:Bool = false, blue:Bool = false, alpha:Bool = false) {
		if (red) {
			matrix[0] = matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0;
		}
		if (green) {
			matrix[5] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0;
		}
		if (blue) {
			matrix[10] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0;
		}
		if (alpha) {
			matrix[15] = matrix[16] = matrix[17] = matrix[18] = matrix[19] = 0;
		}
	}

	public function thresholdAlpha(threshold:Float, factor:Float = 256) {
		concat([
			1,
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			0,
			0,
			factor,
			-factor * threshold
		]);
	}

	public function averageRGB2Alpha() {
		concat([
			0,
			0,
			0,
			0,
			255,
			0,
			0,
			0,
			0,
			255,
			0,
			0,
			0,
			0,
			255,
			0.3333333333333333,
			0.3333333333333333,
			0.3333333333333333,
			0,
			0
		]);
	}

	public function invertAlpha() {
		concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 255]);
	}

	public function rgb2Alpha(r:Float, g:Float, b:Float) {
		concat([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, r, g, b, 0, 0]);
	}

	public function setAlpha(alpha:Float) {
		concat([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, alpha, 0]);
	}

	@:isVar public var filter(get, never):ColorMatrixFilter;

	public function get_filter():ColorMatrixFilter {
		return new ColorMatrixFilter(cast(matrix));
	}

	public function concat(mat:Array<ASAny>) {
		var _loc5_ = 0;
		var _loc3_ = 0;
		var _loc2_:Array<ASAny> = [];
		var _loc4_ = 0;
		_loc5_ = 0;
		while (_loc5_ < 4) {
			_loc3_ = 0;
			while (_loc3_ < 5) {
				_loc2_[_loc4_ + _loc3_] = ASCompat.toNumber(mat[_loc4_]) * ASCompat.toNumber(matrix[_loc3_])
					+ ASCompat.toNumber(mat[_loc4_ + 1]) * ASCompat.toNumber(matrix[_loc3_ + 5])
					+ ASCompat.toNumber(mat[_loc4_ + 2]) * ASCompat.toNumber(matrix[_loc3_ + 10])
					+ ASCompat.toNumber(mat[_loc4_ + 3]) * ASCompat.toNumber(matrix[_loc3_ + 15])
					+ (_loc3_ == 4 ? ASCompat.toNumber(mat[_loc4_ + 4]) : 0);
				_loc3_++;
			}
			_loc4_ += 5;
			_loc5_++;
		}
		matrix = _loc2_;
	}

	public function rotateRed(degrees:Float) {
		rotateColor(degrees, 2, 1);
	}

	public function rotateGreen(degrees:Float) {
		rotateColor(degrees, 0, 2);
	}

	public function rotateBlue(degrees:Float) {
		rotateColor(degrees, 1, 0);
	}

	function rotateColor(degrees:Float, x:Int, y:Int) {
		degrees *= 0.017453292519943295;
		var _loc4_ = IDENTITY.copy();
		_loc4_[x + x * 5] = _loc4_[y + y * 5] = Math.cos(degrees);
		_loc4_[y + x * 5] = Math.sin(degrees);
		_loc4_[x + y * 5] = -Math.sin(degrees);
		concat(_loc4_);
	}

	public function shearRed(green:Float, blue:Float) {
		shearColor(0, 1, green, 2, blue);
	}

	public function shearGreen(red:Float, blue:Float) {
		shearColor(1, 0, red, 2, blue);
	}

	public function shearBlue(red:Float, green:Float) {
		shearColor(2, 0, red, 1, green);
	}

	function shearColor(x:Int, y1:Int, d1:Float, y2:Int, d2:Float) {
		var _loc6_ = IDENTITY.copy();
		_loc6_[y1 + x * 5] = d1;
		_loc6_[y2 + x * 5] = d2;
		concat(_loc6_);
	}

	public function applyColorDeficiency(type:String) {
		switch (type) {
			case "Protanopia":
				concat([
					0.567, 0.433, 0, 0, 0, 0.558, 0.442, 0, 0, 0, 0, 0.242, 0.758, 0, 0, 0, 0, 0, 1, 0
				]);

			case "Protanomaly":
				concat([
					0.817, 0.183, 0, 0, 0, 0.333, 0.667, 0, 0, 0, 0, 0.125, 0.875, 0, 0, 0, 0, 0, 1, 0
				]);

			case "Deuteranopia":
				concat([0.625, 0.375, 0, 0, 0, 0.7, 0.3, 0, 0, 0, 0, 0.3, 0.7, 0, 0, 0, 0, 0, 1, 0]);

			case "Deuteranomaly":
				concat([0.8, 0.2, 0, 0, 0, 0.258, 0.742, 0, 0, 0, 0, 0.142, 0.858, 0, 0, 0, 0, 0, 1, 0]);

			case "Tritanopia":
				concat([0.95, 0.05, 0, 0, 0, 0, 0.433, 0.567, 0, 0, 0, 0.475, 0.525, 0, 0, 0, 0, 0, 1, 0]);

			case "Tritanomaly":
				concat([
					0.967, 0.033, 0, 0, 0, 0, 0.733, 0.267, 0, 0, 0, 0.183, 0.817, 0, 0, 0, 0, 0, 1, 0
				]);

			case "Achromatopsia":
				concat([
					0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0, 0, 0, 1, 0
				]);

			case "Achromatomaly":
				concat([
					0.618, 0.32, 0.062, 0, 0, 0.163, 0.775, 0.062, 0, 0, 0.163, 0.32, 0.516, 0, 0, 0, 0, 0, 1, 0
				]);
		}
	}

	public function applyMatrix(rgba:UInt):UInt {
		var _loc4_:Float = (rgba : Int) >>> 24 & 0xFF;
		var _loc6_:Float = (rgba : Int) >>> 16 & 0xFF;
		var _loc8_:Float = (rgba : Int) >>> 8 & 0xFF;
		var _loc7_:Float = (rgba : Int) & 0xFF;
		var _loc2_ = ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[0]) + _loc8_ * ASCompat.toNumber(matrix[1])
			+ _loc7_ * ASCompat.toNumber(matrix[2]) + _loc4_ * ASCompat.toNumber(matrix[3]) + matrix[4]);
		var _loc9_ = ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[5]) + _loc8_ * ASCompat.toNumber(matrix[6])
			+ _loc7_ * ASCompat.toNumber(matrix[7]) + _loc4_ * ASCompat.toNumber(matrix[8]) + matrix[9]);
		var _loc3_ = ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[10]) + _loc8_ * ASCompat.toNumber(matrix[11])
			+ _loc7_ * ASCompat.toNumber(matrix[12]) + _loc4_ * ASCompat.toNumber(matrix[13]) + matrix[14]);
		var _loc5_ = ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[15]) + _loc8_ * ASCompat.toNumber(matrix[16])
			+ _loc7_ * ASCompat.toNumber(matrix[17]) + _loc4_ * ASCompat.toNumber(matrix[18]) + matrix[19]);
		if (_loc5_ < 0) {
			_loc5_ = 0;
		}
		if (_loc5_ > 255) {
			_loc5_ = 255;
		}
		if (_loc2_ < 0) {
			_loc2_ = 0;
		}
		if (_loc2_ > 255) {
			_loc2_ = 255;
		}
		if (_loc9_ < 0) {
			_loc9_ = 0;
		}
		if (_loc9_ > 255) {
			_loc9_ = 255;
		}
		if (_loc3_ < 0) {
			_loc3_ = 0;
		}
		if (_loc3_ > 255) {
			_loc3_ = 255;
		}
		return (_loc5_ << 24 | _loc2_ << 16 | _loc9_ << 8 | _loc3_ : UInt);
	}

	public function transformVector(values:Array<ASAny>) {
		if (values.length != 4) {
			return;
		}
		var _loc3_ = ASCompat.toNumber(ASCompat.toNumber(values[0]) * ASCompat.toNumber(matrix[0])
			+ ASCompat.toNumber(values[1]) * ASCompat.toNumber(matrix[1])
			+ ASCompat.toNumber(values[2]) * ASCompat.toNumber(matrix[2])
			+ ASCompat.toNumber(values[3]) * ASCompat.toNumber(matrix[3])
			+ matrix[4]);
		var _loc5_ = ASCompat.toNumber(ASCompat.toNumber(values[0]) * ASCompat.toNumber(matrix[5])
			+ ASCompat.toNumber(values[1]) * ASCompat.toNumber(matrix[6])
			+ ASCompat.toNumber(values[2]) * ASCompat.toNumber(matrix[7])
			+ ASCompat.toNumber(values[3]) * ASCompat.toNumber(matrix[8])
			+ matrix[9]);
		var _loc4_ = ASCompat.toNumber(ASCompat.toNumber(values[0]) * ASCompat.toNumber(matrix[10])
			+ ASCompat.toNumber(values[1]) * ASCompat.toNumber(matrix[11])
			+ ASCompat.toNumber(values[2]) * ASCompat.toNumber(matrix[12])
			+ ASCompat.toNumber(values[3]) * ASCompat.toNumber(matrix[13])
			+ matrix[14]);
		var _loc2_ = ASCompat.toNumber(ASCompat.toNumber(values[0]) * ASCompat.toNumber(matrix[15])
			+ ASCompat.toNumber(values[1]) * ASCompat.toNumber(matrix[16])
			+ ASCompat.toNumber(values[2]) * ASCompat.toNumber(matrix[17])
			+ ASCompat.toNumber(values[3]) * ASCompat.toNumber(matrix[18])
			+ matrix[19]);
		values[0] = _loc3_;
		values[1] = _loc5_;
		values[2] = _loc4_;
		values[3] = _loc2_;
	}

	function initHue() {
		var _loc4_:Array<ASAny> = null;
		var _loc1_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc2_:Float = 39.182655;
		if (!hueInitialized) {
			hueInitialized = true;
			preHue = new ColorMatrix();
			preHue.rotateRed(45);
			preHue.rotateGreen(-_loc2_);
			_loc4_ = [0.3086, 0.6094, 0.082, 1];
			preHue.transformVector(_loc4_);
			_loc1_ = ASCompat.toNumber(_loc4_[0]) / ASCompat.toNumber(_loc4_[2]);
			_loc3_ = ASCompat.toNumber(_loc4_[1]) / ASCompat.toNumber(_loc4_[2]);
			preHue.shearBlue(_loc1_, _loc3_);
			postHue = new ColorMatrix();
			postHue.shearBlue(-_loc1_, -_loc3_);
			postHue.rotateGreen(_loc2_);
			postHue.rotateRed(-45);
		}
	}
}
