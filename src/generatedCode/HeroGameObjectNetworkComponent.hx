package generatedCode;

import distributedObjects.HeroGameObject;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;
import flash.geom.Vector3D;

class HeroGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance__GeneratedCode_HeroGameObjectNetworkComponent /*redefined private*/:HeroGameObject;

	public static inline final FLID_type = (146 : UInt);

	public static inline final FLID_position = (147 : UInt);

	public static inline final FLID_heading = (148 : UInt);

	public static inline final FLID_scale = (149 : UInt);

	public static inline final FLID_flip = (150 : UInt);

	public static inline final FLID_hitPoints = (151 : UInt);

	public static inline final FLID_weaponDetails = (152 : UInt);

	public static inline final FLID_consumableDetails = (153 : UInt);

	public static inline final FLID_healthBombsUsed = (154 : UInt);

	public static inline final FLID_partyBombsUsed = (155 : UInt);

	public static inline final FLID_playerID = (156 : UInt);

	public static inline final FLID_state = (157 : UInt);

	public static inline final FLID_team = (158 : UInt);

	public static inline final FLID_ReceiveAttackChoreography = (159 : UInt);

	public static inline final FLID_ReceiveCombatResult = (160 : UInt);

	public static inline final FLID_skinType = (161 : UInt);

	public static inline final FLID_screenName = (162 : UInt);

	public static inline final FLID_manaPoints = (163 : UInt);

	public static inline final FLID_experiencePoints = (164 : UInt);

	public static inline final FLID_slotPoints = (165 : UInt);

	public static inline final FLID_dungeonBusterPoints = (166 : UInt);

	public static inline final FLID_setAFK = (167 : UInt);

	public static inline final FLID_ReportBuffEffect = (168 : UInt);

	public static inline final FLID_ReceivedBuffEffect = (169 : UInt);

	public static inline final FLID_TooFullForDoober = (170 : UInt);

	public static inline final FLID_ProposeCombatResults = (171 : UInt);

	public static inline final FLID_ProposeAttackChoreography = (172 : UInt);

	public static inline final FLID_ProposeRevive = (173 : UInt);

	public static inline final FLID_ProposeSelfRevive = (174 : UInt);

	public static inline final FLID_ProposeSelfRevive_Resp = (175 : UInt);

	public static inline final FLID_PartyBomb = (176 : UInt);

	public static inline final FLID_ProposeCreateNPC = (177 : UInt);

	public static inline final FLID_setStateAndAttackChoreography = (178 : UInt);

	public static inline final FLID_StopChoreography = (179 : UInt);

	public function new(Inst:HeroGameObject, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):HeroGameObjectNetworkComponent {
		var _loc5_ = new HeroGameObject(gs.facade, doid);
		var _loc4_ = new HeroGameObjectNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentHeroGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid) {
			case 146:
				recv_type(packet);

			case 147:
				recv_position(packet);

			case 148:
				recv_heading(packet);

			case 149:
				recv_scale(packet);

			case 150:
				recv_flip(packet);

			case 151:
				recv_hitPoints(packet);

			case 152:
				recv_weaponDetails(packet);

			case 153:
				recv_consumableDetails(packet);

			case 154:
				recv_healthBombsUsed(packet);

			case 155:
				recv_partyBombsUsed(packet);

			case 156:
				recv_playerID(packet);

			case 157:
				recv_state(packet);

			case 158:
				recv_team(packet);

			case 159:
				recv_ReceiveAttackChoreography(packet);

			case 160:
				recv_ReceiveCombatResult(packet);

			case 161:
				recv_skinType(packet);

			case 162:
				recv_screenName(packet);

			case 163:
				recv_manaPoints(packet);

			case 164:
				recv_experiencePoints(packet);

			case 165:
				recv_slotPoints(packet);

			case 166:
				recv_dungeonBusterPoints(packet);

			case 167:
				recv_setAFK(packet);

			case 176:
				recv_PartyBomb(packet);

			case 178:
				recv_setStateAndAttackChoreography(packet);

			case 179:
				recv_StopChoreography(packet);

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

	override public function destroy() {
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.destroy();
	}

	public function recv_type(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.type = _loc2_;
	}

	public function recv_position(packet:DcNetworkPacket) {
		var v_position = (function(param1:DcNetworkPacket):Vector3D {
			var _loc2_ = new Vector3D();
			_loc2_.x = param1.readFloat();
			_loc2_.y = param1.readFloat();
			return _loc2_;
		})(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.position = v_position;
	}

	public function recv_heading(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.heading = _loc2_;
	}

	public function recv_scale(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.scale = _loc2_;
	}

	public function recv_flip(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.flip = _loc2_;
	}

	public function recv_hitPoints(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.hitPoints = _loc2_;
	}

	public function recv_weaponDetails(packet:DcNetworkPacket) {
		var v_weaponDetails = (function(param1:DcNetworkPacket):Vector<WeaponDetails> {
			var _loc3_ = 0;
			var _loc5_:WeaponDetails = null;
			var _loc4_ = new Vector<WeaponDetails>();
			var _loc2_ = (4 : UInt);
			_loc3_ = 0;
			while ((_loc3_ : UInt) < _loc2_) {
				_loc5_ = WeaponDetails.readFromPacket(param1);
				_loc4_.push(_loc5_);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			return _loc4_;
		})(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.weaponDetails = v_weaponDetails;
	}

	public function recv_consumableDetails(packet:DcNetworkPacket) {
		var v_consumableDetails = (function(param1:DcNetworkPacket):Vector<ConsumableDetails> {
			var _loc3_ = 0;
			var _loc5_:ConsumableDetails = null;
			var _loc4_ = new Vector<ConsumableDetails>();
			var _loc2_ = (2 : UInt);
			_loc3_ = 0;
			while ((_loc3_ : UInt) < _loc2_) {
				_loc5_ = ConsumableDetails.readFromPacket(param1);
				_loc4_.push(_loc5_);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			return _loc4_;
		})(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.consumableDetails = v_consumableDetails;
	}

	public function recv_healthBombsUsed(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.healthBombsUsed = _loc2_;
	}

	public function recv_partyBombsUsed(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.partyBombsUsed = _loc2_;
	}

	public function recv_playerID(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.playerID = _loc2_;
	}

	public function recv_state(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.state = _loc2_;
	}

	public function recv_team(packet:DcNetworkPacket) {
		var _loc2_ = packet.readByte();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.team = _loc2_;
	}

	public function recv_ReceiveAttackChoreography(packet:DcNetworkPacket) {
		var _loc2_ = AttackChoreography.readFromPacket(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.ReceiveAttackChoreography(_loc2_);
	}

	public function recv_ReceiveCombatResult(packet:DcNetworkPacket) {
		var _loc2_ = CombatResult.readFromPacket(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.ReceiveCombatResult(_loc2_);
	}

	public function recv_skinType(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.skinType = _loc2_;
	}

	public function recv_screenName(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.screenName = _loc2_;
	}

	public function recv_manaPoints(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.manaPoints = _loc2_;
	}

	public function recv_experiencePoints(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.experiencePoints = _loc2_;
	}

	public function recv_slotPoints(packet:DcNetworkPacket) {
		var v_slotPoints = (function(param1:DcNetworkPacket):Vector<UInt> {
			var _loc3_ = 0;
			var _loc5_ = 0;
			var _loc4_ = new Vector<UInt>();
			var _loc2_ = (4 : UInt);
			_loc3_ = 0;
			while ((_loc3_ : UInt) < _loc2_) {
				_loc5_ = (param1.readUnsignedShort() : Int);
				_loc4_.push((_loc5_ : UInt));
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			return _loc4_;
		})(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.slotPoints = v_slotPoints;
	}

	public function recv_dungeonBusterPoints(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.dungeonBusterPoints = _loc2_;
	}

	public function recv_setAFK(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.setAFK = _loc2_;
	}

	public function recv_PartyBomb(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.PartyBomb(_loc2_);
	}

	public function recv_setStateAndAttackChoreography(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		var _loc3_ = AttackChoreography.readFromPacket(packet);
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.setStateAndAttackChoreography(_loc2_, _loc3_);
	}

	public function recv_StopChoreography(packet:DcNetworkPacket) {
		the_instance__GeneratedCode_HeroGameObjectNetworkComponent.StopChoreography();
	}
}
