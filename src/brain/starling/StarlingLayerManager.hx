package brain.starling;

import brain.facade.Facade;
import brain.logger.Logger;
import brain.starling.swfConverter.BakeScheduler;
import brain.starling.swfConverter.BakedPages;
import flash.display.Sprite;
import flash.display.Stage;
import flash.geom.Rectangle;
import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.display.Stage;
import starling.utils.Color;
import starling.utils.Pool;
import starling.utils.SystemUtil;

class StarlingLayerManager {
	static inline final LAYER_BACKGROUND = "background";

	static inline final LAYER_GROUND = "ground";

	static inline final LAYER_SORTED = "sorted";

	static inline final LAYER_FOREGROUND = "foreground";

	static inline final LAYER_OVERFADE = "overfade";

	static inline final LAYER_TWEEN = "tween";

	static inline final LAYER_STARLING_OVERLAY = "starlingOverlay";

	static inline final LAYER_HUD = "hud";

	var mStarling:Starling;

	var mDBFacade:Facade;

	var mSourceCache:StarlingSourceCache;

	var mWorldCameraOffsetX:Float = 0;

	var mWorldCameraOffsetY:Float = 0;

	var mLayerMap:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mLayers:Vector<StarlingLayer>;

	var mOnContextReady:ASFunction;

	public function new(inFacade:Facade, stage:flash.display.Stage, designWidth:Float, designHeight:Float, onContextReady:ASFunction = null) {
		mDBFacade = inFacade;
		mOnContextReady = onContextReady;
		mSourceCache = new StarlingSourceCache();
		mLayers = new Vector<StarlingLayer>();
		init(stage, designWidth, designHeight);
	}

	static function keepAddOrder(a:DisplayObject, b:DisplayObject):Int {
		return 0;
	}

	@:isVar public var worldCameraOffsetX(get, never):Float;

	public function get_worldCameraOffsetX():Float {
		return mWorldCameraOffsetX;
	}

	@:isVar public var worldCameraOffsetY(get, never):Float;

	public function get_worldCameraOffsetY():Float {
		return mWorldCameraOffsetY;
	}

	public function init(stage:flash.display.Stage, designWidth:Float, designHeight:Float) {
		mStarling = new Starling(starling.display.Sprite, stage);
		mStarling.stage.stageWidth = ASCompat.floatToInt(designWidth);
		mStarling.stage.stageHeight = ASCompat.floatToInt(designHeight);
		mStarling.stage.color = (0 : UInt);
		mStarling.shareContext = true;
		mStarling.addEventListener("rootCreated", onRootCreated);
	}

	public function isReady():Bool {
		return mStarling.isStarted;
	}

	@:isVar public var starlingInstance(get, never):Starling;

	public function get_starlingInstance():Starling {
		return mStarling;
	}

	public function toggleStats() {
		mStarling.showStats = !mStarling.showStats;
	}

	public function toggleStatsAt(horizontalAlign:String = "right", verticalAlign:String = "center", scale:Float = 5) {
		if (mStarling.showStats) {
			mStarling.showStats = false;
		} else {
			mStarling.showStatsAt(horizontalAlign, verticalAlign, scale);
		}
	}

	public function cleanLayers() {
		var _loc1_:StarlingLayer;
		final __ax4_iter_88 = mLayers;
		if (checkNullIteratee(__ax4_iter_88))
			for (_tmp_ in __ax4_iter_88) {
				_loc1_ = _tmp_;
				if (!(_loc1_.sortIndex == 36 || _loc1_.sortIndex == 64)) {
					_loc1_.clean();
				}
			}
	}

	@:isVar public var layers(get, never):Vector<StarlingLayer>;

	public function get_layers():Vector<StarlingLayer> {
		return mLayers;
	}

	@:isVar public var starlingStage(get, never):Stage;

	public function get_starlingStage():Stage {
		return mStarling.stage;
	}

	@:isVar public var viewPort(get, never):Rectangle;

	public function get_viewPort():Rectangle {
		return mStarling.viewPort;
	}

	@:isVar public var juggler(get, never):Juggler;

	public function get_juggler():Juggler {
		return mStarling.juggler_instance;
	}

	public function getLayer(inIndex:Int):StarlingLayer {
		return ASCompat.coerce(ASDictionary.getInt(mLayerMap, inIndex), brain.starling.StarlingLayer);
	}

	function onRootCreated(event:ASObject) {
		Logger.info("StarlingLayerManager: On root created! Start layer initialization...");
		configureBackBuffer();
		mStarling.addEventListener("context3DCreate", onContextRestored);
		var _loc2_ = mStarling.nativeOverlay;
		var _loc4_ = mDBFacade.scalingRoot;
		_loc2_.scaleX = _loc4_.scaleX;
		_loc2_.scaleY = _loc4_.scaleY;
		_loc2_.x = _loc4_.x;
		_loc2_.y = _loc4_.y;
		while (_loc4_.numChildren > 0) {
			_loc2_.addChild(_loc4_.getChildAt(0));
		}
		mDBFacade.stageRef.removeChild(mDBFacade.scalingRoot);
		mDBFacade.scalingRoot = _loc2_;
		Logger.info("StarlingLayerManager: NativeOverlay swap complete!");
		var _loc3_ = mDBFacade.featureFlags.getFlagValue("bake-static-layers");
		createLayer(5, "ground", "none").bakeStaticImages = _loc3_;
		createLayer(10, "background", "normal", false, StarlingLayer.compareByY).bakeStaticImages = _loc3_;
		createLayer(20, "sorted", "normal", true);
		createLayer(30, "foreground", "normal");
		createLayer(46, "overfade", "normal");
		createLayer(50, "tween", "normal", false, null, true);
		BakeScheduler.enabled = mDBFacade.featureFlags.getFlagValue("starling-overlays")
			|| mDBFacade.featureFlags.getFlagValue("starling-hud");
		Logger.info("StarlingLayerManager: Game layer instantiated!");
		mStarling.start();
		Logger.info("StarlingLayerManager: Starling started!");
		if (mOnContextReady != null) {
			mOnContextReady();
			mOnContextReady = null;
		}
	}

	function createLayer(inSortIndex:Int, inName:String, inBlendMode:String, inSortEveryFrame:Bool = false, inCustomSortFunction:ASFunction = null,
			inScreenSpace:Bool = false):StarlingLayer {
		var _loc8_ = new StarlingLayer(inSortIndex, inName, inBlendMode, inSortEveryFrame, inCustomSortFunction, inScreenSpace);
		var _loc7_ = ASCompat.reinterpretAs(mStarling.root, starling.display.Sprite);
		mLayerMap[inSortIndex] = _loc8_;
		mLayers.push(_loc8_);
		_loc7_.addChild(_loc8_);
		return _loc8_;
	}

	@:isVar public var starlingOverlayLayer(get, never):StarlingLayer;

	public function get_starlingOverlayLayer():StarlingLayer {
		return overlayLayer(36, "starlingOverlay", keepAddOrder, false);
	}

	@:isVar public var hudLayer(get, never):StarlingLayer;

	public function get_hudLayer():StarlingLayer {
		return overlayLayer(64, "hud", null, true);
	}

	function overlayLayer(sortIndex:Int, name:String, sort:ASFunction, screenSpace:Bool):StarlingLayer {
		var _loc7_ = ASCompat.coerce(ASDictionary.getInt(mLayerMap, sortIndex), brain.starling.StarlingLayer);
		var _loc6_ = mStarling != null ? ASCompat.reinterpretAs(mStarling.root, starling.display.Sprite) : null;
		if (_loc7_ != null || _loc6_ == null) {
			return _loc7_;
		}
		_loc7_ = new StarlingLayer(sortIndex, name, "normal", false, sort, screenSpace);
		var _loc5_ = 0;
		while (_loc5_ < _loc6_.numChildren
			&& Std.isOfType(_loc6_.getChildAt(_loc5_), StarlingLayer)
			&& cast(_loc6_.getChildAt(_loc5_), StarlingLayer).sortIndex < sortIndex) {
			_loc5_++;
		}
		_loc6_.addChildAt(_loc7_, _loc5_);
		mLayerMap[sortIndex] = _loc7_;
		mLayers.push(_loc7_);
		BakedPages.attach(mStarling);
		return _loc7_;
	}

	function onContextRestored(event:ASObject) {
		configureBackBuffer();
		BakedPages.restoreAll();
		if (mSourceCache != null) {
			mSourceCache.restoreSources();
		}
	}

	function configureBackBuffer() {
		var _loc2_ = mStarling._context;
		if (_loc2_ == null) {
			return;
		}
		var _loc1_ = mStarling.viewPort;
		mStarling.stage3D.x = _loc1_.x;
		mStarling.stage3D.y = _loc1_.y;
		_loc2_.configureBackBuffer(ASCompat.floatToInt(_loc1_.width), ASCompat.floatToInt(_loc1_.height), mStarling.antiAliasing,
			SystemUtil.supportsDepthAndStencil);
	}

	public function syncWorldTransform(worldTransformNode:flash.display.Sprite) {
		if (!isReady()) {
			return;
		}
		var _loc5_ = Pool.getMatrix();
		_loc5_.copyFrom(worldTransformNode.transform.matrix);
		_loc5_.concat(worldTransformNode.parent.transform.matrix);
		var _loc6_ = _loc5_.tx;
		var _loc3_ = _loc5_.ty;
		var _loc7_ = 1 / mStarling._contentScaleFactor;
		if (_loc7_ > 0 && Math.isFinite(_loc7_)) {
			_loc5_.tx = Math.fround(_loc5_.tx / _loc7_) * _loc7_;
			_loc5_.ty = Math.fround(_loc5_.ty / _loc7_) * _loc7_;
		}
		mWorldCameraOffsetX = _loc6_ - _loc5_.tx;
		mWorldCameraOffsetY = _loc3_ - _loc5_.ty;
		StarlingLayer.propsCulledLastFrame = 0;
		var _loc4_ = mDBFacade.featureFlags.getFlagValue("bake-static-layers");
		var _loc8_:StarlingLayer;
		final __ax4_iter_89 = mLayers;
		if (checkNullIteratee(__ax4_iter_89))
			for (_tmp_ in __ax4_iter_89) {
				_loc8_ = _tmp_;
				if (_loc8_.sortIndex == 5 || _loc8_.sortIndex == 10) {
					_loc8_.bakeStaticImages = _loc4_;
				}
				_loc8_.evaluateFrameLayerUpdate(_loc5_);
			}
		Pool.putMatrix(_loc5_);
		if (!mStarling.contextValid) {
			return;
		}
		var _loc2_ = mStarling.stage.color;
		mStarling.painter_instance.clear(_loc2_, Color.getAlpha(_loc2_));
		mStarling.nextFrame();
		mStarling.painter_instance.present();
	}

	public function updateViewPort(rect:Rectangle) {
		if (mStarling != null) {
			mStarling.viewPort = rect;
			configureBackBuffer();
		}
	}

	@:isVar public var sourceCache(get, never):StarlingSourceCache;

	public function get_sourceCache():StarlingSourceCache {
		return mSourceCache;
	}

	public function markLayerDirty(inLayerIndex:Int) {
		var _loc2_ = ASCompat.coerce(ASDictionary.getInt(mLayerMap, inLayerIndex), brain.starling.StarlingLayer);
		if (_loc2_ != null) {
			_loc2_.markDirty();
		}
	}

	public function destroy() {
		mOnContextReady = null;
		mStarling.stop(true);
		mStarling.removeEventListener("rootCreated", onRootCreated);
		mStarling.removeEventListener("context3DCreate", onContextRestored);
		BakedPages.disposeAll();
		mStarling = null;
		var _loc1_:StarlingLayer;
		final __ax4_iter_90 = mLayers;
		if (checkNullIteratee(__ax4_iter_90))
			for (_tmp_ in __ax4_iter_90) {
				_loc1_ = _tmp_;
				_loc1_.destroy();
			}
		mLayers.length = 0;
		ASDictionary.getString(mLayerMap, "clear")();
	}
}
