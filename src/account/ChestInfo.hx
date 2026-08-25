package account;

import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import facade.DBFacade;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMRarity;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

class ChestInfo extends InventoryBaseInfo {
	var mGMChestData:GMChest;

	var mIsFromDungeonSummary:Bool = false;

	public function new(dbFacade:DBFacade, json:ASObject) {
		super(dbFacade, json);
		mIsFromDungeonSummary = false;
		if (json == null) {
			return;
		}
		mGMChestData = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
		if (mGMChestData == null) {
			Logger.error("GMChest is null cannot find item for ID: " + mGMId);
		} else {
			mGMChestInfo = mGMChestData;
		}
	}

	public static function loadItemIcon(swfPath:String, iconName:String, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt,
			iconsNativeSize:UInt, assetLoadingComponent:AssetLoadingComponent = null) {
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
			_loc2_.scaleX = _loc2_.scaleY = desiredSize / iconsNativeSize;
			container.addChild(_loc2_);
			if (destroyAssetLoaderOnCompletion) {
				assetLoadingComponent.destroy();
			}
		});
	}

	public static function loadItemIconFromId(chestId:UInt, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt, iconsNativeSize:UInt,
			assetLoadingComponent:AssetLoadingComponent = null) {
		var _loc7_ = ASCompat.dynamicAs(dbFacade.gameMaster.chestsById.itemFor(chestId), gameMasterDictionary.GMChest);
		loadItemIcon(_loc7_.IconSwf, _loc7_.IconName, container, dbFacade, desiredSize, iconsNativeSize, assetLoadingComponent);
	}

	override public function get_iconScale():Float {
		return 120;
	}

	override function parseJson(json:ASObject) {
		if (json == null) {
			return;
		}
		mGMId = ASCompat.asUint(json.chest_id);
		mDatabaseId = ASCompat.asUint(json.id);
		mIsNew = false;
	}

	public function setParams(databaseId:UInt) {
		mDatabaseId = databaseId;
		mGMId = (ASCompat.toInt(mDBFacade.gameMaster.dooberById.itemFor(mDatabaseId).ChestId) : UInt);
		mGMChestData = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
		if (mGMChestData == null) {
			Logger.error("GMChest (setParams) is null cannot find item for ID: " + mGMId);
		}
		mGMChestInfo = mGMChestData;
	}

	public function isFromDungeonSummary():Bool {
		return mIsFromDungeonSummary;
	}

	public function setFromDungeonSummary() {
		mIsFromDungeonSummary = true;
	}

	override public function get_uiSwfFilepath():String {
		return mGMChestData.IconSwf;
	}

	override public function get_iconName():String {
		return mGMChestData.IconName;
	}

	override public function get_hasColoredBackground():Bool {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.HasColoredBackground : false;
	}

	override public function get_backgroundIconName():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIcon : "";
	}

	override public function get_backgroundSwfPath():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundSwf : "";
	}

	override public function get_Name():String {
		return mGMChestData.Name;
	}

	@:isVar public var rarity(get, never):String;

	public function get_rarity():String {
		return mGMChestData.Rarity;
	}

	override public function get_needsRenderer():Bool {
		return true;
	}
}
