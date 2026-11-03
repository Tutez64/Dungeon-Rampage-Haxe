package combat.attack;

import combat.weapon.WeaponController;

class PotentialWeaponInputQueueStruct {
	var mWeaponController:WeaponController;

	var mDown:Bool = false;

	var mWeaponIndex:UInt = 0;

	var mAutoAim:Bool = false;

	public function new(weaponController:WeaponController, weaponIndex:UInt, down:Bool, autoAim:Bool = true) {
		mWeaponController = weaponController;
		mWeaponIndex = weaponIndex;
		mDown = down;
		mAutoAim = autoAim;
	}

	@:isVar public var down(get, never):Bool;

	public function get_down():Bool {
		return mDown;
	}

	@:isVar public var weaponController(get, never):WeaponController;

	public function get_weaponController():WeaponController {
		return mWeaponController;
	}

	@:isVar public var weaponIndex(get, never):UInt;

	public function get_weaponIndex():UInt {
		return mWeaponIndex;
	}

	@:isVar public var autoAim(get, never):Bool;

	public function get_autoAim():Bool {
		return mAutoAim;
	}
}
