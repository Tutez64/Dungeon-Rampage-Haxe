package facade
;
   import account.AccountBonus;
   import account.DBAccountInfo;
   import account.FacebookAccountInfo;
   import account.StoreServices;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.JsonAsset;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.render.MovieClipPool;
   import brain.uI.UIProgressBar;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import brain.jsonRPC.JSONRPCService;
   import combat.attack.TimelineFactory;
   import config.ConfigFileLoadedEvent;
   import config.DBConfigManager;
   import distributedObjects.DistributedObjectManager;
   import effects.EffectPool;
   import events.ManagersLoadedEvent;
   import facebookAPI.DBFacebookAPIController;
   import gameMasterDictionary.GameMaster;
   import generatedCode.InfiniteMapNodeDetail;
   import magicWords.MagicWordManager;
   import metrics.MetricsLogger;
   import metrics.PixelTracker;
   import sound.DBSoundManager;
   import stateMachine.mainStateMachine.LoadingFinishedEvent;
   import stateMachine.mainStateMachine.MainStateMachine;
   import town.AdManager;
   import uI.DBUIOneButtonPopup;
   import uI.UIHud;
   import com.amanitadesign.steam.FRESteamWorks;
   import com.maccherone.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.text.TextField;
   import org.as3commons.collections.Map;
   
    class DBFacade extends Facade
   {
      
      static inline final CLIENT_ERROR_EVENT= "CLIENT_ERROR_EVENT";
      
      public static inline final VALIDATION_REFRESH_TIME:Float = 3600;
      
      static inline final ORDER_COMPLETE_EXTERNAL_INTERFACE= "orderComplete";
      
      static var mDownloadRoot:String = "";
      
      public static inline final NETWORK_FACEBOOK= (1 : UInt);
      
      public static inline final NETWORK_KONGREGATE= (2 : UInt);
      
      public static inline final NETWORK_DRCOM= (3 : UInt);
      
      var LoadingClass:Dynamic = Loading_screen_swf;
      
      var mInitialLoadingClip:MovieClip;
      
      var mLoadingBar:UIProgressBar;
      
      var mLoadingBarIntStatus:Float = 0;
      
      var mMainStateMachine:MainStateMachine;
      
      var mDBAccountInfo:DBAccountInfo;
      
      var mFacebookAccountInfo:FacebookAccountInfo;
      
      var mDBConfigManager:DBConfigManager;
      
      var mHud:UIHud;
      
      var mEffectPool:EffectPool;
      
      var mMovieClipPool:MovieClipPool;
      
      var mMetricsLogger:MetricsLogger;
      
      var mTileLibraryMap:Map;
      
      var mJsonAssets:Array<ASAny>;
      
      var mLibraryJsonLoaded:Bool = false;
      
      var mTimelineFinishedLoading:Bool = false;
      
      var mTimelineFactory:TimelineFactory;
      
      var mGameMasterJsonLoaded:Bool = false;
      
      var mLibraryJson:Array<ASAny>;
      
      var mGameMasterJson:ASObject;
      
      var mDBFaceBookAPIController:DBFacebookAPIController;
      
      var mAccountBonus:AccountBonus;
      
      public var gameMaster:GameMaster;
      
      var mAssetLoader:AssetLoadingComponent;
      
      var mMagicWordManager:MagicWordManager;
      
      var mWebAPIRoot:String;
      
      var mRPCRoot:String;
      
      var mSteamAPIRoot:String;
      
      var mAccountId:UInt = 0;
      
      var mFacebookId:String;
      
      var mFacebookPlayerId:String;
      
      var mFacebookThirdPartyId:String;
      
      var mFacebookApplication:String;
      
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
      
      var mKongregate:ASAny;
      
      var mKongregatePlayerId:String;
      
      var mSecurityGM:Int = 0;
      
      var mSecurityTL:Int = 0;
      
      var mSecuritySL:Int = 0;
      
      var mAdManager:AdManager;
      
      public var mSteamworks:FRESteamWorks = new FRESteamWorks();
      
      public var mSteamUserId:String;
      
      public var mSteamAppId:UInt = (0 : UInt);
      
      public var mSteamPersonaName:String;
      
      public var mSteamWebApiAuthTicket:String;
      
      public var mSteamAuthTicketHandle:UInt = 0;
      
      public var mUseSteamLogin:Bool = false;
      
      public var mSeenFlaggedPopup:Bool = false;
      
      public var mSteamIsFlagged:Bool = false;
      
      public var mSteamFlaggedUntilAfterDateString:String;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged:Bool = false;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerName:String;
      
      public var mAdditionalConfigFilesToLoad:Array<ASAny> = [];
      
      var mShowCollisions:Bool = false;
      
      public var NODE_RULES:UInt = (0 : UInt);
      
      var tKongregateLoader:Loader;
      
      var stagetwo_init_call_count:UInt = (0 : UInt);
      
      public function new()
      {
         super();
         mWantFramerateEnforcement = true;
         mTileLibraryMap = new Map();
         mCheckedDailyReward = false;
         mInDailyReward = false;
         if(Capabilities.playerType == "Desktop")
         {
            return;
         }
         Security.loadPolicyFile("https://ak.ssl.dungeonbusters.com/crossdomain.xml");
         Security.allowDomain("http://ak.ssl.dungeonbusters.com");
         Security.allowInsecureDomain("https://ak.ssl.dungeonbusters.com");
         Security.allowDomain("www.youtube.com");
         Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
         Security.loadPolicyFile("https://fbstatic-a.akamaihd.net/crossdomain.xml");
         Security.loadPolicyFile("https://fbcdn-profile-a.akamaihd.net/crossdomain.xml");
         Security.loadPolicyFile("https://profile-a.xx.fbcdn.net/crossdomain.xml");
         Security.loadPolicyFile("https://profile-b.xx.fbcdn.net/crossdomain.xml");
         Security.allowDomain("http://profile.ak.fbcdn.net");
         Security.allowInsecureDomain("https://profile.ak.fbcdn.net");
         Security.allowDomain("http://profile-a.xx.fbcdn.net");
         Security.allowInsecureDomain("https://profile-a.xx.fbcdn.net");
         Security.allowDomain("http://profile-a.xx.fbcdn.net/hprofile-snc6/");
         Security.allowInsecureDomain("https://profile-a.xx.fbcdn.net/hprofile-snc6/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ash4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ash4/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/");
         Security.allowDomain("http://fbstatic-a.akamaihd.net");
         Security.allowInsecureDomain("https://fbstatic-a.akamaihd.net");
         Security.allowDomain("http://s-static.ak.facebook.com");
         Security.allowInsecureDomain("https://s-static.ak.facebook.com");
         Security.loadPolicyFile("https://ads.sele.co/crossdomain.xml");
         Security.allowDomain("http://ads.sele.co");
         Security.allowInsecureDomain("https://ads.sele.co");
         Security.loadPolicyFile("https://dungionbusters.webfetti.com/crossdomain.xml");
         Security.allowDomain("https://dungionbusters.webfetti.com");
         killWebSecurity();
      }
      
      @:isVar public static var ROOT_DIR_old(get,never):String;
static public function  get_ROOT_DIR_old() : String
      {
         if(!ASCompat.stringAsBool(mDownloadRoot))
         {
            Logger.error("Download root ROOT_DIR is not set yet.");
         }
         return mDownloadRoot;
      }
      
      public static function buildFullDownloadPath(param1:String) : String
      {
         if(param1 == "" || param1 == "null")
         {
            Logger.error("Trying to create a path from an empty string");
            return "";
         }
         return mDownloadRoot + param1;
      }
      
      public function killWebSecurity() 
      {
         Security.allowDomain("*");
      }
      
            
      @:isVar public var showCollisions(get,set):Bool;
public function  get_showCollisions() : Bool
      {
         return mShowCollisions;
      }
function  set_showCollisions(param1:Bool) :Bool      {
         mShowCollisions = param1;
         mSceneGraphManager.getLayer(40).visible = mShowCollisions;
return param1;
      }
      
      override public function logCheater(param1:String) 
      {
         var howICheat= param1;
         var requestFunc= JSONRPCService.getFunction("LogCheater",rpcRoot + "store");
         requestFunc(dbAccountInfo.id,validationToken,howICheat,demographics,function()
         {
         },function(param1:Error)
         {
         });
      }
      
      function loadBackground() 
      {
         var countBackgroundImagesLoaded= 0;
         mAssetLoader.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/left.jpg"),function(param1:brain.assetRepository.ImageAsset)
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_= viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = -_loc2_.width;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
            if(countBackgroundImagesLoaded > 1)
            {
               mStageRef.displayState = "fullScreenInteractive";
            }
         });
         mAssetLoader.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/right.jpg"),function(param1:brain.assetRepository.ImageAsset)
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_= viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = viewWidth;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
            if(countBackgroundImagesLoaded > 1)
            {
               mStageRef.displayState = "fullScreenInteractive";
            }
         });
      }
      
      function loadLocale() 
      {
         var _loc4_:String = null;
         var _loc1_= "en_US";
         var _loc5_= Capabilities.language;
         if("en" != _loc5_)
         {
            Logger.warn("Locale (" + Capabilities.language + ") not yet supported. Using default: " + _loc1_);
            _loc4_ = _loc1_;
         }
         else
         {
            _loc4_ = "en_US";
         }
         Logger.debug("System language: " + Capabilities.language);
         var _loc3_= mDBConfigManager.getConfigString("locale","");
         var _loc2_:String = ASCompat.stringAsBool(_loc3_) ? _loc3_ : _loc4_;
         Logger.debug("Locale selected: " + _loc4_ + " config: " + _loc3_ + " final: " + _loc2_);
         Locale.loadStrings(this,_loc2_,localeAvailable);
         mMagicWordManager = new MagicWordManager(this);
      }
      
      public function createHUD() 
      {
         if(mHud != null)
         {
            return;
         }
         mHud = new UIHud(this);
      }
      
      public function refreshHUD() 
      {
         if(featureFlags.getFlagValue("want-hud-refresh-on-floor-transition"))
         {
            mHud.refreshHUD();
         }
      }
      
      function computeServerTimeOffset() 
      {
         var _loc1_:Date = null;
         var _loc2_= mDBConfigManager.getConfigString("server_time","");
         if(ASCompat.stringAsBool(_loc2_))
         {
            _loc1_ = GameClock.parseW3CDTF(_loc2_);
            GameClock.computeServerTimeOffset(_loc1_);
         }
         Logger.info("server time offset (ms): " + GameClock.serverTimeOffset);
      }
      
      override public function buildEngines() 
      {
         Logger.info("building engines 0");
         loadBackground();
         Logger.info("building engines 1");
         loadLocale();
         Logger.info("building engines 2");
         computeServerTimeOffset();
         super.buildEngines();
         Logger.info("building engines 3");
         mSoundManager = new DBSoundManager(this);
         var _loc1_= mDBConfigManager.getConfigBoolean("show_colliders",false);
         mSceneGraphManager.getLayer(40).visible = _loc1_;
         if(mDBConfigManager.getConfigBoolean("show_redraw_regions",false))
         {
            ASCompat.showRedrawRegions(true,(16711680 : UInt));
         }
         Logger.info("building engines 4");
         this.accountId = (Std.int(mDBConfigManager.getConfigNumber("AccountId",0)) : UInt);
         if(mAccountId == 0)
         {
            Logger.error("AccountId is 0.  Cannot continue without a valid AccountId.");
         }
         Logger.info("building engines 5");
         mDemographics = mDBConfigManager.GetValueOrDefault("Demographics",{});
         mFacebookId = mDBConfigManager.getConfigString("FacebookAppId","");
         mFacebookPlayerId = mDBConfigManager.getConfigString("FacebookPlayerId","");
         mKongregatePlayerId = mDBConfigManager.getConfigString("KongregatePlayerId","");
         Logger.info("building engines 5.1");
         mFacebookThirdPartyId = mDBConfigManager.getConfigString("FacebookThirdPartyId","0");
         mFacebookApplication = mDBConfigManager.getConfigString("FacebookApplication","");
         Logger.info("building engines 6");
         this.validationToken = mDBConfigManager.getConfigString("API_ValidationToken","");
         Logger.info("building engines 7" + mValidationToken);
         if(mValidationToken == "")
         {
            Logger.error("ValidationToken is empty.  Cannot continue without a valid ValidationToken.");
         }
         Logger.info("building engines 8");
         Logger.info("DBFacade: accountId: " + Std.string(mAccountId) + " facebookId: " + mFacebookId.toString() + " Facebook Player Id:" + mFacebookPlayerId.toString() + " Facebook Application:" + mFacebookApplication.toString());
         mDBFaceBookAPIController = new DBFacebookAPIController(this);
         mFacebookAccountInfo = new FacebookAccountInfo(this);
         mAccountBonus = new AccountBonus(this);
         createTokenRegenTask();
         if(isKongregatePlayer)
         {
            kongregateInit();
         }
         logSystemMetrics();
         NODE_RULES = (ASCompat.toInt(getSplitTestBoolean("NODE_UNLOCK_GLOBAL",false)) : UInt);
         environmentPrefix = dbConfigManager.getConfigString("EnvironmentPrefix","u");
      }
      
      function kongregateInit() 
      {
         var request:URLRequest;
         var context:LoaderContext;
         var paramObj:ASObject = stageRef.root.loaderInfo.parameters;
         var apiPath:String = if (ASCompat.toBool(paramObj.kongregate_api_path)) paramObj.kongregate_api_path else "http://www.kongregate.com/flash/API_AS3_Local.swf";
         Security.allowDomain(apiPath);
         Logger.info("Loading Kongregate swf " + apiPath);
         request = new URLRequest(apiPath);
         context = new LoaderContext();
         context.checkPolicyFile = true;
         tKongregateLoader = new Loader();
         tKongregateLoader.contentLoaderInfo.addEventListener("complete",kongregateLoaded);
         tKongregateLoader.contentLoaderInfo.addEventListener("ioError",function(param1:flash.events.IOErrorEvent)
         {
            Logger.error("IOErrorEvent: " + param1.toString() + " Data:" + Std.string(request.data) + " URL:" + apiPath.toString());
         });
         tKongregateLoader.contentLoaderInfo.addEventListener("securityError",function(param1:flash.events.SecurityErrorEvent)
         {
            Logger.error("SecurityErrorEvent: " + param1.toString() + " Data:" + Std.string(request.data) + " URL:" + apiPath.toString());
         });
         tKongregateLoader.load(request,context);
         addRootDisplayObject(tKongregateLoader);
      }
      
      public function kongregateLoaded(param1:Event) 
      {
         Logger.info("Kongregate swf loaded");
         mKongregate = param1.target.content;
         Logger.info("Connecting to Kongregate");
         if(mKongregate.services == null)
         {
            Logger.info("Kongregate services is null!");
         }
         else
         {
            mKongregate.services.connect();
         }
         removeRootDisplayObject(tKongregateLoader);
         tKongregateLoader = null;
         mKongregate.stats.submit("initialized",1);
      }
      
      @:isVar public var kongregateAPI(get,never):ASAny;
public function  get_kongregateAPI() : ASAny
      {
         return mKongregate;
      }
      
      function localeAvailable() 
      {
         Logger.debug("locale available");
      }
      
      function requestNewValidationToken(param1:GameClock) 
      {
         var requestFunc:ASFunction;
         var facade:DBFacade;
         var gameClock= param1;
         Logger.info("DBFacade: requesting new validation token");
         requestFunc = JSONRPCService.getFunction("token",this.rpcRoot + "account");
         facade = this;
         requestFunc(this.dbAccountInfo.id,this.validationToken,function(param1:String)
         {
            Logger.info("DBFacade: success - new validation token: [Redacted]");
            facade.validationToken = param1;
         },function(param1:Error)
         {
            Logger.info("DBFacade: requesting new validation token: ERROR:" + Std.string(param1));
            if(mainStateMachine.currentStateName != "RunState")
            {
               enterSocketErrorState();
            }
            else
            {
               mEventComponent.addListener("CLIENT_EXIT_COMPLETE",enterSocketErrorState);
            }
            removeTokenRegenTask();
         });
      }
      
      function enterSocketErrorState(param1:Event = null) 
      {
         mDistributedObjectManager.enterSocketErrorState((100 : UInt),Locale.getString("FACEBOOK_LOGOUT"));
         mEventComponent.removeListener("CLIENT_EXIT_COMPLETE");
      }
      
      public function createTokenRegenTask() 
      {
         removeTokenRegenTask();
         mTokenRegenTask = mRealClockWorkManager.doEverySeconds(3600,this.requestNewValidationToken,true);
      }
      
      public function removeTokenRegenTask() 
      {
         if(mTokenRegenTask != null)
         {
            mTokenRegenTask.destroy();
            mTokenRegenTask = null;
         }
      }
      
      override public function init(param1:Stage) 
      {
         super.init(param1);
         MemoryTracker.stage = param1;
         this.setupExternalInterfaces();
         this.stageRef.showDefaultContextMenu = false;
         this.stageRef.addEventListener("keyDown",toggleFullscreen);
         createLetterbox();
         mInitialLoadingClip = ASCompat.dynamicAs(ASCompat.createInstance(LoadingClass, []), flash.display.MovieClip);
         mLoadingBar = new UIProgressBar(this,ASCompat.dynamicAs((mInitialLoadingClip : ASAny).loadingBar.loadingBar, flash.display.MovieClip));
         this.loadingBarTick();
         addRootDisplayObject(mInitialLoadingClip);
         mEventComponent.addListener("enterFrame",this.stagetwo_init);
      }
      
      function toggleFullscreen(param1:KeyboardEvent) 
      {
         if(param1.keyCode == 122)
         {
            stageRef.displayState = this.stageRef.displayState == "normal" ? "fullScreenInteractive" : "normal";
         }
         if(param1.keyCode == 27)
         {
            param1.preventDefault();
         }
      }
      
      function createLetterbox() 
      {
         var _loc2_= new Shape();
         _loc2_.graphics.beginFill((1968136 : UInt));
         var _loc1_:Float = 10000;
         _loc2_.graphics.drawRect(-_loc1_,-_loc1_,_loc1_ + viewWidth + _loc1_,_loc1_);
         _loc2_.graphics.drawRect(-_loc1_,viewHeight,_loc1_ + viewWidth + _loc1_,_loc1_);
         _loc2_.graphics.drawRect(-_loc1_,0,_loc1_,_loc1_);
         _loc2_.graphics.drawRect(viewWidth,0,_loc1_,_loc1_);
         _loc2_.graphics.endFill();
         _loc2_.name = "OutOufBoundLetterbox";
         addRootDisplayObject(_loc2_,1000);
      }
      
      public function stagetwo_init(param1:Event) 
      {
         stagetwo_init_call_count = stagetwo_init_call_count + 1;
         if(stagetwo_init_call_count >= 2)
         {
            this.loadingBarTick();
            mEventComponent.removeListener("enterFrame");
            mAssetLoader = new AssetLoadingComponent(this);
            mEventComponent.addListener("LoadingFinishedEvent",architectureLoaded);
            mEventComponent.addListener("ConfigFileLoadedEvent",configLoaded);
            mMainStateMachine = new MainStateMachine(this);
            mMainStateMachine.enterLoadingState();
         }
      }
      
      function setupExternalInterfaces() 
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("orderComplete",function(param1:String, param2:UInt)
            {
               StoreServices.orderCompleteCallback(this ,param1,param2);
            });
            ExternalInterface.addCallback("earnCurrencyCallback",function(param1:ASObject)
            {
               if(ASCompat.toBool(param1) && ASCompat.toNumberField(param1, "vc_amount") > 0)
               {
                  mDBAccountInfo.getUsersFullAccountInfo();
               }
               mMetricsLogger.log("FacebookEarnCallback");
            });
            Logger.debug("ExternalInterface setup complete");
         }
         else
         {
            trace("ExternalInterface not available");
         }
      }
      
      function configLoaded(param1:ConfigFileLoadedEvent) 
      {
         this.loadingBarTick();
         mDBConfigManager = param1.dbConfigManager;
         initMetricsLogger();
         Logger.setDebugMessages(dbConfigManager.getConfigBoolean("want_debug_logging",true));
         Logger.setInfoMessages(dbConfigManager.getConfigBoolean("want_info_logging",true));
         mEventComponent.removeListener("ConfigFileLoadedEvent");
         Logger.CustomLoggerString = dbConfigManager.getConfigString("customLoggerString",null);
         mWebAPIRoot = dbConfigManager.getConfigString("API_root","");
         if(mWebAPIRoot == "")
         {
            Logger.fatal("Webservice API root is empty.  Unable to continue.");
         }
         mRPCRoot = dbConfigManager.getConfigString("RPC_root","");
         if(mRPCRoot == "")
         {
            Logger.fatal("RPC root is empty.  Unable to continue.");
         }
         mSteamAPIRoot = dbConfigManager.getConfigString("STEAM_API_root","");
         if(mSteamAPIRoot == "")
         {
            Logger.fatal("Steam API root is empty.  Unable to continue.");
         }
         mUseSteamLogin = dbConfigManager.getConfigBoolean("UseSteamLogin",true);
         if(this.getUserAgent() == "Internet Explorer" && !mDBConfigManager.getConfigBoolean("turn_off_ie_input_hack",false))
         {
            this.setupFocusHack();
         }
         mDownloadRoot = dbConfigManager.getConfigString("download_root","./");
         cacheVersion = mDBConfigManager.getConfigString("CacheVersion","development");
         buildEngines();
      }
      
      function initMetricsLogger() 
      {
         mMetricsLogger = new MetricsLogger(this,dbConfigManager.getConfigString("metrics_logging_url",""));
         Logger.errorCallback = loggerErrorCall;
      }
      
      public function preLoadJson() 
      {
         this.loadingBarTick();
         var _loc3_= dbConfigManager.getConfigString("gameMasterPath","Resources/Levels/DB_GameMaster.json");
         var _loc4_= buildFullDownloadPath(_loc3_);
         var _loc1_= buildFullDownloadPath("Resources/Levels/library_server.json");
         var _loc2_= buildFullDownloadPath("Resources/Combat/AttackTimeline.json");
         mAssetLoader.getJsonAsset(_loc4_,gameMasterFinishedLoading,errorLoadingGameMaster);
         mAssetLoader.getJsonAsset(_loc1_,libraryFinishedLoading,errorLoadingLibrary);
         mAssetLoader.getJsonAsset(_loc2_,timelineFinishedLoading,errorLoadingAttackTimeline);
      }
      
      function errorLoadingGameMaster() 
      {
         Logger.fatal("Error loading Game Master json.");
      }
      
      function errorLoadingLibrary() 
      {
         Logger.fatal("Error loading Server Library json.");
      }
      
      function errorLoadingAttackTimeline() 
      {
         Logger.fatal("Error loading Attack Timeline json.");
      }
      
      public function ClearCachedTileLibraryJson() 
      {
         var _loc2_:JsonAsset = null;
         mTileLibraryMap.clear();
         var _loc1_:ASAny;
         final __ax4_iter_67 = mJsonAssets;
         if (checkNullIteratee(__ax4_iter_67)) for (_tmp_ in __ax4_iter_67)
         {
            _loc1_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(_loc1_ , JsonAsset);
            _loc2_.destroy();
         }
         if(mJsonAssets != null)
         {
            mJsonAssets.resize(0);
         }
      }
      
      public function AddTileLibraryJson(param1:String, param2:JsonAsset) 
      {
         mTileLibraryMap.add(param1,param2.json);
         if(mJsonAssets == null)
         {
            mJsonAssets = [];
         }
         mJsonAssets.push(param2);
      }
      
      public function getTileLibraryJson(param1:String) : ASObject
      {
         return mTileLibraryMap.itemFor(param1);
      }
      
      @:isVar public var facebookAccountInfo(get,never):FacebookAccountInfo;
public function  get_facebookAccountInfo() : FacebookAccountInfo
      {
         return mFacebookAccountInfo;
      }
      
      @:isVar public var libraryJson(get,never):Array<ASAny>;
public function  get_libraryJson() : Array<ASAny>
      {
         return mLibraryJson;
      }
      
      function libraryFinishedLoading(param1:JsonAsset) 
      {
         var _loc2_:ASAny;
         var __ax4_iter_69:Array<ASAny>;
         Logger.info("libraryFinishedLoading");
         this.loadingBarTick();
         mLibraryJsonLoaded = true;
         var _loc5_= 0;
         var _loc4_= 0;
         mLibraryJson = ASCompat.dynamicAs(param1.json , Array);
         var _loc3_:ASAny;
         final __ax4_iter_68:ASObject = param1.json;
         if (checkNullIteratee(__ax4_iter_68)) for (_tmp_ in iterateDynamicValues(__ax4_iter_68))
         {
            _loc3_ = _tmp_;
            _loc4_ = 0;
            __ax4_iter_69 = _loc3_.navCollisions;
            if (checkNullIteratee(__ax4_iter_69)) for (_tmp_ in __ax4_iter_69)
            {
               _loc2_ = _tmp_;
               _loc4_ += GetSecurityValue(_loc2_);
            }
            _loc5_ += _loc4_ % 541;
         }
         mSecuritySL = _loc5_ % 1097;
         checkIfFactoryReadyToLoad();
      }
      
      public function GetSecurityValue(param1:ASObject) : Int
      {
         var _loc2_= 0;
         var _loc3_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc3_ = _tmp_;
            if(ASCompat.getQualifiedClassName(_loc3_) == "int")
            {
               _loc2_ += Std.int(Math.abs(ASCompat.toInt(_loc3_)) % 17 + Math.abs(ASCompat.toInt(_loc3_)) / 19);
            }
         }
         return _loc2_;
      }
      
      @:isVar public var timelineFactory(get,never):TimelineFactory;
public function  get_timelineFactory() : TimelineFactory
      {
         return mTimelineFactory;
      }
      
      function timelineFinishedLoading(param1:JsonAsset) 
      {
         Logger.info("timelineFinishedLoading");
         this.loadingBarTick();
         mTimelineFinishedLoading = true;
         mTimelineFactory = new TimelineFactory(this,param1);
         MemoryTracker.track(mTimelineFactory,"TimelineFactory - created in DBFacade.timelineFinishedLoading()");
         mSecurityTL = mTimelineFactory.securityChecksum;
         checkIfFactoryReadyToLoad();
      }
      
      function gameMasterFinishedLoading(param1:JsonAsset) 
      {
         this.loadingBarTick();
         mGameMasterJson = param1.json;
         gameMaster = new GameMaster(mGameMasterJson,this.splitTests);
         mSecurityGM = gameMaster.securityChecksum;
         mGameMasterJsonLoaded = true;
         var _loc3_= false;
         var _loc2_:ASAny;
         final __ax4_iter_70:Array<ASAny> = mGameMasterJson.Hero;
         if (checkNullIteratee(__ax4_iter_70)) for (_tmp_ in __ax4_iter_70)
         {
            _loc2_ = _tmp_;
            if(ASCompat.toNumberField(_loc2_, "BaseMove") > 250)
            {
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            mGameMasterJsonLoaded = false;
            blockCheater();
         }
         checkIfFactoryReadyToLoad();
      }
      
      public function blockCheater() 
      {
         mLoadingBar.displayErrorMessage("Loading Error: Broken files have been detected in your system. \nYou must verify the integrity of the game\'s files in order to load and play the game.\nPlease visit https://discord.gg/dungeonrampage for questions or assistance with this issue.");
      }
      
      public function regenerateGameMaster() 
      {
         if(mGameMasterJsonLoaded)
         {
            gameMaster = new GameMaster(mGameMasterJson,this.splitTests);
         }
      }
      
      function checkIfFactoryReadyToLoad() 
      {
         if(mTimelineFinishedLoading && this.mGameMasterJsonLoaded && this.mLibraryJsonLoaded)
         {
            mEventComponent.dispatchEvent(new ManagersLoadedEvent());
         }
      }
      
      @:isVar public var sCode(get,never):Int;
public function  get_sCode() : Int
      {
         return mSecurityGM + mSecurityTL + mSecuritySL;
      }
      
      public function loadingBarTick() 
      {
         var _loc2_:TextField = null;
         var _loc1_:String = null;
         if(mLoadingBar != null)
         {
            mLoadingBar.value += 0.06666666666666667;
            mLoadingBarIntStatus = mLoadingBarIntStatus + 1;
            if(ASCompat.reinterpretAs(mLoadingBar.root.parent , MovieClip) != null && ASCompat.toBool((ASCompat.reinterpretAs(mLoadingBar.root.parent , MovieClip) : ASAny).loading_text))
            {
               _loc2_ = ASCompat.dynamicAs((ASCompat.reinterpretAs(mLoadingBar.root.parent , MovieClip) : ASAny).loading_text , TextField);
               _loc1_ = "LOADING " + String.fromCharCode(Std.int(64 + mLoadingBarIntStatus)) + "...";
               Logger.info("loadingBarTick at: " + _loc1_);
               _loc2_.text = _loc1_;
            }
         }
      }
      
      public function powerUpDistributedObjectManager() 
      {
         var _loc1_:String = null;
         var _loc2_:Float = 0;
         Logger.info("*****************Starting powerUpDistributedObjectManager");
         this.loadingBarTick();
         if(mDistributedObjectManager == null)
         {
            _loc1_ = dbConfigManager.getConfigString("GameSocketAddress","");
            if(_loc1_ == "")
            {
               Logger.fatal("GameSocketAddress is empty.  Unable to continue.");
               return;
            }
            _loc2_ = dbConfigManager.getConfigNumber("GameSocketPort",0);
            if(_loc2_ == 0)
            {
               Logger.fatal("GameSocketPort is empty.  Unable to continue.");
               return;
            }
            Security.loadPolicyFile("xmlsocket://" + _loc1_.toString() + ":843");
            mDistributedObjectManager = new DistributedObjectManager(this);
            MemoryTracker.track(mDistributedObjectManager,"DistributedObjectManager - created in DBFacade.startGame()");
            mDistributedObjectManager.Initialize(_loc1_,Std.int(_loc2_),validationToken,demographicsJson,accountId,(Std.int(dbConfigManager.networkId) : UInt),NODE_RULES);
         }
      }
      
      public function warningPopup(param1:String, param2:String) 
      {
         var _loc3_= new DBUIOneButtonPopup(this,param1,param2,Locale.getString("OK"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in DBFacade.warningPopup()");
      }
      
      public function errorPopup(param1:String, param2:String) 
      {
         var _loc3_= new DBUIOneButtonPopup(this,param1,param2,Locale.getString("OK"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in DBFacade.errorPopup()");
      }
      
      function getUserAgent() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         try
         {
            _loc2_ = ExternalInterface.call("window.navigator.userAgent.toString");
            _loc1_ = "[Unknown Browser]";
            if(_loc2_.indexOf("Safari") != -1)
            {
               _loc1_ = "Safari";
            }
            else if(_loc2_.indexOf("Firefox") != -1)
            {
               _loc1_ = "Firefox";
            }
            else if(_loc2_.indexOf("Chrome") != -1)
            {
               _loc1_ = "Chrome";
            }
            else if(_loc2_.indexOf("MSIE") != -1)
            {
               _loc1_ = "Internet Explorer";
            }
            else if(_loc2_.indexOf("Opera") != -1)
            {
               _loc1_ = "Opera";
            }
         }
         catch(e:Dynamic)
         {
            return "[No ExternalInterface]";
         }
         return _loc1_;
      }
      
      function logSystemMetrics() 
      {
         var _loc1_:ASObject = {};
         ASCompat.setProperty(_loc1_, "language", Capabilities.language);
         ASCompat.setProperty(_loc1_, "os", Capabilities.os);
         ASCompat.setProperty(_loc1_, "screenResX", Capabilities.screenResolutionX);
         ASCompat.setProperty(_loc1_, "screenResY", Capabilities.screenResolutionY);
         ASCompat.setProperty(_loc1_, "flashVersion", Capabilities.version);
         ASCompat.setProperty(_loc1_, "browser", this.getUserAgent());
         mMetricsLogger.log("FlashCapabilities",_loc1_);
      }
      
      public function enteringSocketError() 
      {
         if(mInitialLoadingClip != null)
         {
            removeRootDisplayObject(mInitialLoadingClip);
            mInitialLoadingClip = null;
         }
      }
      
      function architectureLoaded(param1:LoadingFinishedEvent) 
      {
         this.loadingBarTick();
         mDBAccountInfo = param1.dbAccountInfo;
         mDBAccountInfo.checkFriendsHash();
         PixelTracker.returnDAU(this);
         mEventComponent.removeListener("LoadingFinishedEvent");
         mGameClock.initTime();
         this.run();
         mMainStateMachine.start();
         if(mInitialLoadingClip != null)
         {
            removeRootDisplayObject(mInitialLoadingClip);
            mInitialLoadingClip = null;
            mLoadingBar.destroy();
            mLoadingBar = null;
         }
         mMetricsLogger.log("ArchitectureLoaded",{});
      }
      
      @:isVar public var dbConfigManager(get,never):DBConfigManager;
public function  get_dbConfigManager() : DBConfigManager
      {
         return mDBConfigManager;
      }
      
            
      @:isVar public var dbAccountInfo(get,set):DBAccountInfo;
public function  get_dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
function  set_dbAccountInfo(param1:DBAccountInfo) :DBAccountInfo      {
         return mDBAccountInfo = param1;
      }
      
      @:isVar public var gameMasterJson(get,never):ASObject;
public function  get_gameMasterJson() : ASObject
      {
         return mGameMasterJson;
      }
      
      @:isVar public var hud(get,never):UIHud;
public function  get_hud() : UIHud
      {
         return mHud;
      }
      
      @:isVar public var effectPool(get,never):EffectPool;
public function  get_effectPool() : EffectPool
      {
         if(mEffectPool == null)
         {
            mEffectPool = new EffectPool();
            MemoryTracker.track(mEffectPool,"EffectPool - created in DBFacade.effectPool getter","pool");
         }
         return mEffectPool;
      }
      
      @:isVar public var movieClipPool(get,never):MovieClipPool;
public function  get_movieClipPool() : MovieClipPool
      {
         if(mMovieClipPool == null)
         {
            mMovieClipPool = new MovieClipPool();
            MemoryTracker.track(mMovieClipPool,"MovieClipPool - created in DBFacade.movieClipPool getter","pool");
         }
         return mMovieClipPool;
      }
      
      @:isVar public var mainStateMachine(get,never):MainStateMachine;
public function  get_mainStateMachine() : MainStateMachine
      {
         return mMainStateMachine;
      }
      
      @:isVar public var facebookController(get,never):DBFacebookAPIController;
public function  get_facebookController() : DBFacebookAPIController
      {
         return mDBFaceBookAPIController;
      }
      
      @:isVar public var isFacebookPlayer(get,never):Bool;
public function  get_isFacebookPlayer() : Bool
      {
         return dbConfigManager.networkId == 1;
      }
      
      @:isVar public var isKongregatePlayer(get,never):Bool;
public function  get_isKongregatePlayer() : Bool
      {
         return dbConfigManager.networkId == 2;
      }
      
      @:isVar public var isDRPlayer(get,never):Bool;
public function  get_isDRPlayer() : Bool
      {
         return dbConfigManager.networkId == 3;
      }
      
      @:isVar public var accountBonus(get,never):AccountBonus;
public function  get_accountBonus() : AccountBonus
      {
         return mAccountBonus;
      }
      
      @:isVar public var metrics(get,never):MetricsLogger;
public function  get_metrics() : MetricsLogger
      {
         return mMetricsLogger;
      }
      
      @:isVar public var webServiceAPIRoot(get,never):String;
public function  get_webServiceAPIRoot() : String
      {
         return mWebAPIRoot;
      }
      
      @:isVar public var rpcRoot(get,never):String;
public function  get_rpcRoot() : String
      {
         return mRPCRoot;
      }
      
      @:isVar public var steamAPIRoot(get,never):String;
public function  get_steamAPIRoot() : String
      {
         return mSteamAPIRoot;
      }
      
      @:isVar public var downloadRoot(get,never):String;
public function  get_downloadRoot() : String
      {
         return mDownloadRoot;
      }
      
            
      @:isVar public var accountId(get,set):UInt;
public function  set_accountId(param1:UInt) :UInt      {
         mAccountId = param1;
         JSONRPCService.accountId = Std.string(param1);
return param1;
      }
function  get_accountId() : UInt
      {
         return mAccountId;
      }
      
            
      @:isVar public var validationToken(get,set):String;
public function  set_validationToken(param1:String) :String      {
         mValidationToken = param1;
         return JSONRPCService.validationToken = param1;
      }
function  get_validationToken() : String
      {
         return mValidationToken;
      }
      
      @:isVar public var facebookId(get,never):String;
public function  get_facebookId() : String
      {
         return mFacebookId;
      }
      
      @:isVar public var kongregatePlayerId(get,never):String;
public function  get_kongregatePlayerId() : String
      {
         return mKongregatePlayerId;
      }
      
      @:isVar public var facebookPlayerId(get,never):String;
public function  get_facebookPlayerId() : String
      {
         return mFacebookPlayerId;
      }
      
            
      @:isVar public var facebookThirdPartyId(get,set):String;
public function  get_facebookThirdPartyId() : String
      {
         return mFacebookThirdPartyId;
      }
function  set_facebookThirdPartyId(param1:String) :String      {
         return mFacebookThirdPartyId = param1;
      }
      
      @:isVar public var facebookApplication(get,never):String;
public function  get_facebookApplication() : String
      {
         return mFacebookApplication;
      }
      
      @:isVar public var demographics(get,never):ASObject;
public function  get_demographics() : ASObject
      {
         return mDemographics;
      }
      
      @:isVar public var demographicsJson(get,never):String;
public function  get_demographicsJson() : String
      {
         return com.maccherone.json.JSON.encode(mDemographics);
      }
      
      function _textFocus(param1:FocusEvent) 
      {
         if(mStageRef.focus != null)
         {
            if(!(Std.isOfType(mStageRef.focus , TextField) && cast(mStageRef.focus, TextField).type == "input"))
            {
               this.regainFocus();
            }
         }
         else
         {
            this.regainFocus();
         }
      }
      
      function setupFocusHack() 
      {
         mHiddenFocusText = new TextField();
         mHiddenFocusText.name = "DBFacade.hiddenFocusText";
         mHiddenFocusText.type = "input";
         mHiddenFocusText.width = 1;
         mHiddenFocusText.height = 1;
         mHiddenFocusText.alpha = 0;
         mHiddenFocusText.mouseEnabled = false;
         mHiddenFocusText.tabEnabled = false;
         addRootDisplayObject(mHiddenFocusText);
         mHiddenFocusText.addEventListener("focusOut",_textFocus);
         this.regainFocus();
      }
      
      public function regainFocus() 
      {
         mStageRef.focus = ASCompat.dynamicAs(mHiddenFocusText != null ? mHiddenFocusText : mStageRef, flash.display.InteractiveObject);
      }
      
      public function loggerErrorCall(param1:String) 
      {
         var _loc2_:ASObject = null;
         if(this.metrics != null && logicalWorkManager != null)
         {
            _loc2_ = {};
            ASCompat.setProperty(_loc2_, "details", param1);
            if(mDelayErrors == null)
            {
               mDelayErrors = [];
            }
            mDelayErrors.push(_loc2_);
            if(mLogicalWorkComponent == null)
            {
               mLogicalWorkComponent = new LogicalWorkComponent(this);
            }
            if(mErrorTask == null)
            {
               mErrorTask = mLogicalWorkComponent.doLater(2,sendErrors);
            }
         }
      }
      
      function sendErrors(param1:ASAny) 
      {
         var _loc2_:Array<ASAny> = null;
         mErrorTask = null;
         if(mDelayErrors != null)
         {
            _loc2_ = mDelayErrors;
            mDelayErrors = null;
            param1 = 0;
            while(ASCompat.toNumber(param1) < _loc2_.length)
            {
               this.metrics.log("CLIENT_ERROR_EVENT",_loc2_[ASCompat.toInt(param1)]);
               param1 = ASCompat.toInt(param1) + 1;
            }
         }
      }
      
      @:isVar public var splitTests(get,never):ASObject;
public function  get_splitTests() : ASObject
      {
         return this.dbConfigManager.GetValueOrDefault("SplitTests",{});
      }
      
      public function getSplitTestNumber(param1:String, param2:Float) : Float
      {
         var _loc3_:ASAny;
         final __ax4_iter_71:ASObject = this.splitTests;
         if (checkNullIteratee(__ax4_iter_71)) for (_tmp_ in iterateDynamicValues(__ax4_iter_71))
         {
            _loc3_ = _tmp_;
            if(_loc3_.name == param1)
            {
               return ASCompat.toNumber(_loc3_.value);
            }
         }
         Logger.debug("splitTestValueFor test not found: " + param1);
         return param2;
      }
      
      public function getSplitTestBoolean(param1:String, param2:Bool) : Bool
      {
         var _loc3_:ASAny;
         final __ax4_iter_72:ASObject = this.splitTests;
         if (checkNullIteratee(__ax4_iter_72)) for (_tmp_ in iterateDynamicValues(__ax4_iter_72))
         {
            _loc3_ = _tmp_;
            if(_loc3_.name == param1)
            {
               Logger.debug("splitTestValueFor " + param1 + ": " + Std.string(_loc3_.value));
               return _loc3_.value == "true";
            }
         }
         Logger.debug("splitTestValueFor test not found: " + param1);
         return param2;
      }
      
      public function getSplitTestString(param1:String, param2:String) : String
      {
         var _loc3_:ASAny;
         final __ax4_iter_73:ASObject = this.splitTests;
         if (checkNullIteratee(__ax4_iter_73)) for (_tmp_ in iterateDynamicValues(__ax4_iter_73))
         {
            _loc3_ = _tmp_;
            if(_loc3_.name == param1)
            {
               return _loc3_.value;
            }
         }
         Logger.debug("splitTestValueFor test not found: " + param1);
         return param2;
      }
      
      public function receiveDailyRewards() 
      {
      }
      
      public function getInfiniteDungeonDetailForNodeId(param1:UInt) : InfiniteMapNodeDetail
      {
         return mDistributedObjectManager.mMatchMaker.getInfiniteDungeonDetailForNodeId(param1);
      }
      
            
      @:isVar public var adManager(get,set):AdManager;
public function  get_adManager() : AdManager
      {
         return mAdManager;
      }
function  set_adManager(param1:AdManager) :AdManager      {
         return mAdManager = param1;
      }
      
      public function openSteamPage() 
      {
         var _loc2_:URLRequest = null;
         var _loc1_= mSteamworks.isOverlayEnabled();
         var _loc3_= stageRef.displayState == "fullScreenInteractive";
         if(_loc1_ && _loc3_)
         {
            Logger.debug("Using activateGameOverlayToStore to open steam page");
            mSteamworks.activateGameOverlayToStore((3053950 : UInt),(0 : UInt));
         }
         else
         {
            Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc1_ + " isFullscreen:" + _loc3_);
            _loc2_ = new URLRequest("steam://store/3053950");
            flash.Lib.getURL(_loc2_,"_blank");
         }
      }
      
      public function joinDiscordServer() 
      {
         var _loc2_:URLRequest = null;
         var _loc1_= mSteamworks.isOverlayEnabled();
         var _loc3_= stageRef.displayState == "fullScreenInteractive";
         if(_loc1_ && _loc3_)
         {
            Logger.debug("Using activateGameOverlayToStore to open steam page");
            mSteamworks.activateGameOverlayToWebPage("https://discord.com/invite/dungeonrampage");
         }
         else
         {
            Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc1_ + " isFullscreen:" + _loc3_);
            _loc2_ = new URLRequest("https://discord.com/invite/dungeonrampage");
            flash.Lib.getURL(_loc2_,"_blank");
         }
      }
   }


