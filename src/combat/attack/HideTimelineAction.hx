package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class HideTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "visible";

	var value:Bool = false;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		value = ASCompat.toBool(actionObj.value);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):HideTimelineAction {
		return new HideTimelineAction(actorGameObject, actorView, dbFacade, actionObj);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorGameObject.view.root.visible = value;
	}

	override public function stop() {
		mActorGameObject.view.root.visible = true;
	}
}
