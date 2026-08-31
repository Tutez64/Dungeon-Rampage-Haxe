package brain.uI;

import brain.facade.Facade;
import brain.utils.MemoryTracker;
import flash.display.MovieClip;

class UISlider extends UIObject {
	public static inline final HORIZONTAL = (0 : UInt);

	public static inline final VERTICAL = (1 : UInt);

	var mHandle:UISliderHandleButton;

	var mBack:UIButton;

	var mBackClick:Bool = true;

	var mValue:Float = 0;

	var mMax:Float = 100;

	var mMin:Float = 0;

	var mOrientation:UInt = 0;

	var mTick:Float = 0.01;

	var mUpdateCallback:ASFunction;

	public function new(facade:Facade, root:MovieClip, orientation:UInt = (0 : UInt)) {
		super(facade, root);
		mOrientation = orientation;
		mBack = new UIButton(facade, ASCompat.dynamicAs((root : ASAny).back, flash.display.MovieClip));
		MemoryTracker.track(mBack, "UIButton - slider back created in UISlider()", "brain");
		mBack.releaseCallback = this.backCallback;
		mHandle = new UISliderHandleButton(facade, ASCompat.dynamicAs((root : ASAny).handle, flash.display.MovieClip), mOrientation, mBack.root.width,
			mBack.root.height);
		MemoryTracker.track(mHandle, "UISliderHandleButton - slider handle created in UISlider()", "brain");
		mHandle.slideCallback = this.handleCallback;
	}

	override public function destroy() {
		mBack.destroy();
		mBack = null;
		mHandle.destroy();
		mHandle = null;
		mUpdateCallback = null;
	}

	@:isVar public var updateCallback(never, set):ASFunction;

	public function set_updateCallback(value:ASFunction):ASFunction {
		return mUpdateCallback = value;
	}

	function handleCallback() {
		var _loc1_ = mValue;
		if (mOrientation == 0) {
			mValue = mHandle.root.x / mBack.root.width * (mMax - mMin) + mMin;
		} else {
			mValue = (mBack.root.height - mHandle.root.y) / mBack.root.height * (mMax - mMin) + mMin;
		}
		this.clampValue();
		if (_loc1_ != mValue && mUpdateCallback != null) {
			mUpdateCallback(this.value);
		}
	}

	function backCallback() {
		if (!mBackClick) {
			return;
		}
		var _loc1_ = mValue;
		if (mOrientation == 0) {
			mHandle.root.x = mBack.root.mouseX;
			mHandle.root.x = Math.max(mHandle.root.x, 0);
			mHandle.root.x = Math.min(mHandle.root.x, mBack.root.width);
			mValue = mHandle.root.x / mBack.root.width * (mMax - mMin) + mMin;
		} else {
			mHandle.root.y = mBack.root.mouseY;
			mHandle.root.y = Math.max(mHandle.root.y, 0);
			mHandle.root.y = Math.min(mHandle.root.y, mBack.root.height);
			mValue = (mBack.root.height - mHandle.root.y) / mBack.root.height * (mMax - mMin) + mMin;
		}
		this.clampValue();
		if (_loc1_ != mValue && mUpdateCallback != null) {
			mUpdateCallback(this.value);
		}
	}

	function clampValue() {
		if (mMax > mMin) {
			mValue = Math.min(mValue, mMax);
			mValue = Math.max(mValue, mMin);
		} else {
			mValue = Math.max(mValue, mMax);
			mValue = Math.min(mValue, mMin);
		}
	}

	function positionHandle() {
		var _loc1_ = Math.NaN;
		if (mOrientation == 0) {
			_loc1_ = mBack.root.width;
			mHandle.root.x = (mValue - mMin) / (mMax - mMin) * _loc1_;
		} else {
			_loc1_ = mBack.root.height;
			mHandle.root.y = _loc1_ - (mValue - mMin) / (mMax - mMin) * _loc1_;
		}
	}

	@:isVar public var backClick(get, set):Bool;

	public function set_backClick(b:Bool):Bool {
		return mBackClick = b;
	}

	function get_backClick():Bool {
		return mBackClick;
	}

	@:isVar public var value(get, set):Float;

	public function set_value(v:Float):Float {
		mValue = v;
		this.clampValue();
		this.positionHandle();
		return v;
	}

	@:isVar public var valueWithCallback(never, set):Float;

	public function set_valueWithCallback(v:Float):Float {
		this.value = v;
		if (mUpdateCallback != null) {
			mUpdateCallback(this.value);
		}
		return v;
	}

	function get_value():Float {
		return Math.fround(mValue / mTick) * mTick;
	}

	@:isVar public var rawValue(get, never):Float;

	public function get_rawValue():Float {
		return mValue;
	}

	@:isVar public var maximum(get, set):Float;

	public function set_maximum(m:Float):Float {
		mMax = m;
		this.clampValue();
		this.positionHandle();
		return m;
	}

	function get_maximum():Float {
		return mMax;
	}

	@:isVar public var minimum(get, set):Float;

	public function set_minimum(m:Float):Float {
		mMin = m;
		this.clampValue();
		this.positionHandle();
		return m;
	}

	function get_minimum():Float {
		return mMin;
	}

	@:isVar public var tick(get, set):Float;

	public function set_tick(t:Float):Float {
		return mTick = t;
	}

	function get_tick():Float {
		return mTick;
	}

	@:isVar public var orientation(get, never):UInt;

	public function get_orientation():UInt {
		return mOrientation;
	}
}
