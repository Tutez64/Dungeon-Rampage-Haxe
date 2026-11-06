package generatedCode;

import networkCode.DcNetworkPacket;

class GameServerPartyMember {
	public var id:UInt = 0;

	public var status:Int = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):GameServerPartyMember {
		var _loc2_ = new GameServerPartyMember();
		_loc2_.id = packet.readUnsignedInt();
		_loc2_.status = packet.readByte();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(id);
		outpacket.writeByte(status);
	}
}
