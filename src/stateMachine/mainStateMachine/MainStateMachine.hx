package stateMachine.mainStateMachine;

import brain.logger.Logger;
import brain.stateMachine.StateMachine;
import brain.utils.MemoryTracker;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import uI.leaderboard.UILeaderboard;

class MainStateMachine extends StateMachine {
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

	public function new(dbFacade:DBFacade) {
		super();
		mDBFacade = dbFacade;
		mLoadingState = new LoadingState(dbFacade);
		MemoryTracker.track(mLoadingState, "LoadingState - created in MainStateMachine.MainStateMachine()");
		mReloadTownState = new ReloadTownState(dbFacade, enterTownState);
		MemoryTracker.track(mReloadTownState, "ReloadTownState - created in MainStateMachine.MainStateMachine()");
		mLoadingScreenState = new LoadingScreenState(dbFacade, enterRunState);
		MemoryTracker.track(mLoadingScreenState, "LoadingScreenState - created in MainStateMachine.MainStateMachine()");
		mTownState = new TownState(dbFacade);
		MemoryTracker.track(mTownState, "TownState - created in MainStateMachine.MainStateMachine()");
		mRunState = new RunState(dbFacade, enterReloadTownState);
		MemoryTracker.track(mRunState, "RunState - created in MainStateMachine.MainStateMachine()");
		mSocketErrorState = new SocketErrorState(dbFacade);
		MemoryTracker.track(mSocketErrorState, "SocketErrorState - created in MainStateMachine.MainStateMachine()");
	}

	public function enterLoadingState() {
		this.transitionToState(mLoadingState);
	}

	public function enterLoadingScreenState(mapNodeID:UInt = (0 : UInt), nodeType:String = "", friendID:UInt = (0 : UInt), mapID:UInt = (0 : UInt),
			jumpToMap:Bool = false, makeprivate:Bool = false) {
		if (mapNodeID != 0) {
			mLoadingScreenState.mapNodeID = mapNodeID;
		} else if (friendID != 0) {
			mLoadingScreenState.friendID = friendID;
		} else if (mapID != 0) {
			mLoadingScreenState.mapID = mapID;
		}
		mLoadingScreenState.friendsOnly = makeprivate;
		mLoadingScreenState.nodeType = nodeType;
		mLoadingScreenState.jumpToMapState = jumpToMap;
		this.transitionToState(mLoadingScreenState);
	}

	public function start() {
		if (mDBFacade.dbAccountInfo.activeAvatarInfo == null) {
			Logger.error("Account has invalid active avatar: accountId: " + Std.string(mDBFacade.dbAccountInfo.id) + " activeAvatar: "
				+ Std.string(mDBFacade.dbAccountInfo.activeAvatarId));
			return;
		}
		var _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length > 0;
		if (_loc1_ && !mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam()) {
			this.enterLoadingScreenState(DBGlobal.TUTORIAL_MAP_NODE_ID, "", (0 : UInt), (0 : UInt), true);
		} else {
			this.enterTownState();
		}
	}

	public function enterTownInventoryState(type:UInt = (0 : UInt), offerId:UInt = (0 : UInt), showEquipOption:Bool = false) {
		if (this.currentStateName == mTownState.name) {
			mTownState.townStateMachine.enterInventoryState(false, "", type, offerId, showEquipOption);
		} else {
			Logger.error("Trying to enter inventory state while not in the town state.");
		}
	}

	public function enterTownState(mJumpToMapState:Bool = false) {
		if (mJumpToMapState) {
			mTownState.jumpToMapState = mJumpToMapState;
		}
		this.transitionToState(mTownState);
	}

	public function enterReloadTownState(mJumpToMapState:Bool = false) {
		if (mTownState != null && mJumpToMapState) {
			mTownState.jumpToMapState = mJumpToMapState;
		}
		this.transitionToState(mReloadTownState);
	}

	public function enterRunState() {
		mDBFacade.mainStateMachine.markHasHeroLeveledUp();
		this.transitionToState(mRunState);
	}

	@:isVar public var leaderboard(get, never):UILeaderboard;

	public function get_leaderboard():UILeaderboard {
		return mTownState.leaderboard;
	}

	public function enterSocketErrorState(errorCode:UInt, errorText:String = "") {
		this.transitionToState(mSocketErrorState);
		mSocketErrorState.enterReason(errorCode, errorText);
	}

	public function markHasHeroLeveledUp():Bool {
		var _loc1_ = false;
		if (mLastHeroId != 0
			&& mLastHeroId == mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType
			&& mLastHeroLevel != 0
			&& mLastHeroLevel < mDBFacade.dbAccountInfo.activeAvatarInfo.level) {
			_loc1_ = true;
		}
		mLastHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType;
		mLastHeroLevel = mDBFacade.dbAccountInfo.activeAvatarInfo.level;
		return _loc1_;
	}

	@:isVar public var showedHeroUpsellPopup(get, set):Bool;

	public function set_showedHeroUpsellPopup(value:Bool):Bool {
		return mShowedHeroUpsellPopup = value;
	}

	function get_showedHeroUpsellPopup():Bool {
		return mShowedHeroUpsellPopup;
	}

	@:isVar public var showedInvitePopup(get, set):Bool;

	public function set_showedInvitePopup(value:Bool):Bool {
		return mShowedInvitePopup = value;
	}

	function get_showedInvitePopup():Bool {
		return mShowedInvitePopup;
	}

	@:isVar public var showedRewardPopup(get, set):Bool;

	public function set_showedRewardPopup(value:Bool):Bool {
		return mShowedRewardPopup = value;
	}

	function get_showedRewardPopup():Bool {
		return mShowedRewardPopup;
	}
}
