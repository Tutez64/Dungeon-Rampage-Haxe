package starling.animation;

import starling.events.EventDispatcher;
import starling.utils.Color;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class Tween extends EventDispatcher implements IAnimatable {
	static inline final HINT_MARKER = "#";

	static var sTweenPool:Vector<Tween> = new Vector((0 : UInt));

	var _target:ASObject;

	var _transitionFunc:ASFunction;

	var _transitionName:String;

	var _properties:Vector<String>;

	var _startValues:Vector<Float>;

	var _endValues:Vector<Float>;

	var _updateFuncs:Vector<ASFunction>;

	var _onStart:ASFunction;

	var _onUpdate:ASFunction;

	var _onRepeat:ASFunction;

	var _onComplete:ASFunction;

	var _onRepeatStart:ASFunction;

	var _onRepeatFinish:ASFunction;

	var _onStartArgs:Array<ASAny>;

	var _onUpdateArgs:Array<ASAny>;

	var _onRepeatArgs:Array<ASAny>;

	var _onCompleteArgs:Array<ASAny>;

	var _onRepeatStartArgs:Array<ASAny>;

	var _onRepeatFinishArgs:Array<ASAny>;

	var _totalTime:Float = Math.NaN;

	var _currentTime:Float = Math.NaN;

	var _progress:Float = Math.NaN;

	var _delay:Float = Math.NaN;

	var _roundToInt:Bool = false;

	var _nextTween:Tween;

	var _repeatCount:Int = 0;

	var _repeatDelay:Float = Math.NaN;

	var _repeatReverseDelay:Float = Math.NaN;

	var _reverse:Bool = false;

	var _currentCycle:Int = 0;

	public function new(target:ASObject, time:Float, transition:ASObject = "linear") {
		super();
		reset(target, time, transition);
	}

	@:allow(starling.animation) static function getPropertyHint(property:String):String {
		if (property.indexOf("color") != -1 || property.indexOf("Color") != -1) {
			return "rgb";
		}
		var _loc2_ = property.indexOf("#");
		if (_loc2_ != -1) {
			return property.substr(_loc2_ + 1);
		}
		return null;
	}

	@:allow(starling.animation) static function getPropertyName(property:String):String {
		var _loc2_ = property.indexOf("#");
		if (_loc2_ != -1) {
			return property.substring(0, _loc2_);
		}
		return property;
	}

	/*starling_internal*/
	public static function fromPool(target:ASObject, time:Float, transition:ASObject = "linear"):Tween {
		if (sTweenPool.length != 0) {
			return sTweenPool.pop().reset(target, time, transition);
		}
		return new Tween(target, time, transition);
	}

	/*starling_internal*/
	public static function toPool(tween:Tween) {
		tween._onStart = tween._onUpdate = tween._onRepeat = tween._onComplete = tween._onRepeatStart = tween._onRepeatFinish = null;
		tween._onStartArgs = tween._onUpdateArgs = tween._onRepeatArgs = tween._onCompleteArgs = tween._onRepeatStartArgs = tween._onRepeatFinishArgs = null;
		tween._target = null;
		tween._transitionFunc = null;
		tween.removeEventListeners();
		sTweenPool.push(tween);
	}

	public function reset(target:ASObject, time:Float, transition:ASObject = "linear"):Tween {
		_target = target;
		_currentTime = 0;
		_totalTime = Math.max(0.0001, time);
		_progress = 0;
		_delay = _repeatDelay = _repeatReverseDelay = 0;
		_onStart = _onUpdate = _onRepeat = _onComplete = _onRepeatStart = _onRepeatFinish = null;
		_onStartArgs = _onUpdateArgs = _onRepeatArgs = _onCompleteArgs = _onRepeatStartArgs = _onRepeatFinishArgs = null;
		_roundToInt = _reverse = false;
		_repeatCount = 1;
		_currentCycle = -1;
		_nextTween = null;
		if (Std.isOfType(transition, String)) {
			this.transition = ASCompat.asString(transition);
		} else {
			if (!Reflect.isFunction(transition)) {
				throw new ArgumentError("Transition must be either a string or a function");
			}
			this.transitionFunc = ASCompat.asFunction(transition);
		}
		if (_properties != null) {
			_properties.length = 0;
		} else {
			_properties = new Vector<String>((0 : UInt));
		}
		if (_startValues != null) {
			_startValues.length = 0;
		} else {
			_startValues = new Vector<Float>((0 : UInt));
		}
		if (_endValues != null) {
			_endValues.length = 0;
		} else {
			_endValues = new Vector<Float>((0 : UInt));
		}
		if (_updateFuncs != null) {
			_updateFuncs.length = 0;
		} else {
			_updateFuncs = new Vector<ASFunction>((0 : UInt));
		}
		return this;
	}

	public function animate(property:String, endValue:Float) {
		if (_target == null) {
			return;
		}
		var _loc3_ = _properties.length;
		var _loc4_ = getUpdateFuncFromProperty(property);
		_properties[_loc3_] = getPropertyName(property);
		_startValues[_loc3_] = Math.NaN;
		_endValues[_loc3_] = endValue;
		_updateFuncs[_loc3_] = _loc4_;
	}

	public function scaleTo(factor:Float) {
		animate("scaleX", factor);
		animate("scaleY", factor);
	}

	public function moveTo(x:Float, y:Float) {
		animate("x", x);
		animate("y", y);
	}

	public function fadeTo(alpha:Float) {
		animate("alpha", alpha);
	}

	public function rotateTo(angle:Float, type:String = "rad") {
		animate("rotation#" + type, angle);
	}

	public function advanceTime(time:Float) {
		var _loc6_ = 0;
		var _loc7_:ASFunction = null;
		var _loc5_:ASFunction = null;
		var _loc8_:Array<ASAny> = null;
		if (time == 0 || _repeatCount == 1 && _currentTime == _totalTime) {
			return;
		}
		var _loc3_ = _currentTime;
		var _loc2_ = _totalTime - _currentTime;
		var _loc10_ = time > _loc2_ ? time - _loc2_ : 0;
		_currentTime += time;
		if (_currentTime <= 0) {
			return;
		}
		if (_currentTime > _totalTime) {
			_currentTime = _totalTime;
		}
		if (_currentCycle < 0 && _loc3_ <= 0 && _currentTime > 0) {
			_currentCycle = _currentCycle + 1;
			if (_onStart != null) {
				Reflect.callMethod(this, _onStart, _onStartArgs);
			}
		}
		if (_loc3_ <= 0 && _currentTime > 0) {
			if (_onRepeatStart != null) {
				Reflect.callMethod(this, _onRepeatStart, _onRepeatStartArgs);
			}
		}
		var _loc11_ = _currentTime / _totalTime;
		var _loc9_ = _reverse && _currentCycle % 2 == 1;
		var _loc4_ = _startValues.length;
		_progress = _loc9_ ? ASCompat.toNumber(_transitionFunc(1 - _loc11_)) : ASCompat.toNumber(_transitionFunc(_loc11_));
		_loc6_ = 0;
		while (_loc6_ < _loc4_) {
			if (_startValues[_loc6_] != _startValues[_loc6_]) {
				_startValues[_loc6_] = ASCompat.asNumber(_target[_properties[_loc6_]]);
			}
			_loc7_ = ASCompat.asFunction(_updateFuncs[_loc6_]);
			_loc7_(_properties[_loc6_], _startValues[_loc6_], _endValues[_loc6_]);
			_loc6_++;
		}
		if (_onUpdate != null) {
			Reflect.callMethod(this, _onUpdate, _onUpdateArgs);
		}
		if (_loc3_ < _totalTime && _currentTime >= _totalTime) {
			if (_repeatCount == 0 || _repeatCount > 1) {
				if (_loc9_) {
					_currentTime = -_repeatReverseDelay;
				} else {
					_currentTime = -_repeatDelay;
				}
				_currentCycle = _currentCycle + 1;
				if (_repeatCount > 1) {
					_repeatCount = _repeatCount - 1;
				}
				if (_onRepeat != null) {
					Reflect.callMethod(this, _onRepeat, _onRepeatArgs);
				}
				if (_onRepeatFinish != null) {
					Reflect.callMethod(this, _onRepeatFinish, _onRepeatFinishArgs);
				}
			} else {
				_loc5_ = _onComplete;
				_loc8_ = _onCompleteArgs;
				dispatchEventWith("removeFromJuggler");
				if (_loc5_ != null) {
					Reflect.callMethod(this, _loc5_, _loc8_);
				}
				if (_onRepeatFinish != null) {
					Reflect.callMethod(this, _onRepeatFinish, _onRepeatFinishArgs);
				}
				if (_currentTime == 0) {
					_loc10_ = 0;
				}
			}
		}
		if (ASCompat.floatAsBool(_loc10_)) {
			advanceTime(_loc10_);
		}
	}

	function getUpdateFuncFromProperty(property:String):ASFunction {
		var _loc3_:ASFunction = null;
		var _loc2_ = getPropertyHint(property);
		switch (_loc2_) {
			case null:
				_loc3_ = updateStandard;

			case "rgb":
				_loc3_ = updateRgb;

			case "rad":
				_loc3_ = updateRad;

			case "deg":
				_loc3_ = updateDeg;

			default:
				_loc3_ = updateStandard;
		}
		return _loc3_;
	}

	function updateStandard(property:String, startValue:Float, endValue:Float) {
		var _loc4_ = startValue + _progress * (endValue - startValue);
		if (_roundToInt) {
			_loc4_ = Math.fround(_loc4_);
		}
		_target[property] = _loc4_;
	}

	function updateRgb(property:String, startValue:Float, endValue:Float) {
		_target[property] = Color.interpolate((ASCompat.floatToInt(startValue) : UInt), (ASCompat.floatToInt(endValue) : UInt), _progress);
	}

	function updateRad(property:String, startValue:Float, endValue:Float) {
		updateAngle(3.141592653589793, property, startValue, endValue);
	}

	function updateDeg(property:String, startValue:Float, endValue:Float) {
		updateAngle(180, property, startValue, endValue);
	}

	function updateAngle(pi:Float, property:String, startValue:Float, endValue:Float) {
		while (Math.abs(endValue - startValue) > pi) {
			if (startValue < endValue) {
				endValue -= 2 * pi;
			} else {
				endValue += 2 * pi;
			}
		}
		updateStandard(property, startValue, endValue);
	}

	public function getEndValue(property:String):Float {
		var _loc2_ = _properties.indexOf(property);
		if (_loc2_ == -1) {
			throw new ArgumentError("The property \'" + property + "\' is not animated");
		}
		return ASCompat.asNumber(_endValues[_loc2_]);
	}

	public function animatesProperty(property:String):Bool {
		return _properties.indexOf(property) != -1;
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return _currentTime >= _totalTime && _repeatCount == 1;
	}

	@:isVar public var target(get, never):ASObject;

	public function get_target():ASObject {
		return _target;
	}

	@:isVar public var transition(get, set):String;

	public function get_transition():String {
		return _transitionName;
	}

	function set_transition(value:String):String {
		_transitionName = value;
		_transitionFunc = Transitions.getTransition(value);
		if (_transitionFunc == null) {
			throw new ArgumentError("Invalid transiton: " + value);
		}
		return value;
	}

	@:isVar public var transitionFunc(get, set):ASFunction;

	public function get_transitionFunc():ASFunction {
		return _transitionFunc;
	}

	function set_transitionFunc(value:ASFunction):ASFunction {
		_transitionName = "custom";
		return _transitionFunc = value;
	}

	@:isVar public var totalTime(get, never):Float;

	public function get_totalTime():Float {
		return _totalTime;
	}

	@:isVar public var currentTime(get, never):Float;

	public function get_currentTime():Float {
		return _currentTime;
	}

	@:isVar public var progress(get, never):Float;

	public function get_progress():Float {
		return _progress;
	}

	@:isVar public var delay(get, set):Float;

	public function get_delay():Float {
		return _delay;
	}

	function set_delay(value:Float):Float {
		_currentTime = _currentTime + _delay - value;
		return _delay = value;
	}

	@:isVar public var repeatCount(get, set):Int;

	public function get_repeatCount():Int {
		return _repeatCount;
	}

	function set_repeatCount(value:Int):Int {
		return _repeatCount = value;
	}

	@:isVar public var repeatDelay(get, set):Float;

	public function get_repeatDelay():Float {
		return _repeatDelay;
	}

	function set_repeatDelay(value:Float):Float {
		return _repeatDelay = value;
	}

	@:isVar public var repeatReverseDelay(get, set):Float;

	public function get_repeatReverseDelay():Float {
		return _repeatReverseDelay;
	}

	function set_repeatReverseDelay(value:Float):Float {
		return _repeatReverseDelay = value;
	}

	@:isVar public var reverse(get, set):Bool;

	public function get_reverse():Bool {
		return _reverse;
	}

	function set_reverse(value:Bool):Bool {
		return _reverse = value;
	}

	@:isVar public var roundToInt(get, set):Bool;

	public function get_roundToInt():Bool {
		return _roundToInt;
	}

	function set_roundToInt(value:Bool):Bool {
		return _roundToInt = value;
	}

	@:isVar public var onStart(get, set):ASFunction;

	public function get_onStart():ASFunction {
		return _onStart;
	}

	function set_onStart(value:ASFunction):ASFunction {
		return _onStart = value;
	}

	@:isVar public var onUpdate(get, set):ASFunction;

	public function get_onUpdate():ASFunction {
		return _onUpdate;
	}

	function set_onUpdate(value:ASFunction):ASFunction {
		return _onUpdate = value;
	}

	@:isVar public var onRepeat(get, set):ASFunction;

	public function get_onRepeat():ASFunction {
		return _onRepeat;
	}

	function set_onRepeat(value:ASFunction):ASFunction {
		return _onRepeat = value;
	}

	@:isVar public var onRepeatStart(get, set):ASFunction;

	public function get_onRepeatStart():ASFunction {
		return _onRepeatStart;
	}

	function set_onRepeatStart(value:ASFunction):ASFunction {
		return _onRepeatStart = value;
	}

	@:isVar public var onRepeatFinish(get, set):ASFunction;

	public function get_onRepeatFinish():ASFunction {
		return _onRepeatFinish;
	}

	function set_onRepeatFinish(value:ASFunction):ASFunction {
		return _onRepeatFinish = value;
	}

	@:isVar public var onComplete(get, set):ASFunction;

	public function get_onComplete():ASFunction {
		return _onComplete;
	}

	function set_onComplete(value:ASFunction):ASFunction {
		return _onComplete = value;
	}

	@:isVar public var onStartArgs(get, set):Array<ASAny>;

	public function get_onStartArgs():Array<ASAny> {
		return _onStartArgs;
	}

	function set_onStartArgs(value:Array<ASAny>):Array<ASAny> {
		return _onStartArgs = value;
	}

	@:isVar public var onUpdateArgs(get, set):Array<ASAny>;

	public function get_onUpdateArgs():Array<ASAny> {
		return _onUpdateArgs;
	}

	function set_onUpdateArgs(value:Array<ASAny>):Array<ASAny> {
		return _onUpdateArgs = value;
	}

	@:isVar public var onRepeatArgs(get, set):Array<ASAny>;

	public function get_onRepeatArgs():Array<ASAny> {
		return _onRepeatArgs;
	}

	function set_onRepeatArgs(value:Array<ASAny>):Array<ASAny> {
		return _onRepeatArgs = value;
	}

	@:isVar public var onRepeatStartArgs(get, set):Array<ASAny>;

	public function get_onRepeatStartArgs():Array<ASAny> {
		return _onRepeatStartArgs;
	}

	function set_onRepeatStartArgs(value:Array<ASAny>):Array<ASAny> {
		return _onRepeatStartArgs = value;
	}

	@:isVar public var onRepeatFinishArgs(get, set):Array<ASAny>;

	public function get_onRepeatFinishArgs():Array<ASAny> {
		return _onRepeatFinishArgs;
	}

	function set_onRepeatFinishArgs(value:Array<ASAny>):Array<ASAny> {
		return _onRepeatFinishArgs = value;
	}

	@:isVar public var onCompleteArgs(get, set):Array<ASAny>;

	public function get_onCompleteArgs():Array<ASAny> {
		return _onCompleteArgs;
	}

	function set_onCompleteArgs(value:Array<ASAny>):Array<ASAny> {
		return _onCompleteArgs = value;
	}

	@:isVar public var nextTween(get, set):Tween;

	public function get_nextTween():Tween {
		return _nextTween;
	}

	function set_nextTween(value:Tween):Tween {
		return _nextTween = value;
	}
}
