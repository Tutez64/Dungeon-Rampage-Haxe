package metrics;

import facade.DBFacade;
import flash.text.TextField;
import flash.text.TextFormat;

class FPSReadout {
	var mDBFacade:DBFacade;

	var mFpsTextField:TextField;

	var averageLogicalFPS:Float = 24;

	var averageRenderFPS:Float = 60;

	var mWantVisible:Bool = false;

	var mSuppressed:Bool = false;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mFpsTextField = new TextField();
		mFpsTextField.text = "L:0 R:0 F:0 T:0";
		mFpsTextField.selectable = false;
		mFpsTextField.mouseEnabled = false;
		mFpsTextField.autoSize = "left";
		mFpsTextField.y = 20;
		var _loc2_ = new TextFormat();
		_loc2_.bold = true;
		_loc2_.font = "Verdana";
		_loc2_.color = 65280;
		_loc2_.size = 14;
		mFpsTextField.setTextFormat(_loc2_);
		mFpsTextField.defaultTextFormat = _loc2_;
		mFpsTextField.alpha = 1;
		mFpsTextField.background = true;
		mFpsTextField.backgroundColor = (0 : UInt);
		mFpsTextField.cacheAsBitmap = true;
		mFpsTextField.name = "FpsDebugTextField";
		mDBFacade.addRootDisplayObject(mFpsTextField, 1002);
		mFpsTextField.visible = false;
	}

	public function update(mTickCounter:Int, mWallClockTimeElapsed:Float, mFrameAccumulator:Int, mRenderTickCounter:Int, mTickAccumulator:Int) {
		var _loc7_ = Math.NaN;
		var _loc6_ = Math.NaN;
		if (mFpsTextField != null) {
			_loc7_ = mWallClockTimeElapsed == 0 ? averageLogicalFPS : mTickCounter * 1000 / mWallClockTimeElapsed;
			_loc6_ = mWallClockTimeElapsed == 0 ? averageRenderFPS : mRenderTickCounter * 1000 / mWallClockTimeElapsed;
			averageLogicalFPS = (averageLogicalFPS + _loc7_) / 2;
			averageRenderFPS = (averageRenderFPS + _loc6_) / 2;
			if (!mFpsTextField.visible) {
				return;
			}
			mFpsTextField.text = "L:" + ASCompat.toFixed(_loc7_, (1 : UInt)) + " R:" + ASCompat.toFixed(_loc6_, (1 : UInt)) + " F:" + mFrameAccumulator
				+ " T:" + mTickAccumulator;
		}
	}

	public function toggleVisibility() {
		mWantVisible = !mWantVisible;
		applyVisibility();
	}

	@:isVar public var suppressed(never, set):Bool;

	public function set_suppressed(value:Bool):Bool {
		mSuppressed = value;
		applyVisibility();
		return value;
	}

	function applyVisibility() {
		if (mFpsTextField != null) {
			mFpsTextField.visible = mWantVisible && !mSuppressed;
		}
	}
}
