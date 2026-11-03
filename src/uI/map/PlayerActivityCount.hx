package uI.map;

import brain.assetRepository.AssetLoaderInfo;
import brain.assetRepository.AssetRepository;
import brain.clock.GameClock;
import brain.logger.Logger;
import facade.DBFacade;
import facade.Locale;
import flash.filters.GlowFilter;

class PlayerActivityCount {
	static inline final PLAYER_ACTIVITY_LOCALE_PREFIX = "PLAYER_ACTIVITY_";

	public static final UI_POPULATION_ACTIVE_FILTER:GlowFilter = new GlowFilter((3457628 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_POPULAR_FILTER:GlowFilter = new GlowFilter((9909442 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_BUSTLING_FILTER:GlowFilter = new GlowFilter((12727407 : UInt), 1, 6, 6, 12);

	public static final UI_POPULATION_RAMPAGING_FILTER:GlowFilter = new GlowFilter((12727348 : UInt), 1, 6, 6, 12);

	public var publicDungeonActivityLevel:ASObject = {};

	var mAssetRepository:AssetRepository;

	var mStatusURL:String;

	public function new(dbFacade:DBFacade) {
		mAssetRepository = dbFacade.assetRepository;
		mStatusURL = dbFacade.webServicesUrl + "/game-status";
		fetchPublicDungeonActivityLevel();
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
		var info = new AssetLoaderInfo(mStatusURL, false);
		mAssetRepository.getJsonAsset(info, function(param1:brain.assetRepository.JsonAsset) {
			if (ASCompat.toBool(param1.json) && ASCompat.toBool(param1.json.publicDungeonActivityLevel)) {
				publicDungeonActivityLevel = param1.json.publicDungeonActivityLevel;
			}
		}, function() {
			Logger.warn("game-status request failed: " + mStatusURL);
		});
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
