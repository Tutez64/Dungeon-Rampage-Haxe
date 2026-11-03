package brain.render.tweens;

class Sine {
	static inline final HALF_PI:Float = 1.5707963267948966;

	public static function easeIn(param1:Float):Float {
		return 1 - Math.cos(param1 * 1.5707963267948966);
	}

	public static function easeOut(param1:Float):Float {
		return Math.sin(param1 * 1.5707963267948966);
	}

	public static function easeInOut(param1:Float):Float {
		return -0.5 * (Math.cos(3.141592653589793 * param1) - 1);
	}

	public function new() {}
}
