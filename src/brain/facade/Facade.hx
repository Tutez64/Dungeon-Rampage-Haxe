package brain.facade;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.AssetRepository;
import brain.camera.BackgroundFader;
import brain.camera.Camera;
import brain.camera.LetterboxEffect;
import brain.clock.GameClock;
import brain.clock.RenderClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.event.EventManager;
import brain.gameObject.GameObjectManager;
import brain.gameObject.View;
import brain.input.InputManager;
import brain.logger.Logger;
import brain.mouseCursor.MouseCursorManager;
import brain.render.FlashRendererFactory;
import brain.render.FlashRenderingBackend;
import brain.render.IRenderingBackend;
import brain.render.RendererFactorySelector;
import brain.render.StarlingRendererFactory;
import brain.render.StarlingRenderingBackend;
import brain.render.tweens.TweeningProxy;
import brain.sceneGraph.SceneGraphManager;
import brain.sound.SoundManager;
import brain.starling.StarlingLayerManager;
import brain.starling.StarlingRollerProvider;
import brain.utils.FeatureFlags;
import brain.utils.TextUtil;
import brain.workLoop.WorkLoopManager;
import brain.jsonRPC.JSONRPCService;
import collections.Map;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.text.TextFormat;

class Facade {
	public static inline final MAX_TICKS_PER_FRAME = 5;

	public static inline final FPS = (24 : UInt);

	public static inline final DESIGN_WIDTH:Float = 1920;

	public static inline final DESIGN_HEIGHT:Float = 1080;

	var mElapsedTime:Float = 0;

	var mStageRef:Stage;

	var mSwfWidth:Float = Math.NaN;

	var mSwfHeight:Float = Math.NaN;

	var mScalingRoot:Sprite;

	var mSceneGraphManager:SceneGraphManager;

	var mInputManager:InputManager;

	var mRealClockWorkManager:WorkLoopManager;

	var mLogicalWorkManager:WorkLoopManager;

	var mPhysicsWorkManager:WorkLoopManager;

	var mPreRenderWorkManager:WorkLoopManager;

	var mLayerRenderWorkManager:WorkLoopManager;

	var mGameObjectManager:GameObjectManager;

	var mEventManager:EventManager;

	var mSoundManager:SoundManager;

	var mCamera:Camera;

	var mAssetRepository:AssetRepository;

	var mMouseCursorManager:MouseCursorManager;

	var mStarlingLayerManager:StarlingLayerManager;

	var mFlashRenderingBackend:FlashRenderingBackend;

	var mStarlingRenderingBackend:StarlingRenderingBackend;

	var mRendererFactorySelector:RendererFactorySelector;

	var mAssetLoadingComponent:AssetLoadingComponent;

	public var mTween:TweeningProxy;

	var mGameClock:GameClock;

	var mRealClock:GameClock;

	public var featureFlags:FeatureFlags;

	var mViewScale:Float = 1;

	var mEventComponent:EventComponent;

	public var cacheVersion:String = "";

	public var versions:ASObject = null;

	public var environmentPrefix:String = "u";

	var mAssetRepositoryClass:Dynamic = AssetRepository;

	var mWantConsole:Bool = false;

	var mWantFramerateEnforcement:Bool = false;

	var mFrameTimes:Vector<Int>;

	var mCurrentTime:Float = 0;

	var mSkippingFrame:Bool = false;

	var mSkippedFrames:Int = 0;

	var mCheaterLogMap:Map;

	var mWallClockTimeElapsed:Float = 0;

	var mGameClockTimeElapsed:Float = 0;

	var mTickCounter:Int = 0;

	var mCheatCount:Int = 0;

	var mRenderTickCounter:Int = 0;

	var mRenderClockTimeElapsed:Float = 0;

	var mTickLength:Float = -1;

	var mFrameAccumulator:Float = 0;

	var mTickAccumulator:Float = 0;

	var mInitialLoginTraceId:String;

	var mSessionInfoString:String = "Loading...";

	var mSessionIdTextField:TextField;

	var mSessionIdVisible:Bool = true;

	var mChildLayer:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	public function new() {
		mFrameTimes = new Vector<Int>();
		mCheaterLogMap = new Map();
	}

	public function fileVersion(filename:String):String {
		if (versions == null) {
			return cacheVersion;
		}
		var _loc2_ = filename.indexOf("../../..") == 0 ? filename.substr(8) : filename;
		return versions[_loc2_] == null ? cacheVersion : versions[_loc2_];
	}

	@:isVar public var stageRef(get, never):Stage;

	public function get_stageRef():Stage {
		return mStageRef;
	}

	@:isVar public var viewWidth(get, never):Float;

	public function get_viewWidth():Float {
		return 1920;
	}

	@:isVar public var viewHeight(get, never):Float;

	public function get_viewHeight():Float {
		return 1080;
	}

	@:isVar public var viewScale(get, never):Float;

	public function get_viewScale():Float {
		return mViewScale;
	}

	@:isVar public var starlingLayerManager(get, never):StarlingLayerManager;

	public function get_starlingLayerManager():StarlingLayerManager {
		return mStarlingLayerManager;
	}

	@:isVar public var flashRenderingBackend(get, never):IRenderingBackend;

	public function get_flashRenderingBackend():IRenderingBackend {
		return mFlashRenderingBackend;
	}

	@:isVar public var starlingRenderingBackend(get, never):IRenderingBackend;

	public function get_starlingRenderingBackend():IRenderingBackend {
		return mStarlingRenderingBackend;
	}

	@:isVar public var rendererFactorySelector(get, never):RendererFactorySelector;

	public function get_rendererFactorySelector():RendererFactorySelector {
		return mRendererFactorySelector;
	}

	@:isVar public var scalingRoot(get, set):Sprite;

	public function get_scalingRoot():Sprite {
		return mScalingRoot;
	}

	function set_scalingRoot(inSprite:Sprite):Sprite {
		return mScalingRoot = inSprite;
	}

	public function designLocalToGlobal(other:DisplayObject, point:Point):Point {
		var _loc3_ = other.localToGlobal(point);
		return mScalingRoot.globalToLocal(_loc3_);
	}

	public function designGlobalToLocal(point:Point):Point {
		var _loc2_ = mScalingRoot.localToGlobal(point);
		return mStageRef.globalToLocal(_loc2_);
	}

	function updateScaling(event:Event = null) {
		var _loc3_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc4_ = Math.min(mStageRef.stageWidth / viewWidth, mStageRef.stageHeight / viewHeight);
		mScalingRoot.scaleX = _loc4_;
		mScalingRoot.scaleY = _loc4_;
		mViewScale = _loc4_;
		mScalingRoot.x = (mStageRef.stageWidth - viewWidth * _loc4_) * 0.5;
		mScalingRoot.y = (mStageRef.stageHeight - viewHeight * _loc4_) * 0.5;
		if (mStarlingRenderingBackend != null) {
			_loc3_ = 1920 * _loc4_;
			_loc2_ = 1080 * _loc4_;
			mStarlingRenderingBackend.updateViewPort(new Rectangle((mStageRef.stageWidth - _loc3_) * 0.5, (mStageRef.stageHeight - _loc2_) * 0.5, _loc3_,
				_loc2_));
		}
	}

	public function addRootDisplayObject(child:DisplayObject, layer:Float = 0):DisplayObject {
		var _loc3_:DisplayObject = null;
		var _loc4_ = Math.NaN;
		var _loc5_:Float = mScalingRoot.numChildren - 1;
		while (_loc5_ >= 0) {
			_loc3_ = mScalingRoot.getChildAt(ASCompat.floatToInt(_loc5_));
			_loc4_ = ASCompat.toNumber(mChildLayer.exists(_loc3_) ? mChildLayer[_loc3_] : 0);
			if (layer >= _loc4_) {
				break;
			}
			_loc5_--;
		}
		mChildLayer[child] = layer;
		return mScalingRoot.addChildAt(child, ASCompat.floatToInt(_loc5_ + 1));
	}

	public function removeRootDisplayObject(child:DisplayObject):DisplayObject {
		mChildLayer.remove(child);
		return mScalingRoot.removeChild(child);
	}

	@:isVar public var camera(get, never):Camera;

	public function get_camera():Camera {
		return mCamera;
	}

	@:isVar public var popupCurtainBlockMouse(get, never):Bool;

	public function get_popupCurtainBlockMouse():Bool {
		return true;
	}

	public function buildEngines() {
		mSceneGraphManager = new SceneGraphManager(this);
		mGameObjectManager = new GameObjectManager(this);
		mInputManager = new InputManager(this);
		mSoundManager = new SoundManager(this);
		mMouseCursorManager = new MouseCursorManager(this);
		mFlashRenderingBackend = new FlashRenderingBackend(this);
		mRendererFactorySelector = new RendererFactorySelector(this);
		mRendererFactorySelector.registerFlashFactory(new FlashRendererFactory(this, mFlashRenderingBackend));
	}

	public function initStarlingRendering() {
		var starlingFactory:StarlingRendererFactory;
		mStarlingRenderingBackend = new StarlingRenderingBackend(this);
		if (mAssetLoadingComponent == null) {
			mAssetLoadingComponent = new AssetLoadingComponent(this);
		}
		mStarlingRenderingBackend.onContextReady = function() {
			mStarlingRenderingBackend.contextReady = true;
			mAssetLoadingComponent.initializeStarlingAssetManager();
		};
		mStarlingRenderingBackend.init(this, mStageRef, 1920, 1080);
		mStarlingLayerManager = mStarlingRenderingBackend.starlingLayerManager;
		starlingFactory = new StarlingRendererFactory(this, mStarlingRenderingBackend);
		starlingFactory.sourceCache = mStarlingLayerManager.sourceCache;
		mRendererFactorySelector.registerStarlingFactory(starlingFactory);
		mRendererFactorySelector.setLayerBackend(5, "starling");
		StarlingRollerProvider.install(mStarlingLayerManager);
		updateScaling();
	}

	public function syncStarlingWorld(clock:GameClock) {
		if (mStarlingRenderingBackend != null && mSceneGraphManager != null) {
			mStarlingRenderingBackend.syncWorldTransform(mSceneGraphManager.worldTransformNode);
		}
	}

	public function mainLoop(event:Event) {
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		if (mTickLength == -1) {
			mTickLength = mGameClock.tickLength;
		}
		var _loc11_ = mGameClock.update();
		var _loc8_ = mRealClock.update();
		mElapsedTime += _loc11_;
		var _loc5_ = (0 : UInt);
		mRealClock.gameTime = mRealClock.realTime;
		mRealClockWorkManager.update(mRealClock);
		var _loc7_ = false;
		mSkippingFrame = false;
		var _loc2_ = mCurrentTime;
		mCurrentTime = Date.now().getTime();
		var _loc6_ = ASCompat.floatToInt(mCurrentTime - _loc2_);
		_loc6_ = ASCompat.floatToInt(Math.max(0, _loc6_));
		mWallClockTimeElapsed += _loc6_;
		mGameClockTimeElapsed += _loc11_;
		mRenderClockTimeElapsed += _loc8_;
		if (mWallClockTimeElapsed > 1000) {
			_loc9_ = mGameClockTimeElapsed * 1000;
			_loc10_ = _loc9_ / mWallClockTimeElapsed;
			if (_loc10_ > 1.1) {
				mTickLength = mGameClock.tickLength * _loc10_;
				mCheatCount = mCheatCount + 1;
				if (mCheatCount > 60) {
					iamaCheater("testing_speed_hack_definite");
				} else if (mCheatCount > 3) {
					iamaCheater("testing_speed_hack_probable");
				}
			} else {
				mTickLength = mGameClock.tickLength;
				mCheatCount = 0;
			}
			mGameClockTimeElapsed = 0;
			mRenderClockTimeElapsed = 0;
			mWallClockTimeElapsed = 0;
			mTickCounter = 0;
			mRenderTickCounter = 0;
		}
		while (mElapsedTime >= mTickLength && _loc5_ < 5) {
			mCamera.beginTick();
			View.beginTickAll();
			mTickCounter = mTickCounter + 1;
			mTickAccumulator = mTickAccumulator + 1;
			mLogicalWorkManager.update(mGameClock);
			mPhysicsWorkManager.update(mGameClock);
			mPreRenderWorkManager.update(mGameClock);
			flushInputs();
			mElapsedTime -= mTickLength;
			mGameClock.gameTime += ASCompat.floatToInt(mTickLength * 1000);
			_loc5_++;
		}
		var _loc3_ = Math.min(1, mElapsedTime / mTickLength);
		var _loc4_ = mRealClock.tickLength;
		mRenderTickCounter = mRenderTickCounter + 1;
		mFrameAccumulator = mFrameAccumulator + 1;
		mCamera.renderInterpolated(_loc3_);
		View.renderInterpolatedAll(_loc3_);
		mLayerRenderWorkManager.update(mRealClock);
		syncStarlingWorld(mRealClock);
		mRealClock.gameTime += ASCompat.floatToInt(_loc4_ * 1000);
		if (_loc5_ >= 5) {
			mElapsedTime = 0;
			_loc3_ = 0;
		}
	}

	function flushInputs() {
		mInputManager.flush();
	}

	public function iamaCheater(reason:String) {
		if (!mCheaterLogMap.hasKey(reason)) {
			mCheaterLogMap.add(reason, true);
			logCheater(reason);
		}
	}

	public function logCheater(reason:String) {}

	@:isVar public var skippingFrame(get, never):Bool;

	public function get_skippingFrame():Bool {
		return mSkippingFrame;
	}

	public function init(stageRef:Stage) {
		mStageRef = stageRef;
		mSwfWidth = viewWidth;
		mSwfHeight = viewHeight;
		mScalingRoot = new Sprite();
		mScalingRoot.name = "scalingRoot";
		mStageRef.addChild(mScalingRoot);
		EventListeners.add(mStageRef, "resize", updateScaling);
		updateScaling();
		Logger.init(mStageRef, true);
		mGameClock = new GameClock(1 / 24);
		mRealClock = new RenderClock();
		mEventManager = new EventManager(this);
		mAssetRepository = ASCompat.coerce(ASCompat.createInstance(mAssetRepositoryClass, [this]), brain.assetRepository.AssetRepository);
		featureFlags = new FeatureFlags();
		TextUtil.featureFlags = featureFlags;
		mRealClockWorkManager = new WorkLoopManager(mRealClock);
		mLogicalWorkManager = new WorkLoopManager(mGameClock);
		mPhysicsWorkManager = new WorkLoopManager(mGameClock);
		mPreRenderWorkManager = new WorkLoopManager(mGameClock);
		mLayerRenderWorkManager = new WorkLoopManager(mRealClock);
		mTween = new TweeningProxy(this);
		mCamera = new Camera(this, new BackgroundFader(this), new LetterboxEffect(this));
		mEventComponent = new EventComponent(this);
	}

	public function run() {
		mEventComponent.addListener("enterFrame", this.mainLoop);
	}

	@:isVar public var inputManager(get, never):InputManager;

	public function get_inputManager():InputManager {
		return mInputManager;
	}

	@:isVar public var gameClock(get, never):GameClock;

	public function get_gameClock():GameClock {
		return mGameClock;
	}

	@:isVar public var realClock(get, never):GameClock;

	public function get_realClock():GameClock {
		return mRealClock;
	}

	@:isVar public var initialLoginTraceId(get, set):String;

	public function get_initialLoginTraceId():String {
		return mInitialLoginTraceId;
	}

	function set_initialLoginTraceId(value:String):String {
		mInitialLoginTraceId = value;
		JSONRPCService.initialLoginTraceId = value;
		displaySessionId();
		return value;
	}

	@:isVar public var sessionInfoString(get, never):String;

	public function get_sessionInfoString():String {
		return mSessionInfoString;
	}

	public function displaySessionId() {
		var _loc2_:Array<ASAny> = null;
		var _loc4_ = "";
		if (mInitialLoginTraceId == null || mInitialLoginTraceId == "") {
			_loc4_ = "Loading...";
		} else {
			_loc2_ = (cast mInitialLoginTraceId.split("-"));
			if (_loc2_.length >= 2) {
				_loc4_ = Std.string(_loc2_[1]).substr(-16);
			} else {
				_loc4_ = mInitialLoginTraceId;
			}
		}
		mSessionInfoString = environmentPrefix + ":" + _loc4_;
		var _loc1_ = new TextField();
		_loc1_.text = mSessionInfoString;
		_loc1_.selectable = false;
		_loc1_.autoSize = "left";
		_loc1_.y = -2;
		var _loc3_ = new TextFormat();
		_loc3_.bold = true;
		_loc3_.font = "Verdana";
		_loc3_.color = 15660015;
		_loc3_.size = 18;
		_loc1_.setTextFormat(_loc3_);
		_loc1_.alpha = 0.65;
		_loc1_.cacheAsBitmap = true;
		_loc1_.name = "SessionIdTextField";
		_loc1_.visible = mSessionIdVisible;
		if (mSessionIdTextField != null && mSessionIdTextField.parent == mScalingRoot) {
			removeRootDisplayObject(mSessionIdTextField);
		}
		mSessionIdTextField = _loc1_;
		addRootDisplayObject(_loc1_, 1002);
	}

	@:isVar public var sessionIdVisible(never, set):Bool;

	public function set_sessionIdVisible(value:Bool):Bool {
		mSessionIdVisible = value;
		if (mSessionIdTextField != null) {
			mSessionIdTextField.visible = value;
		}
		return value;
	}

	@:isVar public var eventManager(get, never):EventManager;

	public function get_eventManager():EventManager {
		return mEventManager;
	}

	@:isVar public var gameObjectManager(get, never):GameObjectManager;

	public function get_gameObjectManager():GameObjectManager {
		return mGameObjectManager;
	}

	@:isVar public var sceneGraphManager(get, never):SceneGraphManager;

	public function get_sceneGraphManager():SceneGraphManager {
		return mSceneGraphManager;
	}

	@:isVar public var logicalWorkManager(get, never):WorkLoopManager;

	public function get_logicalWorkManager():WorkLoopManager {
		return mLogicalWorkManager;
	}

	@:isVar public var realClockWorkManager(get, never):WorkLoopManager;

	public function get_realClockWorkManager():WorkLoopManager {
		return mRealClockWorkManager;
	}

	@:isVar public var preRenderWorkManager(get, never):WorkLoopManager;

	public function get_preRenderWorkManager():WorkLoopManager {
		return mPreRenderWorkManager;
	}

	@:isVar public var physicsWorkManager(get, never):WorkLoopManager;

	public function get_physicsWorkManager():WorkLoopManager {
		return mPhysicsWorkManager;
	}

	@:isVar public var layerRenderWorkManager(get, never):WorkLoopManager;

	public function get_layerRenderWorkManager():WorkLoopManager {
		return mLayerRenderWorkManager;
	}

	@:isVar public var assetRepository(get, never):AssetRepository;

	public function get_assetRepository():AssetRepository {
		return mAssetRepository;
	}

	@:isVar public var assetLoadingComponent(get, never):AssetLoadingComponent;

	public function get_assetLoadingComponent():AssetLoadingComponent {
		return mAssetLoadingComponent;
	}

	@:isVar public var soundManager(get, never):SoundManager;

	public function get_soundManager():SoundManager {
		return mSoundManager;
	}

	@:isVar public var mouseCursorManager(get, never):MouseCursorManager;

	public function get_mouseCursorManager():MouseCursorManager {
		return mMouseCursorManager;
	}

	public function getWorldCoordinateFromMouse():Vector3D {
		return camera.getWorldCoordinateFromMouse(inputManager.mouseX, inputManager.mouseY);
	}
}
