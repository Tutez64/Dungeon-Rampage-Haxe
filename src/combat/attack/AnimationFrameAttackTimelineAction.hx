package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class AnimationFrameAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "animFrame";

	var mAnimName:String;

	public var mFrameNumber:UInt = 0;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, animName:String, frameNumber:UInt) {
		super(actorGameObject, actorView, dbFacade);
		mFrameNumber = frameNumber;
		mAnimName = animName;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):AnimationFrameAttackTimelineAction {
		var _loc6_:String = actionObj.animName;
		var _loc5_ = (ASCompat.toInt(actionObj.frame) : UInt);
		return new AnimationFrameAttackTimelineAction(actorGameObject, actorView, dbFacade, _loc6_, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorView.setAnimAt(mAnimName, mFrameNumber);
	}
}
