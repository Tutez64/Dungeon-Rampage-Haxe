package account;

import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMRarity;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

class ChestInfo extends InventoryBaseInfo {
	public static inline final STACK_SIZE = (99 : UInt);

	var mGMChestData:GMChest;

	var mIsFromDungeonSummary:Bool = false;

	var mDatabaseIds:Vector<UInt> = new Vector();

	public function new(dbFacade:DBFacade, json:ASObject) {
		super(dbFacade, json);
		mIsFromDungeonSummary = false;
		if (json != null) {
			mDatabaseIds.push(mDatabaseId);
		}
		if (json == null) {
			return;
		}
		mGMChestData = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
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
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			_loc2_.scaleX = _loc2_.scaleY = desiredSize / iconsNativeSize;
			container.addChild(_loc2_);
			if (destroyAssetLoaderOnCompletion) {
				assetLoadingComponent.destroy();
			}
		});
	}

	public static function loadItemIconFromId(chestId:UInt, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:UInt, iconsNativeSize:UInt,
			assetLoadingComponent:AssetLoadingComponent = null) {
		var _loc7_ = ASCompat.coerce(dbFacade.gameMaster.chestsById.itemFor(chestId), gameMasterDictionary.GMChest);
		loadItemIcon(_loc7_.IconSwf, _loc7_.IconName, container, dbFacade, desiredSize, iconsNativeSize, assetLoadingComponent);
	}

	override public function get_iconScale():Float {
		return DBGlobal.CHEST_ICON_NATIVE_SIZE;
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
		mGMChestData = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(mGMId), gameMasterDictionary.GMChest);
		if (mGMChestData == null) {
			Logger.error("GMChest (setParams) is null cannot find item for ID: " + mGMId);
		}
		mGMChestInfo = mGMChestData;
	}

	@:isVar public var count(get, never):UInt;

	public function get_count():UInt {
		return (mDatabaseIds.length > 0 ? (mDatabaseIds.length : UInt) : (1 : UInt):UInt);
	}

	@:isVar public var isFull(get, never):Bool;

	public function get_isFull():Bool {
		return mDatabaseIds.length >= 99;
	}

	@:isVar public var databaseIds(get, never):Vector<UInt>;

	public function get_databaseIds():Vector<UInt> {
		return mDatabaseIds;
	}

	public function containsDatabaseId(id:UInt):Bool {
		return mDatabaseIds.indexOf(id) != -1;
	}

	public function addDatabaseId(id:UInt) {
		mDatabaseIds.push(id);
	}

	public function removeDatabaseId(id:UInt):Bool {
		var _loc2_ = mDatabaseIds.indexOf(id);
		if (_loc2_ != -1) {
			mDatabaseIds.splice(_loc2_, (1 : UInt));
		}
		if (mDatabaseIds.length > 0) {
			mDatabaseId = mDatabaseIds[0];
		}
		return mDatabaseIds.length > 0;
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
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.HasColoredBackground : false;
	}

	override public function get_backgroundIconName():String {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
		return _loc1_ != null ? _loc1_.BackgroundIcon : "";
	}

	override public function get_backgroundSwfPath():String {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMChestData.Rarity), gameMasterDictionary.GMRarity);
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
