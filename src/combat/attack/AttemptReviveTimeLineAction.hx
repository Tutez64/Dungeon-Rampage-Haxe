package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.workLoop.Task;
import facade.DBFacade;

class AttemptReviveTimeLineAction extends AttackTimelineAction {
	public static inline final TYPE = "attemptRevive";

	static inline final REVIVE_KEYCODE = 32;

	var mKeyboardCheckTask:Task;

	var mDeltaPerFrame:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):AttemptReviveTimeLineAction {
		return new AttemptReviveTimeLineAction(actorGameObject, actorView, dbFacade);
	}

	function keyboardCheck(gameClock:GameClock) {
		var _loc2_ = isReviveActionDown();
		if (!_loc2_ || !this.mTimeline.targetActor.isInReviveState()) {
			mTimeline.stop();
		}
	}

	function isReviveActionDown():Bool {
		return mDBFacade.inputManager.check(32) || mDBFacade.steamInputManager.heldAction("revive_ally");
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mKeyboardCheckTask = mWorkComponent.doEveryFrame(keyboardCheck);
	}

	override public function stop() {
		if (mKeyboardCheckTask != null) {
			mKeyboardCheckTask.destroy();
			mKeyboardCheckTask = null;
		}
	}
}
