package starling.animation;

import starling.events.EventDispatcher;

/*use*/ /*namespace*/ /*starling_internal*/ class DelayedCall extends EventDispatcher implements IAnimatable {
	static var sPool:Vector<DelayedCall> = new Vector((0 : UInt));

	var _currentTime:Float = Math.NaN;

	var _totalTime:Float = Math.NaN;

	var _callback:ASFunction;

	var _args:Array<ASAny>;

	var _repeatCount:Int = 0;

	public function new(callback:ASFunction, delay:Float, args:Array<ASAny> = null) {
		super();
		reset(callback, delay, args);
	}

	/*starling_internal*/
	public static function fromPool(call:ASFunction, delay:Float, args:Array<ASAny> = null):DelayedCall {
		if (sPool.length != 0) {
			return sPool.pop().reset(call, delay, args);
		}
		return new DelayedCall(call, delay, args);
	}

	/*starling_internal*/
	public static function toPool(delayedCall:DelayedCall) {
		delayedCall._callback = null;
		delayedCall._args = null;
		delayedCall.removeEventListeners();
		sPool.push(delayedCall);
	}

	public function reset(callback:ASFunction, delay:Float, args:Array<ASAny> = null):DelayedCall {
		_currentTime = 0;
		_totalTime = Math.max(delay, 0.0001);
		_callback = callback;
		_args = args;
		_repeatCount = 1;
		return this;
	}

	public function advanceTime(time:Float) {
		var _loc2_:ASFunction = null;
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = _currentTime;
		_currentTime += time;
		if (_currentTime > _totalTime) {
			_currentTime = _totalTime;
		}
		if (_loc4_ < _totalTime && _currentTime >= _totalTime) {
			if (_repeatCount == 0 || _repeatCount > 1) {
				ASCompatMacro.applyClosure(_callback, _args);
				if (_repeatCount > 0) {
					_repeatCount -= 1;
				}
				_currentTime = 0;
				advanceTime(_loc4_ + time - _totalTime);
			} else {
				_loc2_ = _callback;
				_loc3_ = _args;
				dispatchEventWith("removeFromJuggler");
				ASCompatMacro.applyClosure(_loc2_, _loc3_);
			}
		}
	}

	public function complete() {
		var _loc1_ = _totalTime - _currentTime;
		if (_loc1_ > 0) {
			advanceTime(_loc1_);
		}
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return _repeatCount == 1 && _currentTime >= _totalTime;
	}

	@:isVar public var totalTime(get, never):Float;

	public function get_totalTime():Float {
		return _totalTime;
	}

	@:isVar public var currentTime(get, never):Float;

	public function get_currentTime():Float {
		return _currentTime;
	}

	@:isVar public var repeatCount(get, set):Int;

	public function get_repeatCount():Int {
		return _repeatCount;
	}

	function set_repeatCount(value:Int):Int {
		return _repeatCount = value;
	}

	@:isVar public var callback(get, never):ASFunction;

	public function get_callback():ASFunction {
		return _callback;
	}

	@:isVar public var arguments(get, never):Array<ASAny>;

	public function get_arguments():Array<ASAny> {
		return _args;
	}
}
