package brain.assetRepository;

import brain.facade.Facade;
import flash.display.MovieClip;
#if cpp
import brain.logger.Logger;
import haxe.Timer;
#end

class SwfAssetLoader extends AssetLoader {
	var mSwfAsset:SwfAsset;

	#if cpp
	var mPreprocessedTimer:Timer;
	#end

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback, true);
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		var _loc2_ = ASCompat.dynamicAs(loadedObject, MovieClip);
		mSwfAsset = new SwfAsset(_loc2_, mAssetLoaderInfo.getRawAssetPath());
		return mSwfAsset;
	}

	override public function destroy() {
		mSwfAsset = null;
		super.destroy();
	}

	#if cpp
	override function loadAsset(facade:Facade, assetPath:String, useCache:Bool = true) {
		if (isSwfPath(assetPath) && SwfAsset.hasPreprocessedBundleForPath(assetPath)) {
			var loaderInfo = mAssetLoaderInfo;
			var createdCallback = mAssetCreatedCallback;
			var errorCallback = mErrorCallback;
			Logger.info("SwfAssetLoader: using preprocessed library without raw SWF: " + assetPath);
			mSwfAsset = new SwfAsset(null, loaderInfo.getRawAssetPath());
			var swfAsset = mSwfAsset;
			mPreprocessedTimer = Timer.delay(function() {
				mPreprocessedTimer = null;
				try {
					swfAsset.preloadPreprocessedLibraries();
					if (createdCallback != null) {
						createdCallback(loaderInfo, swfAsset);
					}
				} catch (e:Dynamic) {
					Logger.error("SwfAssetLoader: failed to load preprocessed library: " + loaderInfo.getRawAssetPath(), e);
					if (errorCallback != null) {
						errorCallback(loaderInfo);
					}
				}
			}, 0);
			return;
		}
		super.loadAsset(facade, assetPath, useCache);
	}

	static function isSwfPath(assetPath:String):Bool {
		if (assetPath == null) {
			return false;
		}
		assetPath = assetPath.split("?")[0].toLowerCase();
		return StringTools.endsWith(assetPath, ".swf");
	}
	#end
}
