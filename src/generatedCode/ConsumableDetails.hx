package generatedCode;

import networkCode.DcNetworkPacket;

class ConsumableDetails {
	public var type:UInt = 0;

	public var count:UInt = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):ConsumableDetails {
		var _loc2_ = new ConsumableDetails();
		_loc2_.type = packet.readUnsignedInt();
		_loc2_.count = packet.readUnsignedShort();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(type);
		outpacket.writeShort((count : Int));
	}
}
