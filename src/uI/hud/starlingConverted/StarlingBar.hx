package uI.hud.starlingConverted;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

class StarlingBar implements IHudTick {
	static inline final LERP_DELAY:Float = 2;

	static inline final LERP_SPEED:Float = 0.125;

	var mBar:DisplayObject;

	var mDelta:DisplayObject;

	var mTicker:HudTicker;

	var mValue:Float = 0;

	var mDeltaValue:Float = 0;

	var mTrueValue:Float = 0;

	var mDeadline:Int = 0;

	var mLerping:Bool = false;

	var mWaiting:Bool = false;

	var mCut:Bool = false;

	var mDeltaCut:Bool = false;

	var mWidth:Float = Math.NaN;

	var mDeltaWidth:Float = Math.NaN;

	public function new(root:DisplayObject, delta:DisplayObject, ticker:HudTicker) {
		mBar = barChild(root);
		mDelta = delta != null ? barChild(delta) : null;
		mTicker = ticker;
		mCut = Std.isOfType(mBar, ArtDisplay) && cast(mBar, ArtDisplay).art.masked;
		mDeltaCut = Std.isOfType(mDelta, ArtDisplay) && cast(mDelta, ArtDisplay).art.masked;
		mWidth = Std.isOfType(mBar, ArtDisplay) ? cast(mBar, ArtDisplay).art.registrationWidth : (mBar != null ? mBar.width : 0);
		mDeltaWidth = Std.isOfType(mDelta, ArtDisplay) ? cast(mDelta, ArtDisplay).art.registrationWidth : (mDelta != null ? mDelta.width : 0);
		if (mDelta != null) {
			mDelta.alpha = 0.3;
		}
		update();
	}

	static function barChild(root:DisplayObject):DisplayObject {
		var _loc2_ = ASCompat.reinterpretAs(root, DisplayObjectContainer);
		var _loc3_ = _loc2_ != null ? _loc2_.getChildByName("bar") : null;
		return _loc3_ ?? root;
	}

	static function cut(display:DisplayObject, right:Float) {
		var _loc4_ = 0;
		if (Std.isOfType(display, StarlingBarImage)) {
			cast(display, StarlingBarImage).setCut(0, right);
		}
		var _loc3_ = ASCompat.reinterpretAs(display, DisplayObjectContainer);
		if (_loc3_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.numChildren) {
				cut(_loc3_.getChildAt(_loc4_), right);
				_loc4_++;
			}
		}
	}

	function update() {
		if (mCut) {
			mBar.scaleX = 1;
			cut(mBar, mWidth * mValue);
		} else if (mBar != null) {
			mBar.scaleX = mValue;
		}
		if (mDelta != null) {
			if (mDeltaCut) {
				mDelta.scaleX = 1;
				cut(mDelta, mDeltaWidth * mDeltaValue);
			} else {
				mDelta.scaleX = mDeltaValue;
			}
		}
	}

	@:isVar public var value(get, set):Float;

	public function get_value():Float {
		return mValue;
	}

	function set_value(value:Float):Float {
		var _loc2_ = Math.max(0, Math.min(1, value));
		mTrueValue = _loc2_;
		if (mDelta == null) {
			mValue = _loc2_;
		} else {
			if (mTrueValue > mValue) {
				mDeltaValue = Math.max(mDeltaValue, mTrueValue);
			} else {
				mValue = mTrueValue;
			}
			if (!mLerping && !mWaiting) {
				mWaiting = true;
				mDeadline = mTicker.gameTime + 2000;
				mTicker.register(this);
			}
		}
		update();
		return value;
	}

	public function tick(tickLength:Float, stageFrame:Bool) {
		var _loc3_ = Math.NaN;
		if (mWaiting) {
			if (mTicker.gameTime < mDeadline) {
				return;
			}
			mWaiting = false;
			mLerping = true;
			return;
		}
		if (!mLerping) {
			return;
		}
		var _loc4_ = mTrueValue <= mValue;
		if (mTrueValue > mValue) {
			_loc3_ = 1 - (mTrueValue - mValue) * 0.125;
			mValue += 1 - _loc3_ * _loc3_;
			if (mTrueValue - mValue < 0.05) {
				_loc4_ = true;
			}
		}
		if (mTrueValue < mDeltaValue) {
			_loc3_ = 1 - (mTrueValue - mDeltaValue) * 0.125;
			mDeltaValue += 1 - _loc3_ * _loc3_;
			if (mDeltaValue - mTrueValue >= 0.05) {
				_loc4_ = false;
			}
		}
		if (_loc4_) {
			mValue = mDeltaValue = mTrueValue;
			mLerping = false;
			mTicker.unregister(this);
		}
		update();
	}

	public function dispose() {
		mTicker.unregister(this);
	}
}
