package uI.friendManager;

import account.FriendInfo;
import account.PlayerSpecialStatus;
import brain.uI.UIButton;
import brain.uI.UIToggleButton;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import facade.Locale;
import town.TownStateMachine;
import uI.UIPagingPanel;
import flash.display.MovieClip;
import flash.geom.Point;
import org.as3commons.collections.Map;

class FriendPopulater {
	public static inline final TOTAL_IN_ROW = (5 : UInt);

	public static inline final TOTAL_IN_COL = (3 : UInt);

	public static inline final FRIEND_POPULATER_POS_X:Float = 732.9;

	public static inline final FRIEND_POPULATER_POS_Y:Float = 542.15;

	public static inline final SELECTION_OPTIONS_POS_X:Float = 358.7;

	public static inline final SELECTION_OPTIONS_POS_Y:Float = 482.85;

	public static inline final FRIEND_POPULATER_CLASS = "friends_populater";

	public var SelectAllButtonSelected:Bool = false;

	public var NoneButtonSelected:Bool = false;

	var mFriendPopulaterMC:MovieClip;

	var mPagination:UIPagingPanel;

	var mCurrentPage:UInt = 0;

	var mTotalPages:UInt = 0;

	var mDBFacade:DBFacade;

	var mUIFriendManager:UIFriendManager;

	var mTownStateMachine:TownStateMachine;

	var mListOfFriends:Vector<FriendInfo>;

	var mListOfFriendSlots:Vector<MovieClip>;

	var mFriendSelectedToggles:Map;

	var mFriendsSelectedAcrossPages:Map;

	var togglesSelectedArray:Array<ASAny>;

	var mSelectAllButton:UIButton;

	var mSelectNoneButton:UIButton;

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine, listOfFriends:Vector<FriendInfo>, friendManager:UIFriendManager) {
		mDBFacade = dbFacade;
		mTownStateMachine = townStateMachine;
		mListOfFriends = listOfFriends;
		mUIFriendManager = friendManager;
		mListOfFriendSlots = new Vector<MovieClip>();
		mFriendSelectedToggles = new Map();
		mFriendsSelectedAcrossPages = new Map();
		togglesSelectedArray = [];
		var _loc5_ = mTownStateMachine.getTownAsset("friends_populater");
		mFriendPopulaterMC = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
		mFriendPopulaterMC.x = 732.9;
		mFriendPopulaterMC.y = 542.15;
		mUIFriendManager.addToUI(mFriendPopulaterMC);
		createSelectionOptionsUI();
		createPagination();
	}

	function createSelectionOptionsUI() {
		ASCompat.setProperty((mFriendPopulaterMC : ASAny).fm_selection_options, "visible", true);
		ASCompat.setProperty((mFriendPopulaterMC : ASAny).fm_selection_options.txt_select, "text", Locale.getString("SELECT"));
		mSelectAllButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mFriendPopulaterMC : ASAny).fm_selection_options.button_all, flash.display.MovieClip));
		ASCompat.setProperty((mFriendPopulaterMC : ASAny).fm_selection_options.button_all.label, "text", Locale.getString("ALL"));
		mSelectAllButton.releaseCallback = selectAllButtonPressed;
		mSelectNoneButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mFriendPopulaterMC : ASAny).fm_selection_options.button_none, flash.display.MovieClip));
		ASCompat.setProperty((mFriendPopulaterMC : ASAny).fm_selection_options.button_none.label, "text", Locale.getString("NONE"));
		mSelectNoneButton.releaseCallback = selectNoneButtonPressed;
	}

	function createPagination() {
		mTotalPages = (Std.int(1 + Math.ffloor(mListOfFriends.length / (5 * 3))) : UInt);
		mPagination = new UIPagingPanel(mDBFacade, (0 : UInt), ASCompat.dynamicAs((mFriendPopulaterMC : ASAny).pagination_friends, flash.display.MovieClip),
			mTownStateMachine.townSwf.getClass("pagination_button"), setCurrentPage);
		MemoryTracker.track(mPagination, "UIPagingPanel - created in FriendPopulater.createPagination()");
		setCurrentPage((0 : UInt));
	}

	function refreshPagination(page:UInt) {
		mPagination.currentPage = (Std.int(mTotalPages != 0 ? (Std.int(Math.min(mTotalPages - 1, page)) : UInt) : (0 : UInt)) : UInt);
		mPagination.numPages = mTotalPages;
		mPagination.visible = true;
	}

	function setCurrentPage(page:UInt) {
		var _loc2_ = 0;
		mCurrentPage = page;
		refreshPagination(page);
		_loc2_ = 0;
		while (_loc2_ < mListOfFriendSlots.length) {
			mUIFriendManager.removeFromUI(mListOfFriendSlots[_loc2_]);
			_loc2_++;
		}
		mListOfFriendSlots.splice(0, (mListOfFriendSlots.length : UInt));
		mFriendSelectedToggles.clear();
		populateUIOnPage(page);
	}

	function populateFriendSlot(idx:UInt, friend:FriendInfo) {
		var _loc8_ = mTownStateMachine.getTownAsset("friend_slot");
		var _loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc8_, []), MovieClip);
		var _loc7_ = ASCompat.reinterpretAs(mFriendPopulaterMC.getChildByName("slot_" + Std.string(idx)), MovieClip);
		var _loc9_ = new Point(mFriendPopulaterMC.x - 732.9, mFriendPopulaterMC.y - 542.15);
		_loc5_.x = _loc7_.localToGlobal(_loc9_).x - _loc5_.width / 2 - 3;
		_loc5_.y = _loc7_.localToGlobal(_loc9_).y - _loc5_.height / 2 - 5;
		ASCompat.setProperty((_loc5_ : ASAny).friend_name, "text", friend.name);
		ASCompat.setProperty((_loc5_ : ASAny).friend_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(friend.name, (ASCompat.toInt((_loc5_ : ASAny).friend_name.textColor) : UInt)));
		var _loc3_ = true;
		if (mDBFacade.isFacebookPlayer) {
			_loc3_ = false;
		}
		var _loc4_ = friend.clonePic();
		_loc4_.x = -5;
		_loc4_.y = 5;
		if (_loc3_) {
			_loc4_.scaleX = _loc4_.scaleY = 1.05;
			(_loc5_ : ASAny).friend_pic.addChild(_loc4_);
			ASCompat.setProperty((_loc5_ : ASAny).friend_pic.default_pic, "visible", false);
		} else {
			(_loc5_ : ASAny).friend_pic.addChild(_loc4_);
			ASCompat.setProperty((_loc5_ : ASAny).friend_pic.default_pic, "visible", false);
		}
		if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(friend.excludeId) < 0) {
			ASCompat.setProperty((_loc5_ : ASAny).gift, "visible", false);
		} else {
			ASCompat.setProperty((_loc5_ : ASAny).gift, "visible", true);
		}
		ASCompat.setProperty((_loc5_ : ASAny).friend_pic.you_online, "visible", false);
		ASCompat.setProperty((_loc5_ : ASAny).friend_pic.friend_offline, "visible", false);
		ASCompat.setProperty((_loc5_ : ASAny).friend_pic.friend_online, "visible", false);
		ASCompat.setProperty((_loc5_ : ASAny).join, "visible", false);
		if (friend.isOnline()) {
			ASCompat.setProperty((_loc5_ : ASAny).friend_pic.friend_online, "visible", false);
		} else {
			ASCompat.setProperty((_loc5_ : ASAny).friend_pic.friend_offline, "visible", false);
		}
		ASCompat.setProperty((_loc5_ : ASAny).friend_level.level, "text", Std.string(friend.trophies));
		var _loc6_ = mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx);
		mFriendSelectedToggles.add(idx,
			new UIToggleButton(mDBFacade, idx, ASCompat.dynamicAs((_loc5_ : ASAny).friends_toggle, flash.display.MovieClip), _loc6_,
				changeToggleStatusCallback));
		mUIFriendManager.addToUI(_loc5_);
		mListOfFriendSlots.push(_loc5_);
	}

	function changeToggleStatusCallback(idx:UInt, selected:Bool) {
		if (mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx)) {
			mFriendsSelectedAcrossPages.removeKey(mCurrentPage * (5 * 3) + idx);
		} else {
			mFriendsSelectedAcrossPages.add(mCurrentPage * (5 * 3) + idx, selected);
		}
	}

	function populateUIOnPage(pageNum:UInt) {
		mListOfFriendSlots.splice(0, (mListOfFriendSlots.length : UInt));
		var _loc3_ = 0;
		var _loc4_ = (pageNum * (5 * 3) : Int);
		var _loc2_ = (_loc4_ + 5 * 3 : UInt);
		if (_loc2_ > (mListOfFriends.length : UInt)) {
			_loc2_ -= _loc2_ - mListOfFriends.length;
		}
		while ((_loc4_ : UInt) < _loc2_) {
			populateFriendSlot((_loc3_ : UInt), mListOfFriends[_loc4_]);
			_loc4_++;
			_loc3_++;
		}
	}

	public function refreshGiftedOnCurrentPage() {
		var _loc3_:ASAny = null;
		var _loc4_ = 0;
		var _loc2_ = (mCurrentPage * (5 * 3) : Int);
		var _loc1_ = ((mCurrentPage + 1) * (5 * 3) - 1 : Int);
		_loc4_ = _loc2_;
		while (_loc4_ < mListOfFriends.length) {
			if (_loc4_ > _loc1_) {
				break;
			}
			if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc4_].excludeId) < 0) {
				ASCompat.setProperty((mListOfFriendSlots[_loc4_ - _loc2_] : ASAny).gift, "visible", false);
			} else {
				ASCompat.setProperty((mListOfFriendSlots[_loc4_ - _loc2_] : ASAny).gift, "visible", true);
			}
			_loc4_++;
		}
	}

	function selectAllButtonPressed() {
		var _loc8_ = 0;
		var _loc5_:UIToggleButton = null;
		var _loc1_ = 0;
		var _loc4_:FriendInfo = null;
		var _loc6_ = 0;
		var _loc7_:FriendInfo = null;
		SelectAllButtonSelected = true;
		NoneButtonSelected = false;
		var _loc3_ = (mCurrentPage * (5 * 3) : Int);
		var _loc2_ = ((mCurrentPage + 1) * (5 * 3) - 1 : Int);
		_loc8_ = _loc3_;
		while (_loc8_ < _loc2_) {
			_loc5_ = ASCompat.dynamicAs(mFriendSelectedToggles.itemFor(_loc8_ - _loc3_), brain.uI.UIToggleButton);
			if (_loc5_ != null) {
				_loc1_ = (mCurrentPage * (5 * 3) : Int);
				if (_loc1_ <= mListOfFriends.length) {
					if (_loc8_ > mListOfFriends.length) {
						break;
					}
					_loc4_ = mListOfFriends[_loc8_];
					if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(_loc4_.excludeId) < 0) {
						_loc5_.selected = true;
					}
				}
			}
			_loc8_++;
		}
		_loc6_ = _loc3_;
		while (_loc6_ < _loc2_) {
			if (_loc6_ <= mListOfFriends.length - 1) {
				_loc7_ = mListOfFriends[_loc6_];
				if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(_loc7_.excludeId) < 0) {
					mFriendsSelectedAcrossPages.add(_loc6_, true);
				}
			}
			_loc6_++;
		}
	}

	function selectNoneButtonPressed() {
		var _loc1_ = 0;
		var _loc2_:UIToggleButton = null;
		SelectAllButtonSelected = false;
		NoneButtonSelected = true;
		_loc1_ = 0;
		while (_loc1_ < mListOfFriendSlots.length) {
			_loc2_ = ASCompat.dynamicAs(mFriendSelectedToggles.itemFor(_loc1_), brain.uI.UIToggleButton);
			if (_loc2_ != null) {
				_loc2_.selected = false;
			}
			_loc1_++;
		}
		mFriendsSelectedAcrossPages.clear();
	}

	public function getSelectedToggles():Array<ASAny> {
		togglesSelectedArray = mFriendsSelectedAcrossPages.keysToArray();
		return togglesSelectedArray;
	}

	public function destroy() {
		var _loc2_:UIToggleButton = null;
		mListOfFriends = null;
		mListOfFriendSlots.splice(0, (mListOfFriendSlots.length : UInt));
		mListOfFriendSlots = null;
		if (mPagination != null) {
			mPagination.destroy();
			mPagination = null;
		}
		mUIFriendManager.removeFromUI(mFriendPopulaterMC);
		mFriendPopulaterMC = null;
		mDBFacade = null;
		mUIFriendManager = null;
		var _loc1_ = mFriendSelectedToggles.keysToArray();
		var _loc3_:UInt;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc2_ = ASCompat.dynamicAs(mFriendSelectedToggles.itemFor(_loc3_), brain.uI.UIToggleButton);
				_loc2_.destroy();
			}
		mFriendSelectedToggles = null;
		mFriendsSelectedAcrossPages = null;
		togglesSelectedArray = null;
	}
}
