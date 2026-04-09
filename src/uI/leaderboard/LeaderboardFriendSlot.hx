package uI.leaderboard
;
   import account.FriendInfo;
   import account.PlayerSpecialStatus;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.uI.UIButton;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import uI.DBUIOneButtonPopup;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
    class LeaderboardFriendSlot
   {
      
      public static inline final ONLINE_POPUP_TWEEN_DURATION:Float = 0.2;
      
      public static inline final OFFLINE_POPUP_TWEEN_DURATION:Float = 0.2;
      
      public static inline final ONLINE_POPUP_OFFSET:Float = 50;
      
      public static inline final OFFLINE_POPUP_OFFSET:Float = 60;
      
      public static inline final POPUP_TIME_TO_LIVE:Float = 1;
      
      var mDBFacade:DBFacade;
      
      var mFriendSlot:MovieClip;
      
      var mFriendName:TextField;
      
      var mFriendOnlineClip:MovieClip;
      
      var mFriendOfflineClip:MovieClip;
      
      var mMeOnlineClip:MovieClip;
      
      var mJoinOnlineClip:MovieClip;
      
      var mFriendInviteButton:UIButton;
      
      var mFriendPicButton:UIButton;
      
      var mFriendLevel:MovieClip;
      
      var mOnlinePopup:MovieClip;
      
      var mOfflinePopup:MovieClip;
      
      var mMessageFriendButton:UIButton;
      
      var mJoinOnlineFriendButton:UIButton;
      
      var mRemoveOnlineFriendButton:UIButton;
      
      var mRemoveFriendButton:UIButton;
      
      var mFBRemoveFriendPopup:DBUIOneButtonPopup;
      
      var mFriendInfo:FriendInfo;
      
      var mLeaderboard:UILeaderboard;
      
      var mThisSlotIndex:UInt = 0;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mFriendSlotPosition:Point;
      
      var mPopupTimeToLiveTask:Task;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:UILeaderboard, param4:Int)
      {
         
         mDBFacade = param1;
         mFriendSlot = param2;
         mLeaderboard = param3;
         mThisSlotIndex = (param4 : UInt);
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mLogicalWorkComponent = new LogicalWorkComponent(param1);
         mFriendSlotPosition = mFriendSlot.localToGlobal(new Point(0,0));
         loadVariables();
         populateSlot(null);
      }
      
      function loadVariables() 
      {
         mOnlinePopup = mLeaderboard.onlinePopup;
         mOfflinePopup = mLeaderboard.offlinePopup;
         mMessageFriendButton = mLeaderboard.messageFriend;
         mFriendName = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_name, flash.text.TextField);
         mFriendName.mouseEnabled = false;
         mFriendPicButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic, flash.display.MovieClip));
         mFriendOnlineClip = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic.friend_online, flash.display.MovieClip);
         mFriendOfflineClip = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic.friend_offline, flash.display.MovieClip);
         mMeOnlineClip = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic.you_online, flash.display.MovieClip);
         mJoinOnlineClip = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic.join, flash.display.MovieClip);
         mJoinOnlineFriendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mFriendSlot : ASAny).friend_pic.join.join, flash.display.MovieClip));
         mJoinOnlineFriendButton.label.text = Locale.getString("LEADERBOARD_JOIN_FRIEND_BUTTON");
         mFriendLevel = ASCompat.dynamicAs((mFriendSlot : ASAny).friend_level, flash.display.MovieClip);
         mFriendLevel.mouseEnabled = false;
         mFriendLevel.mouseChildren = false;
         mFriendInviteButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mFriendSlot : ASAny).invite_friend, flash.display.MovieClip));
         mFriendInviteButton.label.text = Locale.getString("LEADERBOARD_INVITE_FRIEND");
         mFriendInviteButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mFriendPicButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
      }
      
      function showFriendDetails() 
      {
         if(mFriendInfo != null && mFriendInfo.id == mDBFacade.accountId || mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible))
         {
            stopPopupTimeToLiveTask();
            minimizePopup();
         }
         else
         {
            hidePopups();
            if(mFriendInfo == null)
            {
               return;
            }
            mLeaderboard.callStopOnPopupTimeToLiveTask();
            mLeaderboard.currentPopupIndex = mThisSlotIndex;
            if(mFriendInfo.isOnline())
            {
               populateOnlinePopup();
            }
            else
            {
               populateOfflinePopup();
            }
         }
      }
      
      public function populateSlot(param1:FriendInfo) 
      {
         var data= param1;
         mFriendInfo = data;
         mFriendPicButton.root.filters = cast([]);
         if(data != null)
         {
            mFriendInviteButton.visible = false;
            mFriendName.visible = true;
            mFriendLevel.visible = true;
            mFriendOnlineClip.visible = false;
            mJoinOnlineClip.visible = false;
            mFriendOfflineClip.visible = false;
            mMeOnlineClip.visible = false;
            mJoinOnlineFriendButton.root.visible = false;
            mJoinOnlineFriendButton.releaseCallback = null;
            mFriendPicButton.releaseCallback = null;
            mFriendName.text = data.name;
            mFriendName.textColor = PlayerSpecialStatus.getSpecialTextColor(data.name,mFriendName.textColor);
            ASCompat.setProperty((mFriendLevel : ASAny).level, "text", data.trophies);
            if(data.isOnline() && data.isInDungeon())
            {
               mJoinOnlineClip.visible = true;
               mJoinOnlineFriendButton.root.visible = true;
               mJoinOnlineFriendButton.releaseCallback = function()
               {
                  var _loc1_= false;
                  if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
                  {
                     mDBFacade.warningPopup("Warning","Cannot enter dungeon with no weapons equipped.");
                  }
                  else
                  {
                     mDBFacade.metrics.log("JoinFriend",{"friendId":data.id});
                     _loc1_ = false;
                     if(mLeaderboard.currentStateName == "MapTownSubState")
                     {
                        _loc1_ = true;
                     }
                     mDBFacade.mainStateMachine.enterLoadingScreenState((0 : UInt),"",data.id,(0 : UInt),_loc1_);
                  }
               };
            }
            else if(data.isOnline())
            {
               if(data.id != mDBFacade.accountId)
               {
                  mFriendOnlineClip.visible = true;
               }
               else
               {
                  mMeOnlineClip.visible = true;
               }
            }
            else
            {
               mFriendOfflineClip.visible = true;
            }
            if(ASCompat.toBool(cast((mFriendPicButton.root : ASAny).friend_pic, flash.display.DisplayObjectContainer).numChildren))
            {
               (mFriendPicButton.root : ASAny).friend_pic.removeChildAt(0);
            }
            (mFriendPicButton.root : ASAny).friend_pic.addChildAt(data.pic,0);
            ASCompat.setProperty((mFriendPicButton.root : ASAny).default_pic, "visible", false);
            mFriendPicButton.rollOverCallback = showFriendDetails;
            mFriendPicButton.rollOutCallback = function()
            {
               if(mFriendInfo != null && mFriendInfo.id == mDBFacade.accountId)
               {
                  return;
               }
               mPopupTimeToLiveTask = mLogicalWorkComponent.doLater(1,minimizePopup);
            };
         }
         else
         {
            mFriendInviteButton.visible = true;
            mFriendInviteButton.releaseCallback = mFriendPicButton.releaseCallback = mLeaderboard.inviteFriendDR;
            if(ASCompat.toBool(cast((mFriendPicButton.root : ASAny).friend_pic, flash.display.DisplayObjectContainer).numChildren))
            {
               (mFriendPicButton.root : ASAny).friend_pic.removeChildAt(0);
            }
            ASCompat.setProperty((mFriendPicButton.root : ASAny).default_pic, "visible", true);
            mFriendName.visible = false;
            mJoinOnlineFriendButton.root.visible = false;
            mJoinOnlineFriendButton.releaseCallback = null;
            mFriendOnlineClip.visible = false;
            mMeOnlineClip.visible = false;
            mFriendLevel.visible = false;
         }
      }
      
      function populateOnlinePopup() 
      {
         TweenMax.killTweensOf(mOnlinePopup);
         mOnlinePopup.visible = true;
         mOnlinePopup.y = mFriendSlotPosition.y;
         mOnlinePopup.x = mFriendSlotPosition.x;
         ASCompat.setProperty((mOnlinePopup : ASAny).title_label, "mouseEnabled", false);
         ASCompat.setProperty((mOnlinePopup : ASAny).title_label, "text", mFriendInfo.isInDungeon() ? Locale.getString("LEADERBOARD_IN_DUNGEON_TEXT") : Locale.getString("LEADERBOARD_IN_TOWN_TEXT"));
         TweenMax.to(mOnlinePopup,0.2,{"y":mOnlinePopup.y - 50});
         mRemoveFriendButton = mLeaderboard.removeOnlineFriend;
         mRemoveFriendButton.releaseCallback = function()
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
      }
      
      function populateOfflinePopup() 
      {
         TweenMax.killTweensOf(mOfflinePopup);
         mOfflinePopup.visible = true;
         mOfflinePopup.y = mFriendSlotPosition.y;
         mOfflinePopup.x = mFriendSlotPosition.x;
         TweenMax.to(mOfflinePopup,0.2,{"y":mOfflinePopup.y - 60});
         if(mDBFacade.isFacebookPlayer && !mFriendInfo.isDRFriend)
         {
            mLeaderboard.enableMessageFriendButton();
            mMessageFriendButton.releaseCallback = function()
            {
               mDBFacade.facebookController.leaderboardFeedPostToASingleUser(mFriendInfo.facebookId);
            };
         }
         else
         {
            mLeaderboard.disableMessageFriendButton();
         }
         mRemoveFriendButton = mLeaderboard.removeOfflineFriend;
         mRemoveFriendButton.releaseCallback = function()
         {
            mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
         };
      }
      
      public function hidePopups() 
      {
         checkToRefreshLeaderboard();
         if(mOnlinePopup != null)
         {
            mOnlinePopup.visible = false;
         }
         if(mOfflinePopup != null)
         {
            mOfflinePopup.visible = false;
         }
      }
      
      public function minimizePopup(param1:GameClock = null) 
      {
         if(mOnlinePopup.visible)
         {
            TweenMax.killTweensOf(mOnlinePopup);
            TweenMax.to(mOnlinePopup,0.2,{
               "y":mOnlinePopup.y + 50 + 10,
               "visible":false
            });
         }
         if(mOfflinePopup.visible)
         {
            TweenMax.killTweensOf(mOfflinePopup);
            TweenMax.to(mOfflinePopup,0.2,{
               "y":mOfflinePopup.y + 60 + 10,
               "visible":false
            });
         }
         checkToRefreshLeaderboard();
      }
      
      function checkToRefreshLeaderboard() 
      {
         if(mLeaderboard.mustRefreshLeaderboard)
         {
            mLeaderboard.refreshLeaderboard();
         }
      }
      
      public function stopPopupTimeToLiveTask() 
      {
         if(mPopupTimeToLiveTask != null)
         {
            mPopupTimeToLiveTask.destroy();
         }
         mPopupTimeToLiveTask = null;
      }
      
      public function destroy() 
      {
         stopPopupTimeToLiveTask();
         if(mFriendInviteButton != null)
         {
            mFriendInviteButton.destroy();
         }
         mFriendInviteButton = null;
         if(mFriendPicButton != null)
         {
            mFriendPicButton.destroy();
         }
         mFriendPicButton = null;
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
         if(mJoinOnlineFriendButton != null)
         {
            mJoinOnlineFriendButton.destroy();
         }
         mJoinOnlineFriendButton = null;
         mMessageFriendButton = null;
         mDBFacade = null;
         mFriendSlot = null;
         mFriendName = null;
         mFriendOnlineClip = null;
         mJoinOnlineClip = null;
         mFriendOfflineClip = null;
         mMeOnlineClip = null;
         mFriendLevel = null;
         mOnlinePopup = null;
         mOfflinePopup = null;
         mFriendInfo = null;
         mLeaderboard = null;
      }
   }


