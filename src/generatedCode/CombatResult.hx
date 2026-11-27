package generatedCode;

import networkCode.DcNetworkPacket;

class CombatResult {
	public var attacker:UInt = 0;

	public var attackee:UInt = 0;

	public var damage:Int = 0;

	public var attack:Attack;

	public var when:UInt = 0;

	public var suffer:UInt = 0;

	public var knockback:UInt = 0;

	public var blocked:UInt = 0;

	public var criticalHit:UInt = 0;

	public var effectiveness:Int = 0;

	public var selfDamage:Int = 0;

	public var scalingMaxPowerMultiplier:Float = Math.NaN;

	public var generation:UInt = 0;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):CombatResult {
		var _loc2_ = new CombatResult();
		_loc2_.attacker = packet.readUnsignedInt();
		_loc2_.attackee = packet.readUnsignedInt();
		_loc2_.damage = packet.readInt();
		_loc2_.attack = Attack.readFromPacket(packet);
		_loc2_.when = packet.readUnsignedByte();
		_loc2_.suffer = packet.readUnsignedByte();
		_loc2_.knockback = packet.readUnsignedByte();
		_loc2_.blocked = packet.readUnsignedByte();
		_loc2_.criticalHit = packet.readUnsignedByte();
		_loc2_.effectiveness = packet.readByte();
		_loc2_.selfDamage = packet.readInt();
		_loc2_.scalingMaxPowerMultiplier = packet.readFloat();
		_loc2_.generation = packet.readUnsignedByte();
		return _loc2_;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		outpacket.writeUnsignedInt(attacker);
		outpacket.writeUnsignedInt(attackee);
		outpacket.writeInt(damage);
		attack.writeToPacket(outpacket);
		outpacket.writeByte((when : Int));
		outpacket.writeByte((suffer : Int));
		outpacket.writeByte((knockback : Int));
		outpacket.writeByte((blocked : Int));
		outpacket.writeByte((criticalHit : Int));
		outpacket.writeByte(effectiveness);
		outpacket.writeInt(selfDamage);
		outpacket.writeFloat(scalingMaxPowerMultiplier);
		outpacket.writeByte((generation : Int));
	}
}
