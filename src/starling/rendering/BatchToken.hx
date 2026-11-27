package starling.rendering;

import starling.utils.StringUtil;

class BatchToken {
	public var batchID:Int = 0;

	public var vertexID:Int = 0;

	public var indexID:Int = 0;

	public function new(batchID:Int = 0, vertexID:Int = 0, indexID:Int = 0) {
		setTo(batchID, vertexID, indexID);
	}

	public function copyFrom(token:BatchToken) {
		batchID = token.batchID;
		vertexID = token.vertexID;
		indexID = token.indexID;
	}

	public function setTo(batchID:Int = 0, vertexID:Int = 0, indexID:Int = 0) {
		this.batchID = batchID;
		this.vertexID = vertexID;
		this.indexID = indexID;
	}

	public function reset() {
		batchID = vertexID = indexID = 0;
	}

	public function equals(other:BatchToken):Bool {
		return batchID == other.batchID && vertexID == other.vertexID && indexID == other.indexID;
	}

	public function toString():String {
		return StringUtil.format("[BatchToken batchID={0} vertexID={1} indexID={2}]", batchID, vertexID, indexID);
	}
}
