package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class BlockAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "block";

	var mMaximumDotForBlocking:Float = Math.NaN;

	var mPreviousBlockValue:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, blockDot:Float) {
		super(actorGameObject, actorView, dbFacade);
		mMaximumDotForBlocking = blockDot;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):BlockAttackTimelineAction {
		var _loc5_ = ASCompat.toNumber(actionObj.blockDot);
		return new BlockAttackTimelineAction(actorGameObject, actorView, dbFacade, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		mActorGameObject.isBlocking = true;
		mActorGameObject.maximumDotForBlocking = mMaximumDotForBlocking;
		mPreviousBlockValue = mActorGameObject.maximumDotForBlocking;
	}

	override public function stop() {
		if (mActorGameObject != null) {
			mActorGameObject.maximumDotForBlocking = mPreviousBlockValue;
			mActorGameObject.isBlocking = false;
		}
		super.stop();
	}
}
