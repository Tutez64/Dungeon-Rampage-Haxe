package brain.assetRepository;

import brain.facade.Facade;
import brain.utils.MemoryTracker;
import flash.utils.ByteArray;

class ByteArrayAssetLoader extends AssetLoader {
	var mByteArrayAsset:ByteArrayAsset;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback, false, "binary");
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		mByteArrayAsset = new ByteArrayAsset((loadedObject : ByteArray));
		MemoryTracker.track(mByteArrayAsset, "ByteArrayAsset - created in ByteArrayAssetLoader.buildAsset()", "brain");
		return mByteArrayAsset;
	}
}
