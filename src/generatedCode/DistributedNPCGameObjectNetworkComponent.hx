package generatedCode;

import distributedObjects.DistributedNPCGameObject;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;
import flash.geom.Vector3D;

class DistributedNPCGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedNPCGameObject;

	public static inline final FLID_type = (130 : UInt);

	public static inline final FLID_level = (131 : UInt);

	public static inline final FLID_position = (132 : UInt);

	public static inline final FLID_heading = (133 : UInt);

	public static inline final FLID_scale = (134 : UInt);

	public static inline final FLID_flip = (135 : UInt);

	public static inline final FLID_hitPoints = (136 : UInt);

	public static inline final FLID_weaponDetails = (137 : UInt);

	public static inline final FLID_state = (138 : UInt);

	public static inline final FLID_team = (139 : UInt);

	public static inline final FLID_layer = (140 : UInt);

	public static inline final FLID_remoteTriggerState = (141 : UInt);

	public static inline final FLID_masterId = (142 : UInt);

	public static inline final FLID_ReceiveAttackChoreography = (143 : UInt);

	public static inline final FLID_ReceiveCombatResult = (144 : UInt);

	public static inline final FLID_ReceiveTimelineAction = (145 : UInt);

	public function new(Inst:DistributedNPCGameObject, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedNPCGameObjectNetworkComponent {
		var _loc5_ = new DistributedNPCGameObject(gs.facade, doid);
		var _loc4_ = new DistributedNPCGameObjectNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedNPCGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 130) {
			case 0:
				recv_type(packet);

			case 1:
				recv_level(packet);

			case 2:
				recv_position(packet);

			case 3:
				recv_heading(packet);

			case 4:
				recv_scale(packet);

			case 5:
				recv_flip(packet);

			case 6:
				recv_hitPoints(packet);

			case 7:
				recv_weaponDetails(packet);

			case 8:
				recv_state(packet);

			case 9:
				recv_team(packet);

			case 10:
				recv_layer(packet);

			case 11:
				recv_remoteTriggerState(packet);

			case 12:
				recv_masterId(packet);

			case 13:
				recv_ReceiveAttackChoreography(packet);

			case 14:
				recv_ReceiveCombatResult(packet);

			case 15:
				recv_ReceiveTimelineAction(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_type(packet);
		recv_level(packet);
		recv_position(packet);
		recv_heading(packet);
		recv_scale(packet);
		recv_flip(packet);
		recv_hitPoints(packet);
		recv_weaponDetails(packet);
		recv_state(packet);
		recv_team(packet);
		recv_layer(packet);
		recv_remoteTriggerState(packet);
		recv_masterId(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_type(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.type = _loc2_;
	}

	public function recv_level(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.level = _loc2_;
	}

	public function recv_position(packet:DcNetworkPacket) {
		var v_position = (function(param1:DcNetworkPacket):Vector3D {
			var _loc2_ = new Vector3D();
			_loc2_.x = param1.readFloat();
			_loc2_.y = param1.readFloat();
			return _loc2_;
		})(packet);
		the_instance.position = v_position;
	}

	public function recv_heading(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		the_instance.heading = _loc2_;
	}

	public function recv_scale(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		the_instance.scale = _loc2_;
	}

	public function recv_flip(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.flip = _loc2_;
	}

	public function recv_hitPoints(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.hitPoints = _loc2_;
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
		the_instance.weaponDetails = v_weaponDetails;
	}

	public function recv_state(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.state = _loc2_;
	}

	public function recv_team(packet:DcNetworkPacket) {
		var _loc2_ = packet.readByte();
		the_instance.team = _loc2_;
	}

	public function recv_layer(packet:DcNetworkPacket) {
		var _loc2_ = packet.readByte();
		the_instance.layer = _loc2_;
	}

	public function recv_remoteTriggerState(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.remoteTriggerState = _loc2_;
	}

	public function recv_masterId(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.masterId = _loc2_;
	}

	public function recv_ReceiveAttackChoreography(packet:DcNetworkPacket) {
		var _loc2_ = AttackChoreography.readFromPacket(packet);
		the_instance.ReceiveAttackChoreography(_loc2_);
	}

	public function recv_ReceiveCombatResult(packet:DcNetworkPacket) {
		var _loc2_ = CombatResult.readFromPacket(packet);
		the_instance.ReceiveCombatResult(_loc2_);
	}

	public function recv_ReceiveTimelineAction(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.ReceiveTimelineAction(_loc2_);
	}
}
