package uI.equipPicker;

import account.AvatarInfo;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import facade.DBFacade;
import facade.Locale;
import flash.display.MovieClip;

class StuffWithEquipPicker extends UIObject {
	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mHeroSlots:Vector<HeroElement>;

	var mTotalGMHeroes:UInt = 0;

	var mShiftLeft:UIButton;

	var mShiftRight:UIButton;

	var mSetSelectedHeroCallback:ASFunction;

	var mGetSelectedHeroCallback:ASFunction;

	var mSelectedHeroIndex:Int = -1;

	var mCurrentStartIndex:UInt = (0 : UInt);

	public function new(dbFacade:DBFacade, root:MovieClip, heroTooltipClass:Dynamic, getSelectedHeroIndexCallback:ASFunction = null,
			setSelectedHeroIndexCallback:ASFunction = null, isActiveCallback:ASFunction = null) {
		super(dbFacade, root);
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
		mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
		mHeroSlots = new Vector<HeroElement>();
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_0, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_1, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_2, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_3, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_4, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_5, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_6, flash.display.MovieClip), heroTooltipClass, function() {}));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_7, flash.display.MovieClip), heroTooltipClass, function() {}));
		mShiftLeft = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).shift_left, flash.display.MovieClip));
		mShiftLeft.releaseCallback = shiftLeft;
		mShiftRight = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).shift_right, flash.display.MovieClip));
		mShiftRight.releaseCallback = shiftRight;
		mTotalGMHeroes = (mDBFacade.gameMaster.Heroes.length : UInt);
		mShiftLeft.visible = mTotalGMHeroes > (mHeroSlots.length : UInt);
		mShiftRight.visible = mShiftLeft.visible;
		Locale.setText(ASCompat.coerce((mRoot : ASAny).label, flash.text.TextField), "INVENTORY_STUFF_DESCRIPTION");
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			if (isActiveCallback == null || ASCompat.toBool(isActiveCallback())) {
				refresh();
			}
		});
	}

	function populateHeroSlots() {
		var _loc2_ = (0 : UInt);
		var _loc3_ = mDBFacade.gameMaster.Heroes;
		var _loc1_ = mCurrentStartIndex;
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mHeroSlots.length:UInt)) {
			mHeroSlots[(_loc2_ : Int)].clear();
			if (_loc1_ < (_loc3_.length:UInt)
				&& (!_loc3_[(_loc1_ : Int)].Hidden || mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes", false))) {
				mHeroSlots[(_loc2_ : Int)].gmHero = _loc3_[(_loc1_ : Int)];
			} else {
				mHeroSlots[(_loc2_ : Int)].enabled = false;
			}
			_loc1_++;
			_loc2_++;
		}
		updateShiftButtons();
	}

	function updateShiftButtons() {
		if (mCurrentStartIndex == 0) {
			mShiftLeft.enabled = false;
		} else {
			mShiftLeft.enabled = true;
		}
		var _loc1_ = mCurrentStartIndex + mHeroSlots.length;
		if (_loc1_ < mTotalGMHeroes) {
			mShiftRight.enabled = true;
		} else {
			mShiftRight.enabled = false;
		}
	}

	function shiftLeft() {
		mCurrentStartIndex = mCurrentStartIndex - 1;
		populateHeroSlots();
	}

	function shiftRight() {
		mCurrentStartIndex = mCurrentStartIndex + 1;
		populateHeroSlots();
	}

	function rotateRosterLeft() {
		if (mCurrentStartIndex > 0) {
			shiftLeft();
		}
	}

	function rotateRosterRight() {
		if (mCurrentStartIndex + mHeroSlots.length < mTotalGMHeroes) {
			shiftRight();
		}
	}

	override public function destroy() {
		mEventComponent.destroy();
		mDBFacade = null;
		super.destroy();
	}

	public function show() {
		mRoot.visible = true;
	}

	public function hide() {
		mRoot.visible = false;
	}

	public function refresh(resync:Bool = false) {
		if (selectedHeroIndex == -1 || resync) {
			setActiveAvatarAsCurrentSelection();
		}
		if ((selectedHeroIndex : UInt) < mCurrentStartIndex || (selectedHeroIndex : UInt) >= mCurrentStartIndex + mHeroSlots.length) {
			setCurrentIndexToShowSelectedHero();
		}
		populateHeroSlots();
	}

	public function getFirstUIObject():UIObject {
		return mHeroSlots[0];
	}

	public function setupMenuNavigation(returnObject:UIObject) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mHeroSlots.length:UInt)) {
			mHeroSlots[(_loc2_ : Int)].upNavigation = returnObject;
			if (_loc2_ > 0) {
				mHeroSlots[(_loc2_ - 1 : Int)].isToTheLeftOf(mHeroSlots[(_loc2_ : Int)]);
			}
			_loc2_++;
		}
		mHeroSlots[0].leftNavigationAdditionalInteraction = rotateRosterLeft;
		mHeroSlots[mHeroSlots.length - 1].rightNavigationAdditionalInteraction = rotateRosterRight;
	}

	public function resetMenuNavigation() {
		var _loc1_:UIObject;
		final __ax4_iter_481 = mHeroSlots;
		if (checkNullIteratee(__ax4_iter_481))
			for (_tmp_ in __ax4_iter_481) {
				_loc1_ = _tmp_;
				_loc1_.clearNavigationAndInteractions();
			}
	}

	function setActiveAvatarAsCurrentSelection() {
		var _loc2_:Array<ASAny> = null;
		var _loc1_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
		if (_loc1_ == null) {
			Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
			_loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
			if (_loc2_ == null) {
				Logger.error("No avatars found on account id: " + mDBFacade.accountId);
				return;
			}
			_loc1_ = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(_loc2_[0]), AvatarInfo);
			if (_loc1_ == null) {
				Logger.fatal("Could not get avatar info for key: " + Std.string(_loc2_[0]) + " Unable to get active avatar.");
				return;
			}
		}
		selectedHeroIndex = (findHeroIndex(_loc1_.avatarType) : Int);
	}

	@:isVar var selectedHeroIndex(get, set):Int;

	function get_selectedHeroIndex():Int {
		if (mGetSelectedHeroCallback != null) {
			mSelectedHeroIndex = ASCompat.toInt(mGetSelectedHeroCallback());
		}
		return mSelectedHeroIndex;
	}

	function set_selectedHeroIndex(val:Int):Int {
		mSelectedHeroIndex = val;
		if (mSetSelectedHeroCallback != null) {
			mSetSelectedHeroCallback(mSelectedHeroIndex);
		}
		return val;
	}

	function heroClicked(heroElement:HeroElement, owned:Bool) {
		var _loc3_ = mHeroSlots.indexOf(heroElement) + mCurrentStartIndex;
		if ((selectedHeroIndex : UInt) == _loc3_) {
			return;
		}
		selectedHeroIndex = (_loc3_ : Int);
		determineSelectedElement();
		refresh();
	}

	function determineSelectedElement() {
		var _loc1_ = (0 : UInt);
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mHeroSlots.length:UInt)) {
			if (_loc1_ + mCurrentStartIndex == (selectedHeroIndex : UInt)) {
				mHeroSlots[(_loc1_ : Int)].select();
			} else {
				mHeroSlots[(_loc1_ : Int)].deselect();
			}
			_loc1_++;
		}
	}

	function setCurrentIndexToShowSelectedHero() {
		if (selectedHeroIndex < mHeroSlots.length) {
			mCurrentStartIndex = (0 : UInt);
			return;
		}
		mCurrentStartIndex = (selectedHeroIndex - (mHeroSlots.length - 1) : UInt);
	}

	function findHeroIndex(avatarId:UInt):UInt {
		var _loc2_ = (0 : UInt);
		var _loc3_ = mDBFacade.gameMaster.Heroes;
		_loc2_ = (0 : UInt);
		while (_loc2_ < (_loc3_.length:UInt)) {
			if (avatarId == _loc3_[(_loc2_ : Int)].Id) {
				return _loc2_;
			}
			_loc2_++;
		}
		Logger.error("Unable to find gmHero for active avatar Id: " + avatarId);
		return (0 : UInt);
	}
}
