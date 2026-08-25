package generatedCode;

import networkCode.DcNetworkPacket;

class DungeonTileUsage {
	public var x:Int = 0;

	public var y:Int = 0;

	public var tileId:String;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):DungeonTileUsage {
		var _loc2_ = new DungeonTileUsage();
		_loc2_.x = packet.readInt();
		_loc2_.y = packet.readInt();
		_loc2_.tileId = packet.readUTF();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeInt(x);
		outpacket.writeInt(y);
		outpacket.writeUTF(tileId);
	}
}
