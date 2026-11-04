package starling.display;

import flash.errors.IllegalOperationError;
import flash.media.Sound;
import flash.media.SoundTransform;
import starling.animation.IAnimatable;
import starling.textures.Texture;
import flash.media.Sound;
import flash.media.SoundTransform;
import starling.display.MovieClip;
import starling.textures.Texture;
import flash.errors.ArgumentError;

class MovieClip extends Image implements IAnimatable {
	var _frames:Vector<MovieClipFrame>;

	var _defaultFrameDuration:Float = Math.NaN;

	var _currentTime:Float = Math.NaN;

	var _currentFrameID:Int = 0;

	var _loop:Bool = false;

	var _playing:Bool = false;

	var _muted:Bool = false;

	var _wasStopped:Bool = false;

	var _soundTransform:SoundTransform;

	public function new(textures:Vector<Texture>, fps:Float = 12) {
		if (textures.length > 0) {
			super(textures[0]);
			init(textures, fps);
			return;
		}
		throw new ArgumentError("Empty texture array");
	}

	function init(textures:Vector<Texture>, fps:Float) {
		var _loc4_ = 0;
		if (fps <= 0) {
			throw new ArgumentError("Invalid fps: " + fps);
		}
		var _loc3_ = textures.length;
		_defaultFrameDuration = 1 / fps;
		_loop = true;
		_playing = true;
		_currentTime = 0;
		_currentFrameID = 0;
		_wasStopped = true;
		_frames = new Vector<MovieClipFrame>((0 : UInt));
		_loc4_ = 0;
		while (_loc4_ < _loc3_) {
			_frames[_loc4_] = new MovieClipFrame(textures[_loc4_], _defaultFrameDuration, _defaultFrameDuration * _loc4_);
			_loc4_++;
		}
	}

	public function addFrame(texture:Texture, sound:Sound = null, duration:Float = -1) {
		addFrameAt(numFrames, texture, sound, duration);
	}

	public function addFrameAt(frameID:Int, texture:Texture, sound:Sound = null, duration:Float = -1) {
		var _loc6_ = Math.NaN;
		var _loc5_ = Math.NaN;
		if (frameID < 0 || frameID > numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		if (duration < 0) {
			duration = _defaultFrameDuration;
		}
		var _loc7_ = new MovieClipFrame(texture, duration);
		_loc7_.sound = sound;
		_frames.insertAt(frameID, _loc7_);
		if (frameID == numFrames) {
			_loc6_ = frameID > 0 ? _frames[frameID - 1].startTime : 0;
			_loc5_ = frameID > 0 ? _frames[frameID - 1].duration : 0;
			_loc7_.startTime = _loc6_ + _loc5_;
		} else {
			updateStartTimes();
		}
	}

	public function removeFrameAt(frameID:Int) {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		if (numFrames == 1) {
			throw new IllegalOperationError("Movie clip must not be empty");
		}
		_frames.removeAt(frameID);
		if (frameID != numFrames) {
			updateStartTimes();
		}
	}

	public function getFrameTexture(frameID:Int):Texture {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		return _frames[frameID].texture;
	}

	public function setFrameTexture(frameID:Int, texture:Texture) {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		_frames[frameID].texture = texture;
	}

	public function getFrameSound(frameID:Int):Sound {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		return _frames[frameID].sound;
	}

	public function setFrameSound(frameID:Int, sound:Sound) {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		_frames[frameID].sound = sound;
	}

	public function getFrameAction(frameID:Int):ASFunction {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		return _frames[frameID].action;
	}

	public function setFrameAction(frameID:Int, action:ASFunction) {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		_frames[frameID].action = action;
	}

	public function getFrameDuration(frameID:Int):Float {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		return _frames[frameID].duration;
	}

	public function setFrameDuration(frameID:Int, duration:Float) {
		if (frameID < 0 || frameID >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		_frames[frameID].duration = duration;
		updateStartTimes();
	}

	public function reverseFrames() {
		ASCompat.ASVector.reverse(_frames);
		updateStartTimes();
		_currentTime = totalTime - _currentTime;
		_currentFrameID = numFrames - _currentFrameID - 1;
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

	function updateStartTimes() {
		var _loc2_ = 0;
		var _loc1_ = this.numFrames;
		var _loc3_ = _frames[0];
		_loc3_.startTime = 0;
		_loc2_ = 1;
		while (_loc2_ < _loc1_) {
			_frames[_loc2_].startTime = _loc3_.startTime + _loc3_.duration;
			_loc3_ = _frames[_loc2_];
			_loc2_++;
		}
	}

	public function advanceTime(passedTime:Float) {
		var _loc4_ = Math.NaN;
		var _loc2_ = false;
		if (!_playing) {
			return;
		}
		var _loc8_ = _frames[_currentFrameID];
		if (_wasStopped) {
			_wasStopped = false;
			_loc8_.playSound(_soundTransform);
			if (_loc8_.action != null) {
				_loc8_.executeAction(this, _currentFrameID);
				advanceTime(passedTime);
				return;
			}
		}
		if (_currentTime == totalTime) {
			if (!_loop) {
				return;
			}
			_currentTime = 0;
			_currentFrameID = 0;
			_loc8_ = _frames[0];
			_loc8_.playSound(_soundTransform);
			texture = _loc8_.texture;
			if (_loc8_.action != null) {
				_loc8_.executeAction(this, _currentFrameID);
				advanceTime(passedTime);
				return;
			}
		}
		var _loc3_ = _frames.length - 1;
		var _loc5_ = false;
		var _loc6_:ASFunction = null;
		var _loc7_ = _currentFrameID;
		while (_currentTime + passedTime >= _loc8_.endTime) {
			_loc2_ = false;
			_loc4_ = _loc8_.duration - _currentTime + _loc8_.startTime;
			passedTime -= _loc4_;
			_currentTime = _loc8_.startTime + _loc8_.duration;
			if (_currentFrameID == _loc3_) {
				if (hasEventListener("complete")) {
					_loc5_ = true;
				} else {
					if (!_loop) {
						return;
					}
					_currentTime = 0;
					_currentFrameID = 0;
					_loc2_ = true;
				}
			} else {
				_currentFrameID += 1;
				_loc2_ = true;
			}
			_loc8_ = _frames[_currentFrameID];
			_loc6_ = _loc8_.action;
			if (_loc2_) {
				_loc8_.playSound(_soundTransform);
			}
			if (_loc5_) {
				texture = _loc8_.texture;
				dispatchEventWith("complete");
				advanceTime(passedTime);
				return;
			}
			if (_loc6_ != null) {
				texture = _loc8_.texture;
				_loc8_.executeAction(this, _currentFrameID);
				advanceTime(passedTime);
				return;
			}
		}
		if (_loc7_ != _currentFrameID) {
			texture = _frames[_currentFrameID].texture;
		}
		_currentTime += passedTime;
	}

	@:isVar public var numFrames(get, never):Int;

	public function get_numFrames():Int {
		return _frames.length;
	}

	@:isVar public var totalTime(get, never):Float;

	public function get_totalTime():Float {
		var _loc1_ = _frames[_frames.length - 1];
		return _loc1_.startTime + _loc1_.duration;
	}

	@:isVar public var currentTime(get, set):Float;

	public function get_currentTime():Float {
		return _currentTime;
	}

	function set_currentTime(value:Float):Float {
		if (value < 0 || value > totalTime) {
			throw new ArgumentError("Invalid time: " + value);
		}
		var _loc2_ = _frames.length - 1;
		_currentTime = value;
		_currentFrameID = 0;
		while (_currentFrameID < _loc2_ && _frames[_currentFrameID + 1].startTime <= value) {
			_currentFrameID = _currentFrameID + 1;
		}
		var _loc3_ = _frames[_currentFrameID];
		texture = _loc3_.texture;
		return value;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return _loop;
	}

	function set_loop(value:Bool):Bool {
		return _loop = value;
	}

	@:isVar public var muted(get, set):Bool;

	public function get_muted():Bool {
		return _muted;
	}

	function set_muted(value:Bool):Bool {
		return _muted = value;
	}

	@:isVar public var soundTransform(get, set):SoundTransform;

	public function get_soundTransform():SoundTransform {
		return _soundTransform;
	}

	function set_soundTransform(value:SoundTransform):SoundTransform {
		return _soundTransform = value;
	}

	@:isVar public var currentFrame(get, set):Int;

	public function get_currentFrame():Int {
		return _currentFrameID;
	}

	function set_currentFrame(value:Int):Int {
		if (value < 0 || value >= numFrames) {
			throw new ArgumentError("Invalid frame id");
		}
		currentTime = _frames[value].startTime;
		return value;
	}

	@:isVar public var fps(get, set):Float;

	public function get_fps():Float {
		return 1 / _defaultFrameDuration;
	}

	function set_fps(value:Float):Float {
		var _loc4_ = 0;
		if (value <= 0) {
			throw new ArgumentError("Invalid fps: " + value);
		}
		var _loc2_ = 1 / value;
		var _loc3_ = _loc2_ / _defaultFrameDuration;
		_currentTime *= _loc3_;
		_defaultFrameDuration = _loc2_;
		_loc4_ = 0;
		while (_loc4_ < numFrames) {
			_frames[_loc4_].duration *= _loc3_;
			_loc4_++;
		}
		updateStartTimes();
		return value;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		if (_playing) {
			return _loop || _currentTime < totalTime;
		}
		return false;
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return !_loop && _currentTime >= totalTime;
	}
}

private class MovieClipFrame {
	public var texture:Texture;

	public var sound:Sound;

	public var duration:Float = Math.NaN;

	public var startTime:Float = Math.NaN;

	public var action:ASFunction;

	public function new(texture:Texture, duration:Float = 0.1, startTime:Float = 0) {
		this.texture = texture;
		this.duration = duration;
		this.startTime = startTime;
	}

	public function playSound(transform:SoundTransform) {
		if (sound != null) {
			sound.play(0, 0, transform);
		}
	}

	public function executeAction(movie:MovieClip, frameID:Int) {
		var _loc3_ = 0;
		if (action != null) {
			_loc3_ = action.length;
			if (_loc3_ == 0) {
				action();
			} else if (_loc3_ == 1) {
				action(movie);
			} else {
				if (_loc3_ != 2) {
					throw new Error("Frame actions support zero, one or two parameters: movie:MovieClip, frameID:int");
				}
				action(movie, frameID);
			}
		}
	}

	@:isVar public var endTime(get, never):Float;

	public function get_endTime():Float {
		return startTime + duration;
	}
}
