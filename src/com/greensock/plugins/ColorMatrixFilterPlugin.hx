package com.greensock.plugins;

import com.greensock.*;
import flash.filters.ColorMatrixFilter;

class ColorMatrixFilterPlugin extends FilterPlugin {
	public static inline final API:Float = 1;

	static var _propNames:Array<ASAny> = [];

	static var _idMatrix:Array<ASAny> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

	static var _lumR:Float = 0.212671;

	static var _lumG:Float = 0.71516;

	static var _lumB:Float = 0.072169;

	var _matrix:Array<ASAny>;

	var _matrixTween:EndArrayPlugin;

	public function new() {
		super();
		this.propName = "colorMatrixFilter";
		this.overwriteProps = ["colorMatrixFilter"];
	}

	public static function setSaturation(m:Array<ASAny>, n:Float):Array<ASAny> {
		if (Math.isNaN(n)) {
			return m;
		}
		var _loc3_ = 1 - n;
		var _loc4_ = _loc3_ * _lumR;
		var _loc5_ = _loc3_ * _lumG;
		var _loc6_ = _loc3_ * _lumB;
		var _loc7_:Array<ASAny> = [
			_loc4_ + n,
			_loc5_,
			_loc6_,
			0,
			0,
			_loc4_,
			_loc5_ + n,
			_loc6_,
			0,
			0,
			_loc4_,
			_loc5_,
			_loc6_ + n,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		];
		return applyMatrix(_loc7_, m);
	}

	public static function setHue(m:Array<ASAny>, n:Float):Array<ASAny> {
		if (Math.isNaN(n)) {
			return m;
		}
		n *= Math.PI / 180;
		var _loc3_ = Math.cos(n);
		var _loc4_ = Math.sin(n);
		var _loc5_:Array<ASAny> = [
			_lumR + _loc3_ * (1 - _lumR) + _loc4_ * -_lumR,
			_lumG + _loc3_ * -_lumG + _loc4_ * -_lumG,
			_lumB + _loc3_ * -_lumB + _loc4_ * (1 - _lumB),
			0,
			0,
			_lumR + _loc3_ * -_lumR + _loc4_ * 0.143,
			_lumG + _loc3_ * (1 - _lumG) + _loc4_ * 0.14,
			_lumB + _loc3_ * -_lumB + _loc4_ * -0.283,
			0,
			0,
			_lumR + _loc3_ * -_lumR + _loc4_ * -(1 - _lumR),
			_lumG + _loc3_ * -_lumG + _loc4_ * _lumG,
			_lumB + _loc3_ * (1 - _lumB) + _loc4_ * _lumB,
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
			1
		];
		return applyMatrix(_loc5_, m);
	}

	public static function setContrast(m:Array<ASAny>, n:Float):Array<ASAny> {
		if (Math.isNaN(n)) {
			return m;
		}
		n += 0.01;
		var _loc3_:Array<ASAny> = [
			n,
			0,
			0,
			0,
			128 * (1 - n),
			0,
			n,
			0,
			0,
			128 * (1 - n),
			0,
			0,
			n,
			0,
			128 * (1 - n),
			0,
			0,
			0,
			1,
			0
		];
		return applyMatrix(_loc3_, m);
	}

	public static function applyMatrix(m:Array<ASAny>, m2:Array<ASAny>):Array<ASAny> {
		var _loc6_ = 0;
		var _loc7_ = 0;
		if (!Std.isOfType(m, Array) || !Std.isOfType(m2, Array)) {
			return m2;
		}
		var _loc3_:Array<ASAny> = [];
		var _loc4_ = 0;
		var _loc5_ = 0;
		_loc6_ = 0;
		while (_loc6_ < 4) {
			_loc7_ = 0;
			while (_loc7_ < 5) {
				if (_loc7_ == 4) {
					_loc5_ = ASCompat.toInt(m[_loc4_ + 4]);
				} else {
					_loc5_ = 0;
				}
				_loc3_[_loc4_ + _loc7_] = ASCompat.toNumber(m[_loc4_]) * ASCompat.toNumber(m2[_loc7_])
					+ ASCompat.toNumber(m[_loc4_ + 1]) * ASCompat.toNumber(m2[_loc7_ + 5])
					+ ASCompat.toNumber(m[_loc4_ + 2]) * ASCompat.toNumber(m2[_loc7_ + 10])
					+ ASCompat.toNumber(m[_loc4_ + 3]) * ASCompat.toNumber(m2[_loc7_ + 15])
					+ _loc5_;
				_loc7_ += 1;
			}
			_loc4_ += 5;
			_loc6_ += 1;
		}
		return _loc3_;
	}

	public static function setThreshold(m:Array<ASAny>, n:Float):Array<ASAny> {
		if (Math.isNaN(n)) {
			return m;
		}
		var _loc3_:Array<ASAny> = [
			_lumR * 256,
			_lumG * 256,
			_lumB * 256,
			0,
			-256 * n,
			_lumR * 256,
			_lumG * 256,
			_lumB * 256,
			0,
			-256 * n,
			_lumR * 256,
			_lumG * 256,
			_lumB * 256,
			0,
			-256 * n,
			0,
			0,
			0,
			1,
			0
		];
		return applyMatrix(_loc3_, m);
	}

	public static function colorize(m:Array<ASAny>, color:Float, amount:Float = 1):Array<ASAny> {
		if (Math.isNaN(color)) {
			return m;
		}
		if (Math.isNaN(amount)) {
			amount = 1;
		}
		var _loc4_ = (Std.int(color) >> 16 & 0xFF) / 255;
		var _loc5_ = (Std.int(color) >> 8 & 0xFF) / 255;
		var _loc6_ = (Std.int(color) & 0xFF) / 255;
		var _loc7_ = 1 - amount;
		var _loc8_:Array<ASAny> = [
			_loc7_ + amount * _loc4_ * _lumR,
			amount * _loc4_ * _lumG,
			amount * _loc4_ * _lumB,
			0,
			0,
			amount * _loc5_ * _lumR,
			_loc7_ + amount * _loc5_ * _lumG,
			amount * _loc5_ * _lumB,
			0,
			0,
			amount * _loc6_ * _lumR,
			amount * _loc6_ * _lumG,
			_loc7_ + amount * _loc6_ * _lumB,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		];
		return applyMatrix(_loc8_, m);
	}

	public static function setBrightness(m:Array<ASAny>, n:Float):Array<ASAny> {
		if (Math.isNaN(n)) {
			return m;
		}
		n = n * 100 - 100;
		return applyMatrix([1, 0, 0, 0, n, 0, 1, 0, 0, n, 0, 0, 1, 0, n, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], m);
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		_type = ColorMatrixFilter;
		var _loc4_:ASObject = value;
		initFilter({
			"remove": value.remove,
			"index": value.index,
			"addFilter": value.addFilter
		}, new ColorMatrixFilter(cast(_idMatrix.slice(0))), _propNames);
		_matrix = cast(_filter, ColorMatrixFilter).matrix;
		var _loc5_:Array<ASAny> = [];
		if (_loc4_.matrix != null && Std.isOfType(_loc4_.matrix, Array)) {
			_loc5_ = ASCompat.dynamicAs(_loc4_.matrix, Array);
		} else {
			if (_loc4_.relative == true) {
				_loc5_ = _matrix.slice(0);
			} else {
				_loc5_ = _idMatrix.slice(0);
			}
			_loc5_ = setBrightness(_loc5_, ASCompat.toNumberField(_loc4_, "brightness"));
			_loc5_ = setContrast(_loc5_, ASCompat.toNumberField(_loc4_, "contrast"));
			_loc5_ = setHue(_loc5_, ASCompat.toNumberField(_loc4_, "hue"));
			_loc5_ = setSaturation(_loc5_, ASCompat.toNumberField(_loc4_, "saturation"));
			_loc5_ = setThreshold(_loc5_, ASCompat.toNumberField(_loc4_, "threshold"));
			if (!Math.isNaN(ASCompat.toNumberField(_loc4_, "colorize"))) {
				_loc5_ = colorize(_loc5_, ASCompat.toNumberField(_loc4_, "colorize"), ASCompat.toNumberField(_loc4_, "amount"));
			}
		}
		_matrixTween = new EndArrayPlugin();
		_matrixTween.init(_matrix, _loc5_);
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		_matrixTween.changeFactor = n;
		cast(_filter, ColorMatrixFilter).matrix = cast(_matrix);
		return super.changeFactor = n;
	}
}
