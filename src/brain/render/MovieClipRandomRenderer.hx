package brain.render;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.MovieClip;
import org.as3commons.collections.Map;

class MovieClipRandomRenderer extends MovieClipRenderer {
	static inline final RANDOM_SUBSTRING_LABEL = "random";

	var mRandomLabels:Map = new Map();

	var mCurrentRandomLabel:RandomLabelObject;

	public function new(facade:Facade, clip:MovieClip, finishedCallback:ASFunction = null, assetLabel:String = null) {
		super(facade, clip, finishedCallback, assetLabel);
	}

	override public function destroy() {
		mRandomLabels.clear();
		mCurrentRandomLabel = null;
		super.destroy();
	}

	override public function onFrame(gameClock:GameClock) {
		if (mClip == null) {
			return;
		}
		mIsPlaying = true;
		if (mClip.stage == null) {
			Logger.warn("Animating MovieClipRenderer that is not on stage");
		}
		if (!mIsPlaying) {
			return;
		}
		var previousFrame = Math.fround(mPlayHead);
		var forceUpdate = false;
		mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
		if (mPlayHead >= mCurrentRandomLabel.endFrameNumber) {
			playNewRandomLabel();
			forceUpdate = true;
		}
		if (forceUpdate || previousFrame != Math.fround(mPlayHead)) {
			this.updateClip(mClip);
		}
	}

	function playNewRandomLabel() {
		var _loc2_ = mRandomLabels.keysToArray();
		var _loc1_ = Math.ffloor(Math.random() * _loc2_.length);
		mCurrentRandomLabel = ASCompat.dynamicAs(mRandomLabels.itemFor(_loc2_[Std.int(_loc1_)]), RandomLabelObject);
		mPlayHead = mCurrentRandomLabel.startFrameNumber;
	}

	override function determineFrames(clip:MovieClip) {
		var _loc2_:RandomLabelObject = null;
		var _loc3_ = 0;
		if (clip.currentLabels.length > 0) {
			_loc3_ = 1;
			while (_loc3_ <= clip.totalFrames) {
				clip.gotoAndStop(_loc3_);
				if (ASCompat.stringAsBool(clip.currentFrameLabel) && clip.currentFrameLabel.indexOf("random") >= 0) {
					if (_loc2_ != null && _loc2_.endFrameNumber == 0) {
						_loc2_.endFrameNumber = (ASCompat.toInt(_loc3_ - 1) : UInt);
					}
					_loc2_ = new RandomLabelObject();
					_loc2_.startFrameNumber = (_loc3_ : UInt);
					_loc2_.labelName = clip.currentFrameLabel;
					mRandomLabels.add(clip.currentFrameLabel, _loc2_);
				}
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			if (_loc2_ != null && _loc2_.endFrameNumber == 0) {
				_loc2_.endFrameNumber = (ASCompat.toInt(_loc3_ - 1) : UInt);
			}
		}
		playNewRandomLabel();
	}
}

private class RandomLabelObject {
	public var labelName:String;

	public var startFrameNumber:UInt = 0;

	public var endFrameNumber:UInt = 0;

	public function new() {}
}
