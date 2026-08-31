package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.logger.Logger;
import combat.CombatGameObject;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import flash.geom.Vector3D;

class ColliderTimelineAction extends AttackTimelineAction {
	var mHeadingOffset:Vector3D;

	var mGlobalOffset:Vector3D;

	var mWeapon:WeaponGameObject;

	var mDistributedDungeonFloor:DistributedDungeonFloor;

	var mCombatGameObject:CombatGameObject;

	var mCombatResultCallback:ASFunction;

	var mLifeTime:UInt = 0;

	var mHitDelayPerObject:UInt = 0;

	public function new(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:ASFunction, headingOffset:Vector3D, globalOffset:Vector3D,
			lifeTime:UInt = (0 : UInt), hitDelayPerObject:UInt = (0 : UInt)) {
		mLifeTime = lifeTime;
		mWeapon = weapon;
		mCombatResultCallback = combatResultCallback;
		mHeadingOffset = headingOffset;
		mGlobalOffset = globalOffset;
		mDistributedDungeonFloor = distributedDungeonFloor;
		mHitDelayPerObject = hitDelayPerObject;
		super(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mCombatGameObject = buildCombatGameObject(mLifeTime, mHitDelayPerObject);
		perFrameUpCall(timeline);
		if (mLifeTime > 0) {
			timeline.addContinuousCollision(this);
		}
	}

	function buildCombatGameObject(lifetime:UInt, hitDelayPerObj:UInt):CombatGameObject {
		Logger.error("Build Combat Game Object should be overriden.  Implement it in the sub class.");
		return null;
	}

	function returnPositionForCollision():Vector3D {
		var _loc4_ = mActorGameObject.getHeadingAsVector();
		var _loc3_ = mActorGameObject.heading;
		var _loc1_ = new Vector3D(0, 0);
		_loc1_.x += mHeadingOffset.x * _loc4_.x * mActorGameObject.actorData.scale;
		_loc1_.y += mHeadingOffset.x * _loc4_.y * mActorGameObject.actorData.scale;
		var _loc2_ = mActorView.worldCenter.add(_loc1_);
		return _loc2_.add(mGlobalOffset);
	}

	public function perFrameUpCall(timeline:ScriptTimeline):Bool {
		if (mCombatGameObject != null) {
			mCombatGameObject.position = returnPositionForCollision();
			mCombatGameObject.perFrameUpCall(timeline.currentFrame);
			if (!mCombatGameObject.isAlive()) {
				mCombatGameObject.destroy();
				mCombatGameObject = null;
				return false;
			}
			return true;
		}
		return false;
	}
}
