package brain.render.tweens;

import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;

/*internal*/
class GlowFilterAdapter {
	var mTarget:DisplayObject;

	var mProps:ASObject;

	var mRemove:Bool = false;

	var mStart:GlowFilter;

	var mEnd:GlowFilter;

	var mProgress:Float = 0;

	var mOriginalFilter:GlowFilter = null;

	public function new(target:DisplayObject, props:ASObject) {
		mTarget = target;
		mProps = if (ASCompat.toBool(props)) props else {};
		mRemove = mProps.remove == true;
		var _loc3_ = findExisting();
		mOriginalFilter = ASCompat.coerce(_loc3_ != null ? ASCompat.reinterpretAs(_loc3_.clone(), GlowFilter) : null, flash.filters.GlowFilter);
	}

	static function lerp(from:Float, to:Float, ratio:Float):Float {
		return from + (to - from) * ratio;
	}

	static function lerpColor(from:UInt, to:UInt, ratio:Float):UInt {
		var _loc4_ = ASCompat.floatToInt(lerp((from : Int) >> 16 & 0xFF, (to : Int) >> 16 & 0xFF, ratio));
		var _loc6_ = ASCompat.floatToInt(lerp((from : Int) >> 8 & 0xFF, (to : Int) >> 8 & 0xFF, ratio));
		var _loc5_ = ASCompat.floatToInt(lerp((from : Int) & 0xFF, (to : Int) & 0xFF, ratio));
		return ((clampChannel(_loc4_) : Int) << 16 | (clampChannel(_loc6_) : Int) << 8 | (clampChannel(_loc5_) : Int) : UInt);
	}

	static function clampChannel(value:Int):UInt {
		return (value < 0 ? (0 : UInt) : ((value > 255 ? (255 : UInt) : (value : UInt) : UInt)) : UInt);
	}

	@:isVar public var progress(get, set):Float;

	public function get_progress():Float {
		return mProgress;
	}

	function set_progress(value:Float):Float {
		mProgress = value;
		if (mStart == null) {
			capture();
		}
		var _loc2_ = new GlowFilter(lerpColor(mStart.color, mEnd.color, value), lerp(mStart.alpha, mEnd.alpha, value), lerp(mStart.blurX, mEnd.blurX, value),
			lerp(mStart.blurY, mEnd.blurY, value), lerp(mStart.strength, mEnd.strength, value), mEnd.quality, mEnd.inner, mEnd.knockout);
		applyFilter(_loc2_);
		return value;
	}

	public function finish() {
		if (mRemove) {
			removeFilter();
		}
	}

	public function revert() {
		if (mTarget == null) {
			return;
		}
		if (mOriginalFilter != null) {
			applyFilter(mOriginalFilter);
		} else {
			removeFilter();
		}
	}

	function capture() {
		var _loc1_ = findExisting();
		if (_loc1_ != null) {
			mStart = ASCompat.reinterpretAs(_loc1_.clone(), GlowFilter);
		} else {
			mStart = new GlowFilter((16777215 : UInt), 0, 0, 0, mProps.hasOwnProperty("strength") ? ASCompat.toNumber(mProps.strength) : 1,
				mProps.hasOwnProperty("quality") ? ASCompat.toInt(mProps.quality) : 2, mProps.inner == true, mProps.knockout == true);
		}
		mEnd = ASCompat.reinterpretAs(mStart.clone(), GlowFilter);
		if (mProps.hasOwnProperty("color")) {
			mEnd.color = (ASCompat.floatToInt(ASCompat.toNumber(mProps.color)) : UInt);
		}
		if (mProps.hasOwnProperty("alpha")) {
			mEnd.alpha = ASCompat.toNumber(mProps.alpha);
		}
		if (mProps.hasOwnProperty("blurX")) {
			mEnd.blurX = ASCompat.toNumber(mProps.blurX);
		}
		if (mProps.hasOwnProperty("blurY")) {
			mEnd.blurY = ASCompat.toNumber(mProps.blurY);
		}
		if (mProps.hasOwnProperty("strength")) {
			mEnd.strength = ASCompat.toNumber(mProps.strength);
		}
		if (mProps.hasOwnProperty("quality")) {
			mEnd.quality = ASCompat.toInt(mProps.quality);
		}
		if (mProps.hasOwnProperty("inner")) {
			mEnd.inner = mProps.inner == true;
		}
		if (mProps.hasOwnProperty("knockout")) {
			mEnd.knockout = mProps.knockout == true;
		}
	}

	function findExisting():GlowFilter {
		var _loc1_:BitmapFilter;
		var _loc2_ = mTarget.filters;
		if (_loc2_ != null) {
			if (checkNullIteratee(_loc2_))
				for (_tmp_ in _loc2_) {
					_loc1_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
					if (Std.isOfType(_loc1_, GlowFilter)) {
						return cast(_loc1_, GlowFilter);
					}
				}
		}
		return null;
	}

	function applyFilter(filter:GlowFilter) {
		var _loc3_ = 0;
		var _loc4_ = if (mTarget.filters != null) mTarget.filters else [];
		var _loc2_ = false;
		_loc3_ = 0;
		while (_loc3_ < _loc4_.length) {
			if (Std.isOfType(_loc4_[_loc3_], GlowFilter)) {
				_loc4_[_loc3_] = filter;
				_loc2_ = true;
				break;
			}
			_loc3_++;
		}
		if (!_loc2_) {
			_loc4_.push(filter);
		}
		mTarget.filters = cast(_loc4_);
	}

	function removeFilter() {
		var _loc2_ = mTarget.filters;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Array<ASAny> = [];
		var _loc1_:BitmapFilter;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc1_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
				if (!Std.isOfType(_loc1_, GlowFilter)) {
					_loc3_.push(_loc1_);
				}
			}
		mTarget.filters = cast(_loc3_);
	}
}
