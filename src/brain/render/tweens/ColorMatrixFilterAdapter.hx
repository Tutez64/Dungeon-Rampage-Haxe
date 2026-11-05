package brain.render.tweens;

import brain.logger.Logger;
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

/*internal*/
class ColorMatrixFilterAdapter {
	static inline final LUM_R:Float = 0.212671;

	static inline final LUM_G:Float = 0.71516;

	static inline final LUM_B:Float = 0.072169;

	static var IDENTITY:Array<ASAny>;

	var mTarget:DisplayObject;

	var mFromProps:ASObject;

	var mToProps:ASObject;

	var mRemove:Bool = false;

	var mStart:Array<ASAny>;

	var mEnd:Array<ASAny>;

	var mProgress:Float = 0;

	var mOriginalFilter:ColorMatrixFilter = null;

	public function new(target:DisplayObject, fromProps:ASObject, toProps:ASObject) {
		mTarget = target;
		mFromProps = fromProps;
		mToProps = if (ASCompat.toBool(toProps)) toProps else {};
		mRemove = mToProps.remove == true;
		var _loc4_ = findExisting();
		mOriginalFilter = _loc4_ != null ? ASCompat.reinterpretAs(_loc4_.clone(), ColorMatrixFilter) : null;
	}

	static function buildMatrix(base:Array<ASAny>, props:ASObject):Array<ASAny> {
		var _loc3_ = Math.NaN;
		var _loc4_ = Std.isOfType(props.matrix, Array) ? ((ASCompat.dynamicAs(props.matrix, Array) : Array<ASAny>)).copy() : base.copy();
		if (props.hasOwnProperty("colorize")) {
			_loc3_ = props.hasOwnProperty("amount") ? ASCompat.toNumber(props.amount) : 1;
			_loc4_ = colorize(_loc4_, (ASCompat.toInt(props.colorize) : UInt), _loc3_);
		}
		var _loc5_:String;
		if (checkNullIteratee(props))
			for (_tmp_ in props.___keys()) {
				_loc5_ = _tmp_;
				if (_loc5_ != "matrix" && _loc5_ != "colorize" && _loc5_ != "amount" && _loc5_ != "remove") {
					Logger.warn("ColorMatrixFilterAdapter: unsupported colorMatrixFilter property \'" + _loc5_ + "\' ignored");
				}
			}
		return _loc4_;
	}

	static function colorize(matrix:Array<ASAny>, color:UInt, amount:Float):Array<ASAny> {
		var _loc5_ = ((color : Int) >> 16 & 0xFF) / 255;
		var _loc7_ = ((color : Int) >> 8 & 0xFF) / 255;
		var _loc6_ = ((color : Int) & 0xFF) / 255;
		var _loc4_ = 1 - amount;
		var _loc8_:Array<ASAny> = [
			_loc4_ + amount * _loc5_ * 0.212671,
			amount * _loc5_ * 0.71516,
			amount * _loc5_ * 0.072169,
			0,
			0,
			amount * _loc7_ * 0.212671,
			_loc4_ + amount * _loc7_ * 0.71516,
			amount * _loc7_ * 0.072169,
			0,
			0,
			amount * _loc6_ * 0.212671,
			amount * _loc6_ * 0.71516,
			_loc4_ + amount * _loc6_ * 0.072169,
			0,
			0,
			0,
			0,
			0,
			1,
			0
		];
		return multiply(_loc8_, matrix);
	}

	static function multiply(a:Array<ASAny>, b:Array<ASAny>):Array<ASAny> {
		var _loc7_ = 0;
		var _loc4_ = 0;
		var _loc5_ = Math.NaN;
		var _loc3_ = ASCompat.allocArray(20);
		var _loc6_ = 0;
		_loc7_ = 0;
		while (_loc7_ < 4) {
			_loc4_ = 0;
			while (_loc4_ < 5) {
				_loc5_ = ASCompat.toNumber(_loc4_ == 4 ? a[_loc6_ + 4] : 0);
				_loc3_[_loc6_ + _loc4_] = ASCompat.toNumber(a[_loc6_]) * ASCompat.toNumber(b[_loc4_])
					+ ASCompat.toNumber(a[_loc6_ + 1]) * ASCompat.toNumber(b[_loc4_ + 5])
					+ ASCompat.toNumber(a[_loc6_ + 2]) * ASCompat.toNumber(b[_loc4_ + 10])
					+ ASCompat.toNumber(a[_loc6_ + 3]) * ASCompat.toNumber(b[_loc4_ + 15])
					+ _loc5_;
				_loc4_++;
			}
			_loc6_ += 5;
			_loc7_++;
		}
		return _loc3_;
	}

	@:isVar public var progress(get, set):Float;

	public function get_progress():Float {
		return mProgress;
	}

	function set_progress(value:Float):Float {
		var _loc2_ = 0;
		mProgress = value;
		if (mStart == null) {
			capture();
		}
		var _loc3_ = ASCompat.allocArray(20);
		_loc2_ = 0;
		while (_loc2_ < 20) {
			_loc3_[_loc2_] = mStart[_loc2_] + (ASCompat.toNumber(mEnd[_loc2_]) - ASCompat.toNumber(mStart[_loc2_])) * value;
			_loc2_++;
		}
		applyFilter(new ColorMatrixFilter(cast(_loc3_)));
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
		var _loc2_ = _loc1_ != null ? _loc1_.matrix : IDENTITY.copy();
		mStart = ASCompat.toBool(mFromProps) ? buildMatrix(_loc2_, mFromProps) : _loc2_;
		mEnd = buildMatrix(_loc2_, mToProps);
	}

	function findExisting():ColorMatrixFilter {
		var _loc1_:BitmapFilter;
		var _loc2_ = mTarget.filters;
		if (_loc2_ != null) {
			if (checkNullIteratee(_loc2_))
				for (_tmp_ in _loc2_) {
					_loc1_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
					if (Std.isOfType(_loc1_, ColorMatrixFilter)) {
						return cast(_loc1_, ColorMatrixFilter);
					}
				}
		}
		return null;
	}

	function applyFilter(filter:ColorMatrixFilter) {
		var _loc3_ = 0;
		var _loc4_ = if (mTarget.filters != null) mTarget.filters else [];
		var _loc2_ = false;
		_loc3_ = 0;
		while (_loc3_ < _loc4_.length) {
			if (Std.isOfType(_loc4_[_loc3_], ColorMatrixFilter)) {
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
				if (!Std.isOfType(_loc1_, ColorMatrixFilter)) {
					_loc3_.push(_loc1_);
				}
			}
		mTarget.filters = cast(_loc3_);
	}

	static function __init__() {
		IDENTITY = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
	}
}
