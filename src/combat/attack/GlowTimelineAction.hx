package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;
import com.greensock.TweenMax;

class GlowTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "glow";

	var mDuration:Float = Math.NaN;

	var mGlowColor:String;

	var mBlurX:UInt = 0;

	var mBlurY:UInt = 0;

	var mGlowStrength:Float = Math.NaN;

	var mAlpha:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:Float, color:String, blurX:UInt, blurY:UInt,
			strength:UInt, alpha:Float) {
		mDuration = duration;
		mGlowColor = color;
		mBlurX = blurX;
		mBlurY = blurY;
		mGlowStrength = strength;
		mAlpha = alpha;
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):GlowTimelineAction {
		var _loc5_ = ASCompat.toNumber(actionObj.duration);
		var _loc6_:String = actionObj.color;
		var _loc9_ = (ASCompat.toInt(actionObj.blurX) : UInt);
		var _loc8_ = (ASCompat.toInt(actionObj.blurY) : UInt);
		var _loc7_ = (ASCompat.toInt(actionObj.strength) : UInt);
		var _loc10_ = ASCompat.toNumber(actionObj.alpha);
		return new GlowTimelineAction(actorGameObject, actorView, dbFacade, _loc5_, _loc6_, _loc9_, _loc8_, _loc7_, _loc10_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		TweenMax.to(mActorView.body, mDuration, {
			"glowFilter": {
				"color": mGlowColor,
				"blurX": mBlurX,
				"blurY": mBlurY,
				"strength": mGlowStrength,
				"alpha": mAlpha,
				"quality": 3,
				"remove": true
			}
		});
	}

	override public function destroy() {
		super.destroy();
	}
}
