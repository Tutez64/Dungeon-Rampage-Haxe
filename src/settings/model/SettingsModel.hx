package settings.model;

import brain.logger.Logger;
import facade.DBFacade;
import input.keyBindings.KeyBindings;
import settings.model.bindings.FeatureFlagBinding;

class SettingsModel {
	static inline final MUSIC_VOLUME_ELEVEN = 11;

	var mDBFacade:DBFacade;

	var mCatalog:SettingsCatalog;

	var mStore:SettingsStore;

	var mValues:ASObject;

	var mStoredValues:ASObject;

	var mForgottenIds:ASObject;

	var mLoadedValues:ASObject;

	var mDirtyIds:ASObject;

	var mChangeListeners:Vector<ASFunction>;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mCatalog = new SettingsCatalog(dbFacade);
		mStore = new SettingsStore();
		mChangeListeners = new Vector<ASFunction>();
		mDirtyIds = {};
		mForgottenIds = {};
		loadAndApply();
		mDBFacade.displayTimingSettings.changed = notifyChanged;
	}

	static function sameValue(definition:SettingDefinition, a:ASAny, b:ASAny):Bool {
		if (a == b) {
			return true;
		}
		return definition.isKeyBinding && KeyBindingValue.equals(a, b);
	}

	@:isVar public var catalog(get, never):SettingsCatalog;

	public function get_catalog():SettingsCatalog {
		return mCatalog;
	}

	@:isVar public var isDirty(get, never):Bool;

	public function get_isDirty():Bool {
		var _loc3_ = 0;
		var _loc2_:ASObject = mDirtyIds;
		var _loc1_:String;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_.___keys()) {
				_loc1_ = _tmp_;
				return true;
			}
		return false;
	}

	@:isVar public var hasPendingRestart(get, never):Bool;

	public function get_hasPendingRestart():Bool {
		var _loc1_:SettingDefinition = null;
		var _loc2_:String;
		final __ax4_iter_470:ASObject = mDirtyIds;
		if (checkNullIteratee(__ax4_iter_470))
			for (_tmp_ in __ax4_iter_470.___keys()) {
				_loc2_ = _tmp_;
				_loc1_ = mCatalog.getDefinition(_loc2_);
				if (_loc1_ != null && _loc1_.requiresRestart) {
					return true;
				}
			}
		return false;
	}

	public function getValue(id:String):ASAny {
		var _loc2_ = mCatalog.getDefinition(id);
		if (_loc2_ == null) {
			return null;
		}
		if (_loc2_.isPreset) {
			return resolvePreset(_loc2_);
		}
		return mValues[id];
	}

	public function getBoolean(id:String):Bool {
		return getValue(id) == true;
	}

	public function getNumber(id:String):Float {
		return ASCompat.toNumber(getValue(id));
	}

	public function setValue(id:String, value:ASAny) {
		var _loc3_ = mCatalog.getDefinition(id);
		if (_loc3_ == null) {
			Logger.warn("Tried to set unknown setting: " + id);
			return;
		}
		if (_loc3_.isPreset) {
			applyPreset(_loc3_, value);
			return;
		}
		if (_loc3_.coerceValue != null) {
			value = _loc3_.coerceValue(value);
		}
		if (sameValue(_loc3_, mValues[id], value)) {
			return;
		}
		mValues[id] = value;
		mDirtyIds[id] = true;
		ASCompat.deleteProperty(mForgottenIds, id);
		if (_loc3_.binding != null) {
			_loc3_.binding.write(value);
		}
		applyAchievementHooks(_loc3_, value);
		notifyChanged(id);
	}

	public function assignKey(id:String, slotName:String, keyCode:Int) {
		var _loc5_:ASObject = null;
		var _loc6_ = mCatalog.getDefinition(id);
		if (_loc6_ == null || !_loc6_.isKeyBinding) {
			Logger.warn("Tried to assign a key to a setting that is not a binding: " + id);
			return;
		}
		if (!KeyBindings.isBindable(keyCode)) {
			return;
		}
		var _loc4_:SettingDefinition;
		final __ax4_iter_471 = mCatalog.definitions;
		if (checkNullIteratee(__ax4_iter_471))
			for (_tmp_ in __ax4_iter_471) {
				_loc4_ = _tmp_;
				if (_loc4_.isKeyBinding) {
					_loc5_ = mValues[_loc4_.id];
					if (KeyBindingValue.primary(_loc5_) == keyCode) {
						setValue(_loc4_.id, KeyBindingValue.withSlot(_loc5_, "primary", 0));
					}
					if (KeyBindingValue.alternate(_loc5_) == keyCode) {
						setValue(_loc4_.id, KeyBindingValue.withSlot(mValues[_loc4_.id], "alternate", 0));
					}
				}
			}
		setValue(id, KeyBindingValue.withSlot(mValues[id], slotName, keyCode));
	}

	public function resetKeyBinding(id:String) {
		var _loc4_ = mCatalog.getDefinition(id);
		if (_loc4_ == null || !_loc4_.isKeyBinding) {
			Logger.warn("Tried to reset the keys of a setting that is not a binding: " + id);
			return;
		}
		var _loc2_ = KeyBindingValue.primary(_loc4_.defaultValue);
		var _loc3_ = KeyBindingValue.alternate(_loc4_.defaultValue);
		setValue(id, KeyBindingValue.make(0, 0));
		if (KeyBindings.isBindable(_loc2_)) {
			assignKey(id, "primary", _loc2_);
		}
		if (KeyBindings.isBindable(_loc3_)) {
			assignKey(id, "alternate", _loc3_);
		}
	}

	public function revert() {
		var _loc1_:String;
		final __ax4_iter_472:ASObject = mDirtyIds;
		if (checkNullIteratee(__ax4_iter_472))
			for (_tmp_ in __ax4_iter_472.___keys()) {
				_loc1_ = _tmp_;
				setValue(_loc1_, mLoadedValues[_loc1_]);
			}
		mDirtyIds = {};
		mForgottenIds = {};
	}

	public function resetCategory(category:String) {
		var _loc2_:SettingDefinition;
		final __ax4_iter_473 = mCatalog.getDefinitionsForCategory(category);
		if (checkNullIteratee(__ax4_iter_473))
			for (_tmp_ in __ax4_iter_473) {
				_loc2_ = _tmp_;
				if (_loc2_.isPersisted) {
					if (Std.isOfType(_loc2_.binding, FeatureFlagBinding)) {
						forgetFlag(_loc2_);
					} else {
						setValue(_loc2_.id, _loc2_.defaultValue);
						if (!sameValue(_loc2_, mStoredValues[_loc2_.id], _loc2_.defaultValue)) {
							mDirtyIds[_loc2_.id] = true;
						}
					}
				}
			}
	}

	public function resetAll() {
		var _loc1_:String;
		final __ax4_iter_474 = SettingCategory.ORDERED;
		if (checkNullIteratee(__ax4_iter_474))
			for (_tmp_ in __ax4_iter_474) {
				_loc1_ = _tmp_;
				resetCategory(_loc1_);
			}
	}

	public function apply() {
		if (!isDirty) {
			return;
		}
		var _loc1_:String;
		final __ax4_iter_475:ASObject = mDirtyIds;
		if (checkNullIteratee(__ax4_iter_475))
			for (_tmp_ in __ax4_iter_475.___keys()) {
				_loc1_ = _tmp_;
				if (ASCompat.toBool(mForgottenIds[_loc1_])) {
					ASCompat.deleteProperty(mStoredValues, _loc1_);
				} else {
					mStoredValues[_loc1_] = mValues[_loc1_];
				}
				mLoadedValues[_loc1_] = mValues[_loc1_];
			}
		mDirtyIds = {};
		mForgottenIds = {};
		mStore.writeAll(mCatalog, mStoredValues);
	}

	function forgetFlag(definition:SettingDefinition) {
		var _loc2_ = definition.id;
		var _loc3_ = mStoredValues.hasOwnProperty(_loc2_) || ASCompat.toBool(mDirtyIds[_loc2_]);
		cast(definition.binding, FeatureFlagBinding).clear();
		var _loc4_:ASAny = definition.binding.read();
		var _loc5_ = !sameValue(definition, mValues[_loc2_], _loc4_);
		mValues[_loc2_] = _loc4_;
		if (_loc3_ || _loc5_) {
			mDirtyIds[_loc2_] = true;
			mForgottenIds[_loc2_] = true;
		}
		if (_loc5_) {
			notifyChanged(_loc2_);
		}
	}

	public function addChangeListener(listener:ASFunction) {
		if (mChangeListeners.indexOf(listener) == -1) {
			mChangeListeners.push(listener);
		}
	}

	public function removeChangeListener(listener:ASFunction) {
		var _loc2_ = mChangeListeners.indexOf(listener);
		if (_loc2_ != -1) {
			mChangeListeners.splice(_loc2_, (1 : UInt));
		}
	}

	public function destroy() {
		apply();
		mDBFacade.displayTimingSettings.changed = null;
		mChangeListeners = null;
		mValues = null;
		mStoredValues = null;
		mLoadedValues = null;
		mDirtyIds = null;
		mForgottenIds = null;
		mStore.destroy();
		mStore = null;
		mCatalog.destroy();
		mCatalog = null;
		mDBFacade = null;
	}

	function loadAndApply() {
		var _loc2_:ASAny = ASCompat.UNDEFINED;
		mStoredValues = mStore.readAll(mCatalog);
		mValues = {};
		mLoadedValues = {};
		var _loc1_:SettingDefinition;
		final __ax4_iter_476 = mCatalog.definitions;
		if (checkNullIteratee(__ax4_iter_476))
			for (_tmp_ in __ax4_iter_476) {
				_loc1_ = _tmp_;
				if (_loc1_.isPersisted) {
					if (mStoredValues.hasOwnProperty(_loc1_.id)) {
						_loc1_.binding.writeInitial(mStoredValues[_loc1_.id]);
					}
					_loc2_ = _loc1_.binding.read();
					mValues[_loc1_.id] = _loc2_;
					mLoadedValues[_loc1_.id] = _loc2_;
				}
			}
	}

	function resolvePreset(definition:SettingDefinition):ASAny {
		var _loc2_:SettingChoice = null;
		var _loc3_:SettingChoice;
		final __ax4_iter_477 = definition.choices;
		if (checkNullIteratee(__ax4_iter_477))
			for (_tmp_ in __ax4_iter_477) {
				_loc3_ = _tmp_;
				if (_loc3_.derived) {
					_loc2_ = _loc3_;
				} else if (_loc3_.memberValues != null) {
					if (membersMatch(_loc3_.memberValues)) {
						return _loc3_.value;
					}
				}
			}
		return _loc2_ != null ? _loc2_.value : definition.defaultValue;
	}

	function membersMatch(memberValues:ASObject):Bool {
		var _loc2_:String;
		if (checkNullIteratee(memberValues))
			for (_tmp_ in memberValues.___keys()) {
				_loc2_ = _tmp_;
				if (mValues[_loc2_] != memberValues[_loc2_]) {
					return false;
				}
			}
		return true;
	}

	function applyPreset(definition:SettingDefinition, value:ASAny) {
		var _loc3_ = definition.findChoice(value);
		if (_loc3_ == null || _loc3_.memberValues == null) {
			return;
		}
		var _loc4_:String;
		final __ax4_iter_478:ASObject = _loc3_.memberValues;
		if (checkNullIteratee(__ax4_iter_478))
			for (_tmp_ in __ax4_iter_478.___keys()) {
				_loc4_ = _tmp_;
				choosePresetMember(_loc4_, _loc3_.memberValues[_loc4_]);
			}
		notifyChanged(definition.id);
	}

	function choosePresetMember(id:String, value:ASAny) {
		var _loc3_ = mCatalog.getDefinition(id);
		if (_loc3_ == null || !sameValue(_loc3_, mValues[id], value)) {
			setValue(id, value);
			return;
		}
		mDirtyIds[id] = true;
		ASCompat.deleteProperty(mForgottenIds, id);
		if (_loc3_.binding != null) {
			_loc3_.binding.write(value);
		}
	}

	function applyAchievementHooks(definition:SettingDefinition, value:ASAny) {
		if (definition.id != "musicVolume") {
			return;
		}
		if (ASCompat.floatToInt(ASCompat.toNumber(value) * definition.displayScale) != 11) {
			return;
		}
		if (mDBFacade.steamAchievementsHelper == null) {
			return;
		}
		mDBFacade.steamAchievementsHelper.unlockAchievement("MUSIC_VOLUME_SET_TO_11");
	}

	function notifyChanged(id:String) {
		var _loc2_ = mChangeListeners.concat();
		var _loc3_:ASFunction;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = _tmp_;
				_loc3_(id);
			}
	}
}
