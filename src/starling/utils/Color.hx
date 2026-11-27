package starling.utils;

import starling.errors.AbstractClassError;

class Color {
	public static inline final WHITE = (16777215 : UInt);

	public static inline final SILVER = (12632256 : UInt);

	public static inline final GRAY = (8421504 : UInt);

	public static inline final BLACK = (0 : UInt);

	public static inline final RED = (16711680 : UInt);

	public static inline final MAROON = (8388608 : UInt);

	public static inline final YELLOW = (16776960 : UInt);

	public static inline final OLIVE = (8421376 : UInt);

	public static inline final LIME = (65280 : UInt);

	public static inline final GREEN = (32768 : UInt);

	public static inline final AQUA = (65535 : UInt);

	public static inline final TEAL = (32896 : UInt);

	public static inline final BLUE = (255 : UInt);

	public static inline final NAVY = (128 : UInt);

	public static inline final FUCHSIA = (16711935 : UInt);

	public static inline final PURPLE = (8388736 : UInt);

	public function new() {
		throw new AbstractClassError();
	}

	public static function getAlpha(color:UInt):Int {
		return (color : Int) >> 24 & 0xFF;
	}

	public static function getRed(color:UInt):Int {
		return (color : Int) >> 16 & 0xFF;
	}

	public static function getGreen(color:UInt):Int {
		return (color : Int) >> 8 & 0xFF;
	}

	public static function getBlue(color:UInt):Int {
		return (color : Int) & 0xFF;
	}

	public static function setAlpha(color:UInt, alpha:Int):UInt {
		return ((color : Int) & 0xFFFFFF | (alpha & 0xFF) << 24 : UInt);
	}

	public static function setRed(color:UInt, red:Int):UInt {
		return ((color : Int) & ASCompat.floatToInt(0xFF00FFFF) | (red & 0xFF) << 16 : UInt);
	}

	public static function setGreen(color:UInt, green:Int):UInt {
		return ((color : Int) & ASCompat.floatToInt(0xFFFF00FF) | (green & 0xFF) << 8 : UInt);
	}

	public static function setBlue(color:UInt, blue:Int):UInt {
		return ((color : Int) & ASCompat.floatToInt(0xFFFFFF00) | (blue & 0xFF) : UInt);
	}

	public static function rgb(red:Int, green:Int, blue:Int):UInt {
		return (red << 16 | green << 8 | blue : UInt);
	}

	public static function argb(alpha:Int, red:Int, green:Int, blue:Int):UInt {
		return (alpha << 24 | red << 16 | green << 8 | blue : UInt);
	}

	public static function hsv(hue:Float, saturation:Float, value:Float):UInt {
		var _loc10_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc11_ = Math.ffloor(hue * 6);
		var _loc9_ = hue * 6 - _loc11_;
		var _loc4_ = value * (1 - saturation);
		var _loc5_ = value * (1 - _loc9_ * saturation);
		var _loc8_ = value * (1 - (1 - _loc9_) * saturation);
		switch (ASCompat.floatToInt(_loc11_ % 6)) {
			case 0:
				_loc7_ = value;
				_loc10_ = _loc8_;
				_loc6_ = _loc4_;

			case 1:
				_loc7_ = _loc5_;
				_loc10_ = value;
				_loc6_ = _loc4_;

			case 2:
				_loc7_ = _loc4_;
				_loc10_ = value;
				_loc6_ = _loc8_;

			case 3:
				_loc7_ = _loc4_;
				_loc10_ = _loc5_;
				_loc6_ = value;

			case 4:
				_loc7_ = _loc8_;
				_loc10_ = _loc4_;
				_loc6_ = value;

			case 5:
				_loc7_ = value;
				_loc10_ = _loc4_;
				_loc6_ = _loc5_;
		}
		return rgb(Math.ceil(_loc7_ * 255), Math.ceil(_loc10_ * 255), Math.ceil(_loc6_ * 255));
	}

	public static function hsl(hue:Float, saturation:Float, lightness:Float):UInt {
		var _loc7_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc6_ = (1 - Math.abs(2 * lightness - 1)) * saturation;
		var _loc9_ = hue * 6;
		var _loc8_ = _loc6_ * (1 - Math.abs(_loc9_ % 2 - 1));
		var _loc10_ = lightness - _loc6_ / 2;
		switch (ASCompat.floatToInt(_loc9_ % 6)) {
			case 0:
				_loc5_ = _loc6_ + _loc10_;
				_loc7_ = _loc8_ + _loc10_;
				_loc4_ = _loc10_;

			case 1:
				_loc5_ = _loc8_ + _loc10_;
				_loc7_ = _loc6_ + _loc10_;
				_loc4_ = _loc10_;

			case 2:
				_loc5_ = _loc10_;
				_loc7_ = _loc6_ + _loc10_;
				_loc4_ = _loc8_ + _loc10_;

			case 3:
				_loc5_ = _loc10_;
				_loc7_ = _loc8_ + _loc10_;
				_loc4_ = _loc6_ + _loc10_;

			case 4:
				_loc5_ = _loc8_ + _loc10_;
				_loc7_ = _loc10_;
				_loc4_ = _loc6_ + _loc10_;

			case 5:
				_loc5_ = _loc6_ + _loc10_;
				_loc7_ = _loc10_;
				_loc4_ = _loc8_ + _loc10_;
		}
		return rgb(Math.ceil(_loc5_ * 255), Math.ceil(_loc7_ * 255), Math.ceil(_loc4_ * 255));
	}

	public static function rgbToHsv(rgb:UInt, hsv:Vector<Float> = null):Vector<Float> {
		var _loc9_:Float;
		var _loc10_:Float;
		if (hsv == null) {
			hsv = new Vector<Float>((3 : UInt), true);
		}
		var _loc4_ = Color.getRed(rgb) / 255;
		var _loc6_ = Color.getGreen(rgb) / 255;
		var _loc5_ = Color.getBlue(rgb) / 255;
		var _loc8_ = Math.max(_loc4_, Math.max(_loc6_, _loc5_));
		var _loc3_ = Math.min(_loc4_, Math.min(_loc6_, _loc5_));
		var _loc7_ = _loc8_ - _loc3_;
		if (_loc7_ == 0) {
			hsv[0] = 0;
		} else if (_loc8_ == _loc4_) {
			hsv[0] = (_loc6_ - _loc5_) / _loc7_ % 6 / 6;
		} else if (_loc8_ == _loc6_) {
			hsv[0] = ((_loc5_ - _loc4_) / _loc7_ + 2) / 6;
		} else if (_loc8_ == _loc5_) {
			hsv[0] = ((_loc4_ - _loc6_) / _loc7_ + 4) / 6;
		}
		while (hsv[0] < 0) {
			_loc9_ = 0;
			_loc10_ = hsv[ASCompat.floatToInt(_loc9_)] + 1;
			hsv[ASCompat.floatToInt(_loc9_)] = _loc10_;
		}
		while (hsv[0] >= 1) {
			_loc10_ = 0;
			_loc9_ = hsv[ASCompat.floatToInt(_loc10_)] - 1;
			hsv[ASCompat.floatToInt(_loc10_)] = _loc9_;
		}
		hsv[2] = _loc8_;
		hsv[1] = _loc8_ == 0 ? 0 : _loc7_ / _loc8_;
		return hsv;
	}

	public static function rgbToHsl(rgb:UInt, hsl:Vector<Float> = null):Vector<Float> {
		var _loc9_:Float;
		var _loc10_:Float;
		if (hsl == null) {
			hsl = new Vector<Float>((3 : UInt), true);
		}
		var _loc4_ = Color.getRed(rgb) / 255;
		var _loc6_ = Color.getGreen(rgb) / 255;
		var _loc5_ = Color.getBlue(rgb) / 255;
		var _loc8_ = Math.max(_loc4_, Math.max(_loc6_, _loc5_));
		var _loc3_ = Math.min(_loc4_, Math.min(_loc6_, _loc5_));
		var _loc7_ = _loc8_ - _loc3_;
		if (_loc7_ == 0) {
			hsl[0] = 0;
		} else if (_loc8_ == _loc4_) {
			hsl[0] = (_loc6_ - _loc5_) / _loc7_ % 6 / 6;
		} else if (_loc8_ == _loc6_) {
			hsl[0] = ((_loc5_ - _loc4_) / _loc7_ + 2) / 6;
		} else if (_loc8_ == _loc5_) {
			hsl[0] = ((_loc4_ - _loc6_) / _loc7_ + 4) / 6;
		}
		while (hsl[0] < 0) {
			_loc9_ = 0;
			_loc10_ = hsl[ASCompat.floatToInt(_loc9_)] + 1;
			hsl[ASCompat.floatToInt(_loc9_)] = _loc10_;
		}
		while (hsl[0] >= 1) {
			_loc10_ = 0;
			_loc9_ = hsl[ASCompat.floatToInt(_loc10_)] - 1;
			hsl[ASCompat.floatToInt(_loc10_)] = _loc9_;
		}
		hsl[2] = (_loc8_ + _loc3_) * 0.5;
		hsl[1] = _loc7_ == 0 ? 0 : _loc7_ / (1 - Math.abs(2 * hsl[2] - 1));
		return hsl;
	}

	public static function toVector(color:UInt, out:Vector<Float> = null):Vector<Float> {
		if (out == null) {
			out = new Vector<Float>((4 : UInt), true);
		}
		out[0] = ((color : Int) >> 16 & 0xFF) / 255;
		out[1] = ((color : Int) >> 8 & 0xFF) / 255;
		out[2] = ((color : Int) & 0xFF) / 255;
		out[3] = ((color : Int) >> 24 & 0xFF) / 255;
		return out;
	}

	public static function multiply(color:UInt, factor:Float):UInt {
		if (factor == 0) {
			return (0 : UInt);
		}
		var _loc6_ = (ASCompat.floatToInt(((color : Int) >> 24 & 0xFF) * factor) : UInt);
		var _loc3_ = (ASCompat.floatToInt(((color : Int) >> 16 & 0xFF) * factor) : UInt);
		var _loc4_ = (ASCompat.floatToInt(((color : Int) >> 8 & 0xFF) * factor) : UInt);
		var _loc5_ = (ASCompat.floatToInt(((color : Int) & 0xFF) * factor) : UInt);
		if (_loc6_ > 255) {
			_loc6_ = (255 : UInt);
		}
		if (_loc3_ > 255) {
			_loc3_ = (255 : UInt);
		}
		if (_loc4_ > 255) {
			_loc4_ = (255 : UInt);
		}
		if (_loc5_ > 255) {
			_loc5_ = (255 : UInt);
		}
		return argb((_loc6_ : Int), (_loc3_ : Int), (_loc4_ : Int), (_loc5_ : Int));
	}

	public static function interpolate(startColor:UInt, endColor:UInt, ratio:Float):UInt {
		var _loc11_ = ((startColor : Int) >> 24 & 0xFF : UInt);
		var _loc15_ = ((startColor : Int) >> 16 & 0xFF : UInt);
		var _loc6_ = ((startColor : Int) >> 8 & 0xFF : UInt);
		var _loc9_ = ((startColor : Int) & 0xFF : UInt);
		var _loc8_ = ((endColor : Int) >> 24 & 0xFF : UInt);
		var _loc14_ = ((endColor : Int) >> 16 & 0xFF : UInt);
		var _loc5_ = ((endColor : Int) >> 8 & 0xFF : UInt);
		var _loc7_ = ((endColor : Int) & 0xFF : UInt);
		var _loc12_ = (ASCompat.floatToInt(_loc11_ + ((_loc8_ : Float) - (_loc11_ : Float)) * ratio) : UInt);
		var _loc4_ = (ASCompat.floatToInt(_loc15_ + ((_loc14_ : Float) - (_loc15_ : Float)) * ratio) : UInt);
		var _loc13_ = (ASCompat.floatToInt(_loc6_ + ((_loc5_ : Float) - (_loc6_ : Float)) * ratio) : UInt);
		var _loc10_ = (ASCompat.floatToInt(_loc9_ + ((_loc7_ : Float) - (_loc9_ : Float)) * ratio) : UInt);
		return ((_loc12_ : Int) << 24 | (_loc4_ : Int) << 16 | (_loc13_ : Int) << 8 | (_loc10_ : Int) : UInt);
	}
}
