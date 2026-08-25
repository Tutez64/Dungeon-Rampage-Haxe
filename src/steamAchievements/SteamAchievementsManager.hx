package steamAchievements;

import brain.logger.Logger;
import facade.DBFacade;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMMapNode;
import com.amanitadesign.steam.SteamEvent;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class SteamAchievementsManager {
	static inline final LEVEL_COMPLETION = "_LEVEL_COMPLETE";

	static inline final ULTIMATE_RAMPAGE_FLOOR_25_COMPLETE = "_FLOOR_25_STAT";

	public static inline final BASIC_ACHIEVEMENT_TEST_NAME_1 = "TEST_ACHIEVEMENT_1";

	public static inline final BASIC_ACHIEVEMENT_TEST_NAME_2 = "TEST_ACHIEVEMENT_2";

	public static inline final COLLECT_DAILY_REWARD = "COLLECT_DAILY_REWARD";

	public static inline final REROLL_DAILY_REWARD = "REROLL_DAILY_REWARD";

	public static inline final EQUIP_PET = "EQUIP_PET";

	public static inline final SELL_AN_ITEM = "SELL_AN_ITEM";

	public static inline final RETRAIN_CHARACTER = "RETRAIN_CHARACTER";

	public static inline final MUSIC_VOLUME_SET_TO_11 = "MUSIC_VOLUME_SET_TO_11";

	public static inline final STORAGE_EXPAND_FIRST_TIME = "STORAGE_EXPAND_FIRST_TIME";

	public static inline final SEND_A_GIFT = "SEND_A_GIFT";

	public static inline final PURCHASE_WEAPON_FIRST_TIME = "PURCHASE_WEAPON_FIRST_TIME";

	public static inline final USE_CONSUMABLE_FIRST_TIME = "USE_CONSUMABLE_FIRST_TIME";

	public static inline final BASIC_INT_STAT_TEST_1 = "TEST_STAT_INT_1";

	public static inline final BASIC_INT_STAT_TEST_2 = "TEST_STAT_INT_2";

	public static inline final SPEND_COINS_INT_STAT = "SPEND_COINS_INT";

	public static inline final BERSERKER_LEVEL_UP_STAT = "BERSERKER_LEVEL_STAT";

	public static inline final RANGER_LEVEL_UP_STAT = "RANGER_LEVEL_STAT";

	public static inline final REROLL_DAILY_REWARD_STAT = "REROLL_DAILY_REWARD_STAT";

	public static inline final SELL_ITEM_STAT = "SELL_ITEM_STAT";

	public static inline final RETRAIN_STAT = "RETRAIN_STAT";

	public static inline final INFINITE_PRISON_25_STAT = "INFINITE_PRISON_FLOOR_25_STAT";

	public static inline final INFINITE_DINO_25_STAT = "INFINITE_DINO_FLOOR_25_STAT";

	public static inline final INFINITE_AZTECH_25_STAT = "INFINITE_AZTECH_FLOOR_25_STAT";

	public static inline final INFINITE_TEMPLE_25_STAT = "INFINITE_TEMPLE_FLOOR_25_STAT";

	public static inline final INFINITE_ARENA_25_STAT = "INFINITE_ARENA_FLOOR_25_STAT";

	public static inline final INFINITE_ICE_CAVES_25_STAT = "INFINITE_ICE_CAVES_FLOOR_25_STAT";

	public static inline final INFINITE_CATACOMBS_CAVES_25_STAT = "INFINITE_CATACOMBS_FLOOR_25_STAT";

	public static inline final INFINITE_TRIBAL_CAVES_25_STAT = "INFINITE_TRIBAL_FLOOR_25_STAT";

	public static inline final INFINITE_VILLAGE_CAVES_25_STAT = "INFINITE_VILLAGE_FLOOR_25_STAT";

	public static inline final STORAGE_MAX_STAT = "STORAGE_MAX_STAT";

	var mDBFacade:DBFacade;

	var mAppID:UInt = 0;

	var mIsSteamAchsManagerInitialized:Bool = false;

	var mAchievements:Vector<SteamAchievement>;

	var mStats:Map;

	public function new(inDBFacade:DBFacade) {
		mDBFacade = inDBFacade;
		if (mDBFacade.featureFlags.getFlagValue("want-steam-achievements")) {
			mAppID = mDBFacade.mSteamworks.getAppID();
			mAchievements = new Vector<SteamAchievement>();
			mStats = new Map();
			mIsSteamAchsManagerInitialized = true;
			addSteamAchievement("TEST_ACHIEVEMENT_1");
			addSteamAchievement("TEST_ACHIEVEMENT_2");
			addSteamAchievement("COLLECT_DAILY_REWARD");
			addSteamAchievement("REROLL_DAILY_REWARD");
			addSteamAchievement("RETRAIN_CHARACTER");
			addSteamAchievement("EQUIP_PET");
			addSteamAchievement("SELL_AN_ITEM");
			addSteamAchievement("SEND_A_GIFT");
			addSteamAchievement("USE_CONSUMABLE_FIRST_TIME");
			addSteamStat("TEST_STAT_INT_1", 0, 5);
			addSteamStat("TEST_STAT_INT_2", 0, 5);
			addSteamStat("SPEND_COINS_INT", 0, 10000);
			addSteamStat("BERSERKER_LEVEL_STAT", 0, 1);
			addSteamStat("RANGER_LEVEL_STAT", 0, 1);
			addSteamStat("REROLL_DAILY_REWARD_STAT", 0, 10);
			addSteamStat("SELL_ITEM_STAT", 0, 10);
			addSteamStat("RETRAIN_STAT", 0, 50);
			addSteamStat("INFINITE_PRISON_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_DINO_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_AZTECH_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_TEMPLE_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_ARENA_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_ICE_CAVES_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_CATACOMBS_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_TRIBAL_FLOOR_25_STAT", 0, 1);
			addSteamStat("INFINITE_VILLAGE_FLOOR_25_STAT", 0, 1);
			addSteamStat("STORAGE_MAX_STAT", 0, 1);
			mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE, onUserStatsReceived);
			mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE, onStoreStats);
		}
	}

	function addSteamAchievement(inAPIName:String) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		mAchievements.push(SteamAchievement.steamAchievementFactory(inAPIName));
	}

	function addSteamStat(inAPIName:String, inType:Int, inUpdateThreshold:Int) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		mStats.add(inAPIName, SteamStats.steamStatFactory(inAPIName, inType, inUpdateThreshold));
	}

	function onUserStatsReceived(e:SteamEvent) {
		var _loc3_ = 0;
		var _loc5_ = false;
		var _loc2_:IMapIterator = null;
		var _loc4_ = 0;
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		if (e.req_type == 0) {
			Logger.infoch("SteamAchievements", "onUserStatsReceived()");
			_loc3_ = 0;
			while (_loc3_ < mAchievements.length) {
				_loc5_ = mDBFacade.mSteamworks.isAchievement(mAchievements[_loc3_].APIName);
				mAchievements[_loc3_].setIsAchieved(_loc5_);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			_loc2_ = ASCompat.reinterpretAs(mStats.iterator(), IMapIterator);
			while (ASCompat.toBool(_loc2_.next())) {
				_loc4_ = mDBFacade.mSteamworks.getStatInt(_loc2_.key);
				_loc2_.current.setClientIntValue(_loc4_);
			}
		}
	}

	function onStoreStats(e:SteamEvent) {
		var _loc2_ = 0;
		var _loc3_ = false;
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		Logger.infoch("SteamAchievements", "onStoreStats()");
		if (e.req_type == 1) {
			_loc2_ = 0;
			while (_loc2_ < mAchievements.length) {
				_loc3_ = mDBFacade.mSteamworks.isAchievement(mAchievements[_loc2_].APIName);
				mAchievements[_loc2_].setIsAchieved(_loc3_);
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
		}
	}

	function setStatToSteam(inAPIName:String) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		var _loc2_ = getCurrentSteamStats(inAPIName);
		switch (_loc2_.StatType) {
			case 0:
				mDBFacade.mSteamworks.setStatInt(inAPIName, _loc2_.ClientIntValue);
		}
	}

	function storeStatsIfThresholdPassed(oldClientValue:Int, newClientValue:Int, inThreshold:Int) {
		var _loc5_ = Std.int(oldClientValue / inThreshold);
		var _loc4_ = Std.int(newClientValue / inThreshold);
		if (_loc5_ != _loc4_) {
			storeSteamStats();
		}
	}

	function getCurrentSteamStats(inAPIName:String):SteamStats {
		return ASCompat.dynamicAs(mStats.itemFor(inAPIName), SteamStats);
	}

	function updateSteamStatInt(inAPIName:String, inValue:Int, isToIncrease:Bool) {
		var _loc4_ = getCurrentSteamStats(inAPIName);
		var _loc7_ = _loc4_.StoreStatsThreshold;
		var _loc5_ = _loc4_.ClientIntValue;
		if (isToIncrease) {
			_loc4_.increaseClientIntValue(inValue);
		} else {
			_loc4_.setClientIntValue(inValue);
		}
		setStatToSteam(inAPIName);
		var _loc6_ = _loc4_.ClientIntValue;
		storeStatsIfThresholdPassed(_loc5_, _loc6_, _loc7_);
	}

	function storeSteamStats():Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		return mDBFacade.mSteamworks.storeStats();
	}

	function isAchievementUnlocked(inAPIName:String):Bool {
		return mDBFacade.mSteamworks.isAchievement(inAPIName);
	}

	public function setAchievement(inAPIName:String):Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		Logger.infoch("SteamAchievements", "SetAchievement(" + inAPIName + ")");
		if (isAchievementUnlocked(inAPIName)) {
			Logger.infoch("SteamAchievements", "False. Achievement " + inAPIName + " is already unlocked");
			return false;
		}
		mDBFacade.mSteamworks.setAchievement(inAPIName);
		var _loc2_ = mDBFacade.mSteamworks.isAchievement(inAPIName);
		Logger.infoch("SteamAchievements", "Achievement " + inAPIName + " set: " + _loc2_);
		if (_loc2_) {
			storeSteamStats();
			return _loc2_;
		}
		return _loc2_;
	}

	public function resetStatsAndAchievements() {
		mDBFacade.mSteamworks.resetAllStats(true);
		mDBFacade.mSteamworks.requestStats();
	}

	public function findUnlockHeroAchievementAPIName(hero:GMHero):String {
		if (!mIsSteamAchsManagerInitialized) {
			return null;
		}
		return hero.Constant + "_UNLOCK_HERO";
	}

	public function unlockFloorCompleted(inLevelConstant:String) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		var _loc2_ = inLevelConstant + "_LEVEL_COMPLETE";
		setAchievement(_loc2_);
	}

	public function setHeroLevelStat(inLevel:UInt, inHero:GMHero) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		var _loc3_ = inHero.Constant + "_LEVEL_STAT";
		updateSteamStatInt(_loc3_, (inLevel : Int), false);
	}

	public function setValueToStatInt(inAPIName:String, inValue:Int) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		updateSteamStatInt(inAPIName, inValue, false);
	}

	public function addToStatInt(inAPIName:String, inValue:Int) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		updateSteamStatInt(inAPIName, inValue, true);
	}

	public function setHighestFloorAchieved(mMapNode:GMMapNode, inCurrentFloor:UInt) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		if (mMapNode.NodeType != "INFINITE") {
			return;
		}
		var _loc3_:Int = inCurrentFloor;
		var _loc4_ = mMapNode.Constant + "_FLOOR_25_STAT";
		var _loc5_ = mDBFacade.mSteamworks.getStatInt(_loc4_);
		if (inCurrentFloor > (_loc5_ : UInt)) {
			updateSteamStatInt(_loc4_, _loc3_, false);
		}
	}

	public function setMaxStorageStat(previousBucketsWeapon:Int, currentBucketsWeapon:Int) {
		var _loc4_ = 15;
		var _loc3_ = 30;
		var _loc5_ = Std.int(Math.abs(currentBucketsWeapon - _loc3_) / _loc4_);
		setValueToStatInt("STORAGE_MAX_STAT", _loc5_);
	}

	public function checkStorageAchievements() {
		var _loc2_:Int = mDBFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon;
		var _loc3_ = 30;
		var _loc1_ = 120;
		var _loc4_ = 6;
		if (_loc2_ > _loc3_) {
			mDBFacade.steamAchievementsManager.setAchievement("STORAGE_EXPAND_FIRST_TIME");
		}
		if (_loc2_ == _loc1_) {
			mDBFacade.steamAchievementsManager.setValueToStatInt("STORAGE_MAX_STAT", _loc4_);
		}
	}
}
