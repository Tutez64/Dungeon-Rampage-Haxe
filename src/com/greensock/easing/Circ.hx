package com.greensock.easing;

class Circ {
	public function new() {}

	public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
	}

	public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * (Math.sqrt(1 - (t = t / d) * t) - 1) + b;
	}

	public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		t = t / (d * 0.5);
		if (t < 1) {
			return -c * 0.5 * (Math.sqrt(1 - t * t) - 1) + b;
		}
		return c * 0.5 * (Math.sqrt(1 - (t = t - 2) * t) + 1) + b;
	}
}
