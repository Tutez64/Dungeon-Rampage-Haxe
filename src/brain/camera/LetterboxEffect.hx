package brain.camera;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.Sprite;
import flash.geom.Vector3D;

class LetterboxEffect {
	var mFacade:Facade;

	var mRectSprite:Sprite;

	var mDuration:Float = 0;

	var mTransitionDuration:Float = Math.NaN;

	var mColor:Vector3D;

	var mOffset:Float = Math.NaN;

	var mAlpha:Float = Math.NaN;

	var mWorkComponent:LogicalWorkComponent;

	var mFadeTask:Task;

	var mFramesElapsed:Float = 0;

	static inline final mPadding:Float = 512;

	public function new(facade:Facade) {
		mFramesElapsed = 0;
		mFacade = facade;
		mWorkComponent = new LogicalWorkComponent(facade, "LetterboxEffect");
		MemoryTracker.track(mWorkComponent, "LogicalWorkComponent - created in LetterboxEffect()", "brain");
	}

	public function doFade(duration:UInt, transitionDur:Float, color:Vector3D, alpha:Float) {
		var _loc5_:Float = 0;
		if (mRectSprite == null) {
			mDuration = duration;
			mTransitionDuration = transitionDur;
			mColor = new Vector3D(color.x, color.y, color.z);
			mAlpha = alpha;
			mOffset = alpha / transitionDur;
			execute();
		} else {
			_loc5_ = mDuration - mFramesElapsed;
			mDuration = Math.max(_loc5_, duration);
			mTransitionDuration = transitionDur;
			mFramesElapsed = 0;
			mAlpha = mAlpha > alpha ? mAlpha : alpha;
			mOffset = mAlpha / mTransitionDuration;
		}
	}

	function execute() {
		if (mFramesElapsed != 0) {
			ResetFade();
		}
		mFramesElapsed = 0;
		mRectSprite = new Sprite();
		MemoryTracker.track(mRectSprite, "Sprite - letterbox rect created in LetterboxEffect.execute()", "brain");
		mRectSprite.graphics.beginFill((Std.int(mColor.x) << 16 | Std.int(mColor.y) << 8 | Std.int(mColor.z):UInt), 1);
		mRectSprite.graphics.drawRect(0, 0, mFacade.stageRef.fullScreenWidth + 512, 75);
		mRectSprite.graphics.drawRect(0, mFacade.stageRef.fullScreenHeight - 550, mFacade.stageRef.fullScreenWidth + 512, 375);
		mRectSprite.graphics.endFill();
		mRectSprite.cacheAsBitmap = true;
		mRectSprite.alpha = 0;
		mFacade.sceneGraphManager.addChild(mRectSprite, 100);
		mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
	}

	public function UpdateBackgroundFade(clock:GameClock) {
		if (mRectSprite == null) {
			Logger.warn("LetterboxEffect with null RectSprite");
			return;
		}
		var _loc1_ = clock.tickLength / GameClock.ANIMATION_FRAME_DURATION;
		mFramesElapsed += _loc1_;
		if (mFramesElapsed <= mTransitionDuration) {
			mRectSprite.alpha += mOffset * _loc1_;
			mRectSprite.alpha = Math.min(mRectSprite.alpha, mAlpha);
		} else if (mFramesElapsed >= mDuration - mTransitionDuration) {
			mRectSprite.alpha -= mOffset * _loc1_;
			mRectSprite.alpha = Math.max(mRectSprite.alpha, 0);
		} else if (mFramesElapsed > mTransitionDuration) {
			mRectSprite.alpha = mAlpha;
		}
		if (mFramesElapsed > mDuration) {
			ResetFade();
			return;
		}
	}

	function ResetFade() {
		mFramesElapsed = 0;
		mFacade.sceneGraphManager.removeChild(mRectSprite);
		mRectSprite = null;
		mFadeTask.destroy();
		mFadeTask = null;
	}

	public function forceStop() {
		if (mFadeTask != null && mRectSprite != null) {
			ResetFade();
		}
	}

	public function destroy() {
		if (mFadeTask != null) {
			mFadeTask.destroy();
			mFadeTask = null;
		}
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
	}
}
