package generatedCode;

import networkCode.DcNetworkPacket;

class Attack {
	public var weaponSlot:Int = 0;

	public var isConsumableWeapon:UInt = 0;

	public var attackType:UInt = 0;

	public var targetActorDoid:UInt = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):Attack {
		var _loc2_ = new Attack();
		_loc2_.weaponSlot = packet.readByte();
		_loc2_.isConsumableWeapon = packet.readUnsignedByte();
		_loc2_.attackType = packet.readUnsignedInt();
		_loc2_.targetActorDoid = packet.readUnsignedInt();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeByte(weaponSlot);
		outpacket.writeByte((isConsumableWeapon : Int));
		outpacket.writeUnsignedInt(attackType);
		outpacket.writeUnsignedInt(targetActorDoid);
	}
}
