package generatedCode;

import distributedObjects.DistributedDungeonFloor;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedDungeonFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedDungeonFloor;

	public static inline final FLID_mapNodeId = (192 : UInt);

	public static inline final FLID_coliseumTierConstant = (193 : UInt);

	public static inline final FLID_tileLibrary = (194 : UInt);

	public static inline final FLID_tiles = (195 : UInt);

	public static inline final FLID_baseLining = (196 : UInt);

	public static inline final FLID_introMovieSwfFilePath = (197 : UInt);

	public static inline final FLID_introMovieAssetClassName = (198 : UInt);

	public static inline final FLID_currentFloorNum = (199 : UInt);

	public static inline final FLID_activeDungeonModifiers = (200 : UInt);

	public static inline final FLID_show_text = (201 : UInt);

	public static inline final FLID_play_sound = (202 : UInt);

	public static inline final FLID_trigger_camera_zoom = (203 : UInt);

	public static inline final FLID_trigger_camera_shake = (204 : UInt);

	public function new(Inst:DistributedDungeonFloor, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedDungeonFloorNetworkComponent {
		var _loc5_ = new DistributedDungeonFloor(gs.facade, doid);
		var _loc4_ = new DistributedDungeonFloorNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedDungeonFloor(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 192) {
			case 0:
				recv_mapNodeId(packet);

			case 1:
				recv_coliseumTierConstant(packet);

			case 2:
				recv_tileLibrary(packet);

			case 3:
				recv_tiles(packet);

			case 4:
				recv_baseLining(packet);

			case 5:
				recv_introMovieSwfFilePath(packet);

			case 6:
				recv_introMovieAssetClassName(packet);

			case 7:
				recv_currentFloorNum(packet);

			case 8:
				recv_activeDungeonModifiers(packet);

			case 9:
				recv_show_text(packet);

			case 10:
				recv_play_sound(packet);

			case 11:
				recv_trigger_camera_zoom(packet);

			case 12:
				recv_trigger_camera_shake(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_mapNodeId(packet);
		recv_coliseumTierConstant(packet);
		recv_tileLibrary(packet);
		recv_tiles(packet);
		recv_baseLining(packet);
		recv_introMovieSwfFilePath(packet);
		recv_introMovieAssetClassName(packet);
		recv_currentFloorNum(packet);
		recv_activeDungeonModifiers(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_mapNodeId(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.mapNodeId = _loc2_;
	}

	public function recv_coliseumTierConstant(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.coliseumTierConstant = _loc2_;
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

	public function recv_baseLining(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance.baseLining = _loc2_;
	}

	public function recv_introMovieSwfFilePath(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.introMovieSwfFilePath = _loc2_;
	}

	public function recv_introMovieAssetClassName(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.introMovieAssetClassName = _loc2_;
	}

	public function recv_currentFloorNum(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		the_instance.currentFloorNum = _loc2_;
	}

	public function recv_activeDungeonModifiers(packet:DcNetworkPacket) {
		var v_activeDungeonModifiers = (function(param1:DcNetworkPacket):Vector<DungeonModifier> {
			var _loc5_:DungeonModifier = null;
			var _loc3_ = new Vector<DungeonModifier>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = DungeonModifier.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.activeDungeonModifiers = v_activeDungeonModifiers;
	}

	public function recv_show_text(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.show_text(_loc2_);
	}

	public function recv_play_sound(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance.play_sound(_loc2_);
	}

	public function recv_trigger_camera_zoom(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		the_instance.trigger_camera_zoom(_loc2_);
	}

	public function recv_trigger_camera_shake(packet:DcNetworkPacket) {
		var _loc2_ = packet.readFloat();
		var _loc3_ = packet.readFloat();
		var _loc4_ = packet.readUnsignedByte();
		the_instance.trigger_camera_shake(_loc2_, _loc3_, _loc4_);
	}
}
