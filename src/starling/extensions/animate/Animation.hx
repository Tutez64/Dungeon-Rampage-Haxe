package starling.extensions.animate;

import flash.geom.Point;
import starling.animation.IAnimatable;
import starling.display.DisplayObjectContainer;

class Animation extends DisplayObjectContainer implements IAnimatable {
	static inline final STEP_CLIPS = -1;

	static inline final STEP_RESET_CLIPS = -2;

	static inline final STEP_PLAY_ONCE = -3;

	static inline final STEP_CLEAR_PLAY_ONCE = -4;

	static inline final STEP_CLIPS_BY = -4;

	static inline final MAX_SKIPPED_STEPS = 100000;

	var _symbol:Symbol;

	var _labels:LabelTable;

	var _behavior:MovieBehavior;

	var _atlas:AnimationAtlas;

	var _cumulatedTime:Float = 0;

	var _pendingComplete:Bool = false;

	var _deferredCompleteFrames:Int = 0;

	var _composing:Bool = true;

	var _skippedSteps:Vector<Int> = new Vector((0 : UInt));

	var _pendingCompleteDeadline:Int = -1;

	var _waitForNestedClips:Bool = true;

	var _labelStart:Int = -1;

	var _labelEnd:Int = -1;

	var _labelName:String;

	var _labelLoop:Bool = true;

	var _labelCompleteDispatched:Bool = false;

	var _rootWrapFrame:Int = 0;

	public function new(symbolName:String, atlas:AnimationAtlas) {
		super();
		_atlas = atlas;
		var _loc4_:ASObject = atlas.getSymbolData(symbolName);
		_labels = atlas.getLabelTable(_loc4_);
		_symbol = new Symbol(_loc4_, atlas);
		_symbol.update();
		addChild(_symbol);
		_behavior = new MovieBehavior(this, onFrameChanged, atlas.frameRate);
		_behavior.numFrames = _symbol.numFrames;
		_behavior.addEventListener("complete", (cast onComplete));
		var _loc3_ = _symbol.getFrame("loop");
		_rootWrapFrame = _loc3_ > 0 ? _loc3_ : 0;
		_behavior.wrapFrame = _rootWrapFrame;
		play();
	}

	function onComplete() {
		if (_labelStart >= 0 && !_labelLoop && _labelCompleteDispatched) {
			return;
		}
		if (!hasEventListener("complete")) {
			return;
		}
		replaySkippedSteps();
		if (!_waitForNestedClips || _symbol.areMovieClipsAtFinal()) {
			dispatchEventWith("complete");
		} else {
			_pendingComplete = true;
			_pendingCompleteDeadline = ASCompat.floatToInt(ASCompat.floatToInt(_cumulatedTime * _behavior.frameRate)
				+ Math.max(0, _symbol.deepestFrameCount - _behavior.numFrames));
		}
	}

	function onFrameChanged(frameIndex:Int) {
		if (_labelStart >= 0 && (frameIndex < _labelStart || frameIndex > _labelEnd)) {
			_behavior.currentFrame = _labelLoop ? _labelStart : _labelEnd;
			return;
		}
		if (_composing) {
			_symbol.currentFrame = frameIndex;
		} else {
			skipStep(frameIndex);
		}
		if (_labelStart >= 0 && !_labelLoop && frameIndex >= _labelEnd) {
			_behavior.pause();
			if (!_labelCompleteDispatched) {
				_labelCompleteDispatched = true;
				_deferredCompleteFrames = 2;
			}
		}
	}

	public function setColorMatrix(matrix:Vector<Float>) {
		_symbol.setInheritedColor(matrix);
	}

	@:isVar public var pixelSnapping(get, set):Bool;

	public function get_pixelSnapping():Bool {
		return _symbol.pixelSnapping;
	}

	function set_pixelSnapping(value:Bool):Bool {
		return _symbol.pixelSnapping = value;
	}

	public function setMovieClipsPlayOnce() {
		if (_composing) {
			_symbol.setMovieClipLoopMode("playonce");
		} else {
			skipStep(-3);
		}
	}

	public function resetMovieClips() {
		if (_composing) {
			_symbol.resetMovieClips();
		} else {
			skipStep(-2);
		}
	}

	public function clearMovieClipsPlayOnce() {
		if (_composing) {
			_symbol.clearMovieClipsPlayOnce();
		} else {
			skipStep(-4);
		}
	}

	public function play() {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		_behavior.play();
	}

	public function pause() {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		_behavior.pause();
	}

	public function stop() {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		var _loc1_ = _labelStart;
		clearLabel();
		_behavior.stop();
		if (_loc1_ > 0) {
			_behavior.currentFrame = _loc1_;
		}
	}

	public function gotoFrame(index:Int) {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		clearLabel();
		currentFrame = index;
	}

	public function gotoLabel(label:String, loop:Bool = true, startFrame:Int = -1):Point {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		var _loc4_ = _labels.getFrame(label);
		if (_loc4_ < 0) {
			clearLabel();
			return new Point(-1, -1);
		}
		var _loc5_ = _labels.getEnd(label);
		_labelName = label;
		_labelStart = _loc4_;
		_labelEnd = _loc5_;
		_labelLoop = loop;
		_labelCompleteDispatched = false;
		_behavior.wrapFrame = loop ? _loc4_ : _rootWrapFrame;
		var _loc6_ = startFrame >= 0 ? startFrame : _loc4_;
		if (_loc6_ < _loc4_) {
			_loc6_ = _loc4_;
		}
		if (_loc6_ > _loc5_) {
			_loc6_ = _loc5_;
		}
		var _loc7_ = !loop && _loc6_ >= _loc5_;
		currentFrame = _loc6_;
		if (!_loc7_) {
			play();
		} else if (!_labelCompleteDispatched) {
			_behavior.pause();
			_labelCompleteDispatched = true;
			_deferredCompleteFrames = 2;
		}
		return new Point(_loc4_, _loc5_);
	}

	public function clearLabel() {
		_labelName = null;
		_labelStart = _labelEnd = -1;
		_labelLoop = true;
		_labelCompleteDispatched = false;
		_behavior.wrapFrame = _rootWrapFrame;
	}

	@:isVar public var heldLabel(get, never):String;

	public function get_heldLabel():String {
		return _labelName;
	}

	public function addFrameAction(index:Int, action:ASFunction) {
		_behavior.addFrameAction(index, action);
	}

	public function removeFrameAction(index:Int, action:ASFunction) {
		_behavior.removeFrameAction(index, action);
	}

	public function removeFrameActions(index:Int) {
		_behavior.removeFrameActions(index);
	}

	@:isVar public var composing(get, set):Bool;

	public function get_composing():Bool {
		return _composing;
	}

	function set_composing(value:Bool):Bool {
		if (value == _composing) {
			return value;
		}
		_composing = value;
		if (!value) {
			return value;
		}
		replaySkippedSteps();
		_symbol.currentFrame = _behavior.currentFrame;
		return value;
	}

	public function dropSkippedSteps() {
		_skippedSteps.length = 0;
	}

	function skipStep(step:Int) {
		if (_skippedSteps.length >= 100000) {
			replaySkippedSteps();
		}
		_skippedSteps.push(step);
	}

	function replaySkippedSteps() {
		var _loc2_ = 0;
		var _loc3_ = 0;
		var _loc1_ = _skippedSteps.length;
		_loc2_ = 0;
		while (_loc2_ < _loc1_) {
			_loc3_ = _skippedSteps[_loc2_];
			if (_loc3_ >= 0) {
				_symbol.currentFrame = _loc3_;
			} else if (_loc3_ == -1) {
				_symbol.nextFrame_MovieClips();
			} else if (_loc3_ < -4) {
				_symbol.nextFrame_MovieClips(-4 - _loc3_);
			} else if (_loc3_ == -2) {
				_symbol.resetMovieClips();
			} else if (_loc3_ == -3) {
				_symbol.setMovieClipLoopMode("playonce");
			} else {
				_symbol.clearMovieClipsPlayOnce();
			}
			_loc2_++;
		}
		_skippedSteps.length = 0;
	}

	public function advanceTime(time:Float) {
		var _loc2_ = _behavior.frameRate;
		var _loc3_ = ASCompat.floatToInt((_cumulatedTime + time) * _loc2_) - ASCompat.floatToInt(_cumulatedTime * _loc2_);
		if (_loc3_ > 0) {
			if (_composing) {
				_symbol.nextFrame_MovieClips(_loc3_);
			} else {
				skipStep(_loc3_ == 1 ? -1 : -4 - _loc3_);
			}
		}
		_behavior.advanceTime(time);
		_cumulatedTime += time;
		if (_pendingComplete) {
			replaySkippedSteps();
			if (_symbol.areMovieClipsAtFinal() || ASCompat.floatToInt(_cumulatedTime * _loc2_) >= _pendingCompleteDeadline) {
				_pendingComplete = false;
				dispatchEventWith("complete");
			}
		}
		if (_deferredCompleteFrames > 0 && --_deferredCompleteFrames == 0) {
			dispatchEventWith("complete");
		}
	}

	public function getNextLabel(afterLabel:String = null):String {
		return _labels.getNextLabel(afterLabel, _behavior.currentFrame);
	}

	public function getFrame(label:String):Int {
		return _labels.getFrame(label);
	}

	public function getKeyframe(label:String, keyIndex:Int):Int {
		return _labels.getKeyframe(label, keyIndex);
	}

	public function getKeyframeIndex(label:String, frame:Int):Int {
		return _labels.getKeyframeIndex(label, frame);
	}

	public function hasFrameLabelSuffix(suffix:String):Bool {
		return _symbol.hasFrameLabelSuffix(suffix);
	}

	public function hasFrameLabel(label:String):Bool {
		replaySkippedSteps();
		return _symbol.hasFrameLabel(label);
	}

	public function hasFrameLabelNoClamp(label:String):Bool {
		replaySkippedSteps();
		return _symbol.hasFrameLabelNoClamp(label);
	}

	public function advanceMovieClips() {
		_symbol.nextFrame_MovieClips();
	}

	@:isVar public var symbolName(get, never):String;

	public function get_symbolName():String {
		return _symbol.symbolName;
	}

	@:isVar public var currentLabel(get, never):String;

	public function get_currentLabel():String {
		return _labels.labelAt(_behavior.currentFrame);
	}

	@:isVar public var currentFrame(get, set):Int;

	public function get_currentFrame():Int {
		return _behavior.currentFrame;
	}

	function set_currentFrame(value:Int):Int {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		return _behavior.currentFrame = value;
	}

	@:isVar public var currentTime(get, set):Float;

	public function get_currentTime():Float {
		return _behavior.currentTime;
	}

	function set_currentTime(value:Float):Float {
		_pendingComplete = false;
		_deferredCompleteFrames = 0;
		return _behavior.currentTime = value;
	}

	@:isVar public var frameRate(get, set):Float;

	public function get_frameRate():Float {
		return _behavior.frameRate;
	}

	function set_frameRate(value:Float):Float {
		return _behavior.frameRate = value;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return _behavior.loop;
	}

	function set_loop(value:Bool):Bool {
		return _behavior.loop = value;
	}

	@:isVar public var numFrames(get, never):Int;

	public function get_numFrames():Int {
		return _behavior.numFrames;
	}

	@:isVar public var deepestFrames(get, never):Int;

	public function get_deepestFrames():Int {
		return _symbol.deepestFrameCount;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return _behavior.isPlaying;
	}

	@:isVar public var isAnimating(get, never):Bool;

	public function get_isAnimating():Bool {
		return _behavior.isPlaying || _pendingComplete || _deferredCompleteFrames > 0;
	}

	@:isVar public var isFinished(get, never):Bool;

	public function get_isFinished():Bool {
		return _behavior.finished;
	}

	@:isVar public var waitForNestedClips(get, set):Bool;

	public function get_waitForNestedClips():Bool {
		return _waitForNestedClips;
	}

	function set_waitForNestedClips(value:Bool):Bool {
		return _waitForNestedClips = value;
	}

	@:isVar public var totalTime(get, never):Float;

	public function get_totalTime():Float {
		return _behavior.totalTime;
	}

	@:isVar public var sourceWidth(get, never):Float;

	public function get_sourceWidth():Float {
		return _atlas != null ? _atlas.sourceWidth : 0;
	}

	@:isVar public var sourceHeight(get, never):Float;

	public function get_sourceHeight():Float {
		return _atlas != null ? _atlas.sourceHeight : 0;
	}
}
