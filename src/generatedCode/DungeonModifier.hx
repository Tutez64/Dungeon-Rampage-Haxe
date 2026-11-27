package generatedCode;

import networkCode.DcNetworkPacket;

class DungeonModifier {
	public var id:UInt = 0;

	public var new_this_floor:UInt = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):DungeonModifier {
		var _loc2_ = new DungeonModifier();
		_loc2_.id = packet.readUnsignedInt();
		_loc2_.new_this_floor = packet.readUnsignedByte();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(id);
		outpacket.writeByte((new_this_floor : Int));
	}
}
