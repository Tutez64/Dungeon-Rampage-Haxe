package actor.player.input;

import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import steamInput.SteamInputManager;
import flash.geom.Vector3D;

class GamepadController {
	var mDBFacade:DBFacade;

	var mHeroOwner:HeroGameObjectOwner;

	var mSteamInputManager:SteamInputManager;

	var mCombatDisabled:Bool = false;

	var mMovementInput:Vector3D = new Vector3D();

	var mMovementVelocity:Vector3D = new Vector3D();

	var mInputHeading:Vector3D = new Vector3D();

	var mPressedCombatButtonsThisFrame:Vector<Int> = new Vector();

	var mReleasedCombatButtonsThisFrame:Vector<Int> = new Vector();

	var mReleasedConsumableButtonsThisFrame:Vector<Int> = new Vector();

	public function new(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner, steamInputManager:SteamInputManager) {
		mDBFacade = dbFacade;
		mHeroOwner = heroOwner;
		mSteamInputManager = steamInputManager;
		mCombatDisabled = false;
	}

	@:isVar public var inputVelocity(get, never):Vector3D;

	public function get_inputVelocity():Vector3D {
		return mMovementVelocity;
	}

	@:isVar public var inputHeading(get, never):Vector3D;

	public function get_inputHeading():Vector3D {
		return mInputHeading;
	}

	@:isVar public var pressedCombatButtonsThisFrame(get, never):Vector<Int>;

	public function get_pressedCombatButtonsThisFrame():Vector<Int> {
		return mPressedCombatButtonsThisFrame;
	}

	@:isVar public var releasedCombatButtonsThisFrame(get, never):Vector<Int>;

	public function get_releasedCombatButtonsThisFrame():Vector<Int> {
		return mReleasedCombatButtonsThisFrame;
	}

	@:isVar public var releasedConsumableButtonsThisFrame(get, never):Vector<Int>;

	public function get_releasedConsumableButtonsThisFrame():Vector<Int> {
		return mReleasedConsumableButtonsThisFrame;
	}

	public function init() {
		mPressedCombatButtonsThisFrame.length = 0;
		mReleasedCombatButtonsThisFrame.length = 0;
		mReleasedConsumableButtonsThisFrame.length = 0;
	}

	public function destroy() {
		mMovementVelocity = null;
		mInputHeading = null;
		mPressedCombatButtonsThisFrame.length = 0;
		mPressedCombatButtonsThisFrame = null;
		mReleasedCombatButtonsThisFrame.length = 0;
		mReleasedCombatButtonsThisFrame = null;
		mReleasedConsumableButtonsThisFrame.length = 0;
		mReleasedConsumableButtonsThisFrame = null;
	}

	@:isVar public var combatDisabled(never, set):Bool;

	public function set_combatDisabled(disableCombat:Bool):Bool {
		return mCombatDisabled = disableCombat;
	}

	public function perFrameUpCall() {
		updateMovement();
		updateCombatButtons();
	}

	function updateMovement() {
		mMovementInput = calcMovementInput();
		calcMovementVelocity(mMovementInput);
		updateInputHeading(mMovementInput);
	}

	function updateCombatButtons() {
		mPressedCombatButtonsThisFrame.length = 0;
		mReleasedCombatButtonsThisFrame.length = 0;
		if (mCombatDisabled) {
			return;
		}
		handleAttackInputs();
		handleConsumableInputs();
	}

	function calcMovementInput():Vector3D {
		var _loc1_ = mSteamInputManager.getAnalogAction("game_movement");
		_loc1_.y = -_loc1_.y;
		return _loc1_;
	}

	function calcMovementVelocity(movementInput:Vector3D) {
		var _loc3_ = mSteamInputManager.heldAction("hold_in_place");
		if (_loc3_) {
			mMovementVelocity.setTo(0, 0, 0);
			return;
		}
		mMovementVelocity.copyFrom(mMovementInput);
		var _loc2_ = mHeroOwner.movementSpeed;
		mMovementVelocity.scaleBy(_loc2_);
	}

	function updateInputHeading(movementInput:Vector3D) {
		mInputHeading.setTo(movementInput.x, movementInput.y, 0);
	}

	function handleAttackInputs() {
		checkWeaponButton(0, "attack_weapon_1");
		checkWeaponButton(1, "attack_weapon_2");
		checkWeaponButton(2, "attack_weapon_3");
		checkWeaponButton(3, "use_dungeon_buster");
	}

	function checkWeaponButton(index:Int, actionName:String) {
		var _loc3_ = mSteamInputManager.pressedAction(actionName);
		var _loc4_ = mSteamInputManager.releasedAction(actionName);
		if (_loc3_) {
			mPressedCombatButtonsThisFrame.push(index);
		}
		if (_loc4_) {
			mReleasedCombatButtonsThisFrame.push(index);
		}
	}

	function handleConsumableInputs() {
		mReleasedConsumableButtonsThisFrame.length = 0;
		var _loc1_ = mSteamInputManager.releasedAction("use_consumable_one");
		if (_loc1_) {
			mReleasedConsumableButtonsThisFrame.push(0);
		}
		var _loc2_ = mSteamInputManager.releasedAction("use_consumable_two");
		if (_loc2_) {
			mReleasedConsumableButtonsThisFrame.push(1);
		}
	}
}
