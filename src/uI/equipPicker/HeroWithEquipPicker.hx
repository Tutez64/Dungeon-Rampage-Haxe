package uI.equipPicker;

import account.AvatarInfo;
import account.InventoryBaseInfo;
import account.ItemInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.ImageAsset;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMWeaponItem;
import uI.ControllerIconData;
import uI.inventory.UIInventoryItem;
import uI.popup.DBUIPopup;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Vector3D;

class HeroWithEquipPicker extends UIObject {
	static final CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS:Vector3D = new Vector3D(13, -50);

	static final CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS:Point = new Point(25, 25);

	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mHeroSlots:Vector<HeroElement>;

	var mEquipElements:Vector<AvatarEquipElement>;

	var mEquipSlots:Vector<EquipSlot>;

	var mShiftLeft:UIButton;

	var mShiftRight:UIButton;

	var mHeroSelectedCallback:ASFunction;

	var mClickedEquippedWeaponCallback:ASFunction;

	var mSetSelectedHeroCallback:ASFunction;

	var mGetSelectedHeroCallback:ASFunction;

	var mCurrentStartIndex:UInt = (0 : UInt);

	var mTotalGMHeroes:UInt = 0;

	var mEquipResponseCallback:ASFunction;

	var mAllowSelectingUnownedHeroes:Bool = true;

	var mFirstSlotLeftNavigation:UIObject;

	var mAvatarAlertsOn:Bool = false;

	var mAlertDisabledHeroId:UInt = (0 : UInt);

	var mComparisonWeapon:GMWeaponItem;

	var mComparisonPower:UInt = 0;

	var mSelectedHeroIndex:Int = -1;

	var mGlyphFilePathToControllerIconData:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Dynamic, heroTooltipClass:Dynamic, heroSelectedCallback:ASFunction,
			clickedEquippedWeaponCallback:ASFunction = null, getSelectedHeroIndexCallback:ASFunction = null, setSelectedHeroIndexCallback:ASFunction = null,
			equipResponseFinishedCallback:ASFunction = null, allowEquipmentSwapping:Bool = false, allowSelectingUnownedHeroes:Bool = true,
			isActiveCallback:ASFunction = null) {
		super(dbFacade, root);
		mDBFacade = dbFacade;
		mAllowSelectingUnownedHeroes = allowSelectingUnownedHeroes;
		mEventComponent = new EventComponent(mDBFacade);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mHeroSelectedCallback = heroSelectedCallback;
		mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
		mEquipResponseCallback = equipResponseFinishedCallback;
		mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
		mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
		Locale.setText(ASCompat.coerce((mRoot : ASAny).label, flash.text.TextField), "WEAPON_PICKER_LABEL");
		mEquipElements = new Vector<AvatarEquipElement>();
		mEquipElements.push(new AvatarEquipElement(mDBFacade, mDBFacade.keyBindings.displayNameFor("attackWeapon1"),
			ASCompat.coerce((mRoot : ASAny).UI_weapons.equip_slot_0, flash.display.MovieClip), weaponTooltipClass, unequipItem, handleItemDrop, (0 : UInt),
			equippedWeaponClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		mEquipElements.push(new AvatarEquipElement(mDBFacade, mDBFacade.keyBindings.displayNameFor("attackWeapon2"),
			ASCompat.coerce((mRoot : ASAny).UI_weapons.equip_slot_1, flash.display.MovieClip), weaponTooltipClass, unequipItem, handleItemDrop, (1 : UInt),
			equippedWeaponClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		mEquipElements.push(new AvatarEquipElement(mDBFacade, mDBFacade.keyBindings.displayNameFor("attackWeapon3"),
			ASCompat.coerce((mRoot : ASAny).UI_weapons.equip_slot_2, flash.display.MovieClip), weaponTooltipClass, unequipItem, handleItemDrop, (2 : UInt),
			equippedWeaponClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		mEventComponent.removeAllListeners();
		mEventComponent.addListener("OnSteamInputGlyphsChanged", onSteamInputGlyphsChanged);
		mEventComponent.addListener("ControllerConnectionChangedEvent", onControllerConnectionChanged);
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
		mEquipSlots = new Vector<EquipSlot>();
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.coerce((mRoot : ASAny).empty_z, flash.display.MovieClip), this.handleItemDrop, (0 : UInt)));
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.coerce((mRoot : ASAny).empty_x, flash.display.MovieClip), this.handleItemDrop, (1 : UInt)));
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.coerce((mRoot : ASAny).empty_c, flash.display.MovieClip), this.handleItemDrop, (2 : UInt)));
		mHeroSlots = new Vector<HeroElement>();
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_0, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_1, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_2, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_3, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_4, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_5, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_6, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.coerce((mRoot : ASAny).hero_slot_7, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mShiftLeft = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).shift_left, flash.display.MovieClip));
		mShiftLeft.releaseCallback = shiftLeft;
		mShiftRight = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).shift_right, flash.display.MovieClip));
		mShiftRight.releaseCallback = shiftRight;
		mTotalGMHeroes = (mDBFacade.gameMaster.Heroes.length : UInt);
		mShiftLeft.visible = mTotalGMHeroes > (mHeroSlots.length : UInt);
		mShiftRight.visible = mShiftLeft.visible;
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			if (isActiveCallback == null || ASCompat.toBool(isActiveCallback())) {
				refresh();
			}
		});
	}

	function onSteamInputGlyphsChanged(inEvent:Event) {
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
	}

	function onControllerConnectionChanged(inEvent:Event) {
		hideAndUnloadControllerIcons();
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
	}

	public function hideAndUnloadControllerIcons() {
		hideControllerIcons();
		var _loc2_:String;
		final __ax4_iter_482 = mGlyphFilePathToControllerIconData;
		if (checkNullIteratee(__ax4_iter_482))
			for (_tmp_ in __ax4_iter_482.keys()) {
				_loc2_ = _tmp_;
				mGlyphFilePathToControllerIconData.remove(_loc2_);
			}
		var _loc1_:AvatarEquipElement;
		final __ax4_iter_483 = mEquipElements;
		if (checkNullIteratee(__ax4_iter_483))
			for (_tmp_ in __ax4_iter_483) {
				_loc1_ = _tmp_;
				_loc1_.setLabelAsText();
			}
	}

	function hideControllerIcons() {
		var _loc2_:ControllerIconData = null;
		var _loc1_:String;
		final __ax4_iter_484 = mGlyphFilePathToControllerIconData;
		if (checkNullIteratee(__ax4_iter_484))
			for (_tmp_ in __ax4_iter_484.keys()) {
				_loc1_ = _tmp_;
				_loc2_ = ASCompat.coerce(mGlyphFilePathToControllerIconData[_loc1_], uI.ControllerIconData);
				if (!_loc2_.mIsHidden) {
					if (_loc2_.mOwner.contains(_loc2_.mControllerGlyph)) {
						_loc2_.mOwner.removeChild(_loc2_.mControllerGlyph);
					}
					_loc2_.mIsHidden = true;
				}
			}
	}

	function initControllerIcons() {
		var _loc1_ = new Vector<String>();
		_loc1_.push("attack_weapon_1");
		_loc1_.push("attack_weapon_2");
		_loc1_.push("attack_weapon_3");
		var _loc2_:Float = 0;
		var _loc3_:AvatarEquipElement;
		final __ax4_iter_485 = mEquipElements;
		if (checkNullIteratee(__ax4_iter_485))
			for (_tmp_ in __ax4_iter_485) {
				_loc3_ = _tmp_;
				initControllerIcon(_loc3_, _loc1_[ASCompat.floatToInt(_loc2_)]);
				_loc2_++;
			}
	}

	function initControllerIcon(equipElement:AvatarEquipElement, ActionName:String) {
		var iconData:ControllerIconData;
		var glyphFilePath = mDBFacade.steamInputManager.getGlyphFilePathForAction(ActionName);
		if (glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1") {
			equipElement.setLabelAsText();
			return;
		}
		iconData = ASCompat.coerce(mGlyphFilePathToControllerIconData[glyphFilePath], uI.ControllerIconData);
		if (iconData != null) {
			equipElement.setLabelAsControllerGlyph(iconData.mControllerGlyph);
		} else {
			mAssetLoadingComponent.getImageAsset(glyphFilePath, function(param1:ImageAsset) {
				loadControllerIcon(param1, equipElement, glyphFilePath, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
			}, null, false);
		}
	}

	function loadControllerIcon(asset:ImageAsset, equipElement:AvatarEquipElement, glyphFilePath:String, iconPosition:Vector3D, iconScale:Point) {
		var _loc6_ = asset.image;
		var _loc7_:DisplayObject = new Bitmap(_loc6_.bitmapData);
		_loc7_.x = iconPosition.x;
		_loc7_.y = iconPosition.y;
		_loc7_.width = iconScale.x;
		_loc7_.height = iconScale.y;
		equipElement.setLabelAsControllerGlyph(_loc7_);
		var _loc8_ = new ControllerIconData(_loc7_, equipElement.root, false);
		mGlyphFilePathToControllerIconData[glyphFilePath] = _loc8_;
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

	function equippedWeaponClicked(equipElement:AvatarEquipElement) {
		deselectEquipment();
		if (mClickedEquippedWeaponCallback != null && equipElement.itemInfo != null) {
			equipElement.select();
			mClickedEquippedWeaponCallback(equipElement.itemInfo, equipElement);
		}
	}

	public function showWeaponComparison(gmWeaponItem:GMWeaponItem, power:UInt) {
		mComparisonWeapon = gmWeaponItem;
		mComparisonPower = power;
		applyWeaponComparison();
	}

	public function hideWeaponComparison() {
		mComparisonWeapon = null;
		applyWeaponComparison();
	}

	function applyWeaponComparison() {
		var _loc1_:HeroElement;
		final __ax4_iter_486 = mHeroSlots;
		if (checkNullIteratee(__ax4_iter_486))
			for (_tmp_ in __ax4_iter_486) {
				_loc1_ = _tmp_;
				_loc1_.hideWeaponComparison();
				if (mComparisonWeapon != null) {
					_loc1_.showWeaponComparison(mComparisonWeapon, mComparisonPower);
				}
			}
	}

	public function show() {
		mRoot.visible = true;
	}

	public function hide() {
		mRoot.visible = false;
	}

	@:isVar public var currentlySelectedHero(get, never):GMHero;

	public function get_currentlySelectedHero():GMHero {
		var _loc2_ = mDBFacade.gameMaster.Heroes;
		var _loc1_ = selectedHeroIndex;
		return ASCompat.coerce(_loc1_ >= 0 && _loc1_ < _loc2_.length ? _loc2_[_loc1_] : null, gameMasterDictionary.GMHero);
	}

	@:isVar public var currentlySelectedAvatarInfo(get, never):AvatarInfo;

	public function get_currentlySelectedAvatarInfo():AvatarInfo {
		var _loc1_ = this.currentlySelectedHero;
		return ASCompat.coerce(_loc1_ != null ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc1_.Id) : null, account.AvatarInfo);
	}

	public function selectPreviousHero() {
		selectAdjacentHero(-1);
	}

	public function selectNextHero() {
		selectAdjacentHero(1);
	}

	function selectAdjacentHero(direction:Int) {
		var _loc6_ = mDBFacade.gameMaster.Heroes;
		if (_loc6_.length == 0) {
			return;
		}
		var _loc5_ = selectedHeroIndex;
		if (_loc5_ < 0 || _loc5_ >= _loc6_.length) {
			_loc5_ = 0;
		}
		var _loc2_ = mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes", false);
		var _loc4_ = _loc5_;
		while (true) {
			_loc4_ = (_loc4_ + direction + _loc6_.length) % _loc6_.length;
			if (!(_loc4_ != _loc5_
				&& (_loc6_[_loc4_].Hidden
					&& !_loc2_
					|| !mAllowSelectingUnownedHeroes
					&& !mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc6_[_loc4_].Id)))) {
				break;
			}
		}
		if (_loc4_ == _loc5_) {
			return;
		}
		if ((_loc4_ : UInt) < mCurrentStartIndex) {
			mCurrentStartIndex = (_loc4_ : UInt);
		} else if ((_loc4_ : UInt) >= mCurrentStartIndex + mHeroSlots.length) {
			mCurrentStartIndex = (_loc4_ - (mHeroSlots.length - 1) : UInt);
		}
		populateHeroSlots();
		var _loc3_ = mHeroSlots[(_loc4_ - mCurrentStartIndex : Int)];
		heroClicked(_loc3_, mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc3_.gmHero.Id));
		mDBFacade.menuNavigationController.setFocusedUiObject(_loc3_);
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

	function updateFirstSlotLeftNavigation() {
		var _loc1_ = mHeroSlots[0].leftNavigationAdditionalInteraction;
		mHeroSlots[0].clearLeftNavigation();
		if (_loc1_ != null) {
			mHeroSlots[0].leftNavigationAdditionalInteraction = _loc1_;
		}
		if (mCurrentStartIndex == 0 && mFirstSlotLeftNavigation != null) {
			mHeroSlots[0].leftNavigation = mFirstSlotLeftNavigation;
		}
	}

	override public function destroy() {
		mEventComponent.destroy();
		mAssetLoadingComponent.destroy();
		mDBFacade = null;
		mShiftLeft.destroy();
		mShiftRight.destroy();
		mHeroSelectedCallback = null;
		super.destroy();
	}

	function setActiveAvatarAsCurrentSelection() {
		var _loc2_:Array<ASAny> = null;
		var _loc1_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
		if (_loc1_ == null) {
			Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
			if (mDBFacade.dbAccountInfo.inventoryInfo.avatars == null) {
				Logger.error("setActiveAvatarAsCurrentSelection() - mDBFacade.dbAccountInfo.inventoryInfo.avatars == null on account id: "
					+ mDBFacade.accountId);
			}
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

	public function setAvatarAlert(val:Bool) {
		mAvatarAlertsOn = val;
		mAlertDisabledHeroId = (0 : UInt);
		applyAvatarAlerts();
	}

	public function disableAvatarAlertOnSelectedHero() {
		var _loc1_ = currentlySelectedHero;
		if (_loc1_ != null) {
			mAlertDisabledHeroId = _loc1_.Id;
		}
		applyAvatarAlerts();
	}

	function applyAvatarAlerts() {
		var _loc1_:AvatarInfo = null;
		var _loc3_ = (0 : UInt);
		var _loc2_:GMHero = null;
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mHeroSlots.length:UInt)) {
			_loc2_ = mHeroSlots[(_loc3_ : Int)].gmHero;
			if (mAvatarAlertsOn && _loc2_ != null && _loc2_.Id != mAlertDisabledHeroId) {
				_loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc2_.Id);
				mHeroSlots[(_loc3_ : Int)].alert = _loc1_ != null && _loc1_.skillPointsAvailable > 0;
			} else {
				mHeroSlots[(_loc3_ : Int)].alert = false;
			}
			_loc3_++;
		}
	}

	public function refresh(resync:Bool = false) {
		if (selectedHeroIndex == -1 || resync) {
			setActiveAvatarAsCurrentSelection();
		}
		hideWeaponComparison();
		if ((selectedHeroIndex : UInt) < mCurrentStartIndex || (selectedHeroIndex : UInt) >= mCurrentStartIndex + mHeroSlots.length) {
			setCurrentIndexToShowSelectedHero();
		}
		populateHeroSlots();
		setEquipWeaponSlots();
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
		updateFirstSlotLeftNavigation();
		determineSelectedElement();
		applyAvatarAlerts();
		applyWeaponComparison();
	}

	function setCurrentIndexToShowSelectedHero() {
		if (selectedHeroIndex < mHeroSlots.length) {
			mCurrentStartIndex = (0 : UInt);
			return;
		}
		mCurrentStartIndex = (selectedHeroIndex - (mHeroSlots.length - 1) : UInt);
	}

	function shiftLeft() {
		mCurrentStartIndex = mCurrentStartIndex - 1;
		populateHeroSlots();
	}

	function shiftRight() {
		mCurrentStartIndex = mCurrentStartIndex + 1;
		populateHeroSlots();
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

	function heroClicked(heroElement:HeroElement, owned:Bool) {
		if (!mAllowSelectingUnownedHeroes && !owned) {
			return;
		}
		var _loc3_ = mHeroSlots.indexOf(heroElement) + mCurrentStartIndex;
		if ((selectedHeroIndex : UInt) == _loc3_) {
			return;
		}
		selectedHeroIndex = (_loc3_ : Int);
		determineSelectedElement();
		setEquipWeaponSlots();
		if (mHeroSelectedCallback != null) {
			mHeroSelectedCallback(heroElement.gmHero, owned);
		}
	}

	public function setEquipWeaponSlots() {
		var _loc4_ = (0 : UInt);
		var _loc1_ = 0;
		if (selectedHeroIndex >= mDBFacade.gameMaster.Heroes.length) {
			return;
		}
		_loc4_ = (0 : UInt);
		while (_loc4_ < (mEquipElements.length:UInt)) {
			mEquipElements[(_loc4_ : Int)].clear();
			_loc4_++;
		}
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.gameMaster.Heroes[selectedHeroIndex].Id);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(_loc2_.id);
		if (_loc3_.length > 3) {
			Logger.warn("Avatar has more than three equipped items.  Equipping first three.");
		}
		mDBFacade.steamAchievementsHelper.unlockThreeLegendaryWeapons(_loc3_);
		_loc4_ = (0 : UInt);
		while (_loc4_ < (mEquipElements.length:UInt)) {
			if (_loc4_ >= (_loc3_.length : UInt)) {
				break;
			}
			_loc1_ = _loc3_[(_loc4_ : Int)].avatarSlot;
			if (_loc1_ >= mEquipElements.length) {
				Logger.warn("Item instance id: "
					+ _loc3_[(_loc4_ : Int)].databaseId + " is equipped to an invalid slot: " + _loc3_[(_loc4_ : Int)].avatarSlot);
			} else if ((_loc3_.length : UInt) > _loc4_) {
				if (mEquipElements[_loc1_].itemInfo != null) {
					Logger.warn("Equipped items contains multiple items assigned to the same slot. First itemId: "
						+ mEquipElements[_loc1_].itemInfo.gmId + ". Second itemId: " + _loc3_[(_loc4_ : Int)].gmId + ".  Slot: " +
							_loc3_[(_loc4_ : Int)].avatarSlot);
				} else {
					mEquipElements[_loc1_].itemInfo = _loc3_[(_loc4_ : Int)];
				}
			}
			_loc4_++;
		}
	}

	public function equipItemOnCurrentAvatar(info:InventoryBaseInfo, itemSlot:UInt, responseFinishedCallback:ASFunction = null,
			errorCallback:ASFunction = null) {
		var equipServiceResponse:ASFunction;
		var equippingModal:DBUIPopup = null;
		var avatarId:UInt;
		var avatarInfo = currentlySelectedAvatarInfo;
		if (avatarInfo != null) {
			equipServiceResponse = function() {
				equippingModal.destroy();
				if (responseFinishedCallback != null) {
					responseFinishedCallback();
				}
			};
			equippingModal = createEquippingModal();
			avatarId = avatarInfo.id;
			mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar(avatarId, info.databaseId, itemSlot, equipServiceResponse,
				closeEquippingModalOnError(equippingModal, errorCallback));
		}
	}

	public function unequipItem(info:InventoryBaseInfo, responseFinishedCallback:ASFunction = null, errorCallback:ASFunction = null) {
		var equippingModal = createEquippingModal();
		var equipServiceResponse:ASFunction = function() {
			equippingModal.destroy();
			if (responseFinishedCallback != null) {
				responseFinishedCallback();
			}
		};
		mDBFacade.dbAccountInfo.inventoryInfo.unequipItemOffAvatar(info, equipServiceResponse, closeEquippingModalOnError(equippingModal, errorCallback));
	}

	function createEquippingModal():DBUIPopup {
		return new DBUIPopup(mDBFacade, "", Locale.getString("EQUIPPING_MODAL"), null, false);
	}

	function closeEquippingModalOnError(modal:DBUIPopup, callback:ASFunction):ASFunction {
		return Reflect.makeVarArgs(function(_rest:Array<ASAny>) {
			var rest = ASCompat.restToArray(_rest);
			modal.destroy();
			if (callback != null) {
				ASCompatMacro.applyClosure(callback, rest);
			}
		});
	}

	public function highlightItem(info:InventoryBaseInfo) {
		var _loc2_:AvatarEquipElement = null;
		var _loc3_ = (0 : UInt);
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mEquipElements.length:UInt)) {
			_loc2_ = mEquipElements[(_loc3_ : Int)];
			if (info != null && _loc2_.itemInfo == info) {
				mEquipElements[(_loc3_ : Int)].select();
			} else {
				mEquipElements[(_loc3_ : Int)].deselect();
			}
			_loc3_++;
		}
	}

	public function deselectEquipment() {
		var _loc1_ = (0 : UInt);
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mEquipElements.length:UInt)) {
			mEquipElements[(_loc1_ : Int)].deselect();
			_loc1_++;
		}
	}

	public function handleItemDrop(dropObject:UIObject, itemInfo:InventoryBaseInfo, equipSlot:UInt):Bool {
		var equipElement:AvatarEquipElement;
		var uiInvItem = ASCompat.reinterpretAs(dropObject, UIInventoryItem);
		if (uiInvItem != null && uiInvItem.info != null && Std.isOfType(uiInvItem.info, ItemInfo)) {
			this.equipItemOnCurrentAvatar(cast(uiInvItem.info, ItemInfo), equipSlot, mEquipResponseCallback);
			uiInvItem.dragSwapItem(itemInfo);
			return true;
		}
		equipElement = ASCompat.reinterpretAs(dropObject, AvatarEquipElement);
		if (equipElement != null && equipElement.itemInfo != null) {
			equipElement.reset();
			if (equipElement.equipSlot == equipSlot) {
				return true;
			}
			this.equipItemOnCurrentAvatar(equipElement.itemInfo, equipSlot, function() {
				if (itemInfo != null) {
					equipItemOnCurrentAvatar(itemInfo, equipElement.equipSlot, mEquipResponseCallback);
				} else {
					mEquipResponseCallback();
				}
			}, mEquipResponseCallback);
			return true;
		}
		return false;
	}

	public function getFirstHeroSlotUIObject():UIObject {
		return mHeroSlots[0];
	}

	public function setupHeroWithEquipPickerMenuNavigation(returnObject:ASAny) {
		mHeroSlots[0].isToTheLeftOf(mHeroSlots[1]);
		mHeroSlots[1].isToTheLeftOf(mHeroSlots[2]);
		mHeroSlots[2].isToTheLeftOf(mHeroSlots[3]);
		mHeroSlots[3].isToTheLeftOf(mHeroSlots[4]);
		mHeroSlots[4].isToTheLeftOf(mHeroSlots[5]);
		mHeroSlots[5].isToTheLeftOf(mHeroSlots[6]);
		mHeroSlots[6].isToTheLeftOf(mHeroSlots[7]);
		mHeroSlots[0].leftNavigationAdditionalInteraction = rotateRosterLeft;
		mHeroSlots[7].rightNavigationAdditionalInteraction = rotateRosterRight;
		mHeroSlots[0].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[1].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[2].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[3].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[4].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[5].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[6].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mHeroSlots[7].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mEquipElements[0].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mEquipElements[1].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mEquipElements[2].upNavigation = ASCompat.coerce(returnObject, brain.uI.UIObject);
		mEquipElements[0].isToTheLeftOf(mEquipElements[1]);
		mEquipElements[1].isToTheLeftOf(mEquipElements[2]);
		mEquipElements[2].isToTheLeftOf(mHeroSlots[0]);
		mFirstSlotLeftNavigation = mEquipElements[2];
		updateFirstSlotLeftNavigation();
	}

	public function resetHeroWithEquipPickerMenuNavigation() {
		mFirstSlotLeftNavigation = null;
		mHeroSlots[0].clearNavigationAndInteractions();
		mHeroSlots[1].clearNavigationAndInteractions();
		mHeroSlots[2].clearNavigationAndInteractions();
		mHeroSlots[3].clearNavigationAndInteractions();
		mHeroSlots[4].clearNavigationAndInteractions();
		mHeroSlots[5].clearNavigationAndInteractions();
		mHeroSlots[6].clearNavigationAndInteractions();
		mHeroSlots[7].clearNavigationAndInteractions();
		mEquipElements[0].clearNavigationAndInteractions();
		mEquipElements[1].clearNavigationAndInteractions();
		mEquipElements[2].clearNavigationAndInteractions();
	}
}
