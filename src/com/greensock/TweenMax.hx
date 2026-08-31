package com.greensock;

import com.greensock.core.*;
import com.greensock.events.TweenEvent;
import com.greensock.plugins.*;
import flash.display.*;
import flash.events.*;
import flash.utils.*;

class TweenMax extends TweenLite implements IEventDispatcher {
	public static inline final version:Float = 11.69;

	static var _overwriteMode:Int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init(2);

	public static var killTweensOf:ASFunction = TweenLite.killTweensOf;

	public static var killDelayedCallsTo:ASFunction = TweenLite.killTweensOf;

	static final ___init = {
		TweenPlugin.activate([
			AutoAlphaPlugin,
			EndArrayPlugin,
			FramePlugin,
			RemoveTintPlugin,
			TintPlugin,
			VisiblePlugin,
			VolumePlugin,
			BevelFilterPlugin,
			BezierPlugin,
			BezierThroughPlugin,
			BlurFilterPlugin,
			ColorMatrixFilterPlugin,
			ColorTransformPlugin,
			DropShadowFilterPlugin,
			FrameLabelPlugin,
			GlowFilterPlugin,
			HexColorsPlugin,
			RoundPropsPlugin,
			ShortRotationPlugin,
			{}
		]);
		null;
	};

	var _cyclesComplete:Int = 0;

	var _dispatcher:EventDispatcher;

	var _hasUpdateListener:Bool = false;

	var _easeType:Int = 0;

	var _repeatDelay:Float = 0;

	public var yoyo:Bool = false;

	var _easePower:Int = 0;

	var _repeat:Int = 0;

	public function new(target:ASObject, duration:Float, vars:ASObject) {
		super(target, duration, vars);
		if (TweenLite.version < 11.2) {
			throw new Error("TweenMax error! Please update your TweenLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.");
		}
		this.yoyo = ASCompat.toBool(this.vars.yoyo);
		_repeat = ASCompat.toInt(this.vars.repeat);
		_repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
		this.cacheIsDirty = true;
		if (ASCompat.toBool(this.vars.onCompleteListener)
			|| ASCompat.toBool(this.vars.onInitListener)
			|| ASCompat.toBool(this.vars.onUpdateListener)
			|| ASCompat.toBool(this.vars.onStartListener)
			|| ASCompat.toBool(this.vars.onRepeatListener)
			|| ASCompat.toBool(this.vars.onReverseCompleteListener)) {
			initDispatcher();
			if (duration == 0 && _delay == 0) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
			}
		}
		if (ASCompat.toBool(this.vars.timeScale) && !Std.isOfType(this.target, TweenCore)) {
			this.cachedTimeScale = ASCompat.toNumberField(this.vars, "timeScale");
		}
	}

	@:isVar public static var globalTimeScale(get, set):Float;

	static public function set_globalTimeScale(n:Float):Float {
		if (n == 0) {
			n = 0.0001;
		}
		if (TweenLite.rootTimeline == null) {
			TweenLite.to({}, 0, {});
		}
		var _loc2_ = TweenLite.rootTimeline;
		var _loc3_ = flash.Lib.getTimer() * 0.001;
		_loc2_.cachedStartTime = _loc3_ - (_loc3_ - _loc2_.cachedStartTime) * _loc2_.cachedTimeScale / n;
		_loc2_ = TweenLite.rootFramesTimeline;
		_loc3_ = TweenLite.rootFrame;
		_loc2_.cachedStartTime = _loc3_ - (_loc3_ - _loc2_.cachedStartTime) * _loc2_.cachedTimeScale / n;
		TweenLite.rootFramesTimeline.cachedTimeScale = TweenLite.rootTimeline.cachedTimeScale = n;
		return n;
	}

	public static function fromTo(target:ASObject, duration:Float, fromVars:ASObject, toVars:ASObject):TweenMax {
		if (ASCompat.toBool(toVars.isGSVars)) {
			toVars = toVars.vars;
		}
		if (ASCompat.toBool(fromVars.isGSVars)) {
			fromVars = fromVars.vars;
		}
		ASCompat.setProperty(toVars, "startAt", fromVars);
		if (ASCompat.toBool(fromVars.immediateRender)) {
			ASCompat.setProperty(toVars, "immediateRender", true);
		}
		return new TweenMax(target, duration, toVars);
	}

	public static function allFromTo(targets:Array<ASAny>, duration:Float, fromVars:ASObject, toVars:ASObject, stagger:Float = 0,
			onCompleteAll:ASFunction = null, onCompleteAllParams:Array<ASAny> = null):Array<ASAny> {
		if (ASCompat.toBool(toVars.isGSVars)) {
			toVars = toVars.vars;
		}
		if (ASCompat.toBool(fromVars.isGSVars)) {
			fromVars = fromVars.vars;
		}
		ASCompat.setProperty(toVars, "startAt", fromVars);
		if (ASCompat.toBool(fromVars.immediateRender)) {
			ASCompat.setProperty(toVars, "immediateRender", true);
		}
		return allTo(targets, duration, toVars, stagger, onCompleteAll, onCompleteAllParams);
	}

	public static function pauseAll(tweens:Bool = true, delayedCalls:Bool = true) {
		changePause(true, tweens, delayedCalls);
	}

	public static function getTweensOf(target:ASObject):Array<ASAny> {
		var _loc6_:Float;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc2_:Array<ASAny> = ASCompat.dynamicAs(TweenLite.masterList[target], Array);
		var _loc3_:Array<ASAny> = [];
		if (_loc2_ != null) {
			_loc4_ = _loc2_.length;
			_loc5_ = 0;
			while (--_loc4_ > -1) {
				if (!cast(_loc2_[_loc4_], TweenLite).gc) {
					_loc3_[Std.int(_loc6_ = ASCompat.toNumber(_loc5_++))] = _loc2_[_loc4_];
				}
			}
		}
		return _loc3_;
	}

	static function get_globalTimeScale():Float {
		return TweenLite.rootTimeline == null ? 1 : TweenLite.rootTimeline.cachedTimeScale;
	}

	public static function killChildTweensOf(parent:DisplayObjectContainer, complete:Bool = false) {
		var _loc4_:ASObject = null;
		var _loc5_:DisplayObjectContainer = null;
		var _loc3_ = getAllTweens();
		var _loc6_ = _loc3_.length;
		while (--_loc6_ > -1) {
			_loc4_ = _loc3_[_loc6_].target;
			if (Std.isOfType(_loc4_, DisplayObject)) {
				_loc5_ = ASCompat.dynamicAs(_loc4_.parent, flash.display.DisplayObjectContainer);
				while (_loc5_ != null) {
					if (_loc5_ == parent) {
						if (complete) {
							_loc3_[_loc6_].complete(false);
						} else {
							_loc3_[_loc6_].setEnabled(false, false);
						}
					}
					_loc5_ = _loc5_.parent;
				}
			}
		}
	}

	public static function delayedCall(delay:Float, onComplete:ASFunction, onCompleteParams:Array<ASAny> = null, useFrames:Bool = false):TweenMax {
		return new TweenMax(onComplete, 0, {
			"delay": delay,
			"onComplete": onComplete,
			"onCompleteParams": onCompleteParams,
			"immediateRender": false,
			"useFrames": useFrames,
			"overwrite": 0
		});
	}

	public static function isTweening(target:ASObject):Bool {
		var _loc4_:TweenLite = null;
		var _loc2_ = getTweensOf(target);
		var _loc3_ = _loc2_.length;
		while (--_loc3_ > -1) {
			_loc4_ = ASCompat.dynamicAs(_loc2_[_loc3_], com.greensock.TweenLite);
			if (_loc4_.active || _loc4_.cachedStartTime == _loc4_.timeline.cachedTime && _loc4_.timeline.active) {
				return true;
			}
		}
		return false;
	}

	public static function killAll(complete:Bool = false, tweens:Bool = true, delayedCalls:Bool = true) {
		var _loc5_ = false;
		var _loc4_ = getAllTweens();
		var _loc6_ = _loc4_.length;
		while (--_loc6_ > -1) {
			_loc5_ = _loc4_[_loc6_].target == _loc4_[_loc6_].vars.onComplete;
			if (_loc5_ == delayedCalls || _loc5_ != tweens) {
				if (complete) {
					_loc4_[_loc6_].complete(false);
				} else {
					_loc4_[_loc6_].setEnabled(false, false);
				}
			}
		}
	}

	static function changePause(pause:Bool, tweens:Bool = true, delayedCalls:Bool = false) {
		var _loc5_ = false;
		var _loc4_ = getAllTweens();
		var _loc6_ = _loc4_.length;
		while (--_loc6_ > -1) {
			_loc5_ = cast(_loc4_[_loc6_], TweenLite).target == cast(_loc4_[_loc6_], TweenLite).vars.onComplete;
			if (_loc5_ == delayedCalls || _loc5_ != tweens) {
				cast(_loc4_[_loc6_], TweenCore).paused = pause;
			}
		}
	}

	public static function from(target:ASObject, duration:Float, vars:ASObject):TweenMax {
		if (ASCompat.toBool(vars.isGSVars)) {
			vars = vars.vars;
		}
		ASCompat.setProperty(vars, "runBackwards", true);
		if (!vars.hasOwnProperty("immediateRender")) {
			ASCompat.setProperty(vars, "immediateRender", true);
		}
		return new TweenMax(target, duration, vars);
	}

	public static function allFrom(targets:Array<ASAny>, duration:Float, vars:ASObject, stagger:Float = 0, onCompleteAll:ASFunction = null,
			onCompleteAllParams:Array<ASAny> = null):Array<ASAny> {
		if (ASCompat.toBool(vars.isGSVars)) {
			vars = vars.vars;
		}
		ASCompat.setProperty(vars, "runBackwards", true);
		if (!vars.hasOwnProperty("immediateRender")) {
			ASCompat.setProperty(vars, "immediateRender", true);
		}
		return allTo(targets, duration, vars, stagger, onCompleteAll, onCompleteAllParams);
	}

	public static function getAllTweens():Array<ASAny> {
		var _loc8_:Float;
		var _loc4_:Array<ASAny> = null;
		var _loc5_ = 0;
		var _loc1_ = TweenLite.masterList;
		var _loc2_ = 0;
		var _loc3_:Array<ASAny> = [];
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc4_ = ASCompat.dynamicAs(_tmp_, Array);
				_loc5_ = _loc4_.length;
				while (--_loc5_ > -1) {
					if (!cast(_loc4_[_loc5_], TweenLite).gc) {
						_loc3_[Std.int(_loc8_ = ASCompat.toNumber(_loc2_++))] = _loc4_[_loc5_];
					}
				}
			}
		return _loc3_;
	}

	public static function resumeAll(tweens:Bool = true, delayedCalls:Bool = true) {
		changePause(false, tweens, delayedCalls);
	}

	public static function to(target:ASObject, duration:Float, vars:ASObject):TweenMax {
		return new TweenMax(target, duration, vars);
	}

	public static function allTo(targets:Array<ASAny>, duration:Float, vars:ASObject, stagger:Float = 0, onCompleteAll:ASFunction = null,
			onCompleteAllParams:Array<ASAny> = null):Array<ASAny> {
		var lastIndex:Int;
		var curDelay:Float;
		var i = 0;
		var varsDup:ASObject = null;
		var p:String = null;
		var onCompleteProxy:ASFunction = null;
		var onCompleteParamsProxy:Array<ASAny> = null;
		var l = targets.length;
		var a:Array<ASAny> = [];
		if (ASCompat.toBool(vars.isGSVars)) {
			vars = vars.vars;
		}
		curDelay = vars.hasOwnProperty("delay") ? ASCompat.toNumber(vars.delay) : 0;
		onCompleteProxy = ASCompat.asFunction(vars.onComplete);
		onCompleteParamsProxy = ASCompat.dynamicAs(vars.onCompleteParams, Array);
		lastIndex = l - 1;
		i = 0;
		while (i < l) {
			varsDup = {};
			if (checkNullIteratee(vars))
				for (_tmp_ in vars.___keys()) {
					p = _tmp_;
					varsDup[p] = vars[p];
				}
			ASCompat.setProperty(varsDup, "delay", curDelay);
			if (i == lastIndex && onCompleteAll != null) {
				ASCompat.setProperty(varsDup, "onComplete", function() {
					if (onCompleteProxy != null) {
						ASCompatMacro.applyClosure(onCompleteProxy, onCompleteParamsProxy);
					}
					ASCompatMacro.applyClosure(onCompleteAll, onCompleteAllParams);
				});
			}
			a[i] = new TweenMax(targets[i], duration, varsDup);
			curDelay += stagger;
			i += 1;
		}
		return a;
	}

	public function dispatchEvent(e:Event):Bool {
		return _dispatcher == null ? false : _dispatcher.dispatchEvent(e);
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

	override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) {
		var _loc6_ = false;
		var _loc7_ = false;
		var _loc8_ = false;
		var _loc10_ = Math.NaN;
		var _loc11_ = 0;
		var _loc12_ = 0;
		var _loc13_ = Math.NaN;
		var _loc4_ = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
		var _loc5_ = this.cachedTotalTime;
		if (time >= _loc4_) {
			this.cachedTotalTime = _loc4_;
			this.cachedTime = this.cachedDuration;
			this.ratio = 1;
			_loc6_ = true;
			if (this.cachedDuration == 0) {
				if ((time == 0 || _rawPrevTime < 0) && _rawPrevTime != time) {
					force = true;
				}
				_rawPrevTime = time;
			}
		} else if (time <= 0) {
			if (time < 0) {
				this.active = false;
				if (this.cachedDuration == 0) {
					if (_rawPrevTime >= 0) {
						force = true;
						_loc6_ = true;
					}
					_rawPrevTime = time;
				}
			} else if (time == 0 && !this.initted) {
				force = true;
			}
			this.cachedTotalTime = this.cachedTime = this.ratio = 0;
			if (this.cachedReversed && _loc5_ != 0) {
				_loc6_ = true;
			}
		} else {
			this.cachedTotalTime = this.cachedTime = time;
			_loc8_ = true;
		}
		if (_repeat != 0) {
			_loc10_ = this.cachedDuration + _repeatDelay;
			_loc11_ = _cyclesComplete;
			_cyclesComplete = Std.int(this.cachedTotalTime / _loc10_) >> 0;
			if (_cyclesComplete == this.cachedTotalTime / _loc10_) {
				--_cyclesComplete;
			}
			if (_loc11_ != _cyclesComplete) {
				_loc7_ = true;
			}
			if (_loc6_) {
				if (this.yoyo && _repeat % 2 != 0) {
					this.cachedTime = this.ratio = 0;
				}
			} else if (time > 0) {
				this.cachedTime = (this.cachedTotalTime / _loc10_ - _cyclesComplete) * _loc10_;
				if (this.yoyo && _cyclesComplete % 2 != 0) {
					this.cachedTime = this.cachedDuration - this.cachedTime;
				} else if (this.cachedTime >= this.cachedDuration) {
					this.cachedTime = this.cachedDuration;
					this.ratio = 1;
					_loc8_ = false;
				}
				if (this.cachedTime <= 0) {
					this.cachedTime = this.ratio = 0;
					_loc8_ = false;
				}
			} else {
				_cyclesComplete = 0;
			}
		}
		if (_loc5_ == this.cachedTotalTime && !force) {
			return;
		}
		if (!this.initted) {
			init();
		}
		if (!this.active && !this.cachedPaused) {
			this.active = true;
		}
		if (_loc8_) {
			if (_easeType != 0) {
				_loc12_ = _easePower;
				_loc13_ = this.cachedTime / this.cachedDuration;
				if (_easeType == 2) {
					this.ratio = _loc13_ = 1 - _loc13_;
					while (--_loc12_ > -1) {
						this.ratio = _loc13_ * this.ratio;
					}
					this.ratio = 1 - this.ratio;
				} else if (_easeType == 1) {
					this.ratio = _loc13_;
					while (--_loc12_ > -1) {
						this.ratio = _loc13_ * this.ratio;
					}
				} else if (_loc13_ < 0.5) {
					this.ratio = _loc13_ = _loc13_ * 2;
					while (--_loc12_ > -1) {
						this.ratio = _loc13_ * this.ratio;
					}
					this.ratio *= 0.5;
				} else {
					this.ratio = _loc13_ = (1 - _loc13_) * 2;
					while (--_loc12_ > -1) {
						this.ratio = _loc13_ * this.ratio;
					}
					this.ratio = 1 - 0.5 * this.ratio;
				}
			} else {
				this.ratio = ASCompat.toNumber(_ease(this.cachedTime, 0, 1, this.cachedDuration));
			}
		}
		if (_loc5_ == 0 && (this.cachedTotalTime != 0 || this.cachedDuration == 0) && !suppressEvents) {
			if (ASCompat.toBool(this.vars.onStart)) {
				ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
			}
			if (_dispatcher != null) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
			}
		}
		var _loc9_ = this.cachedPT1;
		while (_loc9_ != null) {
			_loc9_.target[_loc9_.property] = _loc9_.start + this.ratio * _loc9_.change;
			_loc9_ = _loc9_.nextNode;
		}
		if (_hasUpdate && !suppressEvents) {
			ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
		}
		if (_hasUpdateListener && !suppressEvents) {
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
		}
		if (_loc7_ && !suppressEvents && !this.gc) {
			if (ASCompat.toBool(this.vars.onRepeat)) {
				ASCompatMacro.applyClosure(this.vars.onRepeat, this.vars.onRepeatParams);
			}
			if (_dispatcher != null) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
			}
		}
		if (_loc6_ && !this.gc) {
			if (_hasPlugins && this.cachedPT1 != null) {
				TweenLite.onPluginEvent("onComplete", this);
			}
			complete(true, suppressEvents);
		}
	}

	override public function set_totalDuration(n:Float):Float {
		if (_repeat == -1) {
			return n;
		}
		this.duration = (n - _repeat * _repeatDelay) / (_repeat + 1);
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

	override function init() {
		var _loc1_:TweenMax = null;
		if (ASCompat.toBool(this.vars.startAt)) {
			ASCompat.setProperty(this.vars.startAt, "overwrite", 0);
			ASCompat.setProperty(this.vars.startAt, "immediateRender", true);
			_loc1_ = new TweenMax(this.target, 0, this.vars.startAt);
		}
		if (_dispatcher != null) {
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.INIT));
		}
		super.init();
		if (TweenLite.fastEaseLookup.exists(_ease)) {
			_easeType = ASCompat.toInt(ASCompat.dynGetIndex(TweenLite.fastEaseLookup[_ease], 0));
			_easePower = ASCompat.toInt(ASCompat.dynGetIndex(TweenLite.fastEaseLookup[_ease], 1));
		}
	}

	public function removeEventListener(type:String, listener:ASFunction, useCapture:Bool = false) {
		if (_dispatcher != null) {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
	}

	public function setDestination(property:String, value:ASAny, adjustStartValues:Bool = true) {
		var _loc4_:ASObject = {};
		_loc4_[property] = value;
		updateTo(_loc4_, !adjustStartValues);
	}

	public function willTrigger(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.willTrigger(type);
	}

	public function hasEventListener(type:String):Bool {
		return _dispatcher == null ? false : _dispatcher.hasEventListener(type);
	}

	function initDispatcher() {
		if (_dispatcher == null) {
			_dispatcher = new EventDispatcher(this);
		}
		if (Reflect.isFunction(this.vars.onInitListener)) {
			_dispatcher.addEventListener(TweenEvent.INIT, ASCompat.asFunction(this.vars.onInitListener), false, 0, true);
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

	@:isVar public var currentProgress(get, set):Float;

	public function set_currentProgress(n:Float):Float {
		if (_cyclesComplete == 0) {
			setTotalTime(this.duration * n, false);
		} else {
			setTotalTime(this.duration * n + _cyclesComplete * this.cachedDuration, false);
		}
		return n;
	}

	@:isVar public var totalProgress(get, set):Float;

	public function get_totalProgress():Float {
		return this.cachedTotalTime / this.totalDuration;
	}

	function set_totalProgress(n:Float):Float {
		setTotalTime(this.totalDuration * n, false);
		return n;
	}

	public function updateTo(vars:ASObject, resetDuration:Bool = false) {
		var _loc4_:String = null;
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_:PropTween = null;
		var _loc8_ = Math.NaN;
		var _loc3_ = this.ratio;
		if (resetDuration && this.timeline != null && this.cachedStartTime < this.timeline.cachedTime) {
			this.cachedStartTime = this.timeline.cachedTime;
			this.setDirtyCache(false);
			if (this.gc) {
				this.setEnabled(true, false);
			} else {
				this.timeline.insert(this, this.cachedStartTime - _delay);
			}
		}
		if (checkNullIteratee(vars))
			for (_tmp_ in vars.___keys()) {
				_loc4_ = _tmp_;
				this.vars[_loc4_] = vars[_loc4_];
			}
		if (this.initted) {
			if (resetDuration) {
				this.initted = false;
			} else {
				if (_notifyPluginsOfEnabled && this.cachedPT1 != null) {
					TweenLite.onPluginEvent("onDisable", this);
				}
				if (this.cachedTime / this.cachedDuration > 0.998) {
					_loc5_ = this.cachedTime;
					this.renderTime(0, true, false);
					this.initted = false;
					this.renderTime(_loc5_, true, false);
				} else if (this.cachedTime > 0) {
					this.initted = false;
					init();
					_loc6_ = 1 / (1 - _loc3_);
					_loc7_ = this.cachedPT1;
					while (_loc7_ != null) {
						_loc8_ = _loc7_.start + _loc7_.change;
						_loc7_.change *= _loc6_;
						_loc7_.start = _loc8_ - _loc7_.change;
						_loc7_ = _loc7_.nextNode;
					}
				}
			}
		}
	}

	function get_currentProgress():Float {
		return this.cachedTime / this.duration;
	}

	@:isVar public var repeat(get, set):Int;

	public function get_repeat():Int {
		return _repeat;
	}

	override public function set_currentTime(n:Float):Float {
		if (_cyclesComplete != 0) {
			if (this.yoyo && _cyclesComplete % 2 == 1) {
				n = this.duration - n + _cyclesComplete * (this.cachedDuration + _repeatDelay);
			} else {
				n += _cyclesComplete * (this.duration + _repeatDelay);
			}
		}
		setTotalTime(n, false);
		return n;
	}

	@:isVar public var repeatDelay(get, set):Float;

	public function get_repeatDelay():Float {
		return _repeatDelay;
	}

	public function killProperties(names:Array<ASAny>) {
		var _loc2_:ASObject = {};
		var _loc3_ = names.length;
		while (--_loc3_ > -1) {
			_loc2_[names[_loc3_]] = true;
		}
		killVars(_loc2_);
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

	override public function complete(skipRender:Bool = false, suppressEvents:Bool = false) {
		super.complete(skipRender, suppressEvents);
		if (!suppressEvents && _dispatcher != null) {
			if (this.cachedTotalTime == this.cachedTotalDuration && !this.cachedReversed) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
			} else if (this.cachedReversed && this.cachedTotalTime == 0) {
				_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
			}
		}
	}

	override public function invalidate() {
		this.yoyo = this.vars.yoyo == true;
		_repeat = ASCompat.toBool(this.vars.repeat) ? Std.int(ASCompat.toNumber(this.vars.repeat)) : 0;
		_repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
		_hasUpdateListener = false;
		if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
			initDispatcher();
		}
		setDirtyCache(true);
		super.invalidate();
	}

	function get_timeScale():Float {
		return this.cachedTimeScale;
	}

	override public function get_totalDuration():Float {
		if (this.cacheIsDirty) {
			this.cachedTotalDuration = _repeat == -1 ? 999999999999 : this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat;
			this.cacheIsDirty = false;
		}
		return this.cachedTotalDuration;
	}
}
