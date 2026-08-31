package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.utils.MemoryTracker;
import combat.CombatGameObject;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import flash.geom.Vector3D;

class RectangleColliderTimelineAction extends ColliderTimelineAction {
	public static inline final TYPE = "rectangleCollider";

	var mHalfWidth:Float = Math.NaN;

	var mHalfHeight:Float = Math.NaN;

	var mRotation:Float = Math.NaN;

	public function new(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:ASFunction, headingOffset:Vector3D, globalOffset:Vector3D, halfWidth:Float,
			halfHeight:Float, rotation:Float, lifeTime:UInt, hitDelayPerObject:UInt) {
		mHalfWidth = halfWidth;
		mHalfHeight = halfHeight;
		mRotation = rotation;
		super(weapon, actorGameObject, actorView, dbFacade, distributedDungeonFloor, combatResultCallback, headingOffset, globalOffset, lifeTime,
			hitDelayPerObject);
	}

	public static function buildFromJson(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, actionObj:ASObject, combatResultCallback:ASFunction):RectangleColliderTimelineAction {
		var _loc17_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc14_:Vector3D = null;
		var _loc13_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc15_:Vector3D = null;
		var _loc18_ = 0;
		var _loc19_ = 0;
		if (actorGameObject.isOwner) {
			_loc17_ = weapon != null ? weapon.collisionScale() : 1;
			_loc10_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "halfHeight") * _loc17_);
			_loc16_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "halfWidth") * _loc17_);
			_loc11_ = ASCompat.toNumber(actionObj.rotation);
			_loc9_ = 0;
			if (actionObj.xOffset != null) {
				_loc9_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "xOffset") * _loc17_);
			}
			_loc8_ = 0;
			if (actionObj.yOffset != null) {
				_loc8_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "yOffset") * _loc17_);
			}
			_loc14_ = new Vector3D(_loc9_, _loc8_);
			_loc13_ = 0;
			if (actionObj.xGlobalOffset != null) {
				_loc13_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "xGlobalOffset") * _loc17_);
			}
			_loc12_ = 0;
			if (actionObj.yGlobalOffset != null) {
				_loc12_ = ASCompat.toNumber(ASCompat.toNumberField(actionObj, "yGlobalOffset") * _loc17_);
			}
			_loc15_ = new Vector3D(_loc13_, _loc12_);
			_loc18_ = 1;
			if (actionObj.lifeTime != null) {
				_loc18_ = ASCompat.toInt(actionObj.timeToLive);
			}
			_loc19_ = 0;
			if (actionObj.hitDelayPerObject != null) {
				_loc19_ = ASCompat.toInt(actionObj.hitDelayPerObject);
			}
			return new RectangleColliderTimelineAction(weapon, actorGameObject, actorView, dbFacade, distributedDungeonFloor, combatResultCallback, _loc14_,
				_loc15_, _loc16_, _loc10_, _loc11_, (_loc18_ : UInt), (_loc19_ : UInt));
		}
		return null;
	}

	override function buildCombatGameObject(lifetime:UInt, hitDelayPerObj:UInt):CombatGameObject {
		var _loc4_ = new RectangleCombatCollider(mDBFacade, mActorGameObject, mDistributedDungeonFloor.box2DWorld, mHalfWidth, mHalfHeight,
			mActorGameObject.heading, mRotation);
		var _loc3_ = new CombatGameObject(mDBFacade, mActorGameObject, mAttackType, mWeapon, mDistributedDungeonFloor, _loc4_, lifetime, hitDelayPerObj,
			mCombatResultCallback);
		MemoryTracker.track(_loc3_, "CombatGameObject - created in RectangleColliderTimelineAction.buildCombatGameObject()");
		return _loc3_;
	}

	override public function destroy() {
		mWeapon = null;
		mDistributedDungeonFloor = null;
		mCombatGameObject.destroy();
		super.destroy();
	}
}
