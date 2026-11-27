package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class MovementAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "move";

	var mMovementType:String;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, movementType:String) {
		super(actorGameObject, actorView, dbFacade);
		mMovementType = movementType;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):MovementAttackTimelineAction {
		var _loc5_:String = actionObj.movementType;
		return new MovementAttackTimelineAction(actorGameObject, actorView, dbFacade, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorGameObject.movementControllerType = mMovementType;
	}
}
