package brain.render;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.sound.SoundComponent;
import brain.uI.UIButton;
import flash.display.MovieClip;
import flash.geom.Vector3D;

class MovieClipCutsceneRenderer extends MovieClipRenderer {
	static inline final PAUSE_LABEL = "pause";

	var mPauseFrames:Vector<UInt> = new Vector();

	var mNextPauseFrame:UInt = 0;

	var mNextButton:UIButton;

	var mSkipButton:UIButton;

	var mSoundFrames:Vector<UInt> = new Vector();

	var mSoundClasses:Vector<String> = new Vector();

	var mSoundComponent:SoundComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mFacade:Facade;

	public function new(facade:Facade, clip:MovieClip, finishedCallback:ASFunction = null, assetLabel:String = null) {
		mAssetLoadingComponent = new AssetLoadingComponent(facade);
		mSoundComponent = new SoundComponent(facade);
		super(facade, clip, finishedCallback, assetLabel);
		mFacade = facade;
		mFacade.camera.doLetterboxEffect((10000 : UInt), 120, new Vector3D(0, 0, 0), 1);
		createButtons();
	}

	function createButtons() {
		mAssetLoadingComponent.getSwfAsset(mClip.loaderInfo.url, buttonsSwfLoaded);
	}

	function buttonsSwfLoaded(swfAsset:SwfAsset) {
		var _loc3_ = swfAsset.getClass("next_button");
		var _loc2_ = swfAsset.getClass("skip_button");
		mNextButton = new UIButton(mFacade, ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip));
		mSkipButton = new UIButton(mFacade, ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip));
		mFacade.sceneGraphManager.addChild(mNextButton.root, 105);
		mFacade.sceneGraphManager.addChild(mSkipButton.root, 105);
		mSkipButton.root.x = mFacade.viewWidth - (mSkipButton.root.width / 2 + 10);
		mSkipButton.root.y = mFacade.viewHeight - (mSkipButton.root.height / 2 + 10);
		mNextButton.root.x = mFacade.viewWidth - (mNextButton.root.width / 2 + 10);
		mNextButton.root.y = mFacade.viewHeight - (mSkipButton.root.height + 10) - (mNextButton.root.height / 2 + 4);
		mNextButton.releaseCallback = onNext;
		mSkipButton.releaseCallback = onSkip;
	}

	override public function destroy() {
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		if (mSoundComponent != null) {
			mSoundComponent.destroy();
			mSoundComponent = null;
		}
		super.destroy();
		if (mNextButton != null) {
			mFacade.sceneGraphManager.removeChild(mNextButton.root);
			mNextButton.destroy();
			mNextButton = null;
		}
		if (mSkipButton != null) {
			mFacade.sceneGraphManager.removeChild(mSkipButton.root);
			mSkipButton.destroy();
			mSkipButton = null;
		}
	}

	function onNext() {
		clip.gotoAndStop(mNextPauseFrame);
		play();
		if (mPauseFrames.length != 0) {
			mNextPauseFrame = mPauseFrames.shift();
		} else {
			mNextPauseFrame = (clip.totalFrames - 1:UInt);
			mNextButton.destroy();
			mNextButton = null;
		}
	}

	function onSkip() {
		clip.gotoAndStop(mNextPauseFrame);
		if (mFinishedCallback != null) {
			mFinishedCallback();
		}
		mFacade.camera.killLetterboxEffect();
	}

	override public function onFrame(gameClock:GameClock) {
		if (mClip == null) {
			return;
		}
		if (mClip.stage == null) {
			Logger.warn("Animating MovieClipRenderer that is not on stage");
		}
		if (!mIsPlaying) {
			return;
		}
		mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
		if (mPlayHead > mNextPauseFrame) {
			mIsPlaying = false;
			mPlayHead = mNextPauseFrame;
			this.updateClip(mClip);
			if (mOnFrameTask != null) {
				mOnFrameTask.destroy();
				mOnFrameTask = null;
			}
			if (mNextPauseFrame == (clip.totalFrames - 1:UInt)) {
				mFacade.camera.killLetterboxEffect();
				if (mFinishedCallback != null) {
					mFinishedCallback();
				}
			}
			return;
		}
		this.updateClip(mClip);
	}

	override function determineFrames(clip:MovieClip) {
		var _loc3_ = Math.NaN;
		var _loc4_ = 0;
		var _loc2_:String = null;
		if (clip.currentLabels != null) {
			_loc3_ = clip.soundTransform.volume;
			_loc4_ = 1;
			while (_loc4_ <= clip.totalFrames) {
				clip.gotoAndStop(_loc4_);
				clip.soundTransform.volume = 0;
				if (clip.currentFrameLabel == "pause") {
					mPauseFrames.push((_loc4_ : UInt));
				} else if (ASCompat.stringAsBool(clip.currentFrameLabel) && clip.currentFrameLabel.indexOf("play ") == 0) {
					mSoundFrames.push((_loc4_ : UInt));
					_loc2_ = clip.currentFrameLabel.substring(5);
					trace("Found sound: " + _loc2_ + " at frame: " + Std.string(_loc4_));
					mSoundClasses.push(_loc2_);
				}
				_loc4_ = ASCompat.toInt(_loc4_) + 1;
			}
		}
		mNextPauseFrame = (ASCompat.toInt(mPauseFrames.length != 0 ? mPauseFrames.shift() : (0 : UInt)) : UInt);
	}
}
