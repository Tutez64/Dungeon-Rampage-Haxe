package projectile;

import actor.ActorGameObject;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import combat.CombatGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import generatedCode.Attack;
import generatedCode.CombatResult;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class CollisionComponent {
	var mDBFacade:DBFacade;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mProjectile:ProjectileGameObject;

	var mParentActorId:UInt = 0;

	var mDungeonFloor:DistributedDungeonFloor;

	var mUpdatedVelocity:Bool = false;

	var mNumCollisions:UInt = 0;

	var mCombatResultCallback:ASFunction;

	var mWeaponType:UInt = 0;

	var mWeaponPower:UInt = 0;

	var mWeaponSlot:Int = 0;

	var mActorCollisions:Map;

	var mHitsPerActor:UInt = 0;

	var mHitRecurDelay:Float = Math.NaN;

	var mMaxCollisions:UInt = 0;

	var mRecurringHitDelayTasks:Map;

	var mGMAttack:GMAttack;

	var mGeneration:UInt = 0;

	var mDontTrackGenerations:Bool = false;

	var mIsPierceProjectile:Bool = false;

	var mMarkedForDeletion:Bool = false;

	public function new(dbFacade:DBFacade, projectile:ProjectileGameObject, parentActorId:UInt, dungeonFloor:DistributedDungeonFloor, weaponType:UInt,
			weaponPower:UInt, gmAttck:GMAttack, combatResultCallback:ASFunction, weaponSlot:Int, additiveHits:Float, isPierceProjectile:Bool,
			generation:UInt = (0 : UInt)) {
		mDBFacade = dbFacade;
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "CollisionComponent");
		mDungeonFloor = dungeonFloor;
		mNumCollisions = (0 : UInt);
		mDontTrackGenerations = projectile.gmProjectile.NoGenerations;
		mGeneration = (ASCompat.toInt(mDontTrackGenerations ? (0 : UInt) : generation) : UInt);
		mProjectile = projectile;
		mParentActorId = parentActorId;
		mCombatResultCallback = combatResultCallback;
		mUpdatedVelocity = false;
		mWeaponType = weaponType;
		mWeaponPower = weaponPower;
		mWeaponSlot = weaponSlot;
		mActorCollisions = new Map();
		mHitRecurDelay = mProjectile.gmProjectile.HitRecurDelay;
		mHitsPerActor = (Std.int(mProjectile.gmProjectile.HitsPerActor) : UInt);
		mMaxCollisions = (Std.int(mProjectile.gmProjectile.MaxCollisions + additiveHits) : UInt);
		mRecurringHitDelayTasks = new Map();
		mGMAttack = gmAttck;
		mIsPierceProjectile = isPierceProjectile;
	}

	@:isVar public var numCollisions(get, never):UInt;

	public function get_numCollisions():UInt {
		return mNumCollisions;
	}

	@:isVar public var updatedVelocity(get, never):Bool;

	public function get_updatedVelocity():Bool {
		return mUpdatedVelocity;
	}

	public function destroy() {
		var _loc3_:Task = null;
		var _loc2_ = 0;
		mDungeonFloor = null;
		mCombatResultCallback = null;
		var _loc1_ = ASCompat.reinterpretAs(mRecurringHitDelayTasks.iterator(), IMapIterator);
		while (ASCompat.toBool(_loc1_.next())) {
			_loc2_ = (ASCompat.asUint(_loc1_.key) : Int);
			_loc3_ = ASCompat.dynamicAs(mRecurringHitDelayTasks.itemFor(_loc2_), Task);
			if (_loc3_ != null) {
				_loc3_.destroy();
			}
		}
		mRecurringHitDelayTasks.clear();
		mRecurringHitDelayTasks = null;
		mActorCollisions.clear();
		mActorCollisions = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
	}

	public function hitWall() {
		mProjectile.onHitWall();
		mProjectile.destroy();
	}

	public function hitActor(actor:ActorGameObject):Bool {
		var _loc2_ = 0;
		var _loc6_ = Math.NaN;
		var _loc3_ = Math.NaN;
		mProjectile.onHitActor(actor);
		var _loc5_ = ASCompat.dynamicAs(mActorCollisions.itemFor(actor.id), CollisionHelper);
		if (_loc5_ != null) {
			_loc5_ = ASCompat.dynamicAs(mActorCollisions.itemFor(actor.id), CollisionHelper);
			_loc2_ = (_loc5_.hits : Int);
			if ((_loc2_ : UInt) >= mHitsPerActor) {
				return false;
			}
		}
		if (_loc5_ != null) {
			_loc6_ = _loc5_.lastHitTime + mHitRecurDelay * 1000;
			if (mDBFacade.gameClock.gameTime < _loc6_) {
				_loc3_ = _loc6_ - mDBFacade.gameClock.gameTime;
				addRecurringHitDelayTask(actor, _loc3_ / 1000);
				return false;
			}
		} else {
			_loc5_ = new CollisionHelper(actor.id);
		}
		if (!mActorCollisions.hasKey(actor.id)) {
			mActorCollisions.add(actor.id, _loc5_);
		}
		_loc5_.hits++;
		_loc5_.lastHitTime = mDBFacade.gameClock.gameTime;
		mNumCollisions = mNumCollisions + 1;
		var _loc7_ = new CombatResult();
		var _loc4_ = new Attack();
		_loc4_.attackType = mProjectile.gmAttack.Id;
		_loc4_.weaponSlot = this.mWeaponSlot;
		_loc7_.attacker = mParentActorId;
		_loc7_.attack = _loc4_;
		_loc7_.attackee = actor.id;
		_loc7_.damage = 0;
		_loc7_.generation = (ASCompat.toInt(mDontTrackGenerations ? (0 : UInt) : mNumCollisions + mGeneration - 1) : UInt);
		if (actor.isBlocking && !mGMAttack.Unblockable) {
			if (CombatGameObject.blockCheck(actor.getHeadingAsVector(), actor.maximumDotForBlocking, actor.worldCenter, mProjectile.worldCenter)) {
				_loc7_.blocked = (1 : UInt);
			} else {
				_loc7_.blocked = (0 : UInt);
			}
		}
		if (_loc7_.blocked == 1) {
			_loc7_.knockback = (0 : UInt);
			_loc7_.suffer = (0 : UInt);
		} else {
			_loc7_.knockback = (Std.int(mProjectile.gmAttack.Knockback) : UInt);
			if (_loc7_.knockback != 0) {
				_loc7_.suffer = (1 : UInt);
			} else {
				_loc7_.suffer = (Math.random() <= mProjectile.gmAttack.StunChance ? (1 : UInt) : (0 : UInt):UInt);
			}
		}
		if (mCombatResultCallback != null) {
			mCombatResultCallback(_loc7_);
		}
		if (mHitsPerActor > (_loc2_ : UInt) && mNumCollisions < mMaxCollisions) {
			addRecurringHitDelayTask(actor, mHitRecurDelay);
		}
		if (mNumCollisions >= mMaxCollisions || actor.hasAbility((16777216 : UInt)) && mIsPierceProjectile) {
			mMarkedForDeletion = true;
		}
		return true;
	}

	function handleRecurringHitDelay(actor:ActorGameObject, actorId:UInt) {
		if (mRecurringHitDelayTasks == null) {
			Logger.error("Error in handleRecurringHitDelay.  mRecurringHitDelayTasks is not being cleaned up correctly.");
			return;
		}
		mRecurringHitDelayTasks.removeKey(actorId);
		if (actor != null && !actor.isDestroyed) {
			hitActor(actor);
		}
	}

	public function exitContact(actorId:UInt) {
		var _loc2_ = ASCompat.dynamicAs(mRecurringHitDelayTasks.itemFor(actorId), brain.workLoop.Task);
		if (_loc2_ != null) {
			_loc2_.destroy();
			mRecurringHitDelayTasks.removeKey(actorId);
		}
	}

	function addRecurringHitDelayTask(actor:ActorGameObject, delayForNextHitInSeconds:Float) {
		var recurringHitTask = ASCompat.dynamicAs(mRecurringHitDelayTasks.removeKey(actor.id), brain.workLoop.Task);
		if (recurringHitTask != null) {
			recurringHitTask.destroy();
		}
		if (delayForNextHitInSeconds > 0) {
			recurringHitTask = mLogicalWorkComponent.doLater(delayForNextHitInSeconds, function(param1:brain.clock.GameClock) {
				if (actor != null && !actor.isDestroyed) {
					handleRecurringHitDelay(actor, actor.id);
				}
			});
			mRecurringHitDelayTasks.add(actor.id, recurringHitTask);
		} else {
			hitActor(actor);
		}
	}

	public function markedForDeletion():Bool {
		return mMarkedForDeletion;
	}
}

private class CollisionHelper {
	public var hits:UInt = 0;

	public var actorId:UInt = 0;

	public var lastHitTime:Int = 0;

	public function new(theActorId:UInt) {
		hits = (0 : UInt);
		lastHitTime = 0;
		actorId = theActorId;
	}
}
