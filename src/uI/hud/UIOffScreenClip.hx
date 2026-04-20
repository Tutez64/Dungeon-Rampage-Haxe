package uI.hud
;
   import actor.ActorGameObject;
   import actor.ChatBalloon;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.event.EventComponent;
   import brain.uI.UIProgressBar;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObject;
   import events.GameObjectEvent;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   
    class UIOffScreenClip
   {
      
      public static inline final HPBAR_OFFSET:Float = 25;
      
      public static inline final CHAT_DURATION:Float = 5;
      
      public static inline final CHAT_BALLOON_Y_OFFSET:Float = -40;
      
      public static inline final REVIVE_PIC_CHANGE_TYPE= "REVIVE";
      
      public static inline final REVIVE_PIC_TOGGLE_TIME:Float = 0.25;
      
      public static inline final MAX_FACEBOOK_PIC_SHOW_COUNT= (5 : UInt);
      
      var mOffScreenPlayerClip:MovieClip;
      
      var mAvatarPic:MovieClip;
      
      var mDeathPic:MovieClip;
      
      var mPlayerIsTypingNotification:MovieClip;
      
      var mHpBar:UIProgressBar;
      
      var mChatBalloon:ChatBalloon;
      
      var mPlayer:ActorGameObject;
      
      var mNametagSwfAsset:SwfAsset;
      
      var mAvatarSwfAsset:SwfAsset;
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mChatBalloonVanishTask:Task;
      
      var mFlashTask:Task;
      
      var mFacebookPicShowCount:UInt = (0 : UInt);
      
      var mIsAHero:Bool = false;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ActorGameObject, param4:SwfAsset)
      {
         var _loc6_:String = null;
         var _loc5_:HeroGameObject = null;
         
         mDBFacade = param1;
         mOffScreenPlayerClip = param2;
         mPlayer = param3;
         if(Std.isOfType(mPlayer , HeroGameObject))
         {
            mIsAHero = true;
            _loc5_ = ASCompat.reinterpretAs(mPlayer , HeroGameObject);
            _loc6_ = _loc5_.gmSkin.IconSwfFilepath;
         }
         else
         {
            _loc6_ = mPlayer.actorData.gMActor.IconSwfFilepath;
         }
         mNametagSwfAsset = param4;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIOffScreenClip");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc6_),setupAvatarPic);
         setupUI();
      }
      
      function setupUI() 
      {
         var balloonClass:Dynamic;
         var balloon:MovieClip;
         var hero:HeroGameObject;
         var chatIsTypingClass:Dynamic;
         var nametagClass= mNametagSwfAsset.getClass("UI_nametag");
         var nametag= ASCompat.dynamicAs(ASCompat.createInstance(nametagClass, []), flash.display.MovieClip);
         mHpBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((nametag : ASAny).hp.hpBar, flash.display.MovieClip));
         mHpBar.value = 100;
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPlayer.id),function(param1:events.HpEvent)
         {
            if(!mPlayer.isDestroyed)
            {
               setHp(param1.hp,param1.maxHp);
            }
         });
         mOffScreenPlayerClip.addChild(mHpBar.root);
         mHpBar.root.y = 25;
         balloonClass = mNametagSwfAsset.getClass("UI_speechbubble");
         mChatBalloon = new ChatBalloon();
         mChatBalloon.visible = false;
         balloon = ASCompat.dynamicAs(ASCompat.createInstance(balloonClass, []), flash.display.MovieClip);
         mChatBalloon.initializeChatBalloon(mNametagSwfAsset);
         mChatBalloon.y = -40;
         mOffScreenPlayerClip.addChild(mChatBalloon);
         if(mIsAHero)
         {
            hero = ASCompat.reinterpretAs(mPlayer , HeroGameObject);
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",hero.playerID),function(param1:events.ChatEvent)
            {
               if(hero != null && !hero.isDestroyed)
               {
                  setChat(param1.message);
               }
            });
            chatIsTypingClass = mNametagSwfAsset.getClass("UI_speechbubble_typing");
            mPlayerIsTypingNotification = ASCompat.dynamicAs(ASCompat.createInstance(chatIsTypingClass, []), flash.display.MovieClip);
            mPlayerIsTypingNotification.y = -40;
            mOffScreenPlayerClip.addChild(mPlayerIsTypingNotification);
            showPlayerIsTypingNotification(false);
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",hero.playerID),function(param1:events.PlayerIsTypingEvent)
            {
               if(param1.subtype == "CHAT_BOX_FOCUS_IN")
               {
                  showPlayerIsTypingNotification(true);
               }
               else
               {
                  showPlayerIsTypingNotification(false);
               }
            });
            showFacebookPicture();
         }
      }
      
      function setupAvatarPic(param1:SwfAsset) 
      {
         var _loc2_:String = null;
         var _loc4_:HeroGameObject = null;
         if(Std.isOfType(mPlayer , HeroGameObject))
         {
            _loc4_ = ASCompat.reinterpretAs(mPlayer , HeroGameObject);
            _loc2_ = _loc4_.gmSkin.IconName;
         }
         else
         {
            _loc2_ = mPlayer.actorData.gMActor.IconName;
         }
         mAvatarSwfAsset = param1;
         var _loc3_= _loc2_;
         if(!ASCompat.stringAsBool(_loc3_) || _loc3_ == "")
         {
            return;
         }
         var _loc5_= mAvatarSwfAsset.getClass(_loc3_);
         var _loc6_= mAvatarSwfAsset.getClass("death_icon");
         mAvatarPic = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
         (mOffScreenPlayerClip : ASAny).UI_avatar.addChild(mAvatarPic);
         if(_loc6_ != null)
         {
            mDeathPic = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip);
         }
      }
      
      public function showFacebookPicture() 
      {
         var _loc1_:HeroGameObject = null;
         if(mIsAHero)
         {
            _loc1_ = ASCompat.reinterpretAs(mPlayer , HeroGameObject);
            if(mFacebookPicShowCount >= 5 || _loc1_ == null || _loc1_.isDestroyed)
            {
               return;
            }
            mFacebookPicShowCount = mFacebookPicShowCount + 1;
            _loc1_.heroView.nametag.showFacebookPicture(_loc1_.playerID);
         }
      }
      
      @:isVar public var clip(get,never):MovieClip;
public function  get_clip() : MovieClip
      {
         return mOffScreenPlayerClip;
      }
      
      public function showPlayerIsTypingNotification(param1:Bool) 
      {
         if(mPlayerIsTypingNotification != null && !mChatBalloon.visible)
         {
            mPlayerIsTypingNotification.visible = param1;
         }
      }
      
      public function setHp(param1:UInt, param2:UInt) 
      {
         if(mHpBar != null)
         {
            mHpBar.value = param1 / param2;
         }
      }
      
      public function setChat(param1:String) 
      {
         var message= param1;
         if(mChatBalloon == null)
         {
            return;
         }
         mChatBalloon.text = message;
         mChatBalloon.visible = true;
         if(mChatBalloonVanishTask != null)
         {
            mChatBalloonVanishTask.destroy();
         }
         mChatBalloonVanishTask = mLogicalWorkComponent.doLater(5,function()
         {
            mChatBalloon.visible = false;
         });
      }
      
      public function handlePicChange(param1:String) 
      {
         var cmf:ColorMatrixFilter;
         var picType= param1;
         if(picType == "REVIVE")
         {
            ASCompat.setProperty((mOffScreenPlayerClip : ASAny).AlertText, "text", "Rescue!");
            if(mDeathPic != null)
            {
               (mOffScreenPlayerClip : ASAny).UI_avatar.addChild(mDeathPic);
               cmf = new ColorMatrixFilter(cast([2.5,0,0,0,0,0,0.25,0,0,0,0,0,0.25,0,0,0,0,0,1,0]));
               mAvatarPic.filters = cast([cmf]);
               mFlashTask = mLogicalWorkComponent.doEverySeconds(0.25,function(param1:brain.clock.GameClock)
               {
                  (mOffScreenPlayerClip : ASAny).UI_avatar.swapChildren(mAvatarPic,mDeathPic);
               });
            }
         }
         else
         {
            ASCompat.setProperty((mOffScreenPlayerClip : ASAny).AlertText, "text", "");
            if(mFlashTask != null)
            {
               mFlashTask.destroy();
            }
            mFlashTask = null;
            mAvatarPic.filters = cast([]);
            if(mDeathPic != null && ASCompat.toBool((mOffScreenPlayerClip : ASAny).UI_avatar.contains(mDeathPic)))
            {
               (mOffScreenPlayerClip : ASAny).UI_avatar.removeChild(mDeathPic);
            }
         }
      }
      
      public function destroy() 
      {
         if(mChatBalloonVanishTask != null)
         {
            mChatBalloonVanishTask.destroy();
         }
         mChatBalloonVanishTask = null;
         if(mFlashTask != null)
         {
            mFlashTask.destroy();
         }
         mFlashTask = null;
         mChatBalloon = null;
         if(mHpBar != null)
         {
            mHpBar.destroy();
         }
         mHpBar = null;
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
         mEventComponent.removeAllListeners();
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mPlayerIsTypingNotification = null;
         mAvatarPic = null;
         mDeathPic = null;
         mPlayer = null;
         mAvatarSwfAsset = null;
         mNametagSwfAsset = null;
         mOffScreenPlayerClip = null;
         mDBFacade = null;
      }
   }


