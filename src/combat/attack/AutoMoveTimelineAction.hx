package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import box2D.common.B2Settings;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.Task;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import flash.geom.Vector3D;

class AutoMoveTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "automove";

	static final MAX_AUTO_MOVE_TRANSLATION_PER_STEP:Float = B2Settings.b2_maxTranslation * 50;

	static final LEGACY_MAX_AUTO_MOVE_SPEED:Float = MAX_AUTO_MOVE_TRANSLATION_PER_STEP / GameClock.ANIMATION_FRAME_DURATION;

	var mTask:Task;

	var mAttack:GMAttack;

	var mDistance:Float = Math.NaN;

	var mDuration:Float = Math.NaN;

	var mAngle:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade):AutoMoveTimelineAction {
		if (actorGameObject.isOwner) {
			return new AutoMoveTimelineAction(actorGameObject, actorView, dbFacade);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		var _loc4_ = cast(mActorGameObject, HeroGameObjectOwner);
		if (mDuration <= 0 || Math.isNaN(mAngle)) {
			Logger.warn("Invalid data for AutoMoveTimelineAction. mDistance: " + mDistance + " mDuration: " + mDuration + " mAngle: " + mAngle + " attack: "
				+ mAttackType);
			return;
		}
		var _loc6_ = Math.max(mDBFacade.gameClock.tickLength, 0.000001);
		var _loc11_ = Std.int(mDuration * 1000);
		var _loc12_ = Std.int(Math.max(Std.int(_loc6_ * 1000), 1));
		var _loc7_ = Std.int(Math.ceil(_loc11_ / Math.max(Std.int(GameClock.ANIMATION_FRAME_DURATION * 1000), 1))) + 1;
		var _loc8_ = Std.int(Math.ceil(_loc11_ / _loc12_)) + 1;
		var _loc13_ = Math.min(mDistance / mDuration, LEGACY_MAX_AUTO_MOVE_SPEED);
		var _loc9_ = _loc13_ * _loc7_ * GameClock.ANIMATION_FRAME_DURATION;
		var _loc10_ = Math.max(_loc8_ * _loc6_, _loc6_);
		var _loc5_ = _loc9_ / _loc10_;
		var _loc3_ = mAngle * 3.141592653589793 / 180;
		var _loc2_ = new Vector3D(Math.cos(_loc3_) * _loc5_, Math.sin(_loc3_) * _loc5_);
		_loc4_.autoMoveVelocity = _loc2_;
		mTask = mWorkComponent.doLater(mDuration, resetVelocity);
	}

	function resetVelocity(gameClock:GameClock) {
		var _loc2_ = cast(mActorGameObject, HeroGameObjectOwner);
		_loc2_.autoMoveVelocity.scaleBy(0);
	}

	override public function destroy() {
		if (mTask != null) {
			resetVelocity(null);
			mTask.destroy();
			mTask = null;
		}
		super.destroy();
	}
}
