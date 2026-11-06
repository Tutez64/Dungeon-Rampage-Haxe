package brain.assetRepository;

import brain.facade.Facade;
import brain.utils.MemoryTracker;
import flash.display.Bitmap;

class ImageAssetLoader extends AssetLoader {
	var mImageAsset:ImageAsset;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback, true);
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		var _loc2_ = ASCompat.dynamicAs(loadedObject, Bitmap);
		mImageAsset = new ImageAsset(_loc2_);
		MemoryTracker.track(mImageAsset, "ImageAsset - created in ImageAssetLoader.buildAsset()", "brain");
		return mImageAsset;
	}
}
