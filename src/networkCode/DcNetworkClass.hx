package networkCode;

class DcNetworkClass {
	static var CREATION_ORDER_SEED:UInt = (0 : UInt);

	var the_gamesocket:DcSocket;

	public var do_id:UInt = 0;

	var mCreationOrder:UInt = 0;

	public function new(trash:ASAny, gs:DcSocket, id:UInt) {
		do_id = id;
		the_gamesocket = gs;
		mCreationOrder = ++CREATION_ORDER_SEED;
	}

	@:isVar public var creationOrder(get, never):UInt;

	public function get_creationOrder():UInt {
		return mCreationOrder;
	}

	public function recvByIdLoop(packet:DcNetworkPacket) {
		var _loc4_ = 0;
		var _loc2_ = 0;
		var _loc3_ = ASCompat.reinterpretAs(this, DcNetworkInterface);
		if (!packet.eof()) {
			_loc4_ = (packet.readUnsignedShort() : Int);
			while (!packet.eof()) {
				_loc2_ = (packet.readUnsignedShort() : Int);
				_loc3_.recvById(packet, (_loc2_ : UInt));
			}
		}
	}

	public function Process_SetFieldValue(packet:DcNetworkPacket) {
		var _loc3_ = ASCompat.reinterpretAs(this, DcNetworkInterface);
		var _loc2_ = packet.readUnsignedShort();
		_loc3_.recvById(packet, _loc2_);
	}

	public function Send_packet(packet:DcNetworkPacket) {
		the_gamesocket.sendpacket(packet);
	}

	public function Prepare_FieldUpdate(packet:DcNetworkPacket, field_id:UInt) {
		packet.writeShort(124);
		packet.writeUnsignedInt(do_id);
		packet.writeShort((field_id : Int));
	}

	public function recvById(packet:DcNetworkPacket, fieldid:UInt) {}

	public function generate(packet:DcNetworkPacket) {}

	public function destroy() {}
}
