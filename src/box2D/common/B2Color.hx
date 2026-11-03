package box2D.common;

import box2D.common.math.B2Math;
import flash.Boot;

class B2Color {
	public var r:Float = Math.NaN;

	public var g:Float = Math.NaN;

	public var color:Int = 0;

	public var b:Float = Math.NaN;

	public var _r:Int = 0;

	public var _g:Int = 0;

	public var _b:Int = 0;

	public function new(rr:Float = 0, gg:Float = 0, bb:Float = 0) {
		if (Boot.skip_constructor) {
			return;
		}
		_r = ASCompat.floatToInt(255 * B2Math.clamp(rr, 0, 1));
		_g = ASCompat.floatToInt(255 * B2Math.clamp(gg, 0, 1));
		_b = ASCompat.floatToInt(255 * B2Math.clamp(bb, 0, 1));
	}

	public function set_r(rr:Float):Float {
		return _r = ASCompat.floatToInt(255 * B2Math.clamp(rr, 0, 1));
	}

	public function set_g(gg:Float):Float {
		return _g = ASCompat.floatToInt(255 * B2Math.clamp(gg, 0, 1));
	}

	public function set_b(bb:Float):Float {
		return _b = ASCompat.floatToInt(255 * B2Math.clamp(bb, 0, 1));
	}

	public function set(rr:Float, gg:Float, bb:Float) {
		Set(rr, gg, bb);
	}

	public function get_color():Int {
		return _r << 16 | _g << 8 | _b;
	}

	public function getString(alpha:Float = 1):String {
		return GetString(alpha);
	}

	public function Set(rr:Float, gg:Float, bb:Float) {
		_r = ASCompat.floatToInt(255 * B2Math.clamp(rr, 0, 1));
		_g = ASCompat.floatToInt(255 * B2Math.clamp(gg, 0, 1));
		_b = ASCompat.floatToInt(255 * B2Math.clamp(bb, 0, 1));
	}

	public function GetString(alpha:Float = 1):String {
		if (alpha == 1) {
			return "#" + StringTools.hex((_r & 0xFF) << 16 | (_g & 0xFF) << 8 | (_b & 0xFF));
		}
		return "rgba(" + _r + "," + _g + "," + _b + "," + alpha + ")";
	}
}
