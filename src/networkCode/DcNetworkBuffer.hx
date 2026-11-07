package networkCode;

import flash.utils.ByteArray;

class DcNetworkBuffer extends ASByteArrayBase {
	static final sSlide:ByteArray = new ByteArray();

	public function new() {
		super();
		endian = "littleEndian";
	}

	public function do_slide() {
		if (position == length) {
			length = (0 : UInt);
			position = (0 : UInt);
			return;
		}
		var _loc1_ = sSlide;
		_loc1_.length = (0 : UInt);
		readBytes(_loc1_);
		length = (0 : UInt);
		position = (0 : UInt);
		writeBytes(_loc1_);
		position = (0 : UInt);
	}

	public function eof():Bool {
		return position == length;
	}
}
