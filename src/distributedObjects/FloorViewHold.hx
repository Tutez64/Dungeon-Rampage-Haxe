package distributedObjects;

class FloorViewHold {
	public static inline final TIMEOUT_SECONDS:Float = 15;

	var mSchedule:ASFunction;

	var mCancel:ASFunction;

	var mOnRelease:ASFunction;

	var mHolding:Bool = false;

	var mHeroReady:Bool = false;

	var mClosureArrived:Bool = false;

	var mIntroPlaying:Bool = false;

	var mTimeout:ASObject;

	public function new(schedule:ASFunction, cancel:ASFunction, onRelease:ASFunction) {
		mSchedule = schedule;
		mCancel = cancel;
		mOnRelease = onRelease;
	}

	@:isVar public var holding(get, never):Bool;

	public function get_holding():Bool {
		return mHolding;
	}

	@:isVar public var heroIsReady(get, never):Bool;

	public function get_heroIsReady():Bool {
		return mHeroReady;
	}

	@:isVar public var closureHasArrived(get, never):Bool;

	public function get_closureHasArrived():Bool {
		return mClosureArrived;
	}

	public function begin() {
		cancelTimeout();
		mHolding = true;
		mHeroReady = false;
		mClosureArrived = false;
		mIntroPlaying = false;
		mTimeout = mSchedule(15, timedOut);
	}

	public function introStarted() {
		mIntroPlaying = true;
	}

	public function introEnded() {
		mIntroPlaying = false;
		if (mHolding) {
			cancelTimeout();
			mTimeout = mSchedule(15, timedOut);
		}
	}

	public function heroReady() {
		mHeroReady = true;
		releaseIfReady();
	}

	public function closureArrived() {
		mClosureArrived = true;
		releaseIfReady();
	}

	public function stop() {
		cancelTimeout();
		mHolding = false;
	}

	function releaseIfReady() {
		if (mHeroReady && mClosureArrived) {
			finish(false);
		}
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
		if (mIntroPlaying && mHolding) {
			mTimeout = mSchedule(15, timedOut);
			return;
		}
		finish(true);
	}

	function finish(timedOut:Bool) {
		cancelTimeout();
		if (mHolding) {
			mHolding = false;
			mOnRelease(timedOut);
		}
	}
}
