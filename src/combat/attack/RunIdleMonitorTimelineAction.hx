package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class RunIdleMonitorTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "runIdleMonitor";

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):RunIdleMonitorTimelineAction {
		return new RunIdleMonitorTimelineAction(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorGameObject.startRunIdleMonitoring();
	}

	override public function stop() {
		mActorGameObject.stopRunIdleMonitoring();
	}
}
