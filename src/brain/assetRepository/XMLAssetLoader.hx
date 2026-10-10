package brain.assetRepository;

import brain.facade.Facade;
import brain.utils.MemoryTracker;

class XMLAssetLoader extends AssetLoader {
	var mXMLAsset:XMLAsset;

	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction = null) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback);
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		mXMLAsset = new XMLAsset(new compat.XML(loadedObject));
		MemoryTracker.track(mXMLAsset, "XMLAsset - created in XMLAssetLoader.buildAsset()", "brain");
		return mXMLAsset;
	}
}
