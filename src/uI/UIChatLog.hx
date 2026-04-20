package uI
;
   import account.PlayerSpecialStatus;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIInputText;
   import brain.uI.UISlider;
   import distributedObjects.HeroGameObjectOwner;
   import events.ChatEvent;
   import events.ChatLogEvent;
   import facade.DBFacade;
   import facade.Locale;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class UIChatLog
   {
      
      static var JOINED_DUNGEON_COLOR:UInt = (16063002 : UInt);
      
      static var LEFT_DUNGEON_COLOR:UInt = (16063002 : UInt);
      
      static var FRIEND_STATUS_ONLINE_COLOR:UInt = (16764232 : UInt);
      
      static var FRIEND_STATUS_OFFLINE_COLOR:UInt = (16764232 : UInt);
      
      static var NAME_CHAT_COLOR:UInt = (16764232 : UInt);
      
      public static var JOINED_DUNGEON_TYPE:String = "JOINED_DUNGEON";
      
      public static var LEFT_DUNGEON_TYPE:String = "LEFT_DUNGEON";
      
      public static var FRIEND_STATUS_ONLINE_TYPE:String = "FRIEND_STATUS_ONLINE";
      
      public static var FRIEND_STATUS_OFFLINE_TYPE:String = "FRIEND_STATUS_OFFLINE";
      
      public static var CHAT_TYPE:String = "CHAT";
      
      static var MAX_CHATS:UInt = (50 : UInt);
      
      static inline final CHAT_FADE_DURATION:Float = 0.3;
      
      static inline final MAX_CHAT_CHARS= (169 : UInt);
      
      static var mChatLogXOffset:UInt = (0 : UInt);
      
      static var mChatLogYOffset:UInt = (0 : UInt);
      
      static var mChats:Vector<ChatTextFieldHelper>;
      
      var mDBFacade:DBFacade;
      
      var mChatLog:TextField;
      
      var mSlider:UISlider;
      
      var mEventComponent:EventComponent;
      
      var mChatLogContainer:MovieClip;
      
      var mFadeTween:TweenMax;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mAutoShowChatLog:Bool = false;
      
      var mUserToggled:Bool = false;
      
      var mToggledOpen:Bool = false;
      
      var mPlayerSetSlider:Bool = false;
      
      var mChatLogButton:UIButton;
      
      var mChatInputText:UIInputText;
      
      var mChatSendButton:UIButton;
      
      var mChatLogShowing:Bool = false;
      
      var mHeroOwner:HeroGameObjectOwner;
      
      var mEnabledChatEnterEvent:Bool = true;
      
      var mPreviousHeight:Float = 1;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:MovieClip)
      {
         
         mDBFacade = param1;
         if(mChats == null)
         {
            mChats = new Vector<ChatTextFieldHelper>();
         }
         mPlayerSetSlider = false;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIChatLog");
         mEventComponent = new EventComponent(mDBFacade);
         setupButtons(param3,param4,param5);
         setupLog(param2);
         mAutoShowChatLog = mDBFacade.dbConfigManager.getConfigBoolean("AUTO_SHOW_CHAT_LOG",true);
         constructAndRenderNewChat();
         enable();
      }
      
      @:isVar public var heroOwner(never,set):HeroGameObjectOwner;
public function  set_heroOwner(param1:HeroGameObjectOwner) :HeroGameObjectOwner      {
         return mHeroOwner = param1;
      }
      
      public function enable() 
      {
         this.disable();
         mEventComponent.addListener("CHAT_LOG_EVENT",chatEventHandler);
         mChatInputText.root.addEventListener("focusIn",onChatTextFieldFocus);
         mChatInputText.root.addEventListener("focusOut",onChatTextFieldLoseFocus);
         mDBFacade.stageRef.addEventListener("keyDown",checkKeyEvent);
      }
      
      public function disable() 
      {
         mEventComponent.removeListener("CHAT_LOG_EVENT");
         mChatInputText.root.removeEventListener("focusIn",onChatTextFieldFocus);
         mChatInputText.root.removeEventListener("focusOut",onChatTextFieldLoseFocus);
         mDBFacade.stageRef.removeEventListener("keyDown",checkKeyEvent);
      }
      
      function onChatTextFieldFocus(param1:FocusEvent) 
      {
         if(mHeroOwner != null)
         {
            mHeroOwner.showPlayerIsTyping(true);
         }
         chatTextFieldFocus();
      }
      
      function onChatTextFieldLoseFocus(param1:FocusEvent) 
      {
         if(mHeroOwner != null)
         {
            mHeroOwner.showPlayerIsTyping(false);
         }
         chatTextFieldLostFocus();
      }
      
      function setupButtons(param1:MovieClip, param2:MovieClip, param3:MovieClip) 
      {
         var chatTextField= param1;
         var chatLogButton= param2;
         var sendChatButton= param3;
         mChatInputText = new UIInputText(mDBFacade,chatTextField);
         mChatInputText.defaultText = Locale.getString("DEFAULT_CHAT_PROMPT");
         mChatInputText.enterCallback = sendChat;
         mChatInputText.textField.maxChars = 169;
         mChatLogButton = new UIButton(mDBFacade,chatLogButton);
         mChatLogButton.releaseCallback = toggleChatLog;
         mChatSendButton = new UIButton(mDBFacade,sendChatButton);
         mChatSendButton.releaseCallback = function()
         {
            sendChat(mChatInputText.text);
         };
      }
      
      function sendChat(param1:String) 
      {
         mChatInputText.clear();
         mDBFacade.regainFocus();
         mDBFacade.inputManager.clear();
         if(ASCompat.stringAsBool(param1))
         {
            mEventComponent.dispatchEvent(new ChatEvent("ChatEvent_OUTGOING_CHAT_UPDATE",(0 : UInt),param1));
         }
      }
      
      public function toggleChatLog() 
      {
         if(mChatLogShowing)
         {
            mToggledOpen = false;
            hideChatLog();
         }
         else
         {
            mToggledOpen = true;
            showChatLog();
         }
      }
      
      function chatTextFieldFocus() 
      {
         if(mAutoShowChatLog)
         {
            showChatLog();
         }
      }
      
      function chatTextFieldLostFocus() 
      {
         if(mAutoShowChatLog && !mToggledOpen)
         {
            hideChatLog();
         }
      }
      
      function checkKeyEvent(param1:KeyboardEvent) 
      {
         if(!Logger.isConsoleVisible())
         {
            if(param1.keyCode == 13 && mEnabledChatEnterEvent)
            {
               mDBFacade.stageRef.focus = mChatInputText.textField;
            }
            else if(param1.keyCode == 220 && mDBFacade.mainStateMachine.currentStateName == "RunState")
            {
               toggleChatLog();
            }
         }
      }
      
      function setupLog(param1:MovieClip) 
      {
         mChatLogContainer = param1;
         mChatLog = ASCompat.dynamicAs((mChatLogContainer : ASAny).chatLog, flash.text.TextField);
         mSlider = new UISlider(mDBFacade,ASCompat.dynamicAs((mChatLogContainer : ASAny).slider, flash.display.MovieClip),(1 : UInt));
         mSlider.minimum = 100;
         mSlider.maximum = 0;
         mSlider.tick = 2;
         mSlider.value = 0;
         mSlider.updateCallback = sliderCallback;
         init();
      }
      
      function sliderCallback(param1:Float) 
      {
         mPlayerSetSlider = true;
         setChatLogPosition(param1);
      }
      
      function init() 
      {
         mChatLogContainer.y += mChatLogYOffset;
         mChatLogContainer.x += mChatLogXOffset;
         mChatLog.text = "";
         mChatLogContainer.visible = false;
         mSlider.visible = false;
      }
      
      function chatEventHandler(param1:ChatLogEvent) 
      {
         var _loc2_= (0 : UInt);
         switch(param1.chatLogType)
         {
            case (_ == JOINED_DUNGEON_TYPE => true):
               _loc2_ = JOINED_DUNGEON_COLOR;
               
            case (_ == LEFT_DUNGEON_TYPE => true):
               _loc2_ = LEFT_DUNGEON_COLOR;
               
            case (_ == FRIEND_STATUS_ONLINE_TYPE => true):
               _loc2_ = FRIEND_STATUS_ONLINE_COLOR;
               
            case (_ == FRIEND_STATUS_OFFLINE_TYPE => true):
               _loc2_ = FRIEND_STATUS_OFFLINE_COLOR;

default:
         }
         addChatLog(param1.chat,_loc2_,param1.playerName);
      }
      
      function addChatLog(param1:String, param2:UInt, param3:String = "") 
      {
         var _loc4_:ChatTextFieldHelper;
         var __ax4_iter_135:Vector<ChatTextFieldHelper>;
         var __tmpAssignObj7:ChatTextFieldHelper;
         var __tmpAssignObj8:ChatTextFieldHelper;
         var _loc8_:ChatTextFieldHelper = null;
         var _loc6_= 0;
         if(mChatLog == null)
         {
            return;
         }
         var _loc7_= new ChatTextFieldHelper();
         param1 += "\n";
         var _loc5_= (mChatLog.length : UInt);
         _loc7_.chatText = param1;
         _loc7_.color = param2;
         _loc7_.playerName = param3;
         _loc7_.colorStartIndex = _loc5_;
         _loc7_.colorEndIndex = _loc5_ + param1.length;
         mChats.push(_loc7_);
         if((mChats.length : UInt) > MAX_CHATS)
         {
            _loc8_ = mChats.shift();
            _loc6_ = _loc8_.colorEndIndex - _loc8_.colorStartIndex;
            __ax4_iter_135 = mChats;
            if (checkNullIteratee(__ax4_iter_135)) for (_tmp_ in __ax4_iter_135)
            {
               _loc4_ = _tmp_;
               __tmpAssignObj7 = _loc4_;
               ASCompat.setProperty(__tmpAssignObj7, "colorEndIndex", __tmpAssignObj7.colorEndIndex - _loc6_);
               __tmpAssignObj8 = _loc4_;
               ASCompat.setProperty(__tmpAssignObj8, "colorStartIndex", __tmpAssignObj8.colorStartIndex - _loc6_);
            }
         }
         constructAndRenderNewChat();
      }
      
      function constructAndRenderNewChat() 
      {
         var _loc1_:TextFormat = null;
         var _loc2_:ASAny = 0;
         mChatLog.text = "";
         var _loc3_:ChatTextFieldHelper;
         final __ax4_iter_136 = mChats;
         if (checkNullIteratee(__ax4_iter_136)) for (_tmp_ in __ax4_iter_136)
         {
            _loc3_ = _tmp_;
            mChatLog.text = mChatLog.text + Std.string(_loc3_.chatText);
         }
         final __ax4_iter_137 = mChats;
         if (checkNullIteratee(__ax4_iter_137)) for (_tmp_ in __ax4_iter_137)
         {
            _loc3_  = _tmp_;
            _loc2_ = _loc3_.colorStartIndex;
            if(_loc3_.playerName != "")
            {
               _loc1_ = new TextFormat();
               _loc1_.color = PlayerSpecialStatus.getSpecialTextColor(_loc3_.playerName,NAME_CHAT_COLOR);
               mChatLog.setTextFormat(_loc1_,ASCompat.toInt(_loc2_),ASCompat.toInt(_loc2_ + _loc3_.playerName.length + 1));
               _loc2_ += _loc3_.playerName.length + 1;
               _loc1_ = null;
            }
            if(ASCompat.toNumberField(_loc3_, "color") != 0)
            {
               _loc1_ = new TextFormat();
               _loc1_.color = _loc3_.color;
               mChatLog.setTextFormat(_loc1_,ASCompat.toInt(_loc2_),ASCompat.toInt(_loc3_.colorEndIndex));
            }
         }
         checkToShowSlider();
         adjustSlider();
      }
      
      function adjustSlider() 
      {
         var _loc1_= false;
         if(mSlider.value == mSlider.minimum)
         {
            _loc1_ = true;
         }
         if(_loc1_ || !mPlayerSetSlider)
         {
            mSlider.value = mSlider.minimum;
         }
         else
         {
            mSlider.value = mPreviousHeight / mChatLog.textHeight * mSlider.value;
         }
         mPreviousHeight = mChatLog.textHeight;
         setChatLogPosition(mSlider.value);
      }
      
      function setChatLogPosition(param1:Float) 
      {
         var _loc2_= Math.fround((mChatLog.maxScrollV + 1) * param1 / 100);
         mChatLog.scrollV = Std.int(_loc2_);
      }
      
      public function isShowing() : Bool
      {
         return mChatLogContainer.visible;
      }
      
      public function hideChatLog() 
      {
         if(!mChatLogShowing)
         {
            return;
         }
         mChatLogShowing = false;
         if(mFadeTween != null && mFadeTween.currentProgress != 1)
         {
            mFadeTween.complete();
         }
         mChatLogContainer.alpha = 1;
         mFadeTween = TweenMax.to(mChatLogContainer,0.3,{
            "alpha":0,
            "onComplete":function()
            {
               mChatLogContainer.visible = false;
            }
         });
         mSlider.visible = false;
      }
      
      public function showChatLog() 
      {
         if(mChatLogShowing)
         {
            return;
         }
         mChatLogShowing = true;
         if(mFadeTween != null && mFadeTween.currentProgress != 1)
         {
            mFadeTween.complete();
         }
         mChatLogContainer.visible = true;
         mChatLogContainer.alpha = 0;
         mFadeTween = TweenMax.to(mChatLogContainer,0.3,{"alpha":1});
         constructAndRenderNewChat();
         checkToShowSlider();
      }
      
      function checkToShowSlider() 
      {
         if(mChatLog.maxScrollV > 1)
         {
            mSlider.visible = true;
         }
      }
      
      public function destroy() 
      {
         if(mFadeTween != null && mFadeTween.currentProgress != 1)
         {
            mFadeTween.complete();
         }
         disable();
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
         if(mEventComponent != null)
         {
            mEventComponent.removeAllListeners();
            mEventComponent.destroy();
         }
         if(mSlider != null)
         {
            mSlider.destroy();
         }
         mSlider = null;
         if(mChatLogButton != null)
         {
            mChatLogButton.destroy();
         }
         mChatLogButton = null;
         mEventComponent = null;
         mDBFacade = null;
         mChatLog = null;
         mChatLogContainer = null;
      }
      
            
      @:isVar public var enabledChatEnterEvent(get,set):Bool;
public function  set_enabledChatEnterEvent(param1:Bool) :Bool      {
         return mEnabledChatEnterEvent = param1;
      }
function  get_enabledChatEnterEvent() : Bool
      {
         return mEnabledChatEnterEvent;
      }
   }


private class ChatTextFieldHelper
{
   
   public var chatText:String;
   
   public var color:UInt = 0;
   
   public var colorStartIndex:UInt = 0;
   
   public var colorEndIndex:UInt = 0;
   
   public var playerName:String;
   
   public function new()
   {
      
   }
}
