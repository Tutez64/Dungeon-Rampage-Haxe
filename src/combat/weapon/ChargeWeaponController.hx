package combat.weapon;

import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import flash.events.Event;

class ChargeWeaponController extends ScalingWeaponController {
	public static inline final CHARGE_ATTACK_EVENT = "CHARGE_ATTACK_EVENT";

	public function new(dbFacade:DBFacade, controlledWeapon:WeaponGameObject, hero:HeroGameObjectOwner) {
		super(dbFacade, controlledWeapon, hero);
	}

	override public function buildControllerAttacks() {
		super.buildControllerAttacks();
	}

	override public function setStartEffectTotalTime():Float {
		return 1.2;
	}

	override public function setTotalTime() {
		if (ASCompat.floatAsBool(mWeapon.weaponData.ControllerTimeTillEnd) && mWeapon.weaponData.ControllerTimeTillEnd > 0) {
			mTotalTime = mWeapon.weaponData.ControllerTimeTillEnd;
		} else {
			mTotalTime = mChargeReleaseGMAttack != null ? mChargeReleaseGMAttack.ChargeTime : 0;
		}
		mTotalTime *= mWeapon.chargeReduction();
	}

	override public function onWeaponUp(autoAim:Bool = true) {
		var _loc2_ = Math.NaN;
		if (!mDBFacade.dbAccountInfo.dbAccountParams.hasChargeTutorialParam() && !mTutorialMessageSent) {
			mDBFacade.eventManager.dispatchEvent(new Event("CHARGE_ATTACK_EVENT"));
			mTutorialMessageSent = true;
		}
		if (mHoldingAttackTimeline != null && mHoldingAttackTimeline.isPlaying) {
			mHoldingAttackTimeline.stopAndFinish();
		}
		if (!mPlayerExittedState) {
			if (mTotalTime > 0 && mNotEnoughManaTask == null) {
				_loc2_ = mFramesFinished / 24 * 1 / mTotalTime;
				if (_loc2_ > 1) {
					_loc2_ = 1;
				}
				if (_loc2_ == 1 && mChargeReleaseGMAttack != null) {
					attack(mChargeReleaseGMAttack.Id, mAutoAim);
				} else {
					attack(getNextAttackId(), mAutoAim);
				}
			} else {
				attack(getNextAttackId(), mAutoAim);
			}
		}
		clear();
	}

	override public function destroy() {
		super.destroy();
		if (mNotEnoughManaTask != null) {
			mNotEnoughManaTask.destroy();
			mNotEnoughManaTask = null;
		}
	}
}
