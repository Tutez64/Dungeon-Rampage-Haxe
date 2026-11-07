package uI.equipPicker;

import account.AvatarInfo;
import account.Consumable;
import account.InventoryBaseInfo;
import account.StackableInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMStackable;
import uI.ControllerIconData;
import uI.inventory.UIInventoryItem;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUIPopup;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Vector3D;

class StacksWithEquipPicker extends UIObject {
	static final CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS:Vector3D = new Vector3D(13, -50);

	static final CONTROLLER_GLYPH_SCALE_STACK_BUTTONS:Point = new Point(20, 20);

	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mHeroSlots:Vector<HeroElement>;

	var mEquipElements:Vector<ConsumableEquipElement>;

	var mEquipSlots:Vector<EquipSlot>;

	var mClickedEquippedWeaponCallback:ASFunction;

	var mCurrentStartIndex:UInt = (0 : UInt);

	var mFirstSlotLeftNavigation:UIObject;

	var mEquipResponseCallback:ASFunction;

	var mSetSelectedHeroCallback:ASFunction;

	var mGetSelectedHeroCallback:ASFunction;

	var mSelectedHeroIndex:Int = -1;

	var mTotalGMHeroes:UInt = 0;

	var mShiftLeft:UIButton;

	var mShiftRight:UIButton;

	var mGlyphFilePathToControllerIconData:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Dynamic, heroTooltipClass:Dynamic,
			clickedEquippedWeaponCallback:ASFunction = null, equipResponseFinishedCallback:ASFunction = null, allowEquipmentSwapping:Bool = false,
			getSelectedHeroIndexCallback:ASFunction = null, setSelectedHeroIndexCallback:ASFunction = null, isActiveCallback:ASFunction = null) {
		super(dbFacade, root);
		mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
		mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
		Locale.setText(ASCompat.coerce((mRoot : ASAny).label, flash.text.TextField), "STACK_PICKER_LABEL");
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
		mEquipResponseCallback = equipResponseFinishedCallback;
		mEquipElements = new Vector<ConsumableEquipElement>();
		mEquipElements.push(new ConsumableEquipElement(mDBFacade, mDBFacade.keyBindings.displayNameFor("useConsumable1"),
			ASCompat.coerce((mRoot : ASAny).UI_potion.equip_slot_0, flash.display.MovieClip), weaponTooltipClass, unequipPotion, handleItemDrop, (0 : UInt),
			equippedPotionClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		mEquipElements.push(new ConsumableEquipElement(mDBFacade, mDBFacade.keyBindings.displayNameFor("useConsumable2"),
			ASCompat.coerce((mRoot : ASAny).UI_potion.equip_slot_1, flash.display.MovieClip), weaponTooltipClass, unequipPotion, handleItemDrop, (1 : UInt),
			equippedPotionClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		mEventComponent.addListener("OnSteamInputGlyphsChanged", onSteamInputGlyphsChanged);
		mEventComponent.addListener("ControllerConnectionChangedEvent", onControllerConnectionChanged);
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
		mEquipSlots = new Vector<EquipSlot>();
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.coerce((mRoot : ASAny).empty_z, flash.display.MovieClip), this.handleItemDrop, (0 : UInt)));
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.coerce((mRoot : ASAny).empty_x, flash.display.MovieClip), this.handleItemDrop, (1 : UInt)));
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

	public function unequipPotion(info:StackableInfo, itemSlot:UInt, responseFinishedCallback:ASFunction = null, errorCallback:ASFunction = null) {
		var equippingModal:DBUIPopup;
		var equipServiceResponse:ASFunction;
		var avatarInfo = selectedAvatarInfo;
		if (avatarInfo != null) {
			equippingModal = createEquippingModal();
			equipServiceResponse = function() {
				equippingModal.destroy();
				if (responseFinishedCallback != null) {
					responseFinishedCallback();
				}
			};
			mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(avatarInfo.id, info.gmStackable.Id, itemSlot, equipServiceResponse,
				closeEquippingModalOnError(equippingModal, errorCallback));
		}
	}

	public function equipPotionOnCurrentAvatar(info:StackableInfo, itemSlot:UInt, swapping:Bool = false, responseFinishedCallback:ASFunction = null,
			errorCallback:ASFunction = null):Bool {
		var equipServiceResponse:ASFunction;
		var equippingModal:DBUIPopup = null;
		var avatarId:UInt;
		var popup:DBUIOneButtonPopup;
		var avatarInfo = selectedAvatarInfo;
		if (avatarInfo != null) {
			equipServiceResponse = function() {
				equippingModal.destroy();
				if (responseFinishedCallback != null) {
					responseFinishedCallback();
				}
			};
			if (swapping || mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(avatarInfo, itemSlot, info.gmId)) {
				equippingModal = createEquippingModal();
				avatarId = avatarInfo.id;
				mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar(avatarId, info.gmStackable.Id, itemSlot, swapping, equipServiceResponse,
					closeEquippingModalOnError(equippingModal, errorCallback));
				return true;
			}
			popup = new DBUIOneButtonPopup(mDBFacade, "STACK_NOT_ALLOWED_POPUP", Locale.getString("STACK_NOT_ALLOWED_TITLE"),
				Locale.getString("STACK_NOT_ALLOWED_MESSAGE"), Locale.getString("CANCEL"), null);
			MemoryTracker.track(popup, "DBUIOneButtonPopup - created in StacksWithEquipPicker.tryEquip()");
		}
		return false;
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

	function equippedPotionClicked(equipElement:ConsumableEquipElement) {
		deselectEquipment();
		if (mClickedEquippedWeaponCallback != null && equipElement.itemInfo != null) {
			equipElement.select();
			mClickedEquippedWeaponCallback(equipElement.itemInfo, equipElement);
		}
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
		hideAndUnloadControllerIcons();
		mEventComponent.destroy();
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mDBFacade = null;
		super.destroy();
	}

	function onSteamInputGlyphsChanged(event:Event) {
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
	}

	function onControllerConnectionChanged(event:Event) {
		hideAndUnloadControllerIcons();
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initControllerIcons();
		}
	}

	public function hideAndUnloadControllerIcons() {
		hideControllerIcons();
		var _loc2_:String;
		final __ax4_iter_486 = mGlyphFilePathToControllerIconData;
		if (checkNullIteratee(__ax4_iter_486))
			for (_tmp_ in __ax4_iter_486.keys()) {
				_loc2_ = _tmp_;
				mGlyphFilePathToControllerIconData.remove(_loc2_);
			}
		var _loc1_:ConsumableEquipElement;
		final __ax4_iter_487 = mEquipElements;
		if (checkNullIteratee(__ax4_iter_487))
			for (_tmp_ in __ax4_iter_487) {
				_loc1_ = _tmp_;
				_loc1_.setLabelAsText();
			}
	}

	function hideControllerIcons() {
		var _loc2_:ControllerIconData = null;
		var _loc1_:String;
		final __ax4_iter_488 = mGlyphFilePathToControllerIconData;
		if (checkNullIteratee(__ax4_iter_488))
			for (_tmp_ in __ax4_iter_488.keys()) {
				_loc1_ = _tmp_;
				_loc2_ = ASCompat.coerce(ASDictionary.getString(mGlyphFilePathToControllerIconData, _loc1_), uI.ControllerIconData);
				if (!_loc2_.mIsHidden) {
					if (_loc2_.mOwner.contains(_loc2_.mControllerGlyph)) {
						_loc2_.mOwner.removeChild(_loc2_.mControllerGlyph);
					}
					_loc2_.mIsHidden = true;
				}
			}
	}

	function initControllerIcons() {
		var _loc1_ = (0 : UInt);
		hideAndUnloadControllerIcons();
		var _loc2_ = new Vector<String>();
		_loc2_.push("use_consumable_one");
		_loc2_.push("use_consumable_two");
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mEquipElements.length:UInt) && _loc1_ < (_loc2_.length:UInt)) {
			initControllerIcon(mEquipElements[(_loc1_ : Int)], _loc2_[(_loc1_ : Int)]);
			_loc1_++;
		}
	}

	function initControllerIcon(equipElement:ConsumableEquipElement, actionName:String) {
		var glyphFilePath = mDBFacade.steamInputManager.getGlyphFilePathForAction(actionName);
		if (glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1") {
			equipElement.setLabelAsText();
			return;
		}
		mAssetLoadingComponent.getImageAsset(glyphFilePath, function(param1:brain.assetRepository.ImageAsset) {
			var _loc2_ = param1.image;
			var _loc3_:DisplayObject = new Bitmap(_loc2_.bitmapData);
			_loc3_.x = CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS.x;
			_loc3_.y = CONTROLLER_ICON_POSITION_FOR_STACK_BUTTONS.y;
			_loc3_.width = CONTROLLER_GLYPH_SCALE_STACK_BUTTONS.x;
			_loc3_.height = CONTROLLER_GLYPH_SCALE_STACK_BUTTONS.y;
			equipElement.setLabelAsControllerGlyph(_loc3_);
			mGlyphFilePathToControllerIconData[glyphFilePath] = new ControllerIconData(_loc3_, equipElement.root, false);
		}, null, false);
	}

	public function show() {
		mRoot.visible = true;
	}

	public function hide() {
		mRoot.visible = false;
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

	@:isVar var selectedGMHero(get, never):GMHero;

	function get_selectedGMHero():GMHero {
		var _loc2_ = mDBFacade.gameMaster.Heroes;
		var _loc1_ = selectedHeroIndex;
		return _loc1_ >= 0 && _loc1_ < _loc2_.length ? _loc2_[_loc1_] : null;
	}

	@:isVar var selectedAvatarInfo(get, never):AvatarInfo;

	function get_selectedAvatarInfo():AvatarInfo {
		var _loc1_ = selectedGMHero;
		return _loc1_ != null ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc1_.Id) : null;
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

	public function refresh(resync:Bool = false) {
		if (selectedHeroIndex == -1 || resync) {
			setActiveAvatarAsCurrentSelection();
		}
		if ((selectedHeroIndex : UInt) < mCurrentStartIndex || (selectedHeroIndex : UInt) >= mCurrentStartIndex + mHeroSlots.length) {
			setCurrentIndexToShowSelectedHero();
		}
		populateHeroSlots();
		setEquipSlots();
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

	function setEquipSlots() {
		var _loc5_ = (0 : UInt);
		var _loc3_:GMStackable = null;
		var _loc1_:Vector<Consumable> = /*undefined*/ null;
		var _loc2_ = 0;
		if (selectedGMHero == null) {
			return;
		}
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mEquipElements.length:UInt)) {
			mEquipElements[(_loc5_ : Int)].clear();
			_loc5_++;
		}
		var _loc4_ = selectedAvatarInfo;
		if (_loc4_ != null) {
			_loc1_ = _loc4_.equippedConsumables;
			_loc5_ = (0 : UInt);
			while (_loc5_ < (mEquipElements.length:UInt)) {
				if (_loc5_ >= (_loc1_.length : UInt)) {
					break;
				}
				if (_loc1_[(_loc5_ : Int)].stackId != 0) {
					_loc2_ = _loc1_[(_loc5_ : Int)].stackSlot;
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.stackableById.itemFor(_loc1_[(_loc5_ : Int)].stackId), gameMasterDictionary.GMStackable);
					if (_loc2_ >= mEquipElements.length || _loc2_ < 0) {
						Logger.warn("Stackable id: " + _loc3_.Id + " is equipped to an invalid slot: " + _loc1_[(_loc5_ : Int)].stackSlot);
					} else {
						mEquipElements[_loc2_].init(_loc3_, _loc1_[(_loc5_ : Int)].stackSlot, _loc1_[(_loc5_ : Int)].stackCount);
					}
				}
				_loc5_++;
			}
		}
	}

	public function highlightItem(info:InventoryBaseInfo) {
		var _loc2_:ConsumableEquipElement = null;
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

	public function getFirstUIObject():UIObject {
		return mHeroSlots[0];
	}

	public function setupMenuNavigation(returnObject:UIObject) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mEquipElements.length:UInt)) {
			mEquipElements[(_loc2_ : Int)].upNavigation = returnObject;
			if (_loc2_ > 0) {
				mEquipElements[(_loc2_ - 1 : Int)].isToTheLeftOf(mEquipElements[(_loc2_ : Int)]);
			}
			_loc2_++;
		}
		if (mEquipElements.length > 0) {
			mEquipElements[mEquipElements.length - 1].isToTheLeftOf(mHeroSlots[0]);
		}
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
		mFirstSlotLeftNavigation = mEquipElements.length > 0 ? mEquipElements[mEquipElements.length - 1] : null;
		updateFirstSlotLeftNavigation();
	}

	public function resetMenuNavigation() {
		mFirstSlotLeftNavigation = null;
		var _loc2_:UIObject;
		final __ax4_iter_489 = mEquipElements;
		if (checkNullIteratee(__ax4_iter_489))
			for (_tmp_ in __ax4_iter_489) {
				_loc2_ = _tmp_;
				_loc2_.clearNavigationAndInteractions();
			}
		var _loc1_:UIObject;
		final __ax4_iter_490 = mHeroSlots;
		if (checkNullIteratee(__ax4_iter_490))
			for (_tmp_ in __ax4_iter_490) {
				_loc1_ = _tmp_;
				_loc1_.clearNavigationAndInteractions();
			}
	}

	public function handleItemDrop(dropObject:UIObject, stackInfo:StackableInfo, equipSlot:UInt):Bool {
		var equipElement:ConsumableEquipElement;
		var uiInvItem = ASCompat.reinterpretAs(dropObject, UIInventoryItem);
		if (uiInvItem != null && uiInvItem.info != null && ASCompat.reinterpretAs(uiInvItem.info, StackableInfo) != null) {
			if (uiInvItem.info.gmId == DBGlobal.RESSURECTION_POTION_STACK_ID
				|| uiInvItem.info.gmId == DBGlobal.PARTYBOMB_POTION_STACK_ID) {
				return false;
			}
			if (!this.equipPotionOnCurrentAvatar(cast(uiInvItem.info, StackableInfo), equipSlot, false, mEquipResponseCallback)) {
				return false;
			}
			uiInvItem.dragSwapItem(stackInfo);
			return true;
		}
		equipElement = ASCompat.reinterpretAs(dropObject, ConsumableEquipElement);
		if (equipElement != null && equipElement.itemInfo != null) {
			equipElement.reset();
			if (equipElement.equipSlot == equipSlot) {
				return true;
			}
			this.equipPotionOnCurrentAvatar(equipElement.stackableInfo, equipSlot, true, function() {}, mEquipResponseCallback);
			return true;
		}
		return false;
	}
}
