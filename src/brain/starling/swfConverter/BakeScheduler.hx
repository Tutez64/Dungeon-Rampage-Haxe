package brain.starling.swfConverter;

class BakeScheduler {
	public static inline final FIGHT_QUIET_MS = 5000;

	public static var enabled:Bool = false;

	static var sLoading:Bool = false;

	static var sLastCombat:Int = ASCompat.floatToInt(-2147483648);

	public function new() {}

	public static function floorLoadStarted() {
		if (enabled) {
			sLoading = true;
		}
	}

	public static function floorLoaded() {
		sLoading = false;
	}

	public static function floorPurged() {
		sLoading = false;
		sLastCombat = ASCompat.floatToInt(-2147483648);
	}

	public static function noteCombat() {
		if (enabled) {
			sLastCombat = flash.Lib.getTimer();
		}
	}

	@:isVar public static var loading(get, never):Bool;

	static public function get_loading():Bool {
		return sLoading;
	}

	@:isVar public static var fighting(get, never):Bool;

	static public function get_fighting():Bool {
		return sLastCombat != -2147483648 && flash.Lib.getTimer() - sLastCombat < 5000;
	}
}
