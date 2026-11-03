package combat.weapon;

import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class ConsumableWeaponController extends WeaponController {
	var consumableWeapon:ConsumableWeaponGameObject;

	public function new(dbFacade:DBFacade, controlledWeapon:ConsumableWeaponGameObject, hero:HeroGameObjectOwner) {
		super(dbFacade, controlledWeapon, hero);
		consumableWeapon = controlledWeapon;
	}

	public function consume() {
		if (consumableWeapon.canExecute() && consumableWeapon.getConsumableAttack() != null && consumableWeapon.getConsumableCount() > 0) {
			attack(consumableWeapon.getConsumableAttack().Id, false, 1, consumableWeapon.getConsumableCount() > 1);
			consumableWeapon.consume();
		}
	}

	override function updateHudCooldown(showStartCooldown:Bool) {
		if (showStartCooldown) {
			mDBFacade.hud.startConsumableCooldown(weapon.slot, mCoolDownTime / 1000);
		} else {
			mDBFacade.hud.stopConsumableCooldown(weapon.slot);
		}
	}

	override public function destroy() {
		mDBFacade.hud.stopConsumableCooldown(weapon.slot);
		super.destroy();
	}
}
