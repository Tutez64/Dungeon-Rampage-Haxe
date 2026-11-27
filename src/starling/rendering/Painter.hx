package starling.rendering;

import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.textures.TextureBase;
import flash.errors.IllegalOperationError;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.display.MeshBatch;
import starling.display.Quad;
import starling.textures.Texture;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.MeshSubset;
import starling.utils.Pool;
import starling.utils.RectangleUtil;
import starling.utils.RenderUtil;
import starling.utils.SystemUtil;

/*use*/ /*namespace*/ /*starling_internal*/ class Painter {
	static inline final PROGRAM_DATA_NAME = "starling.rendering.Painter.Programs";

	public static inline final DEFAULT_STENCIL_VALUE = (127 : UInt);

	static var sSharedData:ASDictionary<ASAny, ASAny> = new ASDictionary();

	static var sMatrix:Matrix = new Matrix();

	static var sPoint3D:Vector3D = new Vector3D();

	static var sMatrix3D:Matrix3D = new Matrix3D();

	static var sClipRect:Rectangle = new Rectangle();

	static var sBufferRect:Rectangle = new Rectangle();

	static var sScissorRect:Rectangle = new Rectangle();

	static var sMeshSubset:MeshSubset = new MeshSubset();

	var _stage3D:Stage3D;

	var _context:Context3D;

	var _shareContext:Bool = false;

	var _drawCount:Int = 0;

	var _frameID:UInt = 0;

	var _pixelSize:Float = Math.NaN;

	var _enableErrorChecking:Bool = false;

	var _stencilReferenceValues:ASDictionary<ASAny, ASAny>;

	var _clipRectStack:Vector<Rectangle>;

	var _batchCacheExclusions:Vector<DisplayObject>;

	var _batchTrimInterval:Int = 250;

	var _batchProcessor:BatchProcessor;

	var _batchProcessorCurr:BatchProcessor;

	var _batchProcessorPrev:BatchProcessor;

	var _batchProcessorSpec:BatchProcessor;

	var _actualRenderTarget:TextureBase;

	var _actualRenderTargetOptions:UInt = 0;

	var _actualCulling:String;

	var _actualBlendMode:String;

	var _actualDepthMask:Bool = false;

	var _actualDepthTest:String;

	var _backBufferWidth:Float = Math.NaN;

	var _backBufferHeight:Float = Math.NaN;

	var _backBufferScaleFactor:Float = Math.NaN;

	var _state:RenderState;

	var _stateStack:Vector<RenderState>;

	var _stateStackPos:Int = 0;

	var _stateStackLength:Int = 0;

	public function new(stage3D:Stage3D) {
		_stage3D = stage3D;
		_stage3D.addEventListener("context3DCreate", onContextCreated, false, 40, true);
		_context = _stage3D.context3D;
		_shareContext = _context != null && _context.driverInfo != "Disposed";
		_backBufferWidth = _context != null ? _context.backBufferWidth : 0;
		_backBufferHeight = _context != null ? _context.backBufferHeight : 0;
		_backBufferScaleFactor = _pixelSize = 1;
		_stencilReferenceValues = new ASDictionary<ASAny, ASAny>(true);
		_clipRectStack = new Vector<Rectangle>((0 : UInt));
		_batchProcessorCurr = new BatchProcessor(drawBatch);
		_batchProcessorPrev = new BatchProcessor(drawBatch);
		_batchProcessorSpec = new BatchProcessor(drawBatch);
		_batchProcessor = _batchProcessorCurr;
		_batchCacheExclusions = new Vector<DisplayObject>();
		_state = new RenderState();
		_state.onDrawRequired = finishMeshBatch;
		_stateStack = new Vector<RenderState>((0 : UInt));
		_stateStackPos = -1;
		_stateStackLength = 0;
	}

	public function dispose() {
		_batchProcessorCurr.dispose();
		_batchProcessorPrev.dispose();
		_batchProcessorSpec.dispose();
		if (!_shareContext) {
			if (_context != null) {
				_context.dispose(false);
			}
			sSharedData = new ASDictionary<ASAny, ASAny>();
		}
	}

	public function requestContext3D(renderMode:String, profile:ASAny) {
		RenderUtil.requestContext3D(_stage3D, renderMode, profile);
	}

	function onContextCreated(event:ASObject) {
		_context = _stage3D.context3D;
		_context.enableErrorChecking = _enableErrorChecking;
	}

	public function configureBackBuffer(viewPort:Rectangle, contentScaleFactor:Float, antiAlias:Int, enableDepthAndStencil:Bool,
			supportBrowserZoom:Bool = false) {
		if (!_shareContext) {
			if (enableDepthAndStencil) {
				enableDepthAndStencil = SystemUtil.supportsDepthAndStencil;
			}
			if (_context.profile == "baselineConstrained") {
				_context.configureBackBuffer(32, 32, antiAlias, enableDepthAndStencil);
			}
			if (viewPort.width * contentScaleFactor > _context.maxBackBufferWidth
				|| viewPort.height * contentScaleFactor > _context.maxBackBufferHeight) {
				contentScaleFactor = 1;
			}
			_stage3D.x = viewPort.x;
			_stage3D.y = viewPort.y;
			_context.configureBackBuffer(ASCompat.floatToInt(viewPort.width), ASCompat.floatToInt(viewPort.height), antiAlias, enableDepthAndStencil,
				contentScaleFactor != 1, supportBrowserZoom);
		}
		_backBufferWidth = viewPort.width;
		_backBufferHeight = viewPort.height;
		_backBufferScaleFactor = contentScaleFactor;
	}

	public function registerProgram(name:String, program:Program) {
		deleteProgram(name);
		programs[name] = program;
	}

	public function deleteProgram(name:String) {
		var _loc2_ = getProgram(name);
		if (_loc2_ != null) {
			_loc2_.dispose();
			programs.remove(name);
		}
	}

	public function getProgram(name:String):Program {
		return ASCompat.dynamicAs(ASDictionary.getString(programs, name), Program);
	}

	public function hasProgram(name:String):Bool {
		return programs.exists(name);
	}

	public function pushState(token:BatchToken = null) {
		_stateStackPos = _stateStackPos + 1;
		if (_stateStackLength < _stateStackPos + 1) {
			_stateStack[_stateStackLength++] = new RenderState();
		}
		if (token != null) {
			_batchProcessor.fillToken(token);
		}
		_stateStack[_stateStackPos].copyFrom(_state);
	}

	public function setStateTo(transformationMatrix:Matrix, alphaFactor:Float = 1, blendMode:String = "auto") {
		if (transformationMatrix != null) {
			MatrixUtil.prependMatrix(_state._modelviewMatrix, transformationMatrix);
		}
		if (alphaFactor != 1) {
			_state._alpha *= alphaFactor;
		}
		if (blendMode != "auto") {
			_state.blendMode = blendMode;
		}
	}

	public function popState(token:BatchToken = null) {
		if (_stateStackPos < 0) {
			throw new IllegalOperationError("Cannot pop empty state stack");
		}
		_state.copyFrom(_stateStack[_stateStackPos]);
		_stateStackPos = _stateStackPos - 1;
		if (token != null) {
			_batchProcessor.fillToken(token);
		}
	}

	public function restoreState() {
		if (_stateStackPos < 0) {
			throw new IllegalOperationError("Cannot restore from empty state stack");
		}
		_state.copyFrom(_stateStack[_stateStackPos]);
	}

	public function fillToken(token:BatchToken) {
		if (token != null) {
			_batchProcessor.fillToken(token);
		}
	}

	public function drawMask(mask:DisplayObject, maskee:DisplayObject = null) {
		if (_context == null) {
			return;
		}
		finishMeshBatch();
		if (isRectangularMask(mask, maskee, sMatrix)) {
			mask.getBounds(mask, sClipRect);
			RectangleUtil.getBounds(sClipRect, sMatrix, sClipRect);
			pushClipRect(sClipRect);
		} else {
			if (maskee != null && maskee.maskInverted) {
				_context.setStencilActions("frontAndBack", "always", "decrementSaturate");
				renderMask(mask);
			} else {
				_context.setStencilActions("frontAndBack", "equal", "incrementSaturate");
				renderMask(mask);
				stencilReferenceValue = stencilReferenceValue + 1;
			}
			_context.setStencilActions("frontAndBack", "equal");
		}
		excludeFromCache(maskee);
	}

	public function eraseMask(mask:DisplayObject, maskee:DisplayObject = null) {
		if (_context == null) {
			return;
		}
		finishMeshBatch();
		if (isRectangularMask(mask, maskee, sMatrix)) {
			popClipRect();
		} else {
			if (maskee != null && maskee.maskInverted) {
				_context.setStencilActions("frontAndBack", "always", "incrementSaturate");
				renderMask(mask);
			} else {
				_context.setStencilActions("frontAndBack", "equal", "decrementSaturate");
				renderMask(mask);
				stencilReferenceValue = stencilReferenceValue - 1;
			}
			_context.setStencilActions("frontAndBack", "equal");
		}
	}

	function renderMask(mask:DisplayObject) {
		var _loc4_:Matrix = null;
		var _loc2_:Matrix3D = null;
		var _loc3_ = cacheEnabled;
		pushState();
		cacheEnabled = false;
		_state.alpha = 0;
		if (mask.stage != null) {
			_state.setModelviewMatricesToIdentity();
			if (mask.is3D) {
				_loc2_ = mask.getTransformationMatrix3D(null, sMatrix3D);
			} else {
				_loc4_ = mask.getTransformationMatrix(null, sMatrix);
			}
		} else if (mask.is3D) {
			_loc2_ = mask.transformationMatrix3D;
		} else {
			_loc4_ = mask.transformationMatrix;
		}
		if (_loc2_ != null) {
			_state.transformModelviewMatrix3D(_loc2_);
		} else {
			_state.transformModelviewMatrix(_loc4_);
		}
		mask.render(this);
		finishMeshBatch();
		cacheEnabled = _loc3_;
		popState();
	}

	function pushClipRect(clipRect:Rectangle) {
		var _loc2_ = _clipRectStack;
		var _loc4_ = (_loc2_.length : UInt);
		var _loc3_ = Pool.getRectangle();
		if (_loc4_ != 0) {
			RectangleUtil.intersect(_loc2_[(_loc4_ - 1 : Int)], clipRect, _loc3_);
		} else {
			_loc3_.copyFrom(clipRect);
		}
		_loc2_[(_loc4_ : Int)] = _loc3_;
		_state.clipRect = _loc3_;
	}

	function popClipRect() {
		var _loc1_ = _clipRectStack;
		var _loc2_ = (_loc1_.length : UInt);
		if (_loc2_ == 0) {
			throw new Error("Trying to pop from empty clip rectangle stack");
		}
		_loc2_--;
		Pool.putRectangle(_loc1_.pop());
		_state.clipRect = _loc2_ != 0 ? _loc1_[(_loc2_ - 1 : Int)] : null;
	}

	function isRectangularMask(mask:DisplayObject, maskee:DisplayObject, out:Matrix):Bool {
		var _loc4_ = ASCompat.reinterpretAs(mask, Quad);
		var _loc6_ = maskee != null && maskee.maskInverted;
		var _loc5_ = mask.is3D || maskee != null && maskee.is3D && mask.stage == null;
		if (_loc4_ != null && !_loc6_ && !_loc5_ && _loc4_.texture == null) {
			if (mask.stage != null) {
				mask.getTransformationMatrix(null, out);
			} else {
				out.copyFrom(mask.transformationMatrix);
				out.concat(_state.modelviewMatrix);
			}
			return MathUtil.isEquivalent(out.a, 0) && MathUtil.isEquivalent(out.d, 0) || MathUtil.isEquivalent(out.b, 0) && MathUtil.isEquivalent(out.c, 0);
		}
		return false;
	}

	public function batchMesh(mesh:Mesh, subset:MeshSubset = null) {
		_batchProcessor.addMesh(mesh, _state, subset);
	}

	public function finishMeshBatch() {
		_batchProcessor.finishBatch();
	}

	public function enableBatchTrimming(enabled:Bool = true, interval:Int = 250) {
		_batchTrimInterval = enabled ? interval : 0;
	}

	public function finishFrame() {
		var _loc1_ = 0;
		var _loc2_ = 0;
		if (_batchTrimInterval > 0) {
			_loc1_ = _batchTrimInterval | 1;
			_loc2_ = ASCompat.floatToInt(_batchTrimInterval * 1.5);
			if (_frameID % _loc1_ == 0) {
				_batchProcessorCurr.trim();
			}
			if (_frameID % _loc2_ == 0) {
				_batchProcessorSpec.trim();
			}
		}
		_batchProcessor.finishFrame();
		_batchProcessor = _batchProcessorSpec;
		processCacheExclusions();
	}

	function processCacheExclusions() {
		var _loc2_ = 0;
		var _loc1_ = _batchCacheExclusions.length;
		_loc2_ = 0;
		while (_loc2_ < _loc1_) {
			_batchCacheExclusions[_loc2_].excludeFromCache();
			_loc2_++;
		}
		_batchCacheExclusions.length = 0;
	}

	public function setupContextDefaults() {
		_actualBlendMode = null;
		_actualCulling = null;
		_actualDepthMask = false;
		_actualDepthTest = null;
	}

	public function nextFrame() {
		_batchProcessor = swapBatchProcessors();
		_batchProcessor.clear();
		_batchProcessorSpec.clear();
		setupContextDefaults();
		stencilReferenceValue = (127 : UInt);
		_clipRectStack.length = 0;
		_drawCount = 0;
		_stateStackPos = -1;
		_state.reset();
	}

	function swapBatchProcessors():BatchProcessor {
		var _loc1_ = _batchProcessorPrev;
		_batchProcessorPrev = _batchProcessorCurr;
		return _batchProcessorCurr = _loc1_;
	}

	public function drawFromCache(startToken:BatchToken, endToken:BatchToken) {
		var _loc3_:MeshBatch = null;
		var _loc4_ = 0;
		var _loc5_ = sMeshSubset;
		if (!startToken.equals(endToken)) {
			if (!_batchProcessorPrev.frameFinished) {
				return;
			}
			pushState();
			_loc4_ = startToken.batchID;
			while (_loc4_ <= endToken.batchID) {
				_loc3_ = _batchProcessorPrev.getBatchAt(_loc4_);
				_loc5_.setTo();
				if (_loc4_ == startToken.batchID) {
					_loc5_.vertexID = startToken.vertexID;
					_loc5_.indexID = startToken.indexID;
					_loc5_.numVertices = _loc3_.numVertices - _loc5_.vertexID;
					_loc5_.numIndices = _loc3_.numIndices - _loc5_.indexID;
				}
				if (_loc4_ == endToken.batchID) {
					_loc5_.numVertices = endToken.vertexID - _loc5_.vertexID;
					_loc5_.numIndices = endToken.indexID - _loc5_.indexID;
				}
				if (_loc5_.numVertices != 0) {
					_state.alpha = 1;
					_state.blendMode = _loc3_.blendMode;
					_batchProcessor.addMesh(_loc3_, _state, _loc5_, true);
				}
				_loc4_++;
			}
			popState();
		}
	}

	public function excludeFromCache(object:DisplayObject) {
		if (object != null) {
			_batchCacheExclusions[_batchCacheExclusions.length] = object;
		}
	}

	function drawBatch(meshBatch:MeshBatch) {
		pushState();
		state.blendMode = meshBatch.blendMode;
		state.modelviewMatrix.identity();
		state.alpha = 1;
		meshBatch.render(this);
		popState();
	}

	public function prepareToDraw() {
		applyBlendMode();
		applyRenderTarget();
		applyClipRect();
		applyCulling();
		applyDepthTest();
	}

	public function clear(rgb:UInt = (0 : UInt), alpha:Float = 0) {
		applyRenderTarget();
		stencilReferenceValue = (127 : UInt);
		RenderUtil.clear(rgb, alpha, 1, (127 : UInt));
	}

	public function present() {
		_state.renderTarget = null;
		_actualRenderTarget = null;
		_context.present();
	}

	function applyBlendMode() {
		var _loc1_ = _state.blendMode;
		if (_loc1_ != _actualBlendMode) {
			BlendMode.get(_state.blendMode).activate();
			_actualBlendMode = _loc1_;
		}
	}

	function applyCulling() {
		var _loc1_ = _state.culling;
		if (_loc1_ != _actualCulling) {
			_context.setCulling(_loc1_);
			_actualCulling = _loc1_;
		}
	}

	function applyDepthTest() {
		var _loc1_ = _state.depthMask;
		var _loc2_ = _state.depthTest;
		if (_loc1_ != _actualDepthMask || _loc2_ != _actualDepthTest) {
			_context.setDepthTest(_loc1_, _loc2_);
			_actualDepthMask = _loc1_;
			_actualDepthTest = _loc2_;
		}
	}

	function applyRenderTarget() {
		var _loc3_ = 0;
		var _loc1_ = false;
		var _loc4_ = _state.renderTargetBase;
		var _loc2_ = _state.renderTargetOptions;
		if (_loc4_ != _actualRenderTarget || _loc2_ != _actualRenderTargetOptions) {
			if (_loc4_ != null) {
				_loc3_ = _state.renderTargetAntiAlias;
				_loc1_ = _state.renderTargetSupportsDepthAndStencil;
				_context.setRenderToTexture(_loc4_, _loc1_, _loc3_);
			} else {
				_context.setRenderToBackBuffer();
			}
			_context.setStencilReferenceValue(stencilReferenceValue);
			_actualRenderTargetOptions = _loc2_;
			_actualRenderTarget = _loc4_;
		}
	}

	function applyClipRect() {
		var _loc5_ = 0;
		var _loc3_ = 0;
		var _loc4_:Matrix3D = null;
		var _loc2_:Texture = null;
		var _loc1_ = _state.clipRect;
		if (_loc1_ != null) {
			_loc4_ = _state.projectionMatrix3D;
			_loc2_ = _state.renderTarget;
			if (_loc2_ != null) {
				_loc3_ = ASCompat.floatToInt(_loc2_.root.nativeWidth);
				_loc5_ = ASCompat.floatToInt(_loc2_.root.nativeHeight);
			} else {
				_loc3_ = ASCompat.floatToInt(_backBufferWidth);
				_loc5_ = ASCompat.floatToInt(_backBufferHeight);
			}
			MatrixUtil.transformCoords3D(_loc4_, _loc1_.x, _loc1_.y, 0, sPoint3D);
			sPoint3D.project();
			sClipRect.x = (sPoint3D.x * 0.5 + 0.5) * _loc3_;
			sClipRect.y = (0.5 - sPoint3D.y * 0.5) * _loc5_;
			MatrixUtil.transformCoords3D(_loc4_, _loc1_.right, _loc1_.bottom, 0, sPoint3D);
			sPoint3D.project();
			sClipRect.right = (sPoint3D.x * 0.5 + 0.5) * _loc3_;
			sClipRect.bottom = (0.5 - sPoint3D.y * 0.5) * _loc5_;
			sBufferRect.setTo(0, 0, _loc3_, _loc5_);
			RectangleUtil.intersect(sClipRect, sBufferRect, sScissorRect);
			if (sScissorRect.width < 1 || sScissorRect.height < 1) {
				sScissorRect.setTo(0, 0, 1, 1);
			}
			_context.setScissorRectangle(sScissorRect);
		} else {
			_context.setScissorRectangle(null);
		}
	}

	public function refreshBackBufferSize(scaleFactor:Float) {
		_backBufferWidth = _context.backBufferWidth;
		_backBufferHeight = _context.backBufferHeight;
		_backBufferScaleFactor = scaleFactor;
	}

	@:isVar public var drawCount(get, set):Int;

	public function get_drawCount():Int {
		return _drawCount;
	}

	function set_drawCount(value:Int):Int {
		return _drawCount = value;
	}

	@:isVar public var stencilReferenceValue(get, set):UInt;

	public function get_stencilReferenceValue():UInt {
		var _loc1_:ASObject = _state.renderTarget != null ? _state.renderTargetBase : this;
		if (_stencilReferenceValues.exists(_loc1_)) {
			return (ASCompat.toInt(_stencilReferenceValues[_loc1_]) : UInt);
		}
		return (127 : UInt);
	}

	function set_stencilReferenceValue(value:UInt):UInt {
		var _loc2_:ASObject = _state.renderTarget != null ? _state.renderTargetBase : this;
		_stencilReferenceValues[_loc2_] = value;
		if (contextValid) {
			_context.setStencilReferenceValue(value);
		}
		return value;
	}

	@:isVar public var cacheEnabled(get, set):Bool;

	public function get_cacheEnabled():Bool {
		return _batchProcessor == _batchProcessorCurr;
	}

	function set_cacheEnabled(value:Bool):Bool {
		if (value != cacheEnabled) {
			finishMeshBatch();
			if (value) {
				_batchProcessor = _batchProcessorCurr;
			} else {
				_batchProcessor = _batchProcessorSpec;
			}
		}
		return value;
	}

	@:isVar public var state(get, never):RenderState;

	public function get_state():RenderState {
		return _state;
	}

	@:isVar public var stage3D(get, never):Stage3D;

	public function get_stage3D():Stage3D {
		return _stage3D;
	}

	@:isVar public var context(get, never):Context3D;

	public function get_context():Context3D {
		return _context;
	}

	@:isVar public var frameID(get, set):UInt;

	public function set_frameID(value:UInt):UInt {
		return _frameID = value;
	}

	function get_frameID():UInt {
		return _batchProcessor == _batchProcessorCurr ? _frameID : (0 : UInt);
	}

	@:isVar public var pixelSize(get, set):Float;

	public function get_pixelSize():Float {
		return _pixelSize;
	}

	function set_pixelSize(value:Float):Float {
		return _pixelSize = value;
	}

	@:isVar public var shareContext(get, set):Bool;

	public function get_shareContext():Bool {
		return _shareContext;
	}

	function set_shareContext(value:Bool):Bool {
		return _shareContext = value;
	}

	@:isVar public var enableErrorChecking(get, set):Bool;

	public function get_enableErrorChecking():Bool {
		return _enableErrorChecking;
	}

	function set_enableErrorChecking(value:Bool):Bool {
		_enableErrorChecking = value;
		if (_context != null) {
			_context.enableErrorChecking = value;
		}
		if (value) {}
		return value;
	}

	@:isVar public var backBufferWidth(get, never):Int;

	public function get_backBufferWidth():Int {
		return ASCompat.floatToInt(_backBufferWidth);
	}

	@:isVar public var backBufferHeight(get, never):Int;

	public function get_backBufferHeight():Int {
		return ASCompat.floatToInt(_backBufferHeight);
	}

	@:isVar public var backBufferScaleFactor(get, never):Float;

	public function get_backBufferScaleFactor():Float {
		return _backBufferScaleFactor;
	}

	@:isVar public var contextValid(get, never):Bool;

	public function get_contextValid():Bool {
		var _loc1_:String = null;
		if (_context != null) {
			_loc1_ = _context.driverInfo;
			return _loc1_ != null && _loc1_ != "" && _loc1_ != "Disposed";
		}
		return false;
	}

	@:isVar public var profile(get, never):String;

	public function get_profile():String {
		if (_context != null) {
			return _context.profile;
		}
		return null;
	}

	@:isVar public var sharedData(get, never):ASDictionary<ASAny, ASAny>;

	public function get_sharedData():ASDictionary<ASAny, ASAny> {
		var _loc1_ = ASDictionary.asDictionary(sSharedData[stage3D]);
		if (_loc1_ == null) {
			_loc1_ = new ASDictionary<ASAny, ASAny>();
			sSharedData[stage3D] = _loc1_;
		}
		return _loc1_;
	}

	@:isVar var programs(get, never):ASDictionary<ASAny, ASAny>;

	function get_programs():ASDictionary<ASAny, ASAny> {
		var _loc1_ = ASDictionary.asDictionary(ASDictionary.getString(sharedData, "starling.rendering.Painter.Programs"));
		if (_loc1_ == null) {
			_loc1_ = new ASDictionary<ASAny, ASAny>();
			sharedData["starling.rendering.Painter.Programs"] = _loc1_;
		}
		return _loc1_;
	}
}
