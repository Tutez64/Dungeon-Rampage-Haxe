package starling.rendering;

import cpp.vm.Gc;
import flash.geom.Matrix;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.MeshBatch;
import starling.filters.FragmentFilter;
import starling.rendering.RenderRecording.DeferredRender;
import starling.rendering.RenderRecording.ParallelChildren;
import starling.rendering.RenderRecording.RenderFork;
import starling.rendering.RenderRecording.RenderTask;
import starling.styles.MultiAtlasStyle;
import starling.utils.MatrixUtil;
import sys.thread.Lock;
import sys.thread.Mutex;
import sys.thread.Thread;

/**
	Walks parts of the display tree on other threads. A container with `parallel` set hands ranges of
	its children to the threads, each with a `RecordingPainter` that keeps its batches instead of
	drawing them, then the main painter draws the recordings in the children's order (`replay`). A
	filter met on the way has its target recorded as a task of its own, and its passes are run by the
	main thread, which alone talks to the context. What a recording thread cannot render is left to
	the main thread too, at its place in the order: a mask, an object whose class is not listed in
	`safeClasses`, a mesh whose style is not in `safeStyles`, a batch drawn on its own.

	The children are handed over as the frame starts, before the main thread walks the tree
	(`prefork`): the threads then work while the main thread draws what comes first. The state a
	container will be rendered with is worked out from its ancestors and checked when the main thread
	reaches it; when it differs the threads' work is dropped and the container renders on its own.

	`DRH_RENDER_THREADS`, or the launch argument `--render-threads`, sets the number of threads, 0 for none;
	without them there are `DEFAULT_THREADS`, or none on a single processor. Other variables, for trials:
	`DRH_RENDER_HUD=0` leaves the HUD to the main thread, `DRH_RENDER_SPIN_US` has an idle thread look for
	work that long before it sleeps, `DRH_RENDER_MIN_CHILDREN` sets the fewest children handed over,
	`DRH_RENDER_SAFE` adds class names to `safeClasses`, `DRH_RENDER_DEBUG` logs every 600 frames what the
	threads did and the classes left to the main thread, `DRH_RENDER_DUMP=<n>` logs the tree at the nth
	frame, `DRH_RENDER_VERIFY` has the main thread record every range again and logs where the two
	recordings differ.
**/
@:access(starling.rendering.Painter)
@:access(starling.rendering.IndexData)
@:access(starling.rendering.VertexData)
@:access(starling.display.DisplayObject)
@:access(starling.display.DisplayObjectContainer)
@:access(starling.display.Mesh)
@:access(starling.filters.FragmentFilter)
@:cppFileCode('
#include <atomic>
#include <chrono>
#include <thread>
#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__) || defined(_M_IX86)
#include <immintrin.h>
#define STARLING_CPU_PAUSE() _mm_pause()
#else
#define STARLING_CPU_PAUSE() ((void)0)
#endif
namespace {
std::atomic<int> sQueued(0);
std::atomic<int> sSleepers(0);
std::atomic<int> sPending[64];
std::atomic_flag sLock = ATOMIC_FLAG_INIT;
inline void lockQueue() {
	while (sLock.test_and_set(std::memory_order_acquire)) STARLING_CPU_PAUSE();
}
inline void unlockQueue() {
	sLock.clear(std::memory_order_release);
}
bool spinForWork(int micros) {
	auto end = std::chrono::steady_clock::now() + std::chrono::microseconds(micros);
	for (;;) {
		for (int i = 0; i < 64; i++) {
			if (sQueued.load(std::memory_order_relaxed) > 0) return true;
			STARLING_CPU_PAUSE();
		}
		if (std::chrono::steady_clock::now() >= end) return false;
	}
}
}
')
class RenderWorkers {
	public static inline final MAX_GROUPS = 64;

	/** Measured on 2, 4 and 8 cores: one thread already gives most of the gain, three give all of it, and each
		one more only ends one more batch per container. **/
	public static inline final DEFAULT_THREADS = 3;

	/** The threads besides the main one, 0 when the tree is walked by the main thread alone. **/
	public static var threads(default, null):Int = 0;

	/** A container with fewer children than this is walked by the main thread. **/
	public static var minChildren:Int = 2;

	/** How long an idle thread looks for work before it sleeps, in microseconds. **/
	public static var spinMicros:Int = 0;

	public static var statForks:Int = 0;
	public static var statTasks:Int = 0;
	public static var statInline:Int = 0;
	public static var statDeferred:Int = 0;
	public static var statBatches:Int = 0;
	public static var statPreforks:Int = 0;
	public static var statMismatches:Int = 0;
	public static var statWait:Float = 0;
	public static var statHelp:Float = 0;
	public static var statShort:Int = 0;
	public static var statVerified:Int = 0;
	public static var statDiffers:Int = 0;
	public static var statUnverified:Int = 0;

	static var initialised:Bool = false;

	static var debug:Bool = false;

	static var hud:Bool = true;

	/** Whether the main thread records every range again, to compare. **/
	static var verify:Bool = false;

	/** Whether the main thread is recording for `verify`: a filter's target is then recorded in place. **/
	static var verifying:Bool = false;

	static var differencesLogged:Int = 0;

	static var mainPainter:Painter;

	/** The main thread's own recording painter at 0, then one per thread. **/
	static final painters:Array<RecordingPainter> = [];

	/** The tasks waiting for a thread, the last one queued taken first. Guarded by a spin lock: a thread
		that slept on a mutex here cost the main thread more than the tasks saved. **/
	static final stack:Array<RenderTask> = [for (i in 0...1024) null];

	static var top:Int = 0;

	/** Where a thread that found nothing for `spinMicros` sleeps. **/
	static var wake:Lock;

	/** The containers whose children are handed over as the frame starts. **/
	static final roots:Array<DisplayObjectContainer> = [];

	static final forkPool:Array<RenderFork> = [];

	static var forkUsed:Int = 0;

	/** The slots of `sPending` taken since the frame started. **/
	static var groupsUsed:Int = 0;

	static final chain:Array<DisplayObject> = [];

	static final scratch:Matrix = new Matrix();

	static var dumpAt:Int = 0;

	/** The classes whose render was read for what it shares between threads. A class that only inherits
		its render is not listed for that: a subclass may come from a mod. **/
	static final safeClasses:Map<String, Bool> = [
		"starling.display.DisplayObjectContainer" => true,
		"starling.display.Sprite" => true,
		"starling.display.Mesh" => true,
		"starling.display.Quad" => true,
		"starling.display.Image" => true,
		"starling.display.MovieClip" => true,
		"starling.display.MeshBatch" => true,
		"starling.extensions.animate.Symbol" => true,
		"starling.extensions.animate.Animation" => true,
		"brain.starling.StarlingScenerySprite" => true,
		"brain.starling.StarlingSceneryImage" => true,
		"starling.StarlingView" => true,
		"brain.starling.swfConverter.BakedRoot" => true,
		"brain.starling.swfConverter.BakedImage" => true,
		"brain.starling.swfConverter.BakedGlyphText" => true,
		"uI.hud.starlingConverted.StarlingBarImage" => true,
		"uI.hud.starlingConverted.StarlingGlyphText" => true,
		"uI.hud.starlingConverted.StarlingSweepMesh" => true,
		"uI.hud.starlingConverted.ArtDisplay" => true,
		"uI.hud.starlingConverted.StatesView" => true,
		"uI.hud.starlingConverted.TimelineView" => true,
		"uI.hud.starlingConverted.StarlingText" => true,
	];

	/** The styles whose batching was read for what it shares between threads. **/
	static final safeStyles:Map<String, Bool> = [
		"starling.styles.MeshStyle" => true,
		"starling.styles.MultiAtlasStyle" => true,
		"starling.styles.DistanceFieldStyle" => true,
		"starling.extensions.animate.styles.ColorTransformStyle" => true,
		"starling.extensions.animate.styles.MaskColorTransformStyle" => true,
		"starling.extensions.animate.styles.MaskStyle" => true,
		"uI.hud.starlingConverted.StarlingColorStyle" => true,
	];

	static final debugMutex:Mutex = new Mutex();

	static final unsafeSeen:Map<String, Int> = [];

	static var failure:Dynamic = null;

	static var failures:Int = 0;

	static var debugFrames:Int = 0;

	static function init(painter:Painter) {
		var wanted = Std.parseInt(Std.string(Sys.getEnv("DRH_RENDER_THREADS")));
		if (wanted == null) {
			var args = Sys.args();
			var at = args.indexOf("--render-threads");
			if (at >= 0 && at + 1 < args.length) {
				wanted = Std.parseInt(args[at + 1]);
			}
		}
		if (wanted == null) {
			wanted = defaultThreads();
		}
		if (wanted <= 0) {
			return;
		}
		if (wanted > MAX_GROUPS - 1) {
			wanted = MAX_GROUPS - 1;
		}
		var spin = Std.parseInt(Std.string(Sys.getEnv("DRH_RENDER_SPIN_US")));
		if (spin != null && spin >= 0) {
			spinMicros = spin;
		}
		var min = Std.parseInt(Std.string(Sys.getEnv("DRH_RENDER_MIN_CHILDREN")));
		if (min != null && min > 0) {
			minChildren = min;
		}
		debug = Sys.getEnv("DRH_RENDER_DEBUG") != null;
		verify = Sys.getEnv("DRH_RENDER_VERIFY") != null;
		hud = Sys.getEnv("DRH_RENDER_HUD") != "0";
		var dump = Std.parseInt(Std.string(Sys.getEnv("DRH_RENDER_DUMP")));
		if (dump != null) {
			dumpAt = dump;
		}
		var more = Sys.getEnv("DRH_RENDER_SAFE");
		if (more != null) {
			for (name in more.split(",")) {
				safeClasses[StringTools.trim(name)] = true;
			}
		}
		mainPainter = painter;
		wake = new Lock();
		// the shared quad indices, filled for the largest batch: no thread grows them
		new IndexData().ensureQuadDataCapacity(204000);
		for (i in 0...wanted + 1) {
			painters.push(new RecordingPainter(painter.stage3D));
		}
		threads = wanted;
		for (i in 0...wanted) {
			var own = painters[i + 1];
			Thread.create(() -> workerLoop(own));
		}
		trace("RenderWorkers: " + wanted + " threads" + (verify ? ", verifying" : ""));
	}

	/** The threads made when none are asked for. **/
	static function defaultThreads():Int {
		var processors:Int = untyped __cpp__("(int)std::thread::hardware_concurrency()");
		return processors >= 2 ? DEFAULT_THREADS : 0;
	}

	static function canFork(painter:Painter):Bool {
		return threads != 0
			&& painter == mainPainter
			&& !painter._state.is3D
			&& MultiAtlasStyle.maxAtlases != 0;
	}

	/** Whether a recording thread may render this object itself. **/
	static function isSafe(object:DisplayObject):Bool {
		var state = object._parallelState;
		if (state == 0) {
			var name = Type.getClassName(Type.getClass(object));
			state = safeClasses.exists(name) ? 1 : 2;
			object._parallelState = state;
			if (state == 2 && debug) {
				noteUnsafe(name);
			}
		}
		return state == 1;
	}

	/** Whether a recording thread may batch a mesh whose style is of this class. **/
	public static function isSafeStyle(type:Dynamic):Bool {
		var name = Type.getClassName(type);
		if (safeStyles.exists(name)) {
			return true;
		}
		if (debug) {
			noteUnsafe(name);
		}
		return false;
	}

	static function noteUnsafe(name:String) {
		debugMutex.acquire();
		unsafeSeen[name] = (unsafeSeen.exists(name) ? unsafeSeen[name] : 0) + 1;
		debugMutex.release();
	}

	/** Called by `DisplayObjectContainer.render` on a recording painter, for each child it is about to render:
		true when the child was left to the main thread instead. **/
	public static function defers(painter:Painter, child:DisplayObject):Bool {
		var recorder:RecordingPainter = cast painter;
		if (child._mask != null || !isSafe(child)) {
			recorder.deferChild(child);
			return true;
		}
		recorder.debugObject = child;
		return false;
	}

	/** Leaves an object a recording painter was asked to render to the main thread. **/
	public static function deferObject(painter:Painter, object:DisplayObject) {
		(cast painter : RecordingPainter).deferObject(object);
	}

	/** Called by `FragmentFilter.render` on a recording painter: the passes need the context, so the main
		thread runs them, over the target recorded here. **/
	public static function recordFilter(filter:FragmentFilter, painter:Painter) {
		var recorder:RecordingPainter = cast painter;
		var target = filter._target;
		if (target.is3D || (filter._cached && !filter._cacheRequested)) {
			recorder.deferFilter(filter, null);
		} else {
			var sub = recorder.allocRecording();
			recorder.deferFilter(filter, sub);
			recorder.recordTarget(target, sub);
		}
	}

	/** Draws what a thread recorded, in its order. **/
	public static function replay(painter:Painter, rec:RenderRecording) {
		var batches = rec.batches;
		var state = painter._state;
		for (i in 0...batches.length) {
			var batch = batches[i];
			if (batch != null) {
				painter.finishMeshBatch();
				painter.drawBatch(batch);
				continue;
			}
			var item = rec.deferred[i];
			painter.pushState();
			state._modelviewMatrix.setTo(item.a, item.b, item.c, item.d, item.tx, item.ty);
			state._alpha = item.alpha;
			state.blendMode = item.blendMode;
			if (item.kind == DeferredRender.FILTER) {
				var filter = item.filter;
				filter._recorded = item.sub;
				try {
					filter.render(painter);
				} catch (error:Dynamic) {
					filter._recorded = null;
					throw error;
				}
				filter._recorded = null;
			} else if (item.kind == DeferredRender.CHILD) {
				// as DisplayObjectContainer.render does for a child
				var child = item.object;
				var mask = child._mask;
				var filter = child._filter;
				painter.setStateTo(child.transformationMatrix, child.alpha, child.blendMode);
				if (mask != null) {
					painter.drawMask(mask, child);
				}
				if (filter != null) {
					filter.render(painter);
				} else {
					child.render(painter);
				}
				if (mask != null) {
					painter.eraseMask(mask, child);
				}
			} else {
				item.object.render(painter);
			}
			painter.popState();
		}
		var exclusions = rec.exclusions;
		for (i in 0...exclusions.length) {
			painter.excludeFromCache(exclusions[i]);
		}
	}

	/** Renders the children of `container` from `start` to `end` on a recording painter, as
		`DisplayObjectContainer.render` does without the cache. **/
	static function renderChildRange(container:DisplayObjectContainer, painter:RecordingPainter, start:Int, end:Int) {
		var children = container._children;
		var frameID = painter.frameID;
		var changed = container._lastParentOrSelfChangeFrameID == frameID;
		var first = true;
		painter.pushState();
		for (i in start...end) {
			var child = children[i];
			if (!child._hasVisibleArea) {
				continue;
			}
			if (first) {
				first = false;
			} else {
				painter.restoreState();
			}
			if (changed) {
				child._lastParentOrSelfChangeFrameID = frameID;
			}
			if (child._mask != null || !isSafe(child)) {
				painter.deferChild(child);
				continue;
			}
			painter.debugObject = child;
			painter.setStateTo(child.transformationMatrix, child.alpha, child.blendMode);
			var filter = child._filter;
			if (filter != null) {
				filter.render(painter);
			} else {
				child.render(painter);
			}
		}
		painter.popState();
	}

	/** Called by `DisplayObjectContainer.render` for a container with `parallel` set: renders its children
		on the threads. False when it does not: the container renders them. **/
	public static function renderChildren(container:DisplayObjectContainer, painter:Painter):Bool {
		if (threads == 0) {
			return false;
		}
		var info = container.parallel;
		if (info.noCache && !hud) {
			return false;
		}
		if (!info.registered && painter == mainPainter) {
			info.registered = true;
			roots.push(container);
		}
		var fork = info.fork;
		if (fork != null) {
			info.fork = null;
			if (join(fork, container, painter)) {
				return true;
			}
		}
		if (container.numChildren < minChildren || !canFork(painter)) {
			return false;
		}
		var state = painter._state;
		fork = makeFork(container, painter.frameID, state._modelviewMatrix, state._alpha, state._blendMode);
		if (fork == null) {
			return false;
		}
		statForks++;
		pushFork(fork);
		return join(fork, container, painter);
	}

	/** Hands the children of the registered containers to the threads. Called by Starling before it renders the stage. **/
	public static function prefork(painter:Painter, stage:DisplayObject) {
		if (!initialised) {
			initialised = true;
			init(painter);
		}
		if (threads == 0 || painter != mainPainter) {
			return;
		}
		finishForks();
		forkUsed = 0;
		groupsUsed = 0;
		var margin = verify ? 64 : 4;
		for (p in painters) {
			if (p.exhausted) {
				statShort++;
			}
			p.resetRecordings(margin);
		}
		if (debug && ++debugFrames >= 600) {
			debugFrames = 0;
			trace("RenderWorkers: " + takeStats());
		}
		if (failure != null) {
			var error = failure;
			failure = null;
			trace("RenderWorkers: a task failed: " + Std.string(error));
		}
		var index = roots.length - 1;
		while (index >= 0) {
			var root = roots[index];
			var info = root.parallel;
			info.fork = null;
			if (root.stage != stage) {
				// off the stage: it registers again the next time it is rendered
				info.registered = false;
				info.candidate = false;
				roots.splice(index, 1);
			}
			index--;
		}
		if (dumpAt > 0 && --dumpAt == 0) {
			var lines:Array<String> = [];
			dumpTree(stage, 0, lines);
			trace("RenderWorkers tree:\n" + lines.join("\n"));
		}
		if (!canFork(painter)) {
			return;
		}
		var frameID = painter.frameID;
		var first = forkUsed;
		for (root in roots) {
			root.parallel.candidate = root.numChildren >= minChildren && (hud || !root.parallel.noCache);
		}
		for (root in roots) {
			var info = root.parallel;
			if (!info.candidate) {
				continue;
			}
			chain.resize(0);
			var node:DisplayObject = root;
			while (node != null && node != stage) {
				if (!node.visible || node.alpha == 0 || node._filter != null || node._mask != null || node.is3D) {
					break;
				}
				if (node != root) {
					// inside a container handed over too: its threads walk this one
					var outer = Std.downcast(node, DisplayObjectContainer);
					if (outer != null && outer.parallel != null && outer.parallel.candidate) {
						break;
					}
				}
				chain.push(node);
				node = node.parent;
			}
			if (node != stage) {
				continue;
			}
			// the state the painter will have in the container's render: what
			// DisplayObjectContainer.render makes of each ancestor, from the stage down
			var matrix = scratch;
			matrix.identity();
			var alpha = 1.0;
			var blendMode = "normal";
			var i = chain.length - 1;
			while (i >= 0) {
				var ancestor = chain[i];
				MatrixUtil.prependMatrix(matrix, ancestor.transformationMatrix);
				var factor = ancestor.alpha;
				if (factor != 1) {
					alpha *= factor;
				}
				var blend = ancestor.blendMode;
				if (blend != "auto") {
					blendMode = blend;
				}
				i--;
			}
			chain.resize(0);
			if (info.prepare != null) {
				info.prepare(blendMode);
				info.setPrepared();
			}
			var fork = makeFork(root, info.noCache ? (0 : UInt) : frameID, matrix, alpha, blendMode);
			if (fork == null) {
				break;
			}
			info.fork = fork;
			statPreforks++;
		}
		// the first container's first children on top: the main thread reaches them first
		var last = forkUsed - 1;
		while (last >= first) {
			pushFork(forkPool[last]);
			last--;
		}
	}

	static function makeFork(container:DisplayObjectContainer, frameID:UInt, matrix:Matrix, alpha:Float, blendMode:String):RenderFork {
		var count = container.numChildren;
		var chunks = threads + 1;
		var per = Math.ceil(count / chunks);
		var floor = minChildren >> 1;
		if (floor < 1) {
			floor = 1;
		}
		if (per < floor) {
			per = floor;
		}
		chunks = Math.ceil(count / per);
		if (chunks < 1 || groupsUsed + chunks > MAX_GROUPS) {
			return null;
		}
		var fork:RenderFork;
		if (forkUsed < forkPool.length) {
			fork = forkPool[forkUsed];
		} else {
			fork = new RenderFork();
			forkPool.push(fork);
		}
		forkUsed++;
		fork.count = chunks;
		fork.container = container;
		fork.numChildren = count;
		fork.frameID = frameID;
		fork.a = matrix.a;
		fork.b = matrix.b;
		fork.c = matrix.c;
		fork.d = matrix.d;
		fork.tx = matrix.tx;
		fork.ty = matrix.ty;
		fork.alpha = alpha;
		fork.blendMode = blendMode;
		fork.joined = false;
		var own = painters[0];
		var start = 0;
		for (i in 0...chunks) {
			var end = i == chunks - 1 ? count : start + per;
			var group = groupsUsed++;
			var task = own.allocTask();
			task.kind = RenderTask.CHILDREN;
			task.container = container;
			task.target = null;
			task.start = start;
			task.end = end;
			task.frameID = frameID;
			task.group = group;
			task.a = matrix.a;
			task.b = matrix.b;
			task.c = matrix.c;
			task.d = matrix.d;
			task.tx = matrix.tx;
			task.ty = matrix.ty;
			task.alpha = alpha;
			task.blendMode = blendMode;
			task.rec = own.allocRecording();
			fork.tasks[i] = task;
			untyped __cpp__("sPending[{0}].store(1)", group);
			start = end;
		}
		return fork;
	}

	static function pushFork(fork:RenderFork) {
		var own = painters[0];
		var pixelSize = mainPainter.pixelSize;
		for (p in painters) {
			p.pixelSize = pixelSize;
		}
		var last = fork.count - 1;
		while (last >= 0) {
			if (!push(fork.tasks[last])) {
				run(fork.tasks[last], own);
			}
			last--;
		}
		statTasks += fork.count;
	}

	/** Draws what the threads made of a container's children. False when the painter is not in the state they
		started from: their work is dropped and the container renders as if never handed over. **/
	static function join(fork:RenderFork, container:DisplayObjectContainer, painter:Painter):Bool {
		var state = painter._state;
		var matrix = state._modelviewMatrix;
		var valid = painter == mainPainter
			&& fork.container == container
			&& !fork.joined
			&& !state.is3D
			&& fork.numChildren == container.numChildren
			&& fork.frameID == painter.frameID
			&& fork.alpha == state._alpha
			&& fork.blendMode == state._blendMode
			&& fork.a == matrix.a
			&& fork.b == matrix.b
			&& fork.c == matrix.c
			&& fork.d == matrix.d
			&& fork.tx == matrix.tx
			&& fork.ty == matrix.ty;
		if (!valid) {
			// the threads are in the children: nothing may walk or change them until they are out
			if (!fork.joined && fork.container == container) {
				fork.joined = true;
				for (i in 0...fork.count) {
					waitFor(fork.tasks[i].group);
				}
			}
			statMismatches++;
			return false;
		}
		fork.joined = true;
		painter.excludeFromCache(container);
		for (i in 0...fork.count) {
			var task = fork.tasks[i];
			waitFor(task.group);
			if (verify) {
				verifyTask(task);
			}
			replay(painter, task.rec);
		}
		return true;
	}

	/** Waits for the threads to be out of the containers handed over and never rendered. Called by Starling once
		the stage is rendered. **/
	public static function finishForks() {
		for (index in 0...forkUsed) {
			var fork = forkPool[index];
			if (!fork.joined) {
				fork.joined = true;
				for (i in 0...fork.count) {
					waitFor(fork.tasks[i].group);
				}
			}
		}
	}

	/** Whether a filter's target is worth a task of its own: only while a thread may be free. **/
	public static function shouldSpawn():Bool {
		if (verifying) {
			return false;
		}
		var queued:Int = untyped __cpp__("sQueued.load(std::memory_order_relaxed)");
		return queued < threads;
	}

	/** Queues a task made by a recording thread. False when the queue is full: the caller does the work. **/
	public static function spawn(task:RenderTask):Bool {
		untyped __cpp__("sPending[{0}].fetch_add(1)", task.group);
		if (push(task)) {
			return true;
		}
		untyped __cpp__("sPending[{0}].fetch_sub(1)", task.group);
		return false;
	}

	static function push(task:RenderTask):Bool {
		untyped __cpp__("lockQueue()");
		if (top == stack.length) {
			untyped __cpp__("unlockQueue()");
			return false;
		}
		stack[top++] = task;
		untyped __cpp__("sQueued.fetch_add(1)");
		untyped __cpp__("unlockQueue()");
		var sleepers:Int = untyped __cpp__("sSleepers.load()");
		if (sleepers > 0) {
			wake.release();
		}
		return true;
	}

	static function pop():RenderTask {
		var queued:Int = untyped __cpp__("sQueued.load(std::memory_order_relaxed)");
		if (queued <= 0) {
			return null;
		}
		var task:RenderTask = null;
		untyped __cpp__("lockQueue()");
		if (top > 0) {
			task = stack[--top];
			stack[top] = null;
			untyped __cpp__("sQueued.fetch_sub(1)");
		}
		untyped __cpp__("unlockQueue()");
		return task;
	}

	static function waitFor(group:Int) {
		var own = painters[0];
		var pending:Int = untyped __cpp__("sPending[{0}].load()", group);
		if (pending <= 0) {
			return;
		}
		var started = debug ? haxe.Timer.stamp() : 0.0;
		while (true) {
			pending = untyped __cpp__("sPending[{0}].load()", group);
			if (pending <= 0) {
				if (debug) {
					statWait += haxe.Timer.stamp() - started;
				}
				return;
			}
			var task = pop();
			if (task != null) {
				if (debug) {
					var before = haxe.Timer.stamp();
					run(task, own);
					statHelp += haxe.Timer.stamp() - before;
				} else {
					run(task, own);
				}
			} else {
				Gc.safePoint();
				untyped __cpp__("STARLING_CPU_PAUSE()");
			}
		}
	}

	static function workerLoop(painter:RecordingPainter) {
		while (true) {
			var task = pop();
			if (task != null) {
				run(task, painter);
				continue;
			}
			Gc.enterGCFreeZone();
			var found:Bool = untyped __cpp__("spinForWork({0})", spinMicros);
			Gc.exitGCFreeZone();
			if (!found) {
				untyped __cpp__("sSleepers.fetch_add(1)");
				var queued:Int = untyped __cpp__("sQueued.load()");
				if (queued <= 0) {
					wake.wait();
				}
				untyped __cpp__("sSleepers.fetch_sub(1)");
			}
		}
	}

	static function run(task:RenderTask, painter:RecordingPainter) {
		try {
			painter.beginRecording(task);
			if (task.kind == RenderTask.CHILDREN) {
				renderChildRange(task.container, painter, task.start, task.end);
			} else {
				task.target.render(painter);
			}
			painter.endRecording();
		} catch (error:Dynamic) {
			if (failures < 3) {
				failures++;
				failure = Std.string(error) + " in " + describe(task.kind == RenderTask.CHILDREN ? task.container : task.target)
					+ (task.kind == RenderTask.CHILDREN ? " children " + task.start + "-" + task.end : " (filter target)")
					+ ", at " + describe(painter.debugObject);
			} else if (failure == null) {
				failure = error;
			}
			painter.abortRecording();
		}
		untyped __cpp__("sPending[{0}].fetch_sub(1)", task.group);
	}

	/** Records a range of children again on the main thread and compares the two recordings. **/
	static function verifyTask(task:RenderTask) {
		var own = painters[0];
		var again = own.allocTask();
		again.kind = task.kind;
		again.container = task.container;
		again.target = task.target;
		again.start = task.start;
		again.end = task.end;
		again.frameID = task.frameID;
		again.group = task.group;
		again.a = task.a;
		again.b = task.b;
		again.c = task.c;
		again.d = task.d;
		again.tx = task.tx;
		again.ty = task.ty;
		again.alpha = task.alpha;
		again.blendMode = task.blendMode;
		again.rec = own.allocRecording();
		verifying = true;
		try {
			own.beginRecording(again);
			renderChildRange(again.container, own, again.start, again.end);
			own.endRecording();
		} catch (error:Dynamic) {
			own.abortRecording();
			verifying = false;
			noteDifference(task, "the main thread's recording failed: " + Std.string(error));
			return;
		}
		verifying = false;
		for (p in painters) {
			if (p.exhausted) {
				// a mesh left to the main thread for want of a batch: the recordings differ by that alone
				statUnverified++;
				return;
			}
		}
		var difference = compare(task.rec, again.rec, "");
		if (difference == null) {
			statVerified++;
		} else {
			noteDifference(task, difference);
		}
	}

	static function noteDifference(task:RenderTask, text:String) {
		statDiffers++;
		if (differencesLogged < 20) {
			differencesLogged++;
			trace("RenderWorkers: recordings differ in " + describe(task.container) + " children " + task.start + "-" + task.end + ": " + text);
		}
	}

	/** Where two recordings of the same objects differ, or null. **/
	static function compare(a:RenderRecording, b:RenderRecording, path:String):String {
		if (a.batches.length != b.batches.length) {
			return path + a.batches.length + " items against " + b.batches.length;
		}
		for (i in 0...a.batches.length) {
			var at = path + "item " + i;
			var batchA = a.batches[i];
			var batchB = b.batches[i];
			if ((batchA == null) != (batchB == null)) {
				return at + ": a batch against something left to the main thread";
			}
			if (batchA != null) {
				var difference = compareBatches(batchA, batchB);
				if (difference != null) {
					return at + ": " + difference;
				}
				continue;
			}
			var itemA = a.deferred[i];
			var itemB = b.deferred[i];
			if (itemA.kind != itemB.kind || itemA.object != itemB.object || itemA.filter != itemB.filter) {
				return at + ": not the same object left to the main thread (" + describe(itemA.object) + " against " + describe(itemB.object) + ")";
			}
			if (itemA.a != itemB.a || itemA.b != itemB.b || itemA.c != itemB.c || itemA.d != itemB.d || itemA.tx != itemB.tx
				|| itemA.ty != itemB.ty || itemA.alpha != itemB.alpha || itemA.blendMode != itemB.blendMode) {
				return at + ": another state for " + describe(itemA.kind == DeferredRender.FILTER ? itemA.filter._target : itemA.object);
			}
			if ((itemA.sub == null) != (itemB.sub == null)) {
				return at + ": a filter's target recorded on one side only";
			}
			if (itemA.sub != null) {
				var difference = compare(itemA.sub, itemB.sub, at + " > ");
				if (difference != null) {
					return difference;
				}
			}
		}
		return null;
	}

	static function compareBatches(a:MeshBatch, b:MeshBatch):String {
		if (a._style.type != b._style.type) {
			return "styles " + Type.getClassName(a._style.type) + " against " + Type.getClassName(b._style.type);
		}
		if (a.blendMode != b.blendMode) {
			return "blend modes " + a.blendMode + " against " + b.blendMode;
		}
		var dataA = a._vertexData;
		var dataB = b._vertexData;
		if (dataA._numVertices != dataB._numVertices || a._indexData.numIndices != b._indexData.numIndices) {
			return dataA._numVertices + " vertices and " + a._indexData.numIndices + " indices against " + dataB._numVertices + " and "
				+ b._indexData.numIndices;
		}
		if (a._style.texture != b._style.texture) {
			return "another texture";
		}
		var bytesA:haxe.io.Bytes = cast dataA._rawData;
		var bytesB:haxe.io.Bytes = cast dataB._rawData;
		var size = dataA._vertexSize;
		for (i in 0...dataA._numVertices * size) {
			if (bytesA.get(i) != bytesB.get(i)) {
				return "vertex " + Std.int(i / size) + " differs at byte " + (i % size) + " of " + size;
			}
		}
		var indexA = a._indexData;
		var indexB = b._indexData;
		if (indexA._useQuadLayout != indexB._useQuadLayout) {
			return "quad indices on one side only";
		}
		if (!indexA._useQuadLayout) {
			var rawA:haxe.io.Bytes = cast indexA._rawData;
			var rawB:haxe.io.Bytes = cast indexB._rawData;
			for (i in 0...indexA._numIndices * 2) {
				if (rawA.get(i) != rawB.get(i)) {
					return "index " + (i >> 1) + " differs";
				}
			}
		}
		return null;
	}

	static function describe(object:DisplayObject):String {
		var text = "";
		var depth = 0;
		while (object != null && depth < 8) {
			text += (depth == 0 ? "" : " < ") + Type.getClassName(Type.getClass(object)) + (object.name != null ? "'" + object.name + "'" : "");
			object = object.parent;
			depth++;
		}
		return text == "" ? "null" : text;
	}

	static function dumpTree(object:DisplayObject, depth:Int, lines:Array<String>) {
		var container = Std.downcast(object, DisplayObjectContainer);
		var text = StringTools.rpad("", " ", depth * 2) + Type.getClassName(Type.getClass(object));
		if (object.name != null) {
			text += " '" + object.name + "'";
		}
		if (container != null) {
			text += " children=" + container.numChildren + " inside=" + countInside(container);
			if (container.parallel != null) {
				text += " PARALLEL";
			}
		}
		if (!object.visible) {
			text += " hidden";
		}
		if (object.filter != null) {
			text += " filter=" + Type.getClassName(Type.getClass(object.filter));
		}
		if (object.mask != null) {
			text += " masked";
		}
		lines.push(text);
		if (container != null && depth < 4 && object.visible) {
			var shown = 0;
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				if (depth >= 2 && shown >= 12) {
					lines.push(StringTools.rpad("", " ", depth * 2 + 2) + "...");
					break;
				}
				shown++;
				dumpTree(child, depth + 1, lines);
			}
		}
	}

	static function countInside(container:DisplayObjectContainer):Int {
		var total = 0;
		for (i in 0...container.numChildren) {
			var child = container.getChildAt(i);
			total++;
			var inner = Std.downcast(child, DisplayObjectContainer);
			if (inner != null && child.visible) {
				total += countInside(inner);
			}
		}
		return total;
	}

	/** What the threads did since the last call, for a log. **/
	public static function takeStats():String {
		var text = "wait_ms=" + Math.round(statWait * 1000) + " help_ms=" + Math.round(statHelp * 1000) + " preforks=" + statPreforks
			+ " mismatches=" + statMismatches + " forks=" + statForks + " tasks=" + statTasks + " inline=" + statInline + " deferred="
			+ statDeferred + " batches=" + statBatches + " short=" + statShort;
		if (verify) {
			text += " verified=" + statVerified + " differ=" + statDiffers + " unverified=" + statUnverified;
		}
		statForks = statTasks = statInline = statDeferred = statBatches = statPreforks = statMismatches = statShort = 0;
		statVerified = statDiffers = statUnverified = 0;
		statWait = statHelp = 0;
		if (debug) {
			debugMutex.acquire();
			for (name => seen in unsafeSeen) {
				text += "\n  left to the main thread: " + name + " x" + seen;
			}
			unsafeSeen.clear();
			debugMutex.release();
		}
		return text;
	}
}
