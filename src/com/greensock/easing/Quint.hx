package com.greensock.easing;

class Quint {
	public static inline final power = (4 : UInt);

	public function new() {}

	public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
	}

	public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return c * (t = t / d) * t * t * t * t + b;
	}

	public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		t = t / (d * 0.5);
		if (t < 1) {
			return c * 0.5 * t * t * t * t * t + b;
		}
		return c * 0.5 * ((t = t - 2) * t * t * t * t + 2) + b;
	}
}
