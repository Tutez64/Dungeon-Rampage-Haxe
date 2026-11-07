package settings.model.bindings;

import facade.DBFacade;

class FeatureFlagBinding implements ISettingBinding {
	var mDBFacade:DBFacade;

	var mFlagName:String;

	public function new(dbFacade:DBFacade, flagName:String) {
		mDBFacade = dbFacade;
		mFlagName = flagName;
	}

	public function read():ASAny {
		return mDBFacade.featureFlags.getFlagValue(mFlagName);
	}

	public function write(value:ASAny) {
		mDBFacade.featureFlags.setFlagOverrideValue(mFlagName, ASCompat.asBool(value));
	}

	public function writeInitial(value:ASAny) {
		mDBFacade.featureFlags.setFlagStoredSettingValue(mFlagName, ASCompat.asBool(value));
	}

	public function clear() {
		mDBFacade.featureFlags.clearFlagPlayerValues(mFlagName);
	}

	public function destroy() {
		mDBFacade = null;
	}
}
