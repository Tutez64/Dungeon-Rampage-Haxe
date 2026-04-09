package actor
;
   import account.PlayerSpecialStatus;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.facade.Facade;
   import brain.gameObject.GameObject;
   import brain.uI.UIProgressBar;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.PlayerGameObject;
   import events.GameObjectEvent;
   import facade.DBFacade;
   import facade.Locale;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
    class ActorNametag extends Sprite
   {
      
      public static inline final NAMETAG_SWF_ROOT= "Resources/Art2D/UI/db_UI_nametag.swf";
      
      static inline final FACEBOOK_PIC_VISIBLE_TIME:Float = 5;
      
      static inline final FACEBOOK_PIC_ANIMATE_UP_FRAMES:Float = 0.25;
      
      static inline final FACEBOOK_PIC_ANIMATE_DOWN_FRAMES:Float = 0.25;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mShowNametagTask:Task;
      
      var mHpProgressBar:UIProgressBar;
      
      var mHpBarBg:Sprite;
      
      var mHpProgressBarVisible:Bool = true;
      
      var mTextField:TextField;
      
      var mAFKText:TextField;
      
      var mScreenName:String = Locale.getString("DEFAULT_NAMETAG");
      
      var mHealth:Float = 1;
      
      var mFacade:Facade;
      
      var mNametagTop:Sprite;
      
      var mNametagTopStartingYPosition:Float = Math.NaN;
      
      var mChatBalloon:ChatBalloon;
      
      var mPlayerIsTypingNotification:MovieClip;
      
      var mChatDuration:Float = 5;
      
      var mAFK:Bool = false;
      
      var mNametagFBPicSlot:MovieClip;
      
      var mFacebokPic:DisplayObject;
      
      var mHpBarHolder:MovieClip;
      
      public function new(param1:Facade, param2:AssetLoadingComponent, param3:LogicalWorkComponent, param4:Float)
      {
         super();
         mFacade = param1;
         mLogicalWorkComponent = param3;
         mEventComponent = new EventComponent(mFacade);
         this.name = "ActorNametag";
         this.mouseChildren = false;
         this.mouseEnabled = false;
         mNametagTop = new Sprite();
         mNametagTop.name = "ActorNametag.mNametagTop";
         this.addChild(mNametagTop);
         this.y = -param4;
         this.x = 0;
         showNametag();
         mChatBalloon = new ChatBalloon();
         mChatBalloon.visible = false;
         this.addChild(mChatBalloon);
         param2.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),setupNametagFromSwf);
      }
      
      function setupNametagFromSwf(param1:SwfAsset) 
      {
         var _loc3_= param1.getClass("UI_nametag");
         var _loc5_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
         mNametagFBPicSlot = ASCompat.dynamicAs((_loc5_ : ASAny).avatar, flash.display.MovieClip);
         mNametagFBPicSlot.visible = false;
         mHpBarHolder = ASCompat.dynamicAs((_loc5_ : ASAny).hp, flash.display.MovieClip);
         mHpProgressBar = new UIProgressBar(mFacade,ASCompat.dynamicAs((_loc5_ : ASAny).hp.hpBar, flash.display.MovieClip));
         mHpProgressBar.value = mHealth;
         mHpProgressBar.visible = mHpProgressBarVisible;
         mTextField = ASCompat.dynamicAs((_loc5_ : ASAny).nameText, flash.text.TextField);
         updateNameTagText();
         mAFKText = ASCompat.dynamicAs((_loc5_ : ASAny).AFKText, flash.text.TextField);
         mAFKText.text = "";
         mHpBarBg = ASCompat.dynamicAs((_loc5_ : ASAny).hp.hpBarBg, flash.display.Sprite);
         mNametagTop.addChild(_loc5_);
         mNametagTopStartingYPosition = mNametagTop.y;
         var _loc4_= param1.getClass("UI_speechbubble");
         var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
         mChatBalloon.initializeChatBalloon(param1);
         var _loc6_= param1.getClass("UI_speechbubble_typing");
         mPlayerIsTypingNotification = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip);
         this.addChild(mPlayerIsTypingNotification);
         showPlayerIsTypingNotification(false);
      }
      
      public function setChat(param1:String) 
      {
         if(mChatBalloon != null)
         {
            mChatBalloon.text = param1;
         }
         showChat();
         if(mShowNametagTask != null)
         {
            mShowNametagTask.destroy();
         }
         mShowNametagTask = mLogicalWorkComponent.doLater(mChatDuration,showNametag);
      }
      
      @:isVar public var chatBalloon(get,never):ChatBalloon;
public function  get_chatBalloon() : ChatBalloon
      {
         return mChatBalloon;
      }
      
      public function setHp(param1:UInt, param2:UInt) 
      {
         mHealth = param1 / param2;
         if(mHpProgressBar != null)
         {
            mHpProgressBar.value = mHealth;
         }
      }
      
            
      @:isVar public var hpBarVisible(get,set):Bool;
public function  set_hpBarVisible(param1:Bool) :Bool      {
         mHpProgressBarVisible = param1;
         if(mHpProgressBar != null)
         {
            mHpProgressBar.visible = mHpProgressBarVisible;
         }
         if(mHpBarBg != null)
         {
            mHpBarBg.visible = mHpProgressBarVisible;
         }
return param1;
      }
      
      @:isVar public var hpBar(get,never):MovieClip;
public function  get_hpBar() : MovieClip
      {
         return mHpBarHolder;
      }
function  get_hpBarVisible() : Bool
      {
         return mHpProgressBarVisible;
      }
      
      @:isVar public var screenName(never,set):String;
public function  set_screenName(param1:String) :String      {
         mScreenName = param1;
         updateNameTagText();
return param1;
      }
      
      function updateNameTagText() 
      {
         if(mTextField != null)
         {
            mTextField.text = mScreenName;
            mTextField.textColor = PlayerSpecialStatus.getSpecialTextColor(mScreenName,mTextField.textColor);
         }
      }
      
      function showChat(param1:GameClock = null) 
      {
         if(mChatBalloon != null)
         {
            mChatBalloon.visible = true;
         }
         mNametagTop.visible = false;
      }
      
      function showNametag(param1:GameClock = null) 
      {
         if(mChatBalloon != null)
         {
            mChatBalloon.visible = false;
         }
         mNametagTop.visible = true;
      }
      
      public function showPlayerIsTypingNotification(param1:Bool) 
      {
         if(mPlayerIsTypingNotification != null && !mChatBalloon.visible)
         {
            mPlayerIsTypingNotification.visible = param1;
         }
      }
      
      public function destroy() 
      {
         if(mShowNametagTask != null)
         {
            mShowNametagTask.destroy();
         }
         if(mHpProgressBar != null)
         {
            mHpProgressBar.destroy();
         }
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mHpBarHolder = null;
         mChatBalloon = null;
         mFacebokPic = null;
         mNametagFBPicSlot = null;
         mPlayerIsTypingNotification = null;
         mLogicalWorkComponent = null;
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         mFacade = null;
      }
      
      public function showFacebookPicture(param1:UInt) 
      {
         var go:GameObject;
         var player:PlayerGameObject;
         var playerId= param1;
         if(mFacebokPic == null)
         {
            go = mFacade.gameObjectManager.getReferenceFromId(playerId);
            player = ASCompat.reinterpretAs(go , PlayerGameObject);
            if(player != null)
            {
               if(ASCompat.stringAsBool(player.facebookId) && player.facebookId != "")
               {
                  saveFacebookPic(player.facebookId);
               }
               else
               {
                  mEventComponent.addListener(GameObjectEvent.uniqueEvent("FACEBOOK_ID_RECEIVED_EVENT",player.id),function(param1:events.FacebookIdReceivedEvent)
                  {
                     saveFacebookPic(param1.facebookId);
                  });
               }
            }
         }
         else if(mNametagFBPicSlot != null && !mNametagFBPicSlot.visible)
         {
            startFacebookPicLerp();
         }
      }
      
      function saveFacebookPic(param1:String) 
      {
         var lc:LoaderContext;
         var fbId= param1;
         var loader= new Loader();
         var picUrl= "https://graph.facebook.com/" + fbId + "/picture";
         var url= new URLRequest(picUrl);
         loader.contentLoaderInfo.addEventListener("ioError",(cast function()
         {
         }));
         loader.contentLoaderInfo.addEventListener("securityError",(cast function()
         {
         }));
         loader.contentLoaderInfo.addEventListener("complete",function(param1:flash.events.Event)
         {
            mFacebokPic = loader;
            mFacebokPic.x -= 25;
            mFacebokPic.y -= 25;
            if(mNametagFBPicSlot != null)
            {
               mNametagFBPicSlot.addChild(mFacebokPic);
               startFacebookPicLerp();
            }
         });
         lc = new LoaderContext(true);
         lc.checkPolicyFile = true;
         loader.load(url,lc);
      }
      
      function startFacebookPicLerp() 
      {
         var _loc1_= new TimelineMax({
            "tweens":[TweenMax.to(mNametagTop,0.25,{"y":mNametagTopStartingYPosition - mNametagFBPicSlot.height}),TweenMax.to(mNametagFBPicSlot,0.041666666666666664,{"visible":true})],
            "align":"sequence"
         });
         mLogicalWorkComponent.doLater(5,finishFacebookLerp);
      }
      
      function finishFacebookLerp(param1:GameClock) 
      {
         var _loc2_= new TimelineMax({
            "tweens":[TweenMax.to(mNametagFBPicSlot,0.041666666666666664,{"visible":false}),TweenMax.to(mNametagTop,0.25,{"y":mNametagTopStartingYPosition})],
            "align":"sequence"
         });
      }
      
      @:isVar public var AFK(never,set):Bool;
public function  set_AFK(param1:Bool) :Bool      {
         mAFK = param1;
         if(mAFKText != null)
         {
            if(mAFK)
            {
               mAFKText.text = Locale.getString("AFK");
            }
            else
            {
               mAFKText.text = "";
            }
         }
return param1;
      }
   }


