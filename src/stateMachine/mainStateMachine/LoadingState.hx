package stateMachine.mainStateMachine
;
   import account.DBAccountInfo;
   import account.SteamAccountInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoader;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.stateMachine.State;
   import config.DBConfigManager;
   import config.ServiceDiscoveryReadyEvent;
   import events.DBAccountLoadedEvent;
   import events.ManagersLoadedEvent;
   import events.MatchMakerLoadedEvent;
   import facade.DBFacade;
   import facade.TrickleCacheLoader;
   import steamAchievements.SteamAchievementsManager;
   import uI.map.PlayerActivityCount;
   
    class LoadingState extends State
   {
      
      public static inline final NAME= "LoadingState";
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mAssetLoader:AssetLoadingComponent;
      
      var mConfigLoaded:Bool = false;
      
      var mTimeLoaded:Bool = false;
      
      var mManagersLoaded:Bool = false;
      
      var mAccountLoaded:Bool = false;
      
      var mTransitionsLoaded:Bool = false;
      
      var mMatchMakerLoaded:Bool = false;
      
      var mSteamInfoLoaded:Bool = false;
      
      var mStarteddbAccountInfoLoad:Bool = false;
      
      var mDBAccountInfo:DBAccountInfo;
      
      var mLoadingStartTime:UInt = 0;
      
      public function new(param1:DBFacade, param2:ASFunction = null)
      {
         super("LoadingState",param2);
         mDBFacade = param1;
      }
      
      override public function enterState() 
      {
         super.enterState();
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING LOADING STATE");
         mLoadingStartTime = (mDBFacade.gameClock.realTime : UInt);
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoader = new AssetLoadingComponent(mDBFacade);
         AssetLoader.startTrackingLoads(finishedLoadingCache);
         mEventComponent.addListener("ServiceDiscoveryReadyEvent",configReady);
         mEventComponent.addListener("ManagersLoadedEvent",managersLoaded);
         mEventComponent.addListener("DB_ACCOUNT_INFO_LOADED",accountLoaded);
         mEventComponent.addListener("MATCH_MAKER_LOADED",matchMakerReady);
         var _loc1_= new DBConfigManager(mDBFacade);
         _loc1_.init();
         AssetLoader.stopTrackingLoads();
      }
      
      function finishedLoadingCache() 
      {
         Logger.info("finishedLoadingCache");
         mTransitionsLoaded = true;
         checkIfLoadingFinished();
      }
      
      override public function exitState() 
      {
         mAssetLoader.destroy();
         mAssetLoader = null;
         mEventComponent.destroy();
         mEventComponent = null;
         super.exitState();
         var _loc1_= (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
         mDBFacade.metrics.log("GameLoaded",{"timeSpentSeconds":_loc1_});
         Logger.debug("MAIN STATE MACHINE TRANSITION -- EXIT LOADING STATE");
      }
      
      function configReady(param1:ServiceDiscoveryReadyEvent) 
      {
         Logger.info("LoadingState configReady");
         mDBFacade.loadingBarTick();
         if(param1.serviceDiscoveryResult == null)
         {
            mDBFacade.mainStateMachine.enterSocketErrorState((param1.serviceDiscoveryErrorCode : UInt),param1.serviceDiscoveryErrorText);
            return;
         }
         mDBFacade.applyServiceDiscoveryResult(param1.serviceDiscoveryResult);
         mConfigLoaded = true;
         mDBFacade.featureFlags.loadFeatureFlagValuesFromConfigs(mDBFacade.dbConfigManager);
         SteamAccountInfo.getOrCreateAccount(mDBFacade,steamInfoLoaded);
         mDBFacade.steamAchievementsManager = new SteamAchievementsManager(mDBFacade);
         Logger.infoch("SteamAchievements","creating SteamAchievementsManager");
         TownState.preLoadAssets(mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_daily_reward.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_chest_reveal.swf"),mDBFacade);
         mDBFacade.preLoadJson();
         GameClock.startSetWebServerTime();
         StoreServicesController.getWebServerTimestamp(mDBFacade,timeLoaded);
         mDBFacade.playerActivityCount = new PlayerActivityCount(mDBFacade);
      }
      
      function steamInfoLoaded() 
      {
         Logger.info("mSteamInfoLoaded");
         mDBFacade.loadingBarTick();
         mSteamInfoLoaded = true;
         checkToLoadDBAccountInfo();
         checkIfLoadingFinished();
      }
      
      function timeLoaded() 
      {
         mTimeLoaded = true;
         checkToLoadDBAccountInfo();
         checkIfLoadingFinished();
      }
      
      function matchMakerReady(param1:MatchMakerLoadedEvent) 
      {
         Logger.info("matchMakerReady");
         mDBFacade.loadingBarTick();
         mMatchMakerLoaded = true;
         checkIfLoadingFinished();
      }
      
      function checkToLoadDBAccountInfo() 
      {
         var _loc1_:DBAccountInfo = null;
         if(mConfigLoaded && mManagersLoaded && !mStarteddbAccountInfoLoad && mSteamInfoLoaded)
         {
            _loc1_ = new DBAccountInfo(mDBFacade);
            _loc1_.getUsersFullAccountInfo();
            mStarteddbAccountInfoLoad = true;
         }
      }
      
      function managersLoaded(param1:ManagersLoadedEvent) 
      {
         Logger.info("managersLoaded");
         mDBFacade.loadingBarTick();
         mManagersLoaded = true;
         checkToLoadDBAccountInfo();
         checkIfLoadingFinished();
      }
      
      function accountLoaded(param1:DBAccountLoadedEvent) 
      {
         Logger.info("accountLoaded");
         mDBFacade.loadingBarTick();
         mAccountLoaded = true;
         mDBAccountInfo = param1.dbAccountInfo;
         checkIfLoadingFinished();
      }
      
      function checkIfLoadingFinished() 
      {
         Logger.info("--->checkIfLoadingFinished  mConfigLoaded:" + Std.string(mConfigLoaded) + " mManagersLoaded:" + Std.string(mManagersLoaded) + " mTransitionsLoaded:" + Std.string(mTransitionsLoaded) + " mMatchMakerLoaded:" + Std.string(mMatchMakerLoaded) + " mAccountLoaded:" + Std.string(mAccountLoaded) + " mTimeLoaded:" + Std.string(mTimeLoaded) + " mSteamInfoLoaded:" + Std.string(mSteamInfoLoaded));
         if(mConfigLoaded && mManagersLoaded && mAccountLoaded && mTransitionsLoaded && mMatchMakerLoaded && mTimeLoaded)
         {
            mEventComponent.dispatchEvent(new LoadingFinishedEvent(mDBAccountInfo));
         }
         else if(mConfigLoaded && mManagersLoaded && mAccountLoaded && mTransitionsLoaded)
         {
            mDBFacade.powerUpDistributedObjectManager();
         }
      }
   }


