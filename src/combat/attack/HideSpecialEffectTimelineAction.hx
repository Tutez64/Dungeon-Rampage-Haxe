package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class HideSpecialEffectTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "hideSpecialEffect";

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):HideSpecialEffectTimelineAction {
		return new HideSpecialEffectTimelineAction(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorView.hideSpecialEffect();
	}

	override public function stop() {
		mActorView.showSpecialEffect();
		super.stop();
	}
}
