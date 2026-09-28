package modding;

import distributedObjects.DistributedDungeonFloor;

/** The dungeon floor in progress. Not town. */
class ModFloor {
	public var id(default, null):UInt;

	/** 1-based index of the floor inside its dungeon. */
	public var number(get, never):Int;

	/** GameMaster map-node constant, empty when the floor is already gone. */
	public var map(get, never):String;

	var floor:DistributedDungeonFloor;

	@:allow(modding.Host)
	function new(floor:DistributedDungeonFloor) {
		this.floor = floor;
		id = floor.id;
	}

	function get_number():Int {
		if (floor == null || floor.isDestroyed)
			return 0;
		return (floor.getCurrentFloorNum() : Int);
	}

	function get_map():String {
		if (floor == null || floor.isDestroyed)
			return "";
		var node = floor.gmMapNode;
		if (node == null || node.Constant == null)
			return "";
		return node.Constant;
	}
}
