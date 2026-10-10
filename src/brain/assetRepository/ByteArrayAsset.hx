package brain.assetRepository;

import flash.utils.ByteArray;

class ByteArrayAsset extends Asset {
	var mByteArray:ByteArray;

	public function new(byteArray:ByteArray) {
		super();
		mByteArray = byteArray;
	}

	@:isVar public var byteArray(get, never):ByteArray;

	public function get_byteArray():ByteArray {
		return mByteArray;
	}

	override public function destroy() {
		mByteArray = null;
		super.destroy();
	}
}
