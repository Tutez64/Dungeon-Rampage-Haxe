package actor.buffs;

import actor.ActorGameObject;
import brain.facade.Facade;
import brain.gameObject.GameObject;
import generatedCode.DistributedBuffGameObjectNetworkComponent;
import generatedCode.IDistributedBuffGameObject;

class DistributedBuffGameObject extends GameObject implements IDistributedBuffGameObject {
	var mType:UInt = 0;

	var mEffectedActor:UInt = 0;

	var mAttackerActor:UInt = 0;

	public var buffHandler:BuffHandler;

	public function new(facade:Facade, remoteId:UInt = (0 : UInt)) {
		super(facade, remoteId);
	}

	public function setNetworkComponentDistributedBuffGameObject(iface:DistributedBuffGameObjectNetworkComponent) {}

	public function postGenerate() {
		var _loc2_ = mFacade.gameObjectManager.getReferenceFromId(mEffectedActor);
		var _loc1_ = ASCompat.reinterpretAs(_loc2_, ActorGameObject);
		if (_loc1_ != null) {
			_loc1_.buffHandler.addBuff(this);
			_loc1_.ponderBuffChanges();
		}
	}

	override public function destroy() {
		if (buffHandler != null) {
			buffHandler.removeBuff(this);
			super.destroy();
		}
	}

	@:isVar public var type(get, set):UInt;

	public function get_type():UInt {
		return this.mType;
	}

	@:isVar public var effectedActor(never, set):UInt;

	public function set_effectedActor(val:UInt):UInt {
		return mEffectedActor = val;
	}

	@:isVar public var attackerActor(get, set):UInt;

	public function set_attackerActor(val:UInt):UInt {
		return mAttackerActor = val;
	}

	function get_attackerActor():UInt {
		return mAttackerActor;
	}

	function set_type(val:UInt):UInt {
		return mType = val;
	}
}
