package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import collections.LinkedList;
import collections.Map;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;

class AttackTimeline extends ScriptTimeline {
	var mCombatResultActions:Map;

	var mAttackName:String;

	var mWeapon:WeaponGameObject;

	var mChoreographed:Bool = false;

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
		mAttackName = attackJson.attackName;
		mChoreographed = ASCompat.toBool(attackJson.choreographed);
	}

	override public function destroy() {
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
		var _loc1_ = (ASCompat.floatToInt(currentGMAttack.ComboWindow * mTotalFrames) : UInt);
		var _loc2_ = (mLastExecutedFrame : UInt);
		return _loc2_ >= _loc1_;
	}

	override function parseAction(actionObj:ASObject):AttackTimelineAction {
		var _loc2_ = ASCompat.asString(actionObj.type);
		var _loc3_:AttackTimelineAction = null;
		switch (_loc2_) {
			case "attackEffect":
				_loc3_ = PlayEffectAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj, mWeapon);

			case "projectile":
				_loc3_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, mDistributedDungeonFloor, actionObj, mWeapon);

			case "automove":
				_loc3_ = AutoMoveTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade);

			case "attackautomove":
				_loc3_ = AttackAutoMoveTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade);

			case "block":
				_loc3_ = BlockAttackTimelineAction.buildFromJson(mActorGameObject, mActorView, mDBFacade, actionObj);

			default:
				return super.parseAction(actionObj);
		}
		return _loc3_;
	}

	override function processTimelineActions(frame:Int, gameClock:GameClock) {
		super.processTimelineActions(frame, gameClock);
		processTimelineFrame(mCombatResultActions, frame, gameClock);
	}

	override public function stop() {
		super.stop();
	}

	public function appendChoreography(attackChoreography:AttackChoreography) {
		var _loc2_:CombatResultAttackTimelineAction = null;
		var _loc4_:LinkedList = null;
		var _loc5_ = (0 : UInt);
		var _loc3_:CombatResult;
		final __ax4_iter_25 = attackChoreography.combatResults;
		if (checkNullIteratee(__ax4_iter_25))
			for (_tmp_ in __ax4_iter_25) {
				_loc3_ = _tmp_;
				_loc5_ = _loc3_.when;
				_loc2_ = new CombatResultAttackTimelineAction(mActorGameObject, mActorView, mDBFacade, _loc3_, mDistributedDungeonFloor);
				if (mCombatResultActions.hasKey(_loc5_)) {
					_loc4_ = ASCompat.coerce(mCombatResultActions.itemFor(_loc5_), collections.LinkedList);
					_loc4_.add(_loc2_);
				} else {
					_loc4_ = new LinkedList();
					_loc4_.add(_loc2_);
					mCombatResultActions.add(_loc5_, _loc4_);
				}
			}
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
		return (ASCompat.floatToInt(mProjectileScalingAngle) : UInt);
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
