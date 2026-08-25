package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class LockAttackTimeLineAction extends AttackTimelineAction {
	public static inline final TYPE = "lockAttack";

	var mHeroGameObjectOwner:HeroGameObjectOwner;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
		mHeroGameObjectOwner = null;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade):LockAttackTimeLineAction {
		return new LockAttackTimeLineAction(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
		if (mHeroGameObjectOwner != null) {
			mHeroGameObjectOwner.canInitiateAnAttack = false;
		}
	}

	override public function stop() {
		if (mHeroGameObjectOwner != null) {
			mHeroGameObjectOwner.canInitiateAnAttack = true;
		}
		super.stop();
	}
}
