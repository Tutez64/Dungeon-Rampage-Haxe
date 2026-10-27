package brain.utils;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.JsonAsset;
import brain.facade.Facade;
import brain.logger.Logger;
import flash.external.ExternalInterface;
import flash.system.Capabilities;

class ConfigManager {
	var mFacade:Facade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	public var networkId:Float = 1;

	var mJsonDictionaries:Array<ASAny> = [];

	var mTotalFilePathsToOpen:Int = 0;

	var mLoadedFiles:Int = 0;

	var mLoadedCallback:ASFunction;

	var mFailureCallback:ASFunction;

	var mIsInError:Bool = false;

	var mFilePathsToOpen__Brain_Utils_ConfigManager /*redefined private*/:Array<ASAny>;

	public function new(facade:Facade, filePathsToOpen:Array<ASAny>, loadedCallback:ASFunction, failureCall:ASFunction) {
		mIsInError = false;
		mFacade = facade;
		mAssetLoadingComponent = new AssetLoadingComponent(facade);
		MemoryTracker.track(mAssetLoadingComponent, "AssetLoadingComponent - created in ConfigManager()", "brain");
		mLoadedCallback = loadedCallback;
		mFailureCallback = failureCall;
		mTotalFilePathsToOpen = filePathsToOpen.length;
		mFilePathsToOpen__Brain_Utils_ConfigManager = filePathsToOpen;
		MemoryTracker.track(mJsonDictionaries, "Array - json dictionaries in ConfigManager()", "brain");
	}

	public function init() {
		var _loc1_:ASObject = null;
		var _loc2_:JsonAsset = null;
		var _loc3_ = 0;
		if (Capabilities.playerType != "Desktop") {
			_loc1_ = ExternalInterface.call("Get_App_Parameters");
			Logger.info("Loading Configs From ExternalInterface = " + Std.string(_loc1_));
		}
		if (_loc1_ != null) {
			Logger.info("Loading Configs From HTML host = " + Std.string(_loc1_));
			mTotalFilePathsToOpen = 1;
			_loc2_ = new JsonAsset(_loc1_);
			jsonFileLoaded(_loc2_);
		} else {
			_loc3_ = 0;
			while (_loc3_ < mFilePathsToOpen__Brain_Utils_ConfigManager.length) {
				Logger.info("Loading Config " + Std.string(mFilePathsToOpen__Brain_Utils_ConfigManager[_loc3_]));
				mAssetLoadingComponent.getJsonAsset(mFilePathsToOpen__Brain_Utils_ConfigManager[_loc3_], jsonFileLoaded,
					wrappedJsonFileFailedCallback(mFilePathsToOpen__Brain_Utils_ConfigManager[_loc3_]), false);
				_loc3_++;
			}
		}
	}

	public function isInError():Bool {
		return mIsInError;
	}

	function wrappedJsonFileFailedCallback(path:String):ASFunction {
		return function() {
			jsonFileFailedCallback(path);
		};
	}

	function jsonFileFailedCallback(configFilePath:String) {
		mIsInError = true;
		if (mFailureCallback != null) {
			Logger.warn("Error occurred trying to load config json from path: " + configFilePath);
			mFailureCallback();
		} else {
			Logger.error("Error occurred trying to load config json from path: " + configFilePath);
		}
	}

	function jsonFileLoaded(asset:JsonAsset) {
		var _loc2_ = asset;
		mJsonDictionaries.push(_loc2_.json);
		networkId = getConfigNumber("NetworkId", 1);
		Logger.info("App launched from network: " + networkId);
		mLoadedFiles = mLoadedFiles + 1;
		if (mTotalFilePathsToOpen == mLoadedFiles) {
			finishedLoadingFiles();
		}
	}

	function findValue(configString:String):ASAny {
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ < mJsonDictionaries.length) {
			if (mJsonDictionaries[_loc2_][configString] != null) {
				return mJsonDictionaries[_loc2_][configString];
			}
			_loc2_++;
		}
		return null;
	}

	public function GetValueOrDefault(configString:String, defaultValue:ASObject):ASObject {
		var _loc3_:ASObject = findValue(configString);
		if (_loc3_ != null) {
			return _loc3_;
		}
		return defaultValue;
	}

	public function getConfigBoolean(configString:String, defaultValue:Bool):Bool {
		var _loc3_ = false;
		var _loc4_:ASObject = findValue(configString);
		if (_loc4_ != null) {
			return ASCompat.asBool(_loc4_);
		}
		return defaultValue;
	}

	public function getConfigNumber(configString:String, defaultValue:Float):Float {
		var _loc3_ = Math.NaN;
		var _loc4_:ASObject = findValue(configString);
		if (_loc4_ != null) {
			return ASCompat.asNumber(_loc4_);
		}
		return defaultValue;
	}

	public function getConfigString(configString:String, defaultValue:String):String {
		var _loc3_:String = null;
		var _loc4_:ASObject = findValue(configString);
		if (_loc4_ != null) {
			_loc3_ = ASCompat.asString(_loc4_);
			if (_loc3_ != null) {
				return _loc3_;
			}
			throw new Error("Config string: "
				+ configString
				+ " returned a value: "
				+ Std.string(_loc4_)
				+ " which cannot be converted to a String.");
		}
		return defaultValue;
	}

	public function getConfigObject(configString:String, defaulValue:ASObject):ASObject {
		return findValue(configString);
	}

	function finishedLoadingFiles() {
		if (mLoadedCallback != null) {
			mLoadedCallback();
		}
	}

	public function destroy() {
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
	}
}
