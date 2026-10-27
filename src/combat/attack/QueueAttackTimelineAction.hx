package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import combat.weapon.WeaponController;
import facade.DBFacade;

class QueueAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "queueAttack";

	var mWeaponController:WeaponController;

	var mAttackToQueue:String;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		mWeaponController = weaponController;
		mAttackToQueue = actionObj.attackName;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController,
			actionObj:ASObject):QueueAttackTimelineAction {
		if (actorGameObject.isOwner) {
			return new QueueAttackTimelineAction(actorGameObject, actorView, dbFacade, weaponController, actionObj);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mWeaponController.queueAttack(mAttackToQueue);
	}

	override public function destroy() {
		mWeaponController = null;
		super.destroy();
	}
}
