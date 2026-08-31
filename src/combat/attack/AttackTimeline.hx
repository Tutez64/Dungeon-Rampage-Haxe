package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.logger.Logger;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import effects.ChargeEffectGameObject;
import effects.EffectGameObject;
import facade.DBFacade;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;
import org.as3commons.collections.LinkedList;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class AttackTimeline extends ScriptTimeline {
	var mCombatResultActions:Map;

	var mAttackName:String;

	var mWeapon:WeaponGameObject;

	var mChoreographed:Bool = false;

	var mRegisteredEffects:Map;

	var mChargeEffect:ChargeEffectGameObject;

	var mPowerMultiplier:Float = 1;

	var mProjectileMultiplier:UInt = (1 : UInt);

	var mProjectileScalingAngle:Float = 20;

	var mDistanceScalingTime:Float = 0;

	var mDistanceScalingForHero:Float = 0;

	var mDistanceScalingForProjectiles:Float = 0;

	public function new(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, attackJson:ASObject, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor) {
		mWeapon = weapon;
		super(actorGameObject, actorView, attackJson, dbFacade, distributedDungeonFloor);
		mCombatResultActions = new Map();
		mRegisteredEffects = new Map();
		mAttackName = attackJson.attackName;
		mChoreographed = ASCompat.toBool(attackJson.choreographed);
	}

	override public function destroy() {
		this.cleanUpRegisteredEffects();
		mRegisteredEffects.clear();
		mRegisteredEffects = null;
		mCombatResultActions.clear();
		mCombatResultActions = null;
		mWeapon = null;
		super.destroy();
	}

	@:isVar public var weapon(get, never):WeaponGameObject;

	public function get_weapon():WeaponGameObject {
		return mWeapon;
	}

	override public function get_attackName():String {
		return mAttackName;
	}

	@:isVar public var totalFrames(get, never):UInt;

	public function get_totalFrames():UInt {
		return mTotalFrames;
	}

	public function isAttackWithinComboWindow():Bool {
		var _loc1_ = (Std.int(currentGMAttack.ComboWindow * mTotalFrames) : UInt);
		var _loc2_ = (mLastExecutedFrame : UInt);
		if (_loc2_ >= _loc1_) {
			return true;
		}
		return false;
	}

	override function parseAction(actionObj:ASObject):AttackTimelineAction {
		var _loc3_ = ASCompat.asString(actionObj.type);
		var _loc2_:AttackTimelineAction = null;
		switch (_loc3_) {
			case "attackEffect":
				_loc2_ = PlayEffectAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj, mWeapon,
					registerEffect);

			case "projectile":
				_loc2_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj, mWeapon);

			case "automove":
				_loc2_ = AutoMoveTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade);

			case "attackautomove":
				_loc2_ = AttackAutoMoveTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade);

			case "block":
				_loc2_ = BlockAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, actionObj);

			default:
				return super.parseAction(actionObj);
		}
		return _loc2_;
	}

	override function processTimelineActions(frame:Int, gameClock:GameClock) {
		super.processTimelineActions(frame, gameClock);
		processTimelineFrame(mCombatResultActions, frame, gameClock);
	}

	override public function stop() {
		super.stop();
		cleanUpRegisteredEffects();
	}

	function cleanUpRegisteredEffects() {
		var _loc2_:EffectGameObject = null;
		var _loc1_ = ASCompat.reinterpretAs(mRegisteredEffects.iterator(), IMapIterator);
		while (ASCompat.toBool(_loc1_.next())) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.current, EffectGameObject);
			_loc2_.destroy();
		}
		mRegisteredEffects.clear();
		if (mChargeEffect != null) {
			mChargeEffect.destroy();
			mChargeEffect = null;
		}
	}

	public function appendChoreography(attackChoreography:AttackChoreography) {
		var _loc2_:CombatResultAttackTimelineAction = null;
		var _loc4_:LinkedList = null;
		var _loc5_ = 0;
		var _loc3_:CombatResult;
		final __ax4_iter_41 = attackChoreography.combatResults;
		if (checkNullIteratee(__ax4_iter_41))
			for (_tmp_ in __ax4_iter_41) {
				_loc3_ = _tmp_;
				_loc5_ = (_loc3_.when : Int);
				_loc2_ = new CombatResultAttackTimelineAction(mActorGameObject, mActorView, mDBFacade, _loc3_, mDistributedDungeonFloor);
				if (mCombatResultActions.hasKey(_loc5_)) {
					_loc4_ = ASCompat.dynamicAs(mCombatResultActions.itemFor(_loc5_), org.as3commons.collections.LinkedList);
					_loc4_.add(_loc2_);
				} else {
					_loc4_ = new LinkedList();
					_loc4_.add(_loc2_);
					mCombatResultActions.add(_loc5_, _loc4_);
				}
			}
	}

	public function registerEffect(effectGameObject:EffectGameObject) {
		if (Std.isOfType(effectGameObject, ChargeEffectGameObject)) {
			if (mChargeEffect != null) {
				Logger.error("Trying to register more than one charge effect on timeline.");
				mRegisteredEffects.removeKey(mChargeEffect.id);
				mChargeEffect.destroy();
				mChargeEffect = null;
				return;
			}
			mChargeEffect = ASCompat.reinterpretAs(effectGameObject, ChargeEffectGameObject);
		}
		mRegisteredEffects.add(effectGameObject.id, effectGameObject);
	}

	@:isVar public var chargeEffect(get, never):ChargeEffectGameObject;

	public function get_chargeEffect():ChargeEffectGameObject {
		return mChargeEffect;
	}

	@:isVar public var powerMultiplier(get, set):Float;

	public function set_powerMultiplier(val:Float):Float {
		return mPowerMultiplier = val;
	}

	function get_powerMultiplier():Float {
		return mPowerMultiplier;
	}

	@:isVar public var projectileMultiplier(get, set):UInt;

	public function set_projectileMultiplier(val:UInt):UInt {
		return mProjectileMultiplier = val;
	}

	function get_projectileMultiplier():UInt {
		return mProjectileMultiplier;
	}

	@:isVar public var projectileScalingAngle(get, set):UInt;

	public function set_projectileScalingAngle(val:UInt):UInt {
		mProjectileScalingAngle = val;
		return val;
	}

	function get_projectileScalingAngle():UInt {
		return (Std.int(mProjectileScalingAngle) : UInt);
	}

	@:isVar public var distanceScalingTime(get, set):Float;

	public function set_distanceScalingTime(val:Float):Float {
		return mDistanceScalingTime = val;
	}

	function get_distanceScalingTime():Float {
		return mDistanceScalingTime;
	}

	@:isVar public var distanceScalingHero(get, set):Float;

	public function set_distanceScalingHero(val:Float):Float {
		return mDistanceScalingForHero = val;
	}

	function get_distanceScalingHero():Float {
		return mDistanceScalingForHero;
	}

	@:isVar public var distanceScalingProjectile(get, set):Float;

	public function set_distanceScalingProjectile(val:Float):Float {
		return mDistanceScalingForProjectiles = val;
	}

	function get_distanceScalingProjectile():Float {
		return mDistanceScalingForProjectiles;
	}
}
