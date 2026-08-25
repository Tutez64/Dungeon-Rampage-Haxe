package uI.map;

import brain.assetRepository.AssetLoaderInfo;
import brain.assetRepository.AssetRepository;
import brain.clock.GameClock;
import brain.logger.Logger;
import facade.DBFacade;
import facade.Locale;

class PlayerActivityCount {
	static inline final PLAYER_ACTIVITY_LOCALE_PREFIX = "PLAYER_ACTIVITY_";

	public var publicDungeonActivityLevel:ASObject = {};

	var mAssetRepository:AssetRepository;

	var mStatusURL:String;

	public function new(dbFacade:DBFacade) {
		mAssetRepository = dbFacade.assetRepository;
		mStatusURL = dbFacade.webServicesUrl + "/game-status";
		fetchPublicDungeonActivityLevel();
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
		var _loc2_ = ASCompat.asString(publicDungeonActivityLevel[Std.string(id)]);
		if (ASCompat.stringAsBool(_loc2_)) {
			return getLocalizedActivityString(_loc2_.toUpperCase());
		}
		return getLocalizedActivityString("UNKNOWN");
	}

	function getLocalizedActivityString(activityString:String):String {
		return Locale.getString("PLAYER_ACTIVITY_" + activityString);
	}
}
