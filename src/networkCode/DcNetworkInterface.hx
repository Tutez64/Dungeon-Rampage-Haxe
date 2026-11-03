package networkCode;

interface DcNetworkInterface {
	function recvById(packet:DcNetworkPacket, fieldid:UInt):Void;

	function generate(packet:DcNetworkPacket):Void;

	function destroy():Void;
}
