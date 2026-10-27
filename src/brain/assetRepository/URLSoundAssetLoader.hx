package brain.assetRepository;

import brain.facade.Facade;
import brain.logger.Logger;
import brain.sound.SoundAsset;
import brain.utils.MemoryTracker;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.net.URLRequest;

class URLSoundAssetLoader extends AssetLoader {
	var mSoundAsset:SoundAsset;

	var mSound:Sound;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback, false);
	}

	override function loadAsset(facade:Facade, assetPath:String, useCache:Bool = true) {
		var _loc4_ = new URLRequest(assetPath);
		if (useCache) {
			_loc4_.url += "?v=" + facade.fileVersion(assetPath);
		} else {
			_loc4_.url += "?t=" + Std.string(Date.now().getTime());
		}
		mSound = new Sound();
		mSound.load(_loc4_);
		mSound.addEventListener("complete", soundLoadComplete);
		mSound.addEventListener("ioError", soundLoadIOError);
		mSound.addEventListener("securityError", soundLoadSecurityError);
		if (AssetLoader.mCollectingTrackLoads) {
			AssetLoader.mTrackedLoads.add(mAssetLoaderInfo.getRawAssetPath());
		}
	}

	function soundLoadComplete(event:Event) {
		Logger.info("Loader.loadComplete: " + Std.string(event.target.url));
		mSoundAsset = new SoundAsset(mSound);
		MemoryTracker.track(mSoundAsset, "SoundAsset - URL: " + Std.string(event.target.url), "brain");
		var _loc2_:Asset = mSoundAsset;
		var _loc3_ = mAssetLoaderInfo;
		mAssetCreatedCallback(mAssetLoaderInfo, _loc2_);
		AssetLoader.updateTrackingLoad(_loc3_.getRawAssetPath());
	}

	function soundLoadIOError(evt:IOErrorEvent) {
		AssetLoader.updateTrackingLoad(mAssetLoaderInfo.getRawAssetPath());
		if (mFacade.gameClock.frame > 1) {
			mFacade.logicalWorkManager.doLater(0.1, function(param1:brain.clock.GameClock) {
				if (mAssetLoaderInfo != null) {
					Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
					if (mErrorCallback != null) {
						mErrorCallback(mAssetLoaderInfo);
					}
				}
			}, false, "URLSoundAssetLoader.handleIOError");
		} else {
			Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
			if (mErrorCallback != null) {
				mErrorCallback(mAssetLoaderInfo);
			}
		}
	}

	function soundLoadSecurityError(evt:SecurityErrorEvent) {
		Logger.error("Loader.handleSecurityError from path: " + mAssetLoaderInfo.getRawAssetPath() + ".   " + evt.text);
		var _loc2_ = mAssetLoaderInfo;
		if (mErrorCallback != null) {
			mErrorCallback(mAssetLoaderInfo);
		}
		AssetLoader.updateTrackingLoad(_loc2_.getRawAssetPath());
	}
}
