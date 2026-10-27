package networkCode;

interface DcSocketGenerate {
	function ObjectFactoryOwner(classid:UInt, do_id:UInt, game_packet:DcNetworkPacket):Void;

	function ObjectFactoryVisible(classid:UInt, do_id:UInt, game_packet:DcNetworkPacket):Void;
}
