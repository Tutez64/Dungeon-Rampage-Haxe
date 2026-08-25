package generatedCode;

import actor.buffs.DistributedBuffGameObject;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedBuffGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedBuffGameObject;

	public static inline final FLID_type = (292 : UInt);

	public static inline final FLID_effectedActor = (293 : UInt);

	public static inline final FLID_attackerActor = (294 : UInt);

	public function new(Inst:DistributedBuffGameObject, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedBuffGameObjectNetworkComponent {
		var _loc5_ = new DistributedBuffGameObject(gs.facade, doid);
		var _loc4_ = new DistributedBuffGameObjectNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedBuffGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 292) {
			case 0:
				recv_type(packet);

			case 1:
				recv_effectedActor(packet);

			case 2:
				recv_attackerActor(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_type(packet);
		recv_effectedActor(packet);
		recv_attackerActor(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_type(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.type = _loc2_;
	}

	public function recv_effectedActor(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.effectedActor = _loc2_;
	}

	public function recv_attackerActor(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.attackerActor = _loc2_;
	}
}
