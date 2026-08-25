package com.greensock.core;

import com.greensock.*;

class TweenCore {
	static var _classInitted:Bool = false;

	public static inline final version:Float = 1.64;

	public var initted:Bool = false;

	var _hasUpdate:Bool = false;

	public var active:Bool = false;

	var _delay:Float = Math.NaN;

	public var cachedReversed:Bool = false;

	public var nextNode:TweenCore;

	public var cachedTime:Float = Math.NaN;

	var _rawPrevTime:Float = -1;

	public var vars:ASObject;

	public var cachedTotalTime:Float = Math.NaN;

	public var data:ASAny;

	public var timeline:SimpleTimeline;

	public var cachedOrphan:Bool = false;

	public var cachedStartTime:Float = Math.NaN;

	public var prevNode:TweenCore;

	public var cachedDuration:Float = Math.NaN;

	public var gc:Bool = false;

	public var cachedPauseTime:Float = Math.NaN;

	public var cacheIsDirty:Bool = false;

	public var cachedPaused:Bool = false;

	public var cachedTimeScale:Float = Math.NaN;

	public var cachedTotalDuration:Float = Math.NaN;

	public function new(duration:Float = 0, vars:ASObject = null) {
		this.vars = vars != null ? vars : {};
		if (ASCompat.toBool(this.vars.isGSVars)) {
			this.vars = this.vars.vars;
		}
		this.cachedDuration = this.cachedTotalDuration = duration;
		_delay = ASCompat.toBool(this.vars.delay) ? ASCompat.toNumber(this.vars.delay) : 0;
		this.cachedTimeScale = ASCompat.toBool(this.vars.timeScale) ? ASCompat.toNumber(this.vars.timeScale) : 1;
		this.active = duration == 0 && _delay == 0 && this.vars.immediateRender != false;
		this.cachedTotalTime = this.cachedTime = 0;
		this.data = this.vars.data;
		if (!_classInitted) {
			if (!Math.isNaN(TweenLite.rootFrame)) {
				return;
			}
			TweenLite.initClass();
			_classInitted = true;
		}
		var _loc3_ = ASCompat.dynamicAs(Std.isOfType(this.vars.timeline,
			SimpleTimeline) ? ASCompat.dynamicAs(this.vars.timeline,
				com.greensock.core.SimpleTimeline) : (ASCompat.toBool(this.vars.useFrames) ? TweenLite.rootFramesTimeline : TweenLite.rootTimeline),
			com.greensock.core.SimpleTimeline);
		_loc3_.insert(this, _loc3_.cachedTotalTime);
		if (ASCompat.toBool(this.vars.reversed)) {
			this.cachedReversed = true;
		}
		if (ASCompat.toBool(this.vars.paused)) {
			this.paused = true;
		}
	}

	public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) {}

	@:isVar public var delay(get, set):Float;

	public function get_delay():Float {
		return _delay;
	}

	@:isVar public var duration(get, set):Float;

	public function get_duration():Float {
		return this.cachedDuration;
	}

	@:isVar public var reversed(get, set):Bool;

	public function set_reversed(b:Bool):Bool {
		if (b != this.cachedReversed) {
			this.cachedReversed = b;
			setTotalTime(this.cachedTotalTime, true);
		}
		return b;
	}

	@:isVar public var startTime(get, set):Float;

	public function set_startTime(n:Float):Float {
		if (this.timeline != null && (n != this.cachedStartTime || this.gc)) {
			this.timeline.insert(this, n - _delay);
		} else {
			this.cachedStartTime = n;
		}
		return n;
	}

	public function restart(includeDelay:Bool = false, suppressEvents:Bool = true) {
		this.reversed = false;
		this.paused = false;
		this.setTotalTime(includeDelay ? -_delay : 0, suppressEvents);
	}

	function set_delay(n:Float):Float {
		this.startTime += n - _delay;
		return _delay = n;
	}

	public function resume() {
		this.paused = false;
	}

	@:isVar public var paused(get, set):Bool;

	public function get_paused():Bool {
		return this.cachedPaused;
	}

	public function play() {
		this.reversed = false;
		this.paused = false;
	}

	function set_duration(n:Float):Float {
		var _loc2_ = n / this.cachedDuration;
		this.cachedDuration = this.cachedTotalDuration = n;
		if (this.active && !this.cachedPaused && n != 0) {
			this.setTotalTime(this.cachedTotalTime * _loc2_, true);
		}
		setDirtyCache(false);
		return n;
	}

	public function invalidate() {}

	public function complete(skipRender:Bool = false, suppressEvents:Bool = false) {
		if (!skipRender) {
			renderTime(this.totalDuration, suppressEvents, false);
			return;
		}
		if (this.timeline.autoRemoveChildren) {
			this.setEnabled(false, false);
		} else {
			this.active = false;
		}
		if (!suppressEvents) {
			if (ASCompat.toBool(this.vars.onComplete) && this.cachedTotalTime >= this.cachedTotalDuration && !this.cachedReversed) {
				ASCompatMacro.applyClosure(this.vars.onComplete, this.vars.onCompleteParams);
			} else if (this.cachedReversed && this.cachedTotalTime == 0 && ASCompat.toBool(this.vars.onReverseComplete)) {
				ASCompatMacro.applyClosure(this.vars.onReverseComplete, this.vars.onReverseCompleteParams);
			}
		}
	}

	@:isVar public var totalTime(get, set):Float;

	public function get_totalTime():Float {
		return this.cachedTotalTime;
	}

	function get_startTime():Float {
		return this.cachedStartTime;
	}

	function get_reversed():Bool {
		return this.cachedReversed;
	}

	@:isVar public var currentTime(get, set):Float;

	public function set_currentTime(n:Float):Float {
		setTotalTime(n, false);
		return n;
	}

	function setDirtyCache(includeSelf:Bool = true) {
		var _loc2_ = ASCompat.dynamicAs(includeSelf ? this : this.timeline, TweenCore);
		while (_loc2_ != null) {
			_loc2_.cacheIsDirty = true;
			_loc2_ = _loc2_.timeline;
		}
	}

	public function reverse(forceResume:Bool = true) {
		this.reversed = true;
		if (forceResume) {
			this.paused = false;
		} else if (this.gc) {
			this.setEnabled(true, false);
		}
	}

	function set_paused(b:Bool):Bool {
		if (b != this.cachedPaused && this.timeline != null) {
			if (b) {
				this.cachedPauseTime = this.timeline.rawTime;
			} else {
				this.cachedStartTime += this.timeline.rawTime - this.cachedPauseTime;
				this.cachedPauseTime = Math.NaN;
				setDirtyCache(false);
			}
			this.cachedPaused = b;
			this.active = !this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration;
		}
		if (!b && this.gc) {
			this.setTotalTime(this.cachedTotalTime, false);
			this.setEnabled(true, false);
		}
		return b;
	}

	public function kill() {
		setEnabled(false, false);
	}

	function set_totalTime(n:Float):Float {
		setTotalTime(n, false);
		return n;
	}

	function get_currentTime():Float {
		return this.cachedTime;
	}

	function setTotalTime(time:Float, suppressEvents:Bool = false) {
		var _loc3_ = Math.NaN;
		var _loc4_ = Math.NaN;
		if (this.timeline != null) {
			_loc3_ = this.cachedPaused ? this.cachedPauseTime : this.timeline.cachedTotalTime;
			if (this.cachedReversed) {
				_loc4_ = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
				this.cachedStartTime = _loc3_ - (_loc4_ - time) / this.cachedTimeScale;
			} else {
				this.cachedStartTime = _loc3_ - time / this.cachedTimeScale;
			}
			if (!this.timeline.cacheIsDirty) {
				setDirtyCache(false);
			}
			if (this.cachedTotalTime != time) {
				renderTime(time, suppressEvents, false);
			}
		}
	}

	public function pause() {
		this.paused = true;
	}

	@:isVar public var totalDuration(get, set):Float;

	public function set_totalDuration(n:Float):Float {
		return this.duration = n;
	}

	function get_totalDuration():Float {
		return this.cachedTotalDuration;
	}

	public function setEnabled(enabled:Bool, ignoreTimeline:Bool = false):Bool {
		this.gc = !enabled;
		if (enabled) {
			this.active = !this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration;
			if (!ignoreTimeline && this.cachedOrphan) {
				this.timeline.insert(this, this.cachedStartTime - _delay);
			}
		} else {
			this.active = false;
			if (!ignoreTimeline && !this.cachedOrphan) {
				this.timeline.remove(this, true);
			}
		}
		return false;
	}
}
