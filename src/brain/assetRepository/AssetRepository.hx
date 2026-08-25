package brain.assetRepository;

import brain.facade.Facade;
import brain.sound.SoundAsset;
import brain.utils.MemoryTracker;
import flash.media.Sound;
import org.as3commons.collections.Map;
import brain.assetRepository.ActiveLoadBase;
import brain.assetRepository.Asset;
import brain.assetRepository.AssetLoader;
import brain.assetRepository.AssetLoaderInfo;
import brain.assetRepository.AssetRepository;

class AssetRepository {
	static var mAssetCache:AssetCache = new AssetCache();

	var mPendingLoads:Map = new Map();

	var mFacade:Facade;

	public function new(facade:Facade) {
		mFacade = facade;
	}

	public function tryCache(Info:AssetLoaderInfo, loadedCallback:ASFunction):Bool {
		var _loc3_ = mAssetCache.itemFor(Info);
		if (_loc3_ != null) {
			if (loadedCallback != null) {
				loadedCallback(_loc3_);
			}
			return true;
		}
		return false;
	}

	function getAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction, assetLoaderClass:Dynamic):Bool {
		var _loc5_:AssetLoader = null;
		var _loc7_ = assetLoaderInfo.getKey();
		if (tryCache(assetLoaderInfo, loadedCallback)) {
			return true;
		}
		var _loc6_ = ASCompat.dynamicAs(mPendingLoads.itemFor(_loc7_), brain.assetRepository.ActiveLoadBase);
		if (_loc6_ == null) {
			_loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(assetLoaderClass, [
				mFacade,
				assetLoaderInfo,
				this.executeSuccessCallbacks,
				this.executeErrorCallbacks
			]), brain.assetRepository.AssetLoader);
			MemoryTracker.track(_loc5_, "AssetLoader - loading: " + _loc7_, "brain");
			_loc6_ = new ActiveLoaderWithLoader(_loc5_, this, assetLoaderInfo);
			MemoryTracker.track(_loc6_, "ActiveLoaderWithLoader - loading: " + _loc7_, "brain");
			mPendingLoads.add(_loc7_, _loc6_);
		}
		_loc6_.AddCallback(loadedCallback, errorCallback);
		return false;
	}

	public function getJsonAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, JsonAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function getXMLAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, XMLAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function getByteArrayAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, ByteArrayAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function getSwfAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, SwfAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function getImageAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, ImageAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function getSpriteSheetAsset(facade:Facade, sheetLoaderInfo:SpriteSheetAssetLoaderInfo, bitmapDataName:String, loadedCallback:ASFunction,
			errorCallback:ASFunction, trickelLoaderCallback:ASFunction, shClassName:String, assetLoadingComponent:AssetLoadingComponent = null) {
		var activeLoad:ActiveLoadBase;
		var swfLoaderInfo:AssetLoaderInfo;
		var loadSpriteSheetFromCache:ASFunction;
		var loadSpriteSheet:ASFunction;
		var trackLoad:ActiveLoaderDependent;
		if (tryCache(sheetLoaderInfo, loadedCallback)) {
			return;
		}
		activeLoad = ASCompat.dynamicAs(mPendingLoads.itemFor(sheetLoaderInfo.getKey()), brain.assetRepository.ActiveLoadBase);
		if (activeLoad != null) {
			activeLoad.AddCallback(loadedCallback, errorCallback);
			return;
		}
		swfLoaderInfo = new AssetLoaderInfo(sheetLoaderInfo.getRawAssetPath(), sheetLoaderInfo.useCache);
		MemoryTracker.track(swfLoaderInfo, "AssetLoaderInfo - SpriteSheet SWF: " + sheetLoaderInfo.getRawAssetPath(), "brain");
		loadSpriteSheetFromCache = function(param1:SwfAsset) {
			var _loc2_:SpriteSheetAsset = null;
			if (ASCompat.toBool((param1.root : ASAny).JsonObject) && ASCompat.toBool((param1.root : ASAny).JsonObject[shClassName])) {
				_loc2_ = new SpriteSheetAsset(facade);
				_loc2_.FactoryFromSWf(StringTools.replace(bitmapDataName, ".png", ""), (param1.root : ASAny).JsonObject[shClassName], param1);
				MemoryTracker.track(_loc2_, "SpriteSheetAsset - " + bitmapDataName + " (from cache)", "brain");
				mAssetCache.add(sheetLoaderInfo, _loc2_);
				if (loadedCallback != null) {
					loadedCallback(_loc2_);
				}
			}
		};
		if (tryCache(swfLoaderInfo, loadSpriteSheetFromCache)) {
			return;
		}
		loadSpriteSheet = function(param1:SwfAsset) {
			var _loc2_:SpriteSheetAsset = null;
			if (ASCompat.toBool((param1.root : ASAny).JsonObject) && ASCompat.toBool((param1.root : ASAny).JsonObject[shClassName])) {
				_loc2_ = new SpriteSheetAsset(facade);
				_loc2_.FactoryFromSWf(StringTools.replace(bitmapDataName, ".png", ""), (param1.root : ASAny).JsonObject[shClassName], param1);
				MemoryTracker.track(_loc2_, "SpriteSheetAsset - " + bitmapDataName + " (new load)", "brain");
				mAssetCache.add(sheetLoaderInfo, _loc2_);
				executeSuccessCallbacks(sheetLoaderInfo, _loc2_);
			}
		};
		trackLoad = new ActiveLoaderDependent(this, loadSpriteSheet, sheetLoaderInfo);
		MemoryTracker.track(trackLoad, "ActiveLoaderDependent - SpriteSheet: " + bitmapDataName, "brain");
		mPendingLoads.add(sheetLoaderInfo.getKey(), trackLoad);
		trackLoad.AddCallback(loadedCallback, errorCallback);
		if (assetLoadingComponent != null) {
			assetLoadingComponent.getSwfAsset(swfLoaderInfo.getRawAssetPath(), trackLoad.successCallback, trackLoad.errorCallback);
		} else {
			getSwfAsset(swfLoaderInfo, trackLoad.successCallback, trackLoad.errorCallback);
		}
	}

	public function getSoundAsset(assetLoaderInfo:SoundAssetLoaderInfo, soundName:String, loadedCallback:ASFunction, errorCallback:ASFunction = null) {
		var activeLoad:ActiveLoadBase;
		var swfLoaderInfo:AssetLoaderInfo;
		var loadSoundFromCache:ASFunction;
		var loadSound:ASFunction;
		var trackLoad:ActiveLoaderDependent;
		var cacheKey = assetLoaderInfo.getKey();
		if (tryCache(assetLoaderInfo, loadedCallback)) {
			return;
		}
		activeLoad = ASCompat.dynamicAs(mPendingLoads.itemFor(cacheKey), brain.assetRepository.ActiveLoadBase);
		if (activeLoad != null) {
			activeLoad.AddCallback(loadedCallback, errorCallback);
			return;
		}
		swfLoaderInfo = new AssetLoaderInfo(assetLoaderInfo.getRawAssetPath(), assetLoaderInfo.useCache);
		MemoryTracker.track(swfLoaderInfo, "AssetLoaderInfo - Sound SWF: " + assetLoaderInfo.getRawAssetPath(), "brain");
		loadSoundFromCache = function(param1:SwfAsset) {
			var _loc3_:Sound = null;
			var _loc4_:SoundAsset = null;
			var _loc2_ = param1.getClass(soundName);
			if (_loc2_ != null) {
				_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), Sound);
				_loc4_ = new SoundAsset(_loc3_);
				MemoryTracker.track(_loc4_, "SoundAsset - " + soundName + " (from cache)", "brain");
				mAssetCache.add(assetLoaderInfo, _loc4_);
				loadedCallback(_loc4_);
			} else if (errorCallback != null) {
				errorCallback();
			}
		};
		if (tryCache(swfLoaderInfo, loadSoundFromCache)) {
			return;
		}
		loadSound = function(param1:SwfAsset) {
			var _loc3_:Sound = null;
			var _loc4_:SoundAsset = null;
			var _loc2_ = param1.getClass(soundName);
			if (_loc2_ != null) {
				_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), Sound);
				_loc4_ = new SoundAsset(_loc3_);
				MemoryTracker.track(_loc4_, "SoundAsset - " + soundName + " (new load)", "brain");
				executeSuccessCallbacks(assetLoaderInfo, _loc4_);
			} else {
				executeErrorCallbacks(assetLoaderInfo);
			}
		};
		trackLoad = new ActiveLoaderDependent(this, loadSound, assetLoaderInfo);
		MemoryTracker.track(trackLoad, "ActiveLoaderDependent - Sound: " + soundName, "brain");
		mPendingLoads.add(cacheKey, trackLoad);
		trackLoad.AddCallback(loadedCallback, errorCallback);
		getSwfAsset(swfLoaderInfo, trackLoad.successCallback, trackLoad.errorCallback);
	}

	public function getURLSoundAsset(assetLoaderInfo:SoundAssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null):AssetLoaderInfo {
		var _loc4_ = getAsset(assetLoaderInfo, loadedCallback, errorCallback, URLSoundAssetLoader);
		return ASCompat.dynamicAs(_loc4_ ? null : assetLoaderInfo, brain.assetRepository.AssetLoaderInfo);
	}

	public function removeCallbackFromPendingDownload(assetKey:String, loadedCallback:ASFunction):Bool {
		var _loc3_ = false;
		var _loc4_ = ASCompat.dynamicAs(mPendingLoads.itemFor(assetKey), brain.assetRepository.ActiveLoadBase);
		if (_loc4_ != null) {
			_loc3_ = _loc4_.removeCallback(loadedCallback, null);
			if (_loc4_.hasNoCallbacks()) {
				mPendingLoads.removeKey(assetKey);
				_loc4_.destroy();
			}
		}
		return _loc3_;
	}

	public function removeErrorCallbackFromPendingDownload(assetKey:String, errorCallback:ASFunction):Bool {
		var _loc3_ = false;
		var _loc4_ = ASCompat.dynamicAs(mPendingLoads.itemFor(assetKey), brain.assetRepository.ActiveLoadBase);
		if (_loc4_ != null) {
			_loc3_ = _loc4_.removeCallback(null, errorCallback);
			if (_loc4_.hasNoCallbacks()) {
				mPendingLoads.removeKey(assetKey);
				_loc4_.destroy();
			}
		}
		return _loc3_;
	}

	function executeSuccessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) {
		var _loc4_ = assetLoaderInfo.getKey();
		mAssetCache.add(assetLoaderInfo, asset);
		var _loc3_ = ASCompat.dynamicAs(mPendingLoads.removeKey(_loc4_), brain.assetRepository.ActiveLoadBase);
		if (_loc3_ != null) {
			_loc3_.executeSucessCallbacks(assetLoaderInfo, asset);
			_loc3_.destroy();
		}
	}

	public function executeErrorCallbacks(assetLoaderInfo:AssetLoaderInfo) {
		var _loc2_:ActiveLoadBase = null;
		var _loc3_ = assetLoaderInfo.getKey();
		if (mPendingLoads.hasKey(_loc3_)) {
			_loc2_ = ASCompat.dynamicAs(mPendingLoads.removeKey(_loc3_), brain.assetRepository.ActiveLoadBase);
			if (_loc2_ != null) {
				_loc2_.executeErrorCallbacks(assetLoaderInfo);
				_loc2_.destroy();
			}
		}
	}

	public function removeCacheForAllSpriteSheetAssets() {
		mAssetCache.removeCacheForSpriteSheetAssets();
	}

	public function removeFromCache(asset:Asset):Bool {
		return mAssetCache.remove(asset);
	}

	public function destroy() {}
}

final private class ActiveLoaderWithLoader extends ActiveLoadBase {
	public var mAssetLoader:AssetLoader;

	public function new(assetLoader:AssetLoader, assetRepository:AssetRepository, info:AssetLoaderInfo) {
		super(assetRepository, info);
		this.mAssetLoader = assetLoader;
	}

	override public function destroy() {
		super.destroy();
		mAssetLoader.destroy();
		mAssetLoader = null;
	}

	override public function executeSucessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) {
		super.executeSucessCallbacks(assetLoaderInfo, asset);
	}
}

final private class ActiveLoaderDependent extends ActiveLoadBase {
	public var mSuccess:ASFunction;

	public function new(assetRepository:AssetRepository, callback:ASFunction, info:AssetLoaderInfo) {
		super(assetRepository, info);
		mSuccess = callback;
	}

	public function successCallback(asset:ASObject) {
		mSuccess(asset);
	}

	public function errorCallback() {
		mAssetRepository.executeErrorCallbacks(mInfo);
	}

	override public function destroy() {
		mSuccess = null;
		mAssetRepository.removeCallbackFromPendingDownload(mInfo.getKey(), successCallback);
		mAssetRepository.removeErrorCallbackFromPendingDownload(mInfo.getKey(), errorCallback);
		super.destroy();
	}
}
