package brain.assetRepository;

import org.as3commons.collections.Map;

class SpriteSheetAssetLoaderInfo extends AssetLoaderInfo {
	static var mLoadedJson:Map = new Map();

	public var bitmapDataName:String;

	public function new(swfPath:String, bitmapDataName:String, shClassName:String, useCache:Bool) {
		super(swfPath, useCache);
		this.bitmapDataName = bitmapDataName;
	}

	override public function getKey():String {
		return getRawAssetPath() + "_" + bitmapDataName;
	}
}
