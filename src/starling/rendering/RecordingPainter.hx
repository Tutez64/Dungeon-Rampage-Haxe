package starling.rendering;

import flash.display.Stage3D;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.display.MeshBatch;
import starling.filters.FragmentFilter;
import starling.rendering.RenderRecording.DeferredRender;
import starling.rendering.RenderRecording.RenderTask;
import starling.styles.MeshStyle;
import starling.utils.MeshSubset;

/**
	The painter of a thread of `RenderWorkers`: it batches like a painter but draws nothing. Its finished
	batches, and what it leaves to the main thread, go to a `RenderRecording` in order.

	Its batches come from pools the main thread fills between frames, a list per style: making a batch
	makes an effect, which registers with the context and is not for another thread. A mesh that finds
	its pool empty is left to the main thread, and the pool is larger on the next frame.
**/
@:access(starling.display.Mesh)
class RecordingPainter extends Painter {
	static inline final POOL_MARGIN = 4;

	static inline final POOL_LIMIT = 1024;

	/** The last child given to this painter, to name where a task failed. **/
	public var debugObject:DisplayObject;

	/** Whether a mesh found its pool empty since `resetRecordings`. **/
	public var exhausted:Bool = false;

	var _rec:RenderRecording;

	var _recFrameID:UInt = 0;

	var _recGroup:Int = 0;

	var _current:MeshBatch;

	final _subset:MeshSubset = new MeshSubset();

	var _styleType:Dynamic;

	var _styleSafe:Bool = false;

	final _poolTypes:Array<Dynamic> = [];

	final _poolFree:Array<Array<MeshBatch>> = [];

	final _poolUsed:Array<Array<MeshBatch>> = [];

	/** The meshes that found a pool empty this frame, per pool. **/
	final _poolShort:Array<Int> = [];

	/** The styles a mesh came with and no pool is for yet. **/
	final _wanted:Array<Dynamic> = [];

	final _recPool:Array<RenderRecording> = [];

	var _recUsed:Int = 0;

	final _deferredPool:Array<DeferredRender> = [];

	var _deferredUsed:Int = 0;

	final _taskPool:Array<RenderTask> = [];

	var _taskUsed:Int = 0;

	public function new(stage3D:Stage3D) {
		super(stage3D);
		recording = true;
	}

	/** Gives back what the last frame recorded and fills the pools. Called by the main thread while no task runs. **/
	public function resetRecordings(margin:Int) {
		_recUsed = _deferredUsed = _taskUsed = 0;
		_current = null;
		exhausted = false;
		for (i in 0..._poolTypes.length) {
			var free = _poolFree[i];
			var used = _poolUsed[i];
			var needed = used.length + _poolShort[i] + margin;
			for (batch in used) {
				batch.clear();
				free.push(batch);
			}
			used.resize(0);
			_poolShort[i] = 0;
			fill(free, _poolTypes[i], needed);
		}
		for (type in _wanted) {
			var free:Array<MeshBatch> = [];
			_poolTypes.push(type);
			_poolFree.push(free);
			_poolUsed.push([]);
			_poolShort.push(0);
			fill(free, type, margin);
		}
		_wanted.resize(0);
	}

	static function fill(free:Array<MeshBatch>, type:Dynamic, needed:Int) {
		if (needed > POOL_LIMIT) {
			needed = POOL_LIMIT;
		}
		while (free.length < needed) {
			var batch = new MeshBatch();
			if (batch.style.type != type) {
				batch.setStyle(cast Type.createInstance(type, []), false);
			}
			free.push(batch);
		}
	}

	function takeBatch(type:Dynamic):MeshBatch {
		var types = _poolTypes;
		for (i in 0...types.length) {
			if (types[i] == type) {
				var free = _poolFree[i];
				if (free.length == 0) {
					_poolShort[i]++;
					exhausted = true;
					return null;
				}
				var batch = free.pop();
				_poolUsed[i].push(batch);
				return batch;
			}
		}
		if (_wanted.indexOf(type) < 0) {
			_wanted.push(type);
		}
		exhausted = true;
		return null;
	}

	override public function batchMesh(mesh:Mesh, subset:MeshSubset = null) {
		var type:Dynamic = mesh._style.type;
		if (type != _styleType) {
			_styleType = type;
			_styleSafe = RenderWorkers.isSafeStyle(type);
		}
		// a style the threads were not checked against, or no batch left: the main thread batches it
		if (!_styleSafe || !addMesh(mesh, type)) {
			deferObject(mesh);
		}
	}

	function addMesh(mesh:Mesh, type:Dynamic):Bool {
		var numVertices = mesh.numVertices;
		if (numVertices <= 0) {
			return true;
		}
		var batch = _current;
		// quad indices after vertices that are not all quads are read from IndexData's shared bytes through
		// their position, which is the main thread's: such a mesh starts a batch
		if (batch == null || !batch.canAddMesh(mesh, numVertices) || ((batch.numVertices & 3) != 0 && mesh._indexData.useQuadLayout)) {
			finishMeshBatch();
			batch = takeBatch(type);
			if (batch == null) {
				return false;
			}
			batch.blendMode = _state._blendMode;
			_current = batch;
		}
		var subset = _subset;
		subset.vertexID = subset.indexID = 0;
		subset.numVertices = numVertices;
		subset.numIndices = mesh.numIndices;
		batch.addMeshAt(mesh, -1, -1, _state._modelviewMatrix, _state._alpha, subset, false);
		return true;
	}

	override public function finishMeshBatch() {
		var batch = _current;
		if (batch != null) {
			_current = null;
			_rec.batches.push(batch);
			_rec.deferred.push(null);
			RenderWorkers.statBatches++;
		}
	}

	override public function excludeFromCache(object:DisplayObject) {
		if (object != null) {
			_rec.exclusions.push(object);
		}
	}

	override public function get_cacheEnabled():Bool {
		return false;
	}

	override function set_cacheEnabled(value:Bool):Bool {
		return value;
	}

	/** The frame a range of children is rendered in, for their change marks; 0 under a filter, as with the cache off. **/
	override function get_frameID():UInt {
		return _recFrameID;
	}

	public function allocRecording():RenderRecording {
		var rec:RenderRecording;
		if (_recUsed < _recPool.length) {
			rec = _recPool[_recUsed];
			rec.reset();
		} else {
			rec = new RenderRecording();
			_recPool.push(rec);
		}
		_recUsed++;
		return rec;
	}

	public function allocTask():RenderTask {
		var task:RenderTask;
		if (_taskUsed < _taskPool.length) {
			task = _taskPool[_taskUsed];
		} else {
			task = new RenderTask();
			_taskPool.push(task);
		}
		_taskUsed++;
		return task;
	}

	public function beginRecording(task:RenderTask) {
		_rec = task.rec;
		_recFrameID = task.frameID;
		_recGroup = task.group;
		_current = null;
		_stateStackPos = -1;
		_state._modelviewMatrix.setTo(task.a, task.b, task.c, task.d, task.tx, task.ty);
		_state._alpha = task.alpha;
		_state._blendMode = task.blendMode;
	}

	public function endRecording() {
		finishMeshBatch();
		_rec = null;
	}

	/** Leaves the painter usable after a task threw. **/
	public function abortRecording() {
		_current = null;
		_rec = null;
		_stateStackPos = -1;
	}

	function addDeferred(kind:Int, object:DisplayObject, filter:FragmentFilter, sub:RenderRecording) {
		finishMeshBatch();
		var item:DeferredRender;
		if (_deferredUsed < _deferredPool.length) {
			item = _deferredPool[_deferredUsed];
		} else {
			item = new DeferredRender();
			_deferredPool.push(item);
		}
		_deferredUsed++;
		var matrix = _state._modelviewMatrix;
		item.kind = kind;
		item.object = object;
		item.filter = filter;
		item.sub = sub;
		item.a = matrix.a;
		item.b = matrix.b;
		item.c = matrix.c;
		item.d = matrix.d;
		item.tx = matrix.tx;
		item.ty = matrix.ty;
		item.alpha = _state._alpha;
		item.blendMode = _state._blendMode;
		_rec.batches.push(null);
		_rec.deferred.push(item);
		RenderWorkers.statDeferred++;
	}

	/** Leaves a child, with its mask and filter, to the main thread. The state is its parent's. **/
	public function deferChild(child:DisplayObject) {
		addDeferred(DeferredRender.CHILD, child, null, null);
	}

	/** Leaves an object to the main thread. The state is the object's own. **/
	public function deferObject(object:DisplayObject) {
		addDeferred(DeferredRender.OBJECT, object, null, null);
	}

	/** Leaves a filter's passes to the main thread; `sub` is its target, recorded, or null. **/
	public function deferFilter(filter:FragmentFilter, sub:RenderRecording) {
		addDeferred(DeferredRender.FILTER, null, filter, sub);
	}

	/** Records a filter's target into `sub`, as a task for another thread when one may be free. **/
	public function recordTarget(target:DisplayObject, sub:RenderRecording) {
		if (RenderWorkers.shouldSpawn()) {
			var matrix = _state._modelviewMatrix;
			var task = allocTask();
			task.kind = RenderTask.TARGET;
			task.container = null;
			task.target = target;
			task.rec = sub;
			task.group = _recGroup;
			task.frameID = (0 : UInt);
			task.a = matrix.a;
			task.b = matrix.b;
			task.c = matrix.c;
			task.d = matrix.d;
			task.tx = matrix.tx;
			task.ty = matrix.ty;
			task.alpha = 1;
			task.blendMode = _state._blendMode;
			if (RenderWorkers.spawn(task)) {
				RenderWorkers.statTasks++;
				return;
			}
		}
		RenderWorkers.statInline++;
		var outer = _rec;
		var outerFrameID = _recFrameID;
		_rec = sub;
		_recFrameID = (0 : UInt);
		pushState();
		_state._alpha = 1;
		target.render(this);
		finishMeshBatch();
		popState();
		_rec = outer;
		_recFrameID = outerFrameID;
	}
}
