package starling.core;

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Mouse;
import flash.ui.Multitouch;
import starling.animation.Juggler;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.EventDispatcher;
import starling.events.KeyboardEvent;
import starling.events.ResizeEvent;
import starling.events.TouchProcessor;
import starling.rendering.Painter;
import starling.textures.TextureSmoothing;
import starling.utils.Color;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import starling.utils.RectangleUtil;
import starling.utils.SystemUtil;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.ArgumentError;

class Starling extends EventDispatcher {
	public static inline final VERSION = "2.8";

	static var sCurrent:Starling;

	static var sAll:Vector<Starling> = new Vector((0 : UInt));

	var _stage:Stage;

	var _rootClass:Dynamic;

	var _root:starling.display.DisplayObject;

	var _juggler:Juggler;

	var _painter:Painter;

	var _touchProcessor:TouchProcessor;

	var _defaultTextureSmoothing:String;

	var _antiAliasing:Int = 0;

	var _frameTimestamp:Float = Math.NaN;

	var _frameID:UInt = 0;

	var _leftMouseDown:Bool = false;

	var _statsDisplay:StatsDisplay;

	var _statsDisplayAlign:ASObject;

	var _started:Bool = false;

	var _rendering:Bool = false;

	var _supportHighResolutions:Bool = false;

	var _supportBrowserZoom:Bool = false;

	var _skipUnchangedFrames:Bool = false;

	var _showStats:Bool = false;

	var _supportsCursor:Bool = false;

	var _multitouchEnabled:Bool = false;

	var _viewPort:Rectangle;

	var _previousViewPort:Rectangle;

	var _clippedViewPort:Rectangle;

	var _nativeStage:flash.display.Stage;

	var _nativeStageEmpty:Bool = false;

	var _nativeOverlay:Sprite;

	public function new(rootClass:Dynamic, stage:flash.display.Stage, viewPort:Rectangle = null, stage3D:Stage3D = null, renderMode:String = "auto",
			profile:ASObject = "auto") {
		var _loc8_:String = null;
		super();
		if (stage == null) {
			throw new ArgumentError("Stage must not be null");
		}
		if (viewPort == null) {
			viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		if (stage3D == null) {
			stage3D = stage.stage3Ds[0];
		}
		SystemUtil.initialize();
		sAll.push(this);
		makeCurrent();
		_rootClass = rootClass;
		_viewPort = viewPort;
		_previousViewPort = new Rectangle();
		_stage = new Stage(ASCompat.floatToInt(viewPort.width), ASCompat.floatToInt(viewPort.height), stage.color);
		_nativeOverlay = new Sprite();
		_nativeStage = stage;
		_nativeStage.addChild(_nativeOverlay);
		_touchProcessor = new TouchProcessor(_stage);
		_touchProcessor.discardSystemGestures = !SystemUtil.isDesktop;
		_juggler = new Juggler();
		_antiAliasing = 0;
		_defaultTextureSmoothing = "bilinear";
		_supportHighResolutions = false;
		_painter = new Painter(stage3D);
		_frameTimestamp = flash.Lib.getTimer() / 1000;
		_frameID = (1 : UInt);
		_supportsCursor = Mouse.supportsCursor || Capabilities.os.indexOf("Windows") == 0;
		_statsDisplayAlign = {};
		setMultitouchEnabled(Multitouch.inputMode == "touchPoint", true);
		nativeOverlayBlocksTouches = true;
		stage.scaleMode = "noScale";
		stage.align = "TL";
		stage.addEventListener("enterFrame", onEnterFrame, false, 0, true);
		stage.addEventListener("keyDown", onKey, false, 0, true);
		stage.addEventListener("keyUp", onKey, false, 0, true);
		stage.addEventListener("resize", onResize, false, 0, true);
		stage.addEventListener("mouseLeave", onMouseLeave, false, 0, true);
		stage.addEventListener("activate", onActivate, false, 0, true);
		stage3D.addEventListener("context3DCreate", onContextCreated, false, 10, true);
		stage3D.addEventListener("error", onStage3DError, false, 10, true);
		var _loc7_ = ASCompat.parseInt(SystemUtil.version.split(",").shift());
		if (_loc7_ < 19) {
			_loc8_ = SystemUtil.isAIR ? "Adobe AIR" : "Flash Player";
			stopWithFatalError("Your " + _loc8_ + " installation is outdated. " + "This software requires at least version 19.");
		} else if (_painter.shareContext) {
			ASCompat.setTimeout(initialize, 1);
		} else {
			_painter.requestContext3D(renderMode, profile);
		}
	}

	@:isVar public static var current(get, never):Starling;

	static public function get_current():Starling {
		return sCurrent;
	}

	@:isVar public static var all(get, never):Vector<Starling>;

	static public function get_all():Vector<Starling> {
		return sAll;
	}

	@:isVar public static var context(get, never):Context3D;

	static public function get_context():Context3D {
		return sCurrent != null ? sCurrent._context : null;
	}

	@:isVar public static var juggler(get, never):Juggler;

	static public function get_juggler():Juggler {
		return sCurrent != null ? sCurrent._juggler : null;
	}

	@:isVar public static var painter(get, never):Painter;

	static public function get_painter():Painter {
		return sCurrent != null ? sCurrent._painter : null;
	}

	@:isVar public static var contentScaleFactor(get, never):Float;

	static public function get_contentScaleFactor():Float {
		return sCurrent != null ? sCurrent._contentScaleFactor : 1;
	}

	@:isVar public static var multitouchEnabled(get, set):Bool;

	static public function get_multitouchEnabled():Bool {
		var _loc3_ = Multitouch.inputMode == "touchPoint";
		var _loc2_ = false;
		var _loc1_:Starling;
		final __ax4_iter_303 = sAll;
		if (checkNullIteratee(__ax4_iter_303))
			for (_tmp_ in __ax4_iter_303) {
				_loc1_ = _tmp_;
				if (_loc1_._multitouchEnabled != _loc3_) {
					_loc2_ = true;
				}
			}
		if (_loc2_) {}
		return _loc3_;
	}

	static function set_multitouchEnabled(value:Bool):Bool {
		var _loc2_:Starling;
		var __ax4_iter_304:Vector<Starling>;
		var _loc4_ = Multitouch.inputMode == "touchPoint";
		Multitouch.inputMode = value ? "touchPoint" : "none";
		var _loc3_ = Multitouch.inputMode == "touchPoint";
		if (_loc4_ != _loc3_) {
			__ax4_iter_304 = sAll;
			if (checkNullIteratee(__ax4_iter_304))
				for (_tmp_ in __ax4_iter_304) {
					_loc2_ = _tmp_;
					_loc2_.setMultitouchEnabled(_loc3_);
				}
		}
		return value;
	}

	@:isVar public static var frameID(get, never):UInt;

	static public function get_frameID():UInt {
		return sCurrent != null ? sCurrent._frameID : (0 : UInt);
	}

	@:isVar public static var currentDefaultTextureSmoothing(get, never):String;

	static public function get_currentDefaultTextureSmoothing():String {
		return sCurrent != null ? sCurrent._defaultTextureSmoothing : "bilinear";
	}

	public function dispose() {
		stop(true);
		_nativeStage.removeEventListener("enterFrame", onEnterFrame, false);
		_nativeStage.removeEventListener("keyDown", onKey, false);
		_nativeStage.removeEventListener("keyUp", onKey, false);
		_nativeStage.removeEventListener("resize", onResize, false);
		_nativeStage.removeEventListener("mouseLeave", onMouseLeave, false);
		_nativeStage.removeEventListener("browserZoomChange", onBrowserZoomChange, false);
		_nativeStage.removeChild(_nativeOverlay);
		stage3D.removeEventListener("context3DCreate", onContextCreated, false);
		stage3D.removeEventListener("context3DCreate", onContextRestored, false);
		stage3D.removeEventListener("error", onStage3DError, false);
		var _loc2_:String;
		final __ax4_iter_305 = getTouchEventTypes(_multitouchEnabled);
		if (checkNullIteratee(__ax4_iter_305))
			for (_tmp_ in __ax4_iter_305) {
				_loc2_ = _tmp_;
				_nativeStage.removeEventListener(_loc2_, onTouch, false);
			}
		_touchProcessor.dispose();
		_stage.dispose();
		_painter.dispose();
		var _loc1_ = sAll.indexOf(this);
		if (_loc1_ != -1) {
			sAll.removeAt(_loc1_);
		}
		if (sCurrent == this) {
			sCurrent = null;
		}
	}

	function initialize() {
		makeCurrent();
		updateViewPort(true);
		dispatchEventWith("context3DCreate", false, context);
		initializeRoot();
		_frameTimestamp = flash.Lib.getTimer() / 1000;
	}

	function initializeRoot() {
		if (_root == null && _rootClass != null) {
			_root = ASCompat.dynamicAs(ASCompat.createInstance(_rootClass, []), starling.display.DisplayObject);
			if (_root == null) {
				throw new Error("Invalid root class: " + _rootClass);
			}
			_stage.addChildAt(_root, 0);
			dispatchEventWith("rootCreated", false, _root);
		}
	}

	public function nextFrame() {
		var _loc1_ = flash.Lib.getTimer() / 1000;
		var _loc2_ = _loc1_ - _frameTimestamp;
		_frameTimestamp = _loc1_;
		if (_loc2_ > 1) {
			_loc2_ = 1;
		}
		if (_loc2_ < 0) {
			_loc2_ = 1 / _nativeStage.frameRate;
		}
		advanceTime(_loc2_);
		render();
	}

	public function advanceTime(passedTime:Float) {
		if (!contextValid) {
			return;
		}
		makeCurrent();
		_touchProcessor.advanceTime(passedTime);
		_stage.advanceTime(passedTime);
		_juggler.advanceTime(passedTime);
	}

	public function render() {
		var _loc5_ = false;
		var _loc1_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc3_ = (0 : UInt);
		if (!contextValid) {
			return;
		}
		makeCurrent();
		updateViewPort();
		var _loc4_ = _stage.requiresRedraw || mustAlwaysRender;
		if (_loc4_) {
			_painter.nextFrame();
			dispatchEventWith("render");
			_loc5_ = _painter.shareContext;
			_loc1_ = _viewPort.width / _stage.stageWidth;
			_loc2_ = _viewPort.height / _stage.stageHeight;
			_loc3_ = _stage.color;
			_painter.pixelSize = 1 / contentScaleFactor;
			_painter.state.setProjectionMatrix(_viewPort.x < 0 ? -_viewPort.x / _loc1_ : 0, _viewPort.y < 0 ? -_viewPort.y / _loc2_ : 0,
				_clippedViewPort.width / _loc1_, _clippedViewPort.height / _loc2_, _stage.stageWidth, _stage.stageHeight, _stage.cameraPosition);
			if (!_loc5_) {
				_painter.clear(_loc3_, Color.getAlpha(_loc3_));
			}
			_stage.render(_painter);
			_painter.finishFrame();
			_painter.frameID = ++_frameID;
			if (!_loc5_) {
				_painter.present();
			}
			dispatchEventWith("renderComplete");
		} else {
			dispatchEventWith("skipFrame");
		}
		if (_statsDisplay != null) {
			_statsDisplay.drawCount = _painter.drawCount;
		}
	}

	function updateViewPort(forceUpdate:Bool = false) {
		var _loc2_ = Math.NaN;
		if (forceUpdate || !RectangleUtil.compare(_viewPort, _previousViewPort)) {
			_previousViewPort.setTo(_viewPort.x, _viewPort.y, _viewPort.width, _viewPort.height);
			updateClippedViewPort();
			updateStatsDisplayPosition();
			_loc2_ = _supportHighResolutions ? _nativeStage.contentsScaleFactor : 1;
			if (_supportBrowserZoom) {
				_loc2_ *= _nativeStage.browserZoomFactor;
			}
			_painter.configureBackBuffer(_clippedViewPort, _loc2_, _antiAliasing, true, _supportBrowserZoom);
			setRequiresRedraw();
		}
	}

	function updateClippedViewPort() {
		var _loc1_ = Pool.getRectangle(0, 0, _nativeStage.stageWidth, _nativeStage.stageHeight);
		_clippedViewPort = RectangleUtil.intersect(_viewPort, _loc1_, _clippedViewPort);
		if (_clippedViewPort.width < 32) {
			_clippedViewPort.width = 32;
		}
		if (_clippedViewPort.height < 32) {
			_clippedViewPort.height = 32;
		}
		Pool.putRectangle(_loc1_);
	}

	function updateNativeOverlay() {
		_nativeOverlay.x = _viewPort.x;
		_nativeOverlay.y = _viewPort.y;
		_nativeOverlay.scaleX = _viewPort.width / _stage.stageWidth;
		_nativeOverlay.scaleY = _viewPort.height / _stage.stageHeight;
	}

	public function stopWithFatalError(message:String) {
		var _loc2_ = new Shape();
		_loc2_.graphics.beginFill((0 : UInt), 0.8);
		_loc2_.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
		_loc2_.graphics.endFill();
		var _loc3_ = new TextField();
		var _loc4_ = new TextFormat("Verdana", 14, 16777215);
		_loc4_.align = "center";
		_loc3_.defaultTextFormat = _loc4_;
		_loc3_.wordWrap = true;
		_loc3_.width = _stage.stageWidth * 0.75;
		_loc3_.autoSize = "center";
		_loc3_.text = message;
		_loc3_.x = (_stage.stageWidth - _loc3_.width) / 2;
		_loc3_.y = (_stage.stageHeight - _loc3_.height) / 2;
		_loc3_.background = true;
		_loc3_.backgroundColor = (5570560 : UInt);
		updateNativeOverlay();
		nativeOverlay.addChild(_loc2_);
		nativeOverlay.addChild(_loc3_);
		stop(true);
		dispatchEventWith("fatalError", false, message);
	}

	public function makeCurrent() {
		sCurrent = this;
	}

	public function start() {
		_started = _rendering = true;
		_frameTimestamp = flash.Lib.getTimer() / 1000;
	}

	public function stop(suspendRendering:Bool = false) {
		_started = false;
		_rendering = !suspendRendering;
	}

	public function setRequiresRedraw() {
		_stage.setRequiresRedraw();
	}

	function onStage3DError(event:ErrorEvent) {
		var _loc2_:String = null;
		if (event.errorID == 3702) {
			_loc2_ = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
			stopWithFatalError("Context3D not available! Possible reasons: wrong " + _loc2_ + " or missing device support.");
		} else {
			stopWithFatalError("Stage3D error: " + event.text);
		}
	}

	function onContextCreated(event:Event) {
		stage3D.removeEventListener("context3DCreate", onContextCreated);
		stage3D.addEventListener("context3DCreate", onContextRestored, false, 10, true);
		initialize();
	}

	function onContextRestored(event:Event) {
		updateViewPort(true);
		_painter.setupContextDefaults();
		dispatchEventWith("context3DCreate", false, context);
	}

	function onEnterFrame(event:Event) {
		if (!shareContext) {
			if (_started) {
				nextFrame();
			} else if (_rendering) {
				render();
			}
		}
		updateNativeOverlay();
	}

	function onActivate(event:Event) {
		ASCompat.setTimeout(setRequiresRedraw, 100);
	}

	function onKey(event:flash.events.KeyboardEvent) {
		if (!_started) {
			return;
		}
		var _loc2_ = new KeyboardEvent(event.type, event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey);
		makeCurrent();
		_stage.dispatchEvent(_loc2_);
		if (_loc2_.isDefaultPrevented()) {
			event.preventDefault();
		}
	}

	function onResize(event:Event) {
		var dispatchResizeEvent:() -> Void = null;
		var stageWidth = 0;
		var stageHeight = 0;
		dispatchResizeEvent = function() {
			makeCurrent();
			removeEventListener("context3DCreate", (cast dispatchResizeEvent));
			_stage.dispatchEvent(new ResizeEvent("resize", stageWidth, stageHeight));
		};
		stageWidth = ASCompat.toInt(event.target.stageWidth);
		stageHeight = ASCompat.toInt(event.target.stageHeight);
		if (contextValid) {
			dispatchResizeEvent();
		} else {
			addEventListener("context3DCreate", (cast dispatchResizeEvent));
		}
	}

	function onBrowserZoomChange(event:Event) {
		_painter.refreshBackBufferSize(_nativeStage.contentsScaleFactor * _nativeStage.browserZoomFactor);
	}

	function onMouseLeave(event:Event) {
		_touchProcessor.enqueueMouseLeftStage();
	}

	function onTouch(event:Event) {
		var _loc5_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc6_ = 0;
		var _loc2_:String = null;
		var _loc4_:MouseEvent = null;
		var _loc8_:TouchEvent = null;
		if (!_started) {
			return;
		}
		var _loc9_:Float = 1;
		var _loc7_:Float = 1;
		var _loc10_:Float = 1;
		if (Std.isOfType(event, MouseEvent)) {
			_loc4_ = ASCompat.reinterpretAs(event, MouseEvent);
			_loc5_ = _loc4_.stageX;
			_loc3_ = _loc4_.stageY;
			_loc6_ = 0;
			if (event.type == "mouseDown") {
				_leftMouseDown = true;
			} else if (event.type == "mouseUp") {
				_leftMouseDown = false;
			}
		} else {
			_loc8_ = ASCompat.reinterpretAs(event, TouchEvent);
			if (_supportsCursor && _loc8_.isPrimaryTouchPoint) {
				return;
			}
			_loc5_ = _loc8_.stageX;
			_loc3_ = _loc8_.stageY;
			_loc6_ = _loc8_.touchPointID;
			_loc9_ = _loc8_.pressure;
			_loc7_ = _loc8_.sizeX;
			_loc10_ = _loc8_.sizeY;
		}
		switch (event.type) {
			case "touchBegin":
				_loc2_ = "began";

			case "touchMove":
				_loc2_ = "moved";

			case "touchEnd":
				_loc2_ = "ended";

			case "mouseDown":
				_loc2_ = "began";

			case "mouseUp":
				_loc2_ = "ended";

			case "mouseMove":
				_loc2_ = _leftMouseDown ? "moved" : "hover";
		}
		_loc5_ = _stage.stageWidth * (_loc5_ - _viewPort.x) / _viewPort.width;
		_loc3_ = _stage.stageHeight * (_loc3_ - _viewPort.y) / _viewPort.height;
		_touchProcessor.enqueue(_loc6_, _loc2_, _loc5_, _loc3_, _loc9_, _loc7_, _loc10_);
		if (event.type == "mouseUp" && _supportsCursor) {
			_touchProcessor.enqueue(_loc6_, "hover", _loc5_, _loc3_);
		}
	}

	function hitTestNativeOverlay(localX:Float, localY:Float):Bool {
		var _loc5_:Point = null;
		var _loc4_:Matrix = null;
		var _loc3_ = false;
		if (_nativeOverlay.numChildren != 0) {
			_loc5_ = Pool.getPoint();
			_loc4_ = Pool.getMatrix(_nativeOverlay.scaleX, 0, 0, _nativeOverlay.scaleY, _nativeOverlay.x, _nativeOverlay.y);
			MatrixUtil.transformCoords(_loc4_, localX, localY, _loc5_);
			_loc3_ = _nativeOverlay.hitTestPoint(_loc5_.x, _loc5_.y, true);
			Pool.putPoint(_loc5_);
			Pool.putMatrix(_loc4_);
			return _loc3_;
		}
		return false;
	}

	function setMultitouchEnabled(value:Bool, forceUpdate:Bool = false) {
		var _loc5_:String;
		var _loc3_:String;
		var _loc6_:Array<ASAny> = null;
		var _loc4_:Array<ASAny> = null;
		if (forceUpdate || value != _multitouchEnabled) {
			_loc6_ = getTouchEventTypes(_multitouchEnabled);
			_loc4_ = getTouchEventTypes(value);
			if (checkNullIteratee(_loc6_))
				for (_tmp_ in _loc6_) {
					_loc5_ = _tmp_;
					_nativeStage.removeEventListener(_loc5_, onTouch);
				}
			if (checkNullIteratee(_loc4_))
				for (_tmp_ in _loc4_) {
					_loc3_ = _tmp_;
					_nativeStage.addEventListener(_loc3_, onTouch, false, 0, true);
				}
			_touchProcessor.cancelTouches();
			_multitouchEnabled = value;
		}
	}

	function getTouchEventTypes(multitouchEnabled:Bool):Array<ASAny> {
		var _loc2_:Array<ASAny> = [];
		if (multitouchEnabled) {
			ASCompat.ASArray.pushMultiple(_loc2_, "touchBegin", "touchMove", "touchEnd");
		}
		if (!multitouchEnabled || _supportsCursor) {
			ASCompat.ASArray.pushMultiple(_loc2_, "mouseDown", "mouseMove", "mouseUp");
		}
		return _loc2_;
	}

	@:isVar var mustAlwaysRender(get, never):Bool;

	function get_mustAlwaysRender():Bool {
		var _loc2_ = false;
		var _loc1_ = false;
		if (!_skipUnchangedFrames || _painter.shareContext) {
			return true;
		}
		if (SystemUtil.isDesktop && profile != "baselineConstrained") {
			return false;
		}
		_loc2_ = isNativeDisplayObjectEmpty(_nativeStage);
		_loc1_ = !_loc2_ || !_nativeStageEmpty;
		_nativeStageEmpty = _loc2_;
		return _loc1_;
	}

	@:isVar public var isStarted(get, never):Bool;

	public function get_isStarted():Bool {
		return _started;
	}

	@:isVar public var juggler_instance(get, never):Juggler;

	public function get_juggler_instance /*renamed*/ ():Juggler {
		return _juggler;
	}

	@:isVar public var painter_instance(get, never):Painter;

	public function get_painter_instance /*renamed*/ ():Painter {
		return _painter;
	}

	@:isVar public var _context(get, never):Context3D;

	public function get__context /*renamed*/ ():Context3D {
		return _painter.context;
	}

	@:isVar public var simulateMultitouch(get, set):Bool;

	public function get_simulateMultitouch():Bool {
		return _touchProcessor.simulateMultitouch;
	}

	function set_simulateMultitouch(value:Bool):Bool {
		return _touchProcessor.simulateMultitouch = value;
	}

	@:isVar public var enableErrorChecking(get, set):Bool;

	public function get_enableErrorChecking():Bool {
		return _painter.enableErrorChecking;
	}

	function set_enableErrorChecking(value:Bool):Bool {
		return _painter.enableErrorChecking = value;
	}

	@:isVar public var antiAliasing(get, set):Int;

	public function get_antiAliasing():Int {
		return _antiAliasing;
	}

	function set_antiAliasing(value:Int):Int {
		if (_antiAliasing != value) {
			_antiAliasing = value;
			if (contextValid) {
				updateViewPort(true);
			}
		}
		return value;
	}

	@:isVar public var defaultTextureSmoothing(get, set):String;

	public function get_defaultTextureSmoothing():String {
		return _defaultTextureSmoothing;
	}

	function set_defaultTextureSmoothing(value:String):String {
		if (!TextureSmoothing.isValid(value)) {
			throw new ArgumentError("Invalid texture smoothing: " + value);
		}
		return _defaultTextureSmoothing = value;
	}

	@:isVar public var viewPort(get, set):Rectangle;

	public function get_viewPort():Rectangle {
		return _viewPort;
	}

	function set_viewPort(value:Rectangle):Rectangle {
		_viewPort.copyFrom(value);
		return value;
	}

	@:isVar public var _contentScaleFactor(get, never):Float;

	public function get__contentScaleFactor /*renamed*/ ():Float {
		return _viewPort.width * _painter.backBufferScaleFactor / _stage.stageWidth;
	}

	@:isVar public var nativeOverlay(get, never):Sprite;

	public function get_nativeOverlay():Sprite {
		return _nativeOverlay;
	}

	@:isVar public var nativeOverlayBlocksTouches(get, set):Bool;

	public function get_nativeOverlayBlocksTouches():Bool {
		return _touchProcessor.occlusionTest != null;
	}

	function set_nativeOverlayBlocksTouches(value:Bool):Bool {
		if (value != this.nativeOverlayBlocksTouches) {
			_touchProcessor.occlusionTest = value ? hitTestNativeOverlay : null;
		}
		return value;
	}

	@:isVar public var showStats(get, set):Bool;

	public function get_showStats():Bool {
		return _showStats;
	}

	function set_showStats(value:Bool):Bool {
		_showStats = value;
		if (value) {
			showStatsAt(if (ASCompat.toBool(_statsDisplayAlign.horizontal)) _statsDisplayAlign.horizontal else "left",
				if (ASCompat.toBool(_statsDisplayAlign.vertical)) _statsDisplayAlign.vertical else "top");
		} else if (_statsDisplay != null) {
			_statsDisplay.removeFromParent();
		}
		return value;
	}

	public function showStatsAt(horizontalAlign:String = "left", verticalAlign:String = "top", scale:Float = 1) {
		var onRootCreated:() -> Void = null;
		onRootCreated = function() {
			if (_showStats) {
				showStatsAt(horizontalAlign, verticalAlign, scale);
			}
			removeEventListener("rootCreated", (cast onRootCreated));
		};
		_showStats = true;
		ASCompat.setProperty(_statsDisplayAlign, "horizontal", horizontalAlign);
		ASCompat.setProperty(_statsDisplayAlign, "vertical", verticalAlign);
		if (context == null) {
			addEventListener("rootCreated", (cast onRootCreated));
		} else {
			if (_statsDisplay == null) {
				_statsDisplay = new StatsDisplay();
				_statsDisplay.touchable = false;
			}
			_stage.addChild(_statsDisplay);
			_statsDisplay.scaleX = _statsDisplay.scaleY = scale;
			_statsDisplay.showSkipped = _skipUnchangedFrames;
			updateClippedViewPort();
			updateStatsDisplayPosition();
		}
	}

	function updateStatsDisplayPosition() {
		if (!_showStats || _statsDisplay == null) {
			return;
		}
		var _loc5_:String = _statsDisplayAlign.horizontal;
		var _loc2_:String = _statsDisplayAlign.vertical;
		var _loc1_ = _viewPort.width / _stage.stageWidth;
		var _loc3_ = _viewPort.height / _stage.stageHeight;
		var _loc4_ = Pool.getRectangle(_viewPort.x < 0 ? -_viewPort.x / _loc1_ : 0, _viewPort.y < 0 ? -_viewPort.y / _loc3_ : 0,
			_clippedViewPort.width / _loc1_, _clippedViewPort.height / _loc3_);
		if (_loc5_ == "left") {
			_statsDisplay.x = _loc4_.x;
		} else if (_loc5_ == "right") {
			_statsDisplay.x = _loc4_.right - _statsDisplay.width;
		} else {
			if (_loc5_ != "center") {
				throw new ArgumentError("Invalid horizontal alignment: " + _loc5_);
			}
			_statsDisplay.x = (_loc4_.right - _statsDisplay.width) / 2;
		}
		if (_loc2_ == "top") {
			_statsDisplay.y = _loc4_.y;
		} else if (_loc2_ == "bottom") {
			_statsDisplay.y = _loc4_.bottom - _statsDisplay.height;
		} else {
			if (_loc2_ != "center") {
				throw new ArgumentError("Invalid vertical alignment: " + _loc2_);
			}
			_statsDisplay.y = (_loc4_.bottom - _statsDisplay.height) / 2;
		}
		Pool.putRectangle(_loc4_);
	}

	@:isVar public var stage(get, never):Stage;

	public function get_stage():Stage {
		return _stage;
	}

	@:isVar public var stage3D(get, never):Stage3D;

	public function get_stage3D():Stage3D {
		return _painter.stage3D;
	}

	@:isVar public var nativeStage(get, never):flash.display.Stage;

	public function get_nativeStage():flash.display.Stage {
		return _nativeStage;
	}

	@:isVar public var root(get, never):starling.display.DisplayObject;

	public function get_root():starling.display.DisplayObject {
		return _root;
	}

	@:isVar public var rootClass(get, set):Dynamic;

	public function get_rootClass():Dynamic {
		return _rootClass;
	}

	function set_rootClass(value:Dynamic):Dynamic {
		if (_rootClass != null && _root != null) {
			throw new Error("Root class may not change after root has been instantiated");
		}
		if (_rootClass == null) {
			_rootClass = value;
			if (context != null) {
				initializeRoot();
			}
		}
		return value;
	}

	@:isVar public var shareContext(get, set):Bool;

	public function get_shareContext():Bool {
		return _painter.shareContext;
	}

	function set_shareContext(value:Bool):Bool {
		if (!value) {
			_previousViewPort.setEmpty();
		}
		return _painter.shareContext = value;
	}

	@:isVar public var profile(get, never):String;

	public function get_profile():String {
		return _painter.profile;
	}

	@:isVar public var supportHighResolutions(get, set):Bool;

	public function get_supportHighResolutions():Bool {
		return _supportHighResolutions;
	}

	function set_supportHighResolutions(value:Bool):Bool {
		if (_supportHighResolutions != value) {
			_supportHighResolutions = value;
			if (contextValid) {
				updateViewPort(true);
			}
		}
		return value;
	}

	@:isVar public var supportBrowserZoom(get, set):Bool;

	public function get_supportBrowserZoom():Bool {
		return _supportBrowserZoom;
	}

	function set_supportBrowserZoom(value:Bool):Bool {
		if (_supportBrowserZoom != value) {
			_supportBrowserZoom = value;
			if (contextValid) {
				updateViewPort(true);
			}
			if (value) {
				_nativeStage.addEventListener("browserZoomChange", onBrowserZoomChange, false, 0, true);
			} else {
				_nativeStage.removeEventListener("browserZoomChange", onBrowserZoomChange, false);
			}
		}
		return value;
	}

	@:isVar public var skipUnchangedFrames(get, set):Bool;

	public function get_skipUnchangedFrames():Bool {
		return _skipUnchangedFrames;
	}

	function set_skipUnchangedFrames(value:Bool):Bool {
		_skipUnchangedFrames = value;
		_nativeStageEmpty = false;
		if (_statsDisplay != null) {
			_statsDisplay.showSkipped = value;
		}
		return value;
	}

	@:isVar public var touchProcessor(get, set):TouchProcessor;

	public function get_touchProcessor():TouchProcessor {
		return _touchProcessor;
	}

	function set_touchProcessor(value:TouchProcessor):TouchProcessor {
		if (value == null) {
			throw new ArgumentError("TouchProcessor must not be null");
		}
		if (value != _touchProcessor) {
			_touchProcessor.dispose();
			_touchProcessor = value;
		}
		return value;
	}

	@:isVar public var discardSystemGestures(get, set):Bool;

	public function get_discardSystemGestures():Bool {
		return _touchProcessor.discardSystemGestures;
	}

	function set_discardSystemGestures(value:Bool):Bool {
		return _touchProcessor.discardSystemGestures = value;
	}

	@:isVar public var frameID_instance(get, never):UInt;

	public function get_frameID_instance /*renamed*/ ():UInt {
		return _frameID;
	}

	@:isVar public var contextValid(get, never):Bool;

	public function get_contextValid():Bool {
		return _painter.contextValid;
	}
}

function isNativeDisplayObjectEmpty(object:DisplayObject):Bool {
	var _loc2_:DisplayObjectContainer = null;
	var _loc3_ = 0;
	var _loc4_ = 0;
	if (object == null) {
		return true;
	}
	if (Std.isOfType(object, DisplayObjectContainer)) {
		_loc2_ = ASCompat.reinterpretAs(object, DisplayObjectContainer);
		_loc3_ = _loc2_.numChildren;
		_loc4_ = 0;
		while (_loc4_ < _loc3_) {
			if (!isNativeDisplayObjectEmpty(_loc2_.getChildAt(_loc4_))) {
				return false;
			}
			_loc4_++;
		}
		return true;
	}
	return !object.visible;
}
