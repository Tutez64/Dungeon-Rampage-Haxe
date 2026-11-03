package uI.inventory;

import account.InventoryBaseInfo;
import account.ItemInfo;
import account.StackableInfo;
import brain.assetRepository.SwfAsset;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUIPopup;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

class EquipItemToSlotPopup extends DBUIPopup {
	static inline final POPUP_SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final EQUIP_POPUP_CLASS_NAME = "popup_equip";

	static inline final CONTROLLER_GLYPH_X:Float = 13;

	static inline final CONTROLLER_GLYPH_Y:Float = -50;

	static inline final CONTROLLER_GLYPH_SCALE:Float = 0.2;

	var mAvatarInstanceId:Int = 0;

	var mClosePopupCallback:ASFunction;

	var mNotAllowedCallback:ASFunction;

	var mItemInfoToEquip:InventoryBaseInfo;

	var mSceneGraphComponent:SceneGraphComponent;

	var mEquipPopupRoot:MovieClip;

	var mTitleLabel:TextField;

	var mMessageLabel:TextField;

	var mEquipSlot0:UIButton;

	var mEquipSlot1:UIButton;

	var mEquipSlot2:UIButton;

	var mEquipSlot0Tooltip:UIWeaponTooltip;

	var mEquipSlot1Tooltip:UIWeaponTooltip;

	var mEquipSlot2Tooltip:UIWeaponTooltip;

	var mIsConsumable:Bool = false;

	public function new(dbFacade:DBFacade, avatarInstanceId:Int, closePopupCallback:ASFunction, itemInfoToEquip:InventoryBaseInfo,
			notAllowedCallback:ASFunction = null, isConsumable:Bool = false) {
		mDBFacade = dbFacade;
		mAvatarInstanceId = avatarInstanceId;
		mClosePopupCallback = closePopupCallback;
		mNotAllowedCallback = notAllowedCallback;
		mItemInfoToEquip = itemInfoToEquip;
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "EquipItemToSlotPopup");
		mIsConsumable = isConsumable;
		super(dbFacade, "EQUIP_ITEM_TO_SLOT_POPUP", "", null, true, true, closePopupCallback, false);
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		mSwfAsset = swfAsset;
		var _loc7_ = swfAsset.getClass("popup_equip");
		mEquipPopupRoot = ASCompat.coerce(ASCompat.createInstance(_loc7_, []), flash.display.MovieClip);
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).close, flash.display.MovieClip));
		mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mCloseButton.releaseCallback = mClosePopupCallback;
		mRoot.addChild(mEquipPopupRoot);
		mTitleLabel = ASCompat.dynamicAs((mEquipPopupRoot : ASAny).title_label, TextField);
		Locale.setText(mTitleLabel, "EQUIP_POPUP_TITLE");
		mMessageLabel = ASCompat.dynamicAs((mEquipPopupRoot : ASAny).message_label, TextField);
		Locale.setText(mMessageLabel, "EQUIP_POPUP_MESSAGE");
		ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_weapons, "visible", false);
		ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_potions, "visible", false);
		ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_pets, "visible", false);
		mSceneGraphComponent.addChild(mRoot, (105 : UInt));
		refresh();
		mRoot.scaleY = mRoot.scaleX = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		var _loc6_ = mRoot.getBounds(mDBFacade.scalingRoot);
		mRoot.x = mDBFacade.viewWidth / 2 - _loc6_.width / 2 - _loc6_.x;
		mRoot.y = mDBFacade.viewHeight / 2 - _loc6_.height / 2 - _loc6_.y;
		setupControllerGlyphs();
	}

	function refresh() {
		if (mEquipPopupRoot == null) {
			return;
		}
		if (mAvatarInstanceId != -1) {
			if (mIsConsumable) {
				refreshAvatarConsumableSlots();
			} else {
				refreshAvatarWeaponSlots();
			}
		}
	}

	function refreshAvatarConsumableSlots() {
		var equippedItem:StackableInfo;
		var equippedItemInfo0:StackableInfo = null;
		var equippedItemInfo1:StackableInfo = null;
		var avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId((mAvatarInstanceId : UInt));
		var equippedItems = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedConsumablesOnAvatar(avatarInfo);
		var i = (0 : UInt);
		while (i < (equippedItems.length:UInt)) {
			equippedItem = equippedItems[(i : Int)];
			switch (equippedItem.consumableSlot) {
				case 0:
					equippedItemInfo0 = equippedItem;

				case 1:
					equippedItemInfo1 = equippedItem;
			}
			i = i + 1;
		}
		ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_potions, "visible", true);
		mEquipSlot0 = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).UI_potions.equip_slot_0, flash.display.MovieClip));
		mEquipSlot0.label.visible = true;
		mEquipSlot0.label.text = mDBFacade.keyBindings.displayNameFor("useConsumable1");
		mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mEquipSlot0.root : ASAny).selected, "visible", false);
		ASCompat.setProperty((mEquipSlot0.root : ASAny).quantity, "visible", false);
		ASCompat.setProperty((mEquipSlot0.root : ASAny).textx, "visible", false);
		mEquipSlot0.releaseCallback = function() {
			equipToAvatarConsumableSlot((0 : UInt));
		};
		if (equippedItemInfo0 != null) {
			ItemInfo.loadItemIconFromId(equippedItemInfo0.gmId, ASCompat.coerce((mEquipSlot0.root : ASAny).graphic, flash.display.DisplayObjectContainer),
				mDBFacade, (70 : UInt), (ASCompat.floatToInt(equippedItemInfo0.iconScale) : UInt), mAssetLoadingComponent);
			ASCompat.setProperty((mEquipSlot0.root : ASAny).quantity, "visible", true);
			TextUtil.setText(ASCompat.coerce((mEquipSlot0.root : ASAny).quantity, flash.text.TextField), Std.string(equippedItemInfo0.count));
			ASCompat.setProperty((mEquipSlot0.root : ASAny).textx, "visible", true);
		}
		mEquipSlot1 = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).UI_potions.equip_slot_1, flash.display.MovieClip));
		mEquipSlot1.label.visible = true;
		mEquipSlot1.label.text = mDBFacade.keyBindings.displayNameFor("useConsumable2");
		mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mEquipSlot1.root : ASAny).selected, "visible", false);
		ASCompat.setProperty((mEquipSlot1.root : ASAny).quantity, "visible", false);
		ASCompat.setProperty((mEquipSlot1.root : ASAny).textx, "visible", false);
		mEquipSlot1.releaseCallback = function() {
			equipToAvatarConsumableSlot((1 : UInt));
		};
		if (equippedItemInfo1 != null) {
			ItemInfo.loadItemIconFromId(equippedItemInfo1.gmId, ASCompat.coerce((mEquipSlot1.root : ASAny).graphic, flash.display.DisplayObjectContainer),
				mDBFacade, (70 : UInt), (ASCompat.floatToInt(equippedItemInfo1.iconScale) : UInt), mAssetLoadingComponent);
			ASCompat.setProperty((mEquipSlot1.root : ASAny).quantity, "visible", true);
			TextUtil.setText(ASCompat.coerce((mEquipSlot1.root : ASAny).quantity, flash.text.TextField), Std.string(equippedItemInfo1.count));
			ASCompat.setProperty((mEquipSlot1.root : ASAny).textx, "visible", true);
		}
		animatedEntrance();
	}

	override function setupMenuNavigation() {
		var _loc1_ = (0 : UInt);
		var _loc2_ = getEquipSlots();
		if (_loc2_.length == 0) {
			return;
		}
		mCloseButton.clearNavigationAndInteractions();
		mCloseButton.downNavigation = _loc2_[0];
		_loc1_ = (0 : UInt);
		while (_loc1_ < (_loc2_.length:UInt)) {
			_loc2_[(_loc1_ : Int)].clearNavigationAndInteractions();
			_loc2_[(_loc1_ : Int)].upNavigation = mCloseButton;
			if (_loc1_ > 0) {
				_loc2_[(_loc1_ - 1 : Int)].isToTheLeftOf(_loc2_[(_loc1_ : Int)]);
			}
			_loc1_++;
		}
	}

	override function getNavigationExitCallback():ASFunction {
		return mClosePopupCallback;
	}

	override function getInitialFocusedNavigationObject():UIObject {
		var _loc1_ = getEquipSlots();
		return _loc1_.length > 0 ? _loc1_[0] : mCloseButton;
	}

	function setupControllerGlyphs() {
		var _loc1_ = (0 : UInt);
		if (!mDBFacade.steamInputManager.isSteamInputReady) {
			return;
		}
		var _loc2_ = getEquipSlots();
		var _loc3_ = new Vector<String>();
		if (mIsConsumable) {
			_loc3_.push("use_consumable_one");
			_loc3_.push("use_consumable_two");
		} else {
			_loc3_.push("attack_weapon_1");
			_loc3_.push("attack_weapon_2");
			_loc3_.push("attack_weapon_3");
		}
		_loc1_ = (0 : UInt);
		while (_loc1_ < (_loc2_.length:UInt) && _loc1_ < (_loc3_.length:UInt)) {
			loadControllerGlyph(_loc2_[(_loc1_ : Int)], _loc3_[(_loc1_ : Int)]);
			_loc1_++;
		}
	}

	function loadControllerGlyph(equipSlot:UIButton, actionName:String) {
		var glyphFilePath = mDBFacade.steamInputManager.getGlyphFilePathForAction(actionName);
		if (glyphFilePath == null || glyphFilePath == "" || glyphFilePath == "error1") {
			return;
		}
		mAssetLoadingComponent.getImageAsset(glyphFilePath, function(param1:brain.assetRepository.ImageAsset) {
			if (param1 == null || equipSlot == null || equipSlot.root == null) {
				return;
			}
			var _loc2_ = param1.image;
			var _loc3_:DisplayObject = new Bitmap(_loc2_.bitmapData);
			_loc3_.x = 13;
			_loc3_.y = -50;
			_loc3_.scaleX = _loc3_.scaleY = 0.2;
			equipSlot.label.visible = false;
			equipSlot.root.addChild(_loc3_);
		}, null, false);
	}

	function getEquipSlots():Vector<UIButton> {
		var _loc1_ = new Vector<UIButton>();
		if (mEquipSlot0 != null) {
			_loc1_.push(mEquipSlot0);
		}
		if (mEquipSlot1 != null) {
			_loc1_.push(mEquipSlot1);
		}
		if (mEquipSlot2 != null) {
			_loc1_.push(mEquipSlot2);
		}
		return _loc1_;
	}

	function refreshAvatarWeaponSlots() {
		var equippedItems:Vector<ItemInfo>;
		var equippedItem:ItemInfo;
		var equippedItemInfo0:ItemInfo = null;
		var equippedItemInfo1:ItemInfo = null;
		var equippedItemInfo2:ItemInfo = null;
		var i:UInt;
		ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_weapons, "visible", true);
		equippedItems = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar((mAvatarInstanceId : UInt));
		i = (0 : UInt);
		while (i < (equippedItems.length:UInt)) {
			equippedItem = equippedItems[(i : Int)];
			switch (equippedItem.avatarSlot) {
				case 0:
					equippedItemInfo0 = equippedItem;

				case 1:
					equippedItemInfo1 = equippedItem;

				case 2:
					equippedItemInfo2 = equippedItem;
			}
			i = i + 1;
		}
		if (mEquipSlot0 == null) {
			mEquipSlot0 = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_0, flash.display.MovieClip));
		}
		mEquipSlot0.label.text = "J";
		mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mEquipSlot0.root : ASAny).selected, "visible", false);
		mEquipSlot0.releaseCallback = function() {
			equipToAvatarWeaponSlot((0 : UInt));
		};
		if (equippedItemInfo0 != null) {
			ItemInfo.loadItemIconFromItemInfo(equippedItemInfo0, ASCompat.coerce((mEquipSlot0.root : ASAny).graphic, flash.display.DisplayObjectContainer),
				mDBFacade, (70 : UInt), (ASCompat.floatToInt(equippedItemInfo0.iconScale) : UInt), mAssetLoadingComponent);
			if (mEquipSlot0Tooltip == null) {
				mEquipSlot0Tooltip = new UIWeaponTooltip(mDBFacade, mSwfAsset.getClass("DR_weapon_equip_tooltip"));
				mEquipSlot0.tooltip = mEquipSlot0Tooltip;
			}
			mEquipSlot0Tooltip.setWeaponItemFromItemInfo(equippedItemInfo0);
		}
		if (mEquipSlot1 == null) {
			mEquipSlot1 = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_1, flash.display.MovieClip));
		}
		mEquipSlot1.label.text = "K";
		mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mEquipSlot1.root : ASAny).selected, "visible", false);
		mEquipSlot1.releaseCallback = function() {
			equipToAvatarWeaponSlot((1 : UInt));
		};
		if (equippedItemInfo1 != null) {
			ItemInfo.loadItemIconFromItemInfo(equippedItemInfo1, ASCompat.coerce((mEquipSlot1.root : ASAny).graphic, flash.display.DisplayObjectContainer),
				mDBFacade, (70 : UInt), (ASCompat.floatToInt(equippedItemInfo1.iconScale) : UInt), mAssetLoadingComponent);
			if (mEquipSlot1Tooltip == null) {
				mEquipSlot1Tooltip = new UIWeaponTooltip(mDBFacade, mSwfAsset.getClass("DR_weapon_equip_tooltip"));
				mEquipSlot1.tooltip = mEquipSlot1Tooltip;
			}
			mEquipSlot1Tooltip.setWeaponItemFromItemInfo(equippedItemInfo1);
		}
		if (mEquipSlot2 == null) {
			mEquipSlot2 = new UIButton(mDBFacade, ASCompat.coerce((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_2, flash.display.MovieClip));
		}
		mEquipSlot2.label.text = "L";
		mEquipSlot2.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mEquipSlot2.root : ASAny).selected, "visible", false);
		mEquipSlot2.releaseCallback = function() {
			equipToAvatarWeaponSlot((2 : UInt));
		};
		if (equippedItemInfo2 != null) {
			ItemInfo.loadItemIconFromItemInfo(equippedItemInfo2, ASCompat.coerce((mEquipSlot2.root : ASAny).graphic, flash.display.DisplayObjectContainer),
				mDBFacade, (70 : UInt), (ASCompat.floatToInt(equippedItemInfo2.iconScale) : UInt), mAssetLoadingComponent);
			if (mEquipSlot2Tooltip == null) {
				mEquipSlot2Tooltip = new UIWeaponTooltip(mDBFacade, mSwfAsset.getClass("DR_weapon_equip_tooltip"));
				mEquipSlot2.tooltip = mEquipSlot2Tooltip;
			}
			mEquipSlot2Tooltip.setWeaponItemFromItemInfo(equippedItemInfo2);
		}
		animatedEntrance();
	}

	function showNotAllowedPopup() {
		var popup:DBUIOneButtonPopup = null;
		var closePopup:ASFunction = function() {
			if (popup != null) {
				popup.destroy();
				popup = null;
			}
		};
		popup = new DBUIOneButtonPopup(mDBFacade, "EQUIP_ITEM_NOT_ALLOWED_POPUP", Locale.getString("STACK_NOT_ALLOWED_TITLE"),
			Locale.getString("STACK_NOT_ALLOWED_MESSAGE"), Locale.getString("CANCEL"), function() {
				if (mNotAllowedCallback != null) {
					mNotAllowedCallback();
				}
				closePopup();
		}, true, closePopup);
		MemoryTracker.track(popup, "DBUIOneButtonPopup - created in EquipItemToSlotPopup.showNotAllowedPopup()");
	}

	function equipToAvatarWeaponSlot(slotIndex:UInt) {
		mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar((mAvatarInstanceId : UInt), mItemInfoToEquip.databaseId, slotIndex, mClosePopupCallback);
	}

	function equipToAvatarConsumableSlot(slotIndex:UInt) {
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId((mAvatarInstanceId : UInt));
		var _loc3_ = ASCompat.reinterpretAs(mItemInfoToEquip, StackableInfo);
		if (mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(_loc2_, slotIndex, _loc3_.gmId)) {
			mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar((mAvatarInstanceId : UInt), _loc3_.gmStackable.Id, slotIndex, false,
				mClosePopupCallback);
		} else {
			showNotAllowedPopup();
		}
	}

	override public function destroy() {
		if (mEquipSlot0 != null) {
			mEquipSlot0.destroy();
		}
		if (mEquipSlot1 != null) {
			mEquipSlot1.destroy();
		}
		if (mEquipSlot2 != null) {
			mEquipSlot2.destroy();
		}
		mEquipSlot0 = null;
		mEquipSlot1 = null;
		mEquipSlot2 = null;
		mSceneGraphComponent.destroy();
		super.destroy();
	}
}
