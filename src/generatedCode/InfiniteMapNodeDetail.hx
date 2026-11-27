package generatedCode;

import networkCode.DcNetworkPacket;

class InfiniteMapNodeDetail {
	public var epoc:UInt = 0;

	public var nodeId:UInt = 0;

	public var modifiers:Vector<UInt>;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):InfiniteMapNodeDetail {
		var work = new InfiniteMapNodeDetail();
		work.epoc = packet.readUnsignedInt();
		work.nodeId = packet.readUnsignedInt();
		work.modifiers = (function(param1:DcNetworkPacket):Vector<UInt> {
			var _loc3_ = (0 : UInt);
			var _loc5_ = (0 : UInt);
			var _loc4_ = new Vector<UInt>();
			var _loc2_ = (4 : UInt);
			_loc3_ = (0 : UInt);
			while (_loc3_ < _loc2_) {
				_loc5_ = param1.readUnsignedInt();
				_loc4_.push(_loc5_);
				_loc3_++;
			}
			return _loc4_;
		})(packet);
		return work;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		var _loc3_ = (0 : UInt);
		outpacket.writeUnsignedInt(epoc);
		outpacket.writeUnsignedInt(nodeId);
		var _loc2_ = (4 : UInt);
		_loc3_ = (0 : UInt);
		while (_loc3_ < _loc2_) {
			outpacket.writeUnsignedInt(modifiers[(_loc3_ : Int)]);
			_loc3_++;
		}
	}
}
