package starling.assets;

import flash.media.Sound;
import flash.utils.ByteArray;
import starling.utils.ByteArrayUtil;

class SoundFactory extends AssetFactory {
	static var MAGIC_NUMBERS_A:Array<ASAny>;

	static var MAGIC_NUMBERS_B:Array<ASAny>;

	public function new() {
		super();
		addMimeTypes("audio/mp3", "audio/mpeg3", "audio/mpeg");
		addExtensions("mp3");
	}

	override public function canHandle(reference:AssetReference):Bool {
		var _loc2_:ByteArray = null;
		if (Std.isOfType(reference.data, Sound) || super.canHandle(reference)) {
			return true;
		}
		if (ASCompat.isByteArray(reference.data)) {
			_loc2_ = (reference.data : ByteArray);
			return ByteArrayUtil.startsWithBytes(_loc2_, MAGIC_NUMBERS_A) || ByteArrayUtil.startsWithBytes(_loc2_, MAGIC_NUMBERS_B);
		}
		return false;
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var _loc6_ = ASCompat.dynamicAs(reference.data, Sound);
		var _loc5_ = (reference.data : ByteArray);
		if (_loc5_ != null) {
			try {
				_loc6_ = new Sound();
				_loc6_.loadCompressedDataFromByteArray(_loc5_, _loc5_.length);
			} catch (e:Dynamic) {
				onError("Could not load sound data: " + Std.string(e.message));
				return;
			}
		}
		onComplete(reference.name, _loc6_);
	}

	static function __init__() {
		MAGIC_NUMBERS_A = [255, 251];
		MAGIC_NUMBERS_B = [73, 68, 51];
	}
}
