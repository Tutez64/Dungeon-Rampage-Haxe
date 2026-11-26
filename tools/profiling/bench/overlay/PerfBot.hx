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
@:cppFileCode("#include <malloc.h>
#include <time.h>
static double perfClock(clockid_t id) { struct timespec ts; clock_gettime(id, &ts); return ts.tv_sec + ts.tv_nsec * 1e-9; }")
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

	// Where a frame's time goes, in wall seconds since the start. The first ones are timed around a line of the
	// game's code by make_overlay.py's hooks; the last four split the whole frame at Lime's and OpenFL's events:
	// update (Lime's update, the pending mouse event), events (the enterFrame broadcast: the game's loop and
	// Starling's are in it), openfl (OpenFL's own display list), swap (buffer swap, event polling, frame limiter).
	public static inline final B_REALWORK = 0;
	public static inline final B_LOGICAL = 1;
	public static inline final B_PHYSICS = 2;
	public static inline final B_PRERENDER = 3;
	public static inline final B_VIEWS = 4;
	public static inline final B_LAYERS = 5;
	public static inline final B_ADVANCE = 6;
	public static inline final B_RENDER = 7;
	public static inline final B_NETWORK = 8;
	static inline final B_UPDATE = 9;
	static inline final B_EVENTS = 10;
	static inline final B_OPENFL = 11;
	static inline final B_SWAP = 12;
	static final blockNames = ["realwork", "logical", "physics", "prerender", "views", "layers", "advance", "render", "network", "update", "events", "openfl", "swap"];
	public static var block:haxe.ds.Vector<Float> = zeros(13);
	static var blockSec:haxe.ds.Vector<Float> = zeros(13);
	static var blockFrame:haxe.ds.Vector<Float> = zeros(13);
	static var lapStamp = -1.0;

	/** Filter passes started (FragmentFilter.renderPasses), and filters that started some. **/
	public static var passes = 0;
	public static var filters = 0;
	static var passesFrame = 0;
	static var passesSec = 0;
	static var filtersSec = 0;
	static var secSlow10 = 0;
	static var secSlow16 = 0;
	static var mainCpu = 0.0;
	static var procCpu = 0.0;

	// DRH_PERF_RECORD: a line per frame in frames.csv, and each second the game objects by class (objects.csv),
	// the floor, and the Starling display tree
	static var record = false;
	static var frames:FileOutput;
	static var objects:FileOutput;
	static var frameLines:StringBuf;
	static var native:FileOutput;
	static var world = ",,,,,,,,,,,,,,,,,";
	static var floorKey = "";

	static function zeros(n:Int):haxe.ds.Vector<Float> {
		var v = new haxe.ds.Vector<Float>(n);
		for (i in 0...n) v[i] = 0;
		return v;
	}

	public static inline function begin():Float {
		return Timer.stamp();
	}

	public static inline function end(b:Int, started:Float):Void {
		block[b] += Timer.stamp() - started;
	}

	static function lap(b:Int):Void {
		var now = Timer.stamp();
		if (lapStamp >= 0) block[b] += now - lapStamp;
		lapStamp = now;
	}

	static function threadCpu():Float {
		return untyped __cpp__("perfClock(CLOCK_THREAD_CPUTIME_ID)");
	}

	static function processCpu():Float {
		return untyped __cpp__("perfClock(CLOCK_PROCESS_CPUTIME_ID)");
	}

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
		seconds.writeString("t,phase,state,frames,max_ms,draws,gc_used_mb,gc_reserved_mb,gc_large_mb,orig_clock_ratio,large_alloc_mb,large_drops,gpu_total_mb,hud_errors,"
			+ "passes,filters,slow10,slow16,main_cpu_ms,proc_cpu_ms,b_" + blockNames.join(",b_")
			+ ",floor,heroes,npcs,projectiles,effects,effects_live,objects,sl_objects,sl_shown,sl_meshes,sl_filters,juggler,nat_objects,nat_shown,nat_text,nat_filters,nat_under_hidden,nat_cache_renders,alt," + [for (i in 0...PerfProbe.time.length) "p" + i + "_us,p" + i + "_calls"].join(",") + "\n");
		var period = Sys.getEnv("DRH_PERF_ALT");
		if (period != null && period != "") altPeriod = Std.parseInt(period);
		var variants = Sys.getEnv("DRH_PERF_VARIANTS");
		if (variants != null && variants != "") altVariants = Std.parseInt(variants);
		var together = Sys.getEnv("DRH_PERF_ALL");
		if (together != null && together != "") {
			altAll = Std.parseInt(together);
			altVariants = 1;
		}
		var forced = Sys.getEnv("DRH_PERF_ON");
		if (forced != null && forced != "") {
			for (part in forced.split(",")) altForced |= 1 << Std.parseInt(part);
		}
		applyAlt();
		record = Sys.getEnv("DRH_PERF_RECORD") == "1";
		if (record) {
			frames = File.write(outDir + "/frames.csv", false);
			frames.writeString("t,ms,draws,passes\n");
			frameLines = new StringBuf();
			objects = File.write(outDir + "/objects.csv", false);
			objects.writeString("t,class,count\n");
			native = File.write(outDir + "/native.csv", false);
			native.writeString("t,branch,class,objects,shown,filters\n");
			cacheFile = File.write(outDir + "/cache.csv", false);
			cacheFile.writeString("t,branch,class,filters,why,objects,renders\n");
			cacheRenders = new haxe.ds.ObjectMap();
		}
		mainCpu = threadCpu();
		procCpu = processCpu();
		// Lime calls the listeners of higher priority first, and OpenFL's stage listens at 0
		var application = openfl.Lib.application;
		application.onUpdate.add(function(_) lap(B_SWAP), false, 1000000);
		application.window.onRender.add(function(_) lap(B_UPDATE), false, 1000000);
		application.window.onRender.add(function(_) lap(B_OPENFL), false, -1000000);
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, function(_) lap(B_EVENTS));
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
		var mono:Float = untyped __cpp__("perfClock(CLOCK_MONOTONIC)");
		var stage = openfl.Lib.current.stage;
		note("start steps=" + steps.length + " epoch=" + Sys.time() + " mono=" + fmt(mono, 4) + " window=" + stage.stageWidth + "x" + stage.stageHeight);
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
			if (ms > 10) secSlow10++;
			if (ms > 16.7) secSlow16++;
			if (ms > longMs && (record || stepIndex > 2)) note("LONGFRAME ms=" + fmt(ms, 1) + " at=" + fmt(Sys.time(), 3) + " state=" + stateName() + frameBlocks());
			if (record) {
				frameLines.add(fmt((now - startStamp) * 1000, 1));
				frameLines.add(",");
				frameLines.add(fmt(ms, 3));
				frameLines.add(",");
				frameLines.add(draws);
				frameLines.add(",");
				frameLines.add(passes - passesFrame);
				frameLines.add("\n");
			}
			if (phaseName != null && sampleCount < MAX_SAMPLES) {
				samples[sampleCount++] = ms;
				drawSum += draws;
			}
		}
		lastStamp = now;
		passesFrame = passes;
		for (i in 0...block.length) blockFrame[i] = block[i];
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
				+ mb(Gc.MEM_INFO_RESERVED) + "," + mb(Gc.MEM_INFO_LARGE) + "," + fmt(probeRatio, 3) + "," + fmt(secLargeAlloc, 1) + "," + secLargeDrops + "," + gpuMb() + "," + hudErrors() + secondBlocks(now) + "\n");
			secLargeAlloc = 0;
			secLargeDrops = 0;
			seconds.flush();
			secStart = now;
			secFrames = 0;
			secMax = 0;
			secDraws = 0;
			secSlow10 = 0;
			secSlow16 = 0;
		}
		runStep(now);
	}

	// The blocks of the frame that just ended, in milliseconds, for a LONGFRAME line
	static function frameBlocks():String {
		var text = "";
		for (i in 0...block.length) {
			var ms = (block[i] - blockFrame[i]) * 1000;
			if (ms >= 0.5) text += " " + blockNames[i] + "=" + fmt(ms, 1);
		}
		return text + " passes=" + (passes - passesFrame);
	}

	// The second's columns after hud_errors: filter passes and filters a frame, slow frames, CPU time of the main
	// thread and of the process, the blocks in milliseconds, then what sampleWorld() counted
	static function secondBlocks(now:Float):String {
		var text = "," + fmt(secFrames > 0 ? (passes - passesSec) / secFrames : 0, 1) + "," + fmt(secFrames > 0 ? (filters - filtersSec) / secFrames : 0, 1) + ","
			+ secSlow10 + "," + secSlow16;
		passesSec = passes;
		filtersSec = filters;
		var cpu = threadCpu();
		var all = processCpu();
		text += "," + fmt((cpu - mainCpu) * 1000, 1) + "," + fmt((all - procCpu) * 1000, 1);
		mainCpu = cpu;
		procCpu = all;
		for (i in 0...block.length) {
			text += "," + fmt((block[i] - blockSec[i]) * 1000, 2);
			blockSec[i] = block[i];
		}
		if (record) {
			frames.writeString(frameLines.toString());
			frames.flush();
			frameLines = new StringBuf();
			try {
				sampleWorld(now);
			} catch (e:Dynamic) {
				world = ",,,,,,,,,,,,,,,,,";
				note("WORLD error " + Std.string(e));
			}
		}
		text += "," + world + "," + alt;
		for (i in 0...PerfProbe.time.length) {
			text += "," + fmt((PerfProbe.time[i] - probeSecTime[i]) * 1e6, 1) + "," + (PerfProbe.count[i] - probeSecCount[i]);
			probeSecTime[i] = PerfProbe.time[i];
			probeSecCount[i] = PerfProbe.count[i];
		}
		if (altPeriod > 0 && ++altSeconds >= altPeriod) {
			altSeconds = 0;
			alt = (alt + 1) % (altVariants + 1);
			applyAlt();
		}
		return text;
	}

	// DRH_PERF_ALT=<seconds>: variants of some code take turns, each for that many seconds, so that one game
	// measures them all on the same content. Variant 0 is the code as it was; variant k (1 to DRH_PERF_VARIANTS,
	// 1 by default) turns on change k alone. The code of change k is written `if (PerfBot.on(k)) new else old`;
	// a change in a library has a switch of its own, set in applyAlt(). DRH_PERF_ON=<k>,<k> keeps changes on in
	// every variant. DRH_PERF_ALL=<n> has two variants instead: none, and changes 1 to n together.
	// seconds.csv says which variant each second ran (alt).
	static var alt = 0;
	static var altPeriod = 0;
	static var altSeconds = 0;
	static var altVariants = 1;
	static var altForced = 0;
	static var altAll = 0;
	public static var onMask = 0;
	static var probeSecTime:Array<Float> = [for (i in 0...12) 0.0];
	static var probeSecCount:Array<Int> = [for (i in 0...12) 0];

	public static inline function on(change:Int):Bool {
		return (onMask & (1 << change)) != 0;
	}

	static function applyAlt():Void {
		onMask = altForced | (altPeriod > 0 && alt > 0 ? (altAll > 0 ? (1 << (altAll + 1)) - 2 : 1 << alt) : 0);
		if (altPeriod > 0) PerfProbe.mode = alt;
		// a change in a library sets its switch here, for the time of the measure
	}

	static var slObjects = 0;
	static var slShown = 0;
	static var slMeshes = 0;
	static var slFilters = 0;

	static function walk(object:starling.display.DisplayObject, shown:Bool):Void {
		slObjects++;
		shown = shown && object.visible && object.alpha != 0;
		if (shown) {
			slShown++;
			if (object.filter != null) slFilters++;
		}
		var container = Std.downcast(object, starling.display.DisplayObjectContainer);
		if (container != null) {
			for (i in 0...container.numChildren) walk(container.getChildAt(i), shown);
		} else if (shown && Std.isOfType(object, starling.display.Mesh)) {
			slMeshes++;
		}
	}

	// Once a second: the game objects by class, the dungeon floor, the effects in use, Starling's display tree
	// (objects, those shown, meshes shown, filters shown) and its juggler
	@:access(brain.gameObject.GameObjectManager)
	@:access(distributedObjects.DistributedDungeonFloor)
	@:access(effects.EffectManager)
	@:access(starling.animation.Juggler)
	static function sampleWorld(now:Float):Void {
		var db:facade.DBFacade = cast facade;
		var all:Array<ASAny> = db.gameObjectManager.mGameObjects.toArray();
		var counts = new Map<String, Int>();
		var floor:distributedObjects.DistributedDungeonFloor = null;
		for (item in all) {
			var object:Dynamic = item;
			var type = Type.getClass(object);
			if (type == null) continue;
			var name = Type.getClassName(type);
			counts.set(name, (counts.exists(name) ? counts.get(name) : 0) + 1);
			if (floor == null && Std.isOfType(object, distributedObjects.DistributedDungeonFloor)) floor = cast object;
		}
		var heroes = 0, npcs = 0, projectiles = 0, effects = 0;
		var t = fmt(now - startStamp, 2);
		var lines = new StringBuf();
		for (name => count in counts) {
			var short = name.substr(name.lastIndexOf(".") + 1);
			if (short == "HeroGameObject" || short == "HeroGameObjectOwner") heroes += count;
			else if (short == "NPCGameObject") npcs += count;
			else if (short.indexOf("Projectile") >= 0) projectiles += count;
			else if (short.indexOf("Effect") >= 0) effects += count;
			lines.add(t + "," + name + "," + count + "\n");
		}
		objects.writeString(lines.toString());
		objects.flush();
		var key = "";
		var live = "";
		if (floor != null) {
			key = floor.mCurrentMapNodeId + "/" + floor.mCurrentFloorNum;
			var manager = floor.mEffectManager;
			if (manager != null) {
				var n:Int = manager.mManagedEffects != null ? manager.mManagedEffects.size : 0;
				if (manager.mOutstandingEffects != null) for (_ in manager.mOutstandingEffects.keys()) n++;
				live = "" + n;
			}
			if (key != floorKey) {
				note("FLOOR " + key + " tiles=" + floor.mTileLibraryPath + " heroes=" + heroes + " npcs=" + npcs + " frame_rate=" + openfl.Lib.current.stage.frameRate
					+ " render_threads=" + starling.rendering.RenderWorkers.threads);
			}
		}
		floorKey = key;
		slObjects = slShown = slMeshes = slFilters = 0;
		var starlingNow = starling.core.Starling.current;
		var juggling = "";
		if (starlingNow != null) {
			walk(starlingNow.stage, true);
			juggling = "" + starling.core.Starling.juggler._objects.length;
		}
		world = key + "," + heroes + "," + npcs + "," + projectiles + "," + effects + "," + live + "," + all.length + "," + slObjects + "," + slShown + "," + slMeshes + ","
			+ slFilters + "," + juggling + "," + sampleNative(t);
	}

	// Cached bitmaps OpenFL drew again (an object with filters or cacheAsBitmap whose content changed), per object
	// since the last native.csv sample
	static var cacheFile:FileOutput;
	static var cacheRenders:haxe.ds.ObjectMap<openfl.display.DisplayObject, Int>;
	static var cacheRendersSec = 0;

	/** Called by OpenFL's renderer (a hook of make_overlay.py) for each cached bitmap it draws again. **/
	public static function cacheBitmapRendered(object:openfl.display.DisplayObject, why:Int):Void {
		if (cacheRenders == null) return;
		cacheRendersSec++;
		var count = cacheRenders.get(object);
		cacheRenders.set(object, count == null ? 1 : count + 1);
		cacheWhy.set(object, why);
	}

	// The last render of each: d its content was dirty, s software dirty, h hardware dirty, then the kind of the
	// cache (gl or sw) and of the renderer that asked (GL or SW), f with filters, and screen when the renderer
	// draws the stage, draw when it draws into a bitmap (BitmapData.draw, another object's cache)
	static var cacheWhy = new haxe.ds.ObjectMap<openfl.display.DisplayObject, Int>();

	static function whyText(why:Int):String {
		return ((why & 1) != 0 ? "d" : "") + ((why & 2) != 0 ? "s" : "") + ((why & 4) != 0 ? "h" : "") + ((why & 8) != 0 ? " gl" : " sw")
			+ ((why & 16) != 0 ? " GL" : " SW") + ((why & 32) != 0 ? " f" : "") + ((why & 64) != 0 ? " screen" : " draw");
	}

	// cache.csv: those objects by branch (the names from the stage down, the middle left out when long), class,
	// filters and the reason of the last render
	@:access(openfl.display.DisplayObject)
	static function dumpCacheRenders(t:String):Void {
		var rows = new Map<String, Array<Int>>();
		for (object in cacheRenders.keys()) {
			var labels = [];
			var parent:openfl.display.DisplayObject = object.parent;
			while (parent != null && parent.parent != null) {
				labels.unshift(nativeLabel(parent));
				parent = parent.parent;
			}
			var type = Type.getClass(object);
			var filters = "";
			if (object.__filters != null) {
				for (filter in object.__filters) {
					var name = Type.getClassName(Type.getClass(filter));
					filters += (filters == "" ? "" : "+") + name.substr(name.lastIndexOf(".") + 1);
				}
			}
			var why = cacheWhy.get(object);
			// the top of the path, then its end: what holds the object matters as much as where it hangs
			var path = labels.length <= 7 ? labels.join("/") : labels.slice(0, 4).join("/") + "/../" + labels.slice(labels.length - 3).join("/");
			var key = "stage/" + path + "," + (type == null ? "?" : Type.getClassName(type)) + "," + filters + ","
				+ whyText(why == null ? 0 : why);
			var row = rows.get(key);
			if (row == null) {
				row = [0, 0];
				rows.set(key, row);
			}
			row[0]++;
			row[1] += cacheRenders.get(object);
		}
		var lines = new StringBuf();
		for (key => row in rows) lines.add(t + "," + key + "," + row[0] + "," + row[1] + "\n");
		cacheFile.writeString(lines.toString());
		cacheFile.flush();
		cacheRenders = new haxe.ds.ObjectMap();
		cacheWhy = new haxe.ds.ObjectMap();
	}

	static var natObjects = 0;
	static var natShown = 0;
	static var natText = 0;
	static var natFilters = 0;
	static var natUnderHidden = 0; // objects below an invisible container
	static var natRows:Map<String, Array<Int>>;
	static var natSamples = 0;

	// A name the player or the game gave, else the class: instance names count up
	static function nativeLabel(object:openfl.display.DisplayObject):String {
		var name = object.name;
		if (name != null && name != "" && !StringTools.startsWith(name, "instance")) return name;
		var type = Type.getClass(object);
		return type == null ? "?" : Type.getClassName(type);
	}

	@:access(openfl.display.DisplayObject)
	static function walkNative(object:openfl.display.DisplayObject, shown:Bool, branch:String, depth:Int, underHidden:Bool = false):Void {
		natObjects++;
		if (underHidden) natUnderHidden++;
		shown = shown && object.visible && object.alpha != 0;
		var filtered = shown && object.__filters != null && object.__filters.length > 0;
		if (shown) {
			natShown++;
			if (filtered) natFilters++;
			if (Std.isOfType(object, openfl.text.TextField)) natText++;
		}
		if (natRows != null) {
			var type = Type.getClass(object);
			var key = branch + "," + (type == null ? "?" : Type.getClassName(type));
			var row = natRows.get(key);
			if (row == null) {
				row = [0, 0, 0];
				natRows.set(key, row);
			}
			row[0]++;
			if (shown) row[1]++;
			if (filtered) row[2]++;
		}
		var container = Std.downcast(object, openfl.display.DisplayObjectContainer);
		if (container != null) {
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				if (child != null) walkNative(child, shown, depth < 3 ? branch + "/" + nativeLabel(child) : branch, depth + 1, underHidden || !object.visible);
			}
		}
	}

	// OpenFL's own display list: objects, those shown, text fields and filtered objects shown, objects below an
	// invisible container; every fifth second,
	// native.csv gets them by branch (three levels of names under the stage) and class
	static function sampleNative(t:String):String {
		natObjects = natShown = natText = natFilters = natUnderHidden = 0;
		natRows = natSamples++ % 5 == 0 ? new Map() : null;
		walkNative(openfl.Lib.current.stage, true, "stage", 0);
		if (natRows != null) {
			var lines = new StringBuf();
			for (key => row in natRows) lines.add(t + "," + key + "," + row[0] + "," + row[1] + "," + row[2] + "\n");
			native.writeString(lines.toString());
			native.flush();
			natRows = null;
			dumpCacheRenders(t);
		}
		var renders = cacheRendersSec;
		cacheRendersSec = 0;
		return natObjects + "," + natShown + "," + natText + "," + natFilters + "," + natUnderHidden + "," + renders;
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
	static var zoomBack:Bool = false;
	static var zoomShot:Bool = false;

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
			case "zoom":
				// zoom:<factor>:<in>:<hold>:<out>[:<shot>] tweens the camera as an attack's zoom action does, in seconds,
				// with a screenshot of that name during the hold
				var camera = (cast facade : facade.DBFacade).camera;
				var zoomIn = Std.parseFloat(step[2]);
				var zoomHold = Std.parseFloat(step[3]);
				var zoomOut = Std.parseFloat(step[4]);
				if (stepFrames == 1) {
					zoomBack = false;
					zoomShot = false;
					camera.tweenZoom(zoomIn, Std.parseFloat(step[1]));
				} else if (step.length > 5 && !zoomShot && elapsed >= zoomIn + 0.3) {
					zoomShot = true;
					note("SHOT " + step[5]);
				} else if (!zoomBack && elapsed >= zoomIn + zoomHold) {
					zoomBack = true;
					camera.tweenToDefaultZoom(zoomOut);
				} else if (elapsed >= zoomIn + zoomHold + zoomOut) {
					nextStep();
				}
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
			case "saturate":
				// saturate:<percent> greys the scene graph's layers as the revive state does (25 when the hero dies, 100 back)
				(cast facade : facade.DBFacade).sceneGraphManager.saturateLayers(Std.parseFloat(step[1]), [50, 105]);
				nextStep();
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
