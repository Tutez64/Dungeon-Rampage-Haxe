package distributedObjects;

import brain.facade.Facade;
import brain.gameObject.GameObject;
import generatedCode.DistributedTownFloorNetworkComponent;
import generatedCode.DungeonTileUsage;
import generatedCode.IDistributedTownFloor;

class DistributedTownFloor extends GameObject implements IDistributedTownFloor {
	public function new(facade:Facade, remoteId:UInt = (0 : UInt)) {
		super(facade, remoteId);
	}

	public function setNetworkComponentDistributedTownFloor(iface:DistributedTownFloorNetworkComponent) {}

	public function postGenerate() {}

	public function tileLibrary(tileLibrary:String) {}

	public function tiles(tiles:Vector<DungeonTileUsage>) {}
}
