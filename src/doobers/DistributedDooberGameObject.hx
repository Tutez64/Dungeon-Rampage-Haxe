package doobers;

import brain.gameObject.GameObject;
import brain.utils.MemoryTracker;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import generatedCode.DistributedDooberGameObjectNetworkComponent;
import generatedCode.IDistributedDooberGameObject;
import flash.geom.Vector3D;

class DistributedDooberGameObject extends GameObject implements IDistributedDooberGameObject {
	var mDooberGameObject:DooberGameObject;

	var localFacade:DBFacade;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		localFacade = facade;
		super(facade, (0 : UInt));
		mDooberGameObject = new DooberGameObject(facade, remoteId);
		MemoryTracker.track(mDooberGameObject, "DooberGameObject - created in DistributedDooberGameObject.constructor()");
	}

	override public function getTrueObject():GameObject {
		return mDooberGameObject;
	}

	public function setNetworkComponentDistributedDooberGameObject(iface:DistributedDooberGameObjectNetworkComponent) {
		mDooberGameObject.setNetworkComponentDistributedDooberGameObject(iface);
	}

	public function postGenerate() {
		if (mDooberGameObject != null) {
			mDooberGameObject.postGenerate();
		}
	}

	@:isVar public var type(never, set):UInt;

	public function set_type(val:UInt):UInt {
		if (mDooberGameObject != null) {
			mDooberGameObject.type = val;
		}
		return val;
	}

	@:isVar public var position(never, set):Vector3D;

	public function set_position(val:Vector3D):Vector3D {
		if (mDooberGameObject != null) {
			mDooberGameObject.position = val;
		}
		return val;
	}

	public function collectedBy(heroId:UInt) {
		if (mDooberGameObject != null) {
			mDooberGameObject.takeOwnership(heroId == HeroGameObjectOwner.currentHeroOwnerId, heroId);
			mDooberGameObject = null;
		}
	}

	public function spawnFrom(loc:Vector3D) {
		if (mDooberGameObject != null) {
			mDooberGameObject.spawnFrom(loc);
		}
	}

	@:isVar public var layer(never, set):Int;

	public function set_layer(val:Int):Int {
		if (mDooberGameObject != null) {
			mDooberGameObject.layer = val;
		}
		return val;
	}

	override public function destroy() {
		if (mDooberGameObject != null) {
			mDooberGameObject.destroy();
			mDooberGameObject = null;
		}
		super.destroy();
	}
}
