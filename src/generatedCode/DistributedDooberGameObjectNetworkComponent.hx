package generatedCode;

import doobers.DistributedDooberGameObject;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;
import flash.geom.Vector3D;

class DistributedDooberGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedDooberGameObject;

	public static inline final FLID_type = (287 : UInt);

	public static inline final FLID_position = (288 : UInt);

	public static inline final FLID_layer = (289 : UInt);

	public static inline final FLID_spawnFrom = (290 : UInt);

	public static inline final FLID_collectedBy = (291 : UInt);

	public function new(Inst:DistributedDooberGameObject, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedDooberGameObjectNetworkComponent {
		var _loc5_ = new DistributedDooberGameObject(gs.facade, doid);
		var _loc4_ = new DistributedDooberGameObjectNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedDooberGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 287) {
			case 0:
				recv_type(packet);

			case 1:
				recv_position(packet);

			case 2:
				recv_layer(packet);

			case 3:
				recv_spawnFrom(packet);

			case 4:
				recv_collectedBy(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_type(packet);
		recv_position(packet);
		recv_layer(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_type(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.type = _loc2_;
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

	public function recv_layer(packet:DcNetworkPacket) {
		var _loc2_ = packet.readByte();
		the_instance.layer = _loc2_;
	}

	public function recv_spawnFrom(packet:DcNetworkPacket) {
		var loc = (function(param1:DcNetworkPacket):Vector3D {
			var _loc2_ = new Vector3D();
			_loc2_.x = param1.readFloat();
			_loc2_.y = param1.readFloat();
			return _loc2_;
		})(packet);
		the_instance.spawnFrom(loc);
	}

	public function recv_collectedBy(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.collectedBy(_loc2_);
	}
}
