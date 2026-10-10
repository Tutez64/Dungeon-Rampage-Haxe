package generatedCode;

import brain.gameObject.GameObject;

interface IDistributedTownFloor {
	function setNetworkComponentDistributedTownFloor(iface:DistributedTownFloorNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	function tileLibrary(tileLibrary:String):Void;

	function tiles(tiles:Vector<DungeonTileUsage>):Void;
}
