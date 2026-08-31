package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;
import flash.geom.Vector3D;

class FadeBackgroundTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "fadebackground";

	var mDuration:UInt = 0;

	var mTransitionDuration:Float = Math.NaN;

	var mColor:Vector3D;

	var mOffset:Float = Math.NaN;

	var mAlpha:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:UInt, color:Vector3D, alpha:Float,
			transitionDur:Float) {
		mDuration = duration;
		mTransitionDuration = transitionDur;
		mColor = new Vector3D(color.x, color.y, color.z);
		mAlpha = alpha;
		mOffset = alpha / transitionDur;
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):FadeBackgroundTimelineAction {
		var _loc5_ = (ASCompat.toInt(actionObj.duration) : UInt);
		var _loc6_ = new Vector3D(ASCompat.toNumberField(actionObj, "color_r"), ASCompat.toNumberField(actionObj, "color_g"),
			ASCompat.toNumberField(actionObj, "color_b"));
		var _loc8_ = ASCompat.toNumber(actionObj.alpha);
		var _loc7_ = ASCompat.toNumber(actionObj.transitionDur);
		return new FadeBackgroundTimelineAction(actorGameObject, actorView, dbFacade, _loc5_, _loc6_, _loc8_, _loc7_);
	}

	override public function execute(timeline:ScriptTimeline) {
		if (!mActorGameObject.isOwner && !mDBFacade.camera.isPointOnScreen(mActorGameObject.position)) {
			return;
		}
		super.execute(timeline);
		var _loc2_:Array<ASAny> = [];
		_loc2_.push(mActorView.root);
		mDBFacade.camera.fadeBackground(_loc2_, mDuration, mTransitionDuration, mColor, mAlpha);
	}

	override public function stop() {
		mDBFacade.camera.killBackgroundFader();
	}
}
