package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;
import gameMasterDictionary.GMActor;

class HideTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "visible";

	var value:Bool = false;

	var persist:Bool = false;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		value = ASCompat.toBool(actionObj.value);
		persist = actionObj.persist == true;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):HideTimelineAction {
		return new HideTimelineAction(actorGameObject, actorView, dbFacade, actionObj);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mActorGameObject.cancelPersistentHideWatch();
		mActorGameObject.view.root.visible = value;
	}

	override public function stop() {
		if (isDeadProp()) {
			return;
		}
		if (persist && mActorGameObject.hitPoints != 0 && mTimeline != null && mTimeline.finishedNaturally) {
			mActorGameObject.notePersistentHide();
			return;
		}
		mActorGameObject.cancelPersistentHideWatch();
		mActorGameObject.view.root.visible = true;
	}

	function isDeadProp():Bool {
		if (mActorGameObject.hitPoints != 0) {
			return false;
		}
		if (mActorGameObject.actorData == null || mActorGameObject.actorData.gMActor == null) {
			return false;
		}
		return mActorGameObject.actorData.gMActor.CharType == GMActor.CHAR_TYPE_PROP;
	}
}
