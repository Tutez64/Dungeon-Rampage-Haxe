package generatedCode;

import distributedObjects.DistributedTownFloor;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedTownFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedTownFloor;

	public static inline final FLID_tileLibrary = (205 : UInt);

	public static inline final FLID_tiles = (206 : UInt);

	public function new(Inst:DistributedTownFloor, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedTownFloorNetworkComponent {
		var _loc5_ = new DistributedTownFloor(gs.facade, doid);
		var _loc4_ = new DistributedTownFloorNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedTownFloor(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 205) {
			case 0:
				recv_tileLibrary(packet);

			case 1:
				recv_tiles(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_tileLibrary(packet);
		recv_tiles(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_tileLibrary(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.tileLibrary(_loc2_);
	}

	public function recv_tiles(packet:DcNetworkPacket) {
		var tiles = (function(param1:DcNetworkPacket):Vector<DungeonTileUsage> {
			var _loc5_:DungeonTileUsage = null;
			var _loc3_ = new Vector<DungeonTileUsage>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = DungeonTileUsage.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.tiles(tiles);
	}
}
