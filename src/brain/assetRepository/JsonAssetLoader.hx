package brain.assetRepository;

import brain.facade.Facade;

class JsonAssetLoader extends AssetLoader {
	public function new(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:ASFunction, errorCallback:ASFunction) {
		super(facade, assetLoaderInfo, loadedCallback, errorCallback);
	}

	override function buildAsset(loadedObject:ASObject):Asset {
		return new JsonAsset(loadedObject);
	}
}
