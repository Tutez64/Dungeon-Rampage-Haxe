package generatedCode;

import distributedObjects.PlayerGameObjectOwner;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class PlayerGameObjectOwnerNetworkComponent extends PlayerGameObjectNetworkComponent implements DcNetworkInterface {
	var the_instance:IPlayerGameObjectOwner;

	public function new(Inst:PlayerGameObjectOwner, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance = Inst;
	}

	public static function ownerFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):PlayerGameObjectOwnerNetworkComponent {
		var _loc5_ = new PlayerGameObjectOwner(gs.facade, doid);
		var _loc4_ = new PlayerGameObjectOwnerNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentPlayerGameObject(_loc4_);
		_loc5_.setOwnerNetworkComponentPlayerGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 181) {
			case 0:
				recv_basicCurrency(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_screenName(packet);
		recv_basicCurrency(packet);
		recvByIdLoop(packet);
	}

	public function recv_basicCurrency(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedInt();
		the_instance.basicCurrency = _loc2_;
	}

	public function send_Chat(text:String) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (182 : UInt));
		_loc2_.writeUTF(text);
		Send_packet(_loc2_);
	}

	public function send_ShowPlayerIsTyping(value:UInt) {
		var _loc2_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc2_, (183 : UInt));
		_loc2_.writeByte((value : Int));
		Send_packet(_loc2_);
	}

	public function send_requesthero() {
		var _loc1_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc1_, (184 : UInt));
		Send_packet(_loc1_);
	}

	public function send_requestentry() {
		var _loc1_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc1_, (185 : UInt));
		Send_packet(_loc1_);
	}

	public function send_requestpartymemberinvite() {
		var _loc1_ = new DcNetworkPacket();
		Prepare_FieldUpdate(_loc1_, (186 : UInt));
		Send_packet(_loc1_);
	}
}
