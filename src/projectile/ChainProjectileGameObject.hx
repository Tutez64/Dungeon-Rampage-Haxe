package projectile;

import actor.ActorGameObject;
import box2D.collision.shapes.B2CircleShape;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import brain.utils.MemoryTracker;
import combat.CombatGameObject;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.NPCGameObject;
import dungeon.NavCollider;
import facade.DBFacade;
import flash.geom.Vector3D;
import org.as3commons.collections.Set;

class ChainProjectileGameObject extends ProjectileGameObject {
	static inline final DEFAULT_CHAIN_CHECK_DISTANCE:Float = 300;

	static inline final DEFAULT_NUM_BRANCHES = (1 : UInt);

	var mMaxBranches:UInt = (3 : UInt);

	var mNumBranches:UInt = (0 : UInt);

	var mMaxChain:UInt = (2 : UInt);

	var mNumChains:UInt = (0 : UInt);

	var mEnvironmentTargets:Vector<NPCGameObject>;

	var mEnemyTargets:Vector<NPCGameObject>;

	var mIgnoreList:Set;

	var mChainCheckDistance:Float = 0;

	var mActorJustHit:ActorGameObject;

	public function new(dbFacade:DBFacade, actorId:UInt, actorTeam:UInt, attackType:UInt, weapon:WeaponGameObject, distDungeonfloor:DistributedDungeonFloor,
			position:Vector3D, directionVector:Vector3D, visualOffset:Vector3D, range:Float = 0, currentChain:UInt = (0 : UInt), ignoreList:Set = null,
			effectObject:ASObject = null, combatResultCallback:ASFunction = null, autoAim:Bool = true, dontRotate:Bool = false) {
		super(dbFacade, actorId, actorTeam, attackType, weapon, distDungeonfloor, position, directionVector, visualOffset, range, effectObject,
			combatResultCallback, autoAim, dontRotate, currentChain);
		mNumChains = currentChain;
		if (ignoreList == null) {
			mIgnoreList = new Set();
		} else {
			mIgnoreList = ignoreList;
		}
		var _loc17_ = (Std.int(weapon != null ? (Std.int(weapon.chains()) : UInt) : (0 : UInt)) : UInt);
		mMaxChain = mGMProjectile.NumChains + _loc17_;
		mMaxBranches = (ASCompat.toInt(mGMProjectile.NumBranches > 0 ? mGMProjectile.NumBranches : (1 : UInt)) : UInt);
		mChainCheckDistance = mGMProjectile.ChainDist > 0 ? mGMProjectile.ChainDist : 300;
	}

	override function hitActor(actor:ActorGameObject):Bool {
		var _loc2_:B2Transform = null;
		mActorJustHit = actor;
		if (mIgnoreList.has(actor.id)) {
			return false;
		}
		if (super.hitActor(actor)) {
			if (mNumChains < mMaxChain) {
				mIgnoreList.add(actor.id);
				_loc2_ = new B2Transform();
				_loc2_.position = NavCollider.convertToB2Vec2(this.position);
				mEnvironmentTargets = new Vector<NPCGameObject>();
				mEnemyTargets = new Vector<NPCGameObject>();
				this.mDistributedDungeonFloor.box2DWorld.QueryShape(collisionCallback, new B2CircleShape(mChainCheckDistance / 50), _loc2_);
				processTargets();
			}
		}
		if (mCollisionComponent.markedForDeletion()) {
			this.destroy();
		}
		return true;
	}

	function collisionCallback(fixture:B2Fixture):Bool {
		var _loc3_ = mDistributedDungeonFloor.getActor(mParentActorId);
		if (_loc3_ == null) {
			return false;
		}
		var _loc2_ = ASCompat.asUint(fixture.GetBody().GetUserData());
		var _loc4_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(_loc2_), NPCGameObject);
		if (_loc4_ != null
			&& mActorJustHit.id != _loc4_.id
			&& _loc4_.isAttackable
			&& (!mIgnoreList.has(_loc4_.id) || mGMProjectile.CyclicChains)) {
			if (mFlightComponent.isTargetableTeam((_loc4_.team : UInt))) {
				if (!CombatGameObject.didAttackGoThroughWall(mDBFacade, mB2Body.GetPosition(), _loc4_, NavCollider.convertToB2Vec2(_loc4_.worldCenter),
					mDistributedDungeonFloor)) {
					if (_loc4_.team == 1) {
						mEnvironmentTargets.push(_loc4_);
					} else {
						mEnemyTargets.push(_loc4_);
					}
				}
			}
		}
		if (mNumBranches >= mMaxBranches) {
			return false;
		}
		return true;
	}

	function processTargets() {
		ASCompat.ASVector.sort(mEnemyTargets, sortByDistance);
		processNewChains(mEnemyTargets);
		ASCompat.ASVector.sort(mEnvironmentTargets, sortByDistance);
		processNewChains(mEnvironmentTargets);
	}

	function sortByDistance(targetA:NPCGameObject, targetB:NPCGameObject):Float {
		var _loc3_ = new B2Vec2();
		_loc3_.x = mActorJustHit.worldCenterAsb2Vec2.x;
		_loc3_.y = mActorJustHit.worldCenterAsb2Vec2.y;
		_loc3_.Subtract(targetA.worldCenterAsb2Vec2);
		var _loc4_ = new B2Vec2();
		_loc4_.x = mActorJustHit.worldCenterAsb2Vec2.x;
		_loc4_.y = mActorJustHit.worldCenterAsb2Vec2.y;
		_loc4_.Subtract(targetB.worldCenterAsb2Vec2);
		return _loc3_.LengthSquared() - _loc4_.LengthSquared();
	}

	function processNewChains(targets:Vector<NPCGameObject>) {
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ < targets.length) {
			if (mNumBranches >= mMaxBranches) {
				return;
			}
			shootNewChain(targets[_loc2_]);
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}

	function shootNewChain(targetActor:NPCGameObject) {
		mNumBranches = mNumBranches + 1;
		var _loc3_ = targetActor.view.position.subtract(this.position);
		_loc3_.normalize();
		var _loc2_ = new ChainProjectileGameObject(mDBFacade, mParentActorId, mParentActorTeam, mAttackType, mWeaponGameObject, this.mDistributedDungeonFloor,
			mActorJustHit.position, _loc3_, new Vector3D(0, 0), mRange, mNumChains + 1, mIgnoreList, mEffectObject, mCombatResultCallback, false);
		MemoryTracker.track(_loc2_, "ChainProjectileGameObject - created in ChainProjectileGameObject.shootNewChain()");
	}
}
