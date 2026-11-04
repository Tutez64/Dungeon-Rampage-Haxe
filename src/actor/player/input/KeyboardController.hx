package actor.player.input;

import brain.logger.Logger;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import input.keyBindings.InputAction;
import input.keyBindings.KeyBindings;
import flash.geom.Vector3D;

class KeyboardController {
	static inline final MENU_INDEX_EXIT = 0;

	static inline final MENU_INDEX_OPEN_OPTIONS_MENU = 1;

	static inline final MENU_INDEX_TOGGLE_CHAT_LOG = 2;

	static inline final MENU_INDEX_CHAT_INPUT = 3;

	static inline final MENU_INDEX_COUNT = 4;

	var mDBFacade:DBFacade;

	var mHeroOwner:HeroGameObjectOwner;

	var mKeyBindings:KeyBindings;

	var mInputVector:Vector3D;

	var mMovementVelocity:Vector3D;

	var mInputHeading:Vector3D;

	var mPressedCombatKeysThisFrame:Vector<Int>;

	var mReleasedCombatKeysThisFrame:Vector<Int>;

	var mReleasedConsumableKeysThisFrame:Vector<Int>;

	var mReleasedMenuKeysThisFrame:Vector<Int>;

	var mCombatDisabled:Bool = false;

	public function new(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner) {
		mDBFacade = dbFacade;
		mHeroOwner = heroOwner;
		mKeyBindings = dbFacade.keyBindings;
		mMovementVelocity = new Vector3D();
		mInputHeading = new Vector3D();
		mPressedCombatKeysThisFrame = new Vector<Int>();
		mReleasedCombatKeysThisFrame = new Vector<Int>();
		mReleasedConsumableKeysThisFrame = new Vector<Int>();
		mReleasedMenuKeysThisFrame = new Vector<Int>();
		mCombatDisabled = false;
	}

	public function perFrameUpCall() {
		getInputDirectionVector();
		checkCombatButtons();
		determineMotion();
		checkForDebugIdentifyTile();
	}

	function checkForDebugIdentifyTile() {
		if (mDBFacade.inputManager.pressed(73)) {
			Logger.warn("[ DEBUG ] Tile ID is : " + mHeroOwner.distributedDungeonFloor.GetTileIdWhichAvatarIsOn());
		}
	}

	function getInputDirectionVector() {
		mInputVector = new Vector3D();
		if (mKeyBindings.isDown("moveUp")) {
			mInputVector.y -= 1;
		}
		if (mKeyBindings.isDown("moveDown")) {
			mInputVector.y += 1;
		}
		if (mKeyBindings.isDown("moveRight")) {
			mInputVector.x += 1;
		}
		if (mKeyBindings.isDown("moveLeft")) {
			mInputVector.x -= 1;
		}
		mInputVector.normalize();
	}

	@:isVar public var combatDisabled(never, set):Bool;

	public function set_combatDisabled(disableCombat:Bool):Bool {
		return mCombatDisabled = disableCombat;
	}

	function checkCombatButtons() {
		var _loc1_:String;
		var __ax4_iter_426:Vector<String>;
		if (!mCombatDisabled) {
			mReleasedCombatKeysThisFrame = new Vector<Int>();
			mPressedCombatKeysThisFrame = new Vector<Int>();
			__ax4_iter_426 = InputAction.ATTACK_SLOTS;
			if (checkNullIteratee(__ax4_iter_426))
				for (_tmp_ in __ax4_iter_426) {
					_loc1_ = _tmp_;
					mPressedCombatKeysThisFrame.push(ASCompat.toInt(mKeyBindings.isDown(_loc1_)));
					mReleasedCombatKeysThisFrame.push(ASCompat.toInt(mKeyBindings.wasReleased(_loc1_)));
				}
		}
		mReleasedConsumableKeysThisFrame = new Vector<Int>();
		var _loc2_:String;
		final __ax4_iter_427 = InputAction.CONSUMABLE_SLOTS;
		if (checkNullIteratee(__ax4_iter_427))
			for (_tmp_ in __ax4_iter_427) {
				_loc2_ = _tmp_;
				mReleasedConsumableKeysThisFrame.push(ASCompat.toInt(mKeyBindings.wasReleased(_loc2_)));
			}
		mReleasedMenuKeysThisFrame = new Vector<Int>((4 : UInt));
		mReleasedMenuKeysThisFrame[0] = ASCompat.toInt(mDBFacade.inputManager.released(27));
		mReleasedMenuKeysThisFrame[1] = ASCompat.toInt(mKeyBindings.wasReleased("openOptionsMenu"));
		mReleasedMenuKeysThisFrame[2] = ASCompat.toInt(mKeyBindings.wasReleased("toggleChatLog"));
		mReleasedMenuKeysThisFrame[3] = ASCompat.toInt(mDBFacade.inputManager.released(13));
	}

	public function determineMotion() {
		mMovementVelocity.copyFrom(mInputVector);
		var _loc1_ = mHeroOwner.movementSpeed;
		mMovementVelocity.scaleBy(_loc1_);
		mInputHeading.copyFrom(mInputVector);
	}

	@:isVar public var inputVelocity(get, never):Vector3D;

	public function get_inputVelocity():Vector3D {
		return mMovementVelocity;
	}

	@:isVar public var inputHeading(get, never):Vector3D;

	public function get_inputHeading():Vector3D {
		return mInputHeading;
	}

	@:isVar public var pressedCombatKeysThisFrame(get, never):Vector<Int>;

	public function get_pressedCombatKeysThisFrame():Vector<Int> {
		return mPressedCombatKeysThisFrame;
	}

	@:isVar public var releasedCombatKeysThisFrame(get, never):Vector<Int>;

	public function get_releasedCombatKeysThisFrame():Vector<Int> {
		return mReleasedCombatKeysThisFrame;
	}

	@:isVar public var releasedConsumableKeysThisFrame(get, never):Vector<Int>;

	public function get_releasedConsumableKeysThisFrame():Vector<Int> {
		return mReleasedConsumableKeysThisFrame;
	}

	@:isVar public var releasedMenuKeysThisFrame(get, never):Vector<Int>;

	public function get_releasedMenuKeysThisFrame():Vector<Int> {
		return mReleasedMenuKeysThisFrame;
	}

	public function destroy() {
		mKeyBindings = null;
	}
}
