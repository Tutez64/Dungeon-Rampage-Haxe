package generatedCode;

import distributedObjects.PlayerGameObject;
import networkCode.DcNetworkClass;
import networkCode.DcNetworkInterface;
import networkCode.DcNetworkPacket;

class PlayerGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface {
	var the_instance__GeneratedCode_PlayerGameObjectNetworkComponent /*redefined private*/:PlayerGameObject;

	public static inline final FLID_screenName = (187 : UInt);

	public static inline final FLID_heroPreloadLook = (188 : UInt);

	public static inline final FLID_basicCurrency = (189 : UInt);

	public static inline final FLID_Chat = (190 : UInt);

	public static inline final FLID_ShowPlayerIsTyping = (191 : UInt);

	public static inline final FLID_requesthero = (192 : UInt);

	public static inline final FLID_requestentry = (193 : UInt);

	public static inline final FLID_requestpartymemberinvite = (194 : UInt);

	public static inline final FLID_requestexit = (195 : UInt);

	public function new(Inst:PlayerGameObject, gs:GeneratedDcSocket, id:UInt) {
		super(Inst, gs, id);
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent = Inst;
	}

	public static function netFactory(packet:DcNetworkPacket, gs:GeneratedDcSocket, doid:UInt):PlayerGameObjectNetworkComponent {
		var _loc5_ = new PlayerGameObject(gs.facade, doid);
		var _loc4_ = new PlayerGameObjectNetworkComponent(_loc5_, gs, doid);
		_loc4_.generate(packet);
		_loc5_.setNetworkComponentPlayerGameObject(_loc4_);
		_loc5_.postGenerate();
		return _loc4_;
	}

	override public function recvById(packet:DcNetworkPacket, fieldid:UInt) {
		switch (fieldid - 187) {
			case 0:
				recv_screenName(packet);

			case 1:
				recv_heroPreloadLook(packet);

			case 3:
				recv_Chat(packet);

			case 4:
				recv_ShowPlayerIsTyping(packet);

			default:
				super.recvById(packet, fieldid);
		}
	}

	override public function generate(packet:DcNetworkPacket) {
		recv_screenName(packet);
		recv_heroPreloadLook(packet);
		recvByIdLoop(packet);
	}

	override public function destroy() {
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.destroy();
	}

	public function recv_screenName(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.screenName = _loc2_;
	}

	public function recv_heroPreloadLook(packet:DcNetworkPacket) {
		var _loc2_ = HeroPreloadLook.readFromPacket(packet);
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.heroPreloadLook = _loc2_;
	}

	public function recv_Chat(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUTF();
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.Chat(_loc2_);
	}

	public function recv_ShowPlayerIsTyping(packet:DcNetworkPacket) {
		var _loc2_ = packet.readUnsignedByte();
		the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.ShowPlayerIsTyping(_loc2_);
	}
}
