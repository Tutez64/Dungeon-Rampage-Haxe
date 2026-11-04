package settings.model;

import dBGlobals.DBGlobal;
import facade.DBFacade;
import input.keyBindings.InputAction;
import settings.model.bindings.DisplayTimingBinding;
import settings.model.bindings.HudStyleBinding;
import settings.model.bindings.KeyBindingSettingBinding;
import settings.model.bindings.SoundVolumeBinding;

class SettingsCatalog {
	public static final STARTUP_FLAGS:ASObject = buildStartupFlags();

	var mDBFacade:DBFacade;

	var mDefinitions:Vector<SettingDefinition>;

	var mDefinitionsById:ASDictionary<ASAny, ASAny>;

	public function new(dbFacade:DBFacade) {
		var _loc3_:SettingDefinition;
		var __ax4_iter_455:Vector<SettingDefinition>;

		mDBFacade = dbFacade;
		mDefinitions = new Vector<SettingDefinition>();
		mDefinitionsById = new ASDictionary<ASAny, ASAny>();
		var _loc4_ = Vector.ofArray([
			defineGraphics(),
			defineAudio(),
			defineControls(),
			defineInterface(),
			defineDisplay(),
			defineAdvanced()
		]);
		var _loc2_:SettingsSection;
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc2_ = _tmp_;
				__ax4_iter_455 = _loc2_.build();
				if (checkNullIteratee(__ax4_iter_455))
					for (_tmp_ in __ax4_iter_455) {
						_loc3_ = _tmp_;
						mDefinitions.push(_loc3_);
						mDefinitionsById[_loc3_.id] = _loc3_;
					}
			}
	}

	static function startupFlag(declared:SettingsSection, id:String):SettingBuilder {
		return declared.flag(id, STARTUP_FLAGS[id]).requiresRestart();
	}

	static function buildStartupFlags():ASObject {
		var _loc1_:ASObject = {};
		_loc1_["steamInput"] = "experimental-use-steam-input";
		_loc1_["startWindowed"] = "start-windowed";
		_loc1_["resumableConnection"] = "experimental-websocket-reconnects";
		return _loc1_;
	}

	@:isVar public var definitions(get, never):Vector<SettingDefinition>;

	public function get_definitions():Vector<SettingDefinition> {
		return mDefinitions;
	}

	public function getDefinition(id:String):SettingDefinition {
		return ASCompat.dynamicAs(mDefinitionsById[id], SettingDefinition);
	}

	public function getDefinitionsForCategory(category:String):Vector<SettingDefinition> {
		var _loc2_ = new Vector<SettingDefinition>();
		var _loc3_:SettingDefinition;
		final __ax4_iter_456 = mDefinitions;
		if (checkNullIteratee(__ax4_iter_456))
			for (_tmp_ in __ax4_iter_456) {
				_loc3_ = _tmp_;
				if (_loc3_.category == category) {
					_loc2_.push(_loc3_);
				}
			}
		return _loc2_;
	}

	public function destroy() {
		var _loc1_:SettingDefinition;
		final __ax4_iter_457 = mDefinitions;
		if (checkNullIteratee(__ax4_iter_457))
			for (_tmp_ in __ax4_iter_457) {
				_loc1_ = _tmp_;
				if (_loc1_.binding != null) {
					_loc1_.binding.destroy();
					_loc1_.binding = null;
				}
				_loc1_.coerceValue = null;
				_loc1_.descriptionKeyProvider = null;
			}
		mDefinitions = null;
		mDefinitionsById = null;
		mDBFacade = null;
	}

	function section(category:String):SettingsSection {
		return new SettingsSection(mDBFacade, category);
	}

	function defineGraphics():SettingsSection {
		var _loc1_ = section("graphics");
		_loc1_.setting("graphicsPreset")
			.defaultsTo("quality")
			.presetChoice("performance", GraphicsPreset.membersAt(false))
			.presetChoice("quality", GraphicsPreset.membersAt(true))
			.derivedChoice("custom");
		_loc1_.flag("zoom", "want-zoom");
		_loc1_.flag("damageFloaters", "want-damage-floaters");
		_loc1_.flag("rarityBackgrounds", "want-dynamic-rarity-backgrounds");
		_loc1_.flag("busterBackgroundFade", "want-buster-background-fade");
		return _loc1_;
	}

	function defineAudio():SettingsSection {
		var _loc1_ = section("audio");
		volume(_loc1_, "musicVolume", "music");
		volume(_loc1_, "sfxVolume", "sfx");
		return _loc1_;
	}

	function volume(audio:SettingsSection, id:String, channel:String) {
		audio.setting(id)
			.defaultsTo(channel == "music" ? DBGlobal.MUSIC_VOLUME : DBGlobal.SFX_VOLUME)
			.boundTo(new SoundVolumeBinding(mDBFacade, channel))
			.range(0, 1.1, 0.1)
			.displayedAs(10);
	}

	function defineControls():SettingsSection {
		var _loc1_ = section("controls");
		startupFlag(_loc1_, "steamInput");
		_loc1_.flag("controllerRumble", "want-controller-rumble");
		var _loc2_:String;
		final __ax4_iter_458 = InputAction.ORDERED;
		if (checkNullIteratee(__ax4_iter_458))
			for (_tmp_ in __ax4_iter_458) {
				_loc2_ = _tmp_;
				_loc1_.setting(SettingIds.keyBindingIdFor(_loc2_))
					.keyBinding(_loc2_)
					.defaultsTo(KeyBindingValue.make(InputAction.defaultPrimary(_loc2_), InputAction.defaultAlternate(_loc2_)))
					.boundTo(new KeyBindingSettingBinding(mDBFacade, _loc2_));
			}
		return _loc1_;
	}

	function defineInterface():SettingsSection {
		var _loc1_ = section("interface");
		_loc1_.setting("hudStyle")
			.defaultsTo(0)
			.boundTo(new HudStyleBinding(mDBFacade))
			.choice(0, "SETTING_HUD_STYLE_ORIGINAL")
			.choice(1, "SETTING_HUD_STYLE_CONDENSED");
		_loc1_.flag("numbersOnBars", "want-numbered-hud");
		_loc1_.flag("townAnimations", "want-town-animations");
		_loc1_.flag("pickupUiPop", "want-pickup-ui-pop");
		return _loc1_;
	}

	function defineDisplay():SettingsSection {
		var _loc2_ = section("display");
		var _loc1_ = mDBFacade.displayTimingSettings;
		_loc2_.setting("fps")
			.defaultsTo(60)
			.boundTo(new DisplayTimingBinding(_loc1_, true))
			.choicesFrom(_loc1_.frameRates.choices, FrameRateOptions.coerce);
		_loc2_.setting("vsync")
			.defaultsTo(true)
			.boundTo(new DisplayTimingBinding(_loc1_, false))
			.descriptionFrom(_loc1_.vsyncDescriptionKey);
		startupFlag(_loc2_, "startWindowed");
		return _loc2_;
	}

	function defineAdvanced():SettingsSection {
		var _loc1_ = section("advanced");
		startupFlag(_loc1_, "resumableConnection");
		return _loc1_;
	}
}
