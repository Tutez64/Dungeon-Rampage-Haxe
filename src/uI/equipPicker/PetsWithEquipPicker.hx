package uI.equipPicker;

import account.AvatarInfo;
import account.InventoryBaseInfo;
import account.PetInfo;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIPopup;
import facade.DBFacade;
import facade.Locale;
import uI.inventory.UIInventoryItem;
import flash.display.MovieClip;

class PetsWithEquipPicker extends UIObject {
	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mHeroSlots:Vector<HeroElement>;

	var mEquipElements:Vector<AvatarEquipElement>;

	var mEquipSlots:Vector<EquipSlot>;

	var mClickedEquippedPetCallback:ASFunction;

	var mSetSelectedHeroCallback:ASFunction;

	var mGetSelectedHeroCallback:ASFunction;

	var mCurrentStartIndex:UInt = (0 : UInt);

	var mEquipResponseCallback:ASFunction;

	var mTotalGMHeroes:UInt = 0;

	var mSelectedHeroIndex:Int = -1;

	var mShiftLeft:UIButton;

	var mShiftRight:UIButton;

	public function new(dbFacade:DBFacade, root:MovieClip, weaponTooltipClass:Dynamic, heroTooltipClass:Dynamic, clickedEquippedPetCallback:ASFunction = null,
			getSelectedHeroIndexCallback:ASFunction = null, setSelectedHeroIndexCallback:ASFunction = null, equipResponseFinishedCallback:ASFunction = null,
			allowEquipmentSwapping:Bool = false) {
		super(dbFacade, root);
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		mClickedEquippedPetCallback = clickedEquippedPetCallback;
		mEquipResponseCallback = equipResponseFinishedCallback;
		mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
		mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
		ASCompat.setProperty((mRoot : ASAny).label, "text", Locale.getString("PET_PICKER_LABEL"));
		mEquipElements = new Vector<AvatarEquipElement>();
		mEquipElements.push(new AvatarEquipElement(mDBFacade, "", ASCompat.dynamicAs((mRoot : ASAny).UI_pet.equip_slot_1, flash.display.MovieClip),
			weaponTooltipClass, unequipPet, handleItemDrop, (0 : UInt), equippedPetClicked, equipResponseFinishedCallback, allowEquipmentSwapping));
		ASCompat.setProperty((mRoot : ASAny).UI_pet.equip_slot_0, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).UI_pet.equip_slot_2, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).empty_z, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).empty_c, "visible", false);
		mEquipSlots = new Vector<EquipSlot>();
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).empty_z, flash.display.MovieClip), this.handleItemDrop, (0 : UInt)));
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).empty_x, flash.display.MovieClip), this.handleItemDrop, (1 : UInt)));
		mEquipSlots.push(new EquipSlot(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).empty_c, flash.display.MovieClip), this.handleItemDrop, (2 : UInt)));
		mHeroSlots = new Vector<HeroElement>();
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_0, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_1, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_2, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_3, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_4, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_5, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_6, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mHeroSlots.push(new HeroElement(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).hero_slot_7, flash.display.MovieClip), heroTooltipClass, heroClicked));
		mShiftLeft = new UIButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).shift_left, flash.display.MovieClip));
		mShiftLeft.releaseCallback = shiftLeft;
		mShiftRight = new UIButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).shift_right, flash.display.MovieClip));
		mShiftRight.releaseCallback = shiftRight;
		mShiftLeft.visible = false;
		mShiftRight.visible = false;
		mTotalGMHeroes = (mDBFacade.gameMaster.Heroes.length : UInt);
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			refresh();
		});
	}

	function populateHeroSlots() {
		var _loc2_ = 0;
		var _loc3_ = mDBFacade.gameMaster.Heroes;
		var _loc1_ = mCurrentStartIndex;
		_loc2_ = 0;
		while (_loc2_ < mHeroSlots.length) {
			mHeroSlots[_loc2_].clear();
			if (_loc1_ < (_loc3_.length:UInt)
				&& (!_loc3_[(_loc1_ : Int)].Hidden || mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes", false))) {
				mHeroSlots[_loc2_].gmHero = _loc3_[(_loc1_ : Int)];
			} else {
				mHeroSlots[_loc2_].enabled = false;
			}
			_loc1_++;
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		updateShiftButtons();
		determineSelectedElement();
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
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mHeroSlots.length) {
			if (ASCompat.toNumber(_loc1_ + mCurrentStartIndex) == selectedHeroIndex) {
				mHeroSlots[_loc1_].select();
			} else {
				mHeroSlots[_loc1_].deselect();
			}
			_loc1_ = ASCompat.toInt(_loc1_) + 1;
		}
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

	function equippedPetClicked(equipElement:AvatarEquipElement) {
		deselectEquipment();
		if (mClickedEquippedPetCallback != null && equipElement.itemInfo != null) {
			equipElement.select();
			mClickedEquippedPetCallback(equipElement.itemInfo);
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
		setEquipSlots();
		populateHeroSlots();
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

	function setCurrentIndexToShowSelectedHero() {
		if (selectedHeroIndex < mHeroSlots.length) {
			mCurrentStartIndex = (0 : UInt);
			return;
		}
		mCurrentStartIndex = (selectedHeroIndex - (mHeroSlots.length - 1) : UInt);
	}

	function findHeroIndex(avatarId:UInt):UInt {
		var _loc2_ = 0;
		var _loc3_ = mDBFacade.gameMaster.Heroes;
		_loc2_ = 0;
		while (_loc2_ < _loc3_.length) {
			if (avatarId == _loc3_[_loc2_].Id) {
				return (_loc2_ : UInt);
			}
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		Logger.error("Unable to find gmHero for active avatar Id: " + avatarId);
		return (0 : UInt);
	}

	function setEquipSlots() {
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < mEquipElements.length) {
			mEquipElements[_loc3_].clear();
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		var _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.gameMaster.Heroes[selectedHeroIndex].Id);
		if (_loc1_ == null) {
			return;
		}
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedPetsOnAvatar(_loc1_.id);
		if (_loc2_.length > 3) {
			Logger.warn("Avatar has more than three equipped pets.  Equipping first three.");
		}
		_loc3_ = 0;
		while (_loc3_ < mEquipElements.length) {
			if (_loc3_ >= _loc2_.length) {
				break;
			}
			if (_loc2_.length > _loc3_) {
				if (mEquipElements[_loc3_].itemInfo != null) {
					Logger.warn("Equipped items contains multiple items assigned to the same slot. First itemId: "
						+ mEquipElements[_loc3_].itemInfo.gmId + ". Second itemId: " + _loc2_[_loc3_].gmId);
				} else {
					mEquipElements[_loc3_].itemInfo = _loc2_[_loc3_];
				}
			}
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
	}

	public function equipPetOnCurrentAvatar(info:InventoryBaseInfo, responseFinishedCallback:ASFunction = null, errorCallback:ASFunction = null) {
		var doEquip:ASFunction;
		var equippedItems:Vector<PetInfo>;
		var avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
		if (avatarInfo != null) {
			doEquip = function() {
				var equippingModal:UIPopup = null;
				var equipServiceResponse:ASFunction = function() {
					equippingModal.destroy();
					if (responseFinishedCallback != null) {
						responseFinishedCallback();
					}
				};
				equippingModal = UIPopup.show(mDBFacade, Locale.getString("EQUIPPING_MODAL"));
				var avatarId = avatarInfo.id;
				mDBFacade.dbAccountInfo.inventoryInfo.equipPetOnAvatar(avatarId, info.databaseId, equipServiceResponse, errorCallback);
				if (mDBFacade.steamAchievementsManager != null) {
					mDBFacade.steamAchievementsManager.setAchievement("EQUIP_PET");
				}
			};
			equippedItems = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedPetsOnAvatar(avatarInfo.id);
			if (equippedItems.length > 0) {
				unequipPet(equippedItems[0], doEquip, errorCallback);
			} else {
				doEquip();
			}
		}
	}

	public function unequipPet(info:PetInfo, responseFinishedCallback:ASFunction = null, errorCallback:ASFunction = null) {
		var equippingModal = UIPopup.show(mDBFacade, Locale.getString("EQUIPPING_MODAL"));
		var equipServiceResponse:ASFunction = function() {
			equippingModal.destroy();
			if (responseFinishedCallback != null) {
				responseFinishedCallback();
			}
		};
		mDBFacade.dbAccountInfo.inventoryInfo.unequipPet(info, equipServiceResponse, errorCallback);
	}

	public function highlightItem(info:InventoryBaseInfo) {}

	public function deselectEquipment() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mEquipElements.length) {
			mEquipElements[_loc1_].deselect();
			_loc1_ = ASCompat.toInt(_loc1_) + 1;
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

	public function handleItemDrop(dropObject:UIObject, petInfo:InventoryBaseInfo, equipSlot:UInt):Bool {
		var uiInvItem:UIInventoryItem;
		var equipElement:AvatarEquipElement;
		if (dropObject == null) {
			this.equipPetOnCurrentAvatar(petInfo, mEquipResponseCallback);
			return true;
		}
		uiInvItem = ASCompat.reinterpretAs(dropObject, UIInventoryItem);
		if (uiInvItem != null && uiInvItem.info != null && Std.isOfType(uiInvItem.info, PetInfo)) {
			this.equipPetOnCurrentAvatar(cast(uiInvItem.info, PetInfo), mEquipResponseCallback);
			uiInvItem.dragSwapItem(petInfo);
			return true;
		}
		equipElement = ASCompat.reinterpretAs(dropObject, AvatarEquipElement);
		if (equipElement != null && equipElement.itemInfo != null) {
			equipElement.reset();
			if (equipElement.equipSlot == equipSlot) {
				return true;
			}
			this.equipPetOnCurrentAvatar(equipElement.itemInfo, function() {
				if (petInfo != null) {
					equipPetOnCurrentAvatar(petInfo, mEquipResponseCallback);
				} else {
					mEquipResponseCallback();
				}
			}, mEquipResponseCallback);
			return true;
		}
		return false;
	}
}
