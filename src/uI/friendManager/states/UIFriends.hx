package uI.friendManager.states
;
   import account.FriendInfo;
   import account.StoreServicesController;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.Locale;
   import town.TownStateMachine;
   import uI.DBUIOneButtonPopup;
   import uI.DBUITwoButtonPopup;
   import uI.friendManager.FriendPopulater;
   import uI.friendManager.UIFriendManager;
   
    class UIFriends extends UIFMState
   {
      
      public static inline final BUTTON_REMOVE_POS_X= (800 : UInt);
      
      public static inline final BUTTON_REMOVE_POS_Y= (1000 : UInt);
      
      public static inline final BUTTON_GIFT_POS_X= (1075 : UInt);
      
      public static inline final BUTTON_GIFT_POS_Y= (1000 : UInt);
      
      var mFriendPopulater:FriendPopulater;
      
      var mListOfFriends:Vector<FriendInfo>;
      
      var mRemoveButton:UIButton;
      
      var mGiftButton:UIButton;
      
      var mRemoveFriendsPopUp:DBUITwoButtonPopup;
      
      var mSelectedDRFriends:Array<ASAny> = [];
      
      var mSelectedFBFriends:Array<ASAny> = [];
      
      var mSelectedKGFriends:Array<ASAny> = [];
      
      var mFBRemoveFriendPopup:DBUIOneButtonPopup;
      
      public function new(param1:UIFriendManager, param2:DBFacade, param3:TownStateMachine)
      {
         super(param2,param1,param3);
         mListOfFriends = new Vector<FriendInfo>();
      }
      
      override public function enter() 
      {
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_FRIENDS"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_FRIENDS"));
         setupUI();
      }
      
      override public function exit() 
      {
         mListOfFriends.splice(0,(mListOfFriends.length : UInt));
         if(mFriendPopulater != null)
         {
            mFriendPopulater.destroy();
            mFriendPopulater = null;
         }
         if(mRemoveButton != null)
         {
            mRemoveButton.destroy();
            mRemoveButton = null;
         }
         if(mGiftButton != null)
         {
            mGiftButton.destroy();
            mGiftButton = null;
         }
         mUIFriendManager.clearUI();
         if(mRemoveFriendsPopUp != null)
         {
            mRemoveFriendsPopUp.destroy();
            mRemoveFriendsPopUp = null;
         }
      }
      
      function refresh(param1:Array<ASAny>) 
      {
         var _loc3_= false;
         var _loc4_= 0;
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            _loc3_ = false;
            _loc4_ = 0;
            while(_loc4_ < mTownStateMachine.leaderboard.onlineFriends.length)
            {
               if(mTownStateMachine.leaderboard.onlineFriends[_loc4_].id == ASCompat.toNumber(_loc2_))
               {
                  mTownStateMachine.leaderboard.onlineFriends.splice(_loc4_,(1 : UInt));
                  _loc3_ = true;
                  break;
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
            if(!_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < mTownStateMachine.leaderboard.offlineFriends.length)
               {
                  if(mTownStateMachine.leaderboard.offlineFriends[_loc4_].id == ASCompat.toNumber(_loc2_))
                  {
                     mTownStateMachine.leaderboard.offlineFriends.splice(_loc4_,(1 : UInt));
                     _loc3_ = true;
                     break;
                  }
                  _loc4_ = ASCompat.toInt(_loc4_) + 1;
               }
            }
         }
         exit();
         enter();
      }
      
      function setupUI() 
      {
         var _loc3_= 0;
         var _loc2_= mTownStateMachine.leaderboard.onlineFriends;
         var _loc1_= mTownStateMachine.leaderboard.offlineFriends;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].id != mDBFacade.accountId)
            {
               mListOfFriends.push(_loc2_[_loc3_]);
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc1_.length)
         {
            mListOfFriends.push(_loc1_[_loc3_]);
            _loc3_++;
         }
         mFriendPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfFriends,mUIFriendManager);
         mRemoveButton = createButton("friend_management_button_grey",Locale.getString("REMOVE"),800,1000,removeFriendsConfirmation);
         mGiftButton = createButton("friend_management_button",Locale.getString("GIFT"),1075,1000,giftButtonCallback);
      }
      
      function removeFriendsConfirmation() 
      {
         mRemoveFriendsPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("REMOVE_FRIEND_POPUP_DESC"),Locale.getString("REMOVE_FRIEND_POPUP_CANCEL"),closeRemoveFriendsPopUp,Locale.getString("REMOVE_FRIEND_POPUP_CONFIRM"),removeButtonCallback,true,null);
         MemoryTracker.track(mRemoveFriendsPopUp,"DBUITwoButtonPopup - created in UIFriends.removeFriendsConfirmation()");
      }
      
      function closeRemoveFriendsPopUp() 
      {
         if(mRemoveFriendsPopUp != null)
         {
            mRemoveFriendsPopUp.destroy();
            mRemoveFriendsPopUp = null;
         }
      }
      
      function removeButtonCallback() 
      {
         var rpcFunc:ASFunction;
         var idx:UInt;
         mSelectedDRFriends.splice(0,(mSelectedDRFriends.length : UInt));
         mSelectedFBFriends.splice(0,(mSelectedFBFriends.length : UInt));
         mSelectedKGFriends.splice(0,(mSelectedKGFriends.length : UInt));
         final __ax4_iter_178 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_178)) for (_tmp_ in __ax4_iter_178)
         {
            idx  = (ASCompat.toInt(_tmp_) : UInt);
            if(mListOfFriends[(idx : Int)].isDRFriend)
            {
               mSelectedDRFriends.push(mListOfFriends[(idx : Int)].id);
            }
            else if(mListOfFriends[(idx : Int)].facebookId != null && mListOfFriends[(idx : Int)].facebookId != "")
            {
               mSelectedFBFriends.push(mListOfFriends[(idx : Int)].id);
            }
            else if(mListOfFriends[(idx : Int)].kongregateId != null && mListOfFriends[(idx : Int)].kongregateId != "")
            {
               mSelectedKGFriends.push(mListOfFriends[(idx : Int)].id);
            }
         }
         if(mSelectedDRFriends.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRemove",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedDRFriends,mDBFacade.validationToken,function(param1:ASAny)
            {
               var _loc2_= 0;
               refresh(mSelectedDRFriends);
               mDBFacade.dbAccountInfo.removeFriendCallback(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
               _loc2_ = 0;
               while(_loc2_ < mSelectedDRFriends.length)
               {
                  mDBFacade.metrics.log("DRFriendRemove",{"friendId":Std.string(mSelectedDRFriends[_loc2_])});
                  _loc2_ = ASCompat.toInt(_loc2_) + 1;
               }
            });
         }
         if(mSelectedFBFriends.length > 0)
         {
            mFBRemoveFriendPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("LEADERBOARD_FB_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_FB_REMOVE_FRIEND_POPUP_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(mFBRemoveFriendPopup,"DBUIOneButtonPopup - created in UIFriends.removeButtonCallback()");
         }
         else if(mSelectedKGFriends.length > 0)
         {
            mFBRemoveFriendPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("LEADERBOARD_KG_REMOVE_FRIEND_POPUP_TITLE"),Locale.getString("LEADERBOARD_KG_REMOVE_FRIEND_POPUP_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(mFBRemoveFriendPopup,"DBUIOneButtonPopup - created in UIFriends.removeButtonCallback()");
         }
      }
      
      function giftButtonCallback() 
      {
         var newFriendsFound:Bool;
         var idx:UInt;
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mGiftButton.releaseCallback = function()
            {
               mDBFacade.errorPopup("GIFTING CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            };
            return;
         }
         newFriendsFound = false;
         final __ax4_iter_179 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_179)) for (_tmp_ in __ax4_iter_179)
         {
            idx  = (ASCompat.toInt(_tmp_) : UInt);
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[(idx : Int)].excludeId) < 0)
            {
               newFriendsFound = true;
            }
         }
         if(newFriendsFound)
         {
            StoreServicesController.showGiftPage(mDBFacade,sendGifts);
         }
      }
      
      function sendGifts(param1:String, param2:UInt) 
      {
         trace("sendGifts");
         if(mDBFacade.isFacebookPlayer)
         {
            trace("  isFacebookPlayer");
            fbGiftFlow(param1,param2);
         }
         else if(mDBFacade.isDRPlayer)
         {
            trace("  isDRPlayer");
            if(ASCompat.stringAsBool(mDBFacade.facebookController.accessToken))
            {
               fbGiftFlow(param1,param2);
               trace("    fbGiftFlow");
            }
            else
            {
               drGiftFlow(param1,param2);
               trace("    drGiftFlow");
            }
         }
         else if(mDBFacade.isKongregatePlayer)
         {
            trace("  isKongregatePlayer");
            kongGiftFlow(param1,param2);
         }
         else
         {
            trace("  isNotPlayer");
            Logger.warn("What kind of player are you??? ");
         }
      }
      
      function fbGiftFlow(param1:String, param2:UInt) 
      {
         trace("fbGiftFlow");
         var _loc3_:Array<ASAny> = [];
         var _loc4_:Array<ASAny> = [];
         var _loc5_:ASAny;
         final __ax4_iter_180 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_180)) for (_tmp_ in __ax4_iter_180)
         {
            _loc5_ = _tmp_;
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[ASCompat.toInt(_loc5_)].excludeId) >= 0)
            {
               trace("  giftExcludeIds");
            }
            else if(mListOfFriends[ASCompat.toInt(_loc5_)].isDRFriend)
            {
               _loc4_.push(_loc5_);
               trace("  isDRFriend");
            }
            else
            {
               _loc3_.push(_loc5_);
               trace("  isFBFriend");
            }
         }
         if(_loc3_.length > 0)
         {
            sendFacebookGift(param1,param2,_loc3_);
            trace("  sendFacebookGift");
         }
         if(_loc4_.length > 0)
         {
            sendDRComGift(param1,param2,_loc4_);
            trace("  sendDRGift");
         }
      }
      
      function drGiftFlow(param1:String, param2:UInt) 
      {
         var _loc3_:Array<ASAny> = [];
         var _loc4_:ASAny;
         final __ax4_iter_181 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_181)) for (_tmp_ in __ax4_iter_181)
         {
            _loc4_ = _tmp_;
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[ASCompat.toInt(_loc4_)].excludeId) < 0)
            {
               _loc3_.push(_loc4_);
            }
         }
         if(_loc3_.length > 0)
         {
            sendDRComGift(param1,param2,_loc3_);
         }
      }
      
      function kongGiftFlow(param1:String, param2:UInt) 
      {
         var _loc4_:Array<ASAny> = [];
         var _loc3_:Array<ASAny> = [];
         var _loc5_:ASAny;
         final __ax4_iter_182 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_182)) for (_tmp_ in __ax4_iter_182)
         {
            _loc5_ = _tmp_;
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[ASCompat.toInt(_loc5_)].excludeId) < 0)
            {
               if(mListOfFriends[ASCompat.toInt(_loc5_)].isDRFriend)
               {
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc4_.push(_loc5_);
               }
            }
         }
         if(_loc4_.length > 0)
         {
            sendKongregateGift(param1,param2,_loc4_);
         }
         if(_loc3_.length > 0)
         {
            sendDRComGift(param1,param2,_loc3_);
         }
      }
      
      function sendFacebookGift(param1:String, param2:UInt, param3:Array<ASAny>) 
      {
         var _loc4_:Array<ASAny> = [];
         var _loc5_:ASAny;
         if (checkNullIteratee(param3)) for (_tmp_ in param3)
         {
            _loc5_ = _tmp_;
            _loc4_.push(mListOfFriends[ASCompat.toInt(_loc5_)].facebookId);
         }
         mDBFacade.facebookController.sendGiftRequests(param1,param2,_loc4_.toString());
         mDBFacade.dbAccountInfo.giftExcludeIds = mDBFacade.dbAccountInfo.giftExcludeIds.concat(_loc4_);
         mFriendPopulater.refreshGiftedOnCurrentPage();
      }
      
      function sendDRComGift(param1:String, param2:UInt, param3:Array<ASAny>) 
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc8_:Array<ASAny> = [];
         var _loc7_:Array<ASAny> = [];
         var _loc6_= Std.string(Date.now().getTime());
         var _loc9_:ASAny;
         if (checkNullIteratee(param3)) for (_tmp_ in param3)
         {
            _loc9_ = _tmp_;
            _loc4_ = Std.string(mListOfFriends[ASCompat.toInt(_loc9_)].id);
            _loc5_ = "0_" + _loc6_ + "_" + _loc4_;
            _loc7_.push(_loc5_);
            _loc8_.push(_loc4_);
            mDBFacade.metrics.log("DRGiftRequest",{"friendId":_loc4_});
         }
         mDBFacade.dbAccountInfo.giftExcludeIds = mDBFacade.dbAccountInfo.giftExcludeIds.concat(_loc8_);
         mDBFacade.dbAccountInfo.sendGiftData(param2,_loc7_,_loc8_);
         mFriendPopulater.refreshGiftedOnCurrentPage();
      }
      
      function sendKongregateGift(param1:String, param2:UInt, param3:Array<ASAny>) 
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc8_:Array<ASAny> = [];
         var _loc7_:Array<ASAny> = [];
         var _loc6_= Std.string(Date.now().getTime());
         var _loc9_:ASAny;
         if (checkNullIteratee(param3)) for (_tmp_ in param3)
         {
            _loc9_ = _tmp_;
            _loc4_ = mListOfFriends[ASCompat.toInt(_loc9_)].kongregateId.toString();
            _loc5_ = "0_" + _loc6_ + "_" + _loc4_;
            _loc7_.push(_loc5_);
            _loc8_.push(_loc4_);
            mDBFacade.metrics.log("KGGiftRequest",{"friendId":_loc4_});
         }
         mDBFacade.dbAccountInfo.giftExcludeIds = mDBFacade.dbAccountInfo.giftExcludeIds.concat(_loc8_);
         mDBFacade.dbAccountInfo.sendGiftData(param2,_loc7_,_loc8_);
         mFriendPopulater.refreshGiftedOnCurrentPage();
      }
   }


