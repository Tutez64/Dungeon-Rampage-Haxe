package generatedCode;

import distributedObjects.PresenceManager;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class PresenceManagerNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance:PresenceManager;

	public static inline final FLID_friendState = (188 : UInt);

	public static inline final FLID_addFriends = (189 : UInt);

	public function new(Inst:PresenceManager, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):PresenceManagerNetworkComponent {
		var _loc5_ = new PresenceManager(gs.facade, doid);
		var _loc4_ = new PresenceManagerNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentPresenceManager(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 188) {
			case 0:
				recv_friendState(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance.destroy();
	}

	public function recv_friendState(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		var _loc4_ = packet.readUnsignedInt();
		var _loc3_ = packet.readUnsignedInt();
		the_instance.friendState(_loc2_, _loc4_, _loc3_);
	}

	public function send_addFriends(who:Vector<UInt>) {
		var whofunc:ASFunction;
		var outpacket = new DcNetworkPacket();
		Prepare_FieldUpdate(outpacket, (189 : UInt));
		whofunc = function() {
			var _loc2_ = 0;
			var _loc3_ = (who.length : UInt);
			var _loc1_ = outpacket;
			outpacket = new DcNetworkPacket();
			_loc2_ = 0;
			while ((_loc2_ : UInt) < _loc3_) {
				outpacket.writeUnsignedInt(who[_loc2_]);
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
			_loc1_.writeShort((outpacket.length : Int));
			_loc1_.writeBytes(outpacket);
			outpacket = _loc1_;
		};
		whofunc();
		Send_packet(outpacket);
	}
}
