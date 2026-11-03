package brain.render.tweens;

import starling.animation.IAnimatable;

class TweenTimeline implements IAnimatable {
	static inline final COMPLETION_EPSILON:Float = 0.0001;

	var mChildren:Vector<TweenHandle> = new Vector((0 : UInt));

	var mPositions:Vector<Float> = new Vector((0 : UInt));

	var mLabels:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mTime:Float = 0;

	var mComplete:Bool = false;

	public var onComplete:ASFunction;

	public var onCompleteArgs:Array<ASAny>;

	public function new() {}

	@:isVar public var duration(get, never):Float;

	public function get_duration():Float {
		var _loc2_ = 0;
		var _loc1_ = Math.NaN;
		var _loc3_:Float = 0;
		_loc2_ = 0;
		while (_loc2_ < mChildren.length) {
			_loc1_ = mPositions[_loc2_] + mChildren[_loc2_].totalSpan;
			if (_loc1_ > _loc3_) {
				_loc3_ = _loc1_;
			}
			_loc2_++;
		}
		return _loc3_;
	}

	@:isVar public var currentTime(get, never):Float;

	public function get_currentTime():Float {
		return mTime;
	}

	@:isVar public var isComplete(get, never):Bool;

	public function get_isComplete():Bool {
		return mComplete;
	}

	@:isVar public var numChildren(get, never):Int;

	public function get_numChildren():Int {
		return mChildren.length;
	}

	public function addLabel(label:String, time:Float) {
		mLabels[label] = time;
	}

	public function resolvePosition(position:ASObject):Float {
		var _loc2_:String = null;
		if (Std.isOfType(position, String)) {
			_loc2_ = ASCompat.toString(position);
			if (!mLabels.exists(_loc2_)) {
				addLabel(_loc2_, duration);
			}
			return ASCompat.toNumber(mLabels[_loc2_]);
		}
		var _loc3_ = ASCompat.toNumber(position);
		return Math.isNaN(_loc3_) ? 0 : _loc3_;
	}

	public function insert(child:TweenHandle, position:ASObject = null) {
		if (child == null || child.isKilled) {
			return;
		}
		var _loc3_ = resolvePosition(position);
		child.detachFromJuggler();
		if (child.parentTimeline != null) {
			child.parentTimeline.removeChild(child);
		}
		child.parentTimeline = this;
		mChildren.push(child);
		mPositions.push(_loc3_);
		mComplete = false;
	}

	public function append(child:TweenHandle) {
		insert(child, duration);
	}

	public function removeChild(child:TweenHandle) {
		var _loc2_ = mChildren.indexOf(child);
		if (_loc2_ == -1) {
			return;
		}
		mChildren.splice(_loc2_, (1 : UInt));
		mPositions.splice(_loc2_, (1 : UInt));
		if (child.parentTimeline == this) {
			child.parentTimeline = null;
		}
		if (mChildren.length == 0 && mTime > 0) {
			mComplete = true;
		}
	}

	public function killChildren() {
		var _loc1_ = mChildren.concat();
		var _loc2_:TweenHandle;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc2_ = _tmp_;
				_loc2_.kill();
			}
	}

	public function advanceTime(time:Float) {
		var _loc7_ = 0;
		var _loc11_:TweenHandle = null;
		var _loc6_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc12_ = Math.NaN;
		if (mComplete || time == 0 || mChildren.length == 0) {
			return;
		}
		var _loc3_ = mTime;
		var _loc2_ = duration;
		mTime += time;
		if (mTime < 0) {
			mTime = 0;
		}
		if (mTime > _loc2_) {
			mTime = _loc2_;
		}
		var _loc4_ = mChildren.concat();
		var _loc8_ = mPositions.concat();
		_loc7_ = 0;
		while (_loc7_ < _loc4_.length) {
			_loc11_ = _loc4_[_loc7_];
			if (!(_loc11_.parentTimeline != this || _loc11_.isComplete)) {
				_loc6_ = _loc8_[_loc7_];
				_loc9_ = _loc6_ + _loc11_.totalSpan;
				if (time > 0) {
					if (mTime >= _loc9_) {
						_loc11_.advanceTime(_loc11_.totalSpan - _loc11_.currentTime + 0.0001);
					} else {
						_loc10_ = _loc3_ > _loc6_ ? _loc3_ : _loc6_;
						if (mTime > _loc10_) {
							_loc11_.advanceTime(mTime - _loc10_);
						}
					}
				} else {
					_loc5_ = _loc3_ < _loc9_ ? _loc3_ : _loc9_;
					_loc12_ = mTime > _loc6_ ? mTime : _loc6_;
					if (_loc12_ < _loc5_) {
						_loc11_.advanceTime(_loc12_ - _loc5_);
					}
				}
			}
			_loc7_++;
		}
		if (time > 0 && mTime >= _loc2_ && allChildrenComplete()) {
			mComplete = true;
			if (onComplete != null) {
				ASCompatMacro.applyClosure(onComplete, onCompleteArgs);
			}
		}
	}

	function allChildrenComplete():Bool {
		var _loc1_:TweenHandle;
		final __ax4_iter_415 = mChildren;
		if (checkNullIteratee(__ax4_iter_415))
			for (_tmp_ in __ax4_iter_415) {
				_loc1_ = _tmp_;
				if (!_loc1_.isComplete) {
					return false;
				}
			}
		return true;
	}
}
