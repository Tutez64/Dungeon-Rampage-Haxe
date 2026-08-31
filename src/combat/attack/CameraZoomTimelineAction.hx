package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.Task;
import facade.DBFacade;

class CameraZoomTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "zoom";

	var mTask:Task;

	var mDuration:Float = 0;

	var mZoomFactor:Float = 1;

	var mLerpInDuration:Float = 0;

	var mLerpOutDuration:Float = 0;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		if (parameterJson.duration == null) {
			Logger.error("CameraZoomTimelineAction: Must specify duration");
		}
		if (parameterJson.zoomFactor == null) {
			Logger.error("CameraZoomTimelineAction: Must specify zoomFactor");
		}
		var _loc5_ = (24 : UInt);
		mDuration = ASCompat.toNumberField(parameterJson, "duration") / _loc5_;
		mZoomFactor = ASCompat.toNumberField(parameterJson, "zoomFactor");
		mLerpInDuration = parameterJson.lerpInDuration != null ? ASCompat.toNumberField(parameterJson, "lerpInDuration") / _loc5_ : 0;
		mLerpOutDuration = parameterJson.lerpOutDuration != null ? ASCompat.toNumberField(parameterJson, "lerpOutDuration") / _loc5_ : 0;
		if (mDuration < mLerpInDuration + mLerpOutDuration) {
			Logger.error("CameraZoomTimelineAction: duration must be >= lerp in + lerp out");
			mDuration = mLerpInDuration + mLerpOutDuration;
		}
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			parameterJson:ASObject):CameraZoomTimelineAction {
		if (actorGameObject.isOwner) {
			return new CameraZoomTimelineAction(actorGameObject, actorView, dbFacade, parameterJson);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (mLerpInDuration > 0) {
			this.mDBFacade.camera.tweenZoom(mLerpInDuration, mZoomFactor);
		} else {
			this.mDBFacade.camera.zoom = mZoomFactor;
		}
		mTask = mWorkComponent.doLater(mDuration - mLerpOutDuration, resetZoom);
	}

	function resetZoom(gameClock:GameClock) {
		if (mLerpOutDuration > 0) {
			this.mDBFacade.camera.tweenToDefaultZoom(mLerpOutDuration);
		} else {
			this.mDBFacade.camera.zoom = this.mDBFacade.camera.defaultZoom;
		}
	}

	override public function destroy() {
		mWorkComponent.destroy();
		mWorkComponent = null;
		super.destroy();
	}
}
