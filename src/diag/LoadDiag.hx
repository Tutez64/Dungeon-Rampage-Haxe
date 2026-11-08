package diag;

import brain.logger.Logger;
import haxe.Timer;

/**
	Temporary diagnostic for slow dungeon loads and freezes (diag/load-timing branch, not to merge).
	Logs, with the "[LoadDiag]" prefix:
	- each file the Starling asset manager loads: time from request to bytes, size;
	- each asset made from them that takes 5 ms or more on the main thread (texture upload, JSON parse);
	- each synchronous Animation.json read that takes 5 ms or more;
	- each frame of 50 ms or more, with what was done in it, the steps it spent the most time in, and whether the
	  collector freed memory in it;
	- once per second while anything above happened: frame rate, longest frame, totals, memory.
**/
class LoadDiag {
	static inline final LONG_FRAME_MS = 50.0;
	static inline final SLOW_WORK_MS = 5.0;

	static inline final STUCK_MS = 2000.0;

	static var sInstalled = false;

	// the step the main thread last started, read by the watchdog thread
	static var sCrumb:String = "start";
	static var sCrumbAt = 0.0;
	static var sStarts:Map<String, Float> = new Map();
	// this frame: time spent in each step, from one crumb to the next
	static var sStepMs:Map<String, Float> = new Map();
	static var sLastUsed = 0.0;

	static var sLastFrame = 0.0;
	static var sSecondStart = 0.0;

	// this frame
	static var sFrameFiles = 0;
	static var sFrameWorkMs = 0.0;
	static var sFrameWorks = 0;
	static var sFrameSyncMs = 0.0;

	// this second
	static var sFrames = 0;
	static var sMaxFrame = 0.0;
	static var sLongFrames = 0;
	static var sFiles = 0;
	static var sBytes = 0.0;
	static var sMaxLatency = 0.0;
	static var sWorks = 0;
	static var sWorkMs = 0.0;
	static var sSyncMs = 0.0;
	static var sInFlight = 0;

	static inline function now():Float {
		return Timer.stamp() * 1000;
	}

	static function install() {
		if (sInstalled) return;
		var stage = openfl.Lib.current != null ? openfl.Lib.current.stage : null;
		if (stage == null) return;
		sInstalled = true;
		sLastFrame = sSecondStart = now();
		stage.addEventListener("enterFrame", onFrame);
		startWatchdog();
		Logger.info("[LoadDiag] installed");
	}

	public static function fileStart(url:String) {
		install();
		sStarts.set(url, now());
		sInFlight++;
	}

	public static function fileEnd(url:String, bytes:Float) {
		var start = sStarts.get(url);
		if (start == null) return;
		sStarts.remove(url);
		sInFlight--;
		var latency = now() - start;
		sFrameFiles++;
		sFiles++;
		sBytes += bytes;
		if (latency > sMaxLatency) sMaxLatency = latency;
		Logger.info("[LoadDiag] file " + Math.round(latency) + " ms " + mb(bytes) + " MB " + shortPath(url));
	}

	public static function work(kind:String, name:String, startMs:Float) {
		var ms = now() - startMs;
		sFrameWorkMs += ms;
		sFrameWorks++;
		sWorks++;
		sWorkMs += ms;
		if (ms >= SLOW_WORK_MS) Logger.info("[LoadDiag] " + kind + " " + Math.round(ms) + " ms " + shortPath(name));
	}

	public static function syncRead(name:String, startMs:Float) {
		var ms = now() - startMs;
		sFrameSyncMs += ms;
		sSyncMs += ms;
		if (ms >= SLOW_WORK_MS) Logger.info("[LoadDiag] sync read " + Math.round(ms) + " ms " + shortPath(name));
	}

	public static inline function stamp():Float {
		return now();
	}

	/** Names the step the main thread starts, for the watchdog, and adds the time of the previous one to this frame's. **/
	public static function crumb(step:String) {
		var t = now();
		var previous = sStepMs.get(sCrumb);
		sStepMs.set(sCrumb, (previous == null ? 0 : previous) + t - sCrumbAt);
		sCrumb = step;
		sCrumbAt = t;
	}

	public static inline function begin(step:String):Float {
		crumb(step);
		return sCrumbAt;
	}

	/**
		Every 250 ms, a thread checks that the main thread still makes frames. When it has not for 2 s, it
		prints the step the main thread last started, then again every 5 s while it stays stuck. It prints to
		the console, which the log captures, so as not to share the logger with the main thread.
	**/
	static function startWatchdog() {
		#if cpp
		sys.thread.Thread.create(function() {
			var reportedAt = 0.0;
			while (true) {
				Sys.sleep(0.25);
				var t = now();
				var stuck = t - sLastFrame;
				if (stuck < STUCK_MS) {
					if (reportedAt > 0) {
						Sys.println("[LoadDiag] main thread back after " + Math.round(t - sLastFrame) + " ms");
					}
					reportedAt = 0;
					continue;
				}
				if (reportedAt == 0 || t - reportedAt >= 5000) {
					reportedAt = t;
					Sys.println("[LoadDiag] " + Date.now().toString() + " main thread stuck for " + Math.round(stuck) + " ms, in: " + sCrumb + " (started "
						+ Math.round(t - sCrumbAt) + " ms ago)");
				}
			}
		});
		#end
	}

	static function onFrame(_) {
		crumb("between frames");
		var t = now();
		var frame = t - sLastFrame;
		sLastFrame = t;
		sFrames++;
		if (frame > sMaxFrame) sMaxFrame = frame;
		if (frame >= LONG_FRAME_MS) {
			sLongFrames++;
			Logger.info("[LoadDiag] long frame " + Math.round(frame) + " ms: files " + sFrameFiles + ", work " + sFrameWorks + " / " + Math.round(sFrameWorkMs)
				+ " ms, sync reads " + Math.round(sFrameSyncMs) + " ms" + collected() + ", steps: " + topSteps());
		}
		sStepMs = new Map();
		#if cpp
		sLastUsed = cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#end
		sFrameFiles = 0;
		sFrameWorks = 0;
		sFrameWorkMs = 0;
		sFrameSyncMs = 0;

		var elapsed = t - sSecondStart;
		if (elapsed >= 1000) {
			if (sFiles > 0 || sWorks > 0 || sLongFrames > 0 || sInFlight > 0) {
				Logger.info("[LoadDiag] second: " + Math.round(sFrames * 1000 / elapsed) + " fps, longest frame " + Math.round(sMaxFrame) + " ms, long frames "
					+ sLongFrames + ", files " + sFiles + " (" + mb(sBytes) + " MB, slowest " + Math.round(sMaxLatency) + " ms, in flight " + sInFlight + "), work "
					+ sWorks + " / " + Math.round(sWorkMs) + " ms, sync reads " + Math.round(sSyncMs) + " ms, memory " + memory());
			}
			sSecondStart = t;
			sFrames = 0;
			sMaxFrame = 0;
			sLongFrames = 0;
			sFiles = 0;
			sBytes = 0;
			sMaxLatency = 0;
			sWorks = 0;
			sWorkMs = 0;
			sSyncMs = 0;
		}
	}

	/** The steps of this frame that took 5 ms or more, longest first. **/
	static function topSteps():String {
		var steps = [for (name => ms in sStepMs) if (ms >= SLOW_WORK_MS) {name: name, ms: ms}];
		steps.sort((a, b) -> a.ms < b.ms ? 1 : (a.ms > b.ms ? -1 : 0));
		if (steps.length > 6) steps.resize(6);
		return steps.length == 0 ? "none of 5 ms" : [for (step in steps) shortStep(step.name) + " " + Math.round(step.ms)].join(", ");
	}

	/** Whether the memory in use dropped since the end of the last frame, which only a collection does. **/
	static function collected():String {
		#if cpp
		var used = cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		if (sLastUsed > 0 && used < sLastUsed - 1048576) return ", collected " + mb(sLastUsed - used) + " MB";
		#end
		return "";
	}

	static function memory():String {
		#if cpp
		return "used " + mb(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE)) + " MB, current " + mb(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_CURRENT))
			+ " MB, reserved " + mb(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED)) + " MB";
		#else
		return "?";
		#end
	}

	static function mb(bytes:Float):String {
		return Std.string(Math.round(bytes / 104857.6) / 10);
	}

	/** A step's name with the paths in it shortened, as "asset create Art3D/…". **/
	static function shortStep(name:String):String {
		var i = name.indexOf("Resources/");
		return i >= 0 ? name.substring(0, name.lastIndexOf(" ", i) + 1) + name.substr(i + 10) : name;
	}

	static function shortPath(path:String):String {
		if (path == null) return "?";
		var i = path.indexOf("Resources/");
		return i >= 0 ? path.substr(i + 10) : path;
	}
}
