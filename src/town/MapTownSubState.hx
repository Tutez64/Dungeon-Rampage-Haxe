package town
;
   import account.FriendInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.render.MovieClipRenderController;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import facade.Locale;
   import uI.leaderboard.UILeaderboard;
   import uI.map.UIMapWorldMap;
   import flash.display.MovieClip;
   
    class MapTownSubState extends TownSubState
   {
      
      public static inline final SCREENS_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      public static inline final NAME= "MapTownSubState";
      
      var mScreensMovieClip:MovieClip;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mClipRenderController:MovieClipRenderController;
      
      var mWorldMap:UIMapWorldMap;
      
      var mUILeaderboard:UILeaderboard;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"MapTownSubState");
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
      }
      
      override function setupState() 
      {
         super.setupState();
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"MapTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
         mWorldMap = new UIMapWorldMap(mDBFacade,mRootMovieClip,mTownStateMachine.townSwf,mTownStateMachine);
         var _loc8_= mTownStateMachine.townSwf.getClass("cursor_pointer");
         var _loc6_= ASCompat.dynamicAs(ASCompat.createInstance(_loc8_, []) , MovieClip);
         mDBFacade.mouseCursorManager.registerMouseCursor(_loc6_,"auto",true);
         var _loc2_= mTownStateMachine.townSwf.getClass("cursor_open");
         var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mDBFacade.mouseCursorManager.registerMouseCursor(_loc3_,"HAND");
         var _loc1_= mTownStateMachine.townSwf.getClass("cursor_fist");
         var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc1_, []) , MovieClip);
         mDBFacade.mouseCursorManager.registerMouseCursor(_loc4_,"DRAG");
         var _loc5_= mTownStateMachine.townSwf.getClass("cursor_point");
         var _loc7_= ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []) , MovieClip);
         mDBFacade.mouseCursorManager.registerMouseCursor(_loc7_,"POINT");
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            if(mTownStateMachine.townHeader.rootMovieClip != null)
            {
               mTownStateMachine.townHeader.rootMovieClip.visible = false;
               mWorkComponent.doLater(0.20833333333333334,function(param1:brain.clock.GameClock)
               {
                  if(mTownStateMachine != null)
                  {
                     mTownStateMachine.townHeader.animateHeader();
                  }
               });
            }
         }
      }
      
      function initMap() 
      {
         var tavernCallback:ASFunction = function()
         {
            mTownStateMachine.enterTavernState(true);
         };
         var inventoryCallback:ASFunction = function()
         {
            mTownStateMachine.enterInventoryState(true,"POWERUP");
         };
         var shopCallback:ASFunction = function()
         {
            mTownStateMachine.enterShopState(true,"STUFF");
         };
         mWorldMap.initialize(tavernCallback,inventoryCallback,shopCallback,mTownStateMachine.enterHomeState);
         mDBFacade.mouseCursorManager.pushMouseCursor("HAND");
         mUILeaderboard = mDBFacade.mainStateMachine.leaderboard;
         mUILeaderboard.setRootMovieClip(mRootMovieClip);
         mUILeaderboard.currentStateName = "MapTownSubState";
         mUILeaderboard.hidePopup();
         animateEntry();
         mTownStateMachine.townHeader.showCloseButton(true);
         mTownStateMachine.townHeader.title = Locale.getString("WORLD_MAP_HEADER");
      }
      
      override public function enterState() 
      {
         super.enterState();
         mEventComponent.addListener(FriendInfo.FRIEND_SCORES_PARSED,function(param1:flash.events.Event)
         {
            mWorldMap.deinit();
            initMap();
         });
         if(mWorkComponent == null)
         {
            mWorkComponent = new LogicalWorkComponent(mDBFacade,"MapTownSubState");
         }
         initMap();
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("MAP_MENU",mTownStateMachine.townHeader.determineCallback,mWorldMap.getCurrentNodeButton(),mWorldMap.getCurrentNodeButton());
      }
      
      override public function exitState() 
      {
         super.exitState();
         mWorldMap.deinit();
         mDBFacade.menuNavigationController.popLayer("MAP_MENU");
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mClipRenderController != null)
         {
            mClipRenderController.destroy();
            mClipRenderController = null;
         }
         if(mEventComponent != null)
         {
            mEventComponent.removeAllListeners();
         }
      }
      
      override public function destroy() 
      {
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
   }


