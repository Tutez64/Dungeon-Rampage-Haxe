#if flash
class ASByteArrayBase extends flash.utils.ByteArray {
	public function new() {
		super();
	}
}
#else
class ASByteArrayBase extends openfl.utils.ByteArray.ByteArrayData {
	public function new() {
		super();
	}
}
#end

