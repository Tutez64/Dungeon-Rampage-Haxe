package com.greensock;

import com.greensock.core.*;
import com.greensock.events.TweenEvent;
import flash.events.*;

class TimelineMax extends TimelineLite implements IEventDispatcher {
	public static inline final version:Float = 1.67;

	var _cyclesComplete:Int = 0;

	var _dispatcher:EventDispatcher;

	var _hasUpdateListener:Bool = false;

	public var yoyo:Bool = false;

	var _repeatDelay:Float = Math.NaN;

	var _repeat:Int = 0;

	public function new(vars:ASObject = null) {
		super(vars);
		_repeat = ASCompat.toBool(this.vars.repeat) ? Std.int(ASCompat.toNumber(this.vars.repeat)) : 0;
		_repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
		_cyclesComplete = 0;
		this.yoyo = this.vars.yoyo == true;
		this.cacheIsDirty = true;
		if (this.vars.onCompleteListener != null
			|| this.vars.onUpdateListener != null
			|| this.vars.onStartListener != null
			|| this.vars.onRepeatListener != null
			|| this.vars.onReverseCompleteListener != null) {
			initDispatcher();
		}
	}

	static function easeNone(t:Float, b:Float, c:Float, d:Float):Float {
		return t / d;
	}

	static function onInitTweenTo(tween:TweenLite, timeline:TimelineMax, fromTime:Float) {
		timeline.paused = true;
		if (!Math.isNaN(fromTime)) {
			timeline.currentTime = fromTime;
		}
		if (ASCompat.toNumberField(tween.vars, "currentTime") != timeline.currentTime) {
			tween.duration = Math.abs(ASCompat.toNumber(tween.vars.currentTime) - timeline.currentTime) / timeline.cachedTimeScale;
		}
	}

	public function dispatchEvent(e:Event):Bool {
		return _dispatcher == null ? false : _dispatcher.dispatchEvent(e);
	}

	@:isVar public var currentLabel(get, never):String;

	public function get_currentLabel():String {
		return getLabelBefore(this.cachedTime + 1e-8);
	}

	override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) {
		var _loc9_:TweenCore = null;
		var _loc10_ = false;
		var _loc11_ = false;
		var _loc12_ = false;
		var _loc13_:TweenCore = null;
		var _loc14_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = 0;
		var _loc18_ = false;
		var _loc19_ = false;
		var _loc20_ = false;
		if (this.gc) {
			this.setEnabled(true, false);
		} else if (!this.active && !this.cachedPaused) {
			this.active = true;
		}
		var _loc4_ = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
		var _loc5_ = this.cachedTime;
		var _loc6_ = this.cachedTotalTime;
		var _loc7_ = this.cachedStartTime;
		var _loc8_ = this.cachedTimeScale;
		var _loc15_ = this.cachedPaused;
		if (time >= _loc4_) {
			if (_rawPrevTime <= _loc4_ && _rawPrevTime != time) {
				this.cachedTotalTime = _loc4_;
				if (!this.cachedReversed && this.yoyo && _repeat % 2 != 0) {
					this.cachedTime = 0;
					forceChildrenToBeginning(0, suppressEvents);
				} else {
					this.cachedTime = this.cachedDuration;
					forceChildrenToEnd(this.cachedDuration, suppressEvents);
				}
				_loc10_ = !this.hasPausedChild();
				_loc11_ = true;
				if (this.cachedDuration == 0 && _loc10_ && (time == 0 || _rawPrevTime < 0)) {
					force = true;
				}
			}
		} else if (time <= 0) {
			if (time < 0) {
				this.active = false;
				if (this.cachedDuration == 0 && _rawPrevTime >= 0) {
					force = true;
					_loc10_ = true;
				}
			} else if (time == 0 && !this.initted) {
				force = true;
			}
			if (_rawPrevTime >= 0 && _rawPrevTime != time) {
				this.cachedTotalTime = 0;
				this.cachedTime = 0;
				forceChildrenToBeginning(0, suppressEvents);
				_loc11_ = true;
				if (this.cachedReversed) {
					_loc10_ = true;
				}
			}
		} else {
			this.cachedTotalTime = this.cachedTime = time;
		}
		_rawPrevTime = time;
		if (_repeat != 0) {
			_loc16_ = this.cachedDuration + _repeatDelay;
			_loc17_ = _cyclesComplete;
			_cyclesComplete = Std.int(this.cachedTotalTime / _loc16_) >> 0;
			if (_cyclesComplete == this.cachedTotalTime / _loc16_) {
				--_cyclesComplete;
			}
			if (_loc17_ != _cyclesComplete) {
				_loc12_ = true;
			}
			if (_loc10_) {
				if (this.yoyo && _repeat % 2 != 0) {
					this.cachedTime = 0;
				}
			} else if (time > 0) {
				this.cachedTime = (this.cachedTotalTime / _loc16_ - _cyclesComplete) * _loc16_;
				if (this.yoyo && _cyclesComplete % 2 != 0) {
					this.cachedTime = this.cachedDuration - this.cachedTime;
				} else if (this.cachedTime >= this.cachedDuration) {
					this.cachedTime = this.cachedDuration;
				}
				if (this.cachedTime < 0) {
					this.cachedTime = 0;
				}
			} else {
				_cyclesComplete = 0;
			}
			if (_loc12_ && !_loc10_ && (this.cachedTime != _loc5_ || force)) {
				_loc18_ = !this.yoyo || _cyclesComplete % 2 == 0;
				_loc19_ = !this.yoyo || _loc17_ % 2 == 0;
				_loc20_ = _loc18_ == _loc19_;
				if (_loc17_ > _cyclesComplete) {
					_loc19_ = !_loc19_;
				}
				if (_loc19_) {
					_loc5_ = forceChildrenToEnd(this.cachedDuration, suppressEvents);
					if (_loc20_) {
						_loc5_ = forceChildrenToBeginning(0, true);
					}
				} else {
					_loc5_ = forceChildrenToBeginning(0, suppressEvents);
					if (_loc20_) {
						_loc5_ = forceChildrenToEnd(this.cachedDuration, true);
					}
				}
				_loc11_ = false;
			}
		}
		if (this.cachedTotalTime == _loc6_ && !force) {
			return;
		}
		if (!this.initted) {
			this.initted = true;
		}
		if (_loc6_ == 0 && this.cachedTotalTime != 0 && !suppressEvents) {
			if (ASCompat.toBool(this.vars.onStart)) {
				ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
			}
			if (_dispatcher != null) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
			}
		}
		if (!_loc11_) {
			if (this.cachedTime - _loc5_ > 0) {
				_loc9_ = _firstChild;
				while (_loc9_ != null) {
					_loc13_ = _loc9_.nextNode;
					if (this.cachedPaused && !_loc15_) {
						break;
					}
					if (_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= this.cachedTime && !_loc9_.gc) {
						if (!_loc9_.cachedReversed) {
							_loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale, suppressEvents, false);
						} else {
							_loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
							_loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale, suppressEvents, false);
						}
					}
					_loc9_ = _loc13_;
				}
			} else {
				_loc9_ = _lastChild;
				while (_loc9_ != null) {
					_loc13_ = _loc9_.prevNode;
					if (this.cachedPaused && !_loc15_) {
						break;
					}
					if (_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= _loc5_ && !_loc9_.gc) {
						if (!_loc9_.cachedReversed) {
							_loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale, suppressEvents, false);
						} else {
							_loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
							_loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale, suppressEvents, false);
						}
					}
					_loc9_ = _loc13_;
				}
			}
		}
		if (_hasUpdate && !suppressEvents) {
			ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
		}
		if (_hasUpdateListener && !suppressEvents) {
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
		}
		if (_loc12_ && !suppressEvents) {
			if (ASCompat.toBool(this.vars.onRepeat)) {
				ASCompatMacro.applyClosure(this.vars.onRepeat, this.vars.onRepeatParams);
			}
			if (_dispatcher != null) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
			}
		}
		if (_loc10_
			&& (_loc7_ == this.cachedStartTime || _loc8_ != this.cachedTimeScale)
			&& (_loc4_ >= this.totalDuration || this.cachedTime == 0)) {
			complete(true, suppressEvents);
		}
	}

	public function addCallback(callback:ASFunction, timeOrLabel:ASAny, params:Array<ASAny> = null):TweenLite {
		var _loc4_ = new TweenLite(callback, 0, {
			"onComplete": callback,
			"onCompleteParams": params,
			"overwrite": 0,
			"immediateRender": false
		});
		insert(_loc4_, timeOrLabel);
		return _loc4_;
	}

	public function tweenFromTo(fromTimeOrLabel:ASAny, toTimeOrLabel:ASAny, vars:ASObject = null):TweenLite {
		var _loc4_ = tweenTo(toTimeOrLabel, vars);
		_loc4_.vars.onInitParams[2] = parseTimeOrLabel(fromTimeOrLabel);
		_loc4_.duration = Math.abs(ASCompat.toNumber(ASCompat.toNumber(_loc4_.vars.currentTime) - ASCompat.toNumber(_loc4_.vars.onInitParams[2]))) / this.cachedTimeScale;
		return _loc4_;
	}

	public function removeEventListener(type:String, listener:ASFunction, useCapture:Bool = false) {
		if (_dispatcher != null) {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
	}

	override public function set_currentTime(n:Float):Float {
		if (_cyclesComplete == 0) {
			setTotalTime(n, false);
		} else if (this.yoyo && _cyclesComplete % 2 == 1) {
			setTotalTime(this.duration - n + _cyclesComplete * (this.cachedDuration + _repeatDelay), false);
		} else {
			setTotalTime(n + _cyclesComplete * (this.duration + _repeatDelay), false);
		}
		return n;
	}

	public function addEventListener(type:String, listener:ASFunction, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) {
		if (_dispatcher == null) {
			initDispatcher();
		}
		if (type == TweenEvent.UPDATE) {
			_hasUpdateListener = true;
		}
		_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function tweenTo(timeOrLabel:ASAny, vars:ASObject = null):TweenLite {
		var _loc4_:String = null;
		var _loc5_:TweenLite = null;
		var _loc3_:ASObject = {
			"ease": easeNone,
			"overwrite": 2,
			"useFrames": this.useFrames,
			"immediateRender": false
		};
		if (checkNullIteratee(vars))
			for (_tmp_ in vars.___keys()) {
				_loc4_ = _tmp_;
				_loc3_[_loc4_] = vars[_loc4_];
			}
		ASCompat.setProperty(_loc3_, "onInit", onInitTweenTo);
		ASCompat.setProperty(_loc3_, "onInitParams", ([null, this, Math.NaN] : Array<ASAny>));
		ASCompat.setProperty(_loc3_, "currentTime", parseTimeOrLabel(timeOrLabel));
		_loc5_ = new TweenLite(this, ASCompat.thisOrDefault(Math.abs(ASCompat.toNumber(_loc3_.currentTime) - this.cachedTime) / this.cachedTimeScale, 0.001),
			_loc3_);
		_loc5_.vars.onInitParams[0] = _loc5_;
		return _loc5_;
	}

	public function hasEventListener(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.hasEventListener(type);
	}

	function initDispatcher() {
		if (_dispatcher == null) {
			_dispatcher = new EventDispatcher(this);
		}
		if (Reflect.isFunction(this.vars.onStartListener)) {
			_dispatcher.addEventListener(TweenEvent.START, ASCompat.asFunction(this.vars.onStartListener), false, 0, true);
		}
		if (Reflect.isFunction(this.vars.onUpdateListener)) {
			_dispatcher.addEventListener(TweenEvent.UPDATE, ASCompat.asFunction(this.vars.onUpdateListener), false, 0, true);
			_hasUpdateListener = true;
		}
		if (Reflect.isFunction(this.vars.onCompleteListener)) {
			_dispatcher.addEventListener(TweenEvent.COMPLETE, ASCompat.asFunction(this.vars.onCompleteListener), false, 0, true);
		}
		if (Reflect.isFunction(this.vars.onRepeatListener)) {
			_dispatcher.addEventListener(TweenEvent.REPEAT, ASCompat.asFunction(this.vars.onRepeatListener), false, 0, true);
		}
		if (Reflect.isFunction(this.vars.onReverseCompleteListener)) {
			_dispatcher.addEventListener(TweenEvent.REVERSE_COMPLETE, ASCompat.asFunction(this.vars.onReverseCompleteListener), false, 0, true);
		}
	}

	@:isVar public var repeat(get, set):Int;

	public function get_repeat():Int {
		return _repeat;
	}

	public function getLabelBefore(time:Float = null):String {
		if (time == null)
			time = Math.NaN;
		if (!ASCompat.floatAsBool(time) && time != 0) {
			time = this.cachedTime;
		}
		var _loc2_ = getLabelsArray();
		var _loc3_ = _loc2_.length;
		while (--_loc3_ > -1) {
			if (ASCompat.toNumberField(_loc2_[_loc3_], "time") < time) {
				return _loc2_[_loc3_].name;
			}
		}
		return null;
	}

	public function willTrigger(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.willTrigger(type);
	}

	@:isVar public var totalProgress(get, set):Float;

	public function get_totalProgress():Float {
		return this.cachedTotalTime / this.totalDuration;
	}

	function set_totalProgress(n:Float):Float {
		setTotalTime(this.totalDuration * n, false);
		return n;
	}

	function getLabelsArray():Array<ASAny> {
		var _loc2_:String = null;
		var _loc1_:Array<ASAny> = [];
		final __ax4_iter_152:ASObject = _labels;
		if (checkNullIteratee(__ax4_iter_152))
			for (_tmp_ in __ax4_iter_152.___keys()) {
				_loc2_ = _tmp_;
				_loc1_[_loc1_.length] = {
					"time": _labels[_loc2_],
					"name": _loc2_
				};
			}
		ASCompat.ASArray.sortOn(_loc1_, "time", ASCompat.ASArray.NUMERIC);
		return _loc1_;
	}

	public function removeCallback(callback:ASFunction, timeOrLabel:ASAny = null):Bool {
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = false;
		var _loc5_ = 0;
		if (timeOrLabel == null) {
			return killTweensOf(callback, false);
		}
		if (ASCompat.typeof(timeOrLabel) == "string") {
			if (!_labels.hasOwnProperty(timeOrLabel)) {
				return false;
			}
			timeOrLabel = _labels[timeOrLabel];
		}
		_loc3_ = getTweensOf(callback, false);
		_loc5_ = _loc3_.length;
		while (--_loc5_ > -1) {
			if (_loc3_[_loc5_].cachedStartTime == timeOrLabel) {
				remove(ASCompat.dynamicAs(_loc3_[_loc5_], TweenCore));
				_loc4_ = true;
			}
		}
		return _loc4_;
	}

	@:isVar public var repeatDelay(get, set):Float;

	public function get_repeatDelay():Float {
		return _repeatDelay;
	}

	function set_repeatDelay(n:Float):Float {
		_repeatDelay = n;
		setDirtyCache(true);
		return n;
	}

	function set_repeat(n:Int):Int {
		_repeat = n;
		setDirtyCache(true);
		return n;
	}

	override public function get_totalDuration():Float {
		var _loc1_ = Math.NaN;
		if (this.cacheIsDirty) {
			_loc1_ = super.totalDuration;
			this.cachedTotalDuration = _repeat == -1 ? 999999999999 : this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat;
		}
		return this.cachedTotalDuration;
	}

	override public function complete(skipRender:Bool = false, suppressEvents:Bool = false) {
		super.complete(skipRender, suppressEvents);
		if (_dispatcher != null && !suppressEvents) {
			if (this.cachedReversed && this.cachedTotalTime == 0 && this.cachedDuration != 0) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
			} else {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
			}
		}
	}

	override public function invalidate() {
		_repeat = ASCompat.toBool(this.vars.repeat) ? Std.int(ASCompat.toNumber(this.vars.repeat)) : 0;
		_repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
		this.yoyo = this.vars.yoyo == true;
		if (this.vars.onCompleteListener != null
			|| this.vars.onUpdateListener != null
			|| this.vars.onStartListener != null
			|| this.vars.onRepeatListener != null
			|| this.vars.onReverseCompleteListener != null) {
			initDispatcher();
		}
		setDirtyCache(true);
		super.invalidate();
	}

	public function getActive(nested:Bool = true, tweens:Bool = true, timelines:Bool = false):Array<ASAny> {
		var _loc10_:Float;
		var _loc6_ = 0;
		var _loc7_:TweenCore = null;
		var _loc4_:Array<ASAny> = [];
		var _loc5_ = getChildren(nested, tweens, timelines);
		var _loc8_ = _loc5_.length;
		var _loc9_ = 0;
		_loc6_ = 0;
		while (_loc6_ < _loc8_) {
			_loc7_ = ASCompat.dynamicAs(_loc5_[_loc6_], com.greensock.core.TweenCore);
			if (!_loc7_.cachedPaused
				&& _loc7_.timeline.cachedTotalTime >= _loc7_.cachedStartTime
				&& _loc7_.timeline.cachedTotalTime < _loc7_.cachedStartTime + _loc7_.cachedTotalDuration / _loc7_.cachedTimeScale
				&& !OverwriteManager.getGlobalPaused(_loc7_.timeline)) {
				_loc4_[Std.int(_loc10_ = ASCompat.toNumber(_loc9_++))] = _loc5_[_loc6_];
			}
			_loc6_ += 1;
		}
		return _loc4_;
	}

	public function getLabelAfter(time:Float = null):String {
		if (time == null)
			time = Math.NaN;
		if (!ASCompat.floatAsBool(time) && time != 0) {
			time = this.cachedTime;
		}
		var _loc2_ = getLabelsArray();
		var _loc3_ = _loc2_.length;
		var _loc4_ = 0;
		while (_loc4_ < _loc3_) {
			if (ASCompat.toNumberField(_loc2_[_loc4_], "time") > time) {
				return _loc2_[_loc4_].name;
			}
			_loc4_ += 1;
		}
		return null;
	}
}
