package;

import cpp.vm.Gc;
import haxe.Timer;
import lime.ui.KeyCode;
import lime.ui.MouseButton;
import sys.io.File;
import sys.io.FileOutput;

/**
	The bench's bot (tools/profiling/bench/README.md), compiled over the game by build.sh only.
	Driven by the environment: DRH_PERF_OUT (output directory) and DRH_PERF_SCRIPT (steps
	separated by ';'). Without DRH_PERF_OUT it does nothing.
**/
@:cppFileCode("#include <malloc.h>")
class PerfBot {
	static inline final MAX_SAMPLES = 400000;

	static var state = 0; // 0 unknown, 1 enabled, 2 disabled
	static var events:FileOutput;
	static var seconds:FileOutput;
	static var outDir:String;
	static var facade:Dynamic;
	static var steps:Array<Array<String>>;
	static var stepIndex = 0;
	static var stepStart = -1.0;
	static var stepFrames = 0;
	static var startStamp = 0.0;
	static var lastStamp = -1.0;

	static var samples:haxe.ds.Vector<Float>;
	static var sampleCount = 0;
	static var drawSum = 0.0;
	static var phaseName:String = null;

	static var secStart = 0.0;
	static var secFrames = 0;
	static var secMax = 0.0;
	static var secDraws = 0.0;

	static var probeLast = 0.0;
	static var probeWall = 0.0;
	static var probeGame = 0.0;
	static var probeRatio = 0.0;
	static var probeMax = 0.0;

	static function init(f:Dynamic):Void {
		outDir = Sys.getEnv("DRH_PERF_OUT");
		if (outDir == null || outDir == "") {
			state = 2;
			return;
		}
		state = 1;
		facade = f;
		var script = Sys.getEnv("DRH_PERF_SCRIPT");
		steps = [];
		if (script != null) {
			for (part in script.split(";")) {
				part = StringTools.trim(part);
				if (part != "") steps.push(part.split(":"));
			}
		}
		events = File.write(outDir + "/events.log", false);
		seconds = File.write(outDir + "/seconds.csv", false);
		seconds.writeString("t,phase,state,frames,max_ms,draws,gc_used_mb,gc_reserved_mb,gc_large_mb,orig_clock_ratio,large_alloc_mb,large_drops,gpu_total_mb,hud_errors\n");
		samples = new haxe.ds.Vector<Float>(MAX_SAMPLES);
		startStamp = Timer.stamp();
		secStart = startStamp;
		var long = Sys.getEnv("DRH_PERF_LONG");
		if (long != null && long != "") longMs = Std.parseFloat(long);
		var idle = Sys.getEnv("DRH_PERF_IDLE");
		if (idle != null && idle != "") {
			swf.exporters.animate.AnimateLibrary.hardwareBitmapIdleTime = Std.parseFloat(idle);
			note("hardwareBitmapIdleTime=" + swf.exporters.animate.AnimateLibrary.hardwareBitmapIdleTime);
		}
		note("start steps=" + steps.length + " epoch=" + Sys.time());
	}

	public static function note(text:String):Void {
		if (state != 1) return;
		events.writeString(fmt(Timer.stamp() - startStamp, 3) + " " + text + "\n");
		events.flush();
	}

	static function fmt(v:Float, digits:Int):String {
		var p = Math.pow(10, digits);
		return Std.string(Math.fround(v * p) / p);
	}

	static function stateName():String {
		try {
			var db:facade.DBFacade = cast facade;
			var machine = db.mainStateMachine;
			return machine == null ? "none" : machine.currentStateName;
		} catch (e:Dynamic) {
			return "error";
		}
	}

	/** What the unpatched comparison would have computed, for the record only. **/
	public static function clockProbe(rawNow:Float, gameDelta:Float):Void {
		if (state != 1) return;
		if (probeLast != 0) {
			var d = Std.int(rawNow - probeLast);
			if (d < 0) d = 0;
			probeWall += d;
		}
		probeLast = rawNow;
		probeGame += gameDelta;
		if (probeWall > 1000) {
			probeRatio = probeGame * 1000 / probeWall;
			if (probeRatio > probeMax && probeRatio < 100) probeMax = probeRatio;
			probeWall = 0;
			probeGame = 0;
		}
	}

	/** The run stops rather than let a third suspicious second lead to a report. **/
	public static function cheatCount(count:Int, ratio:Float):Void {
		if (state != 1) return;
		note("CHEATCOUNT " + count + " ratio=" + fmt(ratio, 3));
		if (count >= 3) {
			note("ABORT before a speed hack report");
			events.close();
			seconds.close();
			Sys.exit(3);
		}
	}

	public static function frame(f:Dynamic):Void {
		if (state == 2) return;
		if (state == 0) {
			init(f);
			if (state != 1) return;
		}
		var now = Timer.stamp();
		var draws = 0;
		try {
			var painter = starling.core.Starling.painter;
			if (painter != null) draws = painter.drawCount;
		} catch (e:Dynamic) {}
		if (lastStamp >= 0) {
			var ms = (now - lastStamp) * 1000;
			secFrames++;
			secDraws += draws;
			if (ms > secMax) secMax = ms;
			if (ms > longMs && stepIndex > 2) note("LONGFRAME ms=" + fmt(ms, 1) + " at=" + fmt(Sys.time(), 3));
			if (phaseName != null && sampleCount < MAX_SAMPLES) {
				samples[sampleCount++] = ms;
				drawSum += draws;
			}
		}
		lastStamp = now;
		var largeNow = Gc.memInfo64(Gc.MEM_INFO_LARGE) / 1048576;
		if (lastLarge >= 0) {
			var d = largeNow - lastLarge;
			if (d > 0) secLargeAlloc += d;
			else if (d < -1) secLargeDrops++;
		}
		lastLarge = largeNow;
		if (wiggle) {
			// wiggleMoves events on this frame, as a mouse reporting faster than the frame rate sends
			for (k in 0...wiggleMoves) {
				wigglePhase = !wigglePhase;
				openfl.Lib.application.window.onMouseMove.dispatch(wiggleX + (wigglePhase ? 3 : 0) + (k % 4), wiggleY);
			}
		}
		if (now - secStart >= 1) {
			seconds.writeString(fmt(now - startStamp, 2) + "," + (phaseName == null ? "" : phaseName) + "," + stateName() + "," + secFrames + ","
				+ fmt(secMax, 2) + "," + fmt(secFrames > 0 ? secDraws / secFrames : 0, 1) + "," + mb(Gc.MEM_INFO_USAGE) + ","
				+ mb(Gc.MEM_INFO_RESERVED) + "," + mb(Gc.MEM_INFO_LARGE) + "," + fmt(probeRatio, 3) + "," + fmt(secLargeAlloc, 1) + "," + secLargeDrops + "," + gpuMb() + "," + hudErrors() + "\n");
			secLargeAlloc = 0;
			secLargeDrops = 0;
			seconds.flush();
			secStart = now;
			secFrames = 0;
			secMax = 0;
			secDraws = 0;
		}
		runStep(now);
	}

	static var probeTime0:Array<Float> = [];
	static var probeCount0:Array<Int> = [];

	// What temporary PerfProbe calls in the game's code measured during the phase, per frame
	static function probes(frames:Int):String {
		var text = "";
		for (i in 0...PerfProbe.time.length) {
			var calls = PerfProbe.count[i] - probeCount0[i];
			if (calls == 0 || frames == 0) continue;
			text += " probe" + i + "_us=" + fmt((PerfProbe.time[i] - probeTime0[i]) * 1e6 / frames, 2) + " probe" + i + "_calls=" + fmt(calls / frames, 2);
		}
		return text;
	}

	static var lastLarge:Float = -1;
	static var secLargeAlloc:Float = 0;
	static var secLargeDrops:Int = 0;
	static var wiggle:Bool = false;
	static var wigglePhase:Bool = false;
	static var wiggleMoves:Int = 1;
	static var wiggleX:Float = 0;
	static var wiggleY:Float = 0;
	static var longMs:Float = 25;

	static var lastHudErrors:Int = 0;

	// What the game's bake budget reads: Context3D.totalGPUMemory, in MiB
	static function gpuMb():String {
		try {
			var context = starling.core.Starling.context;
			if (context == null) return "";
			return fmt(context.totalGPUMemory / 1048576, 0);
		} catch (e:Dynamic) {
			return "";
		}
	}

	// The HUD converter's error count; its last error is noted when the count changes
	@:access(uI.hud.starlingConverted.StarlingHud)
	static function hudErrors():String {
		var count:Int = uI.hud.starlingConverted.StarlingHud.sErrorCount;
		if (count != lastHudErrors) {
			lastHudErrors = count;
			note("HUDERROR count=" + count + " last=" + uI.hud.starlingConverted.StarlingHud.sLastError + " first=" + uI.hud.starlingConverted.StarlingHud.sFirstError);
		}
		return "" + count;
	}

	static function mb(what:Int):String {
		return fmt(Gc.memInfo64(what) / 1048576, 1);
	}

	static function nextStep():Void {
		stepIndex++;
		stepStart = -1;
		stepFrames = 0;
	}

	static function runStep(now:Float):Void {
		if (stepIndex >= steps.length) return;
		var step = steps[stepIndex];
		if (stepStart < 0) {
			stepStart = now;
			stepFrames = 0;
			note("step " + step.join(":") + " state=" + stateName());
		}
		var elapsed = now - stepStart;
		stepFrames++;
		switch (step[0]) {
			case "state":
				var timeout = step.length > 2 ? Std.parseFloat(step[2]) : 120.0;
				if (stateName() == step[1]) {
					nextStep();
				} else if (elapsed > timeout) {
					note("TIMEOUT waiting for state " + step[1] + ", in " + stateName());
					quit();
				}
			case "wait":
				if (elapsed >= Std.parseFloat(step[1])) nextStep();
			case "wiggle":
				// wiggle:<x>:<y>[:<n>] moves the mouse around that point n times (1) on every frame, wiggle:off stops,
				// move:<x>:<y> moves it once.
				if (step[1] == "off") {
					wiggle = false;
				} else {
					var window = openfl.Lib.application.window;
					wiggleX = Std.parseFloat(step[1]) * window.width / 2560;
					wiggleY = Std.parseFloat(step[2]) * window.height / 1440;
					wiggleMoves = step.length > 3 ? Std.parseInt(step[3]) : 1;
					wiggle = true;
				}
				nextStep();
			case "move":
				var window = openfl.Lib.application.window;
				window.onMouseMove.dispatch(Std.parseFloat(step[1]) * window.width / 2560, Std.parseFloat(step[2]) * window.height / 1440);
				nextStep();
			case "click":
				var window = openfl.Lib.application.window;
				var x = Std.parseFloat(step[1]) * window.width / 2560;
				var y = Std.parseFloat(step[2]) * window.height / 1440;
				if (stepFrames == 1) {
					window.onMouseMove.dispatch(x, y);
				} else if (stepFrames == 4) {
					window.onMouseDown.dispatch(x, y, MouseButton.LEFT);
				} else if (stepFrames == 8) {
					window.onMouseUp.dispatch(x, y, 0);
					nextStep();
				}
			case "keydown":
				openfl.Lib.application.window.onKeyDown.dispatch(key(step[1]), 0);
				nextStep();
			case "keyup":
				openfl.Lib.application.window.onKeyUp.dispatch(key(step[1]), 0);
				nextStep();
			case "phase":
				if (phaseName == null) {
					phaseName = step[1];
					sampleCount = 0;
					drawSum = 0;
					probeTime0 = PerfProbe.time.copy();
					probeCount0 = PerfProbe.count.copy();
				} else if (elapsed >= Std.parseFloat(step[2])) {
					endPhase(elapsed);
					nextStep();
				}
			case "shot":
				if (stepFrames == 1) note("SHOT " + step[1]);
				if (elapsed >= 2.5) nextStep();
			case "gc":
				Gc.run(true);
				note("gc used=" + mb(Gc.MEM_INFO_USAGE) + " reserved=" + mb(Gc.MEM_INFO_RESERVED) + " large=" + mb(Gc.MEM_INFO_LARGE));
				nextStep();
			case "census":
				var rows:Array<Dynamic> = untyped __global__.__hxcpp_gc_census();
				var f = File.write(outDir + "/census_" + step[1] + ".csv", false);
				f.writeString("name,count,bytes,large_count,large_bytes\n");
				for (r in rows) {
					f.writeString('"' + r.name + '",' + r.count + "," + r.bytes + "," + (r.largeCount == null ? 0 : r.largeCount) + ","
						+ (r.largeBytes == null ? 0 : r.largeBytes) + "\n");
				}
				f.close();
				note("census " + step[1] + " rows=" + rows.length + " used=" + mb(Gc.MEM_INFO_USAGE) + " large=" + mb(Gc.MEM_INFO_LARGE));
				nextStep();
			case "tex":
				textureCensus();
				nextStep();
			case "bmp":
				bitmapCensus();
				nextStep();
			case "mallinfo":
				note("mallinfo " + mallinfo() + " rss_anon=" + rssAnon());
				nextStep();
			case "trim":
				untyped __cpp__("malloc_trim(0)");
				note("trimmed " + mallinfo() + " rss_anon=" + rssAnon());
				nextStep();
			case "quit":
				quit();
			default:
				note("unknown step " + step[0]);
				nextStep();
		}
	}

	@:access(openfl.display3D.textures.TextureBase)
	static function textureCensus():Void {
		#if perf_tex
		var groups = new Map<String, Array<Float>>();
		var total = 0.0;
		var depthTotal = 0.0;
		for (texture in openfl.display3D.textures.TextureBase.__registry) {
			var name = Type.getClassName(Type.getClass(texture)).split(".").pop();
			var format = texture.__internalFormat;
			var pixels:Float = texture.__width * texture.__height;
			var bytes = switch (format) {
				case 0x83F0, 0x83F1: pixels / 2;
				case 0x83F2, 0x83F3: pixels;
				default: pixels * 4;
			}
			var depth = texture.__glDepthRenderbuffer == null ? 0 : (texture.__glStencilRenderbuffer == texture.__glDepthRenderbuffer ? pixels * 4 : pixels * 3);
			var key = name + " " + texture.__width + "x" + texture.__height + " fmt=0x" + StringTools.hex(format) + (texture.__optimizeForRenderToTexture ? " rtt" : "")
				+ (texture.__glFramebuffer != null ? " fbo" : "") + (depth > 0 ? " depth" : "");
			var entry = groups.get(key);
			if (entry == null) {
				entry = [0, 0, 0];
				groups.set(key, entry);
			}
			entry[0] += 1;
			entry[1] += bytes;
			entry[2] += depth;
			total += bytes;
			depthTotal += depth;
		}
		var keys = [for (k in groups.keys()) k];
		keys.sort(function(a, b) {
			var x = groups.get(a);
			var y = groups.get(b);
			return (y[1] + y[2]) > (x[1] + x[2]) ? 1 : -1;
		});
		note("TEX total_mb=" + fmt(total / 1048576, 1) + " depth_mb=" + fmt(depthTotal / 1048576, 1) + " groups=" + keys.length);
		for (i in 0...Std.int(Math.min(40, keys.length))) {
			var entry = groups.get(keys[i]);
			note("TEX   " + fmt(entry[1] / 1048576, 1) + " MB +depth " + fmt(entry[2] / 1048576, 1) + " MB  x" + entry[0] + "  " + keys[i]);
		}
		#else
		note("TEX census not compiled in");
		#end
	}

	@:access(swf.exporters.animate.AnimateLibrary)
	@:access(openfl.display.BitmapData)
	static function bitmapCensus():Void {
		var pendingBytes = 0.0;
		var pendingCount = 0;
		var uploadedCount = 0;
		var uploadedBytes = 0.0;
		var readableBytes = 0.0;
		var readableCount = 0;
		var libraries = 0;
		for (library in swf.exporters.animate.AnimateLibrary.instances) {
			libraries++;
			for (key => bitmap in library.hardwareBitmapData) {
				var bytes:Float = bitmap.width * bitmap.height * 4;
				if (bitmap.image != null) {
					pendingCount++;
					pendingBytes += bytes;
					if (bytes > 8000000) note("BMP pending " + bitmap.width + "x" + bitmap.height + " " + library.id + " " + key + " texture=" + (bitmap.__texture != null));
				} else {
					uploadedCount++;
					uploadedBytes += bytes;
				}
			}
			for (key => bitmap in library.readableShapeBitmapData) {
				readableCount++;
				readableBytes += bitmap.width * bitmap.height * 4;
				if (bitmap.width * bitmap.height * 4 > 8000000) note("BMP readable " + bitmap.width + "x" + bitmap.height + " " + library.id + " " + key);
			}
		}
		note("BMP libraries=" + libraries + " hardware_with_image=" + pendingCount + " (" + fmt(pendingBytes / 1048576, 1) + " MB) hardware_uploaded=" + uploadedCount
			+ " (" + fmt(uploadedBytes / 1048576, 1) + " MB as textures) readable=" + readableCount + " (" + fmt(readableBytes / 1048576, 1) + " MB)");
	}

	static function mallinfo():String {
		var arena:Float = untyped __cpp__("(double)mallinfo2().arena");
		var inUse:Float = untyped __cpp__("(double)mallinfo2().uordblks");
		var free:Float = untyped __cpp__("(double)mallinfo2().fordblks");
		var mmapped:Float = untyped __cpp__("(double)mallinfo2().hblkhd");
		var mmapCount:Float = untyped __cpp__("(double)mallinfo2().hblks");
		return "arena=" + fmt(arena / 1048576, 1) + " in_use=" + fmt(inUse / 1048576, 1) + " free=" + fmt(free / 1048576, 1) + " mmapped="
			+ fmt(mmapped / 1048576, 1) + " mmap_count=" + mmapCount + " gc_used=" + mb(Gc.MEM_INFO_USAGE) + " gc_reserved=" + mb(Gc.MEM_INFO_RESERVED)
			+ " gc_large=" + mb(Gc.MEM_INFO_LARGE);
	}

	static function rssAnon():String {
		try {
			for (line in File.getContent("/proc/self/status").split("
")) {
				if (StringTools.startsWith(line, "RssAnon:")) return StringTools.trim(line.substr(8));
			}
		} catch (e:Dynamic) {}
		return "?";
	}

	static function key(name:String):KeyCode {
		return switch (name) {
			case "UP": KeyCode.UP;
			case "DOWN": KeyCode.DOWN;
			case "LEFT": KeyCode.LEFT;
			case "RIGHT": KeyCode.RIGHT;
			case "SPACE": KeyCode.SPACE;
			case "ESCAPE": KeyCode.ESCAPE;
			case "J": KeyCode.J;
			case "K": KeyCode.K;
			case "L": KeyCode.L;
			default: cast Std.parseInt(name);
		}
	}

	static function endPhase(elapsed:Float):Void {
		var n = sampleCount;
		var raw = File.write(outDir + "/frames_" + phaseName + ".txt", false);
		var buffer = new StringBuf();
		var sum = 0.0;
		var over16 = 0;
		var over33 = 0;
		var over100 = 0;
		var sorted = new Array<Float>();
		for (i in 0...n) {
			var v = samples[i];
			sum += v;
			if (v > 16.7) over16++;
			if (v > 33.4) over33++;
			if (v > 100) over100++;
			sorted.push(v);
			buffer.add(fmt(v, 3));
			buffer.add("\n");
		}
		raw.writeString(buffer.toString());
		raw.close();
		sorted.sort(function(a, b) return a < b ? -1 : (a > b ? 1 : 0));
		function pct(p:Float):Float {
			return n == 0 ? 0 : sorted[Std.int(Math.min(n - 1, Math.floor(p * n)))];
		}
		note("PHASE " + phaseName + " frames=" + n + " fps=" + fmt(n > 0 ? n * 1000 / sum : 0, 1) + " mean_ms=" + fmt(n > 0 ? sum / n : 0, 3) + " p50="
			+ fmt(pct(0.5), 3) + " p90=" + fmt(pct(0.9), 3) + " p99=" + fmt(pct(0.99), 3) + " p999=" + fmt(pct(0.999), 3) + " max="
			+ fmt(n > 0 ? sorted[n - 1] : 0, 2) + " over16=" + over16 + " over33=" + over33 + " over100=" + over100 + " draws="
			+ fmt(n > 0 ? drawSum / n : 0, 1) + " gc_used=" + mb(Gc.MEM_INFO_USAGE) + " gc_reserved=" + mb(Gc.MEM_INFO_RESERVED) + " gc_large="
			+ mb(Gc.MEM_INFO_LARGE) + " orig_clock_ratio_max=" + fmt(probeMax, 3) + probes(n));
		phaseName = null;
	}

	static function quit():Void {
		note("quit");
		steps = [];
		stepIndex = 0;
		try {
			flash.desktop.NativeApplication.nativeApplication.exit();
		} catch (e:Dynamic) {
			Sys.exit(0);
		}
	}
}
