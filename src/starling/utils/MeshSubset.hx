package starling.utils;

class MeshSubset {
	public var vertexID:Int = 0;

	public var numVertices:Int = 0;

	public var indexID:Int = 0;

	public var numIndices:Int = 0;

	public function new(vertexID:Int = 0, numVertices:Int = -1, indexID:Int = 0, numIndices:Int = -1) {
		setTo(vertexID, numVertices, indexID, numIndices);
	}

	public function setTo(vertexID:Int = 0, numVertices:Int = -1, indexID:Int = 0, numIndices:Int = -1) {
		this.vertexID = vertexID;
		this.numVertices = numVertices;
		this.indexID = indexID;
		this.numIndices = numIndices;
	}
}
