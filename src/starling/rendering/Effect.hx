package starling.rendering;

import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import starling.core.Starling;
import starling.errors.MissingContextError;
import starling.utils.ContextRestoreRegistry;
import starling.utils.Execute;

class Effect {
	public static final VERTEX_FORMAT:VertexDataFormat = VertexDataFormat.fromString("position:float2");

	static var sRestoreRegistry:ContextRestoreRegistry = new ContextRestoreRegistry(20, restoreEffect);

	static var sProgramNameCache:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var _vertexBuffer:VertexBuffer3D;

	var _vertexBufferSize:Int = 0;

	var _indexBuffer:IndexBuffer3D;

	var _indexBufferSize:Int = 0;

	var _indexBufferUsesQuadLayout:Bool = false;

	var _mvpMatrix3D:Matrix3D;

	var _onRestore:ASFunction;

	var _restoreList:ASDictionary<ASAny, ASAny>;

	var _programBaseName:String;

	public function new() {
		_mvpMatrix3D = new Matrix3D();
		_programBaseName = ASCompat.getQualifiedClassName(this);
		_restoreList = sRestoreRegistry.add(this, Starling.current.stage3D);
	}

	static function restoreEffect(effect:Effect, event:Event) {
		effect.onContextCreated(event);
	}

	public function dispose() {
		_restoreList.remove(this);
		purgeBuffers();
	}

	function onContextCreated(event:Event) {
		purgeBuffers();
		Execute.execute(_onRestore, this);
	}

	public function purgeBuffers(vertexBuffer:Bool = true, indexBuffer:Bool = true) {
		if (_vertexBuffer != null && vertexBuffer) {
			try {
				_vertexBuffer.dispose();
			} catch (e:Dynamic) {}
			_vertexBuffer = null;
		}
		if (_indexBuffer != null && indexBuffer) {
			try {
				_indexBuffer.dispose();
			} catch (e:Dynamic) {}
			_indexBuffer = null;
		}
	}

	public function uploadIndexData(indexData:IndexData, bufferUsage:String = "staticDraw") {
		var _loc3_ = indexData.numIndices;
		var _loc5_ = indexData.useQuadLayout;
		var _loc4_ = _indexBufferUsesQuadLayout;
		if (_indexBuffer != null) {
			if (_loc3_ <= _indexBufferSize) {
				if (!_loc5_ || !_loc4_) {
					indexData.uploadToIndexBuffer(_indexBuffer);
					_indexBufferUsesQuadLayout = _loc5_ && _loc3_ == _indexBufferSize;
				}
			} else {
				purgeBuffers(false, true);
			}
		}
		if (_indexBuffer == null) {
			_indexBuffer = indexData.createIndexBuffer(true, bufferUsage);
			_indexBufferSize = _loc3_;
			_indexBufferUsesQuadLayout = _loc5_;
		}
	}

	public function uploadVertexData(vertexData:VertexData, bufferUsage:String = "staticDraw") {
		if (_vertexBuffer != null) {
			if (vertexData.size <= _vertexBufferSize) {
				vertexData.uploadToVertexBuffer(_vertexBuffer);
			} else {
				purgeBuffers(true, false);
			}
		}
		if (_vertexBuffer == null) {
			_vertexBuffer = vertexData.createVertexBuffer(true, bufferUsage);
			_vertexBufferSize = vertexData.size;
		}
	}

	public function render(firstIndex:Int = 0, numTriangles:Int = -1) {
		if (numTriangles < 0) {
			numTriangles = ASCompat.floatToInt(_indexBufferSize / 3);
		}
		if (numTriangles == 0) {
			return;
		}
		var _loc3_ = Starling.context;
		if (_loc3_ == null) {
			throw new MissingContextError();
		}
		beforeDraw(_loc3_);
		_loc3_.drawTriangles(indexBuffer, firstIndex, numTriangles);
		afterDraw(_loc3_);
	}

	function beforeDraw(context:Context3D) {
		program.activate(context);
		vertexFormat.setVertexBufferAt(0, vertexBuffer, "position");
		context.setProgramConstantsFromMatrix("vertex", 0, mvpMatrix3D, true);
	}

	function afterDraw(context:Context3D) {
		context.setVertexBufferAt(0, null);
	}

	function createProgram():Program {
		var _loc1_ = ["m44 op, va0, vc0", "sge v0, va0, va0"].join("\n");
		var _loc2_ = "mov oc, v0";
		return Program.fromSource(_loc1_, _loc2_);
	}

	@:isVar var programVariantName(get, never):UInt;

	function get_programVariantName():UInt {
		return (0 : UInt);
	}

	@:isVar var programBaseName(get, set):String;

	function get_programBaseName():String {
		return _programBaseName;
	}

	function set_programBaseName(value:String):String {
		return _programBaseName = value;
	}

	@:isVar var programName(get, never):String;

	function get_programName():String {
		var _loc3_ = this.programBaseName;
		var _loc2_ = this.programVariantName;
		var _loc4_ = (sProgramNameCache[_loc3_] : ASDictionary<ASAny, ASAny>);
		if (_loc4_ == null) {
			_loc4_ = new ASDictionary<ASAny, ASAny>();
			sProgramNameCache[_loc3_] = _loc4_;
		}
		var _loc1_:String = _loc4_[_loc2_];
		if (_loc1_ == null) {
			if (_loc2_ != 0) {
				_loc1_ = _loc3_ + "#" + ASCompat.toRadix(_loc2_, (16 : UInt));
			} else {
				_loc1_ = _loc3_;
			}
			_loc4_[_loc2_] = _loc1_;
		}
		return _loc1_;
	}

	@:isVar var program(get, never):Program;

	function get_program():Program {
		var _loc2_ = this.programName;
		var _loc1_ = Starling.painter;
		var _loc3_ = _loc1_.getProgram(_loc2_);
		if (_loc3_ == null) {
			_loc3_ = createProgram();
			_loc1_.registerProgram(_loc2_, _loc3_);
		}
		return _loc3_;
	}

	@:isVar public var onRestore(get, set):ASFunction;

	public function get_onRestore():ASFunction {
		return _onRestore;
	}

	function set_onRestore(value:ASFunction):ASFunction {
		return _onRestore = value;
	}

	@:isVar public var vertexFormat(get, never):VertexDataFormat;

	public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	@:isVar public var mvpMatrix3D(get, set):Matrix3D;

	public function get_mvpMatrix3D():Matrix3D {
		return _mvpMatrix3D;
	}

	function set_mvpMatrix3D(value:Matrix3D):Matrix3D {
		_mvpMatrix3D.copyFrom(value);
		return value;
	}

	@:isVar var indexBuffer(get, never):IndexBuffer3D;

	function get_indexBuffer():IndexBuffer3D {
		return _indexBuffer;
	}

	@:isVar var indexBufferSize(get, never):Int;

	function get_indexBufferSize():Int {
		return _indexBufferSize;
	}

	@:isVar var vertexBuffer(get, never):VertexBuffer3D;

	function get_vertexBuffer():VertexBuffer3D {
		return _vertexBuffer;
	}

	@:isVar var vertexBufferSize(get, never):Int;

	function get_vertexBufferSize():Int {
		return _vertexBufferSize;
	}
}
