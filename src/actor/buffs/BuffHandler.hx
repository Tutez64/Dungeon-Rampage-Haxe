package actor.buffs;

import actor.ActorGameObject;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.utils.MemoryTracker;
import brain.workLoop.DoLater;
import collections.IMapIterator;
import collections.Map;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObjectOwner;
import events.ActorInvulnerableEvent;
import events.GameObjectEvent;
import events.XPBonusEvent;
import facade.DBFacade;
import gameMasterDictionary.StatVector;

class BuffHandler {
	public static var ACTOR_INVULNERABLE:String = "ACTOR_INVULNERABLE";

	public static var BERSERK_MODE_START:String = "BERSERK_MODE_START";

	public static var BERSERK_MODE_DONE:String = "BERSERK_MODE_DONE";

	var mActorGameObject:ActorGameObject;

	var mBuffs:Map;

	var mMultiplier:StatVector;

	var mExpMultiplier:Float = Math.NaN;

	var mEventExpMultiplier:Float = Math.NaN;

	var mAttackCooldownMultiplier:Float = Math.NaN;

	var mFacade:DBFacade;

	public var Ability:UInt = 0;

	var mEventComponent:EventComponent;

	var mSwappableBuffs:Vector<BuffGameObject>;

	var mCurrentSwappableBuff:Int = 0;

	var mSwappableBuffDisplayTask:DoLater;

	public function new(facade:DBFacade, actorGameObject:ActorGameObject) {
		mFacade = facade;
		mActorGameObject = actorGameObject;
		mMultiplier = new StatVector();
		resetMultiplier();
		mExpMultiplier = 1;
		mEventExpMultiplier = 1;
		mAttackCooldownMultiplier = 1;
		mBuffs = new Map();
		mEventComponent = new EventComponent(mFacade);
		mSwappableBuffs = new Vector<BuffGameObject>();
	}

	static function isAdditiveSlot(slot:UInt):Bool {
		return slot == (DBGlobal.MELEE_DEF : UInt) || slot == (DBGlobal.SHOOT_DEF : UInt) || slot == (DBGlobal.MAGIC_DEF : UInt);
	}

	public function destroy() {
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		if (mSwappableBuffDisplayTask != null) {
			mSwappableBuffDisplayTask.destroy();
			mSwappableBuffDisplayTask = null;
		}
		var _loc1_ = ASCompat.reinterpretAs(mBuffs.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc1_.next();
			_loc1_.current.destroy();
		}
		mBuffs.clear();
		mMultiplier.destroy();
		mMultiplier = null;
		mExpMultiplier = 0;
		mEventExpMultiplier = 1;
		mAttackCooldownMultiplier = 1;
		mBuffs = null;
		mSwappableBuffs.splice(0, (mSwappableBuffs.length : UInt));
		mSwappableBuffs = null;
	}

	public function addBuff(dBuff:DistributedBuffGameObject) {
		var _loc9_:BuffGameObject = null;
		var _loc3_:BuffGameObject = null;
		var _loc7_:HeroGameObjectOwner = null;
		if (mBuffs == null) {
			return;
		}
		var _loc6_ = IsInvulnerable();
		var _loc5_ = IsBerserk();
		var _loc4_ = mExpMultiplier;
		var _loc8_ = mEventExpMultiplier;
		var _loc2_ = ASCompat.coerce(mBuffs.itemFor(dBuff.type), actor.buffs.BuffGameObject);
		if (_loc2_ == null) {
			_loc9_ = new BuffGameObject(mFacade, mActorGameObject, mActorGameObject.actorView, dBuff.type, (0 : UInt), dBuff.attackerActor);
			MemoryTracker.track(_loc9_, "BuffGameObject - created in BuffHandler.activateBuff()");
			mBuffs.add(dBuff.type, _loc9_);
			recalcBuffMultiplier();
			recalcBuffAbility();
			_loc3_ = ASCompat.coerce(mBuffs.itemFor(dBuff.type), actor.buffs.BuffGameObject);
			if (_loc3_.CanSwapDisplay) {
				mSwappableBuffs.push(_loc3_);
				if (mSwappableBuffDisplayTask == null && mSwappableBuffs.length > 1) {
					processSwappableBuffDisplays();
					mSwappableBuffDisplayTask = mFacade.logicalWorkManager.doEverySeconds(1, processSwappableBuffDisplays, true, "BuffHandler");
				}
			}
		} else {
			_loc2_.instanceCount += (1 : UInt);
			_loc2_.updateInstanceCountOnHud();
			recalcBuffMultiplier();
		}
		dBuff.buffHandler = this;
		if (mActorGameObject.isOwner && IsDisabledControls()) {
			_loc7_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
			if (_loc7_ != null) {
				_loc7_.inputController.disableCombat();
			}
		}
		if (!_loc6_ && IsInvulnerable()) {
			mEventComponent.dispatchEvent(new ActorInvulnerableEvent(ACTOR_INVULNERABLE, mActorGameObject.id, true));
		}
		if (!_loc5_ && IsBerserk()) {
			mEventComponent.dispatchEvent(new GameObjectEvent(BERSERK_MODE_START, mActorGameObject.id));
		}
		if (mActorGameObject != null && mActorGameObject.isOwner && mExpMultiplier != _loc4_) {}
		if (mActorGameObject != null && mActorGameObject.isOwner && mEventExpMultiplier != _loc8_) {
			mEventComponent.dispatchEvent(new XPBonusEvent("XP_BONUS_EVENT", true, mEventExpMultiplier));
		}
	}

	public function removeBuff(dBuff:DistributedBuffGameObject) {
		var _loc6_:HeroGameObjectOwner = null;
		var _loc5_ = 0;
		if (mBuffs == null) {
			return;
		}
		var _loc7_ = IsInvulnerable();
		var _loc4_ = IsBerserk();
		var _loc3_ = mExpMultiplier;
		if (mActorGameObject.isOwner && IsDisabledControls()) {
			_loc6_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
			if (_loc6_ != null) {
				_loc6_.inputController.enableCombat();
			}
		}
		var _loc2_ = ASCompat.coerce(mBuffs.itemFor(dBuff.type), actor.buffs.BuffGameObject);
		if (_loc2_ != null) {
			_loc2_.instanceCount -= (1 : UInt);
			_loc2_.updateInstanceCountOnHud();
			if (_loc2_.instanceCount <= 0) {
				_loc5_ = 0;
				while (_loc5_ < mSwappableBuffs.length) {
					if (mSwappableBuffs[_loc5_] == _loc2_) {
						mSwappableBuffs.splice(_loc5_, (1 : UInt));
					}
					_loc5_++;
				}
				if (mCurrentSwappableBuff > mSwappableBuffs.length) {
					mCurrentSwappableBuff = mSwappableBuffs.length;
				}
				if (mSwappableBuffDisplayTask != null && mSwappableBuffs.length < 2) {
					mSwappableBuffDisplayTask.destroy();
					mSwappableBuffDisplayTask = null;
					mCurrentSwappableBuff = 0;
					if (mSwappableBuffs.length == 1) {
						mSwappableBuffs[0].buffView.show(0.5);
					}
				}
				mBuffs.remove(_loc2_);
				_loc2_.destroy();
				_loc2_ = null;
				recalcBuffAbility();
			}
			recalcBuffMultiplier();
		}
		if (_loc7_ && !IsInvulnerable()) {
			mEventComponent.dispatchEvent(new ActorInvulnerableEvent(ACTOR_INVULNERABLE, mActorGameObject.id, false));
		}
		if (_loc4_ && !IsBerserk()) {
			mEventComponent.dispatchEvent(new GameObjectEvent(BERSERK_MODE_DONE, mActorGameObject.id));
		}
	}

	function processSwappableBuffDisplays(gameClock:GameClock = null) {
		var _loc1_:BuffGameObject = null;
		var _loc2_:BuffGameObject = null;
		if (mSwappableBuffs == null || mSwappableBuffs.length == 0) {
			mCurrentSwappableBuff = 0;
			return;
		}
		if (mCurrentSwappableBuff >= mSwappableBuffs.length) {
			mCurrentSwappableBuff = 0;
			_loc1_ = mSwappableBuffs[mSwappableBuffs.length - 1];
			if (_loc1_ != null && _loc1_.buffView != null) {
				_loc1_.buffView.show(0.5);
			}
		} else if (mCurrentSwappableBuff > 0) {
			_loc1_ = mSwappableBuffs[mCurrentSwappableBuff - 1];
			if (_loc1_ != null && _loc1_.buffView != null) {
				_loc1_.buffView.show(0.5);
			}
		}
		_loc2_ = mSwappableBuffs[mCurrentSwappableBuff];
		if (_loc2_ != null && _loc2_.buffView != null) {
			_loc2_.buffView.hide(0.5);
		}
		mCurrentSwappableBuff = mCurrentSwappableBuff + 1;
	}

	function resetMultiplier() {
		mMultiplier.setConstant(1);
		mMultiplier.values[DBGlobal.MELEE_DEF] = 0;
		mMultiplier.values[DBGlobal.SHOOT_DEF] = 0;
		mMultiplier.values[DBGlobal.MAGIC_DEF] = 0;
	}

	public function recalcBuffMultiplier() {
		var _loc5_:Float;
		var _loc6_:Float;
		var _loc3_:BuffGameObject = null;
		var _loc1_ = (0 : UInt);
		var _loc2_ = (0 : UInt);
		resetMultiplier();
		mExpMultiplier = 1;
		mEventExpMultiplier = 1;
		mAttackCooldownMultiplier = 1;
		var _loc4_ = ASCompat.reinterpretAs(mBuffs.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			_loc3_ = ASCompat.coerce(_loc4_.next(), actor.buffs.BuffGameObject);
			_loc1_ = (0 : UInt);
			while (_loc1_ < _loc3_.instanceCount) {
				_loc2_ = (0 : UInt);
				while (_loc2_ < StatVector.slotCount) {
					if (isAdditiveSlot(_loc2_)) {
						_loc5_ = _loc2_;
						_loc6_ = mMultiplier.values[ASCompat.floatToInt(_loc5_)] + _loc3_.deltaValues.values[(_loc2_ : Int)];
						mMultiplier.values[ASCompat.floatToInt(_loc5_)] = _loc6_;
					} else {
						_loc6_ = _loc2_;
						_loc5_ = mMultiplier.values[ASCompat.floatToInt(_loc6_)] * _loc3_.deltaValues.values[(_loc2_ : Int)];
						mMultiplier.values[ASCompat.floatToInt(_loc6_)] = _loc5_;
					}
					_loc2_++;
				}
				mExpMultiplier *= _loc3_.ExpMult;
				mEventExpMultiplier *= _loc3_.EventExpMult;
				mAttackCooldownMultiplier *= _loc3_.attackCooldownMultiplier;
				_loc1_++;
			}
		}
	}

	@:isVar public var attackCooldownMultiplier(get, never):Float;

	public function get_attackCooldownMultiplier():Float {
		return mAttackCooldownMultiplier;
	}

	public function recalcBuffAbility() {
		var _loc2_:BuffGameObject = null;
		var _loc1_ = (0 : UInt);
		Ability = (0 : UInt);
		var _loc3_ = ASCompat.reinterpretAs(mBuffs.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc3_.next(), actor.buffs.BuffGameObject);
			_loc1_ = (0 : UInt);
			while (_loc1_ < _loc2_.instanceCount) {
				Ability = ((Ability | _loc2_.Ability : UInt) : UInt);
				_loc1_++;
			}
		}
	}

	public function HasAbility(ability:UInt):Bool {
		return ((Ability : Int) & (ability : Int)) != 0;
	}

	public function IsInvulnerable():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_INVULNERABLE_ALL : Int)) != 0;
	}

	public function IsDisabledControls():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_DISABLE_CONTROLS : Int)) != 0;
	}

	public function IsInvulnerableMelee():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_INVULNERABLE_MELEE : Int)) != 0;
	}

	public function IsInvulnerableMagic():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_INVULNERABLE_MAGIC : Int)) != 0;
	}

	public function IsInvulnerableShoot():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_INVULNERABLE_SHOOT : Int)) != 0;
	}

	public function CanStun():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_SUFFER_IMMUNITY : Int)) == 0;
	}

	public function IsBerserk():Bool {
		return ((Ability : Int) & (DBGlobal.ABILITY_BERSERK_MODE : Int)) != 0;
	}

	@:isVar public var multiplier(get, never):StatVector;

	public function get_multiplier():StatVector {
		return mMultiplier;
	}
}
