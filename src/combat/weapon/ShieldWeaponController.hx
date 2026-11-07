package combat.weapon;

import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class ShieldWeaponController extends WeaponController {
	public function new(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner) {
		super(dbFacade, controlledWeapon, hero);
	}

	override public function onWeaponDown(autoAim:Bool = true) {
		var _loc2_ = (0 : UInt);
		if (!mWeaponDownActive) {
			_loc2_ = this.getNextAttackId();
			mWeaponDownActive = true;
			attack(_loc2_, false);
		}
	}

	override public function onWeaponUp(autoAim:Bool = true) {
		mWeaponDownActive = false;
		stopCurrentTimeline();
	}

	override public function canCombo():Bool {
		return true;
	}
}
