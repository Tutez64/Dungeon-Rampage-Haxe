package brain.uI;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.Graphics;
import flash.display.MovieClip;

class UICircularProgressBar extends UIObject {
	var mDuration:Float = Math.NaN;

	var mDeltaAngle:Float = Math.NaN;

	var mCurrentAngle:Float = Math.NaN;

	var mCurrentX:Float = Math.NaN;

	var mCurrentY:Float = Math.NaN;

	var mColor:UInt = 0;

	var mRadius:Float = Math.NaN;

	var mStartAngle:Float = Math.NaN;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mGraphics:Graphics;

	var mEmptyClip:MovieClip;

	var mStartTime:Float = Math.NaN;

	var mDrawTask:Task;

	public function new(facade:Facade, root:MovieClip, radius:Float, color:UInt, duration:Float, dAngle:Float = 1, startAngle:Float = 180) {
		super(facade, root);
		mLogicalWorkComponent = new LogicalWorkComponent(facade, "UICircularProgressBar");
		MemoryTracker.track(mLogicalWorkComponent, "LogicalWorkComponent - created in UICircularProgressBar()", "brain");
		mEmptyClip = new MovieClip();
		MemoryTracker.track(mEmptyClip, "MovieClip - drawing clip created in UICircularProgressBar()", "brain");
		mGraphics = mEmptyClip.graphics;
		root.addChildAt(mEmptyClip, root.numChildren);
		mStartAngle = startAngle;
		mDuration = duration;
		mDeltaAngle = dAngle;
		mRadius = radius;
		mColor = color;
		mCurrentAngle = startAngle;
		calculateStep();
	}

	function killDrawTask(gameClock:GameClock) {
		mGraphics.clear();
		mDrawTask.destroy();
	}

	function calculateStep() {
		var _loc1_ = mCurrentAngle * 3.141592653589793 / 180;
		mCurrentX = mRadius * Math.sin(_loc1_);
		mCurrentY = mRadius * Math.cos(_loc1_);
	}

	@:isVar public var clip(get, set):MovieClip;

	public function get_clip():MovieClip {
		return mEmptyClip;
	}

	function set_clip(value:MovieClip):MovieClip {
		return mEmptyClip = value;
	}

	@:isVar public var angle(get, set):Float;

	public function get_angle():Float {
		return mCurrentAngle;
	}

	function set_angle(value:Float):Float {
		var _loc4_ = 0;
		var _loc2_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.round(value / mDeltaAngle);
		var _loc3_ = mCurrentAngle * 3.141592653589793 / 180;
		_loc4_ = 0;
		while (_loc4_ < _loc6_) {
			_loc2_ = mRadius * Math.sin(_loc3_);
			_loc5_ = mRadius * Math.cos(_loc3_);
			mGraphics.moveTo(mCurrentX, mCurrentY);
			mGraphics.lineStyle(5, mColor);
			mGraphics.lineTo(_loc2_, _loc5_);
			mGraphics.endFill();
			mCurrentX = _loc2_;
			mCurrentY = _loc5_;
			mCurrentAngle -= mDeltaAngle;
			_loc4_++;
		}
		return value;
	}

	@:isVar public var updateTask(never, set):Task;

	public function set_updateTask(value:Task):Task {
		return mDrawTask = value;
	}

	override public function destroy() {
		if (mDrawTask != null) {
			mDrawTask.destroy();
			mDrawTask = null;
		}
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
		super.destroy();
	}
}
