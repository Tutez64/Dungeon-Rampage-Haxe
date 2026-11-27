package starling.assets;

import flash.utils.ByteArray;

class ByteArrayFactory extends AssetFactory {
	public function new() {
		super();
		addExtensions("bin");
		addMimeTypes("application/octet-stream");
	}

	override public function canHandle(reference:AssetReference):Bool {
		return ASCompat.isByteArray(reference.data);
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		onComplete(reference.name, (reference.data : ByteArray));
	}
}
