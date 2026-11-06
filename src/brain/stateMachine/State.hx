package brain.stateMachine;

class State {
	var mName:String = "";

	var mFinishedCallback:ASFunction;

	var mRunning:Bool = false;

	public function new(stateName:String, finishedCallback:ASFunction = null) {
		mName = stateName;
		mFinishedCallback = finishedCallback;
	}

	@:isVar public var running(get, never):Bool;

	public function get_running():Bool {
		return mRunning;
	}

	@:isVar public var finishedCallback(never, set):ASFunction;

	public function set_finishedCallback(callback:ASFunction):ASFunction {
		return mFinishedCallback = callback;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return mName;
	}

	public function enterState() {
		mRunning = true;
	}

	public function exitState() {
		mRunning = false;
	}

	public function destroy() {
		mFinishedCallback = null;
		mRunning = false;
	}
}
