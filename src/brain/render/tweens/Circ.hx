package brain.render.tweens;

class Circ {
	public static function easeIn(param1:Float):Float {
		return -(Math.sqrt(1 - param1 * param1) - 1);
	}

	public static function easeOut(param1:Float):Float {
		param1 -= 1;
		return Math.sqrt(1 - param1 * param1);
	}

	public static function easeInOut(param1:Float):Float {
		param1 *= 2;
		if (param1 < 1) {
			return -0.5 * (Math.sqrt(1 - param1 * param1) - 1);
		}
		param1 -= 2;
		return 0.5 * (Math.sqrt(1 - param1 * param1) + 1);
	}

	public function new() {}
}
