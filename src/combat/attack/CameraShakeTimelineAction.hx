package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.logger.Logger;
import facade.DBFacade;

class CameraShakeTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "shake";

	var mDuration:Float = 0;

	var mNumShakes:UInt = (0 : UInt);

	var mRotation:Float = 0;

	var mX:Float = 0;

	var mY:Float = 0;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		if (parameterJson.duration == null) {
			Logger.error("CameraShakeTimelineAction: Must specify duration");
		}
		if (parameterJson.numShakes == null) {
			Logger.error("CameraShakeTimelineAction: Must specify numShakes");
		}
		if (parameterJson.rotation == null && parameterJson.x == null && parameterJson.y == null) {
			Logger.error("CameraShakeTimelineAction: Must specify at least one of rotation, x, or y");
		}
		var _loc5_ = (24 : UInt);
		mDuration = ASCompat.toNumberField(parameterJson, "duration") / _loc5_;
		mNumShakes = (ASCompat.toInt(parameterJson.numShakes) : UInt);
		mRotation = ASCompat.toNumberField(parameterJson, "rotation");
		mX = ASCompat.toNumberField(parameterJson, "x");
		mY = ASCompat.toNumberField(parameterJson, "y");
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			parameterJson:ASObject):CameraShakeTimelineAction {
		if (actorGameObject.isOwner || actorGameObject.actorData.gMActor.CanShakeCamera) {
			return new CameraShakeTimelineAction(actorGameObject, actorView, dbFacade, parameterJson);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (mDBFacade.featureFlags.getFlagValue("want-zoom")) {
			if (ASCompat.floatAsBool(mRotation)) {
				this.mDBFacade.camera.shakeRotation(mDuration, mRotation, mNumShakes);
			}
			if (ASCompat.floatAsBool(mX)) {
				this.mDBFacade.camera.shakeX(mDuration, mX, mNumShakes);
			}
			if (ASCompat.floatAsBool(mY)) {
				this.mDBFacade.camera.shakeY(mDuration, mY, mNumShakes);
			}
		}
	}

	override public function destroy() {
		super.destroy();
	}
}
