package steamInput;

import flash.display.Stage;
import flash.events.KeyboardEvent;

class KeyboardEventSpoofer {
	var mStageRef:Stage;

	var mKeyboardEventsSpoofMap:KeyboardEventsSpoofMap = new KeyboardEventsSpoofMap();

	var mPressedActions:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(stageRef:Stage) {
		mStageRef = stageRef;
	}

	public function update(steamInputManager:SteamInputManager) {
		var _loc2_:String;
		final __ax4_iter_90 = mKeyboardEventsSpoofMap.actionNames;
		if (checkNullIteratee(__ax4_iter_90))
			for (_tmp_ in __ax4_iter_90) {
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
		if (mPressedActions.exists(action)) {
			fireReleasedEvent(action);
			mPressedActions.remove(action);
		}
	}

	function handlePressedAction(action:String) {
		if (mPressedActions.exists(action)) {
			return;
		}
		mPressedActions[action] = true;
		firePressedEvent(action);
	}

	function fireReleasedEvent(action:String) {
		fireKeyboardEvent("keyUp", action);
	}

	function firePressedEvent(action:String) {
		fireKeyboardEvent("keyDown", action);
	}

	function fireKeyboardEvent(inputType:String, action:String) {
		var _loc3_ = mKeyboardEventsSpoofMap.getKeyCode(action);
		var _loc4_ = new KeyboardEvent(inputType, true, false, (0 : UInt), (_loc3_ : UInt));
		mStageRef.dispatchEvent(_loc4_);
	}
}
