package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;

class ScaleAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "scale";

	var originalScaleValue:Float = Math.NaN;

	var scaleValue:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, scale:Float, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
		scaleValue = scale;
		originalScaleValue = actorView.root.scaleX;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):ScaleAttackTimelineAction {
		var _loc5_ = ASCompat.toNumber(actionObj.value);
		return new ScaleAttackTimelineAction(actorGameObject, actorView, _loc5_, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorView.root.scaleX = mActorView.root.scaleY = scaleValue;
	}

	override public function stop() {
		mActorView.root.scaleX = mActorView.root.scaleY = originalScaleValue;
		super.stop();
	}
}
