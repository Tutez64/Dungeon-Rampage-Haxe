package combat.attack;

import actor.buffs.BuffHandler;
import brain.clock.GameClock;
import actor.player.HeroView;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import combat.weapon.ChargeWeaponController;
import combat.weapon.ConsumableWeaponController;
import combat.weapon.ConsumableWeaponGameObject;
import combat.weapon.RepeaterWeaponController;
import combat.weapon.ScalingWeaponController;
import combat.weapon.ShieldWeaponController;
import combat.weapon.WeaponController;
import combat.weapon.WeaponGameObject;
import distributedObjects.HeroGameObjectOwner;
import events.GameObjectEvent;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import gameMasterDictionary.GMStackable;

class PlayerOwnerAttackController {
	public static inline final DUNGEON_BUSTER_WEAPON_INDEX = (3 : UInt);

	static final LEGACY_ATTACK_QUEUE_INTERVAL_MS:Int = Std.int(GameClock.ANIMATION_FRAME_DURATION * 1000);

	var CHARGE_UP:String = "CHARGE_UP";

	var SCALING:String = "SCALING";

	var REPEATER:String = "REPEATER";

	var SHIELD:String = "BLOCKING";

	var mDistributedPlayerOwner:HeroGameObjectOwner;

	var mDBFacade:DBFacade;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mPotentialWeaponInputQueue:Array<ASAny>;

	var mQueueNextAttackWindow:Float = Math.NaN;

	var mLastQueuedTimeline:ScriptTimeline;

	var mLastQueuedTimelineTick:Int = -1;

	var mNextWeaponCommand:PotentialWeaponInputQueueStruct;

	var mComboTransitionCommand:PotentialWeaponInputQueueStruct;

	var mComboTransitionReadyTime:Int = -1;

	var mDungeonBusterGMAttack:GMAttack;

	var mDungeonBusterAttackTimeline:AttackTimeline;

	var mIsDungeonBusterUsed:Bool = false;

	var mWeaponControllers:Vector<WeaponController>;

	var mConsumableControllers:Vector<ConsumableWeaponController>;

	public function new(distributedPlayerOwner:HeroGameObjectOwner, heroView:HeroView, dbFacade:DBFacade) {
		mDistributedPlayerOwner = distributedPlayerOwner;
		mDBFacade = dbFacade;
		mPotentialWeaponInputQueue = [];
		mLogicalWorkComponent = new LogicalWorkComponent(dbFacade, "PlayerOwnerAttackController");
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.BERSERK_MODE_START, mDistributedPlayerOwner.id), berserkModeStart);
		mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.BERSERK_MODE_DONE, mDistributedPlayerOwner.id), berserkModeEnd);
		mIsDungeonBusterUsed = false;
		buildWeaponControllers();
		buildConsumableControllers();
		buildDungeonBuster();
		mQueueNextAttackWindow = mDBFacade.dbConfigManager.getConfigNumber("QUEUE_NEXT_ATTACK_WINDOW", 0.4);
	}

	function buildWeaponControllers() {
		var _loc3_:WeaponController = null;
		mWeaponControllers = new Vector<WeaponController>();
		var _loc2_ = (0 : UInt);
		var _loc1_:WeaponGameObject;
		final __ax4_iter_41 = mDistributedPlayerOwner.weapons;
		if (checkNullIteratee(__ax4_iter_41))
			for (_tmp_ in __ax4_iter_41) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc3_ = determineWeaponController(_loc1_);
				} else {
					_loc3_ = null;
				}
				mWeaponControllers.push(_loc3_);
				_loc2_++;
			}
	}

	function buildConsumableControllers() {
		var _loc1_:ConsumableWeaponController = null;
		mConsumableControllers = new Vector<ConsumableWeaponController>();
		var _loc2_ = (0 : UInt);
		var _loc3_:ConsumableWeaponGameObject;
		final __ax4_iter_42 = mDistributedPlayerOwner.consumables;
		if (checkNullIteratee(__ax4_iter_42))
			for (_tmp_ in __ax4_iter_42) {
				_loc3_ = _tmp_;
				if (_loc3_ != null) {
					_loc1_ = new ConsumableWeaponController(mDBFacade, _loc3_, mDistributedPlayerOwner);
				} else {
					_loc1_ = null;
				}
				mConsumableControllers.push(_loc1_);
				_loc2_++;
			}
	}

	function determineWeaponController(weapon:WeaponGameObject):WeaponController {
		var _loc2_:WeaponController = null;
		switch (weapon.weaponData.WeaponController) {
			case(_ == CHARGE_UP => true):
				_loc2_ = new ChargeWeaponController(mDBFacade, weapon, mDistributedPlayerOwner);

			case(_ == SCALING => true):
				_loc2_ = new ScalingWeaponController(mDBFacade, weapon, mDistributedPlayerOwner);

			case(_ == REPEATER => true):
				_loc2_ = new RepeaterWeaponController(mDBFacade, weapon, mDistributedPlayerOwner);

			case(_ == SHIELD => true):
				_loc2_ = new ShieldWeaponController(mDBFacade, weapon, mDistributedPlayerOwner);

			default:
				Logger.warn("Unable to determine weapon controller for GMWeaponItem.WeaponController: "
					+ weapon.weaponData.WeaponController
					+ ".  Using ChargeWeaponController as default.");
				_loc2_ = new ChargeWeaponController(mDBFacade, weapon, mDistributedPlayerOwner);
		}
		return _loc2_;
	}

	function buildDungeonBuster() {
		var _loc1_ = mDistributedPlayerOwner.gMHero.DBuster1;
		mDungeonBusterGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc1_), gameMasterDictionary.GMAttack);
		mDungeonBusterAttackTimeline = mDBFacade.timelineFactory.createAttackTimeline(mDungeonBusterGMAttack.AttackTimeline, null, mDistributedPlayerOwner,
			mDistributedPlayerOwner.distributedDungeonFloor);
		mDistributedPlayerOwner.maxBusterPoints = mDungeonBusterGMAttack.CrowdCost;
	}

	@:isVar public var weaponControllers(get, never):Vector<WeaponController>;

	public function get_weaponControllers():Vector<WeaponController> {
		return mWeaponControllers;
	}

	public function scrollWeapons(up:Bool) {
		if (currentWeaponController.currentTimeline == null) {
			if (up) {
				equipNextWeapon();
			} else {
				equipPreviousWeapon();
			}
		}
	}

	function equipNextWeapon() {
		var _loc2_ = this.mDistributedPlayerOwner.currentWeaponIndex;
		var _loc1_ = _loc2_ + 1;
		while (_loc2_ != _loc1_) {
			if (_loc1_ >= mWeaponControllers.length) {
				_loc1_ = 0;
			}
			if (mWeaponControllers[_loc1_] != null) {
				mDistributedPlayerOwner.currentWeaponIndex = _loc1_;
				return;
			}
			_loc1_++;
		}
	}

	function equipPreviousWeapon() {
		var _loc2_ = this.mDistributedPlayerOwner.currentWeaponIndex;
		var _loc1_ = _loc2_ - 1;
		while (_loc2_ != _loc1_) {
			if (_loc1_ < 0) {
				_loc1_ = mWeaponControllers.length - 1;
			}
			if (mWeaponControllers[_loc1_] != null) {
				mDistributedPlayerOwner.currentWeaponIndex = _loc1_;
				return;
			}
			_loc1_--;
		}
	}

	public function playDungeonBusterAttack() {
		if (mDistributedPlayerOwner.stateMachine.currentStateName == "ActorDefaultState" && mDistributedPlayerOwner.canInitiateAnAttack) {
			if (mDungeonBusterAttackTimeline == null) {
				buildDungeonBuster();
			}
			mNextWeaponCommand = null;
			mDistributedPlayerOwner.attack(mDungeonBusterGMAttack.Id, null, mDungeonBusterGMAttack.AttackSpdF, mDungeonBusterAttackTimeline);
			mDBFacade.hud.hideBustSign();
		}
	}

	public function canPlayDungeonBusterAttack():Bool {
		if (mDistributedPlayerOwner.dungeonBusterPoints >= mDistributedPlayerOwner.maxBusterPoints) {
			return true;
		}
		return false;
	}

	public function addToPotentialWeaponInputQueue(weaponIndex:UInt, down:Bool, autoAim:Bool) {
		if (mDungeonBusterAttackTimeline != null && mDungeonBusterAttackTimeline.isPlaying) {
			return;
		}
		if (weaponIndex == 3 && canPlayDungeonBusterAttack()) {
			mPotentialWeaponInputQueue.length;
			mPotentialWeaponInputQueue[0] = new PotentialWeaponInputQueueStruct(mWeaponControllers[(weaponIndex : Int)], weaponIndex, down, autoAim);
		} else {
			mPotentialWeaponInputQueue.push(new PotentialWeaponInputQueueStruct(mWeaponControllers[(weaponIndex : Int)], weaponIndex, down, autoAim));
		}
	}

	public function weaponCommandQueueUpCall() {
		var _loc2_:PotentialWeaponInputQueueStruct = null;
		var _loc1_ = false;
		var _loc3_:ScriptTimeline = currentWeaponController != null ? currentWeaponController.currentTimeline : null;
		var _loc4_ = -1;
		if (_loc3_ != null) {
			_loc4_ = Std.int((mDBFacade.gameClock.gameTime - currentWeaponController.currentAttackStartTime) / LEGACY_ATTACK_QUEUE_INTERVAL_MS);
		}
		if (_loc3_ != null && mLastQueuedTimeline == _loc3_ && mLastQueuedTimelineTick == _loc4_) {
			tryAttack();
			return;
		}
		while (mPotentialWeaponInputQueue.length > 0) {
			_loc2_ = ASCompat.dynamicAs(mPotentialWeaponInputQueue[0], combat.attack.PotentialWeaponInputQueueStruct);
			_loc1_ = false;
			if (_loc2_.weaponIndex == 3 && canPlayDungeonBusterAttack()) {
				mNextWeaponCommand = new PotentialWeaponInputQueueStruct(_loc2_.weaponController, _loc2_.weaponIndex, _loc2_.down, _loc2_.autoAim);
				_loc1_ = true;
				break;
			}
			if (_loc2_.down) {
				_loc1_ = canQueueWeaponDown(_loc2_);
			} else {
				_loc1_ = canQueueWeaponUp(_loc2_);
			}
			if (_loc1_) {
				mNextWeaponCommand = _loc2_;
			}
			mPotentialWeaponInputQueue.shift();
		}
		tryAttack();
		mLastQueuedTimeline = _loc3_;
		mLastQueuedTimelineTick = _loc4_;
		mPotentialWeaponInputQueue.resize(0);
	}

	function canQueueWeaponDown(weaponQueue:PotentialWeaponInputQueueStruct):Bool {
		if (mNextWeaponCommand != null
			|| currentWeaponController.weaponDownActive
			|| weaponQueue.weaponController != null
			&& weaponQueue.weaponController.IsInCooldown) {
			return false;
		}
		return true;
	}

	function canQueueWeaponUp(weaponQueue:PotentialWeaponInputQueueStruct):Bool {
		if (mNextWeaponCommand != null && mNextWeaponCommand.down && mNextWeaponCommand.weaponController == weaponQueue.weaponController) {
			mNextWeaponCommand = null;
		} else if (mNextWeaponCommand != null) {
			return false;
		}
		if (weaponQueue.weaponController != null && weaponQueue.weaponController.IsInCooldown) {
			return false;
		}
		if (currentWeaponController.currentTimeline == null) {
			return true;
		}
		return currentWeaponController.canQueue(weaponQueue, mQueueNextAttackWindow);
	}

	@:isVar var currentWeaponController(get, never):WeaponController;

	function get_currentWeaponController():WeaponController {
		return mWeaponControllers[mDistributedPlayerOwner.currentWeaponIndex];
	}

	function tryAttack() {
		var _loc1_:ScriptTimeline = null;
		if (mNextWeaponCommand == null) {
			clearComboTransitionDelay();
			return;
		}
		if (mDungeonBusterAttackTimeline != null && mDungeonBusterAttackTimeline.isPlaying) {
			mNextWeaponCommand = null;
			clearComboTransitionDelay();
			return;
		}
		var _loc2_ = false;
		var _loc3_ = mNextWeaponCommand.weaponController;
		var _loc4_ = mComboTransitionCommand == mNextWeaponCommand;
		if (mDistributedPlayerOwner.stateMachine.currentStateName == "ActorDefaultState" && mDistributedPlayerOwner.canInitiateAnAttack) {
			if (mNextWeaponCommand.weaponIndex == 3) {
				if (mDistributedPlayerOwner.dungeonBusterPoints >= mDistributedPlayerOwner.maxBusterPoints) {
					playDungeonBusterAttack();
				}
				mNextWeaponCommand = null;
				clearComboTransitionDelay();
				return;
			}
			_loc1_ = currentWeaponController.currentTimeline;
			if (mNextWeaponCommand.down) {
				if (_loc1_ == null) {
					_loc2_ = true;
				}
			} else if (_loc1_ == null) {
				_loc2_ = !_loc4_ || mLogicalWorkComponent.gameClock.gameTime >= mComboTransitionReadyTime;
			} else if (currentWeaponController.isRepeater() && currentWeaponController.weaponDownActive) {
				_loc2_ = true;
			} else if (currentWeaponController.canCombo()) {
				if (!_loc4_) {
					mComboTransitionCommand = mNextWeaponCommand;
					mComboTransitionReadyTime = getLegacyAttackQueueReadyTime(_loc1_);
					_loc4_ = true;
				}
				_loc2_ = mLogicalWorkComponent.gameClock.gameTime >= mComboTransitionReadyTime;
			} else {
				_loc2_ = false;
			}
		} else {
			mNextWeaponCommand = null;
			clearComboTransitionDelay();
			_loc4_ = false;
		}
		if (_loc1_ == null) {
			if (_loc4_) {
				resetCombosOnAllBut(mNextWeaponCommand.weaponIndex);
			} else {
				resetCombosOnAllBut();
			}
		}
		if (_loc2_) {
			if (mNextWeaponCommand.down) {
				onWeaponDown(mNextWeaponCommand.weaponIndex, mNextWeaponCommand.autoAim);
			} else {
				onWeaponUp(mNextWeaponCommand.weaponIndex, mNextWeaponCommand.autoAim);
			}
			mNextWeaponCommand = null;
			clearComboTransitionDelay();
		}
	}

	function clearComboTransitionDelay() {
		mComboTransitionCommand = null;
		mComboTransitionReadyTime = -1;
	}

	function getLegacyAttackQueueReadyTime(timeline:ScriptTimeline):Int {
		var _loc1_ = mLogicalWorkComponent.gameClock.gameTime;
		var _loc2_ = currentWeaponController.currentAttackStartTime;
		var _loc3_ = Std.int((_loc1_ - _loc2_) / LEGACY_ATTACK_QUEUE_INTERVAL_MS);
		if (mLastQueuedTimeline != timeline || mLastQueuedTimelineTick != _loc3_) {
			return _loc1_;
		}
		return _loc2_ + (_loc3_ + 1) * LEGACY_ATTACK_QUEUE_INTERVAL_MS;
	}

	public function isCharging():Bool {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mWeaponControllers.length) {
			if (mWeaponControllers[_loc1_] != null && mWeaponControllers[_loc1_].weaponDownActive) {
				return true;
			}
			_loc1_ = ASCompat.toInt(_loc1_) + 1;
		}
		return false;
	}

	public function onWeaponDown(weaponIndex:UInt, autoAim:Bool) {
		var _loc3_ = mDistributedPlayerOwner.weaponControllers[(weaponIndex : Int)];
		if (_loc3_ != null) {
			mDistributedPlayerOwner.currentWeaponIndex = (weaponIndex : Int);
			_loc3_.onWeaponDown(autoAim);
		}
	}

	public function onWeaponUp(weaponIndex:UInt, autoAim:Bool) {
		var _loc3_ = mDistributedPlayerOwner.weaponControllers[(weaponIndex : Int)];
		if (_loc3_ != null) {
			mDistributedPlayerOwner.heading = mDistributedPlayerOwner.inputHeading;
			_loc3_.onWeaponUp(autoAim);
			mDistributedPlayerOwner.currentWeaponIndex = (weaponIndex : Int);
		}
	}

	public function resetCombosOnAllBut(weaponIndex:UInt = null) {
		if (weaponIndex == null)
			weaponIndex = (Std.int(4294967295) : UInt);
		var _loc2_ = 0;
		var _loc3_:WeaponController = null;
		_loc2_ = 0;
		while (_loc2_ < mWeaponControllers.length) {
			if ((_loc2_ : UInt) != weaponIndex) {
				_loc3_ = mWeaponControllers[_loc2_];
				if (_loc3_ != null) {
					_loc3_.resetCombos();
				}
			}
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}

	public function resetWeapons() {
		var _loc1_ = 0;
		var _loc2_:WeaponController = null;
		mPotentialWeaponInputQueue.resize(0);
		_loc1_ = 0;
		while (_loc1_ < mWeaponControllers.length) {
			_loc2_ = mWeaponControllers[_loc1_];
			if (_loc2_ != null) {
				_loc2_.reset();
			}
			_loc1_ = ASCompat.toInt(_loc1_) + 1;
		}
	}

	public function playPotentialPotionAttack(stackableID:UInt) {
		var _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(stackableID), gameMasterDictionary.GMStackable);
		if (_loc3_ == null) {
			return;
		}
		var _loc2_ = _loc3_.UsageAttack;
		if (_loc2_ == null) {
			return;
		}
		var _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc2_), gameMasterDictionary.GMAttack);
		if (_loc4_ == null) {
			return;
		}
		var _loc6_ = mDBFacade.timelineFactory.createAttackTimeline(_loc4_.AttackTimeline, mDistributedPlayerOwner.currentWeapon, mDistributedPlayerOwner,
			mDistributedPlayerOwner.distributedDungeonFloor);
		var _loc7_:Float = mDistributedPlayerOwner.currentWeapon.getAttackTimeline(_loc4_.Id).totalFrames;
		var _loc5_ = _loc4_.AttackSpdF;
		if (_loc5_ > 0) {
			mDistributedPlayerOwner.attack(_loc4_.Id, null, _loc4_.AttackSpdF, _loc6_);
		}
	}

	function berserkModeStart(e:GameObjectEvent) {
		var _loc2_:ChargeWeaponController = null;
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < mWeaponControllers.length) {
			_loc2_ = ASCompat.reinterpretAs(mWeaponControllers[_loc3_], ChargeWeaponController);
			if (_loc2_ != null) {
				_loc2_.berserkModeStart();
			}
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
	}

	function berserkModeEnd(e:GameObjectEvent) {
		var _loc2_:ChargeWeaponController = null;
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < mWeaponControllers.length) {
			_loc2_ = ASCompat.reinterpretAs(mWeaponControllers[_loc3_], ChargeWeaponController);
			if (_loc2_ != null) {
				_loc2_.berserkModeEnd();
			}
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
	}

	public function tryToDoConsumableAttack(num:UInt) {
		if (mConsumableControllers[(num : Int)] != null && !mConsumableControllers[(num : Int)].IsInCooldown) {
			mConsumableControllers[(num : Int)].consume();
		}
	}

	public function stopAttacking() {
		mNextWeaponCommand = null;
		clearComboTransitionDelay();
		mLastQueuedTimeline = null;
		mLastQueuedTimelineTick = -1;
		mPotentialWeaponInputQueue.resize(0);
	}

	public function clearInput() {
		stopAttacking();
		var _loc1_:WeaponController;
		final __ax4_iter_43 = weaponControllers;
		if (checkNullIteratee(__ax4_iter_43))
			for (_tmp_ in __ax4_iter_43) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.reset();
				}
			}
	}

	public function destroy() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mWeaponControllers.length) {
			if (mWeaponControllers[_loc1_] != null) {
				mWeaponControllers[_loc1_].destroy();
			}
			_loc1_++;
		}
		_loc1_ = 0;
		while (_loc1_ < mConsumableControllers.length) {
			if (mConsumableControllers[_loc1_] != null) {
				mConsumableControllers[_loc1_].destroy();
			}
			_loc1_++;
		}
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mEventComponent.destroy();
		mEventComponent = null;
	}
}
