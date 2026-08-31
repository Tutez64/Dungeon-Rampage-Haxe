package generatedCode;

import distributedObjects.DistributedTownArea;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedTownAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedTownArea;

	public static inline final FLID_tileLibrary = (286 : UInt);

	public function new(Inst:DistributedTownArea, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedTownAreaNetworkComponent {
		var _loc5_ = new DistributedTownArea(gs.facade, doid);
		var _loc4_ = new DistributedTownAreaNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedTownArea(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 286) {
			case 0:
				recv_tileLibrary(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_tileLibrary(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_tileLibrary(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.tileLibrary(_loc2_);
	}
}
