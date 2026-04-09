package town
;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.Locale;
   import uI.friendManager.UIFriendManager;
   
    class SocialSubState extends TownSubState
   {
      
      public static inline final NAME= "FriendTownSubState";
      
      var mEventComponent:EventComponent;
      
      var mUIFriendManager:UIFriendManager;
      
      var mTabCategory:UInt = 0;
      
      var mPendingFriendRequest:Bool = false;
      
      var mAcknowledgedPendingFriendRequest:Bool = false;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"FriendTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function enterState() 
      {
         super.enterState();
         if(mPendingFriendRequest && !mAcknowledgedPendingFriendRequest)
         {
            mAcknowledgedPendingFriendRequest = true;
         }
         if(mUIFriendManager != null)
         {
            mUIFriendManager.init(mTabCategory);
            mUIFriendManager.animateEntry();
         }
         mTownStateMachine.townHeader.title = Locale.getString("FM_HEADER");
         mTownStateMachine.townHeader.showCloseButton(true);
         checkForFriendMessages();
      }
      
      public function setTabCategory(param1:UInt) 
      {
         mTabCategory = param1;
      }
      
      override public function exitState() 
      {
         super.exitState();
         if(mUIFriendManager != null)
         {
            mUIFriendManager.cleanUp();
         }
      }
      
      override public function destroy() 
      {
         super.destroy();
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mUIFriendManager != null)
         {
            mUIFriendManager.destroy();
            mUIFriendManager = null;
         }
      }
      
      override function setupState() 
      {
         super.setupState();
         mUIFriendManager = new UIFriendManager(mDBFacade,mTownStateMachine,mRootMovieClip);
         setTabCategory((1 : UInt));
         checkForFriendMessages();
      }
      
      function checkForFriendMessages() 
      {
         var rpcFunc= JSONRPCService.getFunction("DRFriendRequestPending",mDBFacade.rpcRoot + "friendrequests");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            var pendingRequests:ASAny = param1;
            if(ASCompat.toBool(pendingRequests))
            {
               mPendingFriendRequest = true;
               mUIFriendManager.setPendingList(ASCompat.dynamicAs(pendingRequests , Array));
               setTabCategory((2 : UInt));
               if(mTownStateMachine.leaderboard != null && mTownStateMachine.leaderboard.initialized)
               {
                  mTownStateMachine.leaderboard.alert = mPendingFriendRequest && !mAcknowledgedPendingFriendRequest;
               }
               else
               {
                  Logger.debug("leaderboard not set or not initialized yet: use an event listener");
                  if(mEventComponent != null)
                  {
                     mEventComponent.addListener("LEADERBOARD_INITIALIZED_EVENT",ASCompat.asFunction((function():ASAny
                     {
                        var setPending:ASFunction;
                        return setPending = function()
                        {
                           mTownStateMachine.leaderboard.alert = mPendingFriendRequest && !mAcknowledgedPendingFriendRequest;
                        };
                     })()));
                  }
               }
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,rpcSuccessCallback);
      }
   }


