package uI.uINewsFeed
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObject;
   import distributedObjects.PlayerGameObject;
   import events.FriendStatusEvent;
   import events.FriendSummaryNewsFeedEvent;
   import events.GenericNewsFeedEvent;
   import facade.DBFacade;
   import com.greensock.TweenMax;
   
    class UINewsFeedController
   {
      
      public static inline final MAX_VISIBLE_FEEDS= (1 : UInt);
      
      public static inline final QUEDED_FEEDS_CHECK_INTERVAL:Float = 0.5;
      
      public static inline final FEED_HEIGHT_OFFSET:Float = 75;
      
      public static inline final FEED_LERP_UP_DURATION:Float = 0.16666666666666666;
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mEventComponent:EventComponent;
      
      var mNewsFeedClass:Dynamic;
      
      var mVisibleFeeds:Vector<UINewsFeed>;
      
      var mQueuedFeeds:Vector<UINewsFeed>;
      
      var mNewsFeedTask:Task;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mVisibleFeeds = new Vector<UINewsFeed>();
         mQueuedFeeds = new Vector<UINewsFeed>();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),assetLoaded);
         mEventComponent.addListener("GENERIC_NEWS_FEED_MESSAGE_EVENT",genericNewsFeedMessage);
         mEventComponent.addListener("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",friendSummaryStatusUpdate);
      }
      
      public function startFeedTask() 
      {
         if(mNewsFeedTask != null)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = mLogicalWorkComponent.doEverySeconds(0.5,checkNewsFeedQueue);
         mEventComponent.addListener("FRIEND_STATUS_EVENT",friendOnlineStatusUpdate);
         mEventComponent.addListener("FRIEND_DUNGEON_STATUS_EVENT",friendDungeonStatusUpdate);
      }
      
      public function stopFeedTask() 
      {
         if(mNewsFeedTask != null)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = null;
         flushFeeds();
         mEventComponent.removeListener("FRIEND_STATUS_EVENT");
         mEventComponent.removeListener("FRIEND_DUNGEON_STATUS_EVENT");
      }
      
      function assetLoaded(param1:SwfAsset) 
      {
         mNewsFeedClass = param1.getClass("UI_alertPrompt");
      }
      
      function friendOnlineStatusUpdate(param1:FriendStatusEvent) 
      {
         var _loc3_= mDBFacade.gameObjectManager.getReferenceFromId(param1.friendId);
         var _loc4_= ASCompat.reinterpretAs(_loc3_ , PlayerGameObject);
         if(_loc4_ != null)
         {
            return;
         }
         var _loc2_= new UINewsFeed(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(mNewsFeedClass, []), flash.display.MovieClip),removeNewsFeed,(0 : UInt),param1);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      function friendSummaryStatusUpdate(param1:FriendSummaryNewsFeedEvent) 
      {
         var _loc2_= new UINewsFeed(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(mNewsFeedClass, []), flash.display.MovieClip),removeNewsFeed,(3 : UInt),param1);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      function friendDungeonStatusUpdate(param1:FriendStatusEvent) 
      {
         var _loc3_= mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id);
         var _loc4_= ASCompat.reinterpretAs(_loc3_ , HeroGameObject);
         if(_loc4_ == null || _loc4_.distributedDungeonFloor == null)
         {
            return;
         }
         if(!ASCompat.toBool(mDBFacade.dbAccountInfo.friendInfos.itemFor(param1.friendId)))
         {
            return;
         }
         var _loc2_= new UINewsFeed(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(mNewsFeedClass, []), flash.display.MovieClip),removeNewsFeed,(1 : UInt),param1);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      function genericNewsFeedMessage(param1:GenericNewsFeedEvent) 
      {
         var _loc2_= new UINewsFeed(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(mNewsFeedClass, []), flash.display.MovieClip),removeNewsFeed,(2 : UInt),param1);
         if(_loc2_.isValid)
         {
            mQueuedFeeds.push(_loc2_);
         }
      }
      
      function checkNewsFeedQueue(param1:GameClock) 
      {
         if(mQueuedFeeds.length == 0 || mVisibleFeeds.length >= 1)
         {
            return;
         }
         var _loc2_= mQueuedFeeds.shift();
         mVisibleFeeds.push(_loc2_);
         _loc2_.root.x = mDBFacade.viewWidth;
         _loc2_.root.y = (mVisibleFeeds.length + 1) * 75;
         _loc2_.lerpIntoScreen();
      }
      
      function removeNewsFeed(param1:GameClock) 
      {
         var _loc2_= mVisibleFeeds.shift();
         _loc2_.destroy();
         lerpAllfeedsUp();
      }
      
      function lerpAllfeedsUp() 
      {
         var _loc1_:UINewsFeed;
         final __ax4_iter_64 = mVisibleFeeds;
         if (checkNullIteratee(__ax4_iter_64)) for (_tmp_ in __ax4_iter_64)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               TweenMax.to(_loc1_.root,0.16666666666666666,{"y":ASCompat.toNumberField(_loc1_.root, "y") - 75});
            }
         }
      }
      
      function flushFeeds() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_65 = mQueuedFeeds;
         if (checkNullIteratee(__ax4_iter_65)) for (_tmp_ in __ax4_iter_65)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         mQueuedFeeds.splice(0,(mQueuedFeeds.length : UInt));
         final __ax4_iter_66 = mVisibleFeeds;
         if (checkNullIteratee(__ax4_iter_66)) for (_tmp_ in __ax4_iter_66)
         {
            _loc1_  = _tmp_;
            if(ASCompat.toBool(_loc1_))
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         mVisibleFeeds.splice(0,(mVisibleFeeds.length : UInt));
      }
      
      public function destroy() 
      {
         flushFeeds();
         mDBFacade = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mNewsFeedTask != null)
         {
            mNewsFeedTask.destroy();
         }
         mNewsFeedTask = null;
      }
   }


