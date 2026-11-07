package brain.utils;

import brain.logger.Logger;

class FeatureFlags {
	public static inline final WANT_ZOOM = "want-zoom";

	public static inline final WANT_DYNAMIC_RARITY_BACKGROUNDS = "want-dynamic-rarity-backgrounds";

	public static inline final WANT_DAMAGE_FLOATERS = "want-damage-floaters";

	public static inline final WANT_TOWN_ANIMATIONS = "want-town-animations";

	public static inline final WANT_BUSTER_BACKGROUND_FADE = "want-buster-background-fade";

	public static inline final WANT_PICKUP_UI_POP = "want-pickup-ui-pop";

	public static inline final WANT_MANA_BARS = "want-mana-bars";

	public static inline final QUALITY_CONTROL_BUTTON = "quality-control-button";

	public static inline final WANT_NUMBERS_ON_BARS = "want-numbered-hud";

	public static inline final WANT_REFRESH_HUD_ON_FLOOR_TRANSITION = "want-hud-refresh-on-floor-transition";

	public static inline final EXPERIMENTAL_USE_STEAM_INPUT = "experimental-use-steam-input";

	public static inline final WANT_STEAM_ACHIEVEMENTS = "want-steam-achievements";

	public static inline final FILE_LOGGING_BY_DEFAULT = "file-logging-by-default";

	public static inline final START_WINDOWED = "start-windowed";

	public static inline final DEBUG_OUTLINE_SWF_FALLBACK_PROPS = "debug-outline-swf-fallback-props";

	public static inline final DEBUG_OUTLINE_SWF_FALLBACK = "debug-outline-swf-fallback";

	public static inline final AUTO_SIZE_TEXT = "auto-size-text";

	public static inline final WANT_WEAPON_CURSORS = "want-weapon-cursors";

	public static inline final WANT_CONTROLLER_RUMBLE = "want-controller-rumble";

	public static inline final EXPERIMENTAL_WEBSOCKET_RECONNECTS = "experimental-websocket-reconnects";

	public static inline final SUBPIXEL_CAMERA_TRANSLATION = "subpixel-camera-translation";

	public static inline final BAKE_STATIC_LAYERS = "bake-static-layers";

	public static inline final SMOOTH_RUN_AND_DIRECTION_STATES = "smooth-run-and-direction-states";

	public static inline final SKIP_ROOT_LABELLED_CLIP_FOLDERS = "skip-root-labelled-clip-folders";

	public static inline final LOADING_PREWARM_HOLD = "loading-prewarm-hold";

	public static inline final STARLING_OVERLAYS = "starling-overlays";

	public static inline final STARLING_HUD = "starling-hud";

	public static inline final STARLING_CHAT_PROMPT = "starling-chat-prompt";

	var mFeatureFlags:ASDictionary<ASAny, ASAny>;

	public function new() {
		mFeatureFlags = new ASDictionary<ASAny, ASAny>();
		MemoryTracker.track(mFeatureFlags, "Dictionary - feature flags storage in FeatureFlags()", "brain");
		addFeatureFlag("want-zoom", true);
		addFeatureFlag("want-dynamic-rarity-backgrounds", true);
		addFeatureFlag("want-damage-floaters", true);
		addFeatureFlag("want-town-animations", false);
		addFeatureFlag("want-buster-background-fade", true);
		addFeatureFlag("want-pickup-ui-pop", true);
		addFeatureFlag("want-mana-bars", false);
		addFeatureFlag("quality-control-button", true);
		addFeatureFlag("want-numbered-hud", false);
		addFeatureFlag("want-hud-refresh-on-floor-transition", true);
		addFeatureFlag("experimental-use-steam-input", true);
		addFeatureFlag("want-steam-achievements", true);
		addFeatureFlag("start-windowed", false);
		addFeatureFlag("file-logging-by-default", false);
		addFeatureFlag("debug-outline-swf-fallback-props", false);
		addFeatureFlag("debug-outline-swf-fallback", false);
		addFeatureFlag("auto-size-text", true);
		addFeatureFlag("want-weapon-cursors", false);
		addFeatureFlag("want-controller-rumble", true);
		addFeatureFlag("experimental-websocket-reconnects", false);
		addFeatureFlag("subpixel-camera-translation", false);
		addFeatureFlag("bake-static-layers", true);
		addFeatureFlag("smooth-run-and-direction-states", false);
		addFeatureFlag("skip-root-labelled-clip-folders", false);
		addFeatureFlag("loading-prewarm-hold", true);
		addFeatureFlag("starling-overlays", true);
		addFeatureFlag("starling-hud", true);
		addFeatureFlag("starling-chat-prompt", true);
	}

	function addFeatureFlag(name:String, defaultValue:Bool, commandLineFlag:String = null, configFileAttributeName:String = null) {
		mFeatureFlags[name] = FeatureFlag.featureFlagFactory(name, defaultValue, commandLineFlag, configFileAttributeName);
	}

	public function getFlagValue(name:String):Bool {
		return ASCompat.toBool(ASDictionary.getString(mFeatureFlags, name).currentValue);
	}

	public function getFlagDefaultValue(name:String):Bool {
		return ASCompat.toBool(ASDictionary.getString(mFeatureFlags, name).defaultValue);
	}

	public function setFlagDatabaseValueOnFirstLoad(flagName:String, value:Bool) {
		ASDictionary.getString(mFeatureFlags, flagName).setDbValue(value);
	}

	public function setFlagConfigFileValue(flagName:String, value:Bool) {
		ASDictionary.getString(mFeatureFlags, flagName).setConfigFileValue(value);
	}

	public function setFlagStoredSettingValue(flagName:String, value:Bool) {
		ASDictionary.getString(mFeatureFlags, flagName).setStoredSettingValue(value);
	}

	public function clearFlagPlayerValues(flagName:String) {
		ASDictionary.getString(mFeatureFlags, flagName).clearPlayerValues();
	}

	public function setFlagCliValue(flagName:String, value:Bool) {
		ASDictionary.getString(mFeatureFlags, flagName).setCliValue(value);
	}

	public function setFlagOverrideValue(flagName:String, value:Bool) {
		ASDictionary.getString(mFeatureFlags, flagName).setOverrideValue(value);
	}

	public function loadFeatureFlagValuesFromCli(arguments:Array<ASAny>) {
		var _loc2_:FeatureFlag;
		var __ax4_iter_34:ASDictionary<ASAny, ASAny>;
		var _loc6_ = 0;
		var _loc5_:String = null;
		var _loc8_:FeatureFlag = null;
		var _loc7_ = false;
		var _loc3_:String = null;
		var _loc4_:String = null;
		_loc6_ = 0;
		while (_loc6_ < arguments.length) {
			_loc5_ = arguments[_loc6_];
			if (_loc5_.indexOf("--") == 0) {
				_loc8_ = null;
				__ax4_iter_34 = mFeatureFlags;
				if (checkNullIteratee(__ax4_iter_34))
					for (_tmp_ in __ax4_iter_34) {
						_loc2_ = ASCompat.coerce(_tmp_, brain.utils.FeatureFlag);
						if (_loc2_.commandLineFlag == _loc5_) {
							_loc8_ = _loc2_;
							break;
						}
					}
				if (_loc8_ != null) {
					_loc7_ = true;
					if (_loc6_ + 1 < arguments.length) {
						_loc3_ = arguments[_loc6_ + 1];
						_loc4_ = _loc3_.toLowerCase();
						if (_loc4_ == "true" || _loc4_ == "false") {
							_loc7_ = _loc4_ == "true";
							_loc6_++;
						}
					}
					_loc8_.setCliValue(_loc7_);
				}
			}
			_loc6_++;
		}
	}

	public function loadFeatureFlagValuesFromConfigs(configManager:ConfigManager) {
		var _loc4_:ASObject = null;
		var _loc3_ = false;
		var _loc2_:FeatureFlag;
		final __ax4_iter_35 = mFeatureFlags;
		if (checkNullIteratee(__ax4_iter_35))
			for (_tmp_ in __ax4_iter_35) {
				_loc2_ = ASCompat.coerce(_tmp_, brain.utils.FeatureFlag);
				_loc4_ = configManager.getConfigObject(_loc2_.configFileAttributeName, null);
				if (_loc4_ != null) {
					_loc3_ = ASCompat.asBool(_loc4_);
					_loc2_.setConfigFileValue(_loc3_);
				}
			}
	}

	public function logFeatureFlagNamesAndValues() {
		var _loc1_:ASObject;
		final __ax4_iter_36 = mFeatureFlags;
		if (checkNullIteratee(__ax4_iter_36))
			for (_tmp_ in __ax4_iter_36) {
				_loc1_ = _tmp_;
				Logger.log("Flag Name: " + Std.string(_loc1_.name) + " Flag Value:" + getFlagValue(_loc1_.name));
			}
	}
}
