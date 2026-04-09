package stateMachine.mainStateMachine
;
   import brain.assetRepository.AssetLoader;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.stateMachine.State;
   import brain.uI.UIProgressBar;
   import brain.utils.MemoryTracker;
   import brain.utils.MemoryUtil;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObjectOwner;
   import events.CacheLoadRequestNpcEvent;
   import events.ClientExitCompleteEvent;
   import events.RequestEntryFailedEvent;
   import facade.DBFacade;
   import facade.Locale;
   import facade.TrickleCacheLoader;
   import gameMasterDictionary.GMMapNode;
   import uI.DBUIOneButtonPopup;
   import uI.UIHints;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;

import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.KeyboardEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
   
    class LoadingScreenState extends State
   {
      
      public static inline final NAME= "LoadingScreenState";
      
      public static inline final ERROR_NONE_PARSABLE_DEMOGRAPHICS= (102 : UInt);
      
      public static inline final ERROR_ENTRY_REQUEST_MALFORMED= (103 : UInt);
      
      public static inline final ERROR_ENTRY_REQUEST_BADMAPNODE= (104 : UInt);
      
      public static inline final ERROR_INTERNAL= (105 : UInt);
      
      public static inline final ERROR_INTERNAL_NOT_SUPPORTED= (106 : UInt);
      
      public static inline final ERROR_MAPNODE_NODE_NOTAUTHORIZED= (201 : UInt);
      
      public static inline final WARNING_FRIEND_NOT_FOUND= (500 : UInt);
      
      public static inline final WARNING_FRIEND_GAME_NOT_FOUND= (501 : UInt);
      
      public static inline final WARNING_GAME_IS_FULL= (502 : UInt);
      
      static inline final LERP_RATE:Float = 0.04;
      
      static inline final MINIMUM_LOADING_SECONDS:Float = 3;
      
      static inline final LOADING_SCREEN_PATH= "Resources/Art2D/UI/db_UI_loading_screen.swf";
      
      public static inline final ERROR_NONE_PARSABLE_MESSAGE= (101 : UInt);
      
      var mMinimumLoadingSeconds:Float = 3;
      
      var mFinishLoadingCallback:ASFunction;
      
      var mHasCalledFinishLoadingCallback:Bool = false;
      
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
      
      public function new(param1:DBFacade, param2:ASFunction = null)
      {
         super("LoadingScreenState",param2);
         mDBFacade = param1;
         mWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mScreenLoaded = false;
         mHeroOwnerReady = false;
         mFriendOnly = false;
      }
      
      public function heroOwnerReady(param1:Event) 
      {
         mDBFacade.metrics.log("DungeonLoadHeroReady",{});
         mHeroOwnerReady = true;
         checkIfReadyToMoveOn();
      }
      
      function floorInterestClosureEventCallback(param1:Event) 
      {
         AssetLoader.stopTrackingLoads();
      }
      
      function ponderPlayMovie() : Bool
      {
         var _loc2_:GMMapNode = null;
         var _loc1_= mDBFacade.getSplitTestNumber("SkipVideo",0);
         if(mMapNodeID != 0 && _loc1_ != 1)
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(mMapNodeID), gameMasterDictionary.GMMapNode);
            if(_loc2_ != null && ASCompat.stringAsBool(_loc2_.StorySwfPath))
            {
               mVideoPlayer = new VideoPlayer(mDBFacade,mSceneGraphComponent,enterLoadingState);
               mVideoPlayer.process(_loc2_.StorySwfPath);
               return false;
            }
         }
         enterLoadingState();
         return true;
      }
      
      override public function enterState() 
      {
         mDBFacade.metrics.log("DungeonLoadingScreen",{});
         super.enterState();
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING LOADING SCREEN STATE");
         ponderPlayMovie();
      }
      
      function enterLoadingState() 
      {
         MemoryTracker.nextGeneration();
         mLoadingStartTime = (mDBFacade.gameClock.realTime : UInt);
         mHeroOwnerReady = false;
         mEventComponent.addListener("FLOOR_INTEREST_CLOSURE",floorInterestClosureEventCallback);
         mEventComponent.addListener(HeroGameObjectOwner.HERO_OWNER_READY,heroOwnerReady);
         mEventComponent.addListener("REQUEST_ENTRY_FAILED",failedRequestEntry);
         mEventComponent.addListener("CLIENT_EXIT_COMPLETE",GraceFullClientExited);
         mEventComponent.addListener("Busterncpccahche_event",TickleCacheWithEvent);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"),setUpLoadingScreen);
         AssetLoader.startTrackingLoads(finishedLoading);
         var _loc1_= (0 : UInt);
         if(mFriendOnly)
         {
            _loc1_ = (1 : UInt);
         }
         var _loc2_= mDBFacade.dbConfigManager.getConfigString("MatchMakerGroup","");
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestEntry(mapNodeID,friendID,mapID,_loc1_,_loc2_);
         mTask = mWorkComponent.doEveryFrame(updateProgress);
         MemoryUtil.pauseForGCWithLogging("LoadingScreen: ");
      }
      
      function GraceFullClientExited(param1:ClientExitCompleteEvent) 
      {
         gracefullExit();
      }
      
      function failedRequestEntry(param1:RequestEntryFailedEvent) 
      {
         var _loc3_= param1.errorCode;
         var _loc2_= new DBUIOneButtonPopup(mDBFacade,Locale.getString("MATCHMAKER_REFUSES_TITLE"),Locale.getError((_loc3_ : Int)),Locale.getString("OK"),failedRequestEntryDialogClose,true,failedRequestEntryDialogClose);
         MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in LoadingScreenState.failedRequestEntry()");
         var _loc4_= (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
         mDBFacade.metrics.log("DungeonLoadFailed",{
            "errorCode":_loc3_,
            "timeSpentSeconds":_loc4_
         });
      }
      
      function failedRequestEntryDialogClose() 
      {
         mDBFacade.mainStateMachine.enterReloadTownState(true);
      }
      
      function gracefullExit() 
      {
         mDBFacade.mainStateMachine.enterReloadTownState();
      }
      
      function goBackToTown() 
      {
         mDBFacade.mainStateMachine.enterTownState(mJumpToMapState);
         mJumpToMapState = false;
      }
      
      function setUpLoadingScreen(param1:SwfAsset) 
      {
         var _loc2_:Dynamic = null;
         var _loc3_:String = null;
         if(nodeType == "DUNGEON" || nodeType == "")
         {
            _loc2_ = param1.getClass("loading_gate_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
         }
         else if(nodeType == "INFINITE")
         {
            _loc2_ = param1.getClass("loading_gate_ultimate_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
         }
         else
         {
            _loc2_ = param1.getClass("loading_gateboss_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_CHALLENGE_LABEL");
         }
         mLoadingScreenRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
         mLoadingScreenLabel = ASCompat.dynamicAs((mLoadingScreenRoot : ASAny).loading_gate_text_hint.label, flash.text.TextField);
         mLoadingScreenLabel.text = _loc3_;
         mLoadingBarClip = ASCompat.dynamicAs((mLoadingScreenRoot : ASAny).loading_gate_text_hint.UI_loadingBar, flash.display.MovieClip);
         mLoadingBarClip.visible = true;
         mLoadingBarClip.scaleX = mLoadingBarClip.scaleY = 1.8;
         mLoadingBarClip.x = 548.7;
         mLoadingBarClip.y = 1000;
         mHint = new UIHints(mDBFacade,ASCompat.dynamicAs((mLoadingScreenRoot : ASAny).loading_gate_text_hint.hint, flash.display.MovieClip));
         mLoadingBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mLoadingBarClip : ASAny).loadingBar, flash.display.MovieClip));
         mProgressTarget = 0;
         mLoadingBar.value = 0;
         mScreenLoaded = true;
         mDBFacade.stageRef.addEventListener("keyDown",keyCall);
         mDBFacade.stageRef.addEventListener("mouseDown",handleMouseDown);
         mMinimumLoadingSeconds = 3;
         if(mScreenLoaded && mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState")
         {
            mSceneGraphComponent.addChild(mLoadingScreenRoot,(100 : UInt));
            mSceneGraphComponent.addChild(mLoadingBarClip,(100 : UInt));
         }
      }
      
      function updateProgress(param1:GameClock) 
      {
         var _loc2_= Math.NaN;
         if(!mScreenLoaded)
         {
            return;
         }
         AssetLoader.updateTrackedLoads();
         if(mLoadingBar != null && AssetLoader.pendingBytesTotal > 0)
         {
            _loc2_ = AssetLoader.pendingBytesLoaded / AssetLoader.pendingBytesTotal;
            mProgressTarget = Math.max(mLoadingBar.value,_loc2_);
            mLoadingBar.value += (mProgressTarget - mLoadingBar.value) * 0.04;
         }
      }
      
      function TickleCacheWithEvent(param1:CacheLoadRequestNpcEvent) 
      {
         var _loc2_= 0;
         mDBFacade.metrics.log("DungeonLoadCacheStarted",{});
         _loc2_ = 0;
         while(_loc2_ < param1.tilelibraryname.length)
         {
            TrickleCacheLoader.tilelibrary(param1.tilelibraryname[_loc2_],mDBFacade);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_axes.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_hammers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_throwingweapons.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Charge/db_icons_charge.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/projectiles/db_projectiles_library.swf"),mDBFacade);
         TrickleCacheLoader.loadHero(mDBFacade,mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         TrickleCacheLoader.npcVector(param1.cacheNpc,mDBFacade);
         TrickleCacheLoader.swfVector(param1.cacheSwf,mDBFacade);
         AssetLoader.stopTrackingLoads();
      }
      
      function checkIfReadyToMoveOn() 
      {
         var _loc1_= Math.NaN;
         if(mTask == null && mHeroOwnerReady)
         {
            _loc1_ = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
            mDBFacade.metrics.log("DungeonLoaded",{"timeSpentSeconds":_loc1_});
            mFinishedCallback();
         }
      }
      
      function finishedLoading() 
      {
         var timeTakenToLoadSoFar:Float;
         var timeLeftToLoad:Float;
         mDBFacade.metrics.log("DungeonLoadCacheFinished",{});
         timeTakenToLoadSoFar = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
         timeLeftToLoad = Math.max(0, mMinimumLoadingSeconds - timeTakenToLoadSoFar);
         mHasCalledFinishLoadingCallback = false;
         mFinishLoadingCallback = function()
         {
            if(mHasCalledFinishLoadingCallback)
            {
               return;
            }
            mHasCalledFinishLoadingCallback = true;
            mFinishLoadingCallback = null;
            mDBFacade.createHUD();
            mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_FLOOR"));
            mTask.destroy();
            mTask = null;
            checkIfReadyToMoveOn();
         };
         TweenMax.delayedCall(timeLeftToLoad,mFinishLoadingCallback);
      }
      
      function forceFinishLoading() 
      {
         mMinimumLoadingSeconds = 0;
         if(ASCompat.toBool(mFinishLoadingCallback))
         {
            TweenMax.killDelayedCallsTo(mFinishLoadingCallback);
            mFinishLoadingCallback();
         }
      }
      
      function keyCall(param1:KeyboardEvent) 
      {
         switch(param1.keyCode - 27)
         {
            case 0:
               forceFinishLoading();
         }
      }
      
      function handleMouseDown(param1:MouseEvent) 
      {
         forceFinishLoading();
      }
      
      override public function exitState() 
      {
         if(mHint != null)
         {
            mHint.destroy();
         }
         mHint = null;
         AssetLoader.abortTrackingLoads();
         mSceneGraphComponent.removeChild(mLoadingScreenRoot);
         mSceneGraphComponent.removeChild(mLoadingBarClip);
         mEventComponent.removeAllListeners();
         mDBFacade.stageRef.removeEventListener("keyDown",keyCall);
         mDBFacade.stageRef.removeEventListener("mouseDown",handleMouseDown);
         if(mTask != null)
         {
            mTask.destroy();
         }
         super.exitState();
      }
      
            
      @:isVar public var mapNodeID(get,set):UInt;
public function  get_mapNodeID() : UInt
      {
         return mMapNodeID;
      }
function  set_mapNodeID(param1:UInt) :UInt      {
         mMapNodeID = param1;
         mFriendID = (0 : UInt);
         mMapID = (0 : UInt);
return param1;
      }
      
            
      @:isVar public var mapID(get,set):UInt;
public function  get_mapID() : UInt
      {
         return mMapID;
      }
function  set_mapID(param1:UInt) :UInt      {
         mMapNodeID = (0 : UInt);
         mFriendID = (0 : UInt);
         return mMapID = param1;
      }
      
            
      @:isVar public var friendID(get,set):UInt;
public function  get_friendID() : UInt
      {
         return mFriendID;
      }
function  set_friendID(param1:UInt) :UInt      {
         mMapNodeID = (0 : UInt);
         mFriendID = param1;
         mMapID = (0 : UInt);
return param1;
      }
      
            
      @:isVar public var friendsOnly(get,set):Bool;
public function  get_friendsOnly() : Bool
      {
         return mFriendOnly;
      }
function  set_friendsOnly(param1:Bool) :Bool      {
         return mFriendOnly = param1;
      }
      
      @:isVar public var jumpToMapState(never,set):Bool;
public function  set_jumpToMapState(param1:Bool) :Bool      {
         return mJumpToMapState = param1;
      }
      
            
      @:isVar public var nodeType(get,set):String;
public function  get_nodeType() : String
      {
         return mNodeType;
      }
function  set_nodeType(param1:String) :String      {
         return mNodeType = param1;
      }
   }


private class VideoPlayer
{
   
   var mCutVideo:Video;
   
   var mCutVideoBackGround:Shape;
   
   var mUIButton:UIButton;
   
   var mSceneGraphComponent:SceneGraphComponent;
   
   var mDBFacade:DBFacade;
   
   var mcallback:ASFunction;
   
   var mNetConnection:NetConnection;
   
   var mNetStream:NetStream;
   
   var skipButton:Dynamic = Db_UI_skip_button_swf;
   
   public function new(param1:DBFacade, param2:SceneGraphComponent, param3:ASFunction)
   {
      
      mcallback = param3;
      mSceneGraphComponent = param2;
      mDBFacade = param1;
   }
   
   public function destroy() 
   {
      cleanup();
   }
   
   function cleanupAndTransition() 
   {
      cleanup();
      mcallback();
   }
   
   public function cleanup() 
   {
      mDBFacade.metrics.log("IntroVideoCleanup",{});
      mNetStream.removeEventListener("netStatus",detectEnd);
      mDBFacade.stageRef.removeEventListener("keyDown",KeyCall);
      mSceneGraphComponent.removeChild(mCutVideoBackGround);
      mSceneGraphComponent.removeChild(mCutVideo);
      mSceneGraphComponent.removeChild(mUIButton.root);
      mUIButton.destroy();
      mNetStream.close();
      mNetStream = null;
      mCutVideo = null;
      mCutVideoBackGround = null;
      mUIButton = null;
   }
   
   public function KeyCall(param1:KeyboardEvent) 
   {
      switch(param1.keyCode - 27)
      {
         case 0:
            mDBFacade.metrics.log("IntroVideoSkip",{});
            cleanupAndTransition();
      }
   }
   
   public function detectEnd(param1:NetStatusEvent) 
   {
      switch(param1.info.code)
      {
         case "NetStream.Play.Start":
            mDBFacade.metrics.log("IntroVideoStart",{});
            
         case "NetStream.Play.Stop":
            cleanupAndTransition();
            
         case "NetStream.Play.StreamNotFound":
            cleanupAndTransition();
      }
   }
   
   public function process(param1:String) 
   {
      var customClient:ASObject;
      var tempmovie:MovieClip;
      var clname= param1;
      var cuePointHandler= function(param1:ASObject)
      {
      };
      var metaDataHandler= function(param1:ASObject)
      {
         mCutVideo.y = ASCompat.toNumber(600 - ASCompat.toNumberField(param1, "height")) / 2;
         mCutVideo.x = 0;
         mCutVideo.width = 1920;
         mCutVideo.height = 1080;
         mSceneGraphComponent.addChild(mCutVideo,(50 : UInt));
         SceneGraphComponent.bringToFront(mUIButton.root);
      };
      mDBFacade.metrics.log("IntroVideoCreated",{});
      mCutVideo = new Video(1,1);
      mNetConnection = new NetConnection();
      mNetConnection.connect(null);
      mNetStream = new NetStream(mNetConnection);
      customClient = {};
      ASCompat.setProperty(customClient, "onCuePoint", cuePointHandler);
      ASCompat.setProperty(customClient, "onMetaData", metaDataHandler);
      mNetStream.client = customClient;
      mNetStream.addEventListener("netStatus",detectEnd);
      mCutVideoBackGround = new Shape();
      mCutVideoBackGround.graphics.beginFill((0 : UInt));
      mCutVideoBackGround.graphics.drawRect(0,0,mDBFacade.viewWidth,mDBFacade.viewHeight);
      mCutVideoBackGround.graphics.endFill();
      mSceneGraphComponent.addChildAt(mCutVideoBackGround,(50 : UInt),(0 : UInt));
      tempmovie = ASCompat.dynamicAs(ASCompat.createInstance(skipButton, []) , MovieClip);
      mUIButton = new UIButton(this.mDBFacade,tempmovie);
      tempmovie = null;
      mUIButton.root.x = 1850;
      mUIButton.root.y = 20;
      mUIButton.releaseCallback = cleanupAndTransition;
      mSceneGraphComponent.addChild(mUIButton.root,(50 : UInt));
      mDBFacade.stageRef.addEventListener("keyDown",KeyCall);
      mCutVideo.attachNetStream(mNetStream);
      mNetStream.play(DBFacade.buildFullDownloadPath(clname));
      mNetStream.soundTransform = new SoundTransform(mDBFacade.soundManager.getDampenedVolumeScaleForCategory("sfx"));
   }
}
