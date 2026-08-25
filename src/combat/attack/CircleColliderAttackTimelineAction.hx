package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.utils.MemoryTracker;
import combat.CombatGameObject;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import flash.geom.Vector3D;

class CircleColliderAttackTimelineAction extends ColliderTimelineAction {
	public static inline final TYPE = "circleCollider";

	var mRadius:Float = Math.NaN;

	public function new(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:ASFunction, radius:Float, headingOffset:Vector3D, globalOffset:Vector3D,
			lifeTime:UInt, hitDelayPerObject:UInt) {
		mRadius = radius;
		super(weapon, actorGameObject, actorView, dbFacade, distributedDungeonFloor, combatResultCallback, headingOffset, globalOffset, lifeTime,
			hitDelayPerObject);
	}

	public static function buildFromJson(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, actionObj:ASObject, combatResultCallback:ASFunction):CircleColliderAttackTimelineAction {
		var _loc14_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc10_:Vector3D = null;
		var _loc9_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc13_:Vector3D = null;
		var _loc15_ = 0;
		var _loc17_ = 0;
		if (actorGameObject.isOwner) {
			_loc14_ = weapon != null ? weapon.collisionScale() : 1;
			_loc16_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "radius") * _loc14_);
			_loc12_ = 0;
			if (actionObj.xOffset != null) {
				_loc12_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "xOffset") * _loc14_);
			}
			_loc11_ = 0;
			if (actionObj.yOffset != null) {
				_loc11_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "yOffset") * _loc14_);
			}
			_loc10_ = new Vector3D(_loc12_, _loc11_);
			_loc9_ = 0;
			if (actionObj.xGlobalOffset != null) {
				_loc9_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "xGlobalOffset") * _loc14_);
			}
			_loc8_ = 0;
			if (actionObj.yGlobalOffset != null) {
				_loc8_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "yGlobalOffset") * _loc14_);
			}
			_loc13_ = new Vector3D(_loc9_, _loc8_);
			_loc15_ = 1;
			if (actionObj.lifeTime != null) {
				_loc15_ = ASCompat.toInt(actionObj.lifeTime);
			}
			_loc17_ = 0;
			if (actionObj.hitDelayPerObject != null) {
				_loc17_ = ASCompat.toInt(actionObj.hitDelayPerObject);
			}
			return new CircleColliderAttackTimelineAction(weapon, actorGameObject, actorView, dbFacade, distributedDungeonFloor, combatResultCallback,
				_loc16_, _loc10_, _loc13_, (_loc15_ : UInt), (_loc17_ : UInt));
		}
		return null;
	}

	override function buildCombatGameObject(lifetime:UInt, hitDelayPerObj:UInt):CombatGameObject {
		var _loc3_ = new CircleCombatCollider(mDBFacade, mActorGameObject, mDistributedDungeonFloor.box2DWorld, mRadius);
		var _loc4_ = new CombatGameObject(mDBFacade, mActorGameObject, mAttackType, mWeapon, mDistributedDungeonFloor, _loc3_, lifetime, hitDelayPerObj,
			mCombatResultCallback);
		MemoryTracker.track(_loc4_, "CombatGameObject - created in CircleColliderAttackTimelineAction.buildCombatGameObject()");
		return _loc4_;
	}

	override public function destroy() {
		mWeapon = null;
		mDistributedDungeonFloor = null;
		mCombatGameObject.destroy();
		super.destroy();
	}
}
