package facebookAPI
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.sceneGraph.SceneGraphComponent;
   import events.FacebookLevelUpPostEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMFeedPosts;
   import uI.popup.UIDungeonSummaryLevelUpPopup;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   
    class DBFacebookLevelUpPostController
   {
      
      public static inline final LEVEL_UP_BRAG= "LEVELUP";
      
      public static inline final TIME_TO_SHARE_LEVEL_UP_EVENT= "TIME_TO_SHARE_LEVEL_UP_EVENT";
      
      var mDBFacade:DBFacade;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mEventComponent:EventComponent;
      
      var mLevelUpFeedPostsMap:Map;
      
      var mCurtain:Sprite;
      
      var mSelectedLevelUpPost:GMFeedPosts;
      
      var mFeedPostCallbackFunction:ASFunction;
      
      public function new(param1:DBFacade, param2:ASFunction)
      {
         
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DBFacebookLevelUpPostController");
         mFeedPostCallbackFunction = param2;
         mLevelUpFeedPostsMap = new Map();
         mEventComponent.addListener("FacebookLevelUpPostEvent",setlevelUpPost);
         mEventComponent.addListener("TIME_TO_SHARE_LEVEL_UP_EVENT",checkToSharePopup);
      }
      
      public static function makeCurtain(param1:DBFacade, param2:SceneGraphComponent) : Sprite
      {
         if(param1 == null || param2 == null)
         {
            return null;
         }
         var _loc3_= new Sprite();
         _loc3_.alpha = 0.75;
         _loc3_.x = 0;
         _loc3_.y = 0;
         _loc3_.graphics.clear();
         _loc3_.graphics.beginFill((0 : UInt));
         _loc3_.graphics.drawRect(0,0,param1.viewWidth,param1.viewHeight);
         _loc3_.graphics.endFill();
         param2.addChild(_loc3_,(105 : UInt));
         return _loc3_;
      }
      
      public static function removeCurtain(param1:Sprite, param2:SceneGraphComponent) 
      {
         if(param1 == null || param2 == null)
         {
            return;
         }
         if(param2.contains(param1,(105 : UInt)))
         {
            param2.removeChild(param1);
         }
         param1 = null;
      }
      
      function loadMap() 
      {
         var _loc1_:GMFeedPosts;
         final __ax4_iter_193 = mDBFacade.gameMaster.FeedPosts;
         if (checkNullIteratee(__ax4_iter_193)) for (_tmp_ in __ax4_iter_193)
         {
            _loc1_ = _tmp_;
            if(_loc1_.Category == "LEVELUP")
            {
               if(!mLevelUpFeedPostsMap.hasKey(_loc1_.LevelTrigger))
               {
                  mLevelUpFeedPostsMap.add(_loc1_.LevelTrigger,_loc1_);
               }
            }
         }
      }
      
      function showPopup(param1:GMFeedPosts) 
      {
         var levelUpPost= param1;
         var gmSkin= mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(gmSkin.IconName);
            var _loc2_= new UIDungeonSummaryLevelUpPopup(mDBFacade,null,gmSkin,levelUpPost,_loc3_);
         });
      }
      
      function checkIfMapIsLoaded() 
      {
         if(mLevelUpFeedPostsMap.size > 0)
         {
            return;
         }
         loadMap();
      }
      
      function checkToSharePopup(param1:Event) 
      {
         checkIfMapIsLoaded();
         if(mSelectedLevelUpPost != null)
         {
            showPopup(mSelectedLevelUpPost);
            mSelectedLevelUpPost = null;
         }
      }
      
      function setlevelUpPost(param1:FacebookLevelUpPostEvent) 
      {
         checkIfMapIsLoaded();
         if(mLevelUpFeedPostsMap.hasKey(param1.level))
         {
            mSelectedLevelUpPost = ASCompat.dynamicAs(mLevelUpFeedPostsMap.itemFor(param1.level), gameMasterDictionary.GMFeedPosts);
         }
      }
      
      public function destroy() 
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
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         mDBFacade = null;
         mSelectedLevelUpPost = null;
         mLevelUpFeedPostsMap.clear();
         mFeedPostCallbackFunction = null;
      }
   }


