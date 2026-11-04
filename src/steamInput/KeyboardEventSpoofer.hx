package steamInput;

import input.keyBindings.KeyBindings;
import flash.display.Stage;
import flash.events.KeyboardEvent;

class KeyboardEventSpoofer {
	var mStageRef:Stage;

	var mKeyboardEventsSpoofMap:KeyboardEventsSpoofMap;

	var mPressedActions:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(stageRef:Stage, keyBindings:KeyBindings) {
		mStageRef = stageRef;
		mKeyboardEventsSpoofMap = new KeyboardEventsSpoofMap(keyBindings);
	}

	public function update(steamInputManager:SteamInputManager) {
		var _loc2_:String;
		final __ax4_iter_102 = mKeyboardEventsSpoofMap.actionNames;
		if (checkNullIteratee(__ax4_iter_102))
			for (_tmp_ in __ax4_iter_102) {
				_loc2_ = _tmp_;
				if (steamInputManager.releasedAction(_loc2_)) {
					handleReleasedAction(_loc2_);
				}
				if (steamInputManager.pressedAction(_loc2_)) {
					handlePressedAction(_loc2_);
				}
			}
	}

	function handleReleasedAction(action:String) {
		var _loc2_ = 0;
		if (mPressedActions.exists(action)) {
			_loc2_ = ASCompat.toInt(mPressedActions[action]);
			mPressedActions.remove(action);
			fireKeyboardEvent("keyUp", "UnboundActionEvent.RELEASED", action, _loc2_);
		}
	}

	function handlePressedAction(action:String) {
		if (mPressedActions.exists(action)) {
			return;
		}
		var _loc2_ = mKeyboardEventsSpoofMap.getKeyCode(action);
		mPressedActions[action] = _loc2_;
		fireKeyboardEvent("keyDown", "UnboundActionEvent.PRESSED", action, _loc2_);
	}

	function fireKeyboardEvent(inputType:String, unboundType:String, action:String, keyCode:Int) {
		if (keyCode == 0) {
			mStageRef.dispatchEvent(new UnboundActionEvent(unboundType, action));
			return;
		}
		var _loc5_ = new KeyboardEvent(inputType, true, false, (0 : UInt), (keyCode : UInt));
		mStageRef.dispatchEvent(_loc5_);
	}
}
