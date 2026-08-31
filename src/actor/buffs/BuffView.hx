package actor.buffs;

import actor.ActorView;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import dr_floor.FloorView;
import com.greensock.TweenMax;
import flash.display.MovieClip;

class BuffView extends FloorView {
	var mAssetLoadingComponent:AssetLoadingComponent;

	var mBuff:MovieClip;

	var mParentGameObject:BuffGameObject;

	var mParentView:ActorView;

	var mTintColor:Float = Math.NaN;

	var mTintAmount:Float = Math.NaN;

	var mTween:TweenMax;

	var mSortLayer:String;

	var mNewScale:Float = Math.NaN;

	var mOriginalScale:Float = Math.NaN;

	var mScaleUpStartDelayTime:Float = Math.NaN;

	var mScaleUpIncrementTime:Float = Math.NaN;

	var mScaleUpIncrementScale:Float = Math.NaN;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mHideTween:TweenMax;

	var mShowTween:TweenMax;

	public function new(facade:DBFacade, buffGameObject:BuffGameObject, parentView:ActorView, tintColor:Float, tintAmount:Float, scale:Float,
			scaleStartDelayTime:Float, scaleIncrementTime:Float, scaleIncrementScale:Float) {
		mParentView = parentView;
		mParentGameObject = buffGameObject;
		mTintColor = tintColor;
		mTintAmount = tintAmount;
		mSortLayer = buffGameObject.mSortLayer;
		mNewScale = scale;
		mScaleUpStartDelayTime = scaleStartDelayTime;
		mScaleUpIncrementTime = scaleIncrementTime;
		mScaleUpIncrementScale = scaleIncrementScale;
		mLogicalWorkComponent = new LogicalWorkComponent(facade, "BuffView");
		super(facade, buffGameObject);
		if (ASCompat.stringAsBool(buffGameObject.className)) {
			mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
			mAssetLoadingComponent.getSwfAsset(buffGameObject.swfPath, assetLoaded);
		} else {
			checkForScaling();
		}
	}

	function assetLoaded(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass(mParentGameObject.className);
		if (mFacade == null) {
			return;
		}
		if (_loc2_ != null) {
			mBuff = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
			mMovieClipRenderer = new MovieClipRenderController(mFacade, mBuff, finishedCallback);
			mMovieClipRenderer.play((0 : UInt), true);
			mParentView.buildBuff(mBuff, mSortLayer);
			if (mTintColor != -1) {
				mTween = TweenMax.fromTo(mParentView.body, mMovieClipRenderer.durationInSeconds * 0.5, {"colorMatrixFilter": {}}, {
					"repeat": -1,
					"yoyo": true,
					"colorMatrixFilter": {
						"colorize": mTintColor,
						"amount": mTintAmount
					}
				});
			}
			checkForScaling();
		} else {
			Logger.warn(mParentGameObject.className + " doesn\'t exist !");
		}
	}

	function checkForScaling() {
		if (ASCompat.floatAsBool(mNewScale)) {
			mOriginalScale = mParentView.root.scaleX;
			if (mScaleUpIncrementScale == 0 || mScaleUpIncrementTime == 0) {
				mParentView.root.scaleX = mParentView.root.scaleY = mNewScale;
			} else {
				mLogicalWorkComponent.doLater(mScaleUpStartDelayTime, delayStartScaling);
			}
		}
	}

	function delayStartScaling(gameClock:GameClock) {
		mLogicalWorkComponent.doEverySeconds(mScaleUpIncrementTime, scaleUpCall);
	}

	function scaleUpCall(gameClock:GameClock) {
		if (mParentView.root.scaleX <= mNewScale - mScaleUpIncrementScale) {
			mParentView.root.scaleX += mScaleUpIncrementScale;
			mParentView.root.scaleY += mScaleUpIncrementScale;
			TweenMax.to(mParentView.body, mScaleUpIncrementTime / 2, {
				"tint": mTintColor,
				"onCompleteListener": function() {
					TweenMax.to(mParentView.body, 0, {"removeTint": true});
				}
			});
		} else {
			mParentView.root.scaleX = mParentView.root.scaleY = mNewScale;
			mLogicalWorkComponent.clear();
		}
	}

	public function showInHUD() {
		mDBFacade.hud.showBuffDisplay(mParentGameObject);
	}

	override public function destroy() {
		if (mFacade == null) {
			return;
		}
		if (ASCompat.floatAsBool(mNewScale)) {
			TweenMax.to(mParentView.root, 0.3, {
				"scaleX": mOriginalScale,
				"scaleY": mOriginalScale
			});
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.destroy();
			mMovieClipRenderer = null;
		}
		if (mTween != null) {
			mTween.complete();
			mTween.kill();
			mTween = null;
		}
		if (mHideTween != null) {
			mHideTween.complete();
			mHideTween.kill();
			mHideTween = null;
		}
		if (mShowTween != null) {
			mShowTween.complete();
			mShowTween.kill();
			mShowTween = null;
		}
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
		if (mParentView != null) {
			mParentView.destroyBuff(mBuff);
		}
		super.destroy();
	}

	public function finishedCallback() {}

	public function hide(transitionTime:Float) {
		if (mBuff != null) {
			mHideTween = TweenMax.to(mBuff, transitionTime, {
				"alpha": 0,
				"onCompleteListener": function() {
					mBuff.visible = false;
					mBuff.alpha = 1;
				}
			});
		}
	}

	public function show(transitionTime:Float) {
		mBuff.alpha = 0;
		mBuff.visible = true;
		mShowTween = TweenMax.to(mBuff, transitionTime, {"alpha": 1});
	}
}
