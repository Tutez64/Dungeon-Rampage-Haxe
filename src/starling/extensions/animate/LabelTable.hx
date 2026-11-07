package starling.extensions.animate;

import flash.display.FrameLabel;

/*internal*/
class LabelTable {
	public var frameLabels:Array<ASAny>;

	public var numFrames:Int = 0;

	public var loopStart:Int = 0;

	var _ranges:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var _labelAtFrame:Vector<String>;

	var _layers:Array<ASAny>;

	public function new(data:ASObject) {
		var _loc4_ = 0;
		var _loc6_:FrameLabel = null;
		var _loc7_ = 0;

		var _loc2_:Array<ASAny> = ASCompat.coerce(data.timeline.layers, Array);
		_layers = _loc2_;
		numFrames = countFrames(_loc2_);
		frameLabels = collectLabels(_loc2_);
		var _loc3_ = frameLabels.length;
		_loc4_ = 0;
		while (_loc4_ < _loc3_) {
			_loc6_ = ASCompat.coerce(frameLabels[_loc4_], flash.display.FrameLabel);
			if (ASCompat.dynamicAs(ASDictionary.getString(_ranges, _loc6_.name), LabelRange) == null) {
				_ranges[_loc6_.name] = new LabelRange(_loc6_.frame, _loc4_);
			}
			_loc4_++;
		}
		var _loc5_:LabelRange;
		final __ax4_iter_511 = _ranges;
		if (checkNullIteratee(__ax4_iter_511))
			for (_tmp_ in __ax4_iter_511) {
				_loc5_ = ASCompat.coerce(_tmp_, LabelRange);
				_loc5_.next = labelAfterFrame(_loc5_.start, _loc5_.index + 1);
				_loc7_ = getFrame(_loc5_.next);
				_loc5_.end = (_loc7_ > _loc5_.start ? _loc7_ : numFrames) - 1;
			}
		loopStart = getFrame("loop");
	}

	static function countFrames(layers:Array<ASAny>):Int {
		var _loc7_ = 0;
		var _loc4_:Array<ASAny> = null;
		var _loc5_ = 0;
		var _loc6_ = 0;
		var _loc8_ = 0;
		var _loc3_ = 0;
		var _loc2_ = layers.length;
		_loc7_ = 0;
		while (_loc7_ < _loc2_) {
			_loc4_ = ASCompat.dynamicAs(layers[_loc7_].frames, Array);
			_loc5_ = _loc4_ != null ? _loc4_.length : 0;
			_loc6_ = ASCompat.toInt(_loc5_ != 0 ? _loc4_[0].index : 0);
			_loc8_ = 0;
			while (_loc8_ < _loc5_) {
				_loc6_ += ASCompat.toInt(_loc4_[_loc8_].duration);
				_loc8_++;
			}
			if (_loc6_ > _loc3_) {
				_loc3_ = _loc6_;
			}
			_loc7_++;
		}
		return if (_loc3_ != 0) _loc3_ else 1;
	}

	static function collectLabels(layers:Array<ASAny>):Array<ASAny> {
		var _loc6_ = 0;
		var _loc4_:Array<ASAny> = null;
		var _loc5_ = 0;
		var _loc7_ = 0;
		var _loc3_:ASObject = null;
		var _loc8_:Array<ASAny> = [];
		var _loc2_ = layers.length;
		_loc6_ = 0;
		while (_loc6_ < _loc2_) {
			_loc4_ = ASCompat.dynamicAs(layers[_loc6_].frames, Array);
			_loc5_ = _loc4_ != null ? _loc4_.length : 0;
			_loc7_ = 0;
			while (_loc7_ < _loc5_) {
				_loc3_ = _loc4_[_loc7_];
				if (_loc3_.hasOwnProperty("name")) {
					_loc8_[_loc8_.length] = new FrameLabel(_loc3_.name, ASCompat.toInt(_loc3_.index));
				}
				_loc7_++;
			}
			_loc6_++;
		}
		ASCompat.ASArray.sortOn(_loc8_, "frame", 16);
		return _loc8_;
	}

	static function collectKeyframes(layers:Array<ASAny>, start:Int, end:Int):Vector<Int> {
		var _loc8_ = 0;
		var _loc6_:Array<ASAny> = null;
		var _loc7_ = 0;
		var _loc10_ = 0;
		var _loc9_ = 0;
		var _loc4_ = Vector.ofArray([start]);
		var _loc5_ = layers.length;
		_loc8_ = 0;
		while (_loc8_ < _loc5_) {
			_loc6_ = ASCompat.dynamicAs(layers[_loc8_].frames, Array);
			_loc7_ = _loc6_ != null ? _loc6_.length : 0;
			_loc10_ = 0;
			while (_loc10_ < _loc7_) {
				_loc9_ = ASCompat.toInt(_loc6_[_loc10_].index);
				if (_loc9_ > start && _loc9_ <= end && _loc4_.indexOf(_loc9_) < 0) {
					_loc4_[_loc4_.length] = _loc9_;
				}
				_loc10_++;
			}
			_loc8_++;
		}
		ASCompat.ASVector.sort(_loc4_, compareFrames);
		return _loc4_;
	}

	static function compareFrames(a:Int, b:Int):Float {
		return a - b;
	}

	public function getFrame(label:String):Int {
		if (label == null) {
			return -1;
		}
		var _loc2_ = ASCompat.dynamicAs(ASDictionary.getString(_ranges, label), LabelRange);
		return _loc2_ != null ? _loc2_.start : -1;
	}

	public function getEnd(label:String):Int {
		if (label == null) {
			return -1;
		}
		var _loc2_ = ASCompat.dynamicAs(ASDictionary.getString(_ranges, label), LabelRange);
		return _loc2_ != null ? _loc2_.end : -1;
	}

	public function getKeyframe(label:String, keyIndex:Int):Int {
		var _loc3_ = segmentKeyframes(label);
		if (_loc3_ == null) {
			return -1;
		}
		if (keyIndex < 0) {
			keyIndex = 0;
		}
		if (keyIndex >= _loc3_.length) {
			keyIndex = _loc3_.length - 1;
		}
		return _loc3_[keyIndex];
	}

	public function getKeyframeIndex(label:String, frame:Int):Int {
		var _loc3_ = segmentKeyframes(label);
		if (_loc3_ == null) {
			return -1;
		}
		var _loc4_ = 0;
		while (_loc4_ + 1 < _loc3_.length && _loc3_[_loc4_ + 1] <= frame) {
			_loc4_++;
		}
		return _loc4_;
	}

	function segmentKeyframes(label:String):Vector<Int> {
		if (label == null) {
			return null;
		}
		var _loc2_ = ASCompat.dynamicAs(ASDictionary.getString(_ranges, label), LabelRange);
		if (_loc2_ == null) {
			return null;
		}
		if (_loc2_.keyframes == null) {
			_loc2_.keyframes = collectKeyframes(_layers, _loc2_.start, _loc2_.end);
		}
		return _loc2_.keyframes;
	}

	public function getNextLabel(afterLabel:String, currentFrame:Int):String {
		var _loc3_ = if (ASCompat.stringAsBool(afterLabel)) afterLabel else labelAt(currentFrame);
		var _loc4_ = _loc3_ != null ? ASCompat.dynamicAs(ASDictionary.getString(_ranges, _loc3_), LabelRange) : null;
		return _loc4_ != null ? _loc4_.next : labelAfterFrame(-1, 0);
	}

	public function labelAt(frame:Int):String {
		var _loc2_ = 0;
		if (frameLabels.length == 0) {
			return null;
		}
		if (frame < 0 || frame >= numFrames) {
			return scanLabelAt(frame);
		}
		if (_labelAtFrame == null) {
			_labelAtFrame = new Vector<String>((numFrames : UInt), true);
			_loc2_ = 0;
			while (_loc2_ < numFrames) {
				_labelAtFrame[_loc2_] = scanLabelAt(_loc2_);
				_loc2_++;
			}
		}
		return _labelAtFrame[frame];
	}

	function scanLabelAt(frame:Int):String {
		var _loc4_ = 0;
		var _loc5_:FrameLabel = null;
		var _loc3_ = frameLabels.length;
		var _loc2_:FrameLabel = _loc3_ != 0 ? frameLabels[0] : null;
		_loc4_ = 1;
		while (_loc4_ < _loc3_) {
			_loc5_ = ASCompat.coerce(frameLabels[_loc4_], flash.display.FrameLabel);
			if (_loc5_.frame > frame) {
				break;
			}
			_loc2_ = _loc5_;
			_loc4_++;
		}
		return _loc2_ != null ? _loc2_.name : null;
	}

	function labelAfterFrame(frame:Int, fromIndex:Int):String {
		var _loc4_ = 0;
		var _loc5_:FrameLabel = null;
		var _loc3_ = frameLabels.length;
		_loc4_ = fromIndex;
		while (_loc4_ < _loc3_) {
			_loc5_ = ASCompat.coerce(frameLabels[_loc4_], flash.display.FrameLabel);
			if (_loc5_.frame > frame) {
				return _loc5_.name;
			}
			_loc4_++;
		}
		return _loc3_ != 0 ? frameLabels[0].name : null;
	}
}

private class LabelRange {
	public var start:Int = 0;

	public var end:Int = 0;

	public var next:String;

	public var index:Int = 0;

	public var keyframes:Vector<Int>;

	public function new(start:Int, index:Int) {
		this.start = start;
		this.index = index;
	}
}
