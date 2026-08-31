package box2D.common;

import box2D.common.math.B2Math;

class B2Color {
	var _r:UInt = (0 : UInt);

	var _g:UInt = (0 : UInt);

	var _b:UInt = (0 : UInt);

	public function new(rr:Float, gg:Float, bb:Float) {
		this._r = (Std.int(255 * B2Math.Clamp(rr, 0, 1)) : UInt);
		this._g = (Std.int(255 * B2Math.Clamp(gg, 0, 1)) : UInt);
		this._b = (Std.int(255 * B2Math.Clamp(bb, 0, 1)) : UInt);
	}

	public function Set(rr:Float, gg:Float, bb:Float) {
		this._r = (Std.int(255 * B2Math.Clamp(rr, 0, 1)) : UInt);
		this._g = (Std.int(255 * B2Math.Clamp(gg, 0, 1)) : UInt);
		this._b = (Std.int(255 * B2Math.Clamp(bb, 0, 1)) : UInt);
	}

	@:isVar public var r(never, set):Float;

	public function set_r(rr:Float):Float {
		this._r = (Std.int(255 * B2Math.Clamp(rr, 0, 1)) : UInt);
		return rr;
	}

	@:isVar public var g(never, set):Float;

	public function set_g(gg:Float):Float {
		this._g = (Std.int(255 * B2Math.Clamp(gg, 0, 1)) : UInt);
		return gg;
	}

	@:isVar public var b(never, set):Float;

	public function set_b(bb:Float):Float {
		this._b = (Std.int(255 * B2Math.Clamp(bb, 0, 1)) : UInt);
		return bb;
	}

	@:isVar public var color(get, never):UInt;

	public function get_color():UInt {
		return ((this._r : Int) << 16 | (this._g : Int) << 8 | (this._b : Int) : UInt);
	}
}
