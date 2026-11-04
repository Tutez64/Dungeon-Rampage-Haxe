package networkCode;

interface DcSocketGenerate {
	function ObjectFactoryOwner(classId:UInt, do_id:UInt, game_packet:DcNetworkPacket):Void;

	function ObjectFactoryVisible(classId:UInt, do_id:UInt, game_packet:DcNetworkPacket):Void;
}
