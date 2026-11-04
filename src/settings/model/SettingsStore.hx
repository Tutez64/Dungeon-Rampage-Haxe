package settings.model;

import brain.utils.FeatureFlags;
import settings.model.bindings.FeatureFlagBinding;

class SettingsStore {
	static inline final FILE_VERSION_KEY = "settingsFileVersion";

	static inline final FILE_VERSION = 2;

	var mLocalFile:LocalSettingsFile;

	public function new() {
		mLocalFile = new LocalSettingsFile();
	}

	public static function applyStartupFlags(featureFlags:FeatureFlags) {
		var _loc3_:String = null;
		var _loc5_:ASAny = /*undefined*/ null;
		var _loc2_:ASObject = new LocalSettingsFile().read();
		if (_loc2_ == null) {
			return;
		}
		var _loc4_:String;
		final __ax4_iter_450:ASObject = SettingsCatalog.STARTUP_FLAGS;
		if (checkNullIteratee(__ax4_iter_450))
			for (_tmp_ in __ax4_iter_450.___keys()) {
				_loc4_ = _tmp_;
				_loc3_ = SettingsCatalog.STARTUP_FLAGS[_loc4_];
				_loc5_ = storedFlagValue(_loc2_, _loc4_, featureFlags.getFlagDefaultValue(_loc3_));
				if (_loc5_ != /*undefined*/ null) {
					featureFlags.setFlagStoredSettingValue(_loc3_, ASCompat.toBool(_loc5_));
				}
			}
	}

	static function coerce(definition:SettingDefinition, raw:ASAny):ASAny {
		var _loc4_:SettingChoice;
		var __ax4_iter_451:Vector<SettingChoice>;
		var _loc3_ = Math.NaN;
		if (definition.coerceValue != null) {
			return definition.coerceValue(raw);
		}
		if (definition.isKeyBinding) {
			return KeyBindingValue.coerce(raw, definition.defaultValue);
		}
		if (definition.isChoice) {
			__ax4_iter_451 = definition.choices;
			if (checkNullIteratee(__ax4_iter_451))
				for (_tmp_ in __ax4_iter_451) {
					_loc4_ = _tmp_;
					if (ASCompat.toString(_loc4_.value) == ASCompat.toString(raw)) {
						return _loc4_.value;
					}
				}
			return definition.defaultValue;
		}
		if (definition.isSlider) {
			_loc3_ = ASCompat.toNumber(raw);
			if (Math.isNaN(_loc3_)) {
				return definition.defaultValue;
			}
			return Math.max(definition.minimum, Math.min(definition.maximum, _loc3_));
		}
		return coerceBoolean(raw);
	}

	static function storedFlagValue(stored:ASObject, id:String, defaultValue:Bool):ASAny {
		if (stored == null || !stored.hasOwnProperty(id)) {
			return /*undefined*/ null;
		}
		var _loc4_ = coerceBoolean(stored[id]);
		if (!stored.hasOwnProperty("settingsFileVersion") && _loc4_ == defaultValue) {
			return /*undefined*/ null;
		}
		return _loc4_;
	}

	static function coerceBoolean(raw:ASAny):Bool {
		if (Std.isOfType(raw, Bool)) {
			return ASCompat.toBool(raw);
		}
		return ASCompat.toString(raw) == "true" || ASCompat.toString(raw) == "1";
	}

	public function destroy() {
		mLocalFile = null;
	}

	public function readAll(catalog:SettingsCatalog):ASObject {
		var _loc4_:ASAny = /*undefined*/ null;
		var _loc2_:ASObject = mLocalFile.read();
		var _loc3_:ASObject = {};
		var _loc5_:SettingDefinition;
		final __ax4_iter_452 = catalog.definitions;
		if (checkNullIteratee(__ax4_iter_452))
			for (_tmp_ in __ax4_iter_452) {
				_loc5_ = _tmp_;
				if (_loc5_.isPersisted) {
					if (Std.isOfType(_loc5_.binding, FeatureFlagBinding)) {
						_loc4_ = storedFlagValue(_loc2_, _loc5_.id, ASCompat.toBool(_loc5_.defaultValue));
						if (_loc4_ != /*undefined*/ null) {
							_loc3_[_loc5_.id] = _loc4_;
						}
					} else if (_loc2_ != null && _loc2_.hasOwnProperty(_loc5_.id)) {
						_loc3_[_loc5_.id] = coerce(_loc5_, _loc2_[_loc5_.id]);
					} else {
						_loc3_[_loc5_.id] = _loc5_.binding.read();
					}
				}
			}
		return _loc3_;
	}

	public function writeAll(catalog:SettingsCatalog, values:ASObject) {
		var _loc3_:ASObject = {};
		_loc3_["settingsFileVersion"] = 2;
		var _loc4_:SettingDefinition;
		final __ax4_iter_453 = catalog.definitions;
		if (checkNullIteratee(__ax4_iter_453))
			for (_tmp_ in __ax4_iter_453) {
				_loc4_ = _tmp_;
				if (_loc4_.isPersisted && values.hasOwnProperty(_loc4_.id)) {
					_loc3_[_loc4_.id] = values[_loc4_.id];
				}
			}
		mLocalFile.write(_loc3_);
	}
}
