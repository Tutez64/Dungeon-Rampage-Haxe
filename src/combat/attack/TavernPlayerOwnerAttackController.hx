package combat.attack;

import actor.player.HeroView;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class TavernPlayerOwnerAttackController extends PlayerOwnerAttackController {
	public function new(distributedPlayerOwner:HeroGameObjectOwner, heroView:HeroView, dbFacade:DBFacade) {
		super(distributedPlayerOwner, heroView, dbFacade);
	}

	override function canQueueWeaponDown(weaponQueue:PotentialWeaponInputQueueStruct):Bool {
		return true;
	}

	override function canQueueWeaponUp(weaponQueue:PotentialWeaponInputQueueStruct):Bool {
		return true;
	}

	override function tryAttack() {
		if (mNextWeaponCommand == null) {
			return;
		}
		mDistributedPlayerOwner.currentWeaponIndex = (mNextWeaponCommand.weaponIndex : Int);
		mNextWeaponCommand = null;
	}
}
