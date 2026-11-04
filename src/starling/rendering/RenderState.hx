package starling.rendering;

import flash.display3D.textures.TextureBase;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.textures.Texture;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import starling.utils.RectangleUtil;
import flash.errors.ArgumentError;

class RenderState {
	static var sProjectionMatrix3DRev:UInt = (0 : UInt);

	static final CULLING_VALUES:Vector<String> = Vector.ofArray(["none", "front", "back", "frontAndBack"]);

	static final COMPARE_VALUES:Vector<String> = Vector.ofArray([
		"always",
		"never",
		"less",
		"lessEqual",
		"equal",
		"greaterEqual",
		"greater",
		"notEqual"
	]);

	static var sMatrix3D:Matrix3D = new Matrix3D();

	@:allow(starling.rendering) var _alpha:Float = Math.NaN;

	@:allow(starling.rendering) var _blendMode:String;

	@:allow(starling.rendering) var _modelviewMatrix:Matrix;

	var _miscOptions:UInt = 0;

	var _clipRect:Rectangle;

	var _renderTarget:Texture;

	var _onDrawRequired:ASFunction;

	var _modelviewMatrix3D:Matrix3D;

	var _projectionMatrix3D:Matrix3D;

	var _projectionMatrix3DRev:UInt = 0;

	var _mvpMatrix3D:Matrix3D;

	public function new() {
		reset();
	}

	public function copyFrom(renderState:RenderState) {
		var _loc4_:TextureBase = null;
		var _loc5_:TextureBase = null;
		var _loc6_ = false;
		var _loc7_ = false;
		var _loc3_ = false;
		var _loc2_ = false;
		if (_onDrawRequired != null) {
			_loc4_ = ASCompat.coerce(_renderTarget != null ? _renderTarget.base : null, flash.display3D.textures.TextureBase);
			_loc5_ = ASCompat.coerce(renderState._renderTarget != null ? renderState._renderTarget.base : null, flash.display3D.textures.TextureBase);
			_loc6_ = ((_miscOptions : Int) & 0x0F00) != ((renderState._miscOptions : Int) & 0x0F00);
			_loc7_ = ((_miscOptions : Int) & 0xF000) != ((renderState._miscOptions : Int) & 0xF000);
			_loc3_ = ((_miscOptions : Int) & 0x0F0000) != ((renderState._miscOptions : Int) & 0x0F0000);
			_loc2_ = _clipRect != null || renderState._clipRect != null ? !RectangleUtil.compare(_clipRect, renderState._clipRect) : false;
			if (_blendMode != renderState._blendMode || _loc4_ != _loc5_ || _loc2_ || _loc6_ || _loc7_ || _loc3_) {
				_onDrawRequired();
			}
		}
		_alpha = renderState._alpha;
		_blendMode = renderState._blendMode;
		_renderTarget = renderState._renderTarget;
		_miscOptions = renderState._miscOptions;
		_modelviewMatrix.copyFrom(renderState._modelviewMatrix);
		if (_projectionMatrix3DRev != renderState._projectionMatrix3DRev) {
			_projectionMatrix3DRev = renderState._projectionMatrix3DRev;
			_projectionMatrix3D.copyFrom(renderState._projectionMatrix3D);
		}
		if (_modelviewMatrix3D != null || renderState._modelviewMatrix3D != null) {
			this.modelviewMatrix3D = renderState._modelviewMatrix3D;
		}
		if (_clipRect != null || renderState._clipRect != null) {
			this.clipRect = renderState._clipRect;
		}
	}

	public function reset() {
		this.alpha = 1;
		this.blendMode = "normal";
		this.culling = "none";
		this.depthMask = false;
		this.depthTest = "always";
		this.modelviewMatrix3D = null;
		this.renderTarget = null;
		this.clipRect = null;
		_projectionMatrix3DRev = (0 : UInt);
		if (_modelviewMatrix != null) {
			_modelviewMatrix.identity();
		} else {
			_modelviewMatrix = new Matrix();
		}
		if (_projectionMatrix3D != null) {
			_projectionMatrix3D.identity();
		} else {
			_projectionMatrix3D = new Matrix3D();
		}
		if (_mvpMatrix3D == null) {
			_mvpMatrix3D = new Matrix3D();
		}
	}

	public function transformModelviewMatrix(matrix:Matrix) {
		MatrixUtil.prependMatrix(_modelviewMatrix, matrix);
	}

	public function transformModelviewMatrix3D(matrix:Matrix3D) {
		if (_modelviewMatrix3D == null) {
			_modelviewMatrix3D = Pool.getMatrix3D();
		}
		_modelviewMatrix3D.prepend(MatrixUtil.convertTo3D(_modelviewMatrix, sMatrix3D));
		_modelviewMatrix3D.prepend(matrix);
		_modelviewMatrix.identity();
	}

	public function setProjectionMatrix(x:Float, y:Float, width:Float, height:Float, stageWidth:Float = 0, stageHeight:Float = 0, cameraPos:Vector3D = null) {
		_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
		MatrixUtil.createPerspectiveProjectionMatrix(x, y, width, height, stageWidth, stageHeight, cameraPos, _projectionMatrix3D);
	}

	public function setProjectionMatrixChanged() {
		_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
	}

	public function setModelviewMatricesToIdentity() {
		_modelviewMatrix.identity();
		if (_modelviewMatrix3D != null) {
			_modelviewMatrix3D.identity();
		}
	}

	@:isVar public var modelviewMatrix(get, set):Matrix;

	public function get_modelviewMatrix():Matrix {
		return _modelviewMatrix;
	}

	function set_modelviewMatrix(value:Matrix):Matrix {
		_modelviewMatrix.copyFrom(value);
		return value;
	}

	@:isVar public var modelviewMatrix3D(get, set):Matrix3D;

	public function get_modelviewMatrix3D():Matrix3D {
		return _modelviewMatrix3D;
	}

	function set_modelviewMatrix3D(value:Matrix3D):Matrix3D {
		if (value != null) {
			if (_modelviewMatrix3D == null) {
				_modelviewMatrix3D = Pool.getMatrix3D(false);
			}
			_modelviewMatrix3D.copyFrom(value);
		} else if (_modelviewMatrix3D != null) {
			Pool.putMatrix3D(_modelviewMatrix3D);
			_modelviewMatrix3D = null;
		}
		return value;
	}

	@:isVar public var projectionMatrix3D(get, set):Matrix3D;

	public function get_projectionMatrix3D():Matrix3D {
		return _projectionMatrix3D;
	}

	function set_projectionMatrix3D(value:Matrix3D):Matrix3D {
		setProjectionMatrixChanged();
		_projectionMatrix3D.copyFrom(value);
		return value;
	}

	@:isVar public var mvpMatrix3D(get, never):Matrix3D;

	public function get_mvpMatrix3D():Matrix3D {
		_mvpMatrix3D.copyFrom(_projectionMatrix3D);
		if (_modelviewMatrix3D != null) {
			_mvpMatrix3D.prepend(_modelviewMatrix3D);
		}
		_mvpMatrix3D.prepend(MatrixUtil.convertTo3D(_modelviewMatrix, sMatrix3D));
		return _mvpMatrix3D;
	}

	public function setRenderTarget(target:Texture, enableDepthAndStencil:Bool = true, antiAlias:Int = 0) {
		var _loc5_ = ASCompat.coerce(_renderTarget != null ? _renderTarget.base : null, flash.display3D.textures.TextureBase);
		var _loc6_ = ASCompat.coerce(target != null ? target.base : null, flash.display3D.textures.TextureBase);
		var _loc7_ = (ASCompat.floatToInt(MathUtil.min(antiAlias, 15)) | ASCompat.toInt(enableDepthAndStencil) << 4:UInt);
		var _loc4_ = _loc7_ != (((_miscOptions : Int) & 0xFF) : UInt);
		if (_loc5_ != _loc6_ || _loc4_) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			_renderTarget = target;
			_miscOptions = ((_miscOptions : Int) & ASCompat.floatToInt(0xFFFFFF00) | (_loc7_ : Int) : UInt);
		}
	}

	@:isVar public var alpha(get, set):Float;

	public function get_alpha():Float {
		return _alpha;
	}

	function set_alpha(value:Float):Float {
		return _alpha = value;
	}

	@:isVar public var blendMode(get, set):String;

	public function get_blendMode():String {
		return _blendMode;
	}

	function set_blendMode(value:String):String {
		if (value != "auto" && _blendMode != value) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			_blendMode = value;
		}
		return value;
	}

	@:isVar public var renderTarget(get, set):Texture;

	public function get_renderTarget():Texture {
		return _renderTarget;
	}

	function set_renderTarget(value:Texture):Texture {
		setRenderTarget(value);
		return value;
	}

	@:allow(starling.rendering) @:isVar var renderTargetBase(get, never):TextureBase;

	function get_renderTargetBase():TextureBase {
		return ASCompat.coerce(_renderTarget != null ? _renderTarget.base : null, flash.display3D.textures.TextureBase);
	}

	@:allow(starling.rendering) @:isVar var renderTargetOptions(get, never):UInt;

	function get_renderTargetOptions():UInt {
		return ((_miscOptions : Int) & 0xFF : UInt);
	}

	@:isVar public var culling(get, set):String;

	public function get_culling():String {
		var _loc1_ = ((_miscOptions : Int) & 0x0F00) >> 8;
		return CULLING_VALUES[_loc1_];
	}

	function set_culling(value:String):String {
		var _loc2_ = 0;
		if (this.culling != value) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			_loc2_ = CULLING_VALUES.indexOf(value);
			if (_loc2_ == -1) {
				throw new ArgumentError("Invalid culling mode");
			}
			_miscOptions = ((_miscOptions : Int) & ASCompat.floatToInt(0xFFFFF0FF) | _loc2_ << 8 : UInt);
		}
		return value;
	}

	@:isVar public var depthMask(get, set):Bool;

	public function get_depthMask():Bool {
		return ((_miscOptions : Int) & 0xF000) != 0;
	}

	function set_depthMask(value:Bool):Bool {
		if (depthMask != value) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			_miscOptions = ((_miscOptions : Int) & ASCompat.floatToInt(0xFFFF0FFF) | ASCompat.toInt(value) << 12 : UInt);
		}
		return value;
	}

	@:isVar public var depthTest(get, set):String;

	public function get_depthTest():String {
		var _loc1_ = ((_miscOptions : Int) & 0x0F0000) >> 16;
		return COMPARE_VALUES[_loc1_];
	}

	function set_depthTest(value:String):String {
		var _loc2_ = 0;
		if (depthTest != value) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			_loc2_ = COMPARE_VALUES.indexOf(value);
			if (_loc2_ == -1) {
				throw new ArgumentError("Invalid compare mode");
			}
			_miscOptions = ((_miscOptions : Int) & ASCompat.floatToInt(0xFFF0FFFF) | _loc2_ << 16 : UInt);
		}
		return value;
	}

	@:isVar public var clipRect(get, set):Rectangle;

	public function get_clipRect():Rectangle {
		return _clipRect;
	}

	function set_clipRect(value:Rectangle):Rectangle {
		if (!RectangleUtil.compare(_clipRect, value)) {
			if (_onDrawRequired != null) {
				_onDrawRequired();
			}
			if (value != null) {
				if (_clipRect == null) {
					_clipRect = Pool.getRectangle();
				}
				_clipRect.copyFrom(value);
			} else if (_clipRect != null) {
				Pool.putRectangle(_clipRect);
				_clipRect = null;
			}
		}
		return value;
	}

	@:isVar public var renderTargetAntiAlias(get, never):Int;

	public function get_renderTargetAntiAlias():Int {
		return (_miscOptions : Int) & 0x0F;
	}

	@:isVar public var renderTargetSupportsDepthAndStencil(get, never):Bool;

	public function get_renderTargetSupportsDepthAndStencil():Bool {
		return ((_miscOptions : Int) & 0xF0) != 0;
	}

	@:isVar public var is3D(get, never):Bool;

	public function get_is3D():Bool {
		return _modelviewMatrix3D != null;
	}

	@:allow(starling.rendering) @:allow(starling.rendering) @:isVar var onDrawRequired(get, set):ASFunction;

	function get_onDrawRequired():ASFunction {
		return _onDrawRequired;
	}

	function set_onDrawRequired(value:ASFunction):ASFunction {
		return _onDrawRequired = value;
	}
}
