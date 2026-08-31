package account;

import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMInventoryBase;
import gameMasterDictionary.GMLegendaryModifier;
import gameMasterDictionary.GMModifier;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

class ItemInfo extends InventoryBaseInfo {
	var mAvatarId:UInt = 0;

	var mAvatarSlot:UInt = 0;

	var mCreated:String;

	var mPower:UInt = 0;

	var mGMWeapon:GMWeaponItem;

	var mModifiers:Vector<GMModifier> = new Vector();

	var mLegendaryModifier:UInt = (0 : UInt);

	var mRarity:Float = Math.NaN;

	var mGMRarity:GMRarity;

	var mRequiredLevel:Float = Math.NaN;

	public function new(dbFacade:DBFacade, json:ASObject) {
		super(dbFacade, json);
		mGMWeapon = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mGMId), gameMasterDictionary.GMWeaponItem);
		if (mGMWeapon == null) {
			Logger.error("GMWeapon is null cannot find item for ID: " + mGMId);
		}
		mGMInventoryBase = mGMWeapon;
		mGMRarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
	}

	public static function loadItemIconFromId(itemId:UInt, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt, iconsNativeSize:UInt,
			assetLoadingComponent:AssetLoadingComponent = null) {
		var _loc7_:GMNpc = null;
		var _loc8_ = ASCompat.dynamicAs(dbFacade.gameMaster.stackableById.itemFor(itemId), gameMasterDictionary.GMInventoryBase);
		if (_loc8_ == null) {
			_loc7_ = ASCompat.dynamicAs(dbFacade.gameMaster.npcById.itemFor(itemId), gameMasterDictionary.GMNpc);
			if (_loc7_ == null) {
				Logger.error("Unable to find gmItem for item id: " + itemId);
				return;
			}
			loadItemIcon(_loc7_.IconSwfFilepath, _loc7_.IconName, container, dbFacade, desiredSize, iconsNativeSize, assetLoadingComponent);
			return;
		}
		loadItemIcon(_loc8_.UISwfFilepath, _loc8_.IconName, container, dbFacade, desiredSize, iconsNativeSize, assetLoadingComponent);
	}

	public static function loadItemIconFromItemInfo(itemInfo:ItemInfo, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt,
			iconsNativeSize:UInt, assetLoadingComponent:AssetLoadingComponent = null) {
		var bgColoredExists:Bool;
		var bgSwfPath:String;
		var bgIconName:String;
		loadItemIcon(itemInfo.uiSwfFilepath, itemInfo.iconName, container, dbFacade, desiredSize, iconsNativeSize, assetLoadingComponent);
		bgColoredExists = itemInfo.hasColoredBackground;
		bgSwfPath = itemInfo.backgroundSwfPath;
		bgIconName = itemInfo.backgroundIconName;
		if (bgColoredExists) {
			assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:brain.assetRepository.SwfAsset) {
				var _loc3_:MovieClip = null;
				var _loc2_ = param1.getClass(bgIconName);
				if (_loc2_ != null) {
					_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
					_loc3_.scaleX = _loc3_.scaleY = 0.85;
					container.addChildAt(_loc3_, 0);
				}
			});
		}
	}

	public static function loadItemIcon(swfPath:String, iconName:String, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt,
			iconsNativeSize:UInt, assetLoadingComponent:AssetLoadingComponent = null, onCompletionCallback:ASFunction = null) {
		var destroyAssetLoaderOnCompletion = false;
		if (assetLoadingComponent == null) {
			assetLoadingComponent = new AssetLoadingComponent(dbFacade);
			destroyAssetLoaderOnCompletion = true;
		}
		if (swfPath == null || swfPath == "") {
			Logger.error("swfPath provided to ItemInfo::loadItemIcon is empty or null.");
		}
		assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:brain.assetRepository.SwfAsset) {
			var _loc3_ = param1.getClass(iconName);
			if (_loc3_ == null) {
				Logger.error("Unable to get iconClass for iconName: " + iconName);
				return;
			}
			var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			if (iconsNativeSize == 0) {
				iconsNativeSize = (Std.int(_loc2_.width) : UInt);
			}
			_loc2_.scaleX = _loc2_.scaleY = desiredSize / iconsNativeSize;
			container.addChild(_loc2_);
			if (destroyAssetLoaderOnCompletion) {
				assetLoadingComponent.destroy();
			}
			if (onCompletionCallback != null) {
				onCompletionCallback();
			}
		});
	}

	override public function get_Description():String {
		var _loc1_ = this.gmWeaponAesthetic;
		return _loc1_ != null ? GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION", _loc1_.WeaponItemConstant) : "";
	}

	override public function get_iconScale():Float {
		return 100;
	}

	@:isVar public var power(get, never):UInt;

	public function get_power():UInt {
		return mPower;
	}

	@:isVar public var gmWeaponItem(get, never):GMWeaponItem;

	public function get_gmWeaponItem():GMWeaponItem {
		return mGMWeapon;
	}

	@:isVar public var gmWeaponAesthetic(get, never):GMWeaponAesthetic;

	public function get_gmWeaponAesthetic():GMWeaponAesthetic {
		return mGMWeapon.getWeaponAesthetic(requiredLevel, mLegendaryModifier > 0);
	}

	@:isVar public var requiredLevel(get, never):UInt;

	public function get_requiredLevel():UInt {
		return (Std.int(mRequiredLevel) : UInt);
	}

	@:isVar public var rarity(get, never):GMRarity;

	public function get_rarity():GMRarity {
		return mGMRarity;
	}

	override public function get_uiSwfFilepath():String {
		var _loc1_ = this.gmWeaponAesthetic;
		return _loc1_ != null ? _loc1_.IconSwf : null;
	}

	override public function get_iconName():String {
		var _loc1_ = this.gmWeaponAesthetic;
		return _loc1_ != null ? _loc1_.IconName : null;
	}

	override public function get_isEquipped():Bool {
		return this.gmWeaponItem != null && this.avatarId != 0;
	}

	@:isVar public var avatarId(get, set):UInt;

	public function get_avatarId():UInt {
		return mAvatarId;
	}

	function set_avatarId(id:UInt):UInt {
		return mAvatarId = id;
	}

	@:isVar public var avatarSlot(get, set):UInt;

	public function get_avatarSlot():UInt {
		return mAvatarSlot;
	}

	function set_avatarSlot(slot:UInt):UInt {
		return mAvatarSlot = slot;
	}

	override function parseJson(json:ASObject) {
		var _loc4_:GMModifier = null;
		var _loc2_:GMModifier = null;
		var _loc3_:GMLegendaryModifier = null;
		if (json == null) {
			return;
		}
		mGMId = ASCompat.asUint(json.item_id);
		mAccountId = ASCompat.asUint(json.account_id);
		mAvatarId = ASCompat.asUint(json.avatar_id);
		mDatabaseId = ASCompat.asUint(json.id);
		mAvatarSlot = ASCompat.asUint(json.avatar_slot);
		mCreated = ASCompat.asString(json.created);
		mPower = ASCompat.asUint(json.power);
		mIsNew = false;
		mRarity = ASCompat.toNumberField(json, "rarity");
		mRequiredLevel = ASCompat.toNumberField(json, "requiredlevel");
		if (ASCompat.toNumberField(json, "modifier1") > 0) {
			_loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(json.modifier1), gameMasterDictionary.GMModifier);
			if (_loc4_ != null) {
				mModifiers.push(_loc4_);
			} else {
				Logger.error("Bad modifier id: " + Std.string(json.modifier1));
			}
		}
		if (ASCompat.toNumberField(json, "modifier2") > 0) {
			_loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(json.modifier2), gameMasterDictionary.GMModifier);
			if (_loc2_ != null) {
				mModifiers.push(_loc2_);
			} else {
				Logger.error("Bad modifier id: " + Std.string(json.modifier2));
			}
		}
		if (ASCompat.toNumberField(json, "legendarymodifier") > 0) {
			_loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.legendaryModifiersById.itemFor(json.legendarymodifier), gameMasterDictionary.GMLegendaryModifier);
			if (_loc3_ != null) {
				mLegendaryModifier = _loc3_.Id;
			} else {
				Logger.error("Bad modifier id: " + Std.string(json.legendarymodifier));
			}
		}
	}

	override public function get_sellCoins():Int {
		var _loc5_:GMModifier;
		var __ax4_iter_8:Vector<GMModifier>;
		var _loc1_ = Math.NaN;
		var _loc7_ = mGMWeapon;
		var _loc3_ = mGMRarity;
		var _loc8_ = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(_loc3_.KeyOfferId), gameMasterDictionary.GMOffer);
		if (_loc8_ != null) {
			if (_loc8_.CoinOffer != null) {
				_loc8_ = _loc8_.CoinOffer;
			}
		}
		var _loc2_:Float = 0;
		var _loc4_:Float = 1;
		if (_loc3_.NumberOfModifiers > 0) {
			_loc4_ = _loc3_.NumberOfModifiers * 3;
			__ax4_iter_8 = mModifiers;
			if (checkNullIteratee(__ax4_iter_8))
				for (_tmp_ in __ax4_iter_8) {
					_loc5_ = _tmp_;
					_loc2_ += _loc5_.MODIFIER_LEVEL;
				}
		}
		var _loc6_ = mRequiredLevel / 100 * _loc3_.LevelWeight + _loc2_ * 1 / _loc4_ * _loc3_.ModifierWeight;
		if (_loc8_ != null) {
			_loc1_ = _loc8_.Price;
		}
		return Math.round(((_loc3_.MaxSellPercent - _loc3_.MinSellPercent) * _loc6_ + _loc3_.MinSellPercent) * _loc1_);
	}

	public function hasModifier(constant:String):Bool {
		var _loc2_:GMModifier;
		final __ax4_iter_9 = mModifiers;
		if (checkNullIteratee(__ax4_iter_9))
			for (_tmp_ in __ax4_iter_9) {
				_loc2_ = _tmp_;
				if (_loc2_.Constant == constant) {
					return true;
				}
			}
		return false;
	}

	@:isVar public var modifiers(get, never):Vector<GMModifier>;

	public function get_modifiers():Vector<GMModifier> {
		return mModifiers;
	}

	@:isVar public var legendaryModifier(get, never):UInt;

	public function get_legendaryModifier():UInt {
		return mLegendaryModifier;
	}

	override public function getTextColor():UInt {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
		return (ASCompat.toInt(_loc1_ != null && _loc1_.TextColor != 0 ? _loc1_.TextColor : (15463921 : UInt)) : UInt);
	}

	override public function get_hasColoredBackground():Bool {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.HasColoredBackground : false;
	}

	override public function get_backgroundIconName():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIcon : "";
	}

	override public function get_backgroundSwfPath():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundSwf : "";
	}

	override public function get_backgroundIconBorderName():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mRarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIconBorder : "";
	}

	override public function get_Name():String {
		return gmWeaponAesthetic.Name;
	}

	override public function get_weaponAestheticConstant():String {
		return gmWeaponAesthetic.Constant;
	}
}
