package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.Task;
import facade.DBFacade;

class TimeScaleTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "timeScale";

	var mTask:Task;

	var mDuration:Float = 0;

	var mTimeScale:Float = 1;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		if (parameterJson.duration == null) {
			Logger.error("TimeScaleTimelineAction: Must specify duration");
		}
		if (parameterJson.timeScale == null) {
			Logger.error("TimeScaleTimelineAction: Must specify timeScale");
		}
		var _loc5_ = (24 : UInt);
		mDuration = ASCompat.toNumberField(parameterJson, "duration") / _loc5_;
		mTimeScale = ASCompat.toNumberField(parameterJson, "timeScale");
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			parameterJson:ASObject):TimeScaleTimelineAction {
		if (actorGameObject.isOwner) {
			return new TimeScaleTimelineAction(actorGameObject, actorView, dbFacade, parameterJson);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		this.mDBFacade.gameClock.timeScale = mTimeScale;
		mTask = mWorkComponent.doLater(mDuration, resetTimeScale);
	}

	function resetTimeScale(gameClock:GameClock) {
		this.mDBFacade.gameClock.timeScale = 1;
	}

	override public function destroy() {
		super.destroy();
	}

	override public function stop() {
		this.mDBFacade.gameClock.timeScale = 1;
		if (mTask != null) {
			mTask.destroy();
			mTask = null;
		}
	}
}
