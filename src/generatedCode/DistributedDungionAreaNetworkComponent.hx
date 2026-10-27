package generatedCode;

import distributedObjects.DistributedDungionArea;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class DistributedDungionAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:DistributedDungionArea;

	public static inline final FLID_tileLibrary = (211 : UInt);

	public static inline final FLID_cacheNpc = (212 : UInt);

	public static inline final FLID_cacheSWC = (213 : UInt);

	public static inline final FLID_floorReward = (214 : UInt);

	public static inline final FLID_floorEnding = (215 : UInt);

	public static inline final FLID_dungeonEnding = (216 : UInt);

	public static inline final FLID_floorfailing = (217 : UInt);

	public static inline final FLID_tellClientInfiniteRewardData = (218 : UInt);

	public function new(Inst:DistributedDungionArea, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):DistributedDungionAreaNetworkComponent {
		var _loc5_ = new DistributedDungionArea(gs.facade, doid);
		var _loc4_ = new DistributedDungionAreaNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentDistributedDungionArea(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 211) {
			case 0:
				recv_tileLibrary(packet);

			case 1:
				recv_cacheNpc(packet);

			case 2:
				recv_cacheSWC(packet);

			case 3:
				recv_floorReward(packet);

			case 4:
				recv_floorEnding(packet);

			case 5:
				recv_dungeonEnding(packet);

			case 6:
				recv_floorfailing(packet);

			case 7:
				recv_tellClientInfiniteRewardData(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_tileLibrary(packet);
		recv_cacheNpc(packet);
		recv_cacheSWC(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_tileLibrary(packet:DcNetworkPacket) {
		var tileLibrary = (function(param1:DcNetworkPacket):Vector<Swrapper> {
			var _loc5_:Swrapper = null;
			var _loc3_ = new Vector<Swrapper>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = Swrapper.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.tileLibrary(tileLibrary);
	}

	public function recv_cacheNpc(packet:DcNetworkPacket) {
		var v_cacheNpc = (function(param1:DcNetworkPacket):Vector<UInt> {
			var _loc5_ = 0;
			var _loc3_ = new Vector<UInt>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = (param1.readUnsignedInt() : Int);
				_loc3_.push((_loc5_ : UInt));
			}
			return _loc3_;
		})(packet);
		the_instance.cacheNpc = v_cacheNpc;
	}

	public function recv_cacheSWC(packet:DcNetworkPacket) {
		var v_cacheSWC = (function(param1:DcNetworkPacket):Vector<Swrapper> {
			var _loc5_:Swrapper = null;
			var _loc3_ = new Vector<Swrapper>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = Swrapper.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.cacheSWC = v_cacheSWC;
	}

	public function recv_floorReward(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.floorReward(_loc2_);
	}

	public function recv_floorEnding(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		the_instance.floorEnding(_loc2_);
	}

	public function recv_dungeonEnding(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		var _loc3_ = packet.readUnsignedByte();
		the_instance.dungeonEnding(_loc2_, _loc3_);
	}

	public function recv_floorfailing(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedShort();
		the_instance.floorfailing(_loc2_);
	}

	public function recv_tellClientInfiniteRewardData(packet:DcNetworkPacket) {
		var avId = packet.readUnsignedInt();
		var avScore = packet.readUnsignedShort();
		var goldReward = packet.readUnsignedInt();
		var infiniteRewards = (function(param1:DcNetworkPacket):Vector<InfiniteRewardData> {
			var _loc5_:InfiniteRewardData = null;
			var _loc3_ = new Vector<InfiniteRewardData>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = InfiniteRewardData.readFromPacket(param1);
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		the_instance.tellClientInfiniteRewardData(avId, avScore, goldReward, infiniteRewards);
	}
}
