package config;

import brain.event.EventComponent;
import brain.logger.Logger;
import brain.utils.ConfigManager;
import facade.DBFacade;

class DBConfigManager extends ConfigManager {
	var mFilePathsToOpen:Array<ASAny> = ["./DbConfiguration/Config.json"];

	var mConfigsToLoad:Array<ASAny> = [];

	var mEventComponent:EventComponent;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		var _loc2_:String;
		final __ax4_iter_518 = mFilePathsToOpen.concat(mDBFacade.mAdditionalConfigFilesToLoad);
		if (checkNullIteratee(__ax4_iter_518))
			for (_tmp_ in __ax4_iter_518) {
				_loc2_ = _tmp_;
				mConfigsToLoad.push(DBFacade.buildFullDownloadPath(_loc2_));
			}
		super(dbFacade, mConfigsToLoad, null, handleFailure);
	}

	override function finishedLoadingFiles() {
		super.finishedLoadingFiles();
		Logger.info("Build Version development");
		mEventComponent.dispatchEvent(new ConfigFileLoadedEvent(this));
	}

	function handleFailure() {
		Logger.fatal("Failed to load config files: " + mConfigsToLoad);
	}
}
