package generatedCode;

import brain.gameObject.GameObject;

interface IDistributedTownArea {
	function setNetworkComponentDistributedTownArea(iface:DistributedTownAreaNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	function tileLibrary(tileLibrary:String):Void;
}
