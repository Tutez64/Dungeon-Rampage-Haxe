package brain.assetRepository;

import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import org.as3commons.collections.Set;

class AssetLoader {
	static var mTrackedLoadsCallback:ASFunction = null;

	static var mCollectingTrackLoads:Bool = false;

	static var mBytesLoaded:UInt = (0 : UInt);

	static var mBytesTotal:UInt = (0 : UInt);

	static var mTrackedLoads:Set = new Set();

	static var mloadersets:Vector<Loader> = new Vector();

	var mAssetLoaderInfo:AssetLoaderInfo;

	var mAssetCreatedCallback:ASFunction;

	var mErrorCallback:ASFunction;

	var mEventForLoader:EventDispatcher;

	var mFacade:Facade;

	var mUseLoader:Bool = false;

	var mURLDataFormat:String;

	var mUrlLoader:URLLoader;

	var mLoader:Loader;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null, useLoader:Bool = false,
			urlDataFormat:String = "text") {
		mFacade = facade;
		mAssetLoaderInfo = assetLoaderInfo;
		mAssetCreatedCallback = loadedCallback;
		mErrorCallback = errorCallback;
		mUseLoader = useLoader;
		mURLDataFormat = urlDataFormat;
		loadAsset(facade, mAssetLoaderInfo.getRawAssetPath(), mAssetLoaderInfo.useCache);
	}

	public static function startTrackingLoads(trackedLoadsCallback:ASFunction) {
		if (mCollectingTrackLoads) {
			Logger.warn("startTrackingLoads  with \tmCollectingTrackLoads already Active ");
		}
		mCollectingTrackLoads = true;
		mBytesLoaded = (0 : UInt);
		mBytesTotal = (0 : UInt);
		if (mTrackedLoads.size != 0) {
			mTrackedLoads.clear();
			mloadersets.splice(0, (Std.int(4294967295) : UInt));
		}
		mTrackedLoadsCallback = trackedLoadsCallback;
	}

	public static function abortTrackingLoads() {
		mCollectingTrackLoads = false;
		mTrackedLoadsCallback = null;
		mTrackedLoads.clear();
		mloadersets.splice(0, (Std.int(4294967295) : UInt));
	}

	public static function stopTrackingLoads() {
		if (mCollectingTrackLoads) {
			mCollectingTrackLoads = false;
			if (mTrackedLoads.size == 0) {
				if (mTrackedLoadsCallback != null) {
					mTrackedLoadsCallback();
				}
			}
		}
	}

	@:isVar public static var pendingBytesLoaded(get, never):UInt;

	static public function get_pendingBytesLoaded():UInt {
		return mBytesLoaded;
	}

	@:isVar public static var pendingBytesTotal(get, never):UInt;

	static public function get_pendingBytesTotal():UInt {
		return mBytesTotal;
	}

	public static function updateTrackedLoads() {
		mBytesLoaded = (0 : UInt);
		mBytesTotal = (0 : UInt);
		var _loc1_:Loader;
		final __ax4_iter_66 = mloadersets;
		if (checkNullIteratee(__ax4_iter_66))
			for (_tmp_ in __ax4_iter_66) {
				_loc1_ = _tmp_;
				mBytesLoaded += _loc1_.contentLoaderInfo.bytesLoaded;
				mBytesTotal += _loc1_.contentLoaderInfo.bytesTotal;
			}
	}

	static function updateTrackingLoad(url:String) {
		var _loc2_:ASFunction = null;
		Logger.info("Loader.updateTrackingLoad: mPendingLoads:"
			+ Std.string(mTrackedLoads.size)
			+ " mTrackLoads: "
			+ Std.string(mCollectingTrackLoads));
		if (mTrackedLoads.size > 0) {
			mTrackedLoads.remove(url);
			if (mTrackedLoads.size == 0 && !mCollectingTrackLoads) {
				if (mTrackedLoadsCallback != null) {
					_loc2_ = mTrackedLoadsCallback;
					mTrackedLoadsCallback = null;
					_loc2_();
				}
			}
		}
	}

	function buildAsset(loadedObject:ASObject):Asset {
		Logger.error("Should be overriding buildAsset in the subclasses to build the Asset.");
		return null;
	}

	function loadAsset(facade:Facade, assetPath:String, useCache:Bool = true) {
		var _loc5_:LoaderContext = null;
		var _loc4_ = new URLRequest(assetPath);
		if (useCache) {
			if (assetPath.indexOf("?") > 0) {
				_loc4_.url += "&v=" + facade.fileVersion(assetPath);
			} else {
				_loc4_.url += "?v=" + facade.fileVersion(assetPath);
			}
		} else {
			_loc4_.url += "?t=" + Std.string(Date.now().getTime());
		}
		if (mUseLoader) {
			mLoader = new Loader();
			if (mCollectingTrackLoads) {
				mTrackedLoads.add(mAssetLoaderInfo.getRawAssetPath());
			}
			Logger.info("Loader.load: " + _loc4_.url + " useCache: " + Std.string(useCache));
			mEventForLoader = mLoader.contentLoaderInfo;
			mEventForLoader.addEventListener("complete", loadComplete);
			mEventForLoader.addEventListener("ioError", handleIOError);
			mEventForLoader.addEventListener("securityError", handleSecurityError);
			_loc5_ = new LoaderContext(true);
			_loc5_.checkPolicyFile = true;
			mLoader.load(_loc4_, _loc5_);
			if (mCollectingTrackLoads) {
				mloadersets.push(mLoader);
			}
		} else {
			mUrlLoader = new URLLoader();
			mEventForLoader = mUrlLoader;
			mEventForLoader.addEventListener("complete", urlLoadComplete);
			mEventForLoader.addEventListener("ioError", handleIOErrorUrl);
			mEventForLoader.addEventListener("securityError", handleSecurityError);
			mUrlLoader.dataFormat = mURLDataFormat;
			if (mCollectingTrackLoads) {
				mTrackedLoads.add(mAssetLoaderInfo.getRawAssetPath());
			}
			Logger.info("URLLoader.load: " + _loc4_.url + " useCache: " + Std.string(useCache));
			mUrlLoader.load(_loc4_);
		}
	}

	public function getExtension(path:String):String {
		return path.substring(path.lastIndexOf(".") + 1, path.length);
	}

	function loadComplete(event:Event) {
		var _loc2_:Asset = null;
		Logger.info("Loader.loadComplete: " + Std.string(event.target.url));
		var _loc3_ = cast(event.target, LoaderInfo).loader;
		_loc3_.contentLoaderInfo.removeEventListener("complete", loadComplete);
		_loc3_.contentLoaderInfo.removeEventListener("ioError", handleIOError);
		_loc3_.contentLoaderInfo.removeEventListener("securityError", handleSecurityError);
		mLoader = null;
		var _loc4_ = mAssetLoaderInfo;
		try {
			_loc2_ = buildAsset(_loc3_.content);
			mAssetCreatedCallback(mAssetLoaderInfo, _loc2_);
			updateTrackingLoad(_loc4_.getRawAssetPath());
		} catch (e:Dynamic) {
			Logger.error("Loader.loadComplete error processing: " + mAssetLoaderInfo.getRawAssetPath(), e);
			if (mErrorCallback != null) {
				mErrorCallback(mAssetLoaderInfo);
			}
			updateTrackingLoad(_loc4_.getRawAssetPath());
		}
	}

	function urlLoadComplete(event:Event) {
		var _loc2_:Asset = null;
		var _loc3_ = cast(event.target, URLLoader);
		Logger.info("Loader.urlLoadComplete: " + mAssetLoaderInfo.getRawAssetPath() + " dataFormat: " + _loc3_.dataFormat);
		_loc3_.removeEventListener("complete", urlLoadComplete);
		_loc3_.removeEventListener("ioError", handleIOError);
		_loc3_.removeEventListener("securityError", handleSecurityError);
		mUrlLoader = null;
		var _loc4_ = mAssetLoaderInfo;
		try {
			_loc2_ = buildAsset(_loc3_.data);
			mAssetCreatedCallback(mAssetLoaderInfo, _loc2_);
			updateTrackingLoad(_loc4_.getRawAssetPath());
		} catch (e:Dynamic) {
			Logger.error("Loader.urlLoadComplete error processing: " + mAssetLoaderInfo.getRawAssetPath(), e);
			updateTrackingLoad(_loc4_.getRawAssetPath());
			if (mErrorCallback != null) {
				mErrorCallback(mAssetLoaderInfo);
			}
		}
	}

	function handleIOError(event:Event) {
		var AssetString:String;
		var loader = cast(event.target, LoaderInfo).loader;
		loader.contentLoaderInfo.removeEventListener("complete", loadComplete);
		loader.contentLoaderInfo.removeEventListener("ioError", handleIOError);
		loader.contentLoaderInfo.removeEventListener("securityError", handleSecurityError);
		mLoader = null;
		updateTrackingLoad(mAssetLoaderInfo.getRawAssetPath());
		AssetString = mAssetLoaderInfo.getRawAssetPath();
		mFacade.logicalWorkManager.doLater(0.1, function(param1:brain.clock.GameClock) {
			if (mErrorCallback != null) {
				mErrorCallback(mAssetLoaderInfo);
			}
			Logger.error("Loader.handleIOError from path: " + AssetString);
		}, false, "AssetLoader.handleIOError");
	}

	function handleIOErrorUrl(event:Event) {
		var loader = cast(event.target, URLLoader);
		loader.removeEventListener("complete", loadComplete);
		loader.removeEventListener("ioError", handleIOErrorUrl);
		loader.removeEventListener("securityError", handleSecurityError);
		mUrlLoader = null;
		updateTrackingLoad(mAssetLoaderInfo.getRawAssetPath());
		if (mFacade.gameClock.frame > 1) {
			mFacade.logicalWorkManager.doLater(0.1, function(param1:brain.clock.GameClock) {
				if (mAssetLoaderInfo != null) {
					Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
					if (mErrorCallback != null) {
						mErrorCallback(mAssetLoaderInfo);
					}
				}
			}, false, "AssetLoader.handleIOErrorUrl");
		} else {
			Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
			if (mErrorCallback != null) {
				mErrorCallback(mAssetLoaderInfo);
			}
		}
	}

	function handleSecurityError(event:SecurityErrorEvent) {
		Logger.error("Loader.handleSecurityError from path: " + mAssetLoaderInfo.getRawAssetPath() + ".   " + event.text);
		var _loc2_ = mAssetLoaderInfo;
		mLoader = null;
		mUrlLoader = null;
		if (mErrorCallback != null) {
			mErrorCallback(mAssetLoaderInfo);
		}
		updateTrackingLoad(_loc2_.getRawAssetPath());
	}

	public function destroy() {
		if (mEventForLoader != null) {
			mEventForLoader.removeEventListener("complete", urlLoadComplete);
			mEventForLoader.removeEventListener("ioError", handleIOErrorUrl);
			mEventForLoader.removeEventListener("securityError", handleSecurityError);
			mEventForLoader.removeEventListener("complete", loadComplete);
		}
		if (mUrlLoader != null) {
			mUrlLoader.close();
			mUrlLoader = null;
		}
		if (mLoader != null) {
			mLoader.close();
			mLoader = null;
		}
		mAssetLoaderInfo = null;
		mFacade = null;
		mErrorCallback = null;
		mAssetCreatedCallback = null;
		mEventForLoader = null;
	}
}
