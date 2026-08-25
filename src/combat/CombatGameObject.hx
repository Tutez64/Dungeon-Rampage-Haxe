package combat;

import actor.ActorGameObject;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import brain.logger.Logger;
import combat.attack.CombatCollider;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObjectOwner;
import distributedObjects.NPCGameObject;
import dungeon.Prop;
import dungeon.Tile;
import facade.DBFacade;
import dr_floor.FloorObject;
import gameMasterDictionary.GMAttack;
import generatedCode.Attack;
import generatedCode.CombatResult;
import flash.geom.Vector3D;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.IMapIterator;

class CombatGameObject extends FloorObject {
	var mCombatCollider:CombatCollider;

	var mActorOwner:ActorGameObject;

	var mCombatResults:Vector<CombatResult>;

	var mAttackType:UInt = 0;

	var mWeapon:WeaponGameObject;

	var mTimelineFrame:UInt = 0;

	var mShowColliders:Bool = false;

	var mCombatResultCallback:ASFunction;

	public var mCurrentHitMap:Map;

	public var mLifeTime:UInt = 0;

	public var mHitDelayPerObject:UInt = 0;

	public function new(facade:DBFacade, actor:ActorGameObject, attackName:UInt, weapon:WeaponGameObject, distributedDungeonFloor:DistributedDungeonFloor,
			combatCollider:CombatCollider, lifetime:UInt = (1 : UInt), hitDelayPerObj:UInt = (0 : UInt), callBack:ASFunction = null,
			remoteId:UInt = (0 : UInt)) {
		super(facade, remoteId);
		mActorOwner = actor;
		mCombatResults = new Vector<CombatResult>();
		mDistributedDungeonFloor = distributedDungeonFloor;
		mAttackType = attackName;
		mWeapon = weapon;
		mCombatCollider = combatCollider;
		mShowColliders = mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_colliders", false);
		this.layer = 20;
		mCurrentHitMap = new Map();
		mLifeTime = lifetime;
		mHitDelayPerObject = hitDelayPerObj;
		mCombatResultCallback = callBack;
	}

	public static function blockCheck(blockHeading:Vector3D, maxBlockDotProduct:Float, blockingActorPosition:Vector3D, attackingActorPosition:Vector3D):Bool {
		return false;
	}

	public static function didAttackGoThroughWall(dbFacade:DBFacade, attackerPos:B2Vec2, targetActor:ActorGameObject, attackeePos:B2Vec2,
			dungeonFloor:DistributedDungeonFloor, showColliders:Bool = false):Bool {
		var attackThroughWall = false;
		var distanceOfRayIntersection:Float = 999;
		var wallCheck:ASFunction = function(param1:B2Fixture, param2:B2Vec2, param3:B2Vec2, param4:Float):Float {
			var _loc6_ = ASCompat.asUint(param1.GetBody().GetUserData());
			var _loc5_ = dbFacade.gameObjectManager.getReferenceFromId(_loc6_);
			if (_loc5_ == null || Std.isOfType(_loc5_, Prop)) {
				if (param4 < distanceOfRayIntersection) {
					attackThroughWall = true;
					distanceOfRayIntersection = param4;
				}
			} else if (_loc5_.id == targetActor.id) {
				if (param4 < distanceOfRayIntersection) {
					attackThroughWall = false;
					distanceOfRayIntersection = param4;
				}
			}
			return 1;
		};
		if (showColliders) {
			dungeonFloor.debugVisualizer.reportRayCast(attackerPos, attackeePos);
		}
		dungeonFloor.box2DWorld.RayCast(wallCheck, attackerPos, attackeePos);
		return attackThroughWall;
	}

	public static function determineIfHitBasedOnTeam(attackerTeam:UInt, hitActorTeam:UInt, attackTeamType:String):Bool {
		switch (attackTeamType) {
			case "FRIENDLY":
				return attackerTeam == hitActorTeam;
			case "HOSTILE":
				return attackerTeam != hitActorTeam;
			default:
				Logger.warn("No case for attackTeamType: " + attackTeamType);
				return false;
		}
		return false;
	}

	@:isVar public var combatResult(get, never):Vector<CombatResult>;

	public function get_combatResult():Vector<CombatResult> {
		return mCombatResults;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		mFloorView.position = pos;
		return mCombatCollider.position = pos;
	}

	public function doCollisions(timelineFrame:UInt = (0 : UInt)) {
		checkCollisions(collisionCallback, timelineFrame);
	}

	function checkCollisions(callbackForCollisions:ASFunction, timelineFrame:UInt = (0 : UInt)) {
		mTimelineFrame = timelineFrame;
		mDistributedDungeonFloor.box2DWorld.QueryShape(callbackForCollisions, mCombatCollider.shape, mCombatCollider.transform);
	}

	function collisionCallback(fixture:B2Fixture):Bool {
		var _loc5_:HeroGameObjectOwner = null;
		var _loc2_ = ASCompat.asUint(fixture.GetBody().GetUserData());
		var _loc3_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(_loc2_), ActorGameObject);
		if (_loc3_ == null) {
			return true;
		}
		if (!_loc3_.isAttackable) {
			return true;
		}
		var _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
		if (_loc4_ == null) {
			Logger.error("No GMAttack found for attack type: " + mAttackType);
			return true;
		}
		if (!determineIfHitBasedOnTeam((mActorOwner.team : UInt), (_loc3_.team : UInt), _loc4_.Team)) {
			return true;
		}
		if (ASCompat.floatAsBool(_loc4_.LineOfSightReq)
			&& didAttackGoThroughWall(mDBFacade, mActorOwner.worldCenterAsb2Vec2, _loc3_, fixture.GetBody().GetPosition(), mDistributedDungeonFloor,
				mShowColliders)) {
			return true;
		}
		if (_loc4_.AffectsOthers && mActorOwner.id != _loc3_.id || _loc4_.AffectsSelf && mActorOwner.id == _loc3_.id) {
			if (!_loc4_.AffectsProps && _loc3_.isProp) {
				return true;
			}
			if (passesRecurringHitCheck(_loc2_)) {
				hitActor(_loc3_);
				registerHitActor(_loc2_);
				if (_loc4_.AttackOnHit != null) {
					if (mActorOwner.isOwner) {
						_loc5_ = ASCompat.reinterpretAs(mActorOwner, HeroGameObjectOwner);
						_loc5_.doAttackOnHit(_loc4_.AttackOnHit, this.mWeapon);
					}
				}
			}
			return true;
		}
		return true;
	}

	function registerHitActor(actorId:UInt) {
		if (!mCurrentHitMap.hasKey(actorId)) {
			mCurrentHitMap.add(actorId, mHitDelayPerObject);
		} else {
			mCurrentHitMap.replaceFor(actorId, mHitDelayPerObject);
		}
	}

	function passesRecurringHitCheck(actorId:UInt):Bool {
		if (mCurrentHitMap.hasKey(actorId) && ASCompat.toNumber(mCurrentHitMap.itemFor(actorId)) > 0) {
			return false;
		}
		return true;
	}

	function hitActor(actorGameObject:ActorGameObject) {
		var _loc6_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
		if (_loc6_ == null) {
			Logger.error("No GMAttack found for attack type: " + mAttackType);
			return;
		}
		var _loc4_ = (0 : UInt);
		var _loc5_ = (0 : UInt);
		var _loc2_ = 0;
		if (mWeapon != null) {
			_loc4_ = mWeapon.power;
			_loc5_ = mWeapon.weaponType;
			_loc2_ = mWeapon.slot;
		}
		var _loc7_ = new CombatResult();
		_loc7_.attacker = mActorOwner.id;
		_loc7_.attackee = actorGameObject.id;
		_loc7_.when = mTimelineFrame;
		_loc7_.generation = (0 : UInt);
		var _loc3_ = new Attack();
		_loc3_.attackType = mAttackType;
		_loc3_.weaponSlot = _loc2_;
		_loc3_.isConsumableWeapon = (mWeapon != null && mWeapon.isConsumable() ? (1 : UInt) : (0 : UInt) : UInt);
		if (actorGameObject.isBlocking && !_loc6_.Unblockable) {
			if (blockCheck(actorGameObject.getHeadingAsVector(), actorGameObject.maximumDotForBlocking, actorGameObject.worldCenter, mActorOwner.worldCenter)) {
				_loc7_.blocked = (1 : UInt);
			}
		} else {
			_loc7_.blocked = (0 : UInt);
		}
		if (_loc7_.blocked == 0) {
			if (actorGameObject.hasAbility((1 : UInt))) {
				_loc7_.suffer = (0 : UInt);
			} else {
				_loc7_.suffer = (Math.random() <= _loc6_.StunChance ? (1 : UInt) : (0 : UInt):UInt);
			}
			if (_loc7_.suffer == 1) {
				if (_loc6_.Knockback != 0) {
					_loc7_.knockback = (1 : UInt);
				}
			}
		}
		_loc7_.attack = _loc3_;
		if (mCombatResultCallback != null) {
			mCombatResultCallback(_loc7_);
		}
	}

	function getNPCs():Vector<NPCGameObject> {
		var _loc4_:Tile = null;
		var _loc5_:IIterator = null;
		var _loc1_:NPCGameObject = null;
		var _loc3_ = new Vector<NPCGameObject>();
		var _loc2_ = mDistributedDungeonFloor.tileGrid.iterator(true);
		while (_loc2_.hasNext()) {
			_loc4_ = _loc2_.next();
			_loc5_ = _loc4_.NPCGameObjects.iterator();
			while (_loc5_.hasNext()) {
				_loc1_ = ASCompat.dynamicAs(_loc5_.next(), distributedObjects.NPCGameObject);
				_loc3_.push(_loc1_);
			}
		}
		return _loc3_;
	}

	override public function destroy() {
		mActorOwner = null;
		if (mCombatCollider != null) {
			mCombatCollider.destroy();
			mCombatCollider = null;
		}
		mCombatResults = null;
		super.destroy();
	}

	function updateRecurringHits() {
		var _loc1_ = ASCompat.reinterpretAs(mCurrentHitMap.iterator(), IMapIterator);
		while (ASCompat.toBool(_loc1_.next())) {
			mCurrentHitMap.replaceFor(_loc1_.key, ASCompat.toNumber(mCurrentHitMap.itemFor(_loc1_.key)) - 1);
		}
	}

	public function perFrameUpCall(timelineFrame:UInt) {
		updateRecurringHits();
		doCollisions(timelineFrame);
		mLifeTime = mLifeTime - 1;
	}

	public function isAlive():Bool {
		return mLifeTime > 0;
	}
}
