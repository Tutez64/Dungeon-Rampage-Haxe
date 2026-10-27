package projectile;

import actor.ActorGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import flash.geom.Vector3D;

class FlightComponent {
	var mProjectile:ProjectileGameObject;

	var mParentActorId:UInt = 0;

	var mDBFacade:DBFacade;

	var mDungeonFloor:DistributedDungeonFloor;

	var mHeadingVector:Vector3D;

	var mSteeringUpdated:Bool = false;

	var mSteeringVector:Vector3D;

	var mFriendly:Bool = false;

	var mApplySteeringVector:ASFunction;

	var mStartTime:UInt = 0;

	public function new(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:UInt, dbFacade:DBFacade,
			dungeonFloor:DistributedDungeonFloor, friendly:Bool, applySteeringVector:ASFunction = null) {
		mProjectile = projectile;
		mHeadingVector = directionVector;
		mParentActorId = parentActorId;
		mDBFacade = dbFacade;
		mDungeonFloor = dungeonFloor;
		mApplySteeringVector = applySteeringVector;
		mFriendly = friendly;
		mSteeringUpdated = false;
		mStartTime = (mDBFacade.gameClock.gameTime : UInt);
	}

	public function update() {
		if (mProjectile.gmProjectile.Lifetime > 0 && mDBFacade.gameClock.gameTime - mStartTime > mProjectile.gmProjectile.Lifetime) {
			mProjectile.destroy();
			return;
		}
	}

	public function informOfHit(hitActor:ActorGameObject) {}

	@:isVar public var steeringVector(get, never):Vector3D;

	public function get_steeringVector():Vector3D {
		return mSteeringVector;
	}

	@:isVar public var steeringUpdated(get, never):Bool;

	public function get_steeringUpdated():Bool {
		return mSteeringUpdated;
	}

	public function destroy() {
		mProjectile = null;
		mDBFacade = null;
		mDungeonFloor = null;
		mApplySteeringVector = null;
	}

	function getSteeringVector(target_actor_position:Vector3D, steer_strength:Float):Vector3D {
		var _loc3_ = target_actor_position.subtract(mProjectile.position);
		var _loc5_ = _loc3_.normalize();
		_loc3_.scaleBy(mProjectile.gmProjectile.ProjSpeedF);
		var _loc4_ = _loc3_.subtract(mProjectile.velocity);
		_loc4_.scaleBy(steer_strength);
		return _loc4_;
	}

	public function isTargetableTeam(targetTeam:UInt):Bool {
		return mFriendly ? targetTeam == mProjectile.team : targetTeam != mProjectile.team;
	}
}
