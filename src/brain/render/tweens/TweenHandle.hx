package brain.render.tweens;

import starling.animation.DelayedCall;
import starling.animation.IAnimatable;
import starling.animation.Juggler;
import starling.animation.Tween;
import starling.events.EventDispatcher;

class TweenHandle extends EventDispatcher implements IAnimatable {
	static inline final COMPLETION_EPSILON:Float = 0.0001;

	var mPrimary:IAnimatable;

	var mSideTweens:Vector<Tween>;

	var mTarget:ASObject;

	var mDelay:Float = 0;

	var mFixedSpan:Float = 0;

	var mTime:Float = 0;

	var mPaused:Bool = false;

	var mReversed:Bool = false;

	var mKilled:Bool = false;

	var mFinished:Bool = false;

	var mCompletionPending:Bool = false;

	var mJuggler:Juggler;

	@:allow(brain.render.tweens) var parentTimeline:TweenTimeline;

	@:allow(brain.render.tweens) var onFinished:ASFunction;

	var mCompleteHooks:Vector<ASFunction>;

	var mKillHooks:Vector<ASFunction>;

	var mUserOnStart:ASFunction;

	var mUserOnStartArgs:Array<ASAny>;

	var mUserOnUpdate:ASFunction;

	var mUserOnUpdateArgs:Array<ASAny>;

	var mUserOnComplete:ASFunction;

	var mUserOnCompleteArgs:Array<ASAny>;

	public function new(primary:IAnimatable, target:ASObject = null) {
		super();
		mPrimary = primary;
		mTarget = target;
		var _loc3_ = ASCompat.reinterpretAs(primary, Tween);
		if (_loc3_ != null) {
			_loc3_.onStart = handleStart;
			_loc3_.onUpdate = handleUpdate;
			_loc3_.onComplete = handleComplete;
		}
	}

	@:allow(brain.render.tweens) function addSideTween(tween:Tween) {
		if (mSideTweens == null) {
			mSideTweens = new Vector<Tween>((0 : UInt));
		}
		mSideTweens.push(tween);
	}

	@:allow(brain.render.tweens) function refreshSpan() {
		var _loc2_ = ASCompat.reinterpretAs(mPrimary, Tween);
		var _loc1_ = ASCompat.reinterpretAs(mPrimary, DelayedCall);
		if (_loc2_ != null) {
			mDelay = _loc2_.delay;
			if (_loc2_.repeatCount == 0) {
				mFixedSpan = Math.POSITIVE_INFINITY;
			} else {
				mFixedSpan = _loc2_.delay + _loc2_.totalTime * _loc2_.repeatCount + _loc2_.repeatDelay * (_loc2_.repeatCount - 1);
			}
		} else if (_loc1_ != null) {
			mDelay = 0;
			mFixedSpan = _loc1_.totalTime;
		}
	}

	@:allow(brain.render.tweens) function setCallbacks(onStart:ASFunction, onStartArgs:Array<ASAny>, onUpdate:ASFunction, onUpdateArgs:Array<ASAny>,
			onComplete:ASFunction, onCompleteArgs:Array<ASAny>) {
		mUserOnStart = onStart;
		mUserOnStartArgs = onStartArgs;
		mUserOnUpdate = onUpdate;
		mUserOnUpdateArgs = onUpdateArgs;
		mUserOnComplete = onComplete;
		mUserOnCompleteArgs = onCompleteArgs;
	}

	@:allow(brain.render.tweens) function addCompleteHook(hook:ASFunction) {
		if (mCompleteHooks == null) {
			mCompleteHooks = new Vector<ASFunction>((0 : UInt));
		}
		mCompleteHooks.push(hook);
	}

	@:allow(brain.render.tweens) function addKillHook(hook:ASFunction) {
		if (mKillHooks == null) {
			mKillHooks = new Vector<ASFunction>((0 : UInt));
		}
		mKillHooks.push(hook);
	}

	@:allow(brain.render.tweens) function attachToJuggler(juggler:Juggler) {
		if (mKilled || mFinished) {
			return;
		}
		mJuggler = juggler;
		juggler.add(this);
	}

	@:allow(brain.render.tweens) function detachFromJuggler() {
		if (mJuggler != null) {
			mJuggler.remove(this);
			mJuggler = null;
		}
	}

	@:allow(brain.render.tweens) @:isVar var timeline(get, never):TweenTimeline;

	function get_timeline():TweenTimeline {
		return ASCompat.reinterpretAs(mPrimary, TweenTimeline);
	}

	public function advanceTime(time:Float) {
		var _loc2_:Tween;
		var __ax4_iter_422:Vector<Tween>;
		if (mKilled || mFinished || mPaused || time == 0) {
			return;
		}
		if (mReversed) {
			time = -time;
		}
		var _loc4_ = totalSpan;
		var _loc3_ = mTime + time;
		if (_loc3_ < 0) {
			_loc3_ = 0;
		}
		if (_loc3_ > _loc4_) {
			_loc3_ = _loc4_;
		}
		mTime = _loc3_;
		mCompletionPending = false;
		mPrimary.advanceTime(time);
		if (mSideTweens != null) {
			__ax4_iter_422 = mSideTweens;
			if (checkNullIteratee(__ax4_iter_422))
				for (_tmp_ in __ax4_iter_422) {
					_loc2_ = _tmp_;
					_loc2_.advanceTime(time);
				}
		}
		if (mCompletionPending) {
			mCompletionPending = false;
			executeComplete();
		}
		if (!mKilled && !mFinished && time > 0 && isInnerComplete) {
			finish();
		}
	}

	public function play() {
		mReversed = false;
		mPaused = false;
	}

	public function pause() {
		mPaused = true;
	}

	public function resume() {
		mPaused = false;
	}

	public function reverse() {
		mReversed = true;
		mPaused = false;
	}

	public function complete() {
		if (mKilled || mFinished) {
			return;
		}
		var _loc1_ = totalSpan;
		if (!Math.isFinite(_loc1_)) {
			return;
		}
		mReversed = false;
		mPaused = false;
		advanceTime(_loc1_ - mTime + 0.0001);
	}

	public function kill() {
		var _loc1_:ASFunction;
		var __ax4_iter_423:Vector<ASFunction>;
		if (mKilled) {
			return;
		}
		mKilled = true;
		detachFromJuggler();
		if (parentTimeline != null) {
			parentTimeline.removeChild(this);
			parentTimeline = null;
		}
		if (timeline != null) {
			timeline.killChildren();
		}
		if (mKillHooks != null) {
			__ax4_iter_423 = mKillHooks;
			if (checkNullIteratee(__ax4_iter_423))
				for (_tmp_ in __ax4_iter_423) {
					_loc1_ = _tmp_;
					_loc1_();
				}
		}
		notifyFinished();
	}

	@:isVar public var totalSpan(get, never):Float;

	public function get_totalSpan():Float {
		var _loc1_ = timeline;
		return _loc1_ != null ? _loc1_.duration : mFixedSpan;
	}

	@:isVar public var currentTime(get, never):Float;

	public function get_currentTime():Float {
		return mTime;
	}

	@:isVar public var progress(get, never):Float;

	public function get_progress():Float {
		var _loc2_ = totalSpan;
		if (!Math.isFinite(_loc2_)) {
			return 0;
		}
		var _loc1_ = _loc2_ - mDelay;
		if (_loc1_ <= 0) {
			return mFinished || mTime >= _loc2_ ? 1 : 0;
		}
		var _loc3_ = (mTime - mDelay) / _loc1_;
		return _loc3_ < 0 ? 0 : (_loc3_ > 1 ? 1 : _loc3_);
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return mFinished;
	}

	@:isVar public var isKilled(get, never):Bool;

	public function get_isKilled():Bool {
		return mKilled;
	}

	@:isVar public var target(get, never):ASObject;

	public function get_target():ASObject {
		return mTarget;
	}

	@:isVar public var delayedCallback(get, never):ASFunction;

	public function get_delayedCallback():ASFunction {
		var _loc1_ = ASCompat.reinterpretAs(mPrimary, DelayedCall);
		return ASCompat.coerceFunction(_loc1_ != null ? _loc1_.callback : null);
	}

	@:isVar var isInnerComplete(get, never):Bool;

	function get_isInnerComplete():Bool {
		var _loc2_ = ASCompat.reinterpretAs(mPrimary, Tween);
		if (_loc2_ != null) {
			return _loc2_.isComplete;
		}
		var _loc1_ = ASCompat.reinterpretAs(mPrimary, DelayedCall);
		if (_loc1_ != null) {
			return _loc1_.isComplete;
		}
		var _loc3_ = ASCompat.reinterpretAs(mPrimary, TweenTimeline);
		return _loc3_ != null ? _loc3_.isComplete : true;
	}

	function finish() {
		mFinished = true;
		dispatchEventWith("removeFromJuggler");
		mJuggler = null;
		notifyFinished();
	}

	function notifyFinished() {
		var _loc1_:ASFunction = null;
		if (onFinished != null) {
			_loc1_ = onFinished;
			onFinished = null;
			_loc1_(this);
		}
	}

	function handleStart() {
		if (mUserOnStart != null) {
			ASCompatMacro.applyClosure(mUserOnStart, mUserOnStartArgs);
		}
	}

	function handleUpdate() {
		if (mUserOnUpdate != null) {
			ASCompatMacro.applyClosure(mUserOnUpdate, mUserOnUpdateArgs);
		}
	}

	function handleComplete() {
		mCompletionPending = true;
	}

	function executeComplete() {
		var _loc1_:ASFunction;
		var __ax4_iter_424:Vector<ASFunction>;
		if (mCompleteHooks != null) {
			__ax4_iter_424 = mCompleteHooks;
			if (checkNullIteratee(__ax4_iter_424))
				for (_tmp_ in __ax4_iter_424) {
					_loc1_ = _tmp_;
					_loc1_();
				}
		}
		if (mUserOnComplete != null) {
			ASCompatMacro.applyClosure(mUserOnComplete, mUserOnCompleteArgs);
		}
	}
}
