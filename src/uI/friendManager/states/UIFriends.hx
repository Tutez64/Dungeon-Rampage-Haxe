package uI.friendManager.states;

import account.FriendInfo;
import account.StoreServicesController;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import brain.jsonRPC.JSONRPCService;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import town.TownStateMachine;
import uI.friendManager.FriendPopulater;
import uI.friendManager.UIFriendManager;
import uI.popup.DBUITwoButtonPopup;

class UIFriends extends UIFMState {
	public static inline final BUTTON_REMOVE_POS_X = (800 : UInt);

	public static inline final BUTTON_REMOVE_POS_Y = (1000 : UInt);

	public static inline final BUTTON_GIFT_POS_X = (1075 : UInt);

	public static inline final BUTTON_GIFT_POS_Y = (1000 : UInt);

	var mFriendPopulater:FriendPopulater;

	var mListOfFriends:Vector<FriendInfo>;

	var mRemoveButton:UIButton;

	var mGiftButton:UIButton;

	var mRemoveFriendsPopUp:DBUITwoButtonPopup;

	var mSelectedDRFriends:Array<ASAny> = [];

	public function new(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, uiFriendManager, townStateMachine);
		mListOfFriends = new Vector<FriendInfo>();
	}

	override public function enter() {
		mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_FRIENDS"));
		mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_FRIENDS"));
		setupUI();
	}

	override public function exit() {
		mListOfFriends.splice(0, (mListOfFriends.length : UInt));
		if (mFriendPopulater != null) {
			mFriendPopulater.destroy();
			mFriendPopulater = null;
		}
		if (mRemoveButton != null) {
			mRemoveButton.destroy();
			mRemoveButton = null;
		}
		if (mGiftButton != null) {
			mGiftButton.destroy();
			mGiftButton = null;
		}
		mUIFriendManager.clearUI();
		if (mRemoveFriendsPopUp != null) {
			mRemoveFriendsPopUp.destroy();
			mRemoveFriendsPopUp = null;
		}
	}

	function refresh(list:Array<ASAny>) {
		var _loc3_ = false;
		var _loc4_ = (0 : UInt);
		var _loc2_:UInt;
		if (checkNullIteratee(list))
			for (_tmp_ in list) {
				_loc2_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc3_ = false;
				_loc4_ = (0 : UInt);
				while (_loc4_ < (mTownStateMachine.leaderboard.onlineFriends.length:UInt)) {
					if (mTownStateMachine.leaderboard.onlineFriends[(_loc4_ : Int)].id == _loc2_) {
						mTownStateMachine.leaderboard.onlineFriends.splice((_loc4_ : Int), (1 : UInt));
						_loc3_ = true;
						break;
					}
					_loc4_++;
				}
				if (!_loc3_) {
					_loc4_ = (0 : UInt);
					while (_loc4_ < (mTownStateMachine.leaderboard.offlineFriends.length:UInt)) {
						if (mTownStateMachine.leaderboard.offlineFriends[(_loc4_ : Int)].id == _loc2_) {
							mTownStateMachine.leaderboard.offlineFriends.splice((_loc4_ : Int), (1 : UInt));
							_loc3_ = true;
							break;
						}
						_loc4_++;
					}
				}
			}
		exit();
		enter();
	}

	function setupUI() {
		var _loc3_ = 0;
		var _loc2_ = mTownStateMachine.leaderboard.onlineFriends;
		var _loc1_ = mTownStateMachine.leaderboard.offlineFriends;
		_loc3_ = 0;
		while (_loc3_ < _loc2_.length) {
			if (_loc2_[_loc3_].id != mDBFacade.accountId) {
				mListOfFriends.push(_loc2_[_loc3_]);
			}
			_loc3_++;
		}
		_loc3_ = 0;
		while (_loc3_ < _loc1_.length) {
			mListOfFriends.push(_loc1_[_loc3_]);
			_loc3_++;
		}
		mFriendPopulater = new FriendPopulater(mDBFacade, mTownStateMachine, mListOfFriends, mUIFriendManager);
		mRemoveButton = createButton("friend_management_button_grey", Locale.getString("REMOVE"), 800, 1000, removeFriendsConfirmation);
		mGiftButton = createButton("friend_management_button", Locale.getString("GIFT"), 1075, 1000, giftButtonCallback);
		setupMenuNavigation();
	}

	function setupMenuNavigation() {
		mRemoveButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mGiftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mRemoveButton.isToTheLeftOf(mGiftButton);
		mFriendPopulater.setupMenuNavigation(mUIFriendManager.currentTabButton, mRemoveButton, mGiftButton);
	}

	override public function getFirstNavigationUIObject():UIObject {
		return mFriendPopulater.getFirstNavigationUIObject();
	}

	function removeFriendsConfirmation() {
		mRemoveFriendsPopUp = new DBUITwoButtonPopup(mDBFacade, "REMOVE_FRIEND_POPUP", Locale.getString("REMOVE_FRIEND_POPUP_TITLE"),
			Locale.getString("REMOVE_FRIEND_POPUP_DESC"), Locale.getString("REMOVE_FRIEND_POPUP_CANCEL"), closeRemoveFriendsPopUp,
			Locale.getString("REMOVE_FRIEND_POPUP_CONFIRM"), removeButtonCallback);
		MemoryTracker.track(mRemoveFriendsPopUp, "DBUITwoButtonPopup - created in UIFriends.removeFriendsConfirmation()");
	}

	function closeRemoveFriendsPopUp() {
		if (mRemoveFriendsPopUp != null) {
			mRemoveFriendsPopUp.destroy();
			mRemoveFriendsPopUp = null;
		}
	}

	function removeButtonCallback() {
		var rpcFunc:ASFunction;
		var idx:UInt;
		mSelectedDRFriends.splice(0, (mSelectedDRFriends.length : UInt));
		final __ax4_iter_290 = mFriendPopulater.getSelectedToggles();
		if (checkNullIteratee(__ax4_iter_290))
			for (_tmp_ in __ax4_iter_290) {
				idx = (ASCompat.toInt(_tmp_) : UInt);
				mSelectedDRFriends.push(mListOfFriends[(idx : Int)].id);
			}
		if (mSelectedDRFriends.length > 0) {
			rpcFunc = JSONRPCService.getFunction("DRFriendRemove", mDBFacade.rpcRoot + "friendrequests");
			rpcFunc(mDBFacade.accountId, mSelectedDRFriends, mDBFacade.validationToken, function(param1:ASAny) {
				var _loc2_ = (0 : UInt);
				refresh(mSelectedDRFriends);
				mDBFacade.dbAccountInfo.removeFriendCallback(param1);
				mTownStateMachine.leaderboard.refreshLeaderboard();
				_loc2_ = (0 : UInt);
				while (_loc2_ < (mSelectedDRFriends.length:UInt)) {
					mDBFacade.metrics.log("DRFriendRemove", {"friendId": Std.string(mSelectedDRFriends[(_loc2_ : Int)])});
					_loc2_++;
				}
			});
		}
	}

	function giftButtonCallback() {
		var _loc1_ = false;
		var _loc2_:UInt;
		final __ax4_iter_291 = mFriendPopulater.getSelectedToggles();
		if (checkNullIteratee(__ax4_iter_291))
			for (_tmp_ in __ax4_iter_291) {
				_loc2_ = (ASCompat.toInt(_tmp_) : UInt);
				if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[(_loc2_ : Int)].excludeId) < 0) {
					_loc1_ = true;
				}
			}
		if (_loc1_) {
			StoreServicesController.showGiftPage(mDBFacade, drGiftFlow);
		}
	}

	function drGiftFlow(offerName:String, offerId:UInt) {
		var _loc3_:Array<ASAny> = [];
		var _loc4_:UInt;
		final __ax4_iter_292 = mFriendPopulater.getSelectedToggles();
		if (checkNullIteratee(__ax4_iter_292))
			for (_tmp_ in __ax4_iter_292) {
				_loc4_ = (ASCompat.toInt(_tmp_) : UInt);
				if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[(_loc4_ : Int)].excludeId) < 0) {
					_loc3_.push(_loc4_);
				}
			}
		if (_loc3_.length > 0) {
			sendDRComGift(offerName, offerId, _loc3_);
		}
	}

	function sendDRComGift(offerName:String, offerId:UInt, drFriends:Array<ASAny>) {
		var _loc4_:String = null;
		var _loc5_:String = null;
		var _loc8_:Array<ASAny> = [];
		var _loc7_:Array<ASAny> = [];
		var _loc6_ = Std.string(Date.now().getTime());
		var _loc9_:UInt;
		if (checkNullIteratee(drFriends))
			for (_tmp_ in drFriends) {
				_loc9_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc4_ = Std.string(mListOfFriends[(_loc9_ : Int)].id);
				_loc5_ = "0_" + _loc6_ + "_" + _loc4_;
				_loc7_.push(_loc5_);
				_loc8_.push(_loc4_);
				mDBFacade.metrics.log("DRGiftRequest", {"friendId": _loc4_});
			}
		mDBFacade.dbAccountInfo.giftExcludeIds = mDBFacade.dbAccountInfo.giftExcludeIds.concat(_loc8_);
		mDBFacade.dbAccountInfo.sendGiftData(offerId, _loc7_, _loc8_);
		mFriendPopulater.refreshGiftedOnCurrentPage();
	}
}
