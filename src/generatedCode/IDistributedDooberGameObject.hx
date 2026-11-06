package generatedCode;

import brain.gameObject.GameObject;
import flash.geom.Vector3D;

interface IDistributedDooberGameObject {
	function setNetworkComponentDistributedDooberGameObject(iface:DistributedDooberGameObjectNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	@:isVar var type(never, set):UInt;

	@:isVar var position(never, set):Vector3D;

	@:isVar var layer(never, set):Int;

	function spawnFrom(loc:Vector3D):Void;

	function collectedBy(hero:UInt):Void;
}
