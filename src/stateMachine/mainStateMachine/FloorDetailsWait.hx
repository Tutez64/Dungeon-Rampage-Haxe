package stateMachine.mainStateMachine;

class FloorDetailsWait {
	public static inline final TIMEOUT_SECONDS:Float = 15;

	var mSchedule:ASFunction;

	var mCancel:ASFunction;

	var mOnDone:ASFunction;

	var mPending:Bool = false;

	var mTimeout:ASObject;

	public function new(schedule:ASFunction, cancel:ASFunction, onDone:ASFunction) {
		mSchedule = schedule;
		mCancel = cancel;
		mOnDone = onDone;
	}

	@:isVar public var pending(get, never):Bool;

	public function get_pending():Bool {
		return mPending;
	}

	public function begin() {
		cancelTimeout();
		mPending = true;
	}

	public function heroReady() {
		if (mPending && mTimeout == null) {
			mTimeout = mSchedule(15, timedOut);
		}
	}

	public function closureArrived() {
		finish(false);
	}

	public function stop() {
		cancelTimeout();
		mPending = false;
	}

	function cancelTimeout() {
		if (mTimeout != null) {
			mCancel(mTimeout);
			mTimeout = null;
		}
	}

	function timedOut(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		mTimeout = null;
		finish(true);
	}

	function finish(timedOut:Bool) {
		cancelTimeout();
		if (mPending) {
			mPending = false;
			mOnDone(timedOut);
		}
	}
}
