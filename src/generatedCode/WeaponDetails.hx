package generatedCode;

import networkCode.DcNetworkPacket;

class WeaponDetails {
	public var type:UInt = 0;

	public var power:UInt = 0;

	public var requiredlevel:UInt = 0;

	public var rarity:UInt = 0;

	public var modifier1:UInt = 0;

	public var modifier2:UInt = 0;

	public var legendarymodifier:UInt = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):WeaponDetails {
		var _loc2_ = new WeaponDetails();
		_loc2_.type = packet.readUnsignedInt();
		_loc2_.power = packet.readUnsignedShort();
		_loc2_.requiredlevel = packet.readUnsignedByte();
		_loc2_.rarity = packet.readUnsignedByte();
		_loc2_.modifier1 = packet.readUnsignedInt();
		_loc2_.modifier2 = packet.readUnsignedInt();
		_loc2_.legendarymodifier = packet.readUnsignedInt();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(type);
		outpacket.writeShort((power : Int));
		outpacket.writeByte((requiredlevel : Int));
		outpacket.writeByte((rarity : Int));
		outpacket.writeUnsignedInt(modifier1);
		outpacket.writeUnsignedInt(modifier2);
		outpacket.writeUnsignedInt(legendarymodifier);
	}
}
