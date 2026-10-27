package combat.attack;

import actor.ActorView;
import brain.logger.Logger;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class InputTypeTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "inputType";

	var mHeroGameObjectOwner:HeroGameObjectOwner;

	var mInputType:String;

	public function new(heroOwner:HeroGameObjectOwner, actorView:ActorView, dbFacade:DBFacade, inputType:String) {
		super(heroOwner, actorView, dbFacade);
		mHeroGameObjectOwner = heroOwner;
		mInputType = inputType;
		if (mHeroGameObjectOwner == null) {
			Logger.error("ActorGameObject passed into InputTypeTimelineAction is not a HeroGameObjectOwner.");
		}
	}

	public static function buildFromJson(heroOwner:HeroGameObjectOwner, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):InputTypeTimelineAction {
		var _loc5_:String = actionObj.inputType;
		return new InputTypeTimelineAction(heroOwner, actorView, dbFacade, _loc5_);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mHeroGameObjectOwner.inputController.inputType = mInputType;
	}

	override public function stop() {
		super.stop();
		if (mHeroGameObjectOwner != null && mHeroGameObjectOwner.inputController != null) {
			mHeroGameObjectOwner.inputController.inputType = "free";
		}
	}

	override public function destroy() {
		super.destroy();
		if (mHeroGameObjectOwner != null && mHeroGameObjectOwner.inputController != null) {
			mHeroGameObjectOwner.inputController.inputType = "free";
		}
	}
}
