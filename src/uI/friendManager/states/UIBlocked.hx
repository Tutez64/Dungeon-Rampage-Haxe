package uI.friendManager.states
;
   import account.FriendInfo;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.Locale;
   import town.TownStateMachine;
   import uI.friendManager.FriendPopulater;
   import uI.friendManager.UIFriendManager;
   
    class UIBlocked extends UIFMState
   {
      
      public static inline final BUTTON_UNLOCK_POS_X= (960 : UInt);
      
      public static inline final BUTTON_UNLOCK_POS_Y= (1000 : UInt);
      
      var mFriendPopulater:FriendPopulater;
      
      var mListOfBlockedFriends:Vector<FriendInfo>;
      
      var mUnblockButton:UIButton;
      
      var mSelectedFriends:Array<ASAny> = [];
      
      public function new(param1:UIFriendManager, param2:DBFacade, param3:TownStateMachine)
      {
         super(param2,param1,param3);
      }
      
      override public function enter() 
      {
         Logger.debug("Enterred Blocked State");
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_BLOCKED"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_BLOCKED"));
         setupUI();
      }
      
      override public function exit() 
      {
         Logger.debug("Exiting Blocked State");
         mListOfBlockedFriends = null;
         if(mFriendPopulater != null)
         {
            mFriendPopulater.destroy();
            mFriendPopulater = null;
         }
         mUnblockButton = null;
         mUIFriendManager.clearUI();
      }
      
      function refresh(param1:Array<ASAny>) 
      {
         var _loc3_= 0;
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            _loc3_ = 0;
            while(_loc3_ < mListOfBlockedFriends.length)
            {
               if(mListOfBlockedFriends[_loc3_].id == ASCompat.toNumber(_loc2_))
               {
                  mListOfBlockedFriends.splice(_loc3_,(1 : UInt));
                  break;
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
         exit();
         enter();
      }
      
      function setupUI() 
      {
         mListOfBlockedFriends = mDBFacade.dbAccountInfo.ignoredFriends;
         mFriendPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfBlockedFriends,mUIFriendManager);
         mUnblockButton = createButton("friend_management_button",Locale.getString("UNBLOCK"),960,1000,unblockButtonCallback);
      }
      
      function unblockButtonCallback() 
      {
         var rpcFunc:ASFunction;
         var idx:UInt;
         Logger.debug("unblock button clicked");
         mSelectedFriends.splice(0,(mSelectedFriends.length : UInt));
         final __ax4_iter_186 = mFriendPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_186)) for (_tmp_ in __ax4_iter_186)
         {
            idx  = (ASCompat.toInt(_tmp_) : UInt);
            mSelectedFriends.push(mListOfBlockedFriends[(idx : Int)].id);
         }
         if(mSelectedFriends.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("UnblockFriend",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriends,mDBFacade.validationToken,function(param1:ASAny)
            {
               Logger.debug("friends unblocked: ");
               refresh(mSelectedFriends);
               mDBFacade.dbAccountInfo.refreshFriendData(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
            });
         }
      }
   }


