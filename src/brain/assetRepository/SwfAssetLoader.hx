package brain.assetRepository;

import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.MovieClip;
import flash.filesystem.File;

class SwfAssetLoader extends AssetLoader {
	var mSwfAsset:SwfAsset;

	var mOriginalLoadedCallback:ASFunction;

	var mHdAssetLoader:AssetLoader;

	var mIsHdLoader:Bool = false;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction, isHdLoader:Bool = false) {
		mIsHdLoader = isHdLoader;
		if (!mIsHdLoader) {
			mOriginalLoadedCallback = loadedCallback;
		}
		var _loc6_ = loadedCallback;
		if (!mIsHdLoader && facade.featureFlags.getFlagValue("use-hd-assets")) {
			_loc6_ = hdAwareLoadedCallback;
		}
		super(facade, assetLoaderInfo, _loc6_, errorCallback, true);
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		var _loc2_ = ASCompat.dynamicAs(loadedObject, MovieClip);
		mSwfAsset = new SwfAsset(_loc2_, mAssetLoaderInfo.getRawAssetPath());
		return mSwfAsset;
	}

	function hdAwareLoadedCallback(assetLoaderInfo:AssetLoaderInfo, asset:Asset) {
		var _loc3_:AssetLoaderInfo = null;
		mSwfAsset = ASCompat.reinterpretAs(asset, SwfAsset);
		var _loc4_ = assetLoaderInfo.getRawAssetPath();
		var _loc5_ = getHdPath(_loc4_);
		if (_loc5_ != null && hdFileExists(_loc5_)) {
			Logger.info("SwfAssetLoader: HD file exists, loading: " + _loc5_);
			_loc3_ = new AssetLoaderInfo(_loc5_, assetLoaderInfo.useCache);
			mHdAssetLoader = new SwfAssetLoader(mFacade, _loc3_, hdLoadedCallback, hdErrorCallback, true);
		} else {
			mOriginalLoadedCallback(assetLoaderInfo, asset);
		}
	}

	function hdLoadedCallback(hdAssetLoaderInfo:AssetLoaderInfo, hdAsset:Asset) {
		var _loc3_ = ASCompat.reinterpretAs(hdAsset, SwfAsset);
		mSwfAsset.setHdAsset(_loc3_.root, hdAssetLoaderInfo.getRawAssetPath());
		Logger.info("SwfAssetLoader: HD version loaded successfully: " + hdAssetLoaderInfo.getRawAssetPath());
		mHdAssetLoader = null;
		mOriginalLoadedCallback(mAssetLoaderInfo, mSwfAsset);
	}

	function hdErrorCallback(hdAssetLoaderInfo:AssetLoaderInfo) {
		Logger.info("SwfAssetLoader: HD version not found or failed to load: " + hdAssetLoaderInfo.getRawAssetPath());
		mHdAssetLoader = null;
		mOriginalLoadedCallback(mAssetLoaderInfo, mSwfAsset);
	}

	function hdFileExists(hdPath:String):Bool {
		var _loc8_:Bool;
		var _loc4_:String = null;
		var _loc3_:String = null;
		var _loc2_:File = null;
		try {
			_loc4_ = hdPath;
			if (_loc4_.indexOf("./") == 0) {
				_loc4_ = _loc4_.substring(2);
				_loc3_ = "app:/" + _loc4_;
				_loc2_ = new File(_loc3_);
				return _loc2_.exists;
			}
			Logger.info("SwfAssetLoader: Failed to strip prefix ./ when detecting HD asset: " + hdPath);
			return false;
		} catch (error:Dynamic) {
			Logger.info("SwfAssetLoader: Error checking HD file existence: " + hdPath + " - " + Std.string(error.message));
			_loc8_ = false;
		}
		return _loc8_;
	}

	function getHdPath(basePath:String):String {
		var _loc3_ = basePath.lastIndexOf(".");
		if (_loc3_ == -1) {
			return null;
		}
		var _loc2_ = basePath.substring(_loc3_);
		if (_loc2_.toLowerCase() != ".swf") {
			return null;
		}
		var _loc4_ = basePath.substring(0, _loc3_);
		return _loc4_ + ".HD.swf";
	}

	override public function destroy() {
		mSwfAsset = null;
		mOriginalLoadedCallback = null;
		mHdAssetLoader = null;
		super.destroy();
	}
}
