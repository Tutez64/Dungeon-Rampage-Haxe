package generatedCode;

import networkCode.DcNetworkPacket;

class Swrapper {
	public var fileName:String;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):Swrapper {
		var _loc2_ = new Swrapper();
		_loc2_.fileName = packet.readUTF();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUTF(fileName);
	}
}
