package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class SufferImmunityTimeLineAction extends AttackTimelineAction {
	public static inline final TYPE = "sufferImmunity";

	var mHeroGameObjectOwner:HeroGameObjectOwner;

	var mCanSuffer:Bool = false;

	var mCanSuffer_original:Bool = false;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, canSuffer:Bool) {
		super(actorGameObject, actorView, dbFacade);
		mHeroGameObjectOwner = null;
		mCanSuffer = canSuffer;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):SufferImmunityTimeLineAction {
		var _loc5_ = ASCompat.toBool(actionObj.value);
		return new SufferImmunityTimeLineAction(actorGameObject, actorView, dbFacade, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
		if (mHeroGameObjectOwner != null) {
			mCanSuffer_original = mHeroGameObjectOwner.canSuffer;
			mHeroGameObjectOwner.canSuffer = mCanSuffer;
		}
	}

	override public function stop() {
		if (mHeroGameObjectOwner != null) {
			mHeroGameObjectOwner.canSuffer = mCanSuffer_original;
		}
		mHeroGameObjectOwner = null;
		super.stop();
	}
}
