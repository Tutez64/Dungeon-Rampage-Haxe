package uI.leaderboard
;
   import account.FriendInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.event.EventComponent;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.sceneGraph.SceneGraphManager;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.Locale;
   import town.TownStateMachine;
   import uI.popup.DBUIOneButtonPopup;
   import uI.popup.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
    class UILeaderboard
   {
      
      static var FRIEND_NAME_HIGHLIGHT_COLOR:UInt = (16764232 : UInt);
      
      public static inline final LEADERBOARD_INITIALIZED_EVENT_NAME= "LEADERBOARD_INITIALIZED_EVENT";
      
      public static inline final REFRESH_FRIENDS_EVENT_NAME= "REFRESH_FRIENDS_EVENT";
      
      public static inline final REVERSE_FRIEND_SLOT= false;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mDBFacade:DBFacade;
      
      public var townSwf:SwfAsset;
      
      var mRootMovieClip:MovieClip;
      
      var mLeaderboard:MovieClip;
      
      var mOnlinePopup:MovieClip;
      
      var mOfflinePopup:MovieClip;
      
      var mMessageFriendButton:UIButton;
      
      var mRemoveOnlineFriendButton:UIButton;
      
      var mRemoveOfflineFriendButton:UIButton;
      
      var mGiftFriendButton:UIButton;
      
      var mScrollRightButton:UIButton;
      
      var mScrollLeftButton:UIButton;
      
      var mScrollPageRightButton:UIButton;
      
      var mScrollPageLeftButton:UIButton;
      
      var mFBRemoveFriendPopup:DBUIOneButtonPopup;
      
      var mDRRemoveFriendPopup:DBUITwoButtonPopup;
      
      var mFriendSlots:Vector<LeaderboardFriendSlot>;
      
      var mInviteFriendSlot:LeaderboardFriendSlot;
      
      var mInviteFriendButton:UIButton;
      
      var mOnlineFriends:Vector<FriendInfo>;
      
      var mOfflineFriends:Vector<FriendInfo>;
      
      var mFriendsLength:UInt = 0;
      
      var mCurrentPopupIndex:UInt = 0;
      
      var mScrollIndex:Int = 0;
      
      var mRefreshLeaderboard:Bool = false;
      
      var mCurrentStateName:String;
      
      var mStoreCallback:ASFunction;
      
      var mGetGiftsCallback:ASFunction;
      
      public var initialized:Bool = false;
      
      var mTownStateMachine:TownStateMachine;
      
      var mFriendManagementButton:UIButton;
      
      var mAlert:MovieClip;
      
      var mAlertRenderer:MovieClipRenderController;
      
      public function new(param1:DBFacade, param2:SwfAsset, param3:ASFunction, param4:ASFunction, param5:TownStateMachine)
      {
         
         mDBFacade = param1;
         townSwf = param2;
         mRootMovieClip = param2.root;
         mStoreCallback = param3;
         mGetGiftsCallback = param4;
         mFriendSlots = new Vector<LeaderboardFriendSlot>();
         mOnlineFriends = new Vector<FriendInfo>();
         mOfflineFriends = new Vector<FriendInfo>();
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mSceneGraphComponent = new SceneGraphComponent(param1,"UILeaderboard");
         mLogicalWorkComponent = new LogicalWorkComponent(param1,"UILeaderboard");
         mEventComponent = new EventComponent(mDBFacade);
         mTownStateMachine = param5;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_leaderboard.swf"),leaderboardLoaded);
      }
      
      public function loadRemoveFriendPopup(param1:FriendInfo) 
      {
         var tf:TextFormat;
         var info= param1;
         var mcClass= townSwf.getClass("popup");
         var colorizeStart= (Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1").length : UInt);
         if(info.isDRFriend)
         {
            mDRRemoveFriendPopup = new DBUITwoButtonPopup(mDBFacade,Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1") + info.name + Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_2"),Locale.getString("REMOVE"),function()
            {
               var _loc2_:Array<ASAny> = [];
               _loc2_.push(info.id);
               var _loc1_= JSONRPCService.getFunction("DRFriendRemove",mDBFacade.rpcRoot + "friendrequests");
               _loc1_(mDBFacade.accountId,_loc2_,mDBFacade.validationToken,mDBFacade.dbAccountInfo.removeFriendCallback);
               mDBFacade.metrics.log("DRFriendRemove",{"friendId":Std.string(info.id)});
            },Locale.getString("CANCEL"),null);
            MemoryTracker.track(mDRRemoveFriendPopup,"DBUITwoButtonPopup - created in UILeaderboard.loadRemoveFriendPopup()");
            tf = new TextFormat();
            tf.color = FRIEND_NAME_HIGHLIGHT_COLOR;
            mDRRemoveFriendPopup.colorizeMessage(tf,(colorizeStart : Int),(colorizeStart + info.name.length : Int));
         }
         else if(info.facebookId != null && info.facebookId != "")
         {
            mFBRemoveFriendPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("LEADERBOARD_FB_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_FB_REMOVE_FRIEND_POPUP_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(mFBRemoveFriendPopup,"DBUIOneButtonPopup - created in UILeaderboard.loadRemoveFriendPopup()");
         }
         else if(info.kongregateId != null && info.kongregateId != "")
         {
            mFBRemoveFriendPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("LEADERBOARD_KG_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_KG_REMOVE_FRIEND_POPUP_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(mFBRemoveFriendPopup,"DBUIOneButtonPopup - created in UILeaderboard.loadRemoveFriendPopup()");
         }
      }
      
      function leaderboardLoaded(param1:SwfAsset) 
      {
         if(param1 == null)
         {
            return;
         }
         loadOnlinePopup(param1);
         loadOfflinePopup(param1);
         loadLeaderboard(param1);
         setInitialScrollBarStatus();
         initialized = true;
         mEventComponent.dispatchEvent(new Event("LEADERBOARD_INITIALIZED_EVENT"));
         getFriendData();
      }
      
      function loadOnlinePopup(param1:SwfAsset) 
      {
         var swfAsset= param1;
         var mcClass= swfAsset.getClass("DR_leaderboard_online_tooltip");
         mOnlinePopup = ASCompat.dynamicAs(ASCompat.createInstance(mcClass, []), flash.display.MovieClip);
         if(mOnlinePopup == null)
         {
            return;
         }
         mRootMovieClip.addChild(mOnlinePopup);
         mOnlinePopup.visible = false;
         mGiftFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOnlinePopup : ASAny).join_friend, flash.display.MovieClip));
         mGiftFriendButton.label.text = Locale.getString("LEADERBOARD_GIFT_FRIEND_BUTTON");
         mGiftFriendButton.releaseCallback = function()
         {
            if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
            {
               mDBFacade.errorPopup("GIFTING CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
               return;
            }
            if(mStoreCallback != null)
            {
               mStoreCallback();
            }
         };
         mRemoveOnlineFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOnlinePopup : ASAny).remove_friend, flash.display.MovieClip));
         mRemoveOnlineFriendButton.label.text = Locale.getString("LEADERBOARD_REMOVE_FRIEND_BUTTON");
         mRemoveOnlineFriendButton.releaseCallback = removeFriends;
         ASCompat.setProperty((mOnlinePopup : ASAny).nextassist, "mouseEnabled", false);
         ASCompat.setProperty((mOnlinePopup : ASAny).nextassist, "text", Locale.getString("LEADERBOARD_NEXT_ASSIST"));
         ASCompat.setProperty((mOnlinePopup : ASAny).nextassist, "visible", false);
         ASCompat.setProperty((mOnlinePopup : ASAny).assist_time, "visible", false);
         mOnlinePopup.addEventListener("rollOver",callStopOnPopupTimeToLiveTask);
         mOnlinePopup.addEventListener("rollOut",hidePopup);
      }
      
      function loadOfflinePopup(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass("DR_leaderboard_offline_tooltip");
         mOfflinePopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
         if(mOfflinePopup == null)
         {
            return;
         }
         mRootMovieClip.addChild(mOfflinePopup);
         mOfflinePopup.visible = false;
         SceneGraphManager.setGrayScaleSaturation(ASCompat.dynamicAs((mOfflinePopup : ASAny).join_friend, flash.display.DisplayObject),10);
         ASCompat.setProperty((mOfflinePopup : ASAny).title_label, "mouseEnabled", false);
         ASCompat.setProperty((mOfflinePopup : ASAny).title_label, "text", Locale.getString("LEADERBOARD_OFFLINE_TEXT"));
         ASCompat.setProperty((mOfflinePopup : ASAny).join_friend.label, "mouseEnabled", false);
         ASCompat.setProperty((mOfflinePopup : ASAny).join_friend.label, "text", Locale.getString("LEADERBOARD_JOIN_FRIEND_BUTTON"));
         ASCompat.setProperty((mOfflinePopup : ASAny).nextassist, "mouseEnabled", false);
         ASCompat.setProperty((mOfflinePopup : ASAny).nextassist, "text", Locale.getString("LEADERBOARD_NEXT_ASSIST"));
         mMessageFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOfflinePopup : ASAny).message_friend, flash.display.MovieClip));
         mMessageFriendButton.label.text = Locale.getString("LEADERBOARD_MESSAGE_FRIEND_BUTTON");
         disableMessageFriendButton();
         mRemoveOfflineFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOfflinePopup : ASAny).remove_friend, flash.display.MovieClip));
         mRemoveOfflineFriendButton.label.text = Locale.getString("LEADERBOARD_REMOVE_FRIEND_BUTTON");
         mRemoveOfflineFriendButton.releaseCallback = removeFriends;
         ASCompat.setProperty((mOfflinePopup : ASAny).nextassist, "visible", false);
         ASCompat.setProperty((mOfflinePopup : ASAny).assist_time, "visible", false);
         mOfflinePopup.addEventListener("rollOver",callStopOnPopupTimeToLiveTask);
         mOfflinePopup.addEventListener("rollOut",hidePopup);
      }
      
      function loadLeaderboard(param1:SwfAsset) 
      {
         var swfAsset= param1;
         var leaderboard= swfAsset.getClass("DR_leaderboard");
         mLeaderboard = ASCompat.dynamicAs(ASCompat.createInstance(leaderboard, []), flash.display.MovieClip);
         mLeaderboard.y = mDBFacade.viewHeight - mLeaderboard.height;
         mRootMovieClip.addChild(mLeaderboard);
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_0, flash.display.MovieClip),this,0));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_1, flash.display.MovieClip),this,1));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_2, flash.display.MovieClip),this,2));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_3, flash.display.MovieClip),this,3));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_4, flash.display.MovieClip),this,4));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_5, flash.display.MovieClip),this,5));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_6, flash.display.MovieClip),this,6));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_7, flash.display.MovieClip),this,7));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_8, flash.display.MovieClip),this,8));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_9, flash.display.MovieClip),this,9));
         mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).slot_10, flash.display.MovieClip),this,10));
         mInviteFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).invite_friend, flash.display.MovieClip));
         mInviteFriendButton.label.text = Locale.getString("INVITE_POPUP_BUTTON");
         if(mDBFacade.isFacebookPlayer)
         {
            mInviteFriendButton.releaseCallback = inviteFriendFB;
         }
         else
         {
            mInviteFriendButton.releaseCallback = inviteFriendDR;
         }
         mScrollRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).scrollRight, flash.display.MovieClip));
         mScrollLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).scrollLeft, flash.display.MovieClip));
         mScrollPageRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).scrollPageRight, flash.display.MovieClip));
         mScrollPageLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).scrollPageLeft, flash.display.MovieClip));
         mScrollRightButton.releaseCallback = function()
         {
            scrollLeaderboard(-1);
         };
         mScrollLeftButton.releaseCallback = function()
         {
            scrollLeaderboard(1);
         };
         mScrollPageRightButton.releaseCallback = function()
         {
            scrollLeaderboard(-mFriendSlots.length);
         };
         mScrollPageLeftButton.releaseCallback = function()
         {
            scrollLeaderboard(mFriendSlots.length);
         };
         mDBFacade.dbAccountInfo.getIgnoredFriendData();
         mFriendManagementButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLeaderboard : ASAny).block_button, flash.display.MovieClip));
         mFriendManagementButton.label.text = Locale.getString("FRIEND_MANAGEMENT_HEADING_FRIENDS");
         mFriendManagementButton.releaseCallback = function()
         {
            mTownStateMachine.enterFriendManagementState();
         };
         mAlert = ASCompat.dynamicAs((mLeaderboard : ASAny).block_button.alert_icon, flash.display.MovieClip);
         mAlertRenderer = new MovieClipRenderController(mDBFacade,mAlert);
         mAlertRenderer.play((0 : UInt),true);
         mAlert.visible = false;
      }
      
      public function inviteFriendDR() 
      {
         hidePopup();
         mDBFacade.metrics.log("InviteLeaderboardClickedDR");
         showDRInvitePopup();
      }
      
      public function inviteFriendFB() 
      {
         hidePopup();
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mDBFacade.errorPopup("INVITE CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            return;
         }
         mDBFacade.metrics.log("InviteLeaderboardClickedFB");
         mDBFacade.facebookController.genericFriendRequests();
      }
      
      public function setupNavigationlinks() 
      {
         mFriendManagementButton.isToTheLeftOf(mInviteFriendButton);
      }
      
      public function showDRInvitePopup() 
      {
         townStateMachine.setFriendManagementTabCategory((4 : UInt));
         townStateMachine.enterFriendManagementState();
         townStateMachine.setFriendManagementTabCategory((1 : UInt));
      }
      
      function friendDataSuccessCallback() 
      {
         if(mDBFacade != null)
         {
            loadFriends();
         }
         if(mEventComponent != null)
         {
            mEventComponent.addListener("REFRESH_FRIENDS_EVENT",checkToRefreshLeaderboard);
         }
         if(mGetGiftsCallback != null)
         {
            mGetGiftsCallback();
         }
      }
      
      public function getFriendData() 
      {
         if(mDBFacade.dbAccountInfo.friendInfos.size > 0)
         {
            friendDataSuccessCallback();
            return;
         }
         mDBFacade.dbAccountInfo.getFriendData(friendDataSuccessCallback);
      }
      
      function populateFriendSlots() 
      {
         var _loc1_= 0;
         var _loc2_= 0;
         var _loc4_= (0 : UInt);
         var _loc3_= (0 : UInt);
         _loc1_ = 0;
         while(_loc1_ < mFriendSlots.length)
         {
            mFriendSlots[_loc1_].populateSlot(null);
            _loc2_ = ASCompat.toInt(_loc1_ + mScrollIndex);
            if(_loc2_ < mOnlineFriends.length)
            {
               mFriendSlots[_loc1_].populateSlot(mOnlineFriends[_loc2_]);
            }
            else if(ASCompat.toNumber(_loc2_ - mOnlineFriends.length) < mOfflineFriends.length)
            {
               mFriendSlots[_loc1_].populateSlot(mOfflineFriends[ASCompat.toInt(_loc2_ - mOnlineFriends.length)]);
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      function scrollLeaderboard(param1:Int) 
      {
         hidePopup();
         mScrollIndex += param1;
         if((mScrollIndex : UInt) > mFriendsLength - mFriendSlots.length)
         {
            mScrollIndex = (mFriendsLength - mFriendSlots.length : Int);
         }
         if(mScrollIndex < 0 || mFriendsLength < (mFriendSlots.length : UInt))
         {
            mScrollIndex = 0;
         }
         if(true)
         {
            if(mScrollIndex == 0)
            {
               mScrollRightButton.enabled = false;
               mScrollPageRightButton.enabled = false;
            }
            else
            {
               mScrollRightButton.enabled = true;
               mScrollPageRightButton.enabled = true;
            }
            if((mScrollIndex : UInt) == mFriendsLength - mFriendSlots.length)
            {
               mScrollLeftButton.enabled = false;
               mScrollPageLeftButton.enabled = false;
            }
            else
            {
               mScrollLeftButton.enabled = true;
               mScrollPageLeftButton.enabled = true;
            }
         }
         else
         {
            if(mScrollIndex == 0)
            {
               mScrollLeftButton.enabled = false;
               mScrollPageLeftButton.enabled = false;
            }
            else
            {
               mScrollLeftButton.enabled = true;
               mScrollPageLeftButton.enabled = true;
            }
            if((mScrollIndex : UInt) == mFriendsLength - mFriendSlots.length)
            {
               mScrollRightButton.enabled = false;
               mScrollPageRightButton.enabled = false;
            }
            else
            {
               mScrollRightButton.enabled = true;
               mScrollPageRightButton.enabled = true;
            }
         }
         populateFriendSlots();
      }
      
      function loadFriends() 
      {
         var _loc3_:FriendInfo = null;
         var _loc2_:FriendInfo = null;
         var _loc4_= mDBFacade.dbAccountInfo.friendInfos;
         var _loc1_= _loc4_.keysToArray();
         mOfflineFriends.splice(0,(mOfflineFriends.length : UInt));
         mOnlineFriends.splice(0,(mOnlineFriends.length : UInt));
         var _loc5_:ASAny;
         if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
         {
            _loc5_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(_loc4_.itemFor(_loc5_), account.FriendInfo);
            if(_loc2_.id == mDBFacade.accountId)
            {
               _loc3_ = _loc2_;
            }
            else if(_loc2_.isOnline())
            {
               mOnlineFriends.push(_loc2_);
            }
            else
            {
               mOfflineFriends.push(_loc2_);
            }
         }
         sortFriends();
         mOnlineFriends.unshift(_loc3_);
         mFriendsLength = (mOnlineFriends.length + mOfflineFriends.length : UInt);
         if(mFriendsLength <= (mFriendSlots.length : UInt))
         {
            mScrollLeftButton.enabled = false;
            mScrollPageLeftButton.enabled = false;
         }
         populateFriendSlots();
      }
      
      function removeFriends() 
      {
      }
      
      function sortFriends() 
      {
         ASCompat.ASVector.sort(mOnlineFriends, sortBasedOnFriendsHighestAvatarLevel);
         ASCompat.ASVector.sort(mOfflineFriends, sortBasedOnFriendsHighestAvatarLevel);
      }
      
      function sortBasedOnFriendsHighestAvatarLevel(param1:FriendInfo, param2:FriendInfo) : Int
      {
         if(param1.trophies < param2.trophies)
         {
            return 1;
         }
         return -1;
      }
      
      public function hidePopup(param1:MouseEvent = null) 
      {
         if(mRefreshLeaderboard)
         {
            refreshLeaderboard();
         }
         if(mOnlinePopup != null)
         {
            mOnlinePopup.visible = false;
         }
         if(mOfflinePopup != null)
         {
            mOfflinePopup.visible = false;
         }
      }
      
      @:isVar public var alert(never,set):Bool;
public function  set_alert(param1:Bool) :Bool      {
         return mAlert.visible = param1;
      }
      
      @:isVar public var onlinePopup(get,never):MovieClip;
public function  get_onlinePopup() : MovieClip
      {
         return mOnlinePopup;
      }
      
      @:isVar public var offlinePopup(get,never):MovieClip;
public function  get_offlinePopup() : MovieClip
      {
         return mOfflinePopup;
      }
      
      @:isVar public var messageFriend(get,never):UIButton;
public function  get_messageFriend() : UIButton
      {
         return mMessageFriendButton;
      }
      
      @:isVar public var removeOnlineFriend(get,never):UIButton;
public function  get_removeOnlineFriend() : UIButton
      {
         return mRemoveOnlineFriendButton;
      }
      
      @:isVar public var removeOfflineFriend(get,never):UIButton;
public function  get_removeOfflineFriend() : UIButton
      {
         return mRemoveOfflineFriendButton;
      }
      
      @:isVar public var giftFriend(get,never):UIButton;
public function  get_giftFriend() : UIButton
      {
         return mGiftFriendButton;
      }
      
      @:isVar public var FBRemoveFriendPopup(get,never):DBUIOneButtonPopup;
public function  get_FBRemoveFriendPopup() : DBUIOneButtonPopup
      {
         return mFBRemoveFriendPopup;
      }
      
      public function setRootMovieClip(param1:MovieClip) 
      {
         mRootMovieClip = param1;
         if(mOnlinePopup != null)
         {
            mRootMovieClip.addChild(mOnlinePopup);
         }
         if(mOfflinePopup != null)
         {
            mRootMovieClip.addChild(mOfflinePopup);
         }
         if(mLeaderboard != null)
         {
            mRootMovieClip.addChild(mLeaderboard);
         }
      }
      
      public function setInitialScrollBarStatus() 
      {
         if(true)
         {
            mScrollRightButton.enabled = false;
            mScrollPageRightButton.enabled = false;
         }
         else
         {
            mScrollLeftButton.enabled = false;
            mScrollPageLeftButton.enabled = false;
         }
      }
      
      function checkToRefreshLeaderboard(param1:Event) 
      {
         if(mOnlinePopup.visible || mOfflinePopup.visible)
         {
            mRefreshLeaderboard = true;
         }
         else
         {
            refreshLeaderboard();
         }
      }
      
      public function refreshLeaderboard() 
      {
         mRefreshLeaderboard = false;
         hidePopup();
         loadFriends();
      }
      
            
      @:isVar public var currentPopupIndex(get,set):UInt;
public function  set_currentPopupIndex(param1:UInt) :UInt      {
         return mCurrentPopupIndex = param1;
      }
function  get_currentPopupIndex() : UInt
      {
         return mCurrentPopupIndex;
      }
      
      @:isVar public var mustRefreshLeaderboard(get,never):Bool;
public function  get_mustRefreshLeaderboard() : Bool
      {
         return mRefreshLeaderboard;
      }
      
      public function callStopOnPopupTimeToLiveTask(param1:MouseEvent = null) 
      {
         mFriendSlots[(mCurrentPopupIndex : Int)].stopPopupTimeToLiveTask();
      }
      
      public function destroy() 
      {
         initialized = false;
         mDBFacade = null;
         var _loc2_:ASAny;
         final __ax4_iter_155 = mFriendSlots;
         if (checkNullIteratee(__ax4_iter_155)) for (_tmp_ in __ax4_iter_155)
         {
            _loc2_ = _tmp_;
            _loc2_.destroy();
            _loc2_ = null;
         }
         if(mInviteFriendSlot != null)
         {
            mInviteFriendSlot.destroy();
         }
         mInviteFriendSlot = null;
         if(mInviteFriendButton != null)
         {
            mInviteFriendButton.destroy();
         }
         mInviteFriendButton = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
         }
         mAlertRenderer = null;
         var _loc3_:ASAny;
         final __ax4_iter_156 = mOnlineFriends;
         if (checkNullIteratee(__ax4_iter_156)) for (_tmp_ in __ax4_iter_156)
         {
            _loc3_ = _tmp_;
            _loc3_ = null;
         }
         var _loc1_:ASAny;
         final __ax4_iter_157 = mOfflineFriends;
         if (checkNullIteratee(__ax4_iter_157)) for (_tmp_ in __ax4_iter_157)
         {
            _loc1_ = _tmp_;
            _loc1_ = null;
         }
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mMessageFriendButton != null)
         {
            mMessageFriendButton.destroy();
         }
         mMessageFriendButton = null;
         if(mRemoveOnlineFriendButton != null)
         {
            mRemoveOnlineFriendButton.destroy();
         }
         mRemoveOnlineFriendButton = null;
         if(mRemoveOfflineFriendButton != null)
         {
            mRemoveOfflineFriendButton.destroy();
         }
         mRemoveOfflineFriendButton = null;
         if(mGiftFriendButton != null)
         {
            mGiftFriendButton.destroy();
         }
         mGiftFriendButton = null;
         if(mScrollRightButton != null)
         {
            mScrollRightButton.destroy();
         }
         mScrollRightButton = null;
         if(mScrollLeftButton != null)
         {
            mScrollLeftButton.destroy();
         }
         mScrollLeftButton = null;
         if(mScrollPageRightButton != null)
         {
            mScrollPageRightButton.destroy();
         }
         mScrollPageRightButton = null;
         if(mScrollPageLeftButton != null)
         {
            mScrollPageLeftButton.destroy();
         }
         mScrollPageLeftButton = null;
         mRootMovieClip = null;
         mLeaderboard = null;
         mOnlinePopup = null;
         mOfflinePopup = null;
         mStoreCallback = null;
         mGetGiftsCallback = null;
      }
      
            
      @:isVar public var currentStateName(get,set):String;
public function  set_currentStateName(param1:String) :String      {
         return mCurrentStateName = param1;
      }
function  get_currentStateName() : String
      {
         return mCurrentStateName;
      }
      
      @:isVar public var onlineFriends(get,never):Vector<FriendInfo>;
public function  get_onlineFriends() : Vector<FriendInfo>
      {
         return mOnlineFriends;
      }
      
      @:isVar public var offlineFriends(get,never):Vector<FriendInfo>;
public function  get_offlineFriends() : Vector<FriendInfo>
      {
         return mOfflineFriends;
      }
      
      @:isVar public var townStateMachine(get,never):TownStateMachine;
public function  get_townStateMachine() : TownStateMachine
      {
         return mTownStateMachine;
      }
      
      @:isVar public var getManageFriendsButton(get,never):UIButton;
public function  get_getManageFriendsButton() : UIButton
      {
         return mFriendManagementButton;
      }
      
      @:isVar public var getInviteFriendsButton(get,never):UIButton;
public function  get_getInviteFriendsButton() : UIButton
      {
         return mInviteFriendButton;
      }
      
      public function enableMessageFriendButton() 
      {
         SceneGraphManager.setGrayScaleSaturation(ASCompat.dynamicAs((mOfflinePopup : ASAny).message_friend, flash.display.DisplayObject),100);
         ASCompat.setProperty((mOfflinePopup : ASAny).message_friend.label, "mouseEnabled", true);
         mMessageFriendButton.enabled = true;
      }
      
      public function disableMessageFriendButton() 
      {
         SceneGraphManager.setGrayScaleSaturation(ASCompat.dynamicAs((mOfflinePopup : ASAny).message_friend, flash.display.DisplayObject),10);
         ASCompat.setProperty((mOfflinePopup : ASAny).message_friend.label, "mouseEnabled", false);
         mMessageFriendButton.enabled = false;
      }
   }


