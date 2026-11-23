package starling.rendering;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.MeshBatch;
import starling.filters.FragmentFilter;

/**
	What a thread other than the main one made of a part of the display tree: its batches, in order,
	and between them what only the main thread can render (see `RenderWorkers`).
**/
class RenderRecording {
	/** One entry per item: a finished batch, or null where `deferred` holds the item. **/
	public var batches:Array<MeshBatch> = [];

	public var deferred:Array<DeferredRender> = [];

	public var exclusions:Array<DisplayObject> = [];

	public function new() {}

	public function reset() {
		batches.resize(0);
		deferred.resize(0);
		exclusions.resize(0);
	}
}

/** An object the main thread renders itself, with the state the recording thread had reached. **/
class DeferredRender {
	public static inline final CHILD = 0;
	public static inline final FILTER = 1;
	public static inline final OBJECT = 2;

	public var kind:Int = 0;

	public var object:DisplayObject;

	public var filter:FragmentFilter;

	/** The filter's target, already recorded (null: the main thread renders the target too). **/
	public var sub:RenderRecording;

	public var a:Float = 1;
	public var b:Float = 0;
	public var c:Float = 0;
	public var d:Float = 1;
	public var tx:Float = 0;
	public var ty:Float = 0;
	public var alpha:Float = 1;
	public var blendMode:String;

	public function new() {}
}

/** A part of the tree to record: a range of a container's children, or a filter's target. **/
class RenderTask {
	public static inline final CHILDREN = 0;
	public static inline final TARGET = 1;

	public var kind:Int = 0;

	public var container:DisplayObjectContainer;

	public var start:Int = 0;

	public var end:Int = 0;

	public var target:DisplayObject;

	public var rec:RenderRecording;

	/** The slot of the count of tasks the main thread waits for before replaying `rec`. **/
	public var group:Int = 0;

	public var frameID:UInt = 0;

	public var a:Float = 1;
	public var b:Float = 0;
	public var c:Float = 0;
	public var d:Float = 1;
	public var tx:Float = 0;
	public var ty:Float = 0;
	public var alpha:Float = 1;
	public var blendMode:String;

	public function new() {}
}

/** The children of a container handed to the threads: its tasks, in the children's order. **/
class RenderFork {
	public var tasks:Array<RenderTask> = [];

	public var count:Int = 0;

	public var container:DisplayObjectContainer;

	public var numChildren:Int = 0;

	public var frameID:UInt = 0;

	/** The state the tasks started from, which the main painter must have when it draws them. **/
	public var a:Float = 1;
	public var b:Float = 0;
	public var c:Float = 0;
	public var d:Float = 1;
	public var tx:Float = 0;
	public var ty:Float = 0;
	public var alpha:Float = 1;
	public var blendMode:String;

	public var joined:Bool = false;

	public function new() {}
}

/** What `RenderWorkers` keeps about a container whose children its threads render (`DisplayObjectContainer.parallel`). **/
class ParallelChildren {
	/** What the container's `render` does before it renders the children, given the painter's blend mode:
		`RenderWorkers` calls it before the threads enter the children. **/
	public var prepare:String->Void;

	/** Whether the container's `render` reaches the children with the painter's cache off. **/
	public var noCache:Bool;

	/** The children as handed over for this frame, until the main painter reaches the container. **/
	public var fork:RenderFork;

	/** Whether the children are handed over as each frame starts. **/
	public var registered:Bool = false;

	public var candidate:Bool = false;

	var preparedFrame:Int = -1;

	public function new(prepare:String->Void = null, noCache:Bool = false) {
		this.prepare = prepare;
		this.noCache = noCache;
	}

	public function setPrepared() {
		preparedFrame = (starling.core.Starling.frameID : Int);
	}

	/** Whether `prepare` was called for this frame already. **/
	public function takePrepared():Bool {
		if (preparedFrame == (starling.core.Starling.frameID : Int)) {
			preparedFrame = -1;
			return true;
		}
		return false;
	}
}
