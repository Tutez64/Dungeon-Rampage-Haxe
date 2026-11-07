package account;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.utils.Utf8BitArray;
import brain.jsonRPC.JSONRPCService;
import facade.DBFacade;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMMapNode;

class AvatarInfo {
	public static final MAX_EFFECTIVE_LEVEL:UInt = GMHero.MAX_LEVEL;

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

	public var mAscensionLevel:UInt = 0;

	public var mNextAscensionGemCost:UInt = 0;

	public var mMaxSkillPoints:UInt = 0;

	public var mEquippedConsumables:Vector<Consumable>;

	public var mMapNodes:Vector<AvatarMapNodeInfo>;

	public var mCompletedMapnodeMask:Utf8BitArray;

	public var mTrophyMapnodeMask:Utf8BitArray;

	var mGMHero:GMHero;

	public function new(dbFacade:DBFacade, avatarJson:ASObject, responseCallback:ASFunction) {
		mMapNodes = new Vector<AvatarMapNodeInfo>();
		mEquippedConsumables = new Vector<Consumable>();
		mCompletedMapnodeMask = new Utf8BitArray();
		mTrophyMapnodeMask = new Utf8BitArray();
		mDBFacade = dbFacade;
		mResponseCallback = responseCallback;
		init(avatarJson);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
	}

	@:isVar public var mapNodes(get, never):Vector<AvatarMapNodeInfo>;

	public function get_mapNodes():Vector<AvatarMapNodeInfo> {
		return mMapNodes;
	}

	public function hasTrophy(bitIndex:UInt):Bool {
		return mTrophyMapnodeMask.getBit(bitIndex);
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
		mGMHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(avatarType), gameMasterDictionary.GMHero);
	}

	@:isVar public var skillPointsEarned(get, never):UInt;

	public function get_skillPointsEarned():UInt {
		return mMaxSkillPoints;
	}

	@:isVar public var skillPointsAvailable(get, never):Int;

	public function get_skillPointsAvailable():Int {
		return ASCompat.floatToInt(Math.max((this.skillPointsEarned : Float) - (this.skillPointsSpent : Float), 0));
	}

	@:isVar public var skillPointsSpent(get, never):UInt;

	public function get_skillPointsSpent():UInt {
		return statUpgrade1 + statUpgrade2 + statUpgrade3 + statUpgrade4;
	}

	@:isVar public var cloutLevel(get, never):UInt;

	public function get_cloutLevel():UInt {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(avatarType), gameMasterDictionary.GMHero);
		return _loc1_.getLevelFromExp(experience, mAscensionLevel);
	}

	@:isVar public var effectiveLevel(get, never):UInt;

	public function get_effectiveLevel():UInt {
		return (ASCompat.floatToInt(Math.min(cloutLevel, MAX_EFFECTIVE_LEVEL)) : UInt);
	}

	@:isVar public var ogLevel(get, never):UInt;

	public function get_ogLevel():UInt {
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(avatarType), gameMasterDictionary.GMHero);
		return (ASCompat.floatToInt(Math.min(_loc1_.getLevelFromExp(experience, mAscensionLevel), 100)) : UInt);
	}

	@:isVar public var canAscend(get, never):Bool;

	public function get_canAscend():Bool {
		if (mDBFacade.dbAccountInfo.premiumCurrency < mNextAscensionGemCost) {
			return false;
		}
		if (cloutLevel < GMHero.maxLevelForAscension(mAscensionLevel)) {
			return false;
		}
		var _loc1_ = (mGMHero.getLevelIndex(experience, (mAscensionLevel : Int)) : UInt);
		return experience >= mGMHero.getExpFromIndex(_loc1_);
	}

	@:isVar public var levelForWeaponComparison(get, never):UInt;

	public function get_levelForWeaponComparison():UInt {
		if (cloutLevel <= 99) {
			return cloutLevel;
		}
		return (9001 : UInt);
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
		var _loc2_:AvatarMapNodeInfo = null;
		var _loc3_:GMMapNode = null;
		var _loc4_ = (0 : UInt);
		var _loc5_:Utf8BitArray = null;
		if (avatarJson == null) {
			return;
		}
		mCompletedMapnodeMask.init(avatarJson.completed_mapnode_mask);
		mTrophyMapnodeMask.init(avatarJson.trophy_mapnode_mask);
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
		mAscensionLevel = (ASCompat.toInt(avatarJson.ascension_level) : UInt);
		mMaxSkillPoints = (ASCompat.toInt(avatarJson.max_skill_points) : UInt);
		mNextAscensionGemCost = (ASCompat.toInt(avatarJson.ascension_gem_cost) : UInt);
		if (mDBFacade.NODE_RULES == 0) {
			_loc4_ = (0 : UInt);
			while (_loc4_ < mCompletedMapnodeMask.getLength()) {
				if (mCompletedMapnodeMask.getBit(_loc4_)) {
					_loc2_ = new AvatarMapNodeInfo();
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc4_), gameMasterDictionary.GMMapNode);
					if (_loc3_ == null) {
						Logger.warn("Unable to find map node for bit index: " + _loc4_);
					} else {
						_loc2_.node_id = _loc3_.Id;
						_loc2_.trophy = (_loc3_.NodeType == GMMapNode.BOSS_NODE_TYPE
							|| _loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE ? (1 : UInt) : (0 : UInt):UInt);
						_loc2_.isCompleted = true;
						mMapNodes.push(_loc2_);
					}
				}
				_loc4_++;
			}
		} else {
			_loc5_ = mDBFacade.dbAccountInfo.getCompletedMapnodeMask();
			_loc4_ = (0 : UInt);
			while (_loc4_ < _loc5_.getLength()) {
				if (_loc5_.getBit(_loc4_)) {
					_loc2_ = new AvatarMapNodeInfo();
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc4_), gameMasterDictionary.GMMapNode);
					_loc2_.node_id = _loc3_.Id;
					_loc2_.trophy = (mCompletedMapnodeMask.getBit(_loc4_)
						&& (_loc3_.NodeType == GMMapNode.BOSS_NODE_TYPE
							|| _loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE) ? (1 : UInt) : (0 : UInt):UInt);
					_loc2_.isCompleted = mCompletedMapnodeMask.getBit(_loc4_);
					mMapNodes.push(_loc2_);
				}
				_loc4_++;
			}
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
