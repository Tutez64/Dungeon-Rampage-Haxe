package account;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.utils.Utf8BitArray;
import brain.jsonRPC.JSONRPCService;
import facade.DBFacade;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMMapNode;
import metrics.PixelTracker;
import org.as3commons.collections.Map;
import org.as3commons.collections.Set;
import org.as3commons.collections.framework.IIterator;

class AvatarInfo {
	public static var mAvatarMapIndexes:Map = new Map();

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSwfAsset:SwfAsset;

	var mResponseCallback:ASFunction;

	var mCallbackSuccess:ASFunction;

	var mCallbackFailure:ASFunction;

	public var accountId:UInt = 0;

	public var avatarType:UInt = 0;

	public var created:String;

	public var experience:UInt = 0;

	public var id:UInt = 0;

	public var statUpgrade1:UInt = 0;

	public var statUpgrade2:UInt = 0;

	public var statUpgrade3:UInt = 0;

	public var statUpgrade4:UInt = 0;

	public var skinId:UInt = 0;

	public var consumable1Id:UInt = 0;

	public var consumable1Count:UInt = 0;

	public var consumable2Id:UInt = 0;

	public var consumable2Count:UInt = 0;

	public var mEquippedConsumables:Vector<Consumable>;

	public var mMapNodes:Vector<AvatarMapNodeInfo>;

	public var mCompletedMapnodeMask:Utf8BitArray;

	var mGMHero:GMHero;

	public function new(dbFacade:DBFacade, avatarJson:ASObject, responseCallback:ASFunction) {
		mMapNodes = new Vector<AvatarMapNodeInfo>();
		mEquippedConsumables = new Vector<Consumable>();
		mCompletedMapnodeMask = new Utf8BitArray();
		mDBFacade = dbFacade;
		mResponseCallback = responseCallback;
		init(avatarJson);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
	}

	@:isVar public var mapNodes(get, never):Vector<AvatarMapNodeInfo>;

	public function get_mapNodes():Vector<AvatarMapNodeInfo> {
		return mMapNodes;
	}

	public function destroy() {
		mEquippedConsumables = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mGMHero = null;
		mDBFacade = null;
		mMapNodes = null;
	}

	public function init(avatarJson:ASObject) {
		parseJson(avatarJson);
		mGMHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(avatarType), gameMasterDictionary.GMHero);
	}

	@:isVar public var skillPointsEarned(get, never):UInt;

	public function get_skillPointsEarned():UInt {
		return mGMHero.getTotalStatFromExp(this.experience);
	}

	@:isVar public var skillPointsAvailable(get, never):Int;

	public function get_skillPointsAvailable():Int {
		return Std.int(Math.max(this.skillPointsEarned - this.skillPointsSpent, 0));
	}

	@:isVar public var skillPointsSpent(get, never):UInt;

	public function get_skillPointsSpent():UInt {
		return statUpgrade1 + statUpgrade2 + statUpgrade3 + statUpgrade4;
	}

	@:isVar public var level(get, never):UInt;

	public function get_level():UInt {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(avatarType), gameMasterDictionary.GMHero);
		return _loc1_.getLevelFromExp(experience);
	}

	@:isVar public var gmHero(get, never):GMHero;

	public function get_gmHero():GMHero {
		return mGMHero;
	}

	public function loadHeroIcon(loadedCallback:ASFunction) {
		var iconClass:Dynamic;
		var gmSkin = mDBFacade.gameMaster.getSkinByType(skinId);
		if (mSwfAsset == null) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath), function(param1:SwfAsset) {
				mSwfAsset = param1;
				iconClass = param1.getClass(gmSkin.IconName);
				loadedCallback(ASCompat.createInstance(iconClass, []));
			});
		} else {
			iconClass = mSwfAsset.getClass(gmSkin.IconName);
			loadedCallback(ASCompat.createInstance(iconClass, []));
		}
	}

	function parseJson(avatarJson:ASObject) {
		var _loc6_:AvatarMapNodeInfo = null;
		var _loc7_:GMMapNode = null;
		var _loc11_ = 0;
		var _loc10_:Utf8BitArray = null;
		var _loc3_:IIterator = null;
		var _loc4_ = 0;
		if (avatarJson == null) {
			return;
		}
		mCompletedMapnodeMask.init(avatarJson.completed_mapnode_mask);
		accountId = ASCompat.asUint(avatarJson.account_id);
		avatarType = ASCompat.asUint(avatarJson.avatar_id);
		created = ASCompat.asString(avatarJson.created);
		experience = ASCompat.asUint(avatarJson.experience);
		id = ASCompat.asUint(avatarJson.id);
		statUpgrade1 = ASCompat.asUint(avatarJson.statupgrade1);
		statUpgrade2 = ASCompat.asUint(avatarJson.statupgrade2);
		statUpgrade3 = ASCompat.asUint(avatarJson.statupgrade3);
		statUpgrade4 = ASCompat.asUint(avatarJson.statupgrade4);
		skinId = ASCompat.asUint(avatarJson.skin_type);
		consumable1Id = ASCompat.asUint(avatarJson.consumable1_id);
		consumable1Count = ASCompat.asUint(avatarJson.consumable1_count);
		mEquippedConsumables.push(new Consumable((0 : UInt), consumable1Id, consumable1Count));
		consumable2Id = ASCompat.asUint(avatarJson.consumable2_id);
		consumable2Count = ASCompat.asUint(avatarJson.consumable2_count);
		mEquippedConsumables.push(new Consumable((1 : UInt), consumable2Id, consumable2Count));
		var _loc2_ = new Set();
		var _loc5_:Set = null;
		var _loc9_ = true;
		if (mAvatarMapIndexes.hasKey(id)) {
			_loc5_ = ASCompat.dynamicAs(mAvatarMapIndexes.itemFor(id), org.as3commons.collections.Set);
			_loc9_ = false;
		}
		var _loc8_ = (0 : UInt);
		if (mDBFacade.NODE_RULES == 0) {
			_loc11_ = (mCompletedMapnodeMask.getLength() : Int);
			_loc8_ = (0 : UInt);
			while (_loc8_ < mCompletedMapnodeMask.getLength()) {
				if (mCompletedMapnodeMask.getBit(_loc8_)) {
					_loc6_ = new AvatarMapNodeInfo();
					_loc7_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc8_), gameMasterDictionary.GMMapNode);
					if (_loc7_ == null) {
						Logger.warn("Unable to find map node for bit index: " + _loc8_);
					} else {
						_loc6_.node_id = _loc7_.Id;
						_loc2_.add(_loc7_.Id);
						_loc6_.trophy = (_loc7_.NodeType == "BOSS" || _loc7_.NodeType == "INFINITE" ? (1 : UInt) : (0 : UInt):UInt);
						_loc6_.isCompleted = true;
						mMapNodes.push(_loc6_);
					}
				}
				_loc8_++;
			}
		} else {
			_loc10_ = mDBFacade.dbAccountInfo.getCompletedMapnodeMask();
			_loc8_ = (0 : UInt);
			while (_loc8_ < _loc10_.getLength()) {
				if (_loc10_.getBit(_loc8_)) {
					_loc6_ = new AvatarMapNodeInfo();
					_loc7_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc8_), gameMasterDictionary.GMMapNode);
					_loc6_.node_id = _loc7_.Id;
					_loc2_.add(_loc7_.Id);
					_loc6_.trophy = (mCompletedMapnodeMask.getBit(_loc8_)
						&& (_loc7_.NodeType == "BOSS" || _loc7_.NodeType == "INFINITE") ? (1 : UInt) : (0 : UInt):UInt);
					_loc6_.isCompleted = mCompletedMapnodeMask.getBit(_loc8_);
					mMapNodes.push(_loc6_);
				}
				_loc8_++;
			}
		}
		if (mDBFacade.accountId == accountId) {
			if (!_loc9_) {
				_loc3_ = _loc2_.iterator();
				while (_loc3_.hasNext()) {
					_loc4_ = ASCompat.toInt(_loc3_.next());
					if (!_loc5_.has(_loc4_)) {
						PixelTracker.logMapNodeUnlocked(mDBFacade, (_loc4_ : UInt));
					}
				}
			}
		}
		if (mAvatarMapIndexes.has(id)) {
			mAvatarMapIndexes.replaceFor(id, _loc2_);
		} else {
			mAvatarMapIndexes.add(id, _loc2_);
		}
	}

	public function RPC_updateAvatarSlots(val1:UInt, val2:UInt, val3:UInt, val4:UInt, successCallback:ASFunction, failureCallback:ASFunction) {
		mCallbackSuccess = successCallback;
		mCallbackFailure = failureCallback;
		var _loc7_ = JSONRPCService.getFunction("updateAvatarSlots", mDBFacade.rpcRoot + "avatarrecord");
		_loc7_(mDBFacade.validationToken, accountId, id, val1, val2, val3, val4, mResponseCallback, updateFailure);
	}

	public function RPC_updateAvatarSkin() {
		var _loc1_ = JSONRPCService.getFunction("setSkin", mDBFacade.rpcRoot + "avatarrecord");
		_loc1_(mDBFacade.validationToken, accountId, id, skinId, mResponseCallback, updateFailure);
	}

	function updateFailure(err:Error) {
		if (mCallbackFailure != null) {
			mCallbackFailure(err);
		}
	}

	@:isVar public var equippedConsumables(get, never):Vector<Consumable>;

	public function get_equippedConsumables():Vector<Consumable> {
		return mEquippedConsumables;
	}
}

private class AvatarMapNodeInfo {
	public var node_id:UInt = 0;

	public var trophy:UInt = 0;

	public var isCompleted:Bool = false;

	public function new() {}
}
