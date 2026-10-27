package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class KnockbackImmunityTimeLineAction extends AttackTimelineAction {
	public static inline final TYPE = "knockbackImmunity";

	var mHeroGameObjectOwner:HeroGameObjectOwner;

	var mCanBeKnockedBack:Bool = false;

	var mCanBeKnockedBack_original:Bool = false;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, canBeKnockedBack:Bool) {
		super(actorGameObject, actorView, dbFacade);
		mHeroGameObjectOwner = null;
		mCanBeKnockedBack = canBeKnockedBack;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):KnockbackImmunityTimeLineAction {
		var _loc5_ = ASCompat.toBool(actionObj.value);
		return new KnockbackImmunityTimeLineAction(actorGameObject, actorView, dbFacade, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
		if (mHeroGameObjectOwner != null) {
			mCanBeKnockedBack_original = mHeroGameObjectOwner.canBeKnockedBack;
			mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack;
		}
	}

	override public function stop() {
		if (mHeroGameObjectOwner != null) {
			mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack_original;
		}
		mHeroGameObjectOwner = null;
		super.stop();
	}
}
