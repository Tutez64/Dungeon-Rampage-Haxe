package starling.extensions.animate;

import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.events.EventDispatcher;
import starling.utils.MathUtil;
import starling.display.DisplayObject;
import flash.errors.RangeError;
import flash.errors.ArgumentError;

/*internal*/
class MovieBehavior extends EventDispatcher implements IAnimatable {
	static inline final E:Float = 0.00001;

	var _frames:Vector<MovieFrame>;

	var _numFrames:Int = 0;

	var _frameDuration:Float = Math.NaN;

	var _currentTime:Float = Math.NaN;

	var _currentFrame:Int = 0;

	var _loop:Bool = false;

	var _wrapFrame:Int = 0;

	var _playing:Bool = false;

	var _wasStopped:Bool = false;

	var _target:DisplayObject;

	var _onFrameChanged:ASFunction;

	public function new(target:DisplayObject, onFrameChanged:ASFunction, frameRate:Float = 24) {
		super();
		if (frameRate <= 0) {
			throw new ArgumentError("Invalid frame rate");
		}
		if (target == null) {
			throw new ArgumentError("Target cannot be null");
		}
		if (onFrameChanged == null) {
			throw new ArgumentError("Callback cannot be null");
		}
		_target = target;
		_onFrameChanged = onFrameChanged;
		_frameDuration = 1 / frameRate;
		_frames = new Vector<MovieFrame>((0 : UInt));
		_loop = true;
		_playing = true;
		_currentTime = 0;
		_currentFrame = 0;
		_wasStopped = true;
	}

	public function play() {
		_playing = true;
	}

	public function pause() {
		_playing = false;
	}

	public function stop() {
		_playing = false;
		_wasStopped = true;
		currentFrame = 0;
	}

	public function addFrameAction(index:Int, action:ASFunction) {
		var _loc3_ = findFrameAt(index);
		if (action == null) {
			throw new ArgumentError("action cannot be null");
		}
		if (_loc3_ == null) {
			if (index >= _frames.length) {
				_frames.length = index + 1;
			}
			_loc3_ = _frames[index] = new MovieFrame();
		}
		_loc3_.addAction(action);
	}

	public function removeFrameAction(index:Int, action:ASFunction) {
		var _loc3_ = findFrameAt(index);
		if (_loc3_ != null) {
			_loc3_.removeAction(action);
		}
	}

	public function removeFrameActions(index:Int) {
		var _loc2_ = findFrameAt(index);
		if (_loc2_ != null) {
			_loc2_.removeActions();
		}
	}

	function findFrameAt(index:Int):MovieFrame {
		if (index < 0 || index >= _numFrames) {
			throw new ArgumentError("Invalid frame index");
		}
		return ASCompat.coerce(index < _frames.length ? _frames[index] : null, MovieFrame);
	}

	function actionFrameAt(index:Int):MovieFrame {
		if (index < 0 || index >= _numFrames) {
			throw new RangeError("Error #1125: The index " + index + " is out of range " + _numFrames + ".", 1125);
		}
		return ASCompat.coerce(index < _frames.length ? _frames[index] : null, MovieFrame);
	}

	public function advanceTime(passedTime:Float) {
		var _loc3_ = Math.NaN;
		var _loc5_ = 0;
		if (!_playing) {
			return;
		}
		var _loc9_ = actionFrameAt(_currentFrame);
		var _loc2_ = this.totalTime;
		if (_wasStopped) {
			_wasStopped = false;
			if (_loc9_ != null && _loc9_.numActions != 0) {
				_loc9_.executeActions(_target, _currentFrame);
				advanceTime(passedTime);
				return;
			}
		}
		if (_currentTime >= _loc2_) {
			if (!_loop) {
				return;
			}
			_currentTime = _wrapFrame * _frameDuration;
			_currentFrame = _wrapFrame;
			_onFrameChanged(_wrapFrame);
			_loc9_ = actionFrameAt(_wrapFrame);
			if (_loc9_ != null && _loc9_.numActions != 0) {
				_loc9_.executeActions(_target, _currentFrame);
				advanceTime(passedTime);
				return;
			}
		}
		var _loc6_ = _numFrames - 1;
		var _loc7_ = _currentFrame * _frameDuration;
		var _loc4_ = false;
		var _loc8_ = _currentFrame;
		while (_currentTime + passedTime >= _loc7_ + _frameDuration) {
			_loc3_ = _frameDuration - _currentTime + _loc7_;
			passedTime -= _loc3_;
			_currentTime = _loc7_ + _frameDuration;
			if (_currentFrame == _loc6_) {
				_currentTime = _loc2_;
				if (hasEventListener("complete")) {
					_loc4_ = true;
				} else {
					if (!_loop) {
						return;
					}
					_currentTime = _wrapFrame * _frameDuration;
					_currentFrame = _wrapFrame;
					_loc7_ = _wrapFrame * _frameDuration;
				}
			} else {
				_currentFrame += 1;
				_loc7_ += _frameDuration;
			}
			_loc9_ = actionFrameAt(_currentFrame);
			_loc5_ = _loc9_ != null ? _loc9_.numActions : 0;
			if (_loc4_) {
				_onFrameChanged(_currentFrame);
				dispatchEventWith("complete");
				advanceTime(passedTime);
				return;
			}
			if (_loc5_ != 0) {
				_onFrameChanged(_currentFrame);
				_loc9_.executeActions(_target, _currentFrame);
				advanceTime(passedTime);
				return;
			}
		}
		if (_loc8_ != _currentFrame) {
			_onFrameChanged(_currentFrame);
		}
		_currentTime += passedTime;
	}

	@:isVar public var wrapFrame(get, set):Int;

	public function get_wrapFrame():Int {
		return _wrapFrame;
	}

	function set_wrapFrame(value:Int):Int {
		_wrapFrame = ASCompat.floatToInt(MathUtil.clamp(value, 0, numFrames - 1));
		return value;
	}

	@:isVar public var numFrames(get, set):Int;

	public function get_numFrames():Int {
		return _numFrames;
	}

	function set_numFrames(value:Int):Int {
		if (value < _frames.length) {
			_frames.length = value;
		}
		return _numFrames = value;
	}

	@:isVar public var totalTime(get, never):Float;

	public function get_totalTime():Float {
		return numFrames * _frameDuration;
	}

	@:isVar public var currentTime(get, set):Float;

	public function get_currentTime():Float {
		return _currentTime;
	}

	function set_currentTime(value:Float):Float {
		value = MathUtil.clamp(value, 0, totalTime);
		var _loc2_ = _currentFrame;
		_currentFrame = ASCompat.floatToInt(value / _frameDuration);
		_currentTime = value;
		if (_loc2_ != _currentFrame) {
			_onFrameChanged(_currentFrame);
		}
		return value;
	}

	@:isVar public var frameRate(get, set):Float;

	public function get_frameRate():Float {
		return 1 / _frameDuration;
	}

	function set_frameRate(value:Float):Float {
		if (value <= 0) {
			throw new ArgumentError("Invalid frame rate");
		}
		var _loc2_ = 1 / value;
		var _loc3_ = _loc2_ / _frameDuration;
		_currentTime *= _loc3_;
		_frameDuration = _loc2_;
		return value;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return _loop;
	}

	function set_loop(value:Bool):Bool {
		return _loop = value;
	}

	@:isVar public var currentFrame(get, set):Int;

	public function get_currentFrame():Int {
		return _currentFrame;
	}

	function set_currentFrame(value:Int):Int {
		value = ASCompat.floatToInt(MathUtil.clamp(value, 0, numFrames));
		var _loc2_ = _currentFrame;
		_currentTime = _frameDuration * value;
		_currentFrame = value;
		if (_loc2_ != _currentFrame) {
			_onFrameChanged(_currentFrame);
		}
		return value;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		if (_playing) {
			return _loop || _currentTime < totalTime;
		}
		return false;
	}

	@:isVar public var finished(get, never):Bool;

	public function get_finished():Bool {
		return _playing && !isPlaying;
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return !_loop && _currentTime >= totalTime;
	}
}

private class MovieFrame {
	var _actions:Vector<ASFunction>;

	public function new() {}

	public function addAction(action:ASFunction) {
		if (action == null) {
			throw new ArgumentError("action cannot be null");
		}
		if (_actions == null) {
			_actions = new Vector<ASFunction>((0 : UInt));
		}
		if (_actions.indexOf(action) == -1) {
			_actions[_actions.length] = action;
		}
	}

	public function removeAction(action:ASFunction) {
		var _loc2_ = 0;
		if (_actions != null) {
			_loc2_ = _actions.indexOf(action);
			if (_loc2_ >= 0) {
				_actions.removeAt(_loc2_);
			}
		}
	}

	public function removeActions() {
		if (_actions != null) {
			_actions.length = 0;
		}
	}

	public function executeActions(target:DisplayObject, frameID:Int) {
		var _loc5_ = 0;
		var _loc4_ = 0;
		var _loc6_:ASFunction = null;
		var _loc3_ = 0;
		if (_actions != null) {
			_loc5_ = 0;
			_loc4_ = _actions.length;
			while (_loc5_ < _loc4_) {
				_loc6_ = _actions[_loc5_];
				_loc3_ = (_loc6_.length : Int);
				if (_loc3_ == 0) {
					_loc6_();
				} else if (_loc3_ == 1) {
					_loc6_(target);
				} else {
					if (_loc3_ != 2) {
						throw new Error("Frame actions support zero, one or two parameters: movie:MovieClip, frameID:int");
					}
					_loc6_(target, frameID);
				}
				_loc5_++;
			}
		}
	}

	@:isVar public var numActions(get, never):Int;

	public function get_numActions():Int {
		return _actions != null ? _actions.length : 0;
	}
}
