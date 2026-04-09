package brain.logger;

import haxe.Timer;

class StartupTimer
{
	private static var startupStamp:Float = Timer.stamp();
	private static var startupMarked = false;

	public static function markStartup(source:String):Void
	{
		if (startupMarked)
		{
			return;
		}

		startupStamp = Timer.stamp();
		startupMarked = true;
		Logger.info("StartupTimer: startup marked at " + source);
	}

	public static function elapsedMs():Int
	{
		return Std.int((Timer.stamp() - startupStamp) * 1000);
	}

	public static function logElapsed(label:String):Void
	{
		Logger.info("StartupTimer: " + label + " after " + elapsedMs() + " ms");
	}
}
