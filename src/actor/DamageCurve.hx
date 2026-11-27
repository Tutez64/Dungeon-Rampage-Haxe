package actor;

class DamageCurve {
	public function new() {}

	public static function npcHealthCurve(level:UInt):Float {
		return Math.pow(level, 1.5);
	}

	public static function heroAttackCurve(level:UInt):Float {
		return Math.pow(level, 1.5) * 0.05;
	}
}
