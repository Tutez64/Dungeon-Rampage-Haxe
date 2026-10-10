package generatedCode;

import distributedObjects.DistributedDungeonSummary;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedDungeonSummaryNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedDungeonSummary;

	public static inline final FLID_map_node_id = (274 : UInt);

	public static inline final FLID_report = (275 : UInt);

	public static inline final FLID_dungeon_name = (276 : UInt);

	public static inline final FLID_dungeonSuccess = (277 : UInt);

	public static inline final FLID_dungeonMod1 = (278 : UInt);

	public static inline final FLID_dungeonMod2 = (279 : UInt);

	public static inline final FLID_dungeonMod3 = (280 : UInt);

	public static inline final FLID_dungeonMod4 = (281 : UInt);

	public static inline final FLID_OpenChest = (282 : UInt);

	public static inline final FLID_TakeChest = (283 : UInt);

	public static inline final FLID_DropChest = (284 : UInt);

	public static inline final FLID_TransactionResponse = (285 : UInt);

	public function new(Inst:DistributedDungeonSummary, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedDungeonSummaryNetworkComponent {
		var _loc5_ = new DistributedDungeonSummary(gs.facade, doid);
		var _loc4_ = new DistributedDungeonSummaryNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedDungeonSummary(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 274) {
			case 0:
				recv_map_node_id(packet);

			case 1:
				recv_report(packet);

			case 2:
				recv_dungeon_name(packet);

			case 3:
				recv_dungeonSuccess(packet);

			case 4:
				recv_dungeonMod1(packet);

			case 5:
				recv_dungeonMod2(packet);

			case 6:
				recv_dungeonMod3(packet);

			case 7:
				recv_dungeonMod4(packet);

			case 11:
				recv_TransactionResponse(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_map_node_id(packet);
		recv_report(packet);
		recv_dungeon_name(packet);
		recv_dungeonSuccess(packet);
		recv_dungeonMod1(packet);
		recv_dungeonMod2(packet);
		recv_dungeonMod3(packet);
		recv_dungeonMod4(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_map_node_id(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.map_node_id = _loc2_;
	}

	public function recv_report(packet:DcNetworkPacket) {
		var v_report = (function(param1:DcNetworkPacket):Vector<DungeonReport> {
			var _loc5_:DungeonReport = null;
			var _loc3_ = new Vector<DungeonReport>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = DungeonReport.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.report = v_report;
	}

	public function recv_dungeon_name(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.dungeon_name = _loc2_;
	}

	public function recv_dungeonSuccess(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.dungeonSuccess = _loc2_;
	}

	public function recv_dungeonMod1(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.dungeonMod1 = _loc2_;
	}

	public function recv_dungeonMod2(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.dungeonMod2 = _loc2_;
	}

	public function recv_dungeonMod3(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.dungeonMod3 = _loc2_;
	}

	public function recv_dungeonMod4(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.dungeonMod4 = _loc2_;
	}

	public function send_OpenChest(account_id:UInt, slot:UInt) {
		var _loc3_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc3_, (282 : UInt));
		_loc3_.writeUnsignedInt(account_id);
		_loc3_.writeUnsignedInt(slot);
		Send_packet(_loc3_);
	}

	public function send_TakeChest(account_id:UInt, slot:UInt) {
		var _loc3_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc3_, (283 : UInt));
		_loc3_.writeUnsignedInt(account_id);
		_loc3_.writeUnsignedInt(slot);
		Send_packet(_loc3_);
	}

	public function send_DropChest(account_id:UInt, slot:UInt) {
		var _loc3_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc3_, (284 : UInt));
		_loc3_.writeUnsignedInt(account_id);
		_loc3_.writeUnsignedInt(slot);
		Send_packet(_loc3_);
	}

	public function recv_TransactionResponse(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		var _loc4_ = packet.readUnsignedByte();
		var _loc3_ = packet.readUnsignedInt();
		var _loc5_ = packet.readUnsignedInt();
		the_instance.TransactionResponse(_loc2_, _loc4_, _loc3_, _loc5_);
	}
}
