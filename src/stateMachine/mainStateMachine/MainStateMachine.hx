package stateMachine.mainStateMachine
;
   import brain.logger.Logger;
   import brain.stateMachine.StateMachine;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import uI.leaderboard.UILeaderboard;
   
    class MainStateMachine extends StateMachine
   {
      
      var mLoadingState:LoadingState;
      
      var mReloadTownState:ReloadTownState;
      
      var mLoadingScreenState:LoadingScreenState;
      
      var mTownState:TownState;
      
      var mRunState:RunState;
      
      var mSocketErrorState:SocketErrorState;
      
      var mDBFacade:DBFacade;
      
      var mLastHeroId:UInt = 0;
      
      var mLastHeroLevel:UInt = 0;
      
      var mShowedInvitePopup:Bool = false;
      
      var mShowedHeroUpsellPopup:Bool = false;
      
      var mShowedRewardPopup:Bool = false;
      
      public function new(param1:DBFacade)
      {
         super();
         mDBFacade = param1;
         mLoadingState = new LoadingState(param1);
         MemoryTracker.track(mLoadingState,"LoadingState - created in MainStateMachine.MainStateMachine()");
         mReloadTownState = new ReloadTownState(param1,enterTownState);
         MemoryTracker.track(mReloadTownState,"ReloadTownState - created in MainStateMachine.MainStateMachine()");
         mLoadingScreenState = new LoadingScreenState(param1,enterRunState);
         MemoryTracker.track(mLoadingScreenState,"LoadingScreenState - created in MainStateMachine.MainStateMachine()");
         mTownState = new TownState(param1);
         MemoryTracker.track(mTownState,"TownState - created in MainStateMachine.MainStateMachine()");
         mRunState = new RunState(param1,enterReloadTownState);
         MemoryTracker.track(mRunState,"RunState - created in MainStateMachine.MainStateMachine()");
         mSocketErrorState = new SocketErrorState(param1);
         MemoryTracker.track(mSocketErrorState,"SocketErrorState - created in MainStateMachine.MainStateMachine()");
      }
      
      public function enterLoadingState() 
      {
         this.transitionToState(mLoadingState);
      }
      
      public function enterLoadingScreenState(param1:UInt = (0 : UInt), param2:String = "", param3:UInt = (0 : UInt), param4:UInt = (0 : UInt), param5:Bool = false, param6:Bool = false) 
      {
         if(param1 != 0)
         {
            mLoadingScreenState.mapNodeID = param1;
         }
         else if(param3 != 0)
         {
            mLoadingScreenState.friendID = param3;
         }
         else if(param4 != 0)
         {
            mLoadingScreenState.mapID = param4;
         }
         mLoadingScreenState.friendsOnly = param6;
         mLoadingScreenState.nodeType = param2;
         mLoadingScreenState.jumpToMapState = param5;
         this.transitionToState(mLoadingScreenState);
      }
      
      public function start() 
      {
         if(mDBFacade.dbAccountInfo.activeAvatarInfo == null)
         {
            Logger.error("Account has invalid active avatar: accountId: " + Std.string(mDBFacade.dbAccountInfo.id) + " activeAvatar: " + Std.string(mDBFacade.dbAccountInfo.activeAvatarId));
            return;
         }
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length > 0;
         if(_loc1_ && !mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
         {
            this.enterLoadingScreenState(DBGlobal.TUTORIAL_MAP_NODE_ID,"",(0 : UInt),(0 : UInt),true);
         }
         else
         {
            this.enterTownState();
         }
      }
      
      public function enterTownInventoryState(param1:UInt = (0 : UInt), param2:UInt = (0 : UInt), param3:Bool = false) 
      {
         if(this.currentStateName == mTownState.name)
         {
            mTownState.townStateMachine.enterInventoryState(false,"",param1,param2,param3);
         }
         else
         {
            Logger.error("Trying to enter inventory state while not in the town state.");
         }
      }
      
      public function enterTownState(param1:Bool = false) 
      {
         if(param1)
         {
            mTownState.jumpToMapState = param1;
         }
         this.transitionToState(mTownState);
      }
      
      public function enterReloadTownState(param1:Bool = false) 
      {
         if(mTownState != null && param1)
         {
            mTownState.jumpToMapState = param1;
         }
         this.transitionToState(mReloadTownState);
      }
      
      public function enterRunState() 
      {
         mDBFacade.mainStateMachine.markHasHeroLeveledUp();
         this.transitionToState(mRunState);
      }
      
      @:isVar public var leaderboard(get,never):UILeaderboard;
public function  get_leaderboard() : UILeaderboard
      {
         return mTownState.leaderboard;
      }
      
      public function enterSocketErrorState(param1:UInt, param2:String = "") 
      {
         this.transitionToState(mSocketErrorState);
         mSocketErrorState.enterReason(param1,param2);
      }
      
      public function markHasHeroLeveledUp() : Bool
      {
         var _loc1_= false;
         if(mLastHeroId != 0 && mLastHeroId == mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType && mLastHeroLevel != 0 && mLastHeroLevel < mDBFacade.dbAccountInfo.activeAvatarInfo.level)
         {
            _loc1_ = true;
         }
         mLastHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType;
         mLastHeroLevel = mDBFacade.dbAccountInfo.activeAvatarInfo.level;
         return _loc1_;
      }
      
            
      @:isVar public var showedHeroUpsellPopup(get,set):Bool;
public function  set_showedHeroUpsellPopup(param1:Bool) :Bool      {
         return mShowedHeroUpsellPopup = param1;
      }
function  get_showedHeroUpsellPopup() : Bool
      {
         return mShowedHeroUpsellPopup;
      }
      
            
      @:isVar public var showedInvitePopup(get,set):Bool;
public function  set_showedInvitePopup(param1:Bool) :Bool      {
         return mShowedInvitePopup = param1;
      }
function  get_showedInvitePopup() : Bool
      {
         return mShowedInvitePopup;
      }
      
            
      @:isVar public var showedRewardPopup(get,set):Bool;
public function  set_showedRewardPopup(param1:Bool) :Bool      {
         return mShowedRewardPopup = param1;
      }
function  get_showedRewardPopup() : Bool
      {
         return mShowedRewardPopup;
      }
   }


