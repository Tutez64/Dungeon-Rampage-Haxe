package com.greensock.core;

class SimpleTimeline extends TweenCore {
	public var autoRemoveChildren:Bool = false;

	var _lastChild:TweenCore;

	var _firstChild:TweenCore;

	public function new(vars:ASObject = null) {
		super(0, vars);
	}

	@:isVar public var rawTime(get, never):Float;

	public function get_rawTime():Float {
		return this.cachedTotalTime;
	}

	public function insert(tween:TweenCore, time:ASAny = 0):TweenCore {
		if (!tween.cachedOrphan && tween.timeline != null) {
			tween.timeline.remove(tween, true);
		}
		tween.timeline = this;
		tween.cachedStartTime = ASCompat.toNumber(time) + tween.delay;
		if (tween.gc) {
			tween.setEnabled(true, true);
		}
		if (tween.cachedPaused) {
			tween.cachedPauseTime = tween.cachedStartTime + (this.rawTime - tween.cachedStartTime) / tween.cachedTimeScale;
		}
		if (_lastChild != null) {
			_lastChild.nextNode = tween;
		} else {
			_firstChild = tween;
		}
		tween.prevNode = _lastChild;
		_lastChild = tween;
		tween.nextNode = null;
		tween.cachedOrphan = false;
		return tween;
	}

	override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) {
		var _loc5_ = Math.NaN;
		var _loc6_:TweenCore = null;
		var _loc4_ = _firstChild;
		this.cachedTotalTime = time;
		this.cachedTime = time;
		while (_loc4_ != null) {
			_loc6_ = _loc4_.nextNode;
			if (_loc4_.active || time >= _loc4_.cachedStartTime && !_loc4_.cachedPaused && !_loc4_.gc) {
				if (!_loc4_.cachedReversed) {
					_loc4_.renderTime((time - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale, suppressEvents, false);
				} else {
					_loc5_ = _loc4_.cacheIsDirty ? _loc4_.totalDuration : _loc4_.cachedTotalDuration;
					_loc4_.renderTime(_loc5_ - (time - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale, suppressEvents, false);
				}
			}
			_loc4_ = _loc6_;
		}
	}

	public function remove(tween:TweenCore, skipDisable:Bool = false) {
		if (tween.cachedOrphan) {
			return;
		}
		if (!skipDisable) {
			tween.setEnabled(false, true);
		}
		if (tween.nextNode != null) {
			tween.nextNode.prevNode = tween.prevNode;
		} else if (_lastChild == tween) {
			_lastChild = tween.prevNode;
		}
		if (tween.prevNode != null) {
			tween.prevNode.nextNode = tween.nextNode;
		} else if (_firstChild == tween) {
			_firstChild = tween.nextNode;
		}
		tween.cachedOrphan = true;
	}
}
