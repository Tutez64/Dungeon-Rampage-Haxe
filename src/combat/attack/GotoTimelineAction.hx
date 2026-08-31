package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class GotoTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "goto";

	var mGotoFrame:Int = 0;

	var mGotoFunction:ASFunction;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject, gotoFunction:ASFunction) {
		super(actorGameObject, actorView, dbFacade);
		mGotoFrame = ASCompat.toInt(actionObj.gotoFrame);
		mGotoFunction = gotoFunction;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject,
			gotoFunction:ASFunction):GotoTimelineAction {
		return new GotoTimelineAction(actorGameObject, actorView, dbFacade, actionObj, gotoFunction);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mGotoFunction(mGotoFrame);
	}
}
