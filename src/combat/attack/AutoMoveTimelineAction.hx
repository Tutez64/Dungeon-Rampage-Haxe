package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.Task;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import flash.geom.Vector3D;

class AutoMoveTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "automove";

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
		var _loc5_ = mDistance / mDuration;
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
