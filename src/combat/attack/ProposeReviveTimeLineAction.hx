package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class ProposeReviveTimeLineAction extends AttackTimelineAction {
	public static inline final TYPE = "proposeRevive";

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):ProposeReviveTimeLineAction {
		return new ProposeReviveTimeLineAction(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		var _loc2_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
		if (_loc2_ != null) {
			_loc2_.proposeRevive();
		}
	}
}
