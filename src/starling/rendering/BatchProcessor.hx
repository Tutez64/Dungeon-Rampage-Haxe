package starling.rendering;

import flash.geom.Matrix;
import starling.display.Mesh;
import starling.display.MeshBatch;
import starling.utils.MeshSubset;
import starling.display.MeshBatch;

/*internal*/
class BatchProcessor {
	static var sMeshSubset:MeshSubset = new MeshSubset();

	var _batches:Vector<MeshBatch>;

	var _batchPool:BatchPool;

	var _currentBatch:MeshBatch;

	var _currentStyleType:Dynamic;

	var _onBatchComplete:ASFunction;

	var _cacheToken:BatchToken;

	var _frameFinished:Bool = false;

	public function new(onBatchComplete:ASFunction) {
		_onBatchComplete = onBatchComplete;
		_batches = new Vector<MeshBatch>((0 : UInt));
		_batchPool = new BatchPool();
		_cacheToken = new BatchToken();
	}

	public function dispose() {
		var _loc1_:MeshBatch;
		final __ax4_iter_446 = _batches;
		if (checkNullIteratee(__ax4_iter_446))
			for (_tmp_ in __ax4_iter_446) {
				_loc1_ = _tmp_;
				_loc1_.dispose();
			}
		_batches.length = 0;
		_batchPool.purge();
		_currentBatch = null;
		_onBatchComplete = null;
	}

	public function addMesh(mesh:Mesh, state:RenderState, subset:MeshSubset = null, ignoreTransformations:Bool = false) {
		var _loc6_:Matrix = null;
		var _loc5_ = Math.NaN;
		if (subset == null) {
			subset = sMeshSubset;
			subset.vertexID = subset.indexID = 0;
			subset.numVertices = mesh.numVertices;
			subset.numIndices = mesh.numIndices;
		} else {
			if (subset.numVertices < 0) {
				subset.numVertices = mesh.numVertices - subset.vertexID;
			}
			if (subset.numIndices < 0) {
				subset.numIndices = mesh.numIndices - subset.indexID;
			}
		}
		if (subset.numVertices > 0) {
			if (_currentBatch == null || !_currentBatch.canAddMesh(mesh, subset.numVertices)) {
				finishBatch();
				_currentStyleType = mesh.style.type;
				_currentBatch = _batchPool.get(_currentStyleType);
				_currentBatch.blendMode = state != null ? state.blendMode : mesh.blendMode;
				_cacheToken.setTo(_batches.length);
				_batches[_batches.length] = _currentBatch;
			}
			_loc6_ = ASCompat.coerce(state != null ? state._modelviewMatrix : null, flash.geom.Matrix);
			_loc5_ = state != null ? state._alpha : 1;
			_currentBatch.addMeshAt(mesh, -1, -1, _loc6_, _loc5_, subset, ignoreTransformations);
			_cacheToken.vertexID += subset.numVertices;
			_cacheToken.indexID += subset.numIndices;
		}
	}

	public function finishBatch() {
		var _loc1_ = _currentBatch;
		if (_loc1_ != null) {
			_currentBatch = null;
			_currentStyleType = null;
			if (_onBatchComplete != null) {
				_onBatchComplete(_loc1_);
			}
		}
	}

	public function finishFrame() {
		finishBatch();
		_frameFinished = true;
	}

	public function clear() {
		var _loc1_ = 0;
		var _loc2_ = _batches.length;
		_loc1_ = 0;
		while (_loc1_ < _loc2_) {
			_batchPool.put(_batches[_loc1_]);
			_loc1_++;
		}
		_batches.length = 0;
		_currentBatch = null;
		_currentStyleType = null;
		_cacheToken.reset();
		_frameFinished = false;
	}

	public function getBatchAt(batchID:Int):MeshBatch {
		return _batches[batchID];
	}

	public function trim() {
		_batchPool.purge();
	}

	public function fillToken(token:BatchToken):BatchToken {
		token.batchID = _cacheToken.batchID;
		token.vertexID = _cacheToken.vertexID;
		token.indexID = _cacheToken.indexID;
		return token;
	}

	@:isVar public var numBatches(get, never):Int;

	public function get_numBatches():Int {
		return _batches.length;
	}

	@:isVar public var frameFinished(get, never):Bool;

	public function get_frameFinished():Bool {
		return _frameFinished;
	}

	@:isVar public var onBatchComplete(get, set):ASFunction;

	public function get_onBatchComplete():ASFunction {
		return _onBatchComplete;
	}

	function set_onBatchComplete(value:ASFunction):ASFunction {
		return _onBatchComplete = value;
	}
}

private class BatchPool {
	var _batchLists:ASDictionary<ASAny, ASAny>;

	public function new() {
		_batchLists = new ASDictionary<ASAny, ASAny>();
	}

	public function purge() {
		var _loc1_ = 0;
		var _loc2_:Array<ASAny>;
		final __ax4_iter_447 = _batchLists;
		if (checkNullIteratee(__ax4_iter_447))
			for (_tmp_ in __ax4_iter_447) {
				_loc2_ = ASCompat.coerce(_tmp_, Array);
				_loc1_ = 0;
				while (_loc1_ < _loc2_.length) {
					_loc2_[_loc1_].dispose();
					_loc1_++;
				}
				_loc2_.resize(0);
			}
	}

	public function get(styleType:Dynamic):MeshBatch {
		var _loc2_:Array<ASAny> = ASCompat.coerce(_batchLists[styleType], Array);
		if (_loc2_ == null) {
			_loc2_ = [];
			_batchLists[styleType] = _loc2_;
		}
		if (_loc2_.length > 0) {
			return ASCompat.coerce(_loc2_.pop(), starling.display.MeshBatch);
		}
		return new MeshBatch();
	}

	public function put(meshBatch:MeshBatch) {
		var _loc2_ = meshBatch.style.type;
		var _loc3_:Array<ASAny> = ASCompat.coerce(_batchLists[_loc2_], Array);
		if (_loc3_ == null) {
			_loc3_ = [];
			_batchLists[_loc2_] = _loc3_;
		}
		meshBatch.clear();
		_loc3_[_loc3_.length] = meshBatch;
	}
}
