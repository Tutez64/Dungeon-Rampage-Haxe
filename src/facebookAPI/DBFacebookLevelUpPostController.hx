package facebookAPI
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import events.FacebookLevelUpPostEvent;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMFeedPosts;
   import flash.display.MovieClip;
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
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
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
         final __ax4_iter_177 = mDBFacade.gameMaster.FeedPosts;
         if (checkNullIteratee(__ax4_iter_177)) for (_tmp_ in __ax4_iter_177)
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
         var avatarPicScale:Float = 0.45;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var outerSwfAsset= param1;
            var levelupPopupClass= outerSwfAsset.getClass("UI_prompt_levelup");
            var levelupPopup= ASCompat.dynamicAs(ASCompat.createInstance(levelupPopupClass, []), flash.display.MovieClip);
            levelupPopup.x += 40;
            levelupPopup.scaleX = levelupPopup.scaleY = 1.8;
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:brain.assetRepository.SwfAsset)
            {
               var child:Int;
               var levelUpButton:UIButton;
               var closeButton:UIButton;
               var swfAsset= param1;
               var picClass= swfAsset.getClass(gmSkin.IconName);
               var avatarPic= ASCompat.dynamicAs(ASCompat.createInstance(picClass, []), flash.display.MovieClip);
               var movieClipRenderer= new MovieClipRenderController(mDBFacade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               if(ASCompat.toNumberField((levelupPopup : ASAny).avatar, "numChildren") > 0)
               {
                  child = ASCompat.toInt(ASCompat.toNumberField((levelupPopup : ASAny).avatar, "numChildren") - 1);
                  while(child >= 0)
                  {
                     (levelupPopup : ASAny).avatar.removeChildAt(child);
                     child = child - 1;
                  }
               }
               (levelupPopup : ASAny).avatar.addChildAt(avatarPic,0);
               ASCompat.setProperty((levelupPopup : ASAny).level_text, "text", levelUpPost.LevelTrigger);
               ASCompat.setProperty((levelupPopup : ASAny).congrats_label, "text", Locale.getString("LEVEL_UP_SHARE_TITLE"));
               ASCompat.setProperty((levelupPopup : ASAny).label, "text", Locale.getString("LEVEL_UP_SHARE_TEXT") + levelUpPost.LevelTrigger);
               levelUpButton = new UIButton(mDBFacade,ASCompat.dynamicAs((levelupPopup : ASAny).share, flash.display.MovieClip));
               if(mDBFacade.isDRPlayer)
               {
                  levelUpButton.label.text = Locale.getString("SWEET");
               }
               else
               {
                  levelUpButton.label.text = Locale.getString("LEVEL_UP_SHARE_BUTTON_TEXT");
               }
               closeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((levelupPopup : ASAny).close, flash.display.MovieClip));
               levelUpButton.releaseCallback = function()
               {
                  closePopup(levelupPopup);
                  if(mDBFacade.isFacebookPlayer)
                  {
                     mFeedPostCallbackFunction(levelUpPost,"",gmSkin.FeedPostPicture);
                  }
               };
               closeButton.releaseCallback = function()
               {
                  closePopup(levelupPopup);
               };
               mCurtain = makeCurtain(mDBFacade,mSceneGraphComponent);
               mSceneGraphComponent.addChild(levelupPopup,(105 : UInt));
               levelupPopup.x = mDBFacade.viewWidth / 2;
               levelupPopup.y = mDBFacade.viewHeight / 2;
            });
         });
      }
      
      function closePopup(param1:MovieClip) 
      {
         removeCurtain(mCurtain,mSceneGraphComponent);
         mSceneGraphComponent.removeChild(param1);
         param1 = null;
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
         mDBFacade = null;
         mAssetLoadingComponent = null;
         mEventComponent = null;
         mSelectedLevelUpPost = null;
         mLevelUpFeedPostsMap.clear();
         mFeedPostCallbackFunction = null;
      }
   }


