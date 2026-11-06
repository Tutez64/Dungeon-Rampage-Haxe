package facade;

import account.AccountBonus;
import account.DBAccountInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.JsonAsset;
import brain.assetRepository.TestResourceLocator;
import brain.clock.GameClock;
import brain.event.EventListeners;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.render.MovieClipPool;
import brain.uI.UIProgressBar;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import brain.jsonRPC.JSONRPCService;
import collections.Map;
import combat.attack.TimelineFactory;
import config.ConfigFileLoadedEvent;
import config.DBConfigManager;
import config.ServiceDiscoveryLoader;
import config.ServiceDiscoveryReadyEvent;
import distributedObjects.DistributedObjectManager;
import effects.CustomSkinVisualsOverrideHandler;
import effects.EffectPool;
import events.ManagersLoadedEvent;
import gameMasterDictionary.GameMaster;
import generatedCode.InfiniteMapNodeDetail;
import input.keyBindings.KeyBindings;
import input.MenuNavigationController;
import json.JsonCodec;
import magicWords.MagicWordManager;
import metrics.FPSReadout;
import metrics.MetricsLogger;
import networkCode.transport.GameEndpoints;
import networkCode.transport.TransportSettings;
import settings.model.DisplayTimingSettings;
import settings.model.SettingsModel;
import settings.model.SettingsStore;
import sound.DBSoundManager;
import stateMachine.mainStateMachine.LoadingFinishedEvent;
import stateMachine.mainStateMachine.LoadingScreenState;
import stateMachine.mainStateMachine.LoadingState;
import stateMachine.mainStateMachine.MainStateMachine;
import steamAchievements.SteamAchievementsHelper;
import steamAchievements.SteamAchievementsManager;
import steamInput.SteamInputManager;
import uI.cursor.UIMouseCursors;
import uI.hud.starlingConverted.HudArt;
import uI.hud.starlingConverted.IGameHud;
import uI.hud.starlingConverted.StarlingHud;
import uI.hud.UIHud;
import uI.map.PlayerActivityCount;
import uI.popup.DBUIOneButtonPopup;
import uI.UIHideToggle;
import uI.UILevelUpPostController;
import uI.UIReconnectingIndicator;
import com.amanitadesign.steam.FRESteamWorks;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Stage;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.system.Security;
import flash.text.TextField;

class DBFacade extends Facade {
	static inline final CLIENT_ERROR_EVENT = "CLIENT_ERROR_EVENT";

	public static inline final VALIDATION_REFRESH_TIME:Float = 3600;

	static var mDownloadRoot:String = "";

	var LoadingClass:Dynamic = Db_UI_game_loading_screen_swf;

	var mInitialLoadingClip:MovieClip;

	var mLoadingBar:UIProgressBar;

	var mLoadingBarIntStatus:Float = 0;

	var mAltEnterDown:Bool = false;

	var mPlainEnterDown:Bool = false;

	var mMainStateMachine:MainStateMachine;

	var mDBAccountInfo:DBAccountInfo;

	var mDBConfigManager:DBConfigManager;

	var mHud:IGameHud;

	var mEffectPool:EffectPool;

	var mMovieClipPool:MovieClipPool;

	var mMetricsLogger:MetricsLogger;

	var mFPSReadout:FPSReadout;

	var mReconnectingIndicator:UIReconnectingIndicator;

	var mReconnectFrozeInput:Bool = false;

	var mMainStateAtDrop:String;

	var mTileLibraryMap:Map;

	var mJsonAssets:Array<ASAny>;

	var mLibraryJsonLoaded:Bool = false;

	var mTimelineFinishedLoading:Bool = false;

	var mTimelineFactory:TimelineFactory;

	var mGameMasterJsonLoaded:Bool = false;

	var mLibraryJson:Array<ASAny>;

	var mGameMasterJson:ASObject;

	var mUILevelUpPostController:UILevelUpPostController;

	var mAccountBonus:AccountBonus;

	var mMenuNavigationController:MenuNavigationController;

	var mCustomSkinVisualsOverrideHandler:CustomSkinVisualsOverrideHandler;

	var mSettingsModel:SettingsModel;

	var mDisplayTimingSettings:DisplayTimingSettings;

	var mKeyBindings:KeyBindings;

	var mUIHideToggle:UIHideToggle;

	public var gameMaster:GameMaster;

	var mMagicWordManager:MagicWordManager;

	var mWebServicesUrl:String;

	var mGameSocketAddress:String;

	var mGameSocketPort:Int = 0;

	var mGameSocketTlsOffered:Bool = false;

	var mGameSocketWssPath:String = "";

	var mWebAPIRoot:String;

	var mPendingServiceDiscoveryEvent:ServiceDiscoveryReadyEvent;

	var mRPCRoot:String;

	var mSteamAPIRoot:String;

	var mPlayerActivityCount:PlayerActivityCount;

	var mAccountId:UInt = 0;

	var mValidationToken:String;

	var mDemographics:ASObject;

	var mHiddenFocusText:TextField;

	public var mDistributedObjectManager:DistributedObjectManager;

	public var mCheckedDailyReward:Bool = false;

	public var mInDailyReward:Bool = false;

	var mTokenRegenTask:Task;

	var mDelayErrors:Array<ASAny>;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mErrorTask:Task;

	var mSecurityGM:Int = 0;

	var mSecurityTL:Int = 0;

	var mSecuritySL:Int = 0;

	public var mSteamworks:FRESteamWorks = new FRESteamWorks();

	public var mSteamUserId:String;

	public var mSteamAppId:UInt = (0 : UInt);

	public var mSteamPersonaName:String;

	public var mSteamWebApiAuthTicket:String;

	public var mSteamAuthTicketHandle:UInt = 0;

	public var mSteamLoginFailure:String;

	var mSteamAchievementsHelper:SteamAchievementsHelper;

	var mSteamAchievementsManager:SteamAchievementsManager;

	public var mUseSteamLogin:Bool = false;

	public var mSeenFlaggedPopup:Bool = false;

	public var mSteamIsFlagged:Bool = false;

	public var mSteamFlaggedUntilAfterDateString:String;

	public var mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged:Bool = false;

	public var mSteamIsFlaggedDueToFamilySharingOwnerName:String;

	public var mSteamAvatarUrl:String;

	var mSteamInputManager:SteamInputManager;

	public var mAdditionalConfigFilesToLoad:Array<ASAny> = [];

	var mShowCollisions:Bool = false;

	public var NODE_RULES:UInt = (0 : UInt);

	var stagetwo_init_call_count:UInt = (0 : UInt);

	public function new() {
		super();
		mWantFramerateEnforcement = true;
		mTileLibraryMap = new Map();
		mCheckedDailyReward = false;
		mInDailyReward = false;
		if (Capabilities.playerType == "Desktop") {
			return;
		}
		Security.loadPolicyFile("https://ak.ssl.dungeonbusters.com/crossdomain.xml");
		Security.allowDomain("http://ak.ssl.dungeonbusters.com");
		Security.allowInsecureDomain("https://ak.ssl.dungeonbusters.com");
		Security.allowDomain("www.youtube.com");
		killWebSecurity();
	}

	@:isVar public static var ROOT_DIR_old(get, never):String;

	static public function get_ROOT_DIR_old():String {
		if (!ASCompat.stringAsBool(mDownloadRoot)) {
			Logger.error("Download root ROOT_DIR is not set yet.");
		}
		return mDownloadRoot;
	}

	public static function buildFullDownloadPath(rawAssetPath:String):String {
		if (rawAssetPath == "" || rawAssetPath == "null") {
			Logger.error("Trying to create a path from an empty string");
			return "";
		}
		return TestResourceLocator.url(mDownloadRoot + rawAssetPath);
	}

	public function killWebSecurity() {
		Security.allowDomain("*");
	}

	@:isVar public var showCollisions(get, set):Bool;

	public function get_showCollisions():Bool {
		return mShowCollisions;
	}

	function set_showCollisions(showThem:Bool):Bool {
		mShowCollisions = showThem;
		mSceneGraphManager.getLayer(40).visible = mShowCollisions;
		return showThem;
	}

	@:isVar public var steamAchievementsHelper(get, set):SteamAchievementsHelper;

	public function get_steamAchievementsHelper():SteamAchievementsHelper {
		return mSteamAchievementsHelper;
	}

	function set_steamAchievementsHelper(inSteamAchievementsHelper:SteamAchievementsHelper):SteamAchievementsHelper {
		return mSteamAchievementsHelper = inSteamAchievementsHelper;
	}

	@:isVar public var steamAchievementsManager(get, set):SteamAchievementsManager;

	public function get_steamAchievementsManager():SteamAchievementsManager {
		return mSteamAchievementsManager;
	}

	function set_steamAchievementsManager(inSteamAchievementsManager:SteamAchievementsManager):SteamAchievementsManager {
		return mSteamAchievementsManager = inSteamAchievementsManager;
	}

	override public function logCheater(howICheat:String) {
		var requestFunc = JSONRPCService.getFunction("LogCheater", rpcRoot + "store");
		requestFunc(dbAccountInfo.id, validationToken, howICheat, demographics, function() {}, function(param1:Error) {});
	}

	function loadBackground() {
		var countBackgroundImagesLoaded = 0;
		var startWindowed = featureFlags.getFlagValue("start-windowed");
		mAssetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/left.jpg"),
			function(param1:brain.assetRepository.ImageAsset) {
				var _loc2_:DisplayObject = param1.image;
				var _loc3_ = viewHeight / _loc2_.height;
				_loc2_.scaleX = _loc3_;
				_loc2_.scaleY = _loc3_;
				_loc2_.x = -_loc2_.width;
				_loc2_.y = 0;
				addRootDisplayObject(_loc2_, 1001);
				if (!startWindowed) {
					countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
					if (countBackgroundImagesLoaded > 1) {
						mStageRef.displayState = "fullScreenInteractive";
					}
				}
			});
		mAssetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/right.jpg"),
			function(param1:brain.assetRepository.ImageAsset) {
				var _loc2_:DisplayObject = param1.image;
				var _loc3_ = viewHeight / _loc2_.height;
				_loc2_.scaleX = _loc3_;
				_loc2_.scaleY = _loc3_;
				_loc2_.x = viewWidth;
				_loc2_.y = 0;
				addRootDisplayObject(_loc2_, 1001);
				if (!startWindowed) {
					countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
					if (countBackgroundImagesLoaded > 1) {
						mStageRef.displayState = "fullScreenInteractive";
					}
				}
			});
	}

	function loadLocale() {
		Locale.loadStrings(this, localeAvailable);
		GameMasterLocale.loadGameMasterStrings(this, localeAvailable);
		mMagicWordManager = new MagicWordManager(this);
	}

	public function createHUD() {
		if (mHud != null) {
			return;
		}
		mHud = ASCompat.coerce(featureFlags.getFlagValue("starling-hud") && HudArt.begun ? new StarlingHud(this) : new UIHud(this),
			uI.hud.starlingConverted.IGameHud);
	}

	public function refreshHUD() {
		if (featureFlags.getFlagValue("want-hud-refresh-on-floor-transition")) {
			mHud.refreshHUD();
		}
	}

	function computeServerTimeOffset() {
		var _loc1_:Date = null;
		var _loc2_ = mDBConfigManager.getConfigString("server_time", "");
		if (ASCompat.stringAsBool(_loc2_)) {
			_loc1_ = GameClock.parseW3CDTF(_loc2_);
			GameClock.computeServerTimeOffset(_loc1_);
		}
		Logger.info("server time offset (ms): " + GameClock.serverTimeOffset);
	}

	override public function buildEngines() {
		Logger.info("building engines 0");
		SettingsStore.applyStartupFlags(featureFlags);
		loadBackground();
		Logger.info("building engines 1");
		loadLocale();
		Logger.info("building engines 2");
		computeServerTimeOffset();
		super.buildEngines();
		UIMouseCursors.register(this);
		mKeyBindings = new KeyBindings(inputManager);
		mUIHideToggle = new UIHideToggle(this);
		mSteamInputManager = new SteamInputManager(this, mSteamworks, mStageRef, featureFlags.getFlagValue("experimental-use-steam-input"));
		Logger.info("building engines 3");
		mSoundManager = new DBSoundManager(this);
		var _loc1_ = mDBConfigManager.getConfigBoolean("show_colliders", false);
		mSceneGraphManager.getLayer(40).visible = _loc1_;
		if (mDBConfigManager.getConfigBoolean("show_redraw_regions", false)) {
			ASCompat.showRedrawRegions(true, (16711680 : UInt));
		}
		Logger.info("building engines 4");
		this.accountId = (ASCompat.floatToInt(mDBConfigManager.getConfigNumber("AccountId", 0)) : UInt);
		if (mAccountId == 0) {
			Logger.error("AccountId is 0.  Cannot continue without a valid AccountId.");
		}
		Logger.info("building engines 5");
		mDemographics = mDBConfigManager.GetValueOrDefault("Demographics", {});
		Logger.info("building engines 5.1");
		Logger.info("building engines 6");
		this.validationToken = mDBConfigManager.getConfigString("API_ValidationToken", "");
		Logger.info("building engines 7");
		if (mValidationToken == "") {
			Logger.error("ValidationToken is empty.  Cannot continue without a valid ValidationToken.");
		}
		Logger.info("building engines 8");
		Logger.info("DBFacade: accountId: " + Std.string(mAccountId));
		mUILevelUpPostController = new UILevelUpPostController(this);
		mAccountBonus = new AccountBonus(this);
		createTokenRegenTask();
		logSystemMetrics();
		NODE_RULES = (ASCompat.toInt(getSplitTestBoolean("NODE_UNLOCK_GLOBAL", false)) : UInt);
		environmentPrefix = dbConfigManager.getConfigString("EnvironmentPrefix", "u");
		mMenuNavigationController = new MenuNavigationController(this);
		mCustomSkinVisualsOverrideHandler = new CustomSkinVisualsOverrideHandler(this);
	}

	function localeAvailable() {
		var _loc1_:ServiceDiscoveryReadyEvent = null;
		Logger.debug("locale available");
		if (mPendingServiceDiscoveryEvent != null && Locale.isDefaultLoaded) {
			_loc1_ = mPendingServiceDiscoveryEvent;
			mPendingServiceDiscoveryEvent = null;
			mEventComponent.dispatchEvent(_loc1_);
		}
	}

	override public function mainLoop(event:Event) {
		mSteamInputManager.runFrame();
		super.mainLoop(event);
		if (mFPSReadout != null) {
			mFPSReadout.update(mTickCounter, mWallClockTimeElapsed, ASCompat.floatToInt(mFrameAccumulator), mRenderTickCounter,
				ASCompat.floatToInt(mTickAccumulator));
		}
	}

	override function flushInputs() {
		super.flushInputs();
		mSteamInputManager.flushInputs();
	}

	function requestNewValidationToken(gameClock:GameClock) {
		var requestFunc:ASFunction;
		var facade:DBFacade;
		Logger.info("DBFacade: requesting new validation token");
		requestFunc = JSONRPCService.getFunction("token", this.rpcRoot + "account");
		facade = this;
		requestFunc(this.dbAccountInfo.id, this.validationToken, function(param1:String) {
			Logger.info("DBFacade: success - new validation token: [Redacted]");
			facade.validationToken = param1;
		}, function(param1:Error) {
			Logger.info("DBFacade: requesting new validation token: ERROR:" + Std.string(param1));
			if (mainStateMachine.currentStateName != "RunState") {
				enterSocketErrorState();
			} else {
				mEventComponent.addListener("CLIENT_EXIT_COMPLETE", enterSocketErrorState);
			}
			removeTokenRegenTask();
		});
	}

	function enterSocketErrorState(event:Event = null) {
		mDistributedObjectManager.enterSocketErrorState((100 : UInt), Locale.getString("FACEBOOK_LOGOUT"));
		mEventComponent.removeListener("CLIENT_EXIT_COMPLETE");
	}

	public function createTokenRegenTask() {
		removeTokenRegenTask();
		mTokenRegenTask = mRealClockWorkManager.doEverySeconds(3600, this.requestNewValidationToken, true, "DBFacade.tokenRegen");
	}

	public function removeTokenRegenTask() {
		if (mTokenRegenTask != null) {
			mTokenRegenTask.destroy();
			mTokenRegenTask = null;
		}
	}

	override public function init(stageRef:Stage) {
		super.init(stageRef);
		mDisplayTimingSettings = new DisplayTimingSettings(stageRef);
		MemoryTracker.stage = stageRef;
		this.stageRef.showDefaultContextMenu = false;
		EventListeners.add(this.stageRef, "keyDown", toggleFullscreen);
		EventListeners.add(this.stageRef, "keyDown", altEnterFullscreen, true);
		EventListeners.add(this.stageRef, "keyDown", altEnterFullscreen);
		EventListeners.add(this.stageRef, "keyUp", releaseAltEnter, true);
		EventListeners.add(this.stageRef, "keyUp", releaseAltEnter);
		EventListeners.add(this.stageRef, "deactivate", forgetPlainEnter);
		createLetterbox();
		mInitialLoadingClip = ASCompat.coerce(ASCompat.createInstance(LoadingClass, []), flash.display.MovieClip);
		mInitialLoadingClip.addFrameScript(mInitialLoadingClip.totalFrames - 1, mInitialLoadingClip.stop);
		mLoadingBar = new UIProgressBar(this, ASCompat.coerce((mInitialLoadingClip : ASAny).loadingBar.loadingBar, flash.display.MovieClip));
		this.loadingBarTick();
		mFPSReadout = new FPSReadout(this);
		addRootDisplayObject(mInitialLoadingClip);
		mEventComponent.addListener("enterFrame", this.stagetwo_init);
	}

	function toggleFullscreen(event:KeyboardEvent) {
		if (event.keyCode == 122) {
			stageRef.displayState = this.stageRef.displayState == "normal" ? "fullScreenInteractive" : "normal";
		}
		if (event.keyCode == 27) {
			event.preventDefault();
		}
	}

	function altEnterFullscreen(event:KeyboardEvent) {
		if (event.keyCode != 13) {
			return;
		}
		if (!mAltEnterDown) {
			if (!event.altKey || mPlainEnterDown) {
				mPlainEnterDown = true;
				return;
			}
			mAltEnterDown = true;
			stageRef.displayState = this.stageRef.displayState == "normal" ? "fullScreenInteractive" : "normal";
		}
		event.stopImmediatePropagation();
	}

	function releaseAltEnter(event:KeyboardEvent) {
		if (event.keyCode != 13) {
			return;
		}
		mPlainEnterDown = false;
		if (!mAltEnterDown) {
			return;
		}
		mAltEnterDown = false;
		event.stopImmediatePropagation();
	}

	function forgetPlainEnter(event:Event) {
		mPlainEnterDown = false;
	}

	function createLetterbox() {
		var _loc2_ = new Shape();
		_loc2_.graphics.beginFill((1968136 : UInt));
		var _loc1_:Float = 10000;
		_loc2_.graphics.drawRect(-_loc1_, -_loc1_, _loc1_ + viewWidth + _loc1_, _loc1_);
		_loc2_.graphics.drawRect(-_loc1_, viewHeight, _loc1_ + viewWidth + _loc1_, _loc1_);
		_loc2_.graphics.drawRect(-_loc1_, 0, _loc1_, _loc1_);
		_loc2_.graphics.drawRect(viewWidth, 0, _loc1_, _loc1_);
		_loc2_.graphics.endFill();
		_loc2_.name = "OutOufBoundLetterbox";
		addRootDisplayObject(_loc2_, 1000);
	}

	public function stagetwo_init(event:Event) {
		stagetwo_init_call_count = stagetwo_init_call_count + 1;
		if (stagetwo_init_call_count >= 2) {
			this.loadingBarTick();
			mEventComponent.removeListener("enterFrame");
			if (mAssetLoadingComponent == null) {
				mAssetLoadingComponent = new AssetLoadingComponent(this);
			}
			mEventComponent.addListener("LoadingFinishedEvent", architectureLoaded);
			mEventComponent.addListener("ConfigFileLoadedEvent", configLoaded);
			mMainStateMachine = new MainStateMachine(this);
			mMainStateMachine.enterLoadingState();
		}
	}

	function configLoaded(event:ConfigFileLoadedEvent) {
		this.loadingBarTick();
		mDBConfigManager = event.dbConfigManager;
		initMetricsLogger();
		Logger.setDebugMessages(dbConfigManager.getConfigBoolean("want_debug_logging", true));
		Logger.setInfoMessages(dbConfigManager.getConfigBoolean("want_info_logging", true));
		mEventComponent.removeListener("ConfigFileLoadedEvent");
		Logger.CustomLoggerString = dbConfigManager.getConfigString("customLoggerString", null);
		var _loc2_ = dbConfigManager.getConfigString("ServiceDiscoveryUrl", "");
		if (_loc2_ == "") {
			Logger.fatal("ServiceDiscoveryUrl is empty. Unable to continue.");
		}
		new ServiceDiscoveryLoader(_loc2_, onServiceDiscoveryComplete);
		mUseSteamLogin = dbConfigManager.getConfigBoolean("UseSteamLogin", true);
		if (this.getUserAgent() == "Internet Explorer" && !mDBConfigManager.getConfigBoolean("turn_off_ie_input_hack", false)) {
			this.setupFocusHack();
		}
		mDownloadRoot = dbConfigManager.getConfigString("download_root", "./");
		cacheVersion = mDBConfigManager.getConfigString("CacheVersion", "development");
		buildEngines();
	}

	function onServiceDiscoveryComplete(result:ASObject, errorCode:Int, errorText:String) {
		var _loc4_ = new ServiceDiscoveryReadyEvent(result, errorCode, errorText);
		if (Locale.isDefaultLoaded) {
			mEventComponent.dispatchEvent(_loc4_);
		} else {
			mPendingServiceDiscoveryEvent = _loc4_;
		}
	}

	public function applyServiceDiscoveryResult(result:ASObject) {
		mWebServicesUrl = ASCompat.asString(result.webServicesUrl);
		mGameSocketAddress = ASCompat.asString(result.gameSocketAddress);
		mGameSocketPort = ASCompat.asInt(result.gameSocketPort);
		mGameSocketTlsOffered = result.gameSocketTls == true;
		mGameSocketWssPath = result.gameSocketWssPath != null ? ASCompat.toString(result.gameSocketWssPath) : "";
		mWebAPIRoot = mWebServicesUrl + "/api/";
		mRPCRoot = mWebServicesUrl + "/rpc/";
		mSteamAPIRoot = mWebServicesUrl + "/steam/";
	}

	function initMetricsLogger() {
		mMetricsLogger = new MetricsLogger(this, dbConfigManager.getConfigString("metrics_logging_url", ""));
		Logger.errorCallback = loggerErrorCall;
	}

	public function toggleFpsOverlay() {
		if (mFPSReadout != null) {
			mFPSReadout.toggleVisibility();
		}
	}

	@:isVar public var fpsReadout(get, never):FPSReadout;

	public function get_fpsReadout():FPSReadout {
		return mFPSReadout;
	}

	public function preLoadJson() {
		this.loadingBarTick();
		var _loc3_ = dbConfigManager.getConfigString("gameMasterPath", "Resources/Levels/DB_GameMaster_C.json");
		var _loc4_ = buildFullDownloadPath(_loc3_);
		var _loc1_ = buildFullDownloadPath("Resources/Levels/library_server.json");
		var _loc2_ = buildFullDownloadPath("Resources/Combat/AttackTimeline.json");
		mAssetLoadingComponent.getJsonAsset(_loc4_, gameMasterFinishedLoading, errorLoadingGameMaster);
		mAssetLoadingComponent.getJsonAsset(_loc1_, libraryFinishedLoading, errorLoadingLibrary);
		mAssetLoadingComponent.getJsonAsset(_loc2_, timelineFinishedLoading, errorLoadingAttackTimeline);
	}

	function errorLoadingGameMaster() {
		Logger.fatal("Error loading Game Master json.");
	}

	function errorLoadingLibrary() {
		Logger.fatal("Error loading Server Library json.");
	}

	function errorLoadingAttackTimeline() {
		Logger.fatal("Error loading Attack Timeline json.");
	}

	public function ClearCachedTileLibraryJson() {
		var _loc2_:JsonAsset = null;
		mTileLibraryMap.clear();
		var _loc1_:ASObject;
		final __ax4_iter_81 = mJsonAssets;
		if (checkNullIteratee(__ax4_iter_81))
			for (_tmp_ in __ax4_iter_81) {
				_loc1_ = _tmp_;
				_loc2_ = ASCompat.dynamicAs(_loc1_, JsonAsset);
				_loc2_.destroy();
			}
		if (mJsonAssets != null) {
			mJsonAssets.resize(0);
		}
	}

	public function AddTileLibraryJson(path:String, tileLibraryJson:JsonAsset) {
		mTileLibraryMap.add(path, tileLibraryJson.json);
		if (mJsonAssets == null) {
			mJsonAssets = [];
		}
		mJsonAssets.push(tileLibraryJson);
	}

	public function getTileLibraryJson(path:String):ASObject {
		return mTileLibraryMap.itemFor(path);
	}

	@:isVar public var libraryJson(get, never):Array<ASAny>;

	public function get_libraryJson():Array<ASAny> {
		return mLibraryJson;
	}

	function libraryFinishedLoading(libraryJson:JsonAsset) {
		var _loc2_:ASObject;
		var __ax4_iter_83:ASAny;
		Logger.info("libraryFinishedLoading");
		this.loadingBarTick();
		mLibraryJsonLoaded = true;
		var _loc5_ = 0;
		var _loc4_ = 0;
		mLibraryJson = ASCompat.dynamicAs(libraryJson.json, Array);
		var _loc3_:ASObject;
		final __ax4_iter_82:ASObject = libraryJson.json;
		if (checkNullIteratee(__ax4_iter_82))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_82)) {
				_loc3_ = _tmp_;
				_loc4_ = 0;
				__ax4_iter_83 = _loc3_.navCollisions;
				if (checkNullIteratee(__ax4_iter_83))
					for (_tmp_ in __ax4_iter_83) {
						_loc2_ = _tmp_;
						_loc4_ += GetSecurityValue(_loc2_);
					}
				_loc5_ += _loc4_ % 541;
			}
		mSecuritySL = _loc5_ % 1097;
		checkIfFactoryReadyToLoad();
	}

	public function GetSecurityValue(jsonAsset:ASObject):Int {
		var _loc2_ = 0;
		var _loc3_:ASObject;
		if (checkNullIteratee(jsonAsset))
			for (_tmp_ in iterateDynamicValues(jsonAsset)) {
				_loc3_ = _tmp_;
				if (ASCompat.getQualifiedClassName(_loc3_) == "int") {
					_loc2_ += ASCompat.floatToInt(Math.abs(ASCompat.toInt(_loc3_)) % 17 + Math.abs(ASCompat.toInt(_loc3_)) / 19);
				}
			}
		return _loc2_;
	}

	@:isVar public var timelineFactory(get, never):TimelineFactory;

	public function get_timelineFactory():TimelineFactory {
		return mTimelineFactory;
	}

	function timelineFinishedLoading(jsonAsset:JsonAsset) {
		Logger.info("timelineFinishedLoading");
		this.loadingBarTick();
		mTimelineFinishedLoading = true;
		mTimelineFactory = new TimelineFactory(this, jsonAsset);
		MemoryTracker.track(mTimelineFactory, "TimelineFactory - created in DBFacade.timelineFinishedLoading()");
		mSecurityTL = mTimelineFactory.securityChecksum;
		checkIfFactoryReadyToLoad();
	}

	function gameMasterFinishedLoading(gameMasterJson:JsonAsset) {
		this.loadingBarTick();
		mGameMasterJson = gameMasterJson.json;
		gameMaster = new GameMaster(mGameMasterJson, this.splitTests);
		mSecurityGM = gameMaster.securityChecksum;
		mGameMasterJsonLoaded = true;
		var _loc3_ = false;
		var _loc2_:ASObject;
		final __ax4_iter_84:ASAny = mGameMasterJson.Hero;
		if (checkNullIteratee(__ax4_iter_84))
			for (_tmp_ in __ax4_iter_84) {
				_loc2_ = _tmp_;
				if (ASCompat.toNumberField(_loc2_, "BaseMove") > 250) {
					_loc3_ = true;
				}
			}
		if (_loc3_) {
			mGameMasterJsonLoaded = false;
			blockCheater();
		}
		checkIfFactoryReadyToLoad();
	}

	public function blockCheater() {
		mLoadingBar.displayErrorMessage("Loading Error: Broken files have been detected in your system. \nYou must verify the integrity of the game\'s files in order to load and play the game.\nPlease visit https://discord.gg/dungeonrampage for questions or assistance with this issue.");
	}

	public function regenerateGameMaster() {
		if (mGameMasterJsonLoaded) {
			gameMaster = new GameMaster(mGameMasterJson, this.splitTests);
		}
	}

	function checkIfFactoryReadyToLoad() {
		if (mTimelineFinishedLoading && this.mGameMasterJsonLoaded && this.mLibraryJsonLoaded) {
			mEventComponent.dispatchEvent(new ManagersLoadedEvent());
		}
	}

	@:isVar public var sCode(get, never):Int;

	public function get_sCode():Int {
		return mSecurityGM + mSecurityTL + mSecuritySL;
	}

	public function loadingBarTick() {
		if (mLoadingBar != null) {
			mLoadingBar.value += 0.06666666666666667;
			mLoadingBarIntStatus = mLoadingBarIntStatus + 1;
			setLoadingBarText("LOADING " + String.fromCharCode(ASCompat.floatToInt(64 + mLoadingBarIntStatus)) + "...");
		}
	}

	public function setLoadingBarText(message:String) {
		var _loc2_ = mInitialLoadingClip != null ? ASCompat.dynamicAs((mInitialLoadingClip : ASAny).loadingBar, MovieClip) : null;
		var _loc4_ = _loc2_ != null ? ASCompat.dynamicAs((_loc2_ : ASAny).loading_text, TextField) : null;
		if (_loc4_ == null || _loc4_.text == message) {
			return;
		}
		Logger.info("loadingBarTick at: " + message);
		_loc4_.text = message;
		var _loc3_ = _loc4_.textWidth + 4;
		if (_loc3_ > _loc4_.width) {
			_loc4_.x -= (_loc3_ - _loc4_.width) / 2;
			_loc4_.width = _loc3_;
		}
	}

	@:isVar public var loadingStateLeft(get, never):Bool;

	public function get_loadingStateLeft():Bool {
		return mMainStateMachine != null && !Std.isOfType(mMainStateMachine.currentState, LoadingState);
	}

	public function powerUpDistributedObjectManager() {
		var _loc2_ = false;
		var _loc1_:GameEndpoints = null;
		var _loc3_ = false;
		Logger.info("*****************Starting powerUpDistributedObjectManager");
		this.loadingBarTick();
		if (mDistributedObjectManager == null) {
			if (mGameSocketAddress == null || mGameSocketAddress == "") {
				Logger.fatal("GameSocketAddress is empty.  Unable to continue.");
				return;
			}
			TransportSettings.applyOverrides(dbConfigManager);
			_loc2_ = dbConfigManager.getConfigBoolean("EnforceServerCertificate", true);
			_loc1_ = new GameEndpoints(mGameSocketAddress, mGameSocketPort, mGameSocketWssPath, _loc2_, mGameSocketTlsOffered);
			_loc3_ = featureFlags.getFlagValue("experimental-websocket-reconnects");
			Logger.info("WorldServer endpoints: " + _loc1_ + " experimentalWebSocketReconnects=" + _loc3_);
			mDistributedObjectManager = new DistributedObjectManager(this);
			MemoryTracker.track(mDistributedObjectManager, "DistributedObjectManager - created in DBFacade.startGame()");
			mDistributedObjectManager.Initialize(_loc1_, _loc3_, validationToken, demographicsJson, accountId,
				(ASCompat.floatToInt(dbConfigManager.networkId) : UInt), NODE_RULES);
		}
	}

	public function onConnectionReconnecting(reason:String) {
		Logger.warn("WorldServer connection lost, resuming: " + reason);
		mMainStateAtDrop = mMainStateMachine?.currentStateName;
		showReconnectingIndicator();
		if (!mReconnectFrozeInput && inputManager != null) {
			inputManager.disableControls();
			mReconnectFrozeInput = true;
		}
	}

	public function onConnectionReconnectAttempt(attempt:Int, elapsedMilliseconds:Int, graceMilliseconds:Int) {
		showReconnectingIndicator();
		mReconnectingIndicator.update(attempt, elapsedMilliseconds, graceMilliseconds);
	}

	public function onConnectionResumed() {
		Logger.info("WorldServer connection resumed.");
		if (reconnectChangedMainState) {
			Logger.warn("WorldServer connection resumed into " + mMainStateMachine.currentStateName + " after dropping in " + mMainStateAtDrop);
		}
		endReconnecting();
	}

	@:isVar public var reconnectChangedMainState(get, never):Bool;

	public function get_reconnectChangedMainState():Bool {
		return mMainStateAtDrop != null && mMainStateMachine != null && mMainStateMachine.currentStateName != mMainStateAtDrop;
	}

	public function onConnectionReconnectFailed() {
		Logger.warn("WorldServer connection could not be resumed.");
		endReconnecting();
	}

	function endReconnecting() {
		var _loc1_:UIReconnectingIndicator = null;
		mMainStateAtDrop = null;
		if (mReconnectingIndicator != null) {
			_loc1_ = mReconnectingIndicator;
			mReconnectingIndicator = null;
			_loc1_.destroy();
		}
		if (mReconnectFrozeInput) {
			mReconnectFrozeInput = false;
			if (inputManager != null) {
				inputManager.enableControls();
			}
		}
	}

	function showReconnectingIndicator() {
		if (mReconnectingIndicator == null) {
			mReconnectingIndicator = new UIReconnectingIndicator(this);
		}
		mReconnectingIndicator.show();
	}

	public function warningPopup(title:String, message:String) {
		var _loc3_ = new DBUIOneButtonPopup(this, "WARNING_POPUP", title, message, Locale.getString("OK"), null);
		MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in DBFacade.warningPopup()");
	}

	public function errorPopup(title:String, message:String, uiLayerName:String) {
		if (menuNavigationController != null && menuNavigationController.getAllCurrentLayers().indexOf(uiLayerName) >= 0) {
			return;
		}
		var _loc4_ = new DBUIOneButtonPopup(this, uiLayerName, title, message, Locale.getString("OK"), null);
		MemoryTracker.track(_loc4_, "DBUIOneButtonPopup - created in DBFacade.errorPopup()");
	}

	function getUserAgent():String {
		var _loc2_:String = null;
		var _loc1_:String = null;
		try {
			_loc2_ = ExternalInterface.call("window.navigator.userAgent.toString");
			_loc1_ = "[Unknown Browser]";
			if (_loc2_.indexOf("Safari") != -1) {
				_loc1_ = "Safari";
			} else if (_loc2_.indexOf("Firefox") != -1) {
				_loc1_ = "Firefox";
			} else if (_loc2_.indexOf("Chrome") != -1) {
				_loc1_ = "Chrome";
			} else if (_loc2_.indexOf("MSIE") != -1) {
				_loc1_ = "Internet Explorer";
			} else if (_loc2_.indexOf("Opera") != -1) {
				_loc1_ = "Opera";
			}
		} catch (e:Dynamic) {
			return "[No ExternalInterface]";
		}
		return _loc1_;
	}

	function logSystemMetrics() {
		var _loc1_:ASObject = {};
		ASCompat.setProperty(_loc1_, "language", Capabilities.language);
		ASCompat.setProperty(_loc1_, "os", Capabilities.os);
		ASCompat.setProperty(_loc1_, "screenResX", Capabilities.screenResolutionX);
		ASCompat.setProperty(_loc1_, "screenResY", Capabilities.screenResolutionY);
		ASCompat.setProperty(_loc1_, "flashVersion", Capabilities.version);
		ASCompat.setProperty(_loc1_, "browser", this.getUserAgent());
		mMetricsLogger.log("FlashCapabilities", _loc1_);
	}

	public function enteringSocketError() {
		if (mInitialLoadingClip != null) {
			removeRootDisplayObject(mInitialLoadingClip);
			mInitialLoadingClip = null;
		}
	}

	function architectureLoaded(event:LoadingFinishedEvent) {
		this.loadingBarTick();
		mDBAccountInfo = event.dbAccountInfo;
		mEventComponent.removeListener("LoadingFinishedEvent");
		mGameClock.initTime();
		this.run();
		mMainStateMachine.start();
		if (mInitialLoadingClip != null) {
			removeRootDisplayObject(mInitialLoadingClip);
			mInitialLoadingClip = null;
			mLoadingBar.destroy();
			mLoadingBar = null;
		}
		mMetricsLogger.log("ArchitectureLoaded", {});
	}

	@:isVar public var dbConfigManager(get, never):DBConfigManager;

	public function get_dbConfigManager():DBConfigManager {
		return mDBConfigManager;
	}

	@:isVar public var dbAccountInfo(get, set):DBAccountInfo;

	public function get_dbAccountInfo():DBAccountInfo {
		return mDBAccountInfo;
	}

	function set_dbAccountInfo(dbAccInfo:DBAccountInfo):DBAccountInfo {
		return mDBAccountInfo = dbAccInfo;
	}

	@:isVar public var gameMasterJson(get, never):ASObject;

	public function get_gameMasterJson():ASObject {
		return mGameMasterJson;
	}

	@:isVar public var hud(get, never):IGameHud;

	public function get_hud():IGameHud {
		return mHud;
	}

	@:isVar public var effectPool(get, never):EffectPool;

	public function get_effectPool():EffectPool {
		if (mEffectPool == null) {
			mEffectPool = new EffectPool();
			MemoryTracker.track(mEffectPool, "EffectPool - created in DBFacade.effectPool getter", "pool");
		}
		return mEffectPool;
	}

	@:isVar public var movieClipPool(get, never):MovieClipPool;

	public function get_movieClipPool():MovieClipPool {
		if (mMovieClipPool == null) {
			mMovieClipPool = new MovieClipPool();
			MemoryTracker.track(mMovieClipPool, "MovieClipPool - created in DBFacade.movieClipPool getter", "pool");
		}
		return mMovieClipPool;
	}

	@:isVar public var mainStateMachine(get, never):MainStateMachine;

	public function get_mainStateMachine():MainStateMachine {
		return mMainStateMachine;
	}

	@:isVar public var heroInputSuspended(get, never):Bool;

	public function get_heroInputSuspended():Bool {
		return mMainStateMachine != null && Std.isOfType(mMainStateMachine.currentState, LoadingScreenState);
	}

	@:isVar public var accountBonus(get, never):AccountBonus;

	public function get_accountBonus():AccountBonus {
		return mAccountBonus;
	}

	@:isVar public var metrics(get, never):MetricsLogger;

	public function get_metrics():MetricsLogger {
		return mMetricsLogger;
	}

	@:isVar public var webServiceAPIRoot(get, never):String;

	public function get_webServiceAPIRoot():String {
		return mWebAPIRoot;
	}

	@:isVar public var webServicesUrl(get, never):String;

	public function get_webServicesUrl():String {
		return mWebServicesUrl;
	}

	@:isVar public var playerActivityCount(get, set):PlayerActivityCount;

	public function get_playerActivityCount():PlayerActivityCount {
		return mPlayerActivityCount;
	}

	function set_playerActivityCount(inPlayerActivityCount:PlayerActivityCount):PlayerActivityCount {
		return mPlayerActivityCount = inPlayerActivityCount;
	}

	@:isVar public var rpcRoot(get, never):String;

	public function get_rpcRoot():String {
		return mRPCRoot;
	}

	@:isVar public var steamAPIRoot(get, never):String;

	public function get_steamAPIRoot():String {
		return mSteamAPIRoot;
	}

	@:isVar public var downloadRoot(get, never):String;

	public function get_downloadRoot():String {
		return mDownloadRoot;
	}

	@:isVar public var accountId(get, set):UInt;

	public function set_accountId(value:UInt):UInt {
		mAccountId = value;
		JSONRPCService.accountId = Std.string(value);
		return value;
	}

	function get_accountId():UInt {
		return mAccountId;
	}

	@:isVar public var validationToken(get, set):String;

	public function set_validationToken(value:String):String {
		mValidationToken = value;
		return JSONRPCService.validationToken = value;
	}

	function get_validationToken():String {
		return mValidationToken;
	}

	@:isVar public var demographics(get, never):ASObject;

	public function get_demographics():ASObject {
		return mDemographics;
	}

	@:isVar public var demographicsJson(get, never):String;

	public function get_demographicsJson():String {
		return JsonCodec.encode(mDemographics);
	}

	@:isVar public var steamInputManager(get, never):SteamInputManager;

	public function get_steamInputManager():SteamInputManager {
		return mSteamInputManager;
	}

	function _textFocus(e:FocusEvent) {
		if (mStageRef.focus != null) {
			if (!(Std.isOfType(mStageRef.focus, TextField) && cast(mStageRef.focus, TextField).type == "input")) {
				this.regainFocus();
			}
		} else {
			this.regainFocus();
		}
	}

	function setupFocusHack() {
		mHiddenFocusText = new TextField();
		mHiddenFocusText.name = "DBFacade.hiddenFocusText";
		mHiddenFocusText.type = "input";
		mHiddenFocusText.width = 1;
		mHiddenFocusText.height = 1;
		mHiddenFocusText.alpha = 0;
		mHiddenFocusText.mouseEnabled = false;
		mHiddenFocusText.tabEnabled = false;
		addRootDisplayObject(mHiddenFocusText);
		EventListeners.add(mHiddenFocusText, "focusOut", _textFocus);
		this.regainFocus();
	}

	public function regainFocus() {
		mStageRef.focus = ASCompat.coerce(mHiddenFocusText != null ? mHiddenFocusText : mStageRef, flash.display.InteractiveObject);
	}

	@:isVar public var textInputHasFocus(get, never):Bool;

	public function get_textInputHasFocus():Bool {
		var _loc1_ = ASCompat.reinterpretAs(mStageRef.focus, TextField);
		return _loc1_ != null && _loc1_.type == "input" && _loc1_ != mHiddenFocusText;
	}

	public function loggerErrorCall(logString:String) {
		var _loc2_:ASObject = null;
		if (this.metrics != null && logicalWorkManager != null) {
			_loc2_ = {};
			ASCompat.setProperty(_loc2_, "details", logString);
			if (mDelayErrors == null) {
				mDelayErrors = [];
			}
			mDelayErrors.push(_loc2_);
			if (mLogicalWorkComponent == null) {
				mLogicalWorkComponent = new LogicalWorkComponent(this, "DBFacade");
			}
			if (mErrorTask == null) {
				mErrorTask = mLogicalWorkComponent.doLater(2, sendErrors);
			}
		}
	}

	function sendErrors(t:ASAny) {
		var _loc2_:Array<ASAny> = null;
		mErrorTask = null;
		if (mDelayErrors != null) {
			_loc2_ = mDelayErrors;
			mDelayErrors = null;
			t = 0;
			while (ASCompat.toNumber(t) < _loc2_.length) {
				this.metrics.log("CLIENT_ERROR_EVENT", _loc2_[ASCompat.toInt(t)]);
				t = ASCompat.toInt(t) + 1;
			}
		}
	}

	@:isVar public var splitTests(get, never):ASObject;

	public function get_splitTests():ASObject {
		return this.dbConfigManager.GetValueOrDefault("SplitTests", {});
	}

	public function getSplitTestNumber(key:String, defaultValue:Float):Float {
		var _loc3_:ASObject;
		final __ax4_iter_85:ASObject = this.splitTests;
		if (checkNullIteratee(__ax4_iter_85))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_85)) {
				_loc3_ = _tmp_;
				if (_loc3_.name == key) {
					return ASCompat.toNumber(_loc3_.value);
				}
			}
		Logger.debug("splitTestValueFor test not found: " + key);
		return defaultValue;
	}

	public function getSplitTestBoolean(key:String, defaultValue:Bool):Bool {
		var _loc3_:ASObject;
		final __ax4_iter_86:ASObject = this.splitTests;
		if (checkNullIteratee(__ax4_iter_86))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_86)) {
				_loc3_ = _tmp_;
				if (_loc3_.name == key) {
					Logger.debug("splitTestValueFor " + key + ": " + Std.string(_loc3_.value));
					return _loc3_.value == "true";
				}
			}
		Logger.debug("splitTestValueFor test not found: " + key);
		return defaultValue;
	}

	public function getSplitTestString(key:String, defaultValue:String):String {
		var _loc3_:ASObject;
		final __ax4_iter_87:ASObject = this.splitTests;
		if (checkNullIteratee(__ax4_iter_87))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_87)) {
				_loc3_ = _tmp_;
				if (_loc3_.name == key) {
					return _loc3_.value;
				}
			}
		Logger.debug("splitTestValueFor test not found: " + key);
		return defaultValue;
	}

	public function receiveDailyRewards() {}

	public function getInfiniteDungeonDetailForNodeId(nodeId:UInt):InfiniteMapNodeDetail {
		return mDistributedObjectManager.mMatchMaker.getInfiniteDungeonDetailForNodeId(nodeId);
	}

	public function overlaySteamwithURL(urlLink:String) {
		var _loc3_:URLRequest = null;
		var _loc2_ = mSteamworks.isOverlayEnabled();
		var _loc4_ = stageRef.displayState == "fullScreenInteractive";
		if (_loc2_ && _loc4_) {
			Logger.debug("Using activateGameOverlayToStore to open steam page");
			mSteamworks.activateGameOverlayToWebPage(urlLink);
		} else {
			Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc2_ + " isFullscreen:" + _loc4_);
			_loc3_ = new URLRequest(urlLink);
			flash.Lib.getURL(_loc3_, "_blank");
		}
	}

	public function overlaySteamBasedOnAppId(appId:UInt) {
		overlaySteamwithURL("https://store.steampowered.com/app/" + appId + "/");
	}

	@:isVar public var menuNavigationController(get, never):MenuNavigationController;

	public function get_menuNavigationController():MenuNavigationController {
		return mMenuNavigationController;
	}

	@:isVar public var customSkinVisualsOverrideHandler(get, never):CustomSkinVisualsOverrideHandler;

	public function get_customSkinVisualsOverrideHandler():CustomSkinVisualsOverrideHandler {
		return mCustomSkinVisualsOverrideHandler;
	}

	@:isVar public var keyBindings(get, never):KeyBindings;

	public function get_keyBindings():KeyBindings {
		return mKeyBindings;
	}

	@:isVar public var uiHideToggle(get, never):UIHideToggle;

	public function get_uiHideToggle():UIHideToggle {
		return mUIHideToggle;
	}

	@:isVar public var settingsModel(get, never):SettingsModel;

	public function get_settingsModel():SettingsModel {
		if (mSettingsModel == null) {
			mSettingsModel = new SettingsModel(this);
			MemoryTracker.track(mSettingsModel, "SettingsModel - created in DBFacade.settingsModel");
		}
		return mSettingsModel;
	}

	@:isVar public var displayTimingSettings(get, never):DisplayTimingSettings;

	public function get_displayTimingSettings():DisplayTimingSettings {
		return mDisplayTimingSettings;
	}
}
