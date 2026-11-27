package brain.camera;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.Sprite;
import flash.geom.Vector3D;

class BackgroundFader {
	public static inline final TYPE = "fadebackground";

	var mFacade:Facade;

	var mExcludes:Array<ASAny>;

	var mRequests:ASObject = {};

	var mNextFadeId:UInt = (1 : UInt);

	var mRectSprite:Sprite;

	var mActive:Bool = false;

	var mCurrentAlpha:Float = 0;

	var mDuration:UInt = 0;

	var mTransitionDuration:Float = Math.NaN;

	var mColor:Vector3D;

	var mOffset:Float = Math.NaN;

	var mAlpha:Float = Math.NaN;

	var mWorkComponent:LogicalWorkComponent;

	var mFadeTask:Task;

	var mFramesElapsed:UInt = 0;

	var mStartTop:Float = Math.NaN;

	var mStartLeft:Float = Math.NaN;

	static inline final mPadding:Float = 1300;

	public function new(facade:Facade) {
		mFramesElapsed = (0 : UInt);
		mFacade = facade;
		mWorkComponent = new LogicalWorkComponent(facade, "BackgroundFader");
		MemoryTracker.track(mWorkComponent, "LogicalWorkComponent - created in BackgroundFader()", "brain");
	}

	public function doFade(excludes:Array<ASAny>, duration:UInt, transitionDur:Float, color:Vector3D, alpha:Float):UInt {
		var _loc7_:Sprite;
		var _loc8_ = 0;
		var _loc6_ = mNextFadeId++;
		mRequests[Std.string(_loc6_)] = excludes;
		if (!mActive) {
			mDuration = duration;
			mTransitionDuration = transitionDur;
			mColor = new Vector3D(color.x, color.y, color.z);
			mAlpha = alpha;
			mOffset = alpha / transitionDur;
			mExcludes = excludes.copy();
			execute();
		} else {
			_loc8_ = (mDuration - mFramesElapsed : Int);
			mDuration = (_loc8_ : UInt) > duration ? (_loc8_ : UInt) : duration;
			mTransitionDuration = transitionDur;
			mFramesElapsed = (0 : UInt);
			mAlpha = mAlpha > alpha ? mAlpha : alpha;
			mOffset = mAlpha / mTransitionDuration;
			if (checkNullIteratee(excludes))
				for (_tmp_ in excludes) {
					_loc7_ = ASCompat.coerce(_tmp_, flash.display.Sprite);
					if (mExcludes.indexOf(_loc7_) < 0) {
						mExcludes.push(_loc7_);
						mFacade.sceneGraphManager.addChild(_loc7_, 46);
					}
				}
		}
		return _loc6_;
	}

	public function cancelFade(requestId:UInt) {
		if (!mActive || mRequests[Std.string(requestId)] == null) {
			return;
		}
		var _loc2_:Sprite;
		final __ax4_iter_301:ASAny = mRequests[Std.string(requestId)];
		if (checkNullIteratee(__ax4_iter_301))
			for (_tmp_ in __ax4_iter_301) {
				_loc2_ = ASCompat.coerce(_tmp_, flash.display.Sprite);
				if (!excludedByOther(_loc2_, requestId)) {
					mExcludes.splice(mExcludes.indexOf(_loc2_), (1 : UInt));
					if (_loc2_.parent != null) {
						mFacade.sceneGraphManager.addChild(_loc2_, 20);
					}
				}
			}
		ASCompat.deleteProperty(mRequests, Std.string(requestId));
		if (mExcludes.length == 0) {
			ResetFade();
		}
	}

	function excludedByOther(sprite:Sprite, skipId:UInt):Bool {
		var _loc3_:Array<ASAny>;
		final __ax4_iter_302:ASObject = mRequests;
		if (checkNullIteratee(__ax4_iter_302))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_302)) {
				_loc3_ = ASCompat.coerce(_tmp_, Array);
				if (_loc3_ != mRequests[Std.string(skipId)] && _loc3_.indexOf(sprite) >= 0) {
					return true;
				}
			}
		return false;
	}

	function execute() {
		if (mFramesElapsed != 0) {
			ResetFade();
		}
		mFramesElapsed = (0 : UInt);
		mActive = true;
		mCurrentAlpha = 0;
		if (mFacade.starlingLayerManager == null) {
			mRectSprite = new Sprite();
			MemoryTracker.track(mRectSprite, "Sprite - fade rect created in BackgroundFader.execute()", "brain");
			mRectSprite.graphics.beginFill((ASCompat.floatToInt(mColor.x) << 16 | ASCompat.floatToInt(mColor.y) << 8 | ASCompat.floatToInt(mColor.z):UInt), 1);
			mStartTop = mFacade.camera.visibleRectangle.top - 1300 * 0.5;
			mStartLeft = mFacade.camera.visibleRectangle.left - 1300 * 0.5;
			mRectSprite.graphics.drawRect(mStartLeft, mStartTop, mFacade.stageRef.fullScreenWidth + 1300, mFacade.stageRef.fullScreenHeight + 1300);
			mRectSprite.graphics.endFill();
			mRectSprite.cacheAsBitmap = true;
			mRectSprite.alpha = 0;
			mFacade.sceneGraphManager.addChild(mRectSprite, 42);
		}
		var _loc1_:Sprite;
		final __ax4_iter_303 = mExcludes;
		if (checkNullIteratee(__ax4_iter_303))
			for (_tmp_ in __ax4_iter_303) {
				_loc1_ = ASCompat.coerce(_tmp_, flash.display.Sprite);
				mFacade.sceneGraphManager.addChild(_loc1_, 46);
			}
		mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
	}

	public function UpdateBackgroundFade(clock:GameClock) {
		if (!mActive) {
			Logger.error("BackgroundFader inactive");
			return;
		}
		if (mRectSprite != null) {
			mRectSprite.x = mFacade.camera.visibleRectangle.left - mStartLeft - 1300 * 0.5;
			mRectSprite.y = mFacade.camera.visibleRectangle.top - mStartTop - 1300 * 0.5;
		}
		mFramesElapsed = mFramesElapsed + 1;
		if (mFramesElapsed <= mTransitionDuration) {
			mCurrentAlpha += mOffset;
			mCurrentAlpha = Math.min(mCurrentAlpha, mAlpha);
		} else if (mFramesElapsed >= mDuration - mTransitionDuration) {
			mCurrentAlpha -= mOffset;
			mCurrentAlpha = Math.max(mCurrentAlpha, 0);
		}
		if (mRectSprite != null) {
			mRectSprite.alpha = mCurrentAlpha;
		}
		if (mFramesElapsed > mDuration) {
			ResetFade();
			return;
		}
	}

	function ResetFade() {
		mFramesElapsed = (0 : UInt);
		mActive = false;
		mCurrentAlpha = 0;
		if (mRectSprite != null) {
			mFacade.sceneGraphManager.removeChild(mRectSprite);
			mRectSprite = null;
		}
		var _loc1_:Sprite;
		final __ax4_iter_304 = mExcludes;
		if (checkNullIteratee(__ax4_iter_304))
			for (_tmp_ in __ax4_iter_304) {
				_loc1_ = ASCompat.coerce(_tmp_, flash.display.Sprite);
				if (_loc1_.parent != null) {
					mFacade.sceneGraphManager.addChild(_loc1_, 20);
				}
			}
		mExcludes = null;
		mRectSprite = null;
		mRequests = {};
		mFadeTask.destroy();
		mFadeTask = null;
	}

	@:isVar public var color(get, never):UInt;

	public function get_color():UInt {
		return
			(mColor != null ? (ASCompat.floatToInt(mColor.x) << 16 | ASCompat.floatToInt(mColor.y) << 8 | ASCompat.floatToInt(mColor.z):UInt) : (0 : UInt) : UInt);
	}

	@:isVar public var alpha(get, never):Float;

	public function get_alpha():Float {
		return mActive ? mCurrentAlpha : 0;
	}

	public function forceStop() {
		if (mFadeTask != null && mActive) {
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
