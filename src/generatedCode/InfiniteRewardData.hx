package generatedCode;

import networkCode.DcNetworkPacket;

class InfiniteRewardData {
	public var dooberId:UInt = 0;

	public var floorNumber:UInt = 0;

	public var status:Int = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):InfiniteRewardData {
		var _loc2_ = new InfiniteRewardData();
		_loc2_.dooberId = packet.readUnsignedInt();
		_loc2_.floorNumber = packet.readUnsignedShort();
		_loc2_.status = packet.readByte();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(dooberId);
		outpacket.writeShort((floorNumber : Int));
		outpacket.writeByte(status);
	}
}
