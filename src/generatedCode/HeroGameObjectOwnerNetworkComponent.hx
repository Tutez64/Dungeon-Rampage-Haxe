package generatedCode;

import distributedObjects.HeroGameObjectOwner;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;
import flash.geom.Vector3D;

class HeroGameObjectOwnerNetworkComponent extends HeroGameObjectNetworkComponent implements DcNetworkInterface {
	var the_instance:IHeroGameObjectOwner;

	public function new(Inst:HeroGameObjectOwner, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function ownerFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):HeroGameObjectOwnerNetworkComponent {
		var _loc5_ = new HeroGameObjectOwner(gs.facade, doid);
		var _loc4_ = new HeroGameObjectOwnerNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentHeroGameObject(_loc4_);
		_loc5_.setOwnerNetworkComponentHeroGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 168) {
			case 0:
				recv_ReportBuffEffect(packet);

			case 1:
				recv_ReceivedBuffEffect(packet);

			case 2:
				recv_TooFullForDoober(packet);

			case 7:
				recv_ProposeSelfRevive_Resp(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_type(packet);
		recv_position(packet);
		recv_heading(packet);
		recv_scale(packet);
		recv_flip(packet);
		recv_hitPoints(packet);
		recv_weaponDetails(packet);
		recv_consumableDetails(packet);
		recv_healthBombsUsed(packet);
		recv_partyBombsUsed(packet);
		recv_playerID(packet);
		recv_state(packet);
		recv_team(packet);
		recv_skinType(packet);
		recv_screenName(packet);
		recv_manaPoints(packet);
		recv_experiencePoints(packet);
		recv_slotPoints(packet);
		recv_dungeonBusterPoints(packet);
		recv_setAFK(packet);
		recvByIdLoop(packet);
	}

	public function send_position(position:Vector3D) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (147 : UInt));
		_loc2_.writeFloat(position.x);
		_loc2_.writeFloat(position.y);
		Send_packet(_loc2_);
	}

	public function send_heading(heading:Float) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (148 : UInt));
		_loc2_.writeFloat(heading);
		Send_packet(_loc2_);
	}

	public function send_ReceiveAttackChoreography(attackChoreography:AttackChoreography) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (159 : UInt));
		attackChoreography.writeToPacket(_loc2_);
		Send_packet(_loc2_);
	}

	public function recv_ReportBuffEffect(packet:DcNetworkPacket) {
		var _loc5_ = packet.readUnsignedInt();
		var _loc3_ = packet.readInt();
		var _loc4_ = packet.readUnsignedInt();
		var _loc2_ = packet.readByte();
		the_instance.ReportBuffEffect(_loc5_, _loc3_, _loc4_, _loc2_);
	}

	public function recv_ReceivedBuffEffect(packet:DcNetworkPacket) {
		var _loc3_ = packet.readInt();
		var _loc4_ = packet.readUnsignedInt();
		var _loc2_ = packet.readByte();
		the_instance.ReceivedBuffEffect(_loc3_, _loc4_, _loc2_);
	}

	public function recv_TooFullForDoober(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.TooFullForDoober(_loc2_);
	}

	public function send_ProposeCombatResults(combatResults:Vector<CombatResult>) {
		var combatResultsfunc:ASFunction;
		var outpacket = new DcNetworkPacket();
		Prepare_FieldUpdate(outpacket, (171 : UInt));
		combatResultsfunc = function() {
			var _loc2_ = 0;
			var _loc1_ = (combatResults.length : UInt);
			var _loc3_ = outpacket;
			outpacket = new DcNetworkPacket();
			_loc2_ = 0;
			while ((_loc2_ : UInt) < _loc1_) {
				combatResults[_loc2_].writeToPacket(outpacket);
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
			_loc3_.writeShort((outpacket.length : Int));
			_loc3_.writeBytes(outpacket);
			outpacket = _loc3_;
		};
		combatResultsfunc();
		Send_packet(outpacket);
	}

	public function send_ProposeAttackChoreography(attackChoreography:AttackChoreography) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (172 : UInt));
		attackChoreography.writeToPacket(_loc2_);
		Send_packet(_loc2_);
	}

	public function send_ProposeRevive(revivee:UInt) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (173 : UInt));
		_loc2_.writeUnsignedInt(revivee);
		Send_packet(_loc2_);
	}

	public function send_ProposeSelfRevive(isParty:UInt) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (174 : UInt));
		_loc2_.writeByte((isParty : Int));
		Send_packet(_loc2_);
	}

	public function recv_ProposeSelfRevive_Resp(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		var _loc3_ = packet.readUnsignedByte();
		the_instance.ProposeSelfRevive_Resp(_loc2_, _loc3_);
	}

	public function send_ProposeCreateNPC(npcId:UInt, weaponSlot:UInt, x:Float, y:Float) {
		var _loc5_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc5_, (177 : UInt));
		_loc5_.writeUnsignedInt(npcId);
		_loc5_.writeUnsignedInt(weaponSlot);
		_loc5_.writeFloat(x);
		_loc5_.writeFloat(y);
		Send_packet(_loc5_);
	}

	public function send_StopChoreography() {
		var _loc1_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc1_, (179 : UInt));
		Send_packet(_loc1_);
	}
}
