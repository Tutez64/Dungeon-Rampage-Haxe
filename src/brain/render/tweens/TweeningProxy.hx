package brain.render.tweens;

import brain.event.EventListeners;
import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Stage;
import flash.events.Event;
import starling.animation.DelayedCall;
import starling.animation.Juggler;
import starling.animation.Tween;

class TweeningProxy {
	static inline final DEFAULT_FRAME_RATE:Float = 60;

	static var sJuggler:Juggler;

	static var sTicker:Shape;

	static var sLastTickTime:Int = 0;

	static var RESERVED_KEYS:ASObject;

	static var sHandlesByTarget:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	static var sHandlesByCallback:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mFacade:Facade;

	public function new(facade:Facade) {
		mFacade = facade;
		ensureTicker(mFacade.stageRef);
	}

	public static function setGlobalTimeScale(value:Float) {
		ensureTicker();
		if (sJuggler != null) {
			sJuggler.timeScale = value;
		}
	}

	static function createAdapterTween(adapter:ASObject, duration:Float, transition:ASObject):Tween {
		var _loc4_ = new Tween(adapter, duration, transition);
		_loc4_.animate("progress", 1);
		return _loc4_;
	}

	static function configureTiming(tween:Tween, vars:ASObject) {
		var _loc3_ = 0;
		tween.delay = ASCompat.toNumber(ASCompat.orValue(ASCompat.toNumber(vars.delay), 0));
		if (vars.hasOwnProperty("repeat")) {
			_loc3_ = ASCompat.toInt(vars.repeat);
			tween.repeatCount = _loc3_ < 0 ? 0 : _loc3_ + 1;
		}
		tween.repeatDelay = ASCompat.toNumber(ASCompat.orValue(ASCompat.toNumber(vars.repeatDelay), 0));
		tween.reverse = vars.yoyo == true;
	}

	static function makeVisibleSetter(target:ASObject, visible:Bool):ASFunction {
		return function() {
			if (target != null && target.hasOwnProperty("visible")) {
				ASCompat.setProperty(target, "visible", visible);
			}
		};
	}

	static function register(registry:ASDictionary<ASAny, ASAny>, key:ASObject, handle:TweenHandle) {
		var _loc4_ = (registry[key] : Vector<TweenHandle>);
		if (_loc4_ == null) {
			registry[key] = _loc4_ = new Vector<TweenHandle>((0 : UInt));
		}
		_loc4_.push(handle);
		handle.onFinished = unregister;
	}

	static function unregister(handle:TweenHandle) {
		var _loc2_ = handle.delayedCallback;
		if (_loc2_ != null) {
			removeFromRegistry(sHandlesByCallback, _loc2_, handle);
		} else if (handle.target != null) {
			removeFromRegistry(sHandlesByTarget, handle.target, handle);
		}
	}

	static function removeFromRegistry(registry:ASDictionary<ASAny, ASAny>, key:ASObject, handle:TweenHandle) {
		var _loc5_ = (registry[key] : Vector<TweenHandle>);
		if (_loc5_ == null) {
			return;
		}
		var _loc4_ = _loc5_.indexOf(handle);
		if (_loc4_ != -1) {
			_loc5_.splice(_loc4_, (1 : UInt));
		}
		if (_loc5_.length == 0) {
			registry.remove(key);
		}
	}

	static function killRegistered(registry:ASDictionary<ASAny, ASAny>, key:ASObject) {
		if (key == null) {
			return;
		}
		var _loc5_ = (registry[key] : Vector<TweenHandle>);
		if (_loc5_ == null) {
			return;
		}
		var _loc3_ = _loc5_.concat();
		var _loc4_:TweenHandle;
		if (checkNullIteratee(_loc3_))
			for (_tmp_ in _loc3_) {
				_loc4_ = _tmp_;
				_loc4_.kill();
			}
	}

	static function ensureTicker(stage:Stage = null) {
		if (sJuggler == null) {
			sJuggler = new Juggler();
			sTicker = new Shape();
			sLastTickTime = flash.Lib.getTimer();
			EventListeners.add(sTicker, "enterFrame", onTick);
		}
		if (stage != null && sTicker != null && sTicker.stage == null) {
			stage.addChild(sTicker);
			sLastTickTime = flash.Lib.getTimer();
		}
	}

	public static function shutdown() {
		if (sTicker != null) {
			EventListeners.remove(sTicker, "enterFrame", onTick);
			if (sTicker.parent != null) {
				sTicker.parent.removeChild(sTicker);
			}
			sTicker = null;
		}
		sJuggler = null;
		sLastTickTime = 0;
	}

	static function onTick(event:Event) {
		if (sJuggler == null) {
			return;
		}
		var _loc3_ = flash.Lib.getTimer();
		var _loc2_ = (_loc3_ - sLastTickTime) * 0.001;
		sLastTickTime = _loc3_;
		if (_loc2_ > 0) {
			sJuggler.advanceTime(_loc2_);
		}
	}

	public function tweenMaxTo(target:ASObject, duration:Float, vars:ASObject):TweenHandle {
		return createTween(target, duration, vars, null);
	}

	public function tweenLiteTo(target:ASObject, duration:Float, vars:ASObject):TweenHandle {
		return createTween(target, duration, vars, null);
	}

	public function tweenFromTo(target:ASObject, duration:Float, fromVars:ASObject, toVars:ASObject):TweenHandle {
		return createTween(target, duration, toVars, if (ASCompat.toBool(fromVars)) fromVars else {});
	}

	public function delayedCall(delay:Float, onComplete:ASFunction, onCompleteParams:Array<ASAny> = null, useFrames:Bool = false):TweenHandle {
		if (onComplete == null) {
			Logger.warn("TweeningProxy.delayedCall: null callback ignored");
			return null;
		}
		if (useFrames) {
			delay /= frameRate;
		}
		var _loc5_ = new TweenHandle(new DelayedCall(onComplete, delay, onCompleteParams));
		_loc5_.refreshSpan();
		register(sHandlesByCallback, onComplete, _loc5_);
		if (delay <= 0) {
			_loc5_.complete();
		} else {
			_loc5_.attachToJuggler(sJuggler);
		}
		return _loc5_;
	}

	public function createTimeline(vars:ASObject = null):TweenHandle {
		var _loc2_:ASObject;
		var __ax4_iter_421:ASAny;
		var _loc7_:String = null;
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc8_:TweenHandle = null;
		var _loc3_ = new TweenTimeline();
		var _loc4_ = new TweenHandle(_loc3_);
		if (ASCompat.toBool(vars)) {
			_loc3_.onComplete = ASCompat.asFunction(vars.onComplete);
			_loc3_.onCompleteArgs = ASCompat.dynamicAs(vars.onCompleteParams, Array);
			if (ASCompat.toBool(vars.tweens)) {
				_loc7_ = ASCompat.toBool(vars.align) ? ASCompat.toString(vars.align) : "normal";
				_loc5_ = ASCompat.toNumber(ASCompat.orValue(ASCompat.toNumber(vars.stagger), 0));
				_loc6_ = 0;
				__ax4_iter_421 = vars.tweens;
				if (checkNullIteratee(__ax4_iter_421))
					for (_tmp_ in __ax4_iter_421) {
						_loc2_ = _tmp_;
						_loc8_ = ASCompat.dynamicAs(_loc2_, TweenHandle);
						if (_loc8_ == null) {
							Logger.warn("TweeningProxy.createTimeline: ignoring non-TweenHandle entry in \'tweens\'");
						} else {
							_loc3_.insert(_loc8_, _loc6_);
							if (_loc7_ == "sequence") {
								_loc6_ += _loc8_.totalSpan;
							}
							_loc6_ += _loc5_;
						}
					}
			}
			if (vars.paused == true) {
				_loc4_.pause();
			}
		}
		_loc4_.attachToJuggler(sJuggler);
		return _loc4_;
	}

	public function appendTween(timeline:TweenHandle, tween:TweenHandle):TweenHandle {
		var _loc3_ = requireTimeline(timeline, "appendTween");
		if (_loc3_ != null && tween != null) {
			_loc3_.append(tween);
		}
		return timeline;
	}

	public function insertTween(timeline:TweenHandle, tween:TweenHandle, position:ASObject = null):TweenHandle {
		var _loc4_ = requireTimeline(timeline, "insertTween");
		if (_loc4_ != null && tween != null) {
			_loc4_.insert(tween, position);
		}
		return timeline;
	}

	public function addLabel(timeline:TweenHandle, label:String, position:ASObject = null) {
		var _loc4_ = requireTimeline(timeline, "addLabel");
		if (_loc4_ != null) {
			_loc4_.addLabel(label, _loc4_.resolvePosition(position));
		}
	}

	public function killTweensOf(target:ASObject) {
		killRegistered(sHandlesByTarget, target);
	}

	public function killDelayedCallsTo(callback:ASFunction) {
		killRegistered(sHandlesByCallback, callback);
	}

	public function killTween(tween:TweenHandle) {
		if (tween != null) {
			tween.kill();
		}
	}

	public function playTween(tween:TweenHandle) {
		if (tween != null) {
			tween.play();
		}
	}

	public function pauseTween(tween:TweenHandle) {
		if (tween != null) {
			tween.pause();
		}
	}

	public function resumeTween(tween:TweenHandle) {
		if (tween != null) {
			tween.resume();
		}
	}

	public function reverseTween(tween:TweenHandle) {
		if (tween != null) {
			tween.reverse();
		}
	}

	public function completeTween(tween:TweenHandle) {
		if (tween != null) {
			tween.complete();
		}
	}

	public function getCurrentProgress(tween:TweenHandle):Float {
		return tween != null ? tween.progress : 1;
	}

	function createTween(target:ASObject, duration:Float, vars:ASObject, fromVars:ASObject):TweenHandle {
		var _loc14_:ASAny = ASCompat.UNDEFINED;
		var _loc10_:TintAdapter = null;
		var _loc15_:GlowFilterAdapter = null;
		var _loc7_:ColorMatrixFilterAdapter = null;
		vars = if (ASCompat.toBool(vars)) vars else {};
		if (target == null) {
			Logger.warn("TweeningProxy: tweening a null target; only callbacks will run");
		}
		var _loc11_:ASObject = Reflect.isFunction(vars.ease) ? vars.ease : Quad.easeOut;
		var _loc17_ = new Tween(target, duration, _loc11_);
		var _loc9_ = new TweenHandle(_loc17_, target);
		var _loc12_ = new Vector<Tween>((0 : UInt));
		var _loc13_ = ASCompat.dynamicAs(target, DisplayObject);
		var _loc16_:String;
		if (checkNullIteratee(vars))
			for (_tmp_ in vars.___keys()) {
				_loc16_ = _tmp_;
				if (!ASCompat.toBool(RESERVED_KEYS[_loc16_])) {
					_loc14_ = vars[_loc16_];
					switch (_loc16_) {
						case "tint" | "removeTint":
							if (!(_loc16_ == "removeTint" && _loc14_ != true)) {
								if (requireFlashTarget(_loc13_, _loc16_)) {
									_loc10_ = new TintAdapter(_loc13_, (ASCompat.toInt(_loc14_) : UInt), _loc16_ == "removeTint");
									_loc12_.push(createAdapterTween(_loc10_, duration, _loc11_));
									_loc9_.addKillHook(_loc10_.revert);
								}
							}

						case "glowFilter":
							if (requireFlashTarget(_loc13_, _loc16_)) {
								_loc15_ = new GlowFilterAdapter(_loc13_, _loc14_);
								_loc12_.push(createAdapterTween(_loc15_, duration, _loc11_));
								_loc9_.addCompleteHook(_loc15_.finish);
								_loc9_.addKillHook(_loc15_.revert);
							}

						case "colorMatrixFilter":
							if (requireFlashTarget(_loc13_, _loc16_)) {
								_loc7_ = new ColorMatrixFilterAdapter(_loc13_, ASCompat.toBool(fromVars) ? fromVars.colorMatrixFilter : null, _loc14_);
								_loc12_.push(createAdapterTween(_loc7_, duration, _loc11_));
								_loc9_.addCompleteHook(_loc7_.finish);
								_loc9_.addKillHook(_loc7_.revert);
							}

						case "visible":
							_loc9_.addCompleteHook(makeVisibleSetter(target, _loc14_ == true));

						default:
							if (Std.isOfType(_loc14_, Float) || Std.isOfType(_loc14_, Int) || Std.isOfType(_loc14_, Int)) {
								if (target != null && ASCompat.toBool(fromVars) && fromVars.hasOwnProperty(_loc16_)) {
									target[_loc16_] = ASCompat.toNumber(fromVars[_loc16_]);
								}
								_loc17_.animate(_loc16_, ASCompat.toNumber(_loc14_));
							} else {
								Logger.warn("TweeningProxy: ignoring non-numeric tween var \'" + _loc16_ + "\'");
							}
					}
				}
			}
		configureTiming(_loc17_, vars);
		var _loc5_:Tween;
		if (checkNullIteratee(_loc12_))
			for (_tmp_ in _loc12_) {
				_loc5_ = _tmp_;
				configureTiming(_loc5_, vars);
				_loc9_.addSideTween(_loc5_);
			}
		_loc9_.refreshSpan();
		var _loc8_ = ASCompat.coerceFunction(Reflect.isFunction(vars.onComplete) ? ASCompat.coerceFunction(vars.onComplete) : null);
		var _loc6_:Array<ASAny> = ASCompat.coerce(Std.isOfType(vars.onCompleteParams, Array) ? ASCompat.coerce(vars.onCompleteParams, Array) : null, Array);
		if (_loc8_ == null && Reflect.isFunction(vars.onCompleteListener)) {
			_loc8_ = ASCompat.asFunction(vars.onCompleteListener);
			_loc6_ = ASCompat.coerce(Std.isOfType(vars.onCompleteListenerParams, Array) ? ASCompat.coerce(vars.onCompleteListenerParams, Array) : null, Array);
		}
		_loc9_.setCallbacks(ASCompat.asFunction(vars.onStart), ASCompat.dynamicAs(vars.onStartParams, Array), ASCompat.asFunction(vars.onUpdate),
			ASCompat.dynamicAs(vars.onUpdateParams, Array), _loc8_, _loc6_);
		if (target != null) {
			register(sHandlesByTarget, target, _loc9_);
		}
		if (duration <= 0 && _loc17_.delay <= 0) {
			_loc9_.complete();
		} else {
			_loc9_.attachToJuggler(sJuggler);
		}
		return _loc9_;
	}

	function requireFlashTarget(flashTarget:DisplayObject, key:String):Bool {
		if (flashTarget == null) {
			Logger.warn("TweeningProxy: \'" + key + "\' needs a flash.display.DisplayObject target; ignored");
			return false;
		}
		return true;
	}

	function requireTimeline(handle:TweenHandle, operation:String):TweenTimeline {
		var _loc3_ = handle != null ? handle.timeline : null;
		if (_loc3_ == null) {
			Logger.warn("TweeningProxy." + operation + ": handle is not a timeline");
		}
		return _loc3_;
	}

	@:isVar var frameRate(get, never):Float;

	function get_frameRate():Float {
		return mFacade != null && mFacade.stageRef != null ? mFacade.stageRef.frameRate : 60;
	}

	static function __init__() {
		RESERVED_KEYS = {
			"ease": true,
			"delay": true,
			"repeat": true,
			"yoyo": true,
			"repeatDelay": true,
			"onStart": true,
			"onStartParams": true,
			"onUpdate": true,
			"onUpdateParams": true,
			"onComplete": true,
			"onCompleteParams": true,
			"onCompleteListener": true,
			"onCompleteListenerParams": true,
			"immediateRender": true,
			"overwrite": true,
			"useFrames": true,
			"paused": true
		};
	}
}
