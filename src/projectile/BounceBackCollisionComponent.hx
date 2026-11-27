package projectile;

import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;

class BounceBackCollisionComponent extends CollisionComponent {
	static inline final DAMPING_FACTOR:Float = 0.5;

	public function new(dbFacade:DBFacade, projectile:ProjectileGameObject, parentActorId:UInt, dungeonFloor:DistributedDungeonFloor, weaponType:UInt,
			weaponPower:UInt, gmAttack:GMAttack, combatResultCallback:ASFunction, weaponSlot:Int, additiveHits:Float) {
		super(dbFacade, projectile, parentActorId, dungeonFloor, weaponType, weaponPower, gmAttack, combatResultCallback, weaponSlot, additiveHits, false);
	}

	override public function hitWall() {
		var _loc1_ = mDungeonFloor.getActor(mParentActorId);
		if (_loc1_ == null || _loc1_.isDestroyed) {
			mProjectile.destroy();
			return;
		}
		var _loc2_ = _loc1_.worldCenter.subtract(mProjectile.position);
		_loc2_.normalize();
		_loc2_.scaleBy(mProjectile.velocity.length * 0.5);
		mProjectile.velocity = _loc2_;
		mUpdatedVelocity = true;
	}
}
