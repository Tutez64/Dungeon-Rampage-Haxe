package com.greensock;

import com.greensock.core.*;

class TimelineLite extends SimpleTimeline {
	public static inline final version:Float = 1.66;

	static var _overwriteMode:Int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init(2);

	var _endCaps:Array<ASAny>;

	var _labels:ASObject;

	public function new(vars:ASObject = null) {
		super(vars);
		_endCaps = [null, null];
		_labels = {};
		this.autoRemoveChildren = this.vars.autoRemoveChildren == true;
		_hasUpdate = ASCompat.typeof(this.vars.onUpdate) == "function";
		if (Std.isOfType(this.vars.tweens, Array)) {
			this.insertMultiple(ASCompat.dynamicAs(this.vars.tweens, Array), 0, this.vars.align != null ? this.vars.align : "normal",
				ASCompat.toBool(this.vars.stagger) ? ASCompat.toNumber(this.vars.stagger) : 0);
		}
	}

	@:isVar public var timeScale(get, set):Float;

	public function set_timeScale(n:Float):Float {
		if (n == 0) {
			n = 0.0001;
		}
		var _loc2_ = ASCompat.floatAsBool(this.cachedPauseTime)
			|| this.cachedPauseTime == 0 ? this.cachedPauseTime : this.timeline.cachedTotalTime;
		this.cachedStartTime = _loc2_ - (_loc2_ - this.cachedStartTime) * this.cachedTimeScale / n;
		this.cachedTimeScale = n;
		setDirtyCache(false);
		return n;
	}

	public function stop() {
		this.paused = true;
	}

	override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) {
		var _loc8_:TweenCore = null;
		var _loc9_ = false;
		var _loc10_ = false;
		var _loc11_:TweenCore = null;
		var _loc12_ = Math.NaN;
		if (this.gc) {
			this.setEnabled(true, false);
		} else if (!this.active && !this.cachedPaused) {
			this.active = true;
		}
		var _loc4_ = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
		var _loc5_ = this.cachedTime;
		var _loc6_ = this.cachedStartTime;
		var _loc7_ = this.cachedTimeScale;
		var _loc13_ = this.cachedPaused;
		if (time >= _loc4_) {
			if (_rawPrevTime <= _loc4_ && _rawPrevTime != time) {
				this.cachedTotalTime = this.cachedTime = _loc4_;
				forceChildrenToEnd(_loc4_, suppressEvents);
				_loc9_ = !this.hasPausedChild();
				_loc10_ = true;
				if (this.cachedDuration == 0 && _loc9_ && (time == 0 || _rawPrevTime < 0)) {
					force = true;
				}
			}
		} else if (time <= 0) {
			if (time < 0) {
				this.active = false;
				if (this.cachedDuration == 0 && _rawPrevTime >= 0) {
					force = true;
					_loc9_ = true;
				}
			} else if (time == 0 && !this.initted) {
				force = true;
			}
			if (_rawPrevTime >= 0 && _rawPrevTime != time) {
				this.cachedTotalTime = 0;
				this.cachedTime = 0;
				forceChildrenToBeginning(0, suppressEvents);
				_loc10_ = true;
				if (this.cachedReversed) {
					_loc9_ = true;
				}
			}
		} else {
			this.cachedTotalTime = this.cachedTime = time;
		}
		_rawPrevTime = time;
		if (this.cachedTime == _loc5_ && !force) {
			return;
		}
		if (!this.initted) {
			this.initted = true;
		}
		if (_loc5_ == 0 && ASCompat.toBool(this.vars.onStart) && this.cachedTime != 0 && !suppressEvents) {
			ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
		}
		if (!_loc10_) {
			if (this.cachedTime - _loc5_ > 0) {
				_loc8_ = _firstChild;
				while (_loc8_ != null) {
					_loc11_ = _loc8_.nextNode;
					if (this.cachedPaused && !_loc13_) {
						break;
					}
					if (_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= this.cachedTime && !_loc8_.gc) {
						if (!_loc8_.cachedReversed) {
							_loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale, suppressEvents, false);
						} else {
							_loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
							_loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale, suppressEvents, false);
						}
					}
					_loc8_ = _loc11_;
				}
			} else {
				_loc8_ = _lastChild;
				while (_loc8_ != null) {
					_loc11_ = _loc8_.prevNode;
					if (this.cachedPaused && !_loc13_) {
						break;
					}
					if (_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= _loc5_ && !_loc8_.gc) {
						if (!_loc8_.cachedReversed) {
							_loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale, suppressEvents, false);
						} else {
							_loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
							_loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale, suppressEvents, false);
						}
					}
					_loc8_ = _loc11_;
				}
			}
		}
		if (_hasUpdate && !suppressEvents) {
			ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
		}
		if (_loc9_
			&& (_loc6_ == this.cachedStartTime || _loc7_ != this.cachedTimeScale)
			&& (_loc4_ >= this.totalDuration || this.cachedTime == 0)) {
			complete(true, suppressEvents);
		}
	}

	override public function remove(tween:TweenCore, skipDisable:Bool = false) {
		if (tween.cachedOrphan) {
			return;
		}
		if (!skipDisable) {
			tween.setEnabled(false, true);
		}
		var _loc3_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		var _loc4_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore) : _lastChild, com.greensock.core.TweenCore);
		if (tween.nextNode != null) {
			tween.nextNode.prevNode = tween.prevNode;
		} else if (_loc4_ == tween) {
			_loc4_ = tween.prevNode;
		}
		if (tween.prevNode != null) {
			tween.prevNode.nextNode = tween.nextNode;
		} else if (_loc3_ == tween) {
			_loc3_ = tween.nextNode;
		}
		if (this.gc) {
			_endCaps[0] = _loc3_;
			_endCaps[1] = _loc4_;
		} else {
			_firstChild = _loc3_;
			_lastChild = _loc4_;
		}
		tween.cachedOrphan = true;
		setDirtyCache(true);
	}

	@:isVar public var currentProgress(get, set):Float;

	public function get_currentProgress():Float {
		return this.cachedTime / this.duration;
	}

	override public function get_totalDuration():Float {
		var _loc1_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc3_:TweenCore = null;
		var _loc4_ = Math.NaN;
		var _loc5_:TweenCore = null;
		if (this.cacheIsDirty) {
			_loc1_ = 0;
			_loc3_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
			_loc4_ = Math.NEGATIVE_INFINITY;
			while (_loc3_ != null) {
				_loc5_ = _loc3_.nextNode;
				if (_loc3_.cachedStartTime < _loc4_) {
					this.insert(_loc3_, _loc3_.cachedStartTime - _loc3_.delay);
					_loc4_ = _loc3_.prevNode.cachedStartTime;
				} else {
					_loc4_ = _loc3_.cachedStartTime;
				}
				if (_loc3_.cachedStartTime < 0) {
					_loc1_ -= _loc3_.cachedStartTime;
					this.shiftChildren(-_loc3_.cachedStartTime, false, -9999999999);
				}
				_loc2_ = _loc3_.cachedStartTime + _loc3_.totalDuration / _loc3_.cachedTimeScale;
				if (_loc2_ > _loc1_) {
					_loc1_ = _loc2_;
				}
				_loc3_ = _loc5_;
			}
			this.cachedDuration = this.cachedTotalDuration = _loc1_;
			this.cacheIsDirty = false;
		}
		return this.cachedTotalDuration;
	}

	public function gotoAndPlay(timeOrLabel:ASAny, suppressEvents:Bool = true) {
		setTotalTime(parseTimeOrLabel(timeOrLabel), suppressEvents);
		play();
	}

	public function appendMultiple(tweens:Array<ASAny>, offset:Float = 0, align:String = "normal", stagger:Float = 0):Array<ASAny> {
		return insertMultiple(tweens, this.duration + offset, align, stagger);
	}

	function set_currentProgress(n:Float):Float {
		setTotalTime(this.duration * n, false);
		return n;
	}

	public function clear(tweens:Array<ASAny> = null) {
		if (tweens == null) {
			tweens = getChildren(false, true, true);
		}
		var _loc2_ = tweens.length;
		while (--_loc2_ > -1) {
			cast(tweens[_loc2_], TweenCore).setEnabled(false, false);
		}
	}

	public function prepend(tween:TweenCore, adjustLabels:Bool = false):TweenCore {
		shiftChildren(tween.totalDuration / tween.cachedTimeScale + tween.delay, adjustLabels, 0);
		return insert(tween, 0);
	}

	public function removeLabel(label:String):Float {
		var _loc2_ = ASCompat.toNumber(_labels[label]);
		ASCompat.deleteProperty(_labels, label);
		return _loc2_;
	}

	function parseTimeOrLabel(timeOrLabel:ASAny):Float {
		if (ASCompat.typeof(timeOrLabel) == "string") {
			if (!_labels.hasOwnProperty(timeOrLabel)) {
				throw new Error("TimelineLite error: the " + Std.string(timeOrLabel) + " label was not found.");
			}
			return getLabelTime(ASCompat.toString(timeOrLabel));
		}
		return ASCompat.toNumber(timeOrLabel);
	}

	public function addLabel(label:String, time:Float) {
		_labels[label] = time;
	}

	public function hasPausedChild():Bool {
		var _loc1_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		while (_loc1_ != null) {
			if (_loc1_.cachedPaused
				|| Std.isOfType(_loc1_, TimelineLite)
				&& ASCompat.reinterpretAs(_loc1_, TimelineLite).hasPausedChild()) {
				return true;
			}
			_loc1_ = _loc1_.nextNode;
		}
		return false;
	}

	public function getTweensOf(target:ASObject, nested:Bool = true):Array<ASAny> {
		var _loc8_:Float;
		var _loc5_ = 0;
		var _loc3_ = getChildren(nested, true, false);
		var _loc4_:Array<ASAny> = [];
		var _loc6_ = _loc3_.length;
		var _loc7_ = 0;
		_loc5_ = 0;
		while (_loc5_ < _loc6_) {
			if (cast(_loc3_[_loc5_], TweenLite).target == target) {
				_loc4_[Std.int(_loc8_ = ASCompat.toNumber(_loc7_++))] = _loc3_[_loc5_];
			}
			_loc5_ += 1;
		}
		return _loc4_;
	}

	public function gotoAndStop(timeOrLabel:ASAny, suppressEvents:Bool = true) {
		setTotalTime(parseTimeOrLabel(timeOrLabel), suppressEvents);
		this.paused = true;
	}

	public function append(tween:TweenCore, offset:Float = 0):TweenCore {
		return insert(tween, this.duration + offset);
	}

	override public function get_duration():Float {
		var _loc1_ = Math.NaN;
		if (this.cacheIsDirty) {
			_loc1_ = this.totalDuration;
		}
		return this.cachedDuration;
	}

	@:isVar public var useFrames(get, never):Bool;

	public function get_useFrames():Bool {
		var _loc1_ = this.timeline;
		while (_loc1_.timeline != null) {
			_loc1_ = _loc1_.timeline;
		}
		return _loc1_ == TweenLite.rootFramesTimeline;
	}

	public function shiftChildren(amount:Float, adjustLabels:Bool = false, ignoreBeforeTime:Float = 0) {
		var __ax4_iter_154:ASObject;
		var _loc5_:String = null;
		var _loc4_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		while (_loc4_ != null) {
			if (_loc4_.cachedStartTime >= ignoreBeforeTime) {
				_loc4_.cachedStartTime += amount;
			}
			_loc4_ = _loc4_.nextNode;
		}
		if (adjustLabels) {
			__ax4_iter_154 = _labels;
			if (checkNullIteratee(__ax4_iter_154))
				for (_tmp_ in __ax4_iter_154.___keys()) {
					_loc5_ = _tmp_;
					if (ASCompat.toNumber(_labels[_loc5_]) >= ignoreBeforeTime) {
						_labels[_loc5_] += amount;
					}
				}
		}
		this.setDirtyCache(true);
	}

	public function seek(timeOrLabel:ASAny, suppressEvents:Bool = true) {
		setTotalTime(parseTimeOrLabel(timeOrLabel), suppressEvents);
	}

	public function killTweensOf(target:ASObject, nested:Bool = true, vars:ASObject = null):Bool {
		var _loc6_:TweenLite = null;
		var _loc4_ = getTweensOf(target, nested);
		var _loc5_ = _loc4_.length;
		while (--_loc5_ > -1) {
			_loc6_ = ASCompat.dynamicAs(_loc4_[_loc5_], com.greensock.TweenLite);
			if (vars != null) {
				_loc6_.killVars(vars);
			}
			if (vars == null || _loc6_.cachedPT1 == null && _loc6_.initted) {
				_loc6_.setEnabled(false, false);
			}
		}
		return _loc4_.length > 0;
	}

	override public function set_duration(n:Float):Float {
		if (this.duration != 0 && n != 0) {
			this.timeScale = this.duration / n;
		}
		return n;
	}

	public function insertMultiple(tweens:Array<ASAny>, timeOrLabel:ASAny = 0, align:String = "normal", stagger:Float = 0):Array<ASAny> {
		var _loc5_ = 0;
		var _loc6_:TweenCore = null;
		var _loc7_ = ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(timeOrLabel), 0));
		var _loc8_ = tweens.length;
		if (ASCompat.typeof(timeOrLabel) == "string") {
			if (!_labels.hasOwnProperty(timeOrLabel)) {
				addLabel(timeOrLabel, this.duration);
			}
			_loc7_ = ASCompat.toNumber(_labels[timeOrLabel]);
		}
		_loc5_ = 0;
		while (_loc5_ < _loc8_) {
			_loc6_ = ASCompat.dynamicAs(tweens[_loc5_], TweenCore);
			insert(_loc6_, _loc7_);
			if (align == "sequence") {
				_loc7_ = _loc6_.cachedStartTime + _loc6_.totalDuration / _loc6_.cachedTimeScale;
			} else if (align == "start") {
				_loc6_.cachedStartTime -= _loc6_.delay;
			}
			_loc7_ += stagger;
			_loc5_ += 1;
		}
		return tweens;
	}

	public function getLabelTime(label:String):Float {
		return _labels.hasOwnProperty(label) ? ASCompat.toNumber(_labels[label]) : -1;
	}

	override public function get_rawTime():Float {
		if (this.cachedTotalTime != 0 && this.cachedTotalTime != this.cachedTotalDuration) {
			return this.cachedTotalTime;
		}
		return (this.timeline.rawTime - this.cachedStartTime) * this.cachedTimeScale;
	}

	override public function set_totalDuration(n:Float):Float {
		if (this.totalDuration != 0 && n != 0) {
			this.timeScale = this.totalDuration / n;
		}
		return n;
	}

	public function getChildren(nested:Bool = true, tweens:Bool = true, timelines:Bool = true, ignoreBeforeTime:Float = -9999999999):Array<ASAny> {
		var _loc8_:Float;
		var _loc5_:Array<ASAny> = [];
		var _loc6_ = 0;
		var _loc7_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		while (_loc7_ != null) {
			if (_loc7_.cachedStartTime >= ignoreBeforeTime) {
				if (Std.isOfType(_loc7_, TweenLite)) {
					if (tweens) {
						_loc5_[Std.int(_loc8_ = ASCompat.toNumber(_loc6_++))] = _loc7_;
					}
				} else {
					if (timelines) {
						_loc5_[Std.int(_loc8_ = ASCompat.toNumber(_loc6_++))] = _loc7_;
					}
					if (nested) {
						_loc5_ = _loc5_.concat(cast(_loc7_, TimelineLite).getChildren(true, tweens, timelines));
						_loc6_ = _loc5_.length;
					}
				}
			}
			_loc7_ = _loc7_.nextNode;
		}
		return _loc5_;
	}

	function forceChildrenToEnd(time:Float, suppressEvents:Bool = false):Float {
		var _loc4_:TweenCore = null;
		var _loc5_ = Math.NaN;
		var _loc3_ = _firstChild;
		var _loc6_ = this.cachedPaused;
		while (_loc3_ != null) {
			_loc4_ = _loc3_.nextNode;
			if (this.cachedPaused && !_loc6_) {
				break;
			}
			if (_loc3_.active
				|| !_loc3_.cachedPaused
				&& !_loc3_.gc
				&& (_loc3_.cachedTotalTime != _loc3_.cachedTotalDuration || _loc3_.cachedDuration == 0)) {
				if (time == this.cachedDuration && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == this.cachedDuration)) {
					_loc3_.renderTime(_loc3_.cachedReversed ? 0 : _loc3_.cachedTotalDuration, suppressEvents, false);
				} else if (!_loc3_.cachedReversed) {
					_loc3_.renderTime((time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale, suppressEvents, false);
				} else {
					_loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
					_loc3_.renderTime(_loc5_ - (time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale, suppressEvents, false);
				}
			}
			_loc3_ = _loc4_;
		}
		return time;
	}

	function forceChildrenToBeginning(time:Float, suppressEvents:Bool = false):Float {
		var _loc4_:TweenCore = null;
		var _loc5_ = Math.NaN;
		var _loc3_ = _lastChild;
		var _loc6_ = this.cachedPaused;
		while (_loc3_ != null) {
			_loc4_ = _loc3_.prevNode;
			if (this.cachedPaused && !_loc6_) {
				break;
			}
			if (_loc3_.active || !_loc3_.cachedPaused && !_loc3_.gc && (_loc3_.cachedTotalTime != 0 || _loc3_.cachedDuration == 0)) {
				if (time == 0 && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == 0)) {
					_loc3_.renderTime(_loc3_.cachedReversed ? _loc3_.cachedTotalDuration : 0, suppressEvents, false);
				} else if (!_loc3_.cachedReversed) {
					_loc3_.renderTime((time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale, suppressEvents, false);
				} else {
					_loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
					_loc3_.renderTime(_loc5_ - (time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale, suppressEvents, false);
				}
			}
			_loc3_ = _loc4_;
		}
		return time;
	}

	override public function insert(tween:TweenCore, timeOrLabel:ASAny = 0):TweenCore {
		var _loc5_:TweenCore = null;
		var _loc6_ = Math.NaN;
		var _loc7_:SimpleTimeline = null;
		if (ASCompat.typeof(timeOrLabel) == "string") {
			if (!_labels.hasOwnProperty(timeOrLabel)) {
				addLabel(timeOrLabel, this.duration);
			}
			timeOrLabel = ASCompat.toNumber(_labels[timeOrLabel]);
		}
		if (!tween.cachedOrphan && tween.timeline != null) {
			tween.timeline.remove(tween, true);
		}
		tween.timeline = this;
		tween.cachedStartTime = ASCompat.toNumber(timeOrLabel) + tween.delay;
		if (tween.cachedPaused) {
			tween.cachedPauseTime = tween.cachedStartTime + (this.rawTime - tween.cachedStartTime) / tween.cachedTimeScale;
		}
		if (tween.gc) {
			tween.setEnabled(true, true);
		}
		setDirtyCache(true);
		var _loc3_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		var _loc4_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore) : _lastChild, com.greensock.core.TweenCore);
		if (_loc4_ == null) {
			_loc3_ = _loc4_ = tween;
			tween.nextNode = tween.prevNode = null;
		} else {
			_loc5_ = _loc4_;
			_loc6_ = tween.cachedStartTime;
			while (_loc5_ != null && _loc6_ < _loc5_.cachedStartTime) {
				_loc5_ = _loc5_.prevNode;
			}
			if (_loc5_ == null) {
				_loc3_.prevNode = tween;
				tween.nextNode = _loc3_;
				tween.prevNode = null;
				_loc3_ = tween;
			} else {
				if (_loc5_.nextNode != null) {
					_loc5_.nextNode.prevNode = tween;
				} else if (_loc5_ == _loc4_) {
					_loc4_ = tween;
				}
				tween.prevNode = _loc5_;
				tween.nextNode = _loc5_.nextNode;
				_loc5_.nextNode = tween;
			}
		}
		tween.cachedOrphan = false;
		if (this.gc) {
			_endCaps[0] = _loc3_;
			_endCaps[1] = _loc4_;
		} else {
			_firstChild = _loc3_;
			_lastChild = _loc4_;
		}
		if (this.gc
			&& !this.cachedPaused
			&& this.cachedStartTime + (tween.cachedStartTime +
				tween.cachedTotalDuration / tween.cachedTimeScale) / this.cachedTimeScale > this.timeline.cachedTime) {
			if (this.timeline == TweenLite.rootTimeline || this.timeline == TweenLite.rootFramesTimeline) {
				this.setTotalTime(this.cachedTotalTime, true);
			}
			this.setEnabled(true, false);
			_loc7_ = this.timeline;
			while (_loc7_.gc && _loc7_.timeline != null) {
				if (_loc7_.cachedStartTime + _loc7_.totalDuration / _loc7_.cachedTimeScale > _loc7_.timeline.cachedTime) {
					_loc7_.setEnabled(true, false);
				}
				_loc7_ = _loc7_.timeline;
			}
		}
		return tween;
	}

	override public function invalidate() {
		var _loc1_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
		while (_loc1_ != null) {
			_loc1_.invalidate();
			_loc1_ = _loc1_.nextNode;
		}
	}

	function get_timeScale():Float {
		return this.cachedTimeScale;
	}

	public function prependMultiple(tweens:Array<ASAny>, align:String = "normal", stagger:Float = 0, adjustLabels:Bool = false):Array<ASAny> {
		var _loc5_ = new TimelineLite({
			"tweens": tweens,
			"align": align,
			"stagger": stagger
		});
		shiftChildren(_loc5_.duration, adjustLabels, 0);
		insertMultiple(tweens, 0, align, stagger);
		_loc5_.kill();
		return tweens;
	}

	override public function setEnabled(enabled:Bool, ignoreTimeline:Bool = false):Bool {
		var _loc3_:TweenCore = null;
		if (enabled == this.gc) {
			if (enabled) {
				_firstChild = _loc3_ = ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore);
				_lastChild = ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore);
				_endCaps = [null, null];
			} else {
				_loc3_ = _firstChild;
				_endCaps = [_firstChild, _lastChild];
				_firstChild = _lastChild = null;
			}
			while (_loc3_ != null) {
				_loc3_.setEnabled(enabled, true);
				_loc3_ = _loc3_.nextNode;
			}
		}
		return super.setEnabled(enabled, ignoreTimeline);
	}
}
