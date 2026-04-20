package uI.friendManager.states
;
   import account.FriendInfo;
   import brain.event.EventComponent;
   import brain.uI.UIButton;
   import brain.jsonRPC.JSONRPCService;
   import distributedObjects.PresenceManager;
   import events.FriendshipEvent;
   import facade.DBFacade;
   import facade.Locale;
   import town.TownStateMachine;
   import uI.friendManager.FriendPopulater;
   import uI.friendManager.UIFriendManager;
   
    class UIPending extends UIFMState
   {
      
      public static inline final BUTTON_DECLINE_POS_X= (800 : UInt);
      
      public static inline final BUTTON_DECLINE_POS_Y= (1000 : UInt);
      
      public static inline final BUTTON_ACCEPT_POS_X= (1075 : UInt);
      
      public static inline final BUTTON_ACCEPT_POS_Y= (1000 : UInt);
      
      public static inline final ACCEPT_REQUEST= (1 : UInt);
      
      public static inline final DECLINE_REQUEST= (2 : UInt);
      
      var mEventComponent:EventComponent;
      
      var mFriendRequestPopulater:FriendPopulater;
      
      var mListOfFriendRequests:Vector<FriendInfo>;
      
      var mDeclineButton:UIButton;
      
      var mAcceptButton:UIButton;
      
      var mPendingFriendRequests:Array<ASAny>;
      
      var mSelectedFriendToIds:Array<ASAny> = [];
      
      var mSelectedFriendRequestIds:Array<ASAny> = [];
      
      public function new(param1:UIFriendManager, param2:DBFacade, param3:TownStateMachine)
      {
         super(param2,param1,param3);
         mListOfFriendRequests = new Vector<FriendInfo>();
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener(UIFriendManager.FRIENDSHIP_MADE,friendshipMadeHandler);
      }
      
      override public function enter() 
      {
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_PENDING"));
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_PENDING"));
         setupUI();
      }
      
      override public function exit() 
      {
         mListOfFriendRequests.splice(0,(mListOfFriendRequests.length : UInt));
         if(mFriendRequestPopulater != null)
         {
            mFriendRequestPopulater.destroy();
            mFriendRequestPopulater = null;
         }
         mDeclineButton = null;
         mAcceptButton = null;
         mUIFriendManager.clearUI();
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mEventComponent.removeListener(UIFriendManager.FRIENDSHIP_MADE);
         mEventComponent.destroy();
      }
      
      function refresh(param1:Array<ASAny>) 
      {
         var _loc3_= 0;
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            _loc3_ = 0;
            while(_loc3_ < mPendingFriendRequests.length)
            {
               if(mPendingFriendRequests[_loc3_].id == _loc2_)
               {
                  mPendingFriendRequests.splice(_loc3_,(1 : UInt));
                  break;
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
         exit();
         enter();
      }
      
      @:isVar public var pendingFriendRequests(never,set):Array<ASAny>;
public function  set_pendingFriendRequests(param1:Array<ASAny>) :Array<ASAny>      {
         mPendingFriendRequests = param1;
         if(mPendingFriendRequests != null && mPendingFriendRequests.length > 0)
         {
            mUIFriendManager.alert = true;
         }
         else
         {
            mUIFriendManager.alert = false;
            mTownStateMachine.leaderboard.alert = false;
         }
return param1;
      }
      
      public function setupUI() 
      {
         var _loc2_:FriendInfo = null;
         pendingFriendRequests = mPendingFriendRequests;
         var _loc1_:ASAny;
         final __ax4_iter_199 = mPendingFriendRequests;
         if (checkNullIteratee(__ax4_iter_199)) for (_tmp_ in __ax4_iter_199)
         {
            _loc1_ = _tmp_;
            _loc2_ = new FriendInfo(mDBFacade,_loc1_);
            mListOfFriendRequests.push(_loc2_);
         }
         mFriendRequestPopulater = new FriendPopulater(mDBFacade,mTownStateMachine,mListOfFriendRequests,mUIFriendManager);
         mDeclineButton = createButton("friend_management_button_grey",Locale.getString("DECLINE"),800,1000,declineButtonCallback);
         mAcceptButton = createButton("friend_management_button",Locale.getString("ACCEPT"),1075,1000,acceptButtonCallback);
      }
      
      function declineButtonCallback() 
      {
         var rpcFunc:ASFunction;
         var idx:UInt;
         mSelectedFriendToIds.splice(0,(mSelectedFriendToIds.length : UInt));
         mSelectedFriendRequestIds.splice(0,(mSelectedFriendRequestIds.length : UInt));
         final __ax4_iter_200 = mFriendRequestPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_200)) for (_tmp_ in __ax4_iter_200)
         {
            idx  = (ASCompat.toInt(_tmp_) : UInt);
            mSelectedFriendToIds.push(mPendingFriendRequests[(idx : Int)].account_id);
            mSelectedFriendRequestIds.push(mPendingFriendRequests[(idx : Int)].id);
         }
         if(mSelectedFriendToIds.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRequestUpdate",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriendRequestIds,mSelectedFriendToIds,2,mDBFacade.validationToken,function(param1:ASAny)
            {
               var _loc2_= 0;
               refresh(mSelectedFriendRequestIds);
               _loc2_ = 0;
               while(_loc2_ < mSelectedFriendToIds.length)
               {
                  mDBFacade.metrics.log("DRFriendDecline",{"friendId":Std.string(mSelectedFriendToIds[_loc2_])});
                  _loc2_ = ASCompat.toInt(_loc2_) + 1;
               }
            });
         }
      }
      
      function acceptButtonCallback() 
      {
         var rpcFunc:ASFunction;
         var fullAcceptList:String;
         var idx:UInt;
         mSelectedFriendToIds.splice(0,(mSelectedFriendToIds.length : UInt));
         mSelectedFriendRequestIds.splice(0,(mSelectedFriendRequestIds.length : UInt));
         fullAcceptList = "[";
         final __ax4_iter_201 = mFriendRequestPopulater.getSelectedToggles();
         if (checkNullIteratee(__ax4_iter_201)) for (_tmp_ in __ax4_iter_201)
         {
            idx  = (ASCompat.toInt(_tmp_) : UInt);
            mSelectedFriendToIds.push(mPendingFriendRequests[(idx : Int)].account_id);
            mSelectedFriendRequestIds.push(mPendingFriendRequests[(idx : Int)].id);
         }
         if(mSelectedFriendToIds.length > 0)
         {
            rpcFunc = JSONRPCService.getFunction("DRFriendRequestUpdate",mDBFacade.rpcRoot + "friendrequests");
            rpcFunc(mDBFacade.accountId,mSelectedFriendRequestIds,mSelectedFriendToIds,1,mDBFacade.validationToken,function(param1:ASAny)
            {
               var _loc2_= 0;
               refresh(mSelectedFriendRequestIds);
               var _loc3_= Vector.ofArray((ASCompat.dynamicAs((cast mSelectedFriendToIds), Array) : Array<UInt>));
               PresenceManager.instance().addFriends(_loc3_);
               mDBFacade.dbAccountInfo.addFriendCallback(param1);
               mTownStateMachine.leaderboard.refreshLeaderboard();
               _loc2_ = 0;
               while(_loc2_ < mSelectedFriendToIds.length)
               {
                  mDBFacade.metrics.log("DRFriendAccept",{"friendId":Std.string(mSelectedFriendToIds[_loc2_])});
                  _loc2_ = ASCompat.toInt(_loc2_) + 1;
               }
            },UIFriendManager.createFriendRPCErrorCallback(mDBFacade,"acceptButton"));
         }
      }
      
      function friendshipMadeHandler(param1:FriendshipEvent) 
      {
         var _loc3_= 0;
         var _loc2_= param1.id;
         _loc3_ = 0;
         while(_loc3_ < mPendingFriendRequests.length)
         {
            if(ASCompat.toNumberField(mPendingFriendRequests[_loc3_], "id") == param1.id)
            {
               mPendingFriendRequests.splice(_loc3_,(1 : UInt));
               break;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
   }


