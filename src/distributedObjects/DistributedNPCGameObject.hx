package distributedObjects;

import brain.gameObject.GameObject;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import gameMasterDictionary.StatVector;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;
import generatedCode.DistributedNPCGameObjectNetworkComponent;
import generatedCode.IDistributedNPCGameObject;
import generatedCode.WeaponDetails;
import flash.geom.Vector3D;

class DistributedNPCGameObject extends GameObject implements IDistributedNPCGameObject {
	var mNPCGameObject:NPCGameObject;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(facade, (0 : UInt));
		mNPCGameObject = new NPCGameObject(facade, remoteId);
		MemoryTracker.track(mNPCGameObject, "NPCGameObject - created in DistributedNPCGameObject.constructor()");
	}

	override public function getTrueObject():GameObject {
		return mNPCGameObject;
	}

	public function setNetworkComponentDistributedNPCGameObject(iface:DistributedNPCGameObjectNetworkComponent) {
		if (mNPCGameObject != null) {
			mNPCGameObject.setNetworkComponentDistributedNPCGameObject(iface);
		}
	}

	@:isVar public var state(never, set):String;

	public function set_state(state:String):String {
		if (mNPCGameObject != null) {
			mNPCGameObject.state = state;
			if (state == "dead") {
				mNPCGameObject.hasOwnership = true;
				mNPCGameObject = null;
			}
		}
		return state;
	}

	public function postGenerate() {
		if (mNPCGameObject != null) {
			mNPCGameObject.postGenerate();
		}
	}

	@:isVar public var type(never, set):UInt;

	public function set_type(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.type = val;
		}
		return val;
	}

	@:isVar public var level(never, set):UInt;

	public function set_level(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.level = val;
		}
		return val;
	}

	@:isVar public var position(never, set):Vector3D;

	public function set_position(val:Vector3D):Vector3D {
		if (mNPCGameObject != null) {
			mNPCGameObject.position = val;
		}
		return val;
	}

	@:isVar public var heading(never, set):Float;

	public function set_heading(val:Float):Float {
		if (mNPCGameObject != null) {
			mNPCGameObject.heading = val;
		}
		return val;
	}

	@:isVar public var scale(never, set):Float;

	public function set_scale(val:Float):Float {
		if (mNPCGameObject != null) {
			mNPCGameObject.scale = val;
		}
		return val;
	}

	@:isVar public var flip(never, set):UInt;

	public function set_flip(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.flip = val;
		}
		return val;
	}

	@:isVar public var hitPoints(never, set):UInt;

	public function set_hitPoints(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.hitPoints = val;
		}
		return val;
	}

	@:isVar public var weaponDetails(never, set):Vector<WeaponDetails>;

	public function set_weaponDetails(val:Vector<WeaponDetails>):Vector<WeaponDetails> {
		if (mNPCGameObject != null) {
			mNPCGameObject.weaponDetails = val;
		}
		return val;
	}

	@:isVar public var stats(never, set):StatVector;

	public function set_stats(val:StatVector):StatVector {
		if (mNPCGameObject != null) {
			mNPCGameObject.stats = val;
		}
		return val;
	}

	@:isVar public var masterId(never, set):UInt;

	public function set_masterId(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.masterId = val;
		}
		return val;
	}

	public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) {
		if (mNPCGameObject != null) {
			mNPCGameObject.ReceiveAttackChoreography(attackChoreography);
		}
	}

	public function ReceiveTimelineAction(timelineAction:String) {
		if (mNPCGameObject != null) {
			mNPCGameObject.ReceiveTimelineAction(timelineAction);
		}
	}

	public function ReceiveCombatResult(combatResult:CombatResult) {
		if (mNPCGameObject != null) {
			mNPCGameObject.ReceiveCombatResult(combatResult);
		}
	}

	override public function destroy() {
		if (mNPCGameObject != null) {
			mNPCGameObject.destroy();
			mNPCGameObject = null;
		}
		super.destroy();
	}

	@:isVar public var layer(never, set):Int;

	public function set_layer(val:Int):Int {
		if (mNPCGameObject != null) {
			mNPCGameObject.layer = val;
		}
		return val;
	}

	@:isVar public var team(never, set):Int;

	public function set_team(val:Int):Int {
		if (mNPCGameObject != null) {
			mNPCGameObject.team = val;
		}
		return val;
	}

	@:isVar public var remoteTriggerState(never, set):UInt;

	public function set_remoteTriggerState(val:UInt):UInt {
		if (mNPCGameObject != null) {
			mNPCGameObject.remoteTriggerState = val;
		}
		return val;
	}
}
