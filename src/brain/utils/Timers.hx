package brain.utils;

import flash.utils.Timer;

class Timers {
	public function new() {}

	public static function create(delay:Float, repeatCount:Int = 0, label:String = null):Timer {
		return new Timer(delay, repeatCount);
	}
}
