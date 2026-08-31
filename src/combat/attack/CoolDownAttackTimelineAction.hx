package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import combat.weapon.WeaponController;
import facade.DBFacade;

class CoolDownAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "startCooldown";

	var mWeaponController:WeaponController;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController, actionObj:ASObject) {
		super(actorGameObject, actorView, dbFacade);
		mWeaponController = weaponController;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, weaponController:WeaponController,
			actionObj:ASObject):CoolDownAttackTimelineAction {
		if (actorGameObject.isOwner) {
			return new CoolDownAttackTimelineAction(actorGameObject, actorView, dbFacade, weaponController, actionObj);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		mWeaponController.startCooldown();
	}

	override public function destroy() {
		mWeaponController = null;
		super.destroy();
	}
}
