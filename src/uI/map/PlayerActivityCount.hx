package uI.map;

import brain.assetRepository.AssetLoaderInfo;
import brain.assetRepository.AssetRepository;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.DoLater;
import config.ServiceDiscoveryLoader;
import facade.DBFacade;
import facade.Locale;
import flash.filters.GlowFilter;

class PlayerActivityCount {
	static inline final PLAYER_ACTIVITY_LOCALE_PREFIX = "PLAYER_ACTIVITY_";

	static inline final CHECK_FRESH_MS = 60000;

	static inline final HOLD_MS = 3000;

	public static final UI_POPULATION_ACTIVE_FILTER:GlowFilter = new GlowFilter((3457628 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_POPULAR_FILTER:GlowFilter = new GlowFilter((9909442 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_BUSTLING_FILTER:GlowFilter = new GlowFilter((12727407 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_RAMPAGING_FILTER:GlowFilter = new GlowFilter((12727348 : UInt), 1, 6, 6, 12);

	public var publicDungeonActivityLevel:ASObject = {};

	var mDBFacade:DBFacade;

	var mAssetRepository:AssetRepository;

	var mStatusURL:String;

	var mChecksInFlight:Int = 0;

	var mLastCheckStartMs:Int = -60000;

	var mHeldAction:ASFunction;

	var mHoldTimeout:DoLater;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mAssetRepository = dbFacade.assetRepository;
		mStatusURL = dbFacade.webServicesUrl + "/game-status";
		fetch(false);
	}

	public function getPopulationGlow(activityLevel:String):GlowFilter {
		if (ASCompat.stringAsBool(activityLevel)) {
			activityLevel = activityLevel.toUpperCase();
			if (activityLevel == "QUIET") {
				return null;
			}
			if (activityLevel == "ACTIVE") {
				return UI_POPULATION_ACTIVE_FILTER;
			}
			if (activityLevel == "POPULAR") {
				return UI_POPULATION_POPULAR_FILTER;
			}
			if (activityLevel == "BUSTLING") {
				return UI_POPULATION_BUSTLING_FILTER;
			}
			if (activityLevel == "RAMPAGING!") {
				return UI_POPULATION_RAMPAGING_FILTER;
			}
		}
		return null;
	}

	public function fetchPublicDungeonActivityLevel(gameClock:GameClock = null) {
		fetch(true);
	}

	public function afterMaintenanceCheck(action:ASFunction) {
		if (mHeldAction == null) {
			if (mChecksInFlight == 0 && flash.Lib.getTimer() - mLastCheckStartMs >= 60000) {
				fetch(true);
			}
			if (mChecksInFlight == 0 || flash.Lib.getTimer() - mLastCheckStartMs >= 3000) {
				action();
				return;
			}
		}
		mHeldAction = action;
		if (mHoldTimeout == null) {
			mHoldTimeout = mDBFacade.realClockWorkManager.doLater(3000 / 1000, function(param1:GameClock = null) {
				mHoldTimeout = null;
				Logger.warn("game-status maintenance check took over 3000ms; going ahead without it");
				releaseHeldAction();
			}, false, "PlayerActivityCount.hold");
		}
	}

	public function dropHeldAction() {
		mHeldAction = null;
		if (mHoldTimeout != null) {
			mDBFacade.realClockWorkManager.removeDoLater(mHoldTimeout);
			mHoldTimeout = null;
		}
	}

	function releaseHeldAction() {
		var _loc1_ = mHeldAction;
		dropHeldAction();
		if (_loc1_ != null && mDBFacade.mainStateMachine.currentStateName == "TownState") {
			_loc1_();
		}
	}

	function fetch(obeyMaintenance:Bool) {
		var info:AssetLoaderInfo;
		if (obeyMaintenance) {
			mChecksInFlight = mChecksInFlight + 1;
			mLastCheckStartMs = flash.Lib.getTimer();
		}
		info = new AssetLoaderInfo(mStatusURL, false);
		mAssetRepository.getJsonAsset(info, function(param1:brain.assetRepository.JsonAsset) {
			if (ASCompat.toBool(param1.json) && ASCompat.toBool(param1.json.publicDungeonActivityLevel)) {
				publicDungeonActivityLevel = param1.json.publicDungeonActivityLevel;
			}
			if (obeyMaintenance) {
				checkFinished(ServiceDiscoveryLoader.maintenanceMessage(param1.json));
			}
		}, function() {
			Logger.warn("game-status request failed: " + mStatusURL);
			if (obeyMaintenance) {
				checkFinished(null);
			}
		});
	}

	function checkFinished(message:String) {
		mChecksInFlight = mChecksInFlight - 1;
		if (message != null) {
			dropHeldAction();
			enterMaintenance(message);
		} else {
			releaseHeldAction();
		}
	}

	function enterMaintenance(message:String) {
		if (mDBFacade.mainStateMachine.currentStateName != "TownState") {
			return;
		}
		Logger.info("game-status carried a maintenance message; showing the exit-only popup");
		mDBFacade.mDistributedObjectManager.enterSocketErrorState((1504 : UInt), message);
	}

	public function getActivityString(id:Int):String {
		var _loc2_:String = null;
		if (ASCompat.toBool(publicDungeonActivityLevel)) {
			_loc2_ = ASCompat.asString(publicDungeonActivityLevel[Std.string(id)]);
			if (ASCompat.stringAsBool(_loc2_)) {
				return getLocalizedActivityString(_loc2_.toUpperCase());
			}
		}
		return getLocalizedActivityString("UNKNOWN");
	}

	function getLocalizedActivityString(activityString:String):String {
		return Locale.getString("PLAYER_ACTIVITY_" + activityString);
	}
}
