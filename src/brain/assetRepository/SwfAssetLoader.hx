package brain.assetRepository;

import brain.facade.Facade;
import flash.display.MovieClip;

class SwfAssetLoader extends AssetLoader {
	var mSwfAsset:SwfAsset;

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
}
