package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import combat.weapon.WeaponController;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import generatedCode.Attack;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;

class OwnerAttackTimeline extends AttackTimeline {
	var mHeroGameObjectOwner:HeroGameObjectOwner;

	var mCombatResults:Vector<CombatResult>;

	var mWeaponController:WeaponController;

	var mChoreographySent:Bool = false;

	public function new(weapon:WeaponGameObject, heroGameObjectOwner:HeroGameObjectOwner, actorView:ActorView, attackJson:ASObject, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor) {
		mHeroGameObjectOwner = heroGameObjectOwner;
		super(weapon, heroGameObjectOwner, actorView, attackJson, dbFacade, distributedDungeonFloor);
	}

	override function parseAction(actionObj:ASObject):AttackTimelineAction {
		var __ax4_iter_39:Vector<WeaponController> = null;
		var __ax4_iter_40:Vector<WeaponController>;
		var _loc3_:WeaponController = null;
		var _loc4_ = ASCompat.asString(actionObj.type);
		var _loc2_:AttackTimelineAction = null;
		switch (_loc4_) {
			case "attemptRevive":
				_loc2_ = AttemptReviveTimeLineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, actionObj);

			case "proposeRevive":
				_loc2_ = ProposeReviveTimeLineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, actionObj);

			case "lockAttack":
				_loc2_ = LockAttackTimeLineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade);

			case "circleCollider":
				_loc2_ = CircleColliderAttackTimelineAction.buildFromJson(mWeapon, mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor,
					actionObj, combatResultCallback);

			case "rectangleCollider":
				_loc2_ = RectangleColliderTimelineAction.buildFromJson(mWeapon, mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj,
					combatResultCallback);

			case "zoom":
				_loc2_ = CameraZoomTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, actionObj);

			case "timeScale":

			case "projectile":
				_loc2_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj, mWeapon,
					combatResultCallback);

			case "inputType":
				_loc2_ = InputTypeTimelineAction.buildFromJson(mHeroGameObjectOwner, mActorView, mDBFacade, actionObj);

			case "startCooldown":
				final __ax4_iter_39 = mHeroGameObjectOwner.weaponControllers;
				if (checkNullIteratee(__ax4_iter_39))
					for (_tmp_ in __ax4_iter_39) {
						_loc3_ = _tmp_;
						if (_loc3_.weapon == mWeapon) {
							mWeaponController = _loc3_;
							break;
						}
					}
				_loc2_ = CoolDownAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mWeaponController, actionObj);

			case "queueAttack":
				if (mHeroGameObjectOwner != null && mHeroGameObjectOwner.weaponControllers != null) {
					__ax4_iter_40 = mHeroGameObjectOwner.weaponControllers;
					if (checkNullIteratee(__ax4_iter_40))
						for (_tmp_ in __ax4_iter_40) {
							_loc3_ = _tmp_;
							if (_loc3_.weapon == mWeapon) {
								mWeaponController = _loc3_;
								break;
							}
						}
					_loc2_ = QueueAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mWeaponController, actionObj);
				}

			default:
				return super.parseAction(actionObj);
		}
		return _loc2_;
	}

	override public function play(playSpeed:Float, target:ActorGameObject, finishedCallback:ASFunction = null, stopCallback:ASFunction = null,
			loop:Bool = false) {
		mCombatResults = new Vector<CombatResult>();
		mChoreographySent = false;
		super.play(playSpeed, target, finishedCallback, stopCallback, loop);
		if (!mChoreographed) {
			buildAndSendAttackObject();
		}
	}

	override public function stop() {
		if (mChoreographed) {
			buildAndSendAttackObject();
		}
		super.stop();
	}

	function buildAndSendAttackObject() {
		var _loc4_:Float = 0;
		var _loc5_ = false;
		if (mWeapon != null) {
			_loc4_ = this.mWeapon.slot;
			_loc5_ = this.mWeapon.isConsumable();
		}
		var _loc2_ = new Attack();
		_loc2_.attackType = mCurrentAttackType;
		_loc2_.weaponSlot = Std.int(_loc4_);
		_loc2_.isConsumableWeapon = (_loc5_ ? (1 : UInt) : (0 : UInt) : UInt);
		_loc2_.targetActorDoid = (ASCompat.toInt(mTargetActor != null ? mTargetActor.id : (0 : UInt)) : UInt);
		var _loc3_ = new AttackChoreography();
		_loc3_.attack = _loc2_;
		var _loc1_ = (mLoop ? (1 : UInt) : (0 : UInt) : UInt);
		_loc3_.loop = _loc1_;
		_loc3_.combatResults = mCombatResults;
		_loc3_.playSpeed = this.playSpeed;
		_loc3_.scalingMaxProjectiles = projectileMultiplier;
		mHeroGameObjectOwner.sendChoreography(_loc3_);
		mChoreographySent = true;
	}

	function combatResultCallback(combatResult:CombatResult) {
		var _loc3_:Vector<CombatResult> = /*undefined*/ null;
		combatResult.scalingMaxPowerMultiplier = mPowerMultiplier;
		if (!mChoreographed) {
			if (!mChoreographySent) {
				mCombatResults.push(combatResult);
			} else {
				_loc3_ = new Vector<CombatResult>();
				_loc3_.push(combatResult);
				mHeroGameObjectOwner.proposeCombatResults(_loc3_);
			}
		} else {
			mCombatResults.push(combatResult);
		}
		var _loc2_ = mDistributedDungeonFloor.getActor(combatResult.attackee);
		if (_loc2_ != null) {
			_loc2_.localCombatHit(combatResult);
		}
	}

	override public function destroy() {
		mCombatResults = null;
		super.destroy();
	}
}
