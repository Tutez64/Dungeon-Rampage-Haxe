package steamAchievements;

import account.AvatarInfo;
import account.ItemInfo;
import collections.IMapIterator;
import collections.Map;
import distributedObjects.HeroGameObject;
import facade.DBFacade;
import gameMasterDictionary.GMMapNode;

class SteamAchievementsHelper {
	static inline final ULTIMATE_RAMPAGE_TARGET_FLOOR = 25;

	static inline final INITIAL_STORAGE_SLOTS = 15;

	static inline final MAX_LEVEL_BEFORE_ASCENSION = (100 : UInt);

	var mDBFacade:DBFacade;

	public function new(inDBFacade:DBFacade) {
		mDBFacade = inDBFacade;
	}

	public function unlockOwnedHeroes(inAvatars:Map) {
		var _loc3_:AvatarInfo = null;
		if (inAvatars == null) {
			return;
		}
		var _loc2_ = ASCompat.reinterpretAs(inAvatars.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc3_ = ASCompat.dynamicAs(_loc2_.next(), AvatarInfo);
			if (_loc3_ != null && _loc3_.gmHero != null && _loc3_.gmHero.Constant != "BERSERKER") {
				unlockAchievement(SteamAPINames.getUnlockHeroAchievementAPIName(_loc3_.gmHero.Constant));
			}
		}
	}

	public function updateHeroLevelStat(inHeroConstant:String, inLevel:UInt, inAscensionLevel:UInt) {
		var _loc4_ = (ASCompat.floatToInt(Math.min(inLevel, AvatarInfo.MAX_EFFECTIVE_LEVEL)) : UInt);
		if (inAscensionLevel > 0) {
			_loc4_ = (ASCompat.floatToInt(Math.max(_loc4_, 100)) : UInt);
		}
		setHighestStatValueAchieved((_loc4_ : Int), SteamAPINames.getHighestLevelHeroStatAPIName(inHeroConstant));
	}

	public function updateHeroProgressStats(inAvatars:Map) {
		var _loc3_:AvatarInfo = null;
		if (inAvatars == null) {
			return;
		}
		var _loc2_ = ASCompat.reinterpretAs(inAvatars.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc3_ = ASCompat.dynamicAs(_loc2_.next(), AvatarInfo);
			if (_loc3_ != null && _loc3_.gmHero != null) {
				updateHeroLevelStat(_loc3_.gmHero.Constant, _loc3_.effectiveLevel, _loc3_.mAscensionLevel);
				setHighestStatValueAchieved((_loc3_.mAscensionLevel : Int), SteamAPINames.getAscensionHeroStatAPIName(_loc3_.gmHero.Constant));
			}
		}
	}

	public function updateMapsAtFloor25Stat(inMapNode:GMMapNode):Bool {
		var _loc5_:String = null;
		if (inMapNode.NodeType != GMMapNode.INFINITE_NODE_TYPE || mDBFacade.steamAchievementsManager == null) {
			return false;
		}
		var _loc2_ = 0;
		var _loc3_:GMMapNode;
		final __ax4_iter_332 = mDBFacade.gameMaster.MapNodes;
		if (checkNullIteratee(__ax4_iter_332))
			for (_tmp_ in __ax4_iter_332) {
				_loc3_ = _tmp_;
				if (_loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE) {
					_loc5_ = SteamAPINames.getUltimateRampageHighestFloorStatAPIName(_loc3_.Constant);
					if (mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue(_loc5_) >= 25) {
						_loc2_++;
					}
				}
			}
		var _loc4_ = mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue("ULTIMATE_RAMPAGE_MAPS_AT_FLOOR_25");
		if (_loc2_ != _loc4_) {
			return setValueToStatInt(_loc2_, "ULTIMATE_RAMPAGE_MAPS_AT_FLOOR_25");
		}
		return false;
	}

	public function setHighestStatValueAchieved(inCurrentValue:Int, inStatAPIName:String) {
		var _loc3_ = 0;
		if (mDBFacade.steamAchievementsManager != null) {
			_loc3_ = mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue(inStatAPIName);
			if (inCurrentValue > _loc3_) {
				setValueToStatInt(inCurrentValue, inStatAPIName);
			}
		}
	}

	public function checkHighestUltimateRampageFloorAchieved(inMapNode:GMMapNode, inCurrentFloor:UInt) {
		if (inMapNode.NodeType != GMMapNode.INFINITE_NODE_TYPE) {
			return;
		}
		var _loc3_ = SteamAPINames.getUltimateRampageHighestFloorStatAPIName(inMapNode.Constant);
		setHighestStatValueAchieved(inCurrentFloor, _loc3_);
	}

	public function checkStorageAchievements(inStorageSlots:Int):Bool {
		var _loc2_ = false;
		if (inStorageSlots > 15) {
			_loc2_ = unlockAchievement("STORAGE_EXPAND_FIRST_TIME");
		}
		setHighestStatValueAchieved(inStorageSlots, "STORAGE_SLOTS");
		return _loc2_;
	}

	public function unlockDarkBarrowsAsVampireHunter(inHeroConstant:String, inMapConstant:String) {
		if (inHeroConstant == "VAMPIRE_HUNTER" && inMapConstant == "CATACOMBS_BOSS_2") {
			unlockAchievement("VAMPIRE_HUNTER_CHALLENGE_DEFEAT_DARK_BARROWS-2-6");
		}
	}

	public function unlockUpgradeStat(amount:UInt) {
		var _loc2_:Int = amount;
		if (_loc2_ > 0) {
			unlockAchievement("UPGRADE_HERO");
		}
	}

	function unlockBerserkerBossChallenge(inHeroWeapons:Vector<ItemInfo>) {
		var _loc2_:ItemInfo;
		var _loc3_:String = null;
		if (inHeroWeapons.length == 1) {
			if (checkNullIteratee(inHeroWeapons))
				for (_tmp_ in inHeroWeapons) {
					_loc2_ = _tmp_;
					_loc3_ = _loc2_.gmWeaponItem.MasterType;
					if (_loc3_ == "HAMMER_TYPE") {
						unlockAchievement("BESERKER_CHALLENGE_ONLY_HAMMER");
					}
				}
		}
	}

	function unlockRangerBossChallenge(inHeroWeapons:Vector<ItemInfo>) {
		var _loc2_:ItemInfo;
		var _loc3_:String = null;
		if (inHeroWeapons.length != 0) {
			if (checkNullIteratee(inHeroWeapons))
				for (_tmp_ in inHeroWeapons) {
					_loc2_ = _tmp_;
					_loc3_ = _loc2_.gmWeaponItem.MasterType;
					if (_loc3_ == "BOW_TYPE") {
						return;
					}
				}
			unlockAchievement("RANGER_CHALLENGE_NO_BOW");
		}
	}

	function unlockBattleChefBossChallenge(inHeroWeapons:Vector<ItemInfo>) {
		var _loc2_:ItemInfo;
		var _loc3_:String = null;
		if (inHeroWeapons.length != 0) {
			if (checkNullIteratee(inHeroWeapons))
				for (_tmp_ in inHeroWeapons) {
					_loc2_ = _tmp_;
					_loc3_ = _loc2_.gmWeaponItem.MasterType;
					if (_loc3_ == "FRYING_PAN_TYPE" || _loc3_ == "COOKING_TYPE") {
						return;
					}
				}
			unlockAchievement("BATTLE_CHEF_CHALLENGE_NO_POT_NO_PAN");
		}
	}

	function unlockSorcererBossChallenge(inHeroWeapons:Vector<ItemInfo>) {
		var _loc2_:ItemInfo;
		var _loc3_:String = null;
		if (inHeroWeapons.length != 0) {
			if (checkNullIteratee(inHeroWeapons))
				for (_tmp_ in inHeroWeapons) {
					_loc2_ = _tmp_;
					_loc3_ = _loc2_.gmWeaponItem.MasterType;
					if (_loc3_ == "LIGHTNING_STAFF_TYPE" || _loc3_ == "LIGHTNING_MAGIC_TYPE") {
						return;
					}
				}
			unlockAchievement("SORCERER_CHALLENGE_NO_STAFF_NO_TOME");
		}
	}

	public function unlockBossChallengeWithUncommonWeapon(inMapNode:GMMapNode, inHeroConstant:String, inHeroWeapons:Vector<ItemInfo>) {
		if (inMapNode.NodeType == "BOSS" && inMapNode.Constant != "TUTORIAL") {
			switch (inHeroConstant) {
				case "BERSERKER":
					unlockBerserkerBossChallenge(inHeroWeapons);

				case "RANGER":
					unlockRangerBossChallenge(inHeroWeapons);

				case "BATTLE_CHEF":
					unlockBattleChefBossChallenge(inHeroWeapons);

				case "SORCERER":
					unlockSorcererBossChallenge(inHeroWeapons);
			}
		}
	}

	public function unlockAchievement(inAPIName:String):Bool {
		var _loc2_ = false;
		if (mDBFacade.steamAchievementsManager != null) {
			_loc2_ = mDBFacade.steamAchievementsManager.unlockAchievement(inAPIName);
		}
		return _loc2_;
	}

	public function setValueToStatInt(inValue:Float, inStatAPIName:String):Bool {
		var _loc3_ = false;
		if (mDBFacade.steamAchievementsManager != null) {
			_loc3_ = mDBFacade.steamAchievementsManager.updateSteamStatInt(inStatAPIName, inValue, false);
		}
		return _loc3_;
	}

	public function addValueToStatInt(inValue:Float, inStatAPIName:String):Bool {
		var _loc3_ = false;
		if (mDBFacade.steamAchievementsManager != null) {
			_loc3_ = mDBFacade.steamAchievementsManager.updateSteamStatInt(inStatAPIName, inValue, true);
		}
		return _loc3_;
	}

	public function unlockFinishFloorWithThreeTeammatesDowned(mRemoteHeroes:Map) {
		var _loc4_ = 0;
		var _loc5_:HeroGameObject = null;
		var _loc3_:IMapIterator = null;
		var _loc2_ = mRemoteHeroes.size;
		if (_loc2_ >= 3) {
			_loc4_ = 0;
			_loc3_ = ASCompat.reinterpretAs(mRemoteHeroes.iterator(), IMapIterator);
			while (_loc3_.hasNext()) {
				_loc5_ = ASCompat.dynamicAs(_loc3_.next(), HeroGameObject);
				if (_loc5_.isDead() || _loc5_.isInReviveState()) {
					_loc4_++;
				}
				if (_loc4_ >= 3) {
					unlockAchievement("CHALLENGE_DUNGEON_COMPLETE_3_DOWNED_TEAMMATES");
				}
			}
		}
	}

	public function unlockThreeLegendaryWeapons(inEquippedItems:Vector<ItemInfo>) {
		var _loc2_:ItemInfo;
		var _loc3_ = 0;
		if (inEquippedItems.length >= 3) {
			_loc3_ = 0;
			if (checkNullIteratee(inEquippedItems))
				for (_tmp_ in inEquippedItems) {
					_loc2_ = _tmp_;
					if (_loc2_.rarity.Constant == "LEGENDARY") {
						_loc3_++;
					}
				}
			if (_loc3_ >= 3) {
				unlockAchievement("EQUIP_3_LEGENDARY_WEAPONS");
			}
		}
	}

	public function finishDungeonWithFriends(mRemoteHeroes:Map, CurrentPlayerFriends:Map) {
		var _loc4_:HeroGameObject = null;
		var _loc3_ = ASCompat.reinterpretAs(mRemoteHeroes.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc4_ = ASCompat.dynamicAs(_loc3_.next(), HeroGameObject);
			if (_loc4_ != null && CurrentPlayerFriends.hasKey(_loc4_.playerID)) {
				addValueToStatInt(1, "DUNGEONS_COMPLETED_WITH_FRIENDS");
				return;
			}
		}
	}
}
