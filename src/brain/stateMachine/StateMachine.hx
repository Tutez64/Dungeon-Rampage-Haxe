package brain.stateMachine;

import brain.logger.Logger;

class StateMachine {
	var mCurrentState:State;

	public function new() {}

	@:isVar public var currentState(get, set):State;

	public function get_currentState():State {
		return mCurrentState;
	}

	function set_currentState(state:State):State {
		return mCurrentState = state;
	}

	@:isVar public var currentStateName(get, never):String;

	public function get_currentStateName():String {
		if (mCurrentState != null) {
			return mCurrentState.name;
		}
		return "";
	}

	public function transitionToState(nextState:State):Bool {
		if (mCurrentState != null) {
			if (!mCurrentState.running) {
				Logger.warn("transitionToState (" + nextState.name + ") but old state (" + mCurrentState.name + ") was not running.");
			}
			#if cpp
			modding.Host.stateExited(this, mCurrentState);
			#end
			mCurrentState.exitState();
		}
		mCurrentState = nextState;
		mCurrentState.enterState();
		#if cpp
		modding.Host.stateEntered(this, mCurrentState);
		#end
		return true;
	}

	public function destroy() {
		if (mCurrentState != null && mCurrentState.running) {
			#if cpp
			modding.Host.stateExited(this, mCurrentState);
			#end
			mCurrentState.exitState();
		}
		mCurrentState = null;
	}
}
