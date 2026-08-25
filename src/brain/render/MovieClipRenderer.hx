package brain.render;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
import flash.display.MovieClip;
import flash.events.Event;

class MovieClipRenderer {
	static inline final LOOP_LABEL = "loop";

	static inline final NO_LOOP_LABEL = "noloop";

	static inline final RENDERER_OWNER_PROPERTY = "MCR_renderer";

	var mFrameRate:Float = 24;

	var mPlayRate:Float = 1;

	var mLoop:Bool = true;

	var mPlayHead:Float = 1;

	var mStartFrame:UInt = (1 : UInt);

	var mMaxFrames:UInt = 0;

	var mClip:MovieClip;

	var mOnFrameTask:Task;

	var mFinishedCallback:ASFunction;

	var mIsPlaying:Bool = false;

	var mLogicalWorkComponent:LogicalWorkComponent;

	public function new(facade:Facade, clip:MovieClip, finishedCallback:ASFunction = null, assetLabel:String = null) {
		this.clip = clip;
		mFinishedCallback = finishedCallback;
		if (mMaxFrames > 1) {
			mLogicalWorkComponent = new LogicalWorkComponent(facade, "MovieClipRenderer");
			if (mClip.stage != null) {
				onAdd();
			}
			mClip.addEventListener("addedToStage", onAdd);
			mClip.addEventListener("removedFromStage", onRemove);
		}
	}

	public function setFrame(frameNumber:UInt) {
		mPlayHead = frameNumber;
		this.updateClip(mClip);
	}

	@:isVar public var currentFrame(get, never):UInt;

	public function get_currentFrame():UInt {
		return (Std.int(Math.fround(mPlayHead % mMaxFrames) + 1) : UInt);
	}

	public function play(startingFrame:UInt = (0 : UInt), loop:Bool = false, finishedCallback:ASFunction = null) {
		if (finishedCallback != null) {
			mFinishedCallback = finishedCallback;
		}
		if (mMaxFrames <= 1) {
			mClip.gotoAndStop(1);
		} else {
			mPlayHead = startingFrame;
			mLoop = loop;
			mIsPlaying = true;
			mMaxFrames = initialize(mClip);
			this.updateClip(mClip);
			if (mClip.stage != null) {
				onAdd();
			}
		}
	}

	@:isVar public var finishedCallback(never, set):ASFunction;

	public function set_finishedCallback(value:ASFunction):ASFunction {
		return mFinishedCallback = value;
	}

	public function stop() {
		mIsPlaying = false;
	}

	public function destroy() {
		if (mClip != null) {
			mClip.removeEventListener("addedToStage", onAdd);
			mClip.removeEventListener("removedFromStage", onRemove);
			if (ASCompat.getProperty(mClip, RENDERER_OWNER_PROPERTY) == this) {
				ASCompat.deleteProperty(mClip, RENDERER_OWNER_PROPERTY);
			}
		}
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
			mOnFrameTask = null;
		}
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
		mClip = null;
		mFinishedCallback = null;
	}

	function onAdd(event:Event = null) {
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
		}
		mOnFrameTask = mLogicalWorkComponent.doEveryFrame(onFrame);
	}

	function onRemove(event:Event = null) {
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
			mOnFrameTask = null;
		}
	}

	@:isVar public var playRate(get, set):Float;

	public function get_playRate():Float {
		return mPlayRate;
	}

	function set_playRate(value:Float):Float {
		return mPlayRate = value;
	}

	@:isVar public var frameRate(get, set):Float;

	public function get_frameRate():Float {
		return mFrameRate;
	}

	function set_frameRate(value:Float):Float {
		mFrameRate = frameRate;
		return value;
	}

	@:isVar public var startFrame(never, set):UInt;

	public function set_startFrame(value:UInt):UInt {
		return mStartFrame = value;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return mLoop;
	}

	function set_loop(value:Bool):Bool {
		return mLoop = value;
	}

	public function onFrame(gameClock:GameClock) {
		if (mClip == null) {
			return;
		}
		if (mClip.stage == null) {
			Logger.warn("Animating MovieClipRenderer that is not on stage");
		}
		if (!mIsPlaying) {
			return;
		}
		var previousFrame = Math.fround(mPlayHead);
		mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
		if (mPlayHead > mMaxFrames - 1 && !mLoop) {
			mIsPlaying = false;
			mPlayHead = mMaxFrames - 1;
			this.updateClip(mClip);
			if (mOnFrameTask != null) {
				mOnFrameTask.destroy();
				mOnFrameTask = null;
			}
			mIsPlaying = false;
			if (mFinishedCallback != null) {
				mFinishedCallback();
			}
			return;
		}
		if (previousFrame != Math.fround(mPlayHead)) {
			this.updateClip(mClip);
		}
	}

	@:isVar public var clip(get, set):MovieClip;

	public function set_clip(value:MovieClip):MovieClip {
		if (value == mClip) {
			return value;
		}
		if (mClip != null && ASCompat.getProperty(mClip, RENDERER_OWNER_PROPERTY) == this) {
			ASCompat.deleteProperty(mClip, RENDERER_OWNER_PROPERTY);
		}
		mClip = value;
		ASCompat.setProperty(mClip, RENDERER_OWNER_PROPERTY, this);
		mPlayHead = mStartFrame;
		mMaxFrames = initialize(mClip);
		this.updateClip(mClip);
		return value;
	}

	function get_clip():MovieClip {
		return mClip;
	}

	@:isVar public var numFrames(get, never):UInt;

	public function get_numFrames():UInt {
		if (mClip == null) {
			return (0 : UInt);
		}
		return mMaxFrames;
	}

	function updateClip(parent:DisplayObjectContainer) {
		var rendererOwner = ASCompat.getProperty(parent, RENDERER_OWNER_PROPERTY);
		if (parent != mClip && rendererOwner != null && rendererOwner != this) {
			return;
		}
		var _loc5_:MovieClip = null;
		var _loc4_:DisplayObject = null;
		var _loc7_:DisplayObjectContainer = null;
		var _loc2_:MovieClip = null;
		var _loc3_ = 0;
		var _loc6_ = 0;
		var _loc8_ = 0;
		_loc5_ = ASCompat.reinterpretAs(parent, MovieClip);
		if (_loc5_ != null && _loc5_.totalFrames > 1) {
			if (ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame") > 0) {
				if (ASCompat.toBool((_loc5_ : ASAny).MCR_playedIntro)) {
					_loc3_ = ASCompat.toInt(_loc5_.totalFrames - ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame") + 1);
					_loc6_ = ASCompat.toInt(Math.fround(ASCompat.toNumber(ASCompat.toNumber(ASCompat.toNumber(mPlayHead
						- ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame"))
						- 1) % _loc3_))
						+ (_loc5_ : ASAny).MCR_firstLoopFrame);
				} else {
					_loc6_ = Std.int(Math.fround(mPlayHead % _loc5_.totalFrames) + 1);
					if (mPlayHead >= _loc5_.totalFrames) {
						ASCompat.setProperty(_loc5_, "MCR_playedIntro", true);
					}
				}
			} else {
				_loc6_ = Std.int(Math.fround(mPlayHead % _loc5_.totalFrames) + 1);
			}
			_loc5_.gotoAndStop(_loc6_);
		}
		_loc8_ = 0;
		while (_loc8_ < parent.numChildren) {
			try {
				_loc4_ = parent.getChildAt(_loc8_);
				_loc7_ = ASCompat.reinterpretAs(_loc4_, DisplayObjectContainer);
				if (_loc7_ != null && _loc7_.numChildren != 0) {
					updateClip(_loc7_);
				} else {
					_loc2_ = ASCompat.reinterpretAs(_loc4_, MovieClip);
					if (_loc2_ != null && _loc2_.totalFrames > 1) {
						updateClip(_loc2_);
					}
				}
			} catch (error:Dynamic) {}
			_loc8_++;
		}
	}

	@:isVar public var duration(get, never):Float;

	public function get_duration():Float {
		if (mClip == null) {
			return 0;
		}
		return mMaxFrames / this.frameRate / this.playRate;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return mIsPlaying;
	}

	function initialize(parent:DisplayObjectContainer, currentMax:UInt = (0 : UInt), indent:String = ""):UInt {
		var rendererOwner = ASCompat.getProperty(parent, RENDERER_OWNER_PROPERTY);
		if (parent != mClip && rendererOwner != null && rendererOwner != this) {
			return currentMax;
		}
		var _loc7_:DisplayObject = null;
		var _loc4_:MovieClip = null;
		var _loc5_:DisplayObjectContainer = null;
		var _loc6_ = 0;
		_loc4_ = ASCompat.reinterpretAs(parent, MovieClip);
		if (_loc4_ != null) {
			currentMax = (Std.int(Math.max(currentMax, _loc4_.totalFrames)) : UInt);
			this.determineFrames(_loc4_);
		}
		_loc6_ = 0;
		while (_loc6_ < parent.numChildren) {
			try {
				_loc7_ = parent.getChildAt(_loc6_);
				_loc5_ = ASCompat.reinterpretAs(_loc7_, DisplayObjectContainer);
				if (_loc5_ != null && _loc5_.numChildren != 0) {
					currentMax = (Std.int(Math.max(currentMax, initialize(_loc5_, currentMax, indent + "    "))) : UInt);
				} else if (Std.isOfType(_loc7_, MovieClip)) {
					currentMax = (Std.int(Math.max(currentMax, cast(_loc7_, MovieClip).totalFrames)) : UInt);
				}
			} catch (error:Dynamic) {}
			_loc6_++;
		}
		return currentMax;
	}

	function determineFrames(mc:MovieClip) {
		var _loc2_ = -1;
		var _loc3_:FrameLabel;
		final __ax4_iter_148 = mc.currentLabels;
		if (checkNullIteratee(__ax4_iter_148))
			for (_tmp_ in __ax4_iter_148) {
				_loc3_ = _tmp_;
				if (_loc3_.name == "loop") {
					_loc2_ = _loc3_.frame;
					mLoop = true;
					break;
				}
				if (_loc3_.name == "noloop") {
					mLoop = false;
					break;
				}
			}
		ASCompat.setProperty(mc, "MCR_firstLoopFrame", _loc2_);
		ASCompat.setProperty(mc, "MCR_playedIntro", false);
	}
}
