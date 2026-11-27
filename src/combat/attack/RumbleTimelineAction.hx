package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.logger.Logger;
import facade.DBFacade;
import steamInput.RumbleEffect;

class RumbleTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "rumbleEffect";

	var mRumbleEffect:RumbleEffect;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		if (parameterJson.intensity == null) {
			Logger.error("RumbleTimelineAction: Must specify intensity");
		}
		if (parameterJson.duration == null) {
			Logger.error("RumbleTimelineAction: Must specify duration");
		}
		mRumbleEffect = new RumbleEffect("AttackEffect", ASCompat.toNumberField(parameterJson, "intensity"),
			ASCompat.toNumberField(parameterJson, "intensity"), ASCompat.toNumberField(parameterJson, "duration"));
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:ASObject):RumbleTimelineAction {
		if (actorGameObject.isOwner) {
			return new RumbleTimelineAction(actorGameObject, actorView, dbFacade, parameterJson);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mDBFacade.steamInputManager.playRumble(mRumbleEffect);
	}

	override public function destroy() {
		mWorkComponent.destroy();
		mWorkComponent = null;
		super.destroy();
	}
}
