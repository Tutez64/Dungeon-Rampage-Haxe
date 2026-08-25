package brain.render;

import brain.assetRepository.SpriteSheetAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.workLoop.WorkComponent;

class ActorSpriteSheetRenderer extends SpriteSheetRenderer implements IRenderer {
	public static var SPRITE_SHEET_RENDERER_TYPE:String = "SpriteSheetRenderer";

	var mFrameRate:Float = 24;

	var mPlayRate:Float = 1;

	var mDuration:Float = 0;

	var mFrameTimes:Vector<Float>;

	var mLoop:Bool = true;

	var mIsPlaying:Bool = false;

	var mAnimationFrame:UInt = (0 : UInt);

	var mPlayHead:Float = 0;

	var mHeading:Float = 0;

	public function new(workComponent:WorkComponent, sheet:SpriteSheetAsset, bitmapNameValue:String) {
		super(workComponent, sheet);
		mBitmap.name = "ActorSpriteSheetRenderer_" + bitmapNameValue;
		mFrameTimes = sheet.timingVector;
		if ((mFrameTimes.length : UInt) != sheet.numFramesX) {
			throw new Error("Warning: frameTimes vector length and sheet numFramesX must match");
		}
		mDuration = 0;
		var _loc4_:Int;
		final __ax4_iter_148 = mFrameTimes;
		if (checkNullIteratee(__ax4_iter_148))
			for (_tmp_ in __ax4_iter_148) {
				_loc4_ = Std.int(_tmp_);
				mDuration += _loc4_ / 1000;
			}
		MemoryTracker.track(this, "ActorSpriteSheetRenderer name=" + bitmapNameValue + " - created in ActorSpriteSheetRenderer()", "brain");
	}

	@:isVar public var playRate(get, set):Float;

	public function get_playRate():Float {
		return mPlayRate;
	}

	@:isVar public var rendererType(get, never):String;

	public function get_rendererType():String {
		return SPRITE_SHEET_RENDERER_TYPE;
	}

	function set_playRate(value:Float):Float {
		return mPlayRate = value;
	}

	override public function destroy() {
		super.destroy();
	}

	@:isVar public var durationInSeconds(get, never):Float;

	public function get_durationInSeconds():Float {
		return mDuration / mPlayRate;
	}

	@:isVar public var frameCount(get, never):Float;

	public function get_frameCount():Float {
		return mFrameTimes.length;
	}

	override public function get_loop():Bool {
		return mLoop;
	}

	@:isVar public var frameRate(get, never):UInt;

	public function get_frameRate():UInt {
		return (Std.int(mFrameRate) : UInt);
	}

	function getFrameFromTime(time:Float):UInt {
		var _loc3_ = (0 : UInt);
		var _loc4_:Float = 0;
		var _loc2_:Float;
		final __ax4_iter_149 = mFrameTimes;
		if (checkNullIteratee(__ax4_iter_149))
			for (_tmp_ in __ax4_iter_149) {
				_loc2_ = _tmp_;
				_loc4_ += _loc2_ / 1000 / mPlayRate;
				if (_loc4_ > time) {
					break;
				}
				_loc3_++;
			}
		return _loc3_;
	}

	function getTimeFromFrame(frame:UInt):Float {
		var _loc3_ = 0;
		var _loc2_ = frame;
		if (frame >= (mFrameTimes.length : UInt)) {
			Logger.warn("Trying to set animation to frame: " + frame + ", but mFrameTimes only has length of: " + mFrameTimes.length);
			_loc2_ = (mFrameTimes.length : UInt);
		}
		var _loc4_:Float = 0;
		_loc3_ = 0;
		while ((_loc3_ : UInt) < _loc2_) {
			_loc4_ += mFrameTimes[_loc3_] / 1000 / mPlayRate;
			_loc3_++;
		}
		return _loc4_;
	}

	function getAnimationIndexFromClock(gameClock:GameClock):UInt {
		mPlayHead += gameClock.tickLength;
		if (!mLoop && mPlayHead >= this.durationInSeconds) {
			stop();
			return this.mSpriteSheet.numFramesX - 1;
		}
		mPlayHead %= this.durationInSeconds;
		mAnimationFrame = this.getFrameFromTime(mPlayHead);
		return mAnimationFrame;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return mIsPlaying;
	}

	override public function play(startingFrame:UInt = (0 : UInt), loop:Bool = true, finishedCallback:ASFunction = null) {
		mIsPlaying = true;
		mAnimationFrame = startingFrame;
		mPlayHead = this.getTimeFromFrame(startingFrame);
		mLoop = loop;
		super.play(startingFrame, loop, finishedCallback);
		if (mIsPlaying && mBitmap.stage != null && mOnFrameTask == null) {
			this.onAdd();
		}
	}

	override public function stop() {
		super.stop();
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
			mOnFrameTask = null;
		}
		mIsPlaying = false;
	}

	override function onFrame(gameClock:GameClock) {
		var _loc3_ = 0;
		var _loc5_ = 0;
		var _loc4_ = 0;
		var _loc2_ = 0;
		if (mIsPlaying && mBitmap.stage != null) {
			_loc3_ = (getAnimationIndexFromClock(gameClock) : Int);
			_loc5_ = (getDirectionIndexFromHeading(mHeading) : Int);
			_loc4_ = (mXIndex : Int);
			_loc2_ = (mYIndex : Int);
			setFrameIndexes((_loc3_ : UInt), (_loc5_ : UInt));
			if (mXIndex != (_loc4_ : UInt) || mYIndex != (_loc2_ : UInt)) {
				super.onFrame(gameClock);
			}
		}
	}

	override public function set_heading(value:Float):Float {
		while (value < -180) {
			value += 360;
		}
		while (value > 180) {
			value -= 360;
		}
		return mHeading = value;
	}

	public override function get_heading():Float {
		return mHeading;
	}

	public function getDirectionIndexFromHeading(heading:Float):UInt {
		if (heading > 90) {
			heading = -heading + 180;
		} else if (heading < -90) {
			heading = -heading - 180;
		}
		switch (mSpriteSheet.numFramesY - 1) {
			case 0:
				return (0 : UInt);
			case 1:
				if (180 >= heading && heading >= 0) {
					return (1 : UInt);
				}
				if (0 >= heading && heading >= -180) {
					return (0 : UInt);
				}
				throw new Error("unknown heading:", ASCompat.toInt(heading));

			case 2:
				if (90 >= heading && heading >= 60) {
					return (0 : UInt);
				}
				if (60 >= heading && heading >= 0) {
					return (2 : UInt);
				}
				if (0 >= heading && heading >= -90) {
					return (1 : UInt);
				}
				throw new Error("unknown heading:", ASCompat.toInt(heading));

			case 4:
				if (120 >= heading && heading >= 60) {
					return (4 : UInt);
				}
				if (60 >= heading && heading >= 30) {
					return (3 : UInt);
				}
				if (30 >= heading && heading >= -30) {
					return (2 : UInt);
				}
				if (-30 >= heading && heading >= -60) {
					return (1 : UInt);
				}
				if (-60 >= heading && heading >= -120) {
					return (0 : UInt);
				}
				throw new Error("unknown heading:", ASCompat.toInt(heading));

			default:
				throw new Error("unsupported numFramesY: " + Std.string(mSpriteSheet.numFramesY));
		}
		return 0;
	}

	override public function setFrame(frameNumber:UInt) {
		var _loc2_:Int = getDirectionIndexFromHeading(this.heading);
		setFrameIndexes(frameNumber, (_loc2_ : UInt));
		updateToCurrentFrame();
	}
}
