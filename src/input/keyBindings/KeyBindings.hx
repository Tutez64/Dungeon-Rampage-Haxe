package input.keyBindings;

import brain.input.InputManager;
import brain.logger.Logger;

class KeyBindings {
	public static inline final NONE = 0;

	var mInputManager:InputManager;

	var mPrimary:ASObject;

	var mAlternate:ASObject;

	var mChangeListeners:Vector<ASFunction>;

	public function new(inputManager:InputManager) {
		mInputManager = inputManager;
		mPrimary = {};
		mAlternate = {};
		mChangeListeners = new Vector<ASFunction>();
		var _loc2_:String;
		final __ax4_iter_405 = InputAction.ORDERED;
		if (checkNullIteratee(__ax4_iter_405))
			for (_tmp_ in __ax4_iter_405) {
				_loc2_ = _tmp_;
				resetToDefault(_loc2_);
			}
	}

	public static function isBindable(keyCode:Int):Bool {
		if (keyCode <= 0 || keyCode >= 256) {
			return false;
		}
		return keyCode != 27 && keyCode != 13 && keyCode != 119 && keyCode != 122;
	}

	static function checkKey(keyCode:Int, query:ASFunction):Bool {
		return keyCode != 0 && ASCompat.toBool(query(keyCode));
	}

	public function destroy() {
		mInputManager = null;
		mPrimary = null;
		mAlternate = null;
		mChangeListeners = null;
	}

	public function addChangeListener(listener:ASFunction) {
		if (mChangeListeners.indexOf(listener) == -1) {
			mChangeListeners.push(listener);
		}
	}

	public function removeChangeListener(listener:ASFunction) {
		if (mChangeListeners == null) {
			return;
		}
		var _loc2_ = mChangeListeners.indexOf(listener);
		if (_loc2_ != -1) {
			mChangeListeners.splice(_loc2_, (1 : UInt));
		}
	}

	public function getPrimary(action:String):Int {
		return mPrimary.hasOwnProperty(action) ? ASCompat.toInt(mPrimary[action]) : 0;
	}

	public function getAlternate(action:String):Int {
		return mAlternate.hasOwnProperty(action) ? ASCompat.toInt(mAlternate[action]) : 0;
	}

	public function setBinding(action:String, primary:Int, alternate:Int) {
		if (!InputAction.isKnown(action)) {
			Logger.warn("Tried to bind unknown input action: " + action);
			return;
		}
		var _loc5_ = isBindable(primary) ? primary : 0;
		var _loc4_ = isBindable(alternate) ? alternate : 0;
		if (getPrimary(action) == _loc5_ && getAlternate(action) == _loc4_) {
			return;
		}
		mPrimary[action] = _loc5_;
		mAlternate[action] = _loc4_;
		notifyChanged(action);
	}

	public function resetToDefault(action:String) {
		setBinding(action, InputAction.defaultPrimary(action), InputAction.defaultAlternate(action));
	}

	public function isDown(action:String):Bool {
		return checkKey(getPrimary(action), mInputManager.check)
			|| checkKey(getAlternate(action), mInputManager.check)
			|| checkKey(activeLegacyAlias(action), mInputManager.check);
	}

	public function wasPressed(action:String):Bool {
		return checkKey(getPrimary(action), mInputManager.pressed)
			|| checkKey(getAlternate(action), mInputManager.pressed)
			|| checkKey(activeLegacyAlias(action), mInputManager.pressed);
	}

	public function wasReleased(action:String):Bool {
		return checkKey(getPrimary(action), mInputManager.released)
			|| checkKey(getAlternate(action), mInputManager.released)
			|| checkKey(activeLegacyAlias(action), mInputManager.released);
	}

	public function matches(action:String, keyCode:Int):Bool {
		if (keyCode == 0) {
			return false;
		}
		return getPrimary(action) == keyCode || getAlternate(action) == keyCode || activeLegacyAlias(action) == keyCode;
	}

	public function actionForKey(keyCode:Int):String {
		if (keyCode == 0) {
			return null;
		}
		var _loc2_:String;
		final __ax4_iter_406 = InputAction.ORDERED;
		if (checkNullIteratee(__ax4_iter_406))
			for (_tmp_ in __ax4_iter_406) {
				_loc2_ = _tmp_;
				if (matches(_loc2_, keyCode)) {
					return _loc2_;
				}
			}
		return null;
	}

	public function displayNameFor(action:String):String {
		var _loc2_ = getPrimary(action);
		if (_loc2_ == 0) {
			_loc2_ = getAlternate(action);
		}
		return KeyNames.displayName(_loc2_);
	}

	function activeLegacyAlias(action:String):Int {
		var _loc3_ = InputAction.legacyAlias(action);
		if (_loc3_ == 0) {
			return 0;
		}
		if (getPrimary(action) != InputAction.defaultPrimary(action) || getAlternate(action) != InputAction.defaultAlternate(action)) {
			return 0;
		}
		var _loc2_:String;
		final __ax4_iter_407 = InputAction.ORDERED;
		if (checkNullIteratee(__ax4_iter_407))
			for (_tmp_ in __ax4_iter_407) {
				_loc2_ = _tmp_;
				if (getPrimary(_loc2_) == _loc3_ || getAlternate(_loc2_) == _loc3_) {
					return 0;
				}
			}
		return _loc3_;
	}

	function notifyChanged(action:String) {
		if (mChangeListeners == null) {
			return;
		}
		var _loc2_ = mChangeListeners.concat();
		var _loc3_:ASFunction;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = _tmp_;
				_loc3_(action);
			}
	}
}
