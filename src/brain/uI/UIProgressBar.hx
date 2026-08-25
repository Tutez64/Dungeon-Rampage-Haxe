package brain.uI;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.MovieClip;
import flash.text.TextField;

class UIProgressBar extends UIObject {
	static inline final LERP_DELAY:Float = 2;

	static inline final LERP_SPEED:Float = 0.125;

	var mErrorMessage:MovieClip;

	var mErrorMessageLabel:TextField;

	var mMaximum:Float = 1;

	var mMinimum:Float = 0;

	var mValue:Float = Math.NaN;

	var mDeltaValue:Float = Math.NaN;

	var mTrueValue:Float = Math.NaN;

	public var bar:MovieClip;

	var mDeltaBar:MovieClip;

	var mWorkComponent:LogicalWorkComponent;

	var mLerpTask:Task;

	var mTimerTask:Task;

	public function new(facade:Facade, root:MovieClip, delta:MovieClip = null) {
		super(facade, root);
		mValue = mMinimum;
		mDeltaValue = mMinimum;
		mTrueValue = mMinimum;
		bar = ASCompat.dynamicAs(ASCompat.toBool((root : ASAny).bar) ? ASCompat.dynamicAs((root : ASAny).bar, flash.display.MovieClip) : root,
			flash.display.MovieClip);
		if (delta != null) {
			mDeltaBar = ASCompat.dynamicAs(ASCompat.toBool((delta : ASAny).bar) ? ASCompat.dynamicAs((delta : ASAny).bar, flash.display.MovieClip) : delta,
				flash.display.MovieClip);
			mDeltaBar.alpha = 0.3;
		}
		mWorkComponent = new LogicalWorkComponent(facade, "UIProgressBar");
		MemoryTracker.track(mWorkComponent, "LogicalWorkComponent - created in UIProgressBar()", "brain");
		update();
	}

	function update() {
		bar.scaleX = (mValue - mMinimum) / (mMaximum - mMinimum);
		if (mDeltaBar != null) {
			mDeltaBar.scaleX = (mDeltaValue - mMinimum) / (mMaximum - mMinimum);
		}
	}

	@:isVar public var maximum(get, set):Float;

	public function set_maximum(value:Float):Float {
		mMaximum = value;
		mValue = Math.min(mValue, mMaximum);
		update();
		return value;
	}

	function get_maximum():Float {
		return mMaximum;
	}

	@:isVar public var minimum(never, set):Float;

	public function set_minimum(value:Float):Float {
		mMinimum = value;
		mValue = Math.max(mValue, mMinimum);
		update();
		return value;
	}

	@:isVar public var mimimum(get, never):Float;

	public function get_mimimum():Float {
		return mMinimum;
	}

	function updateLerp(clock:GameClock) {
		var _loc2_ = Math.NaN;
		var _loc3_ = false;
		var _loc4_ = 1 - Math.pow(1 - LERP_SPEED, clock.tickLength / GameClock.ANIMATION_FRAME_DURATION);
		if (mTrueValue > mValue) {
			_loc2_ = 1 - (mTrueValue - mValue) * _loc4_;
			mValue += 1 - _loc2_ * _loc2_;
			if (mTrueValue - mValue < 0.05) {
				_loc3_ = true;
			}
		}
		if (mTrueValue < mDeltaValue) {
			_loc2_ = 1 - (mTrueValue - mDeltaValue) * _loc4_;
			mDeltaValue += 1 - _loc2_ * _loc2_;
			if (mDeltaValue - mTrueValue >= 0.05) {
				_loc3_ = false;
			}
		}
		if (_loc3_) {
			mDeltaValue = mValue = mTrueValue;
			mLerpTask.destroy();
			mLerpTask = null;
		}
		update();
	}

	function startLerp(clock:GameClock) {
		if (mLerpTask == null) {
			mLerpTask = mWorkComponent.doEveryFrame(updateLerp);
		}
		mTimerTask.destroy();
		mTimerTask = null;
	}

	@:isVar public var value(get, set):Float;

	public function set_value(v:Float):Float {
		var _loc2_ = Math.max(mMinimum, Math.min(v, mMaximum));
		if (mDeltaBar != null) {
			mTrueValue = _loc2_;
			if (mTrueValue > mValue) {
				mDeltaValue = Math.max(mDeltaValue, mTrueValue);
			} else {
				mValue = mTrueValue;
			}
			if (mLerpTask == null) {
				if (mTimerTask == null) {
					mTimerTask = mWorkComponent.doLater(2, startLerp);
				}
			}
		} else {
			mValue = _loc2_;
		}
		update();
		return v;
	}

	function get_value():Float {
		return mValue;
	}

	override public function destroy() {
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
		super.destroy();
	}

	public function displayErrorMessage(message:String) {
		mErrorMessage = new MovieClip();
		MemoryTracker.track(mErrorMessage, "MovieClip - error message container created in UIProgressBar.displayErrorMessage()", "brain");
		mFacade.sceneGraphManager.addChild(mErrorMessage, Std.int(mTooltipLayer));
		mErrorMessageLabel = new TextField();
		MemoryTracker.track(mErrorMessageLabel, "TextField - error label created in UIProgressBar.displayErrorMessage()", "brain");
		mErrorMessageLabel.x = 320;
		mErrorMessageLabel.y = 100;
		mErrorMessageLabel.text = message;
		mErrorMessageLabel.autoSize = "center";
		mErrorMessageLabel.background = true;
		mErrorMessageLabel.backgroundColor = (16711680 : UInt);
		mErrorMessageLabel.textColor = (0 : UInt);
		mErrorMessage.addChild(mErrorMessageLabel);
	}
}
