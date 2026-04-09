package uI.uINewsFeed
;
   import account.FriendInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.workLoop.LogicalWorkComponent;
   import events.ChatLogEvent;
   import events.FriendStatusEvent;
   import events.FriendSummaryNewsFeedEvent;
   import events.GenericNewsFeedEvent;
   import facade.DBFacade;
   import facade.Locale;
   import uI.UIChatLog;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class UINewsFeed
   {
      
      public static inline final FRIEND_STATUS_TYPE= (0 : UInt);
      
      public static inline final PLAYER_DUNGEON_STATUS_TYPE= (1 : UInt);
      
      public static inline final GENERIC_MESSAGE_STATUS_TYPE= (2 : UInt);
      
      public static inline final FRIEND_SUMMARY_MESSAGE_STATUS_TYPE= (3 : UInt);
      
      public static inline final LERP_INTO_SCREEN_TIME:Float = 0.25;
      
      public static inline final LERP_OUT_OF_SCREEN_TIME:Float = 0.25;
      
      public static inline final STAY_ON_SCREEN_DURATION:Float = 5;
      
      public static inline final FEED_HANGING_OFF_THE_EDGE_OFFSET:Float = 13;
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mRoot:MovieClip;
      
      var mLabel:TextField;
      
      var mLabelY:Float = Math.NaN;
      
      var mIcon:MovieClip;
      
      var mFriendEvent:FriendStatusEvent;
      
      var mGenericFeedMessageEvent:GenericNewsFeedEvent;
      
      var mFriendSummaryFeedMessageEvent:FriendSummaryNewsFeedEvent;
      
      var mFinishedCallback:ASFunction;
      
      var mIsValid:Bool = true;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ASFunction, param4:UInt, param5:Event = null)
      {
         
         mDBFacade = param1;
         mRoot = param2;
         mFinishedCallback = param3;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent.addChild(mRoot,(50 : UInt));
         setupUI();
         if(Std.isOfType(param5 , FriendStatusEvent))
         {
            mFriendEvent = ASCompat.reinterpretAs(param5 , FriendStatusEvent);
            loadFriendDetails();
         }
         else if(Std.isOfType(param5 , GenericNewsFeedEvent))
         {
            mGenericFeedMessageEvent = ASCompat.reinterpretAs(param5 , GenericNewsFeedEvent);
         }
         else if(Std.isOfType(param5 , FriendSummaryNewsFeedEvent))
         {
            mFriendSummaryFeedMessageEvent = ASCompat.reinterpretAs(param5 , FriendSummaryNewsFeedEvent);
         }
         else
         {
            mIsValid = false;
         }
         switch(param4)
         {
            case 0:
               prepareFriendStatusFeed();
               
            case 1:
               preparePlayerDungeonStatusFeed();
               
            case 2:
               prepareGenericMessageFeed();
               
            case 3:
               prepareFriendSummaryMessageFeed();
         }
         mRoot.visible = false;
      }
      
      function setupUI() 
      {
         mLabel = ASCompat.dynamicAs((mRoot : ASAny).label, flash.text.TextField);
         mLabelY = mLabel.y;
         mIcon = ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip);
      }
      
      public function lerpIntoScreen() 
      {
         mRoot.visible = true;
         TweenMax.to(mRoot,0.25,{"x":mRoot.x - mRoot.width / 2 + 13});
         mLogicalWorkComponent.doLater(5,lerpOutOfScreen);
      }
      
      public function lerpOutOfScreen(param1:GameClock) 
      {
         TweenMax.to(mRoot,0.25,{"x":mRoot.x + mRoot.width});
         mLogicalWorkComponent.doLater(0.25,mFinishedCallback);
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      function loadFriendDetails() 
      {
         if(mFriendEvent == null)
         {
            mIsValid = false;
            return;
         }
         var _loc2_= ASCompat.dynamicAs(mDBFacade.dbAccountInfo.friendInfos.itemFor(mFriendEvent.friendId), account.FriendInfo);
         if(_loc2_ == null)
         {
            mIsValid = false;
            return;
         }
         var _loc1_= _loc2_.name;
         mLabel.text = _loc1_;
         var _loc3_= _loc2_.clonePic();
         mIcon.addChild(_loc3_);
         _loc3_.x -= 25;
         _loc3_.y -= 25;
      }
      
      function adjustLabelHeight() 
      {
         if(mLabel.numLines == 1)
         {
            mLabel.y = mLabelY + mLabel.height * 0.2;
         }
         else
         {
            mLabel.y = mLabelY;
         }
      }
      
      function prepareFriendStatusFeed() 
      {
         var _loc1_:String = null;
         var _loc2_= "";
         if(mFriendEvent.status)
         {
            _loc2_ += Locale.getString("NEWS_FEED_FRIEND_ONLINE");
            _loc1_ = UIChatLog.FRIEND_STATUS_ONLINE_TYPE;
         }
         else
         {
            _loc2_ += Locale.getString("NEWS_FEED_FRIEND_OFFLINE");
            _loc1_ = UIChatLog.FRIEND_STATUS_OFFLINE_TYPE;
         }
         mLabel.text = mLabel.text + _loc2_;
         mDBFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT",mLabel.text.toUpperCase(),_loc1_));
         adjustLabelHeight();
      }
      
      function preparePlayerDungeonStatusFeed() 
      {
         var _loc1_:String = null;
         var _loc2_= "";
         if(mFriendEvent.status)
         {
            _loc2_ += Locale.getString("NEWS_FEED_PLAYER_JOINED_DUNGEON");
            _loc1_ = UIChatLog.JOINED_DUNGEON_TYPE;
         }
         else
         {
            _loc2_ += Locale.getString("NEWS_FEED_PLAYER_LEFT_DUNGEON");
            _loc1_ = UIChatLog.LEFT_DUNGEON_TYPE;
         }
         mLabel.text = mLabel.text + _loc2_;
         mDBFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT",mLabel.text.toUpperCase(),_loc1_));
         adjustLabelHeight();
      }
      
      public function colorizeMessage(param1:TextFormat, param2:Int, param3:Int) 
      {
         mLabel.setTextFormat(param1,param2,param3);
      }
      
      function prepareFriendSummaryMessageFeed() 
      {
         if(mFriendSummaryFeedMessageEvent == null)
         {
            mIsValid = false;
            return;
         }
         var _loc1_= new TextFormat();
         _loc1_.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
         if(mFriendSummaryFeedMessageEvent.isFriendNameInFront)
         {
            mLabel.text = mFriendSummaryFeedMessageEvent.friendName + mFriendSummaryFeedMessageEvent.message;
            colorizeMessage(_loc1_,0,mFriendSummaryFeedMessageEvent.friendName.length);
         }
         else
         {
            mLabel.text = mFriendSummaryFeedMessageEvent.message + mFriendSummaryFeedMessageEvent.friendName;
            colorizeMessage(_loc1_,mFriendSummaryFeedMessageEvent.message.length,mFriendSummaryFeedMessageEvent.message.length + mFriendSummaryFeedMessageEvent.friendName.length);
         }
         adjustLabelHeight();
         var _loc2_= mFriendSummaryFeedMessageEvent.pic;
         _loc2_.scaleX = _loc2_.scaleY = 0.75;
         mIcon.addChild(_loc2_);
      }
      
      function prepareGenericMessageFeed() 
      {
         var picLocation:String;
         var picClassName:String;
         if(mGenericFeedMessageEvent == null)
         {
            mIsValid = false;
            return;
         }
         mLabel.text = mGenericFeedMessageEvent.message;
         adjustLabelHeight();
         picLocation = mGenericFeedMessageEvent.picLocation;
         picClassName = mGenericFeedMessageEvent.picClassName;
         if(picLocation != "")
         {
            if(picClassName != "")
            {
               mAssetLoadingComponent.getSwfAsset(picLocation,function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc2_= param1.getClass(picClassName);
                  var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                  _loc3_.scaleX = _loc3_.scaleY = 1.07;
                  _loc3_.x -= _loc3_.width / 2 + 10;
                  _loc3_.y -= _loc3_.height / 2;
                  mIcon.addChild(_loc3_);
               });
            }
         }
      }
      
      @:isVar public var isValid(get,never):Bool;
public function  get_isValid() : Bool
      {
         return mIsValid;
      }
      
      public function destroy() 
      {
         if(mSceneGraphComponent.contains(mRoot,(50 : UInt)))
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         mDBFacade = null;
         mFinishedCallback = null;
         mRoot = null;
         mLabel = null;
         mIcon = null;
         mFriendEvent = null;
      }
   }


