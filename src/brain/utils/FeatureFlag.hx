package brain.utils;

import flash.errors.ArgumentError;

class FeatureFlag {
	static inline final UNSET_ENUM = (0 : UInt);

	static inline final FALSE_ENUM = (1 : UInt);

	static inline final TRUE_ENUM = (2 : UInt);

	public var name:String;

	public var defaultValue:Bool = false;

	var _currentValue:Bool = false;

	var _commandLineFlag:String;

	var _configFileAttributeName:String;

	var configFileValue:UInt = 0;

	var dbValue:UInt = 0;

	var cliValue:UInt = 0;

	var overrideValue:UInt = 0;

	public function new(name:String, defaultValue:Bool, commandLineFlag:String, configFileAttributeName:String) {
		this.name = name;
		this._currentValue = defaultValue;
		this.defaultValue = defaultValue;
		if (ASCompat.stringAsBool(commandLineFlag)) {
			this._commandLineFlag = commandLineFlag;
		} else {
			this._commandLineFlag = "--" + name;
		}
		if (_commandLineFlag.indexOf("--") != 0) {
			throw new ArgumentError("FeatureFlag commandLineFlag must start with --");
		}
		if (_commandLineFlag.indexOf(" ") != -1) {
			throw new ArgumentError("FeatureFlag commandLineFlag must not contain spaces");
		}
		if (ASCompat.stringAsBool(configFileAttributeName)) {
			this._configFileAttributeName = configFileAttributeName;
		} else {
			this._configFileAttributeName = name;
		}
		if (_configFileAttributeName.indexOf(" ") != -1) {
			throw new ArgumentError("ConfigFileAttributeName  must not contain spaces");
		}
		this.configFileValue = (0 : UInt);
		this.dbValue = (0 : UInt);
		this.cliValue = (0 : UInt);
		this.overrideValue = (0 : UInt);
	}

	public static function featureFlagFactory(name:String, defaultValue:Bool, commandLineFlag:String = null,
			configFileAttributeName:String = null):FeatureFlag {
		return new FeatureFlag(name, defaultValue, commandLineFlag, configFileAttributeName);
	}

	public function setConfigFileValue(value:Bool) {
		this.configFileValue = (value ? (2 : UInt) : (1 : UInt) : UInt);
		this.updateCurrentValue();
	}

	public function setDbValue(value:Bool) {
		this.dbValue = (value ? (2 : UInt) : (1 : UInt) : UInt);
		this.updateCurrentValue();
	}

	public function setCliValue(value:Bool) {
		this.cliValue = (value ? (2 : UInt) : (1 : UInt) : UInt);
		this.updateCurrentValue();
	}

	public function setOverrideValue(value:Bool) {
		this.overrideValue = (value ? (2 : UInt) : (1 : UInt) : UInt);
		this.updateCurrentValue();
	}

	public function updateCurrentValue() {
		if (this.overrideValue != 0) {
			this._currentValue = this.overrideValue == 2;
			return;
		}
		if (this.cliValue != 0) {
			this._currentValue = this.cliValue == 2;
			return;
		}
		if (this.dbValue != 0) {
			this._currentValue = this.dbValue == 2;
			return;
		}
		if (this.configFileValue != 0) {
			this._currentValue = this.configFileValue == 2;
			return;
		}
	}

	@:isVar public var currentValue(get, never):Bool;

	public function get_currentValue():Bool {
		return _currentValue;
	}

	@:isVar public var commandLineFlag(get, never):String;

	public function get_commandLineFlag():String {
		return _commandLineFlag;
	}

	@:isVar public var configFileAttributeName(get, never):String;

	public function get_configFileAttributeName():String {
		return _configFileAttributeName;
	}
}
