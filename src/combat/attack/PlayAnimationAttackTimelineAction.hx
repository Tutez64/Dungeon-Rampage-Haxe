package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class PlayAnimationAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "playAnim";

	var mAnimName:String;

	public var mStartFrame:UInt = 0;

	var mScriptTimeline:ScriptTimeline;

	public function new(scriptTimeline:ScriptTimeline, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, animName:String,
			startFrame:UInt) {
		super(actorGameObject, actorView, dbFacade);
		mStartFrame = startFrame;
		mAnimName = animName;
		mScriptTimeline = scriptTimeline;
	}

	public static function buildFromJson(attackTimeline:ScriptTimeline, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):PlayAnimationAttackTimelineAction {
		var _loc7_:String = actionObj.animName;
		var _loc6_ = (ASCompat.toInt(actionObj.startFrame) : UInt);
		return new PlayAnimationAttackTimelineAction(attackTimeline, actorGameObject, actorView, dbFacade, _loc7_, _loc6_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorView.playAnim(mAnimName, (mStartFrame : Int), true, false, mScriptTimeline.playSpeed);
	}
}
