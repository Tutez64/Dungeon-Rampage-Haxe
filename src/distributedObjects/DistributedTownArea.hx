package distributedObjects;

import brain.facade.Facade;
import brain.gameObject.GameObject;
import generatedCode.DistributedTownAreaNetworkComponent;
import generatedCode.IDistributedTownArea;

class DistributedTownArea extends GameObject implements IDistributedTownArea {
	public function new(facade:Facade, remoteId:UInt = (0 : UInt)) {
		super(facade, remoteId);
	}

	public function setNetworkComponentDistributedTownArea(iface:DistributedTownAreaNetworkComponent) {}

	public function postGenerate() {}

	public function tileLibrary(tileLibrary:String) {}
}
