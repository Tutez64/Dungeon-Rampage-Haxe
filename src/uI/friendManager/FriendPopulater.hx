package uI.friendManager;

import account.FriendInfo;
import account.PlayerSpecialStatus;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIToggleButton;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import collections.Map;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import town.TownStateMachine;
import uI.portrait.PlayerPortraits;
import uI.UIPagingPanel;
import flash.display.MovieClip;
import flash.geom.Point;

class FriendPopulater {
	public static inline final TOTAL_IN_ROW = (5 : UInt);

	public static inline final TOTAL_IN_COL = (3 : UInt);

	public static inline final FRIEND_POPULATER_POS_X:Float = 732.9;

	public static inline final FRIEND_POPULATER_POS_Y:Float = 542.15;

	public static inline final SELECTION_OPTIONS_POS_X:Float = 358.7;

	public static inline final SELECTION_OPTIONS_POS_Y:Float = 482.85;

	public static inline final FRIEND_POPULATER_CLASS = "friends_populater";

	var mPortraits:PlayerPortraits = new PlayerPortraits();

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

	var mUIObjectAboveFriendList:UIObject;

	var mUIObjectBelowFriendListLeft:UIObject;

	var mUIObjectBelowFriendListRight:UIObject;

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
		mFriendPopulaterMC = ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
		mFriendPopulaterMC.x = 732.9;
		mFriendPopulaterMC.y = 542.15;
		mUIFriendManager.addToUI(mFriendPopulaterMC);
		createSelectionOptionsUI();
		createPagination();
	}

	function createSelectionOptionsUI() {
		ASCompat.setProperty((mFriendPopulaterMC : ASAny).fm_selection_options, "visible", true);
		Locale.setText(ASCompat.coerce((mFriendPopulaterMC : ASAny).fm_selection_options.txt_select, flash.text.TextField), "SELECT");
		mSelectAllButton = new UIButton(mDBFacade, ASCompat.coerce((mFriendPopulaterMC : ASAny).fm_selection_options.button_all, flash.display.MovieClip));
		Locale.setText(ASCompat.coerce((mFriendPopulaterMC : ASAny).fm_selection_options.button_all.label, flash.text.TextField), "ALL");
		mSelectAllButton.releaseCallback = selectAllButtonPressed;
		mSelectAllButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mSelectNoneButton = new UIButton(mDBFacade, ASCompat.coerce((mFriendPopulaterMC : ASAny).fm_selection_options.button_none, flash.display.MovieClip));
		Locale.setText(ASCompat.coerce((mFriendPopulaterMC : ASAny).fm_selection_options.button_none.label, flash.text.TextField), "NONE");
		mSelectNoneButton.releaseCallback = selectNoneButtonPressed;
		mSelectNoneButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
	}

	function createPagination() {
		mTotalPages = (ASCompat.floatToInt(Math.max(1, Math.fceil(mListOfFriends.length / (5 * 3)))) : UInt);
		mPagination = new UIPagingPanel(mDBFacade, (0 : UInt), ASCompat.coerce((mFriendPopulaterMC : ASAny).pagination_friends, flash.display.MovieClip),
			mTownStateMachine.townSwf.getClass("pagination_button"), setCurrentPage);
		MemoryTracker.track(mPagination, "UIPagingPanel - created in FriendPopulater.createPagination()");
		setCurrentPage((0 : UInt));
	}

	function refreshPagination(page:UInt) {
		mPagination.currentPage = (ASCompat.floatToInt(mTotalPages != 0 ? (ASCompat.floatToInt(Math.min((mTotalPages : Float) - 1,
			page)) : UInt) : (0 : UInt)) : UInt);
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
		mPortraits.clear();
		destroyToggles();
		mFriendSelectedToggles.clear();
		populateUIOnPage(page);
		refreshMenuNavigation();
	}

	function populateFriendSlot(idx:UInt, friend:FriendInfo) {
		var _loc7_ = mTownStateMachine.getTownAsset("friend_slot");
		var _loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
		var _loc6_ = ASCompat.reinterpretAs(mFriendPopulaterMC.getChildByName("slot_" + Std.string(idx)), MovieClip);
		var _loc8_ = new Point(mFriendPopulaterMC.x - 732.9, mFriendPopulaterMC.y - 542.15);
		var _loc12_ = mDBFacade.designLocalToGlobal(_loc6_, _loc8_);
		var _loc9_:Float = 52.5;
		var _loc11_ = new Point(-5, 5);
		var _loc10_ = ASCompat.coerce((_loc4_ : ASAny).friend_pic.transform.matrix.transformPoint(new Point(_loc11_.x + _loc9_ / 2, _loc11_.y + _loc9_ / 2)),
			flash.geom.Point);
		_loc4_.x = _loc12_.x - _loc10_.x;
		_loc4_.y = _loc12_.y - _loc10_.y - 5;
		ASCompat.setProperty((_loc4_ : ASAny).friend_name, "x", _loc10_.x - ASCompat.toNumberField((_loc4_ : ASAny).friend_name, "width") / 2);
		ASCompat.setProperty((_loc4_ : ASAny).friend_name, "text", friend.name);
		ASCompat.setProperty((_loc4_ : ASAny).friend_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(friend.name, (ASCompat.toInt((_loc4_ : ASAny).friend_name.textColor) : UInt)));
		var _loc3_ = mPortraits.showFriend(ASCompat.coerce((_loc4_ : ASAny).friend_pic, flash.display.DisplayObjectContainer), mDBFacade, friend, _loc9_);
		_loc3_.x = _loc11_.x;
		_loc3_.y = _loc11_.y;
		ASCompat.setProperty((_loc4_ : ASAny).friend_pic.default_pic, "visible", false);
		if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(friend.excludeId) < 0) {
			ASCompat.setProperty((_loc4_ : ASAny).gift, "visible", false);
		} else {
			ASCompat.setProperty((_loc4_ : ASAny).gift, "visible", true);
		}
		ASCompat.setProperty((_loc4_ : ASAny).friend_pic.you_online, "visible", false);
		ASCompat.setProperty((_loc4_ : ASAny).friend_pic.friend_offline, "visible", false);
		ASCompat.setProperty((_loc4_ : ASAny).friend_pic.friend_online, "visible", false);
		ASCompat.setProperty((_loc4_ : ASAny).join, "visible", false);
		if (friend.isOnline()) {
			ASCompat.setProperty((_loc4_ : ASAny).friend_pic.friend_online, "visible", false);
		} else {
			ASCompat.setProperty((_loc4_ : ASAny).friend_pic.friend_offline, "visible", false);
		}
		TextUtil.setText(ASCompat.coerce((_loc4_ : ASAny).friend_level.level, flash.text.TextField), Std.string(friend.trophies));
		var _loc13_ = mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx);
		var _loc5_ = new UIToggleButton(mDBFacade, idx, ASCompat.coerce((_loc4_ : ASAny).friends_toggle, flash.display.MovieClip), _loc13_,
			changeToggleStatusCallback);
		_loc5_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mFriendSelectedToggles.add(idx, _loc5_);
		mUIFriendManager.addToUI(_loc4_);
		mListOfFriendSlots.push(_loc4_);
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
		var _loc3_ = 0;
		var _loc2_ = (mCurrentPage * (5 * 3) : Int);
		var _loc1_ = ((mCurrentPage + 1) * (5 * 3) - 1 : Int);
		_loc3_ = _loc2_;
		while (_loc3_ < mListOfFriends.length) {
			if (_loc3_ > _loc1_) {
				break;
			}
			if (mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc3_].excludeId) < 0) {
				ASCompat.setProperty((mListOfFriendSlots[_loc3_ - _loc2_] : ASAny).gift, "visible", false);
			} else {
				ASCompat.setProperty((mListOfFriendSlots[_loc3_ - _loc2_] : ASAny).gift, "visible", true);
			}
			_loc3_++;
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
		while (_loc8_ <= _loc2_) {
			_loc5_ = ASCompat.coerce(mFriendSelectedToggles.itemFor(_loc8_ - _loc3_), brain.uI.UIToggleButton);
			if (_loc5_ != null) {
				_loc1_ = (mCurrentPage * (5 * 3) : Int);
				if (_loc1_ <= mListOfFriends.length) {
					if (_loc8_ >= mListOfFriends.length) {
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
		while (_loc6_ <= _loc2_) {
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
			_loc2_ = ASCompat.coerce(mFriendSelectedToggles.itemFor(_loc1_), brain.uI.UIToggleButton);
			if (_loc2_ != null) {
				_loc2_.selected = false;
			}
			_loc1_++;
		}
		mFriendsSelectedAcrossPages.clear();
	}

	public function setupMenuNavigation(upObject:UIObject, downObjectLeft:UIObject, downObjectRight:UIObject = null) {
		mUIObjectAboveFriendList = upObject;
		mUIObjectBelowFriendListLeft = downObjectLeft;
		mUIObjectBelowFriendListRight = downObjectRight;
		refreshMenuNavigation();
	}

	public function getFirstNavigationUIObject():UIObject {
		var _loc1_ = ASCompat.coerce(mFriendSelectedToggles.itemFor(0), brain.uI.UIToggleButton);
		if (_loc1_ != null) {
			return _loc1_;
		}
		return mSelectAllButton;
	}

	function refreshMenuNavigation() {
		if (mUIObjectAboveFriendList == null || mUIObjectBelowFriendListLeft == null) {
			return;
		}
		mSelectAllButton.clearNavigationAndInteractions();
		mSelectNoneButton.clearNavigationAndInteractions();
		mPagination.getPageLeftButton.clearNavigationAndInteractions();
		mPagination.getPageRightButton.clearNavigationAndInteractions();
		mUIObjectBelowFriendListLeft.clearUpNavigation();
		if (mUIObjectBelowFriendListRight != null) {
			mUIObjectBelowFriendListRight.clearUpNavigation();
		}
		linkFriendGrid();
		linkListControls();
		mUIFriendManager.linkTabsToCurrentState();
		mDBFacade.menuNavigationController.setFocusedUiObject(getFirstNavigationUIObject());
	}

	function linkFriendGrid() {
		var _loc2_ = (0 : UInt);
		var _loc3_:UIToggleButton = null;
		var _loc4_:UIToggleButton = null;
		var _loc5_:UIToggleButton = null;
		var _loc1_ = (mListOfFriendSlots.length : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < _loc1_) {
			_loc3_ = ASCompat.coerce(mFriendSelectedToggles.itemFor(_loc2_), brain.uI.UIToggleButton);
			if (_loc3_ != null) {
				if (_loc2_ % 5 != 0) {
					_loc4_ = ASCompat.coerce(mFriendSelectedToggles.itemFor((_loc2_ : Float) - 1), brain.uI.UIToggleButton);
					if (_loc4_ != null) {
						_loc4_.isToTheLeftOf(_loc3_);
					}
				}
				if (_loc2_ < 5) {
					_loc3_.upNavigation = mUIObjectAboveFriendList;
				} else {
					_loc5_ = ASCompat.coerce(mFriendSelectedToggles.itemFor((_loc2_ : Float) - 5), brain.uI.UIToggleButton);
					if (_loc5_ != null) {
						_loc5_.isAbove(_loc3_);
					}
				}
				if (_loc2_ + 5 >= _loc1_) {
					_loc3_.downNavigation = mSelectAllButton;
				}
			}
			_loc2_++;
		}
	}

	function linkListControls() {
		var _loc3_ = 0;
		mSelectAllButton.isToTheLeftOf(mSelectNoneButton);
		var _loc5_ = getLastRowFirstToggle();
		if (_loc5_ == null) {
			_loc5_ = mUIObjectAboveFriendList;
		}
		mSelectAllButton.upNavigation = _loc5_;
		mSelectNoneButton.upNavigation = _loc5_;
		var _loc2_ = getPaginationObjects();
		_loc3_ = 1;
		while (_loc3_ < _loc2_.length) {
			cast(_loc2_[_loc3_ - 1], UIObject).isToTheLeftOf(cast(_loc2_[_loc3_], UIObject));
			_loc3_++;
		}
		var _loc1_:UIObject;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc1_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				_loc1_.upNavigation = mSelectAllButton;
				_loc1_.downNavigation = mUIObjectBelowFriendListLeft;
			}
		var _loc4_ = getFirstFocusableObject(_loc2_);
		mSelectAllButton.downNavigation = _loc4_ ?? mUIObjectBelowFriendListLeft;
		mSelectNoneButton.downNavigation = _loc4_ ?? mUIObjectBelowFriendListLeft;
		var _loc6_ = ASCompat.coerce(_loc4_ ?? mSelectAllButton, brain.uI.UIObject);
		mUIObjectBelowFriendListLeft.upNavigation = _loc6_;
		if (mUIObjectBelowFriendListRight != null) {
			mUIObjectBelowFriendListRight.upNavigation = _loc6_;
		}
	}

	function getLastRowFirstToggle():UIObject {
		var _loc1_ = (mListOfFriendSlots.length : UInt);
		if (_loc1_ == 0) {
			return null;
		}
		var _loc2_ = (ASCompat.floatToInt(((_loc1_ : Float) - 1) / 5) * 5:UInt);
		return ASCompat.coerce(mFriendSelectedToggles.itemFor(_loc2_), brain.uI.UIObject);
	}

	function getPaginationObjects():Array<ASAny> {
		var _loc3_ = 0;
		var _loc1_:UIButton = null;
		var _loc2_:Array<ASAny> = [mPagination.getPageLeftButton];
		_loc3_ = 0;
		while ((_loc3_ : UInt) < mPagination.numPageButtons) {
			_loc1_ = mPagination.getPageButton(_loc3_);
			if (_loc1_ != null) {
				_loc2_.push(_loc1_);
			}
			_loc3_++;
		}
		_loc2_.push(mPagination.getPageRightButton);
		return _loc2_;
	}

	function getFirstFocusableObject(uiObjects:Array<ASAny>):UIObject {
		var _loc2_:UIObject;
		if (checkNullIteratee(uiObjects))
			for (_tmp_ in uiObjects) {
				_loc2_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				if (_loc2_ != null && _loc2_.canBeFocused()) {
					return _loc2_;
				}
			}
		return null;
	}

	public function getSelectedToggles():Array<ASAny> {
		togglesSelectedArray = mFriendsSelectedAcrossPages.keysToArray();
		return togglesSelectedArray;
	}

	public function destroy() {
		mPortraits.destroy();
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
		destroyToggles();
		mFriendSelectedToggles = null;
		mFriendsSelectedAcrossPages = null;
		mUIObjectAboveFriendList = null;
		mUIObjectBelowFriendListLeft = null;
		mUIObjectBelowFriendListRight = null;
		togglesSelectedArray = null;
	}

	function destroyToggles() {
		var _loc2_:UIToggleButton = null;
		var _loc1_ = mFriendSelectedToggles.keysToArray();
		var _loc3_:UInt;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc2_ = ASCompat.coerce(mFriendSelectedToggles.itemFor(_loc3_), brain.uI.UIToggleButton);
				if (_loc2_ != null) {
					_loc2_.destroy();
				}
			}
	}
}
