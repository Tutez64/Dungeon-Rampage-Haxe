package diag;

import brain.logger.Logger;
import haxe.Timer;

/**
	Temporary diagnostic for slow dungeon loads and freezes (diag/load-timing branch, not to merge).
	Logs, with the "[LoadDiag]" prefix:
	- each file the Starling asset manager loads: time from request to bytes, size;
	- each asset made from them that takes 5 ms or more on the main thread (texture upload, JSON parse);
	- each synchronous Animation.json read that takes 5 ms or more;
	- each frame of 50 ms or more, with what was done in it;
	- once per second while anything above happened: frame rate, longest frame, totals, memory.
**/
class LoadDiag {
	static inline final LONG_FRAME_MS = 50.0;
	static inline final SLOW_WORK_MS = 5.0;

	static var sInstalled = false;
	static var sStarts:Map<String, Float> = new Map();

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

	static function onFrame(_) {
		var t = now();
		var frame = t - sLastFrame;
		sLastFrame = t;
		sFrames++;
		if (frame > sMaxFrame) sMaxFrame = frame;
		if (frame >= LONG_FRAME_MS) {
			sLongFrames++;
			Logger.info("[LoadDiag] long frame " + Math.round(frame) + " ms: files " + sFrameFiles + ", work " + sFrameWorks + " / " + Math.round(sFrameWorkMs)
				+ " ms, sync reads " + Math.round(sFrameSyncMs) + " ms");
		}
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

	static function shortPath(path:String):String {
		if (path == null) return "?";
		var i = path.indexOf("Resources/");
		return i >= 0 ? path.substr(i + 10) : path;
	}
}
