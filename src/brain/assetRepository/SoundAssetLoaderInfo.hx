package brain.assetRepository;

class SoundAssetLoaderInfo extends AssetLoaderInfo {
	var mSoundName:String;

	public function new(path:String, soundName:String, useCache:Bool) {
		super(path, useCache);
		mSoundName = soundName;
	}

	override public function getKey():String {
		return getRawAssetPath() + "_" + mSoundName;
	}
}
