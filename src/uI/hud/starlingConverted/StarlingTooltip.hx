package uI.hud.starlingConverted;

import brain.clock.GameClock;
import brain.workLoop.DoLater;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.geom.Point;
import starling.display.DisplayObject;

class StarlingTooltip {
	var mFacade:DBFacade;

	var mOwner:DisplayObject;

	var mSpace:DisplayObject;

	var mClip:MovieClip;

	var mOffset:Point;

	var mDelay:Float = Math.NaN;

	var mTask:DoLater;

	var mMatrix:Matrix = new Matrix();

	var mHovered:Bool = false;

	var mStagePosition:Bool = false;

	var mOriginalX:Float = Math.NaN;

	var mOriginalY:Float = Math.NaN;

	public function new(facade:DBFacade, owner:DisplayObject, space:DisplayObject, clip:MovieClip, delay:Float = 0, offset:Point = null,
			stagePosition:Bool = false) {
		mFacade = facade;
		mOwner = owner;
		mSpace = space;
		mClip = clip;
		mOriginalX = clip.x;
		mOriginalY = clip.y;
		mDelay = delay;
		mStagePosition = stagePosition;
		mOffset = offset ?? new Point(clip.x, clip.y);
		clip.mouseEnabled = clip.mouseChildren = false;
		if (clip.parent != null) {
			clip.parent.removeChild(clip);
		}
	}

	public function rollOver() {
		hide();
		mHovered = true;
		if (mDelay == 0) {
			show();
		} else {
			mTask = mFacade.preRenderWorkManager.doLater(mDelay, show, false, "StarlingTooltip");
		}
	}

	function show(clock:GameClock = null) {
		try {
			mTask = null;
			if (!mHovered || mClip == null) {
				return;
			}
			mOwner.getTransformationMatrix(mSpace, mMatrix);
			mClip.x = mMatrix.a * mOffset.x + mMatrix.c * mOffset.y + mMatrix.tx;
			mClip.y = mMatrix.b * mOffset.x + mMatrix.d * mOffset.y + mMatrix.ty;
			mFacade.sceneGraphManager.addChild(mClip, 107);
			if (mStagePosition) {
				mClip.x = mOffset.x;
				mClip.y = mOffset.y;
			}
			mClip.visible = true;
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	public function hide() {
		mHovered = false;
		if (mTask != null) {
			mTask.destroy();
		}
		mTask = null;
		if (mClip != null && mClip.parent != null) {
			mClip.parent.removeChild(mClip);
		}
	}

	public function dispose() {
		hide();
		if (mClip != null) {
			mClip.x = mOriginalX;
			mClip.y = mOriginalY;
		}
		mClip = null;
		mOwner = mSpace = null;
		mFacade = null;
	}
}
