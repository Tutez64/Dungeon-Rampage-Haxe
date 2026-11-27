package starling.assets;

import flash.utils.ByteArray;
import starling.utils.ByteArrayUtil;

class JsonFactory extends AssetFactory {
	public function new() {
		super();
		addExtensions("json");
		addMimeTypes("application/json", "text/json");
	}

	override public function canHandle(reference:AssetReference):Bool {
		return super.canHandle(reference)
			|| ASCompat.isByteArray(reference.data)
			&& (ByteArrayUtil.startsWithString((reference.data : ByteArray), "{")
				|| ByteArrayUtil.startsWithString((reference.data : ByteArray), "["));
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var _loc5_:ByteArray = null;
		var _loc6_:ASObject = null;
		try {
			_loc5_ = (reference.data : ByteArray);
			_loc6_ = haxe.Json.parse(_loc5_.readUTFBytes(_loc5_.length));
			onComplete(reference.name, _loc6_);
		} catch (e:Dynamic) {
			onError("Could not parse JSON: " + ASCompat.asError(e).message);
		}
	}
}
