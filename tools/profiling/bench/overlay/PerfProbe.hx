// Timers for temporary measures in the game's code:
//   var t = PerfProbe.start(); ...; PerfProbe.stop(0, t);
// PerfBot prints, for each phase, the microseconds and the calls per frame of every probe used.
class PerfProbe {
	public static var time:Array<Float> = [for (i in 0...12) 0.0];
	public static var count:Array<Int> = [for (i in 0...12) 0];

	// DRH_PROBE_MODE, for a build that holds two versions of some code and picks one when it starts
	public static var mode:Int = Std.parseInt(Sys.getEnv("DRH_PROBE_MODE") ?? "0");

	public static inline function start():Float {
		return haxe.Timer.stamp();
	}

	public static inline function stop(probe:Int, started:Float):Void {
		time[probe] += haxe.Timer.stamp() - started;
		count[probe]++;
	}

	public static inline function add(probe:Int, n:Int = 1):Void {
		count[probe] += n;
	}
}
