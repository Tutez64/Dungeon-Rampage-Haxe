package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.utils.MathUtil;
import brain.utils.MemoryTracker;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import projectile.ChainProjectileGameObject;
import projectile.ProjectileGameObject;
import flash.geom.Vector3D;

class ProjectileAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "projectile";

	var mDistributedDungeonFloor:DistributedDungeonFloor;

	var mEffectObject:ASObject;

	var mWeaponGameObject:WeaponGameObject;

	var mCombatResultCallback:ASFunction;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, weaponGameObject:WeaponGameObject, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, actionObj:ASObject, combatResultCallback:ASFunction = null) {
		super(actorGameObject, actorView, dbFacade);
		mDistributedDungeonFloor = distributedDungeonFloor;
		mEffectObject = actionObj;
		mWeaponGameObject = weaponGameObject;
		mCombatResultCallback = combatResultCallback;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, actionObj:ASObject, weapon:WeaponGameObject,
			combatResultCallback:ASFunction = null):ProjectileAttackTimelineAction {
		return new ProjectileAttackTimelineAction(actorGameObject, actorView, weapon, dbFacade, distributedDungeonFloor, actionObj, combatResultCallback);
	}

	override public function execute(timeline:ScriptTimeline) {
		var _loc18_:ProjectileGameObject = null;
		var _loc19_:AttackTimeline = null;
		var _loc7_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc8_ = 0;
		super.execute(timeline);
		var _loc17_ = ASCompat.toBool(mEffectObject.dontRotate != null ? mEffectObject.dontRotate : false);
		var _loc11_ = ASCompat.toNumber(mEffectObject.headingOffset != null ? mEffectObject.headingOffset : 0);
		var _loc12_ = ASCompat.toNumber(mEffectObject.headingOffsetAngle != null ? mEffectObject.headingOffsetAngle : 0);
		var _loc6_ = ASCompat.toNumber(mEffectObject.headingRandomnessAngle != null ? mEffectObject.headingRandomnessAngle : 0);
		_loc12_ += MathUtil.rand(-_loc6_, _loc6_);
		var _loc20_ = ASCompat.toNumber(mEffectObject.startingAngleOffset != null ? mEffectObject.startingAngleOffset : 0);
		var _loc15_ = mWeaponGameObject != null ? mWeaponGameObject.collisionScale() : 1;
		var _loc3_ = ASCompat.toNumber(mEffectObject.xOffset != null ? mEffectObject.xOffset : 0);
		_loc3_ *= _loc15_;
		var _loc2_ = ASCompat.toNumber(mEffectObject.yOffset != null ? mEffectObject.yOffset : 0);
		_loc2_ *= _loc15_;
		var _loc5_ = mActorGameObject.heading;
		var _loc9_ = mActorGameObject.getHeadingAsVector(_loc12_);
		var _loc14_ = mActorGameObject.worldCenter;
		var _loc10_ = mActorGameObject.projectileLaunchOffset;
		var _loc4_ = calculateHeadingOffset(_loc11_, _loc5_, _loc12_);
		_loc14_.x += _loc4_.x + _loc3_;
		_loc14_.y += _loc4_.y + _loc2_;
		_loc10_.x += _loc4_.x;
		_loc10_.y += _loc4_.y;
		var _loc13_ = timeline.autoAim;
		if (Std.isOfType(timeline, AttackTimeline)) {
			_loc19_ = ASCompat.reinterpretAs(timeline, AttackTimeline);
			_loc7_ = 1;
			_loc16_ = _loc12_;
			_loc8_ = 0;
			while ((_loc8_ : UInt) < _loc19_.projectileMultiplier) {
				_loc7_ = _loc8_ % 2 == 0 ? 1 : -1;
				_loc12_ = (_loc16_ + _loc19_.projectileScalingAngle * Std.int((_loc8_ + 1) / 2)) * _loc7_;
				_loc9_ = mActorGameObject.getHeadingAsVector(_loc12_);
				_loc18_ = new ChainProjectileGameObject(this.mDBFacade, mActorGameObject.id, (mActorGameObject.team : UInt), mAttackType, mWeaponGameObject,
					mDistributedDungeonFloor, _loc14_, _loc9_, _loc10_, _loc19_.distanceScalingProjectile, (0 : UInt), null, mEffectObject,
					mCombatResultCallback, _loc13_, _loc17_);
				MemoryTracker.track(_loc18_, "ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
				_loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
				_loc8_++;
			}
		} else {
			_loc18_ = new ChainProjectileGameObject(this.mDBFacade, mActorGameObject.id, (mActorGameObject.team : UInt), mAttackType, mWeaponGameObject,
				mDistributedDungeonFloor, _loc14_, _loc9_, _loc10_, 0, (0 : UInt), null, mEffectObject, mCombatResultCallback, _loc13_, _loc17_);
			MemoryTracker.track(_loc18_, "ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
			_loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
		}
	}

	public function calculateHeadingOffset(offset:Float, heading:Float, angleAddition:Float = 0):Vector3D {
		heading += angleAddition;
		if (heading < 0) {
			heading = 360 + heading;
		}
		heading = heading * 3.141592653589793 / 180;
		var _loc4_ = new Vector3D(0, 0, 0);
		_loc4_.x = offset * Math.cos(heading);
		_loc4_.y = offset * Math.sin(heading);
		return _loc4_;
	}

	override public function destroy() {
		mWeaponGameObject = null;
		mDistributedDungeonFloor = null;
		mEffectObject = null;
		super.destroy();
	}
}
