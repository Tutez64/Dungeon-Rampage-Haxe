package stateMachine.mainStateMachine;

import brain.assetRepository.AssetLoader;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import brain.stateMachine.State;
import brain.uI.UIProgressBar;
import brain.utils.MemoryTracker;
import brain.utils.MemoryUtil;
import brain.utils.TextUtil;
import brain.workLoop.DoLater;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObjectOwner;
import events.CacheLoadRequestNpcEvent;
import events.ClientExitCompleteEvent;
import events.RequestEntryFailedEvent;
import facade.DBFacade;
import facade.Locale;
import facade.TrickleCacheLoader;
import gameMasterDictionary.GMMapNode;
import uI.popup.DBUIOneButtonPopup;
import uI.UIHints;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import brain.event.EventListeners;
import brain.sceneGraph.SceneGraphComponent;
import facade.DBFacade;
import sound.DBSoundManager;
import uI.CutsceneOverlay;
import flash.display.Shape;
import flash.events.KeyboardEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class LoadingScreenState extends State {
	public static inline final NAME = "LoadingScreenState";

	public static inline final HERO_ENTRY_RELEASED = "LOADING_SCREEN_HERO_ENTRY_RELEASED";

	public static inline final ERROR_NONE_PARSABLE_DEMOGRAPHICS = (102 : UInt);

	public static inline final ERROR_ENTRY_REQUEST_MALFORMED = (103 : UInt);

	public static inline final ERROR_ENTRY_REQUEST_BADMAPNODE = (104 : UInt);

	public static inline final ERROR_INTERNAL = (105 : UInt);

	public static inline final ERROR_INTERNAL_NOT_SUPPORTED = (106 : UInt);

	public static inline final ERROR_MAPNODE_NODE_NOTAUTHORIZED = (201 : UInt);

	public static inline final WARNING_FRIEND_NOT_FOUND = (500 : UInt);

	public static inline final WARNING_FRIEND_GAME_NOT_FOUND = (501 : UInt);

	public static inline final WARNING_GAME_IS_FULL = (502 : UInt);

	static inline final LERP_RATE:Float = 0.04;

	static inline final LEGACY_PROGRESS_WEIGHT:Float = 0.5;

	static inline final FLOOR_PROGRESS_WEIGHT:Float = 0.1;

	static inline final STARLING_PROGRESS_WEIGHT:Float = 0.4;

	static inline final NETWORK_WAIT_EASE_RATE:Float = 0.005;

	static inline final MINIMUM_LOADING_SECONDS:Float = 3;

	static inline final LOADING_SCREEN_PATH = "Resources/Art2D/UI/db_UI_loading_screen.swf";

	public static inline final ERROR_NONE_PARSABLE_MESSAGE = (101 : UInt);

	var mMinimumLoadingSeconds:Float = 3;

	var mFloorDetails:FloorDetailsWait;

	var mFinishLoadingCallback:ASFunction;

	var mHasCalledFinishLoadingCallback:Bool = false;

	var mHeroEntryHeld:Bool = false;

	var mDBFacade:DBFacade;

	var mWorkComponent:LogicalWorkComponent;

	var mTask:Task;

	var mGoToSplashScreenCallback:ASFunction;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mEventComponent:EventComponent;

	var mLoadingScreenRoot:MovieClip;

	var mLoadingBarClip:MovieClip;

	var mLoadingBar:UIProgressBar;

	var mProgressTarget:Float = Math.NaN;

	var mScreenLoaded:Bool = false;

	var mHeroOwnerReady:Bool = false;

	var mStarlingAssetsPending:Bool = false;

	var mLegacyAssetsReady:Bool = false;

	var mFloorRequested:Bool = false;

	var mFloorReady:Bool = false;

	var mStarlingBundlesLoadedAtStart:UInt = 0;

	var mMapNodeID:UInt = 0;

	public var mNodeType:String;

	var mFriendID:UInt = 0;

	var mMapID:UInt = 0;

	var mJumpToMapState:Bool = false;

	var mLoadingStartTime:UInt = 0;

	var mHint:UIHints;

	var mFriendOnly:Bool = false;

	var mLoadingScreenLabel:TextField;

	var mVideoPlayer:VideoPlayer;

	public function new(dbFacade:DBFacade, finishedCallback:ASFunction = null) {
		super("LoadingScreenState", finishedCallback);
		mDBFacade = dbFacade;
		mWorkComponent = new LogicalWorkComponent(mDBFacade, "LoadingScreenState");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "LoadingScreenState");
		mEventComponent = new EventComponent(mDBFacade);
		mScreenLoaded = false;
		mHeroOwnerReady = false;
		mFriendOnly = false;
		mFloorDetails = new FloorDetailsWait(function(param1:Float, param2:ASFunction):ASObject {
			return mDBFacade.realClockWorkManager.doLater(param1, param2, false, "LoadingScreenState");
		}, function(param1:ASObject) {
			mDBFacade.realClockWorkManager.removeDoLater(ASCompat.dynamicAs(param1, DoLater));
		}, floorDetailsDone);
	}

	@:isVar public var holdsHeroEntry(get, never):Bool;

	public function get_holdsHeroEntry():Bool {
		return mHeroEntryHeld;
	}

	public function heroOwnerReady(e:Event) {
		mDBFacade.metrics.log("DungeonLoadHeroReady", {});
		mHeroOwnerReady = true;
		mFloorDetails.heroReady();
		checkIfReadyToMoveOn();
	}

	function floorInterestClosureEventCallback(e:Event) {
		AssetLoader.stopTrackingLoads();
		mFloorReady = true;
		mFloorDetails.closureArrived();
	}

	function floorDetailsDone(timedOut:Bool) {
		var _loc2_ = Math.NaN;
		if (timedOut) {
			_loc2_ = (mDBFacade.gameClock.realTime - (mLoadingStartTime : Float)) / 1000;
			mDBFacade.metrics.log("DungeonLoadFloorDetailsTimeout", {"timeSpentSeconds": _loc2_});
		}
		checkIfReadyToMoveOn();
	}

	function ponderPlayMovie():Bool {
		var _loc2_:GMMapNode = null;
		var _loc1_ = mDBFacade.getSplitTestNumber("SkipVideo", 0);
		if (mMapNodeID != 0 && _loc1_ != 1) {
			_loc2_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeById.itemFor(mMapNodeID), gameMasterDictionary.GMMapNode);
			if (_loc2_ != null && ASCompat.stringAsBool(_loc2_.StorySwfPath)) {
				mVideoPlayer = new VideoPlayer(mDBFacade, mSceneGraphComponent, enterLoadingState);
				mVideoPlayer.process(_loc2_.StorySwfPath);
				return false;
			}
		}
		enterLoadingState();
		return true;
	}

	override public function enterState() {
		mDBFacade.metrics.log("DungeonLoadingScreen", {});
		super.enterState();
		Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING LOADING SCREEN STATE");
		ponderPlayMovie();
	}

	function enterLoadingState() {
		MemoryTracker.nextGeneration();
		mLoadingStartTime = (mDBFacade.gameClock.realTime : UInt);
		mHeroOwnerReady = false;
		mFloorDetails.begin();
		mStarlingAssetsPending = false;
		mLegacyAssetsReady = false;
		mFloorRequested = false;
		mFloorReady = false;
		mStarlingBundlesLoadedAtStart = mDBFacade.assetLoadingComponent.starlingBundlesLoaded;
		mHeroEntryHeld = true;
		mEventComponent.addListener("StarlingAssetsQueued", starlingAssetsQueued);
		mEventComponent.addListener("StarlingAssetsReady", starlingAssetsReady);
		mEventComponent.addListener("FLOOR_INTEREST_CLOSURE", floorInterestClosureEventCallback);
		mEventComponent.addListener(HeroGameObjectOwner.HERO_OWNER_READY, heroOwnerReady);
		mEventComponent.addListener("REQUEST_ENTRY_FAILED", failedRequestEntry);
		mEventComponent.addListener("CLIENT_EXIT_COMPLETE", GraceFullClientExited);
		mEventComponent.addListener("Busterncpccahche_event", TickleCacheWithEvent);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"), setUpLoadingScreen);
		if (mDBFacade.assetLoadingComponent != null) {
			mDBFacade.assetLoadingComponent.beginEntry();
			TrickleCacheLoader.queueCommonStarlingAtlases(mDBFacade);
			TrickleCacheLoader.queueHeroKitStarlingAtlases(mDBFacade);
			mStarlingAssetsPending = mDBFacade.assetLoadingComponent.isStarlingLoadPending;
		}
		AssetLoader.startTrackingLoads(finishedLoading);
		var _loc1_ = (0 : UInt);
		if (mFriendOnly) {
			_loc1_ = (1 : UInt);
		}
		var _loc2_ = mDBFacade.dbConfigManager.getConfigString("MatchMakerGroup", "");
		mDBFacade.mDistributedObjectManager.mMatchMaker.RequestEntry(mapNodeID, friendID, mapID, _loc1_, _loc2_);
		mTask = mWorkComponent.doEveryFrame(updateProgress);
		MemoryUtil.pauseForGCWithLogging("LoadingScreen: ");
	}

	function GraceFullClientExited(event:ClientExitCompleteEvent) {
		gracefullExit();
	}

	function failedRequestEntry(event:RequestEntryFailedEvent) {
		var _loc3_ = event.errorCode;
		var _loc2_ = new DBUIOneButtonPopup(mDBFacade, "MATCHMAKER_REFUSED_POPUP", Locale.getString("MATCHMAKER_REFUSES_TITLE"),
			Locale.getError((_loc3_ : Int)), Locale.getString("OK"), failedRequestEntryDialogClose, true, failedRequestEntryDialogClose);
		MemoryTracker.track(_loc2_, "DBUIOneButtonPopup - created in LoadingScreenState.failedRequestEntry()");
		var _loc4_ = (mDBFacade.gameClock.realTime - (mLoadingStartTime : Float)) / 1000;
		mDBFacade.metrics.log("DungeonLoadFailed", {
			"errorCode": _loc3_,
			"timeSpentSeconds": _loc4_
		});
	}

	function failedRequestEntryDialogClose() {
		mDBFacade.mainStateMachine.enterReloadTownState(true);
	}

	function gracefullExit() {
		mDBFacade.mainStateMachine.enterReloadTownState();
	}

	function goBackToTown() {
		mDBFacade.mainStateMachine.enterTownState(mJumpToMapState);
		mJumpToMapState = false;
	}

	function setUpLoadingScreen(swfAsset:SwfAsset) {
		var _loc2_:Dynamic = null;
		var _loc3_:String = null;
		if (nodeType == GMMapNode.DUNGEON_NODE_TYPE || nodeType == "") {
			_loc2_ = swfAsset.getClass("loading_gate_random");
			_loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
		} else if (nodeType == GMMapNode.INFINITE_NODE_TYPE) {
			_loc2_ = swfAsset.getClass("loading_gate_ultimate_random");
			_loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
		} else {
			_loc2_ = swfAsset.getClass("loading_gateboss_random");
			_loc3_ = Locale.getString("LOADING_SCREEN_CHALLENGE_LABEL");
		}
		mLoadingScreenRoot = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
		mLoadingScreenLabel = ASCompat.coerce((mLoadingScreenRoot : ASAny).loading_gate_text_hint.label, flash.text.TextField);
		TextUtil.setText(mLoadingScreenLabel, _loc3_);
		mLoadingBarClip = ASCompat.coerce((mLoadingScreenRoot : ASAny).loading_gate_text_hint.UI_loadingBar, flash.display.MovieClip);
		mLoadingBarClip.visible = true;
		mLoadingBarClip.scaleX = mLoadingBarClip.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		mLoadingBarClip.x = 548.7;
		mLoadingBarClip.y = 1000;
		mHint = new UIHints(mDBFacade, ASCompat.coerce((mLoadingScreenRoot : ASAny).loading_gate_text_hint.hint, flash.display.MovieClip));
		mLoadingBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mLoadingBarClip : ASAny).loadingBar, flash.display.MovieClip));
		mProgressTarget = 0;
		mLoadingBar.value = 0;
		mScreenLoaded = true;
		EventListeners.add(mDBFacade.stageRef, "keyDown", keyCall);
		EventListeners.add(mDBFacade.stageRef, "mouseDown", handleMouseDown);
		mMinimumLoadingSeconds = 3;
		if (mScreenLoaded && mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState") {
			mSceneGraphComponent.addChild(mLoadingScreenRoot, (100 : UInt));
			mSceneGraphComponent.addChild(mLoadingBarClip, (100 : UInt));
		}
	}

	function updateProgress(clock:GameClock) {
		var _loc2_ = Math.NaN;
		var _loc3_ = Math.NaN;
		if (!mScreenLoaded) {
			return;
		}
		if (!mFloorRequested) {
			AssetLoader.updateTrackedLoads();
		}
		if (mLoadingBar != null) {
			_loc2_ = 0.5 * legacyProgress(clock) + (mFloorReady ? 0.1 : 0) + 0.4 * starlingProgress();
			mProgressTarget = Math.max(mProgressTarget, _loc2_);
			if (waitingOnNetwork()) {
				_loc3_ = nextMilestone(_loc2_);
				if (mProgressTarget < _loc3_) {
					mProgressTarget += (_loc3_ - mProgressTarget) * 0.005;
				}
			}
			mLoadingBar.value += (mProgressTarget - mLoadingBar.value) * 0.04;
		}
	}

	function waitingOnNetwork():Bool {
		if (mStarlingAssetsPending) {
			return false;
		}
		if (!mFloorRequested) {
			return !mLegacyAssetsReady && AssetLoader.pendingBytesTotal == 0;
		}
		return !mHeroOwnerReady || mFloorDetails.pending;
	}

	function nextMilestone(earned:Float):Float {
		if (!mFloorRequested) {
			return 0.5;
		}
		if (!mFloorReady) {
			return earned + 0.1;
		}
		var _loc2_ = mDBFacade.assetLoadingComponent.starlingBundlesLoaded - mStarlingBundlesLoadedAtStart;
		return 0.5 + 0.1 + 0.4 * (_loc2_ + 1) / (_loc2_ + 2);
	}

	function legacyProgress(clock:GameClock):Float {
		if (!mHeroEntryHeld) {
			return 1;
		}
		var _loc2_ = mLegacyAssetsReady ? 1 : (AssetLoader.pendingBytesTotal > 0 ? AssetLoader.pendingBytesLoaded / AssetLoader.pendingBytesTotal : 0);
		var _loc3_ = mMinimumLoadingSeconds > 0 ? (clock.realTime - (mLoadingStartTime : Float)) / (1000 * mMinimumLoadingSeconds) : 1;
		return Math.min(_loc2_, _loc3_);
	}

	function starlingProgress():Float {
		var _loc1_ = mDBFacade.assetLoadingComponent;
		var _loc2_ = _loc1_.starlingBundlesLoaded - mStarlingBundlesLoadedAtStart;
		var _loc4_ = _loc1_.activeStarlingBundleCount;
		var _loc3_ = _loc2_ + _loc4_ + _loc1_.pendingStarlingBundleCount + (mHeroOwnerReady ? 0 : 1);
		if (_loc3_ == 0) {
			return 1;
		}
		return (_loc2_ + _loc1_.starlingLoadProgress) / _loc3_;
	}

	function TickleCacheWithEvent(event:CacheLoadRequestNpcEvent) {
		var _loc2_ = (0 : UInt);
		mDBFacade.metrics.log("DungeonLoadCacheStarted", {});
		_loc2_ = (0 : UInt);
		while (_loc2_ < (event.tileLibraryName.length:UInt)) {
			TrickleCacheLoader.tileLibrary(event.tileLibraryName[(_loc2_ : Int)], mDBFacade);
			_loc2_++;
		}
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_axes.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_hammers.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_throwingweapons.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Charge/db_icons_charge.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/projectiles/db_projectiles_library.swf"), mDBFacade);
		TrickleCacheLoader.swfVector(event.cacheSwf, mDBFacade);
		AssetLoader.stopTrackingLoads();
	}

	function starlingAssetsQueued(e:Event) {
		mStarlingAssetsPending = true;
	}

	function starlingAssetsReady(e:Event) {
		mStarlingAssetsPending = false;
		checkIfReadyToMoveOn();
	}

	function checkIfReadyToMoveOn() {
		var _loc1_ = Math.NaN;
		if (!mHeroEntryHeld && mHeroOwnerReady && !mFloorDetails.pending && !mStarlingAssetsPending) {
			_loc1_ = (mDBFacade.gameClock.realTime - (mLoadingStartTime : Float)) / 1000;
			mDBFacade.metrics.log("DungeonLoaded", {"timeSpentSeconds": _loc1_});
			mFinishedCallback();
			mEventComponent.dispatchEvent(new Event("FLOOR_REVEALED"));
		}
	}

	function finishedLoading() {
		var timeTakenToLoadSoFar:Float;
		var timeLeftToLoad:Float;
		mLegacyAssetsReady = true;
		mDBFacade.metrics.log("DungeonLoadCacheFinished", {});
		mDBFacade.createHUD();
		mFloorRequested = true;
		mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_FLOOR"));
		timeTakenToLoadSoFar = (mDBFacade.gameClock.realTime - (mLoadingStartTime : Float)) / 1000;
		timeLeftToLoad = Math.max(0, mMinimumLoadingSeconds - timeTakenToLoadSoFar);
		mHasCalledFinishLoadingCallback = false;
		mFinishLoadingCallback = function() {
			if (mHasCalledFinishLoadingCallback) {
				return;
			}
			mHasCalledFinishLoadingCallback = true;
			mFinishLoadingCallback = null;
			mHeroEntryHeld = false;
			mEventComponent.dispatchEvent(new Event("LOADING_SCREEN_HERO_ENTRY_RELEASED"));
			checkIfReadyToMoveOn();
		};
		mDBFacade.mTween.delayedCall(timeLeftToLoad, mFinishLoadingCallback);
	}

	function forceFinishLoading() {
		mMinimumLoadingSeconds = 0;
		if (mFinishLoadingCallback != null) {
			mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
			mFinishLoadingCallback();
		}
	}

	function keyCall(event:KeyboardEvent) {
		switch (event.keyCode - 27) {
			case 0:
				forceFinishLoading();
		}
	}

	function handleMouseDown(event:MouseEvent) {
		forceFinishLoading();
	}

	override public function exitState() {
		if (mHint != null) {
			mHint.destroy();
		}
		mHint = null;
		if (mFinishLoadingCallback != null) {
			mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
			mFinishLoadingCallback = null;
		}
		AssetLoader.abortTrackingLoads();
		mSceneGraphComponent.removeChild(mLoadingScreenRoot);
		mSceneGraphComponent.removeChild(mLoadingBarClip);
		mEventComponent.removeAllListeners();
		EventListeners.remove(mDBFacade.stageRef, "keyDown", keyCall);
		EventListeners.remove(mDBFacade.stageRef, "mouseDown", handleMouseDown);
		if (mTask != null) {
			mTask.destroy();
			mTask = null;
		}
		mFloorDetails.stop();
		if (mFinishLoadingCallback != null) {
			mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
			mFinishLoadingCallback = null;
		}
		if (mDBFacade.assetLoadingComponent != null) {
			mDBFacade.assetLoadingComponent.endEntry();
		}
		super.exitState();
	}

	@:isVar public var mapNodeID(get, set):UInt;

	public function get_mapNodeID():UInt {
		return mMapNodeID;
	}

	function set_mapNodeID(value:UInt):UInt {
		mMapNodeID = value;
		mFriendID = (0 : UInt);
		mMapID = (0 : UInt);
		return value;
	}

	@:isVar public var mapID(get, set):UInt;

	public function get_mapID():UInt {
		return mMapID;
	}

	function set_mapID(value:UInt):UInt {
		mMapNodeID = (0 : UInt);
		mFriendID = (0 : UInt);
		return mMapID = value;
	}

	@:isVar public var friendID(get, set):UInt;

	public function get_friendID():UInt {
		return mFriendID;
	}

	function set_friendID(value:UInt):UInt {
		mMapNodeID = (0 : UInt);
		mFriendID = value;
		mMapID = (0 : UInt);
		return value;
	}

	@:isVar public var friendsOnly(get, set):Bool;

	public function get_friendsOnly():Bool {
		return mFriendOnly;
	}

	function set_friendsOnly(value:Bool):Bool {
		return mFriendOnly = value;
	}

	@:isVar public var jumpToMapState(never, set):Bool;

	public function set_jumpToMapState(value:Bool):Bool {
		return mJumpToMapState = value;
	}

	@:isVar public var nodeType(get, set):String;

	public function get_nodeType():String {
		return mNodeType;
	}

	function set_nodeType(value:String):String {
		return mNodeType = value;
	}
}

private class VideoPlayer {
	var mCutVideo:Video;

	var mCutVideoBackGround:Shape;

	var mOverlay:CutsceneOverlay;

	var mSceneGraphComponent:SceneGraphComponent;

	var mDBFacade:DBFacade;

	var mcallback:ASFunction;

	var mNetConnection:NetConnection;

	var mNetStream:NetStream;

	var mIsCleanedUp:Bool = false;

	public function new(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent, callback:ASFunction) {
		mcallback = callback;
		mSceneGraphComponent = sceneGraphComponent;
		mDBFacade = dbFacade;
	}

	public function destroy() {
		cleanup();
	}

	function cleanupAndTransition() {
		if (mIsCleanedUp) {
			return;
		}
		cleanup();
		mcallback();
	}

	public function cleanup() {
		if (mIsCleanedUp) {
			return;
		}
		mIsCleanedUp = true;
		mDBFacade.metrics.log("IntroVideoCleanup", {});
		EventListeners.remove(mNetStream, "netStatus", detectEnd);
		EventListeners.remove(mDBFacade.stageRef, "keyDown", KeyCall);
		mDBFacade.menuNavigationController.popLayer("INTRO_CINEMATIC");
		mSceneGraphComponent.removeChild(mCutVideoBackGround);
		mSceneGraphComponent.removeChild(mCutVideo);
		mSceneGraphComponent.removeChild(mOverlay.skipButton.root);
		mSceneGraphComponent.removeChild(mOverlay.coliseumAdvert);
		mOverlay.destroy();
		mNetStream.close();
		mNetStream = null;
		mCutVideo = null;
		mCutVideoBackGround = null;
		mOverlay = null;
	}

	public function KeyCall(event:KeyboardEvent) {
		switch (event.keyCode - 27) {
			case 0:
				mDBFacade.metrics.log("IntroVideoSkip", {});
				cleanupAndTransition();
		}
	}

	public function detectEnd(myevent:NetStatusEvent) {
		switch (myevent.info.code) {
			case "NetStream.Play.Start":
				mDBFacade.metrics.log("IntroVideoStart", {});

			case "NetStream.Play.Stop":
				cleanupAndTransition();

			case "NetStream.Play.StreamNotFound":
				cleanupAndTransition();
		}
	}

	public function process(clname:String) {
		var customClient:ASObject;
		var dbSoundManager:DBSoundManager;
		var cuePointHandler = function(param1:ASObject) {};
		var metaDataHandler = function(param1:ASObject) {
			mCutVideo.y = 0;
			mCutVideo.x = 0;
			mCutVideo.width = 1920;
			mCutVideo.height = 1080;
			mSceneGraphComponent.addChild(mCutVideo, (50 : UInt));
			SceneGraphComponent.bringToFront(mOverlay.skipButton.root);
			SceneGraphComponent.bringToFront(mOverlay.coliseumAdvert);
		};
		mDBFacade.metrics.log("IntroVideoCreated", {});
		mCutVideo = new Video(1, 1);
		mNetConnection = new NetConnection();
		mNetConnection.connect(null);
		mNetStream = new NetStream(mNetConnection);
		customClient = {};
		ASCompat.setProperty(customClient, "onCuePoint", cuePointHandler);
		ASCompat.setProperty(customClient, "onMetaData", metaDataHandler);
		mNetStream.client = customClient;
		EventListeners.add(mNetStream, "netStatus", detectEnd);
		mCutVideoBackGround = new Shape();
		mCutVideoBackGround.graphics.beginFill((0 : UInt));
		mCutVideoBackGround.graphics.drawRect(0, 0, mDBFacade.viewWidth, mDBFacade.viewHeight);
		mCutVideoBackGround.graphics.endFill();
		mSceneGraphComponent.addChildAt(mCutVideoBackGround, (50 : UInt), (0 : UInt));
		mOverlay = new CutsceneOverlay(mDBFacade, cleanupAndTransition);
		mSceneGraphComponent.addChild(mOverlay.skipButton.root, (50 : UInt));
		mSceneGraphComponent.addChild(mOverlay.coliseumAdvert, (50 : UInt));
		mDBFacade.menuNavigationController.pushNewLayer("INTRO_CINEMATIC", cleanupAndTransition, mOverlay.skipButton);
		EventListeners.add(mDBFacade.stageRef, "keyDown", KeyCall);
		mCutVideo.attachNetStream(mNetStream);
		mNetStream.play(DBFacade.buildFullDownloadPath(clname));
		dbSoundManager = ASCompat.reinterpretAs(mDBFacade.soundManager, DBSoundManager);
		dbSoundManager.applyStoredVolumeSettings();
		mNetStream.soundTransform = new SoundTransform(dbSoundManager.getDampenedVolumeScaleForCategory("music"));
	}
}
