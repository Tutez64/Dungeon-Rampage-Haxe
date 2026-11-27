package starling.display;

import flash.geom.Matrix;
import starling.rendering.IndexData;
import starling.rendering.MeshEffect;
import starling.rendering.Painter;
import starling.rendering.VertexData;
import starling.styles.MeshStyle;
import starling.utils.MatrixUtil;
import starling.utils.MeshSubset;

class MeshBatch extends Mesh {
	public static inline final MAX_NUM_VERTICES = 65535;

	static var sFullMeshSubset:MeshSubset = new MeshSubset();

	var _effect:MeshEffect;

	var _batchable:Bool = false;

	var _vertexSyncRequired:Bool = false;

	var _indexSyncRequired:Bool = false;

	public function new() {
		var _loc1_ = new VertexData();
		var _loc2_ = new IndexData();
		super(_loc1_, _loc2_);
	}

	override public function dispose() {
		if (_effect != null) {
			_effect.dispose();
		}
		super.dispose();
	}

	override public function setVertexDataChanged() {
		_vertexSyncRequired = true;
		super.setVertexDataChanged();
	}

	override public function setIndexDataChanged() {
		_indexSyncRequired = true;
		super.setIndexDataChanged();
	}

	function setVertexAndIndexDataChanged() {
		_vertexSyncRequired = _indexSyncRequired = true;
	}

	function syncVertexBuffer() {
		_effect.uploadVertexData(_vertexData);
		_vertexSyncRequired = false;
	}

	function syncIndexBuffer() {
		_effect.uploadIndexData(_indexData);
		_indexSyncRequired = false;
	}

	public function clear() {
		if (_parent != null) {
			setRequiresRedraw();
		}
		_vertexData.numVertices = 0;
		_indexData.numIndices = 0;
		_vertexSyncRequired = true;
		_indexSyncRequired = true;
	}

	public function addMesh(mesh:Mesh, matrix:Matrix = null, alpha:Float = 1, subset:MeshSubset = null, ignoreTransformations:Bool = false) {
		addMeshAt(mesh, -1, -1, matrix, alpha, subset, ignoreTransformations);
	}

	public function addMeshAt(mesh:Mesh, indexID:Int = -1, vertexID:Int = -1, matrix:Matrix = null, alpha:Float = 1, subset:MeshSubset = null,
			ignoreTransformations:Bool = false) {
		if (ignoreTransformations) {
			matrix = null;
		} else if (matrix == null) {
			matrix = mesh.transformationMatrix;
		}
		if (subset == null) {
			subset = sFullMeshSubset;
		}
		var _loc10_ = _vertexData.numVertices;
		var _loc9_ = vertexID >= 0 ? vertexID : _loc10_;
		var _loc11_ = indexID >= 0 ? indexID : _indexData.numIndices;
		var _loc8_ = mesh._style;
		if (_loc10_ == 0) {
			setupFor(mesh);
		}
		_loc8_.batchVertexData(_style, _loc9_, matrix, subset.vertexID, subset.numVertices);
		_loc8_.batchIndexData(_style, _loc11_, _loc9_ - subset.vertexID, subset.indexID, subset.numIndices);
		if (alpha != 1) {
			_vertexData.scaleAlphas("color", alpha, _loc9_, subset.numVertices);
		}
		if (_parent != null) {
			setRequiresRedraw();
		}
		_indexSyncRequired = _vertexSyncRequired = true;
	}

	function setupFor(mesh:Mesh) {
		var _loc4_:MeshStyle = null;
		var _loc3_ = mesh._style;
		var _loc2_ = _loc3_.type;
		if (_style.type != _loc2_) {
			_loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MeshStyle);
			_loc4_.copyFrom(_loc3_);
			setStyle(_loc4_, false);
		} else {
			_style.copyFrom(_loc3_);
		}
	}

	public function canAddMesh(mesh:Mesh, numVertices:Int = -1):Bool {
		var _loc3_ = _vertexData.numVertices;
		if (_loc3_ == 0) {
			return true;
		}
		if (numVertices < 0) {
			numVertices = mesh.numVertices;
		}
		if (numVertices == 0) {
			return true;
		}
		if (numVertices + _loc3_ > 65535) {
			return false;
		}
		return _style.canBatchWith(mesh._style);
	}

	override public function render(painter:Painter) {
		if (_vertexData.numVertices == 0) {
			return;
		}
		if (_pixelSnapping) {
			MatrixUtil.snapToPixels(painter.state.modelviewMatrix, painter.pixelSize);
		}
		if (_batchable) {
			painter.batchMesh(this);
		} else {
			painter.finishMeshBatch();
			painter.drawCount += 1;
			painter.prepareToDraw();
			painter.excludeFromCache(this);
			if (_vertexSyncRequired) {
				syncVertexBuffer();
			}
			if (_indexSyncRequired) {
				syncIndexBuffer();
			}
			_style.updateEffect(_effect, painter.state);
			_effect.render(0, _indexData.numTriangles);
		}
	}

	override public function setStyle(meshStyle:MeshStyle = null, mergeWithPredecessor:Bool = true) {
		super.setStyle(meshStyle, mergeWithPredecessor);
		if (_effect != null) {
			_effect.dispose();
		}
		_effect = style.createEffect();
		_effect.onRestore = setVertexAndIndexDataChanged;
		setVertexAndIndexDataChanged();
	}

	public override function set_numVertices(value:Int):Int {
		if (_vertexData.numVertices != value) {
			_vertexData.numVertices = value;
			_vertexSyncRequired = true;
			setRequiresRedraw();
		}
		return value;
	}

	public override function set_numIndices(value:Int):Int {
		if (_indexData.numIndices != value) {
			_indexData.numIndices = value;
			_indexSyncRequired = true;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var batchable(get, set):Bool;

	public function get_batchable():Bool {
		return _batchable;
	}

	function set_batchable(value:Bool):Bool {
		if (_batchable != value) {
			_batchable = value;
			setRequiresRedraw();
		}
		return value;
	}
}
