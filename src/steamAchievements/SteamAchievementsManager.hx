package steamAchievements;

import brain.event.EventListeners;
import brain.logger.Logger;
import collections.IMapIterator;
import collections.Map;
import facade.DBFacade;
import com.amanitadesign.steam.SteamEvent;

class SteamAchievementsManager {
	var mDBFacade:DBFacade;

	var mAppID:UInt = 0;

	var mIsSteamAchsManagerInitialized:Bool = false;

	var mStats:Map;

	var mNamesSteamRejected:ASDictionary<ASAny, ASAny>;

	var mNamesNotRegistered:ASDictionary<ASAny, ASAny>;

	public function new(inDBFacade:DBFacade) {
		mDBFacade = inDBFacade;
		if (mDBFacade.featureFlags.getFlagValue("want-steam-achievements")) {
			mAppID = mDBFacade.mSteamworks.getAppID();
			mStats = new Map();
			mNamesSteamRejected = new ASDictionary<ASAny, ASAny>();
			mNamesNotRegistered = new ASDictionary<ASAny, ASAny>();
			mIsSteamAchsManagerInitialized = true;
			addSteamStat("COINS_SPENT", 0, 10000, 2000000000);
			addSteamStat("BERSERKER_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("RANGER_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("VAMPIRE_HUNTER_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("SORCERER_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("BATTLE_CHEF_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("GHOST_SAMURAI_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("PYROMANCER_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("DRAGON_KNIGHT_HIGHEST_LEVEL", 0, 1, 150);
			addSteamStat("DAILY_REWARDS_REROLLED", 0, 10, 2000000000);
			addSteamStat("ITEMS_SOLD", 0, 10, 2000000000);
			addSteamStat("HEROES_RETRAINED", 0, 50, 2000000000);
			addSteamStat("INFINITE_PRISON_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_DINO_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_AZTECH_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_TEMPLE_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_ARENA_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_ICE_CAVES_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_CATACOMBS_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_TRIBAL_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("INFINITE_VILLAGE_HIGHEST_FLOOR", 0, 1, 55);
			addSteamStat("STORAGE_SLOTS", 0, 1, 1000);
			addSteamStat("ULTIMATE_RAMPAGE_MAPS_AT_FLOOR_25", 0, 1, 9);
			addSteamStat("MOST_HEALTH_BOMBS_IN_DUNGEON", 0, 1, 1000);
			addSteamStat("MOST_REVIVES_IN_DUNGEON", 0, 1, 1000);
			addSteamStat("TEAMMATES_REVIVED", 0, 1, 2000000000);
			addSteamStat("CHESTS_OPENED", 0, 1, 2000000000);
			addSteamStat("DUNGEON_BUSTERS_USED", 0, 1, 2000000000);
			addSteamStat("DUNGEONS_COMPLETED", 0, 1, 2000000000);
			addSteamStat("ENEMIES_KILLED", 0, 1, 2000000000);
			addSteamStat("DUNGEONS_COMPLETED_WITH_FRIENDS", 0, 1, 2000000000);
			addSteamStat("TROPHIES_EARNED", 0, 1, 2000000000);
			addSteamStat("BERSERKER_ASCENSION", 0, 1, 100000);
			addSteamStat("RANGER_ASCENSION", 0, 1, 100000);
			addSteamStat("VAMPIRE_HUNTER_ASCENSION", 0, 1, 100000);
			addSteamStat("SORCERER_ASCENSION", 0, 1, 100000);
			addSteamStat("BATTLE_CHEF_ASCENSION", 0, 1, 100000);
			addSteamStat("GHOST_SAMURAI_ASCENSION", 0, 1, 100000);
			addSteamStat("PYROMANCER_ASCENSION", 0, 1, 100000);
			addSteamStat("DRAGON_KNIGHT_ASCENSION", 0, 1, 100000);
			syncStatsFromSteam("startup");
			EventListeners.add(mDBFacade.mSteamworks, SteamEvent.STEAM_RESPONSE, onUserStatsReceived);
			EventListeners.add(mDBFacade.mSteamworks, SteamEvent.STEAM_RESPONSE, onStoreStats);
		}
	}

	function addSteamStat(inAPIName:String, inType:Int, inUpdateThreshold:Int, inMaxValue:Int) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		mStats.add(inAPIName, SteamStats.steamStatFactory(inAPIName, inType, inUpdateThreshold, inMaxValue));
	}

	function syncStatsFromSteam(inReason:String) {
		var _loc3_:SteamStats = null;
		var _loc5_ = 0;
		var _loc2_ = 0;
		var _loc6_ = 0;
		var _loc4_ = ASCompat.reinterpretAs(mStats.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			_loc3_ = ASCompat.dynamicAs(_loc4_.next(), SteamStats);
			_loc5_ = mDBFacade.mSteamworks.getStatInt(_loc3_.APIName);
			_loc3_.setClientIntValue(_loc5_);
			_loc2_++;
			if (_loc5_ != 0) {
				_loc6_++;
			}
		}
		Logger.infoch("SteamAchievements", "syncStatsFromSteam(" + inReason + "): " + _loc2_ + " stats read, " + _loc6_ + " non-zero");
	}

	function onUserStatsReceived(e:SteamEvent) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		if (e.req_type == 0 && e.response == 1) {
			mNamesSteamRejected = new ASDictionary<ASAny, ASAny>();
			syncStatsFromSteam("onUserStatsReceived");
		}
	}

	function onStoreStats(e:SteamEvent) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		Logger.infoch("SteamAchievements", "onStoreStats() - check its usage");
		if (e.req_type == 1) {}
	}

	function setStatToSteam(inAPIName:String) {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		var _loc2_ = getCurrentSteamStats(inAPIName);
		switch (_loc2_.StatType) {
			case 0:
				if (!mDBFacade.mSteamworks.setStatInt(inAPIName, _loc2_.ClientIntValue)
					&& !ASCompat.toBool(ASDictionary.getString(mNamesSteamRejected, inAPIName))) {
					mNamesSteamRejected[inAPIName] = true;
					Logger.warnch("SteamAchievements",
						"setStatInt("
						+ inAPIName
						+ ", "
						+ _loc2_.ClientIntValue
						+ ") rejected by Steam: stat not configured for app "
						+ mAppID
						+ ", wrong type, or decreased an increment-only stat");
				}
		}
	}

	function storeStatsIfThresholdPassed(oldClientValue:Int, newClientValue:Int, inThreshold:Int) {
		var _loc5_ = ASCompat.floatToInt(oldClientValue / inThreshold);
		var _loc4_ = ASCompat.floatToInt(newClientValue / inThreshold);
		if (_loc5_ != _loc4_) {
			storeSteamStats();
		}
	}

	function getCurrentSteamStats(inAPIName:String):SteamStats {
		return ASCompat.dynamicAs(mStats.itemFor(inAPIName), SteamStats);
	}

	function storeSteamStats():Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		return mDBFacade.mSteamworks.storeStats();
	}

	function setAchievement(inAPIName:String):Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		Logger.infoch("SteamAchievements", "SetAchievement(" + inAPIName + ")");
		if (isAchievementUnlocked(inAPIName)) {
			Logger.infoch("SteamAchievements", "False. Achievement " + inAPIName + " is already unlocked");
			return false;
		}
		if (ASCompat.toBool(ASDictionary.getString(mNamesSteamRejected, inAPIName))) {
			return false;
		}
		mDBFacade.mSteamworks.setAchievement(inAPIName);
		var _loc2_ = mDBFacade.mSteamworks.isAchievement(inAPIName);
		if (!_loc2_) {
			mNamesSteamRejected[inAPIName] = true;
			Logger.warnch("SteamAchievements",
				"SetAchievement("
				+ inAPIName
				+ ") had no effect: achievement not configured for app "
				+ mAppID
				+ " or stats not loaded");
		}
		Logger.infoch("SteamAchievements", "Achievement " + inAPIName + " set: " + _loc2_);
		if (_loc2_) {
			storeSteamStats();
			return _loc2_;
		}
		return _loc2_;
	}

	public function isAchievementUnlocked(inAPIName:String):Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		return mDBFacade.mSteamworks.isAchievement(inAPIName);
	}

	public function unlockAchievement(inAPIName:String):Bool {
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		if (isAchievementUnlocked(inAPIName)) {
			return false;
		}
		return setAchievement(inAPIName);
	}

	public function updateSteamStatInt(inAPIName:String, inValue:Float, isToIncrease:Bool):Bool {
		if (inValue < 0 || inValue % 1 != 0) {
			return false;
		}
		if (!mIsSteamAchsManagerInitialized) {
			return false;
		}
		var _loc6_ = false;
		var _loc4_ = getCurrentSteamStats(inAPIName);
		if (_loc4_ == null) {
			if (ASCompat.toBool(ASDictionary.getString(mNamesNotRegistered, inAPIName))) {
				return false;
			}
			mNamesNotRegistered[inAPIName] = true;
			Logger.warnch("SteamAchievements", "updateSteamStatInt(" + inAPIName + ") ignored: the stat is not registered in SteamAchievementsManager");
			return false;
		}
		var _loc8_ = _loc4_.StoreStatsThreshold;
		var _loc5_ = _loc4_.ClientIntValue;
		if (isToIncrease) {
			_loc4_.increaseClientIntValue(inValue);
		} else {
			_loc4_.setClientIntValue(inValue);
		}
		setStatToSteam(inAPIName);
		var _loc7_ = _loc4_.ClientIntValue;
		if (_loc5_ != _loc7_) {
			_loc6_ = true;
		}
		storeStatsIfThresholdPassed(_loc5_, _loc7_, _loc8_);
		return _loc6_;
	}

	public function resetStatsAndAchievements() {
		if (!mIsSteamAchsManagerInitialized) {
			return;
		}
		mDBFacade.mSteamworks.resetAllStats(true);
		syncStatsFromSteam("resetStatsAndAchievements");
	}

	public function getCurrentSteamStatIntValue(inStatAPIName:String):Int {
		if (!mIsSteamAchsManagerInitialized) {
			return 0;
		}
		return mDBFacade.mSteamworks.getStatInt(inStatAPIName);
	}
}
