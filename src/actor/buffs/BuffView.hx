package actor.buffs;

import actor.ActorView;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.render.tweens.TweenHandle;
import brain.workLoop.LogicalWorkComponent;
import distributedObjects.DistributedDungeonFloor;
import effects.EffectManager;
import effects.EffectView;
import facade.DBFacade;
import dr_floor.FloorView;
import flash.display.DisplayObject;
import flash.display.MovieClip;

class BuffView extends FloorView {
	var mAssetLoadingComponent:AssetLoadingComponent;

	var mBuff:MovieClip;

	var mParentGameObject:BuffGameObject;

	var mParentView:ActorView;

	var mTintColor:Float = Math.NaN;

	var mTintAmount:Float = Math.NaN;

	var mTween:TweenHandle;

	var mStarlingTintTween:TweenHandle;

	var mStarlingTintProxy:ASObject;

	var mSortLayer:String;

	var mNewScale:Float = Math.NaN;

	var mOriginalScale:Float = Math.NaN;

	var mScaleUpStartDelayTime:Float = Math.NaN;

	var mScaleUpIncrementTime:Float = Math.NaN;

	var mScaleUpIncrementScale:Float = Math.NaN;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mHideTween:TweenHandle;

	var mShowTween:TweenHandle;

	var mEffectManager:EffectManager;

	var mManagedEffectId:UInt = 0;

	var mEffectView:EffectView;

	var mTintStarted:Bool = false;

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
			if (!startManagedBuffEffect()) {
				mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
				mAssetLoadingComponent.getSwfAsset(buffGameObject.swfPath, assetLoaded);
			}
		} else {
			checkForScaling();
		}
	}

	function startManagedBuffEffect():Bool {
		var _loc2_ = mParentGameObject.actorGameObject;
		var _loc3_ = ASCompat.coerce(_loc2_ != null ? _loc2_.distributedDungeonFloor : null, distributedObjects.DistributedDungeonFloor);
		var _loc1_ = ASCompat.coerce(_loc3_ != null ? _loc3_.effectManager : null, effects.EffectManager);
		if (_loc1_ == null) {
			return false;
		}
		mEffectManager = _loc1_;
		mManagedEffectId = _loc1_.playEffect(mParentGameObject.swfPath, mParentGameObject.className, mParentGameObject.position, _loc2_,
			mSortLayer != "foreground", 1, 0, 0, 0, 0, true, "sorted", true, 1, null, null, "BUFF");
		mEffectView = _loc1_.managedEffectView(mManagedEffectId);
		if (mEffectView != null) {
			mEffectView.artResolvedCallback = onBuffArtResolved;
			if (mEffectView.isArtLoaded) {
				onBuffArtResolved();
			}
		}
		checkForScaling();
		return true;
	}

	function onBuffArtResolved() {
		if (mDBFacade == null || mTintStarted || mTintColor == -1) {
			return;
		}
		mTintStarted = true;
		var _loc1_ = mEffectView.artDurationInSeconds * 0.5;
		startTintTweens(_loc1_);
	}

	function startTintTweens(halfDuration:Float) {
		mTween = mDBFacade.mTween.tweenFromTo(mParentView.body, halfDuration, {"colorMatrixFilter": {}}, {
			"repeat": -1,
			"yoyo": true,
			"colorMatrixFilter": {
				"colorize": mTintColor,
				"amount": mTintAmount
			}
		});
		mStarlingTintProxy = {"amount": 0};
		var tintColor = (ASCompat.floatToInt(mTintColor) : UInt);
		var parentView = mParentView;
		var proxy:ASObject = mStarlingTintProxy;
		mStarlingTintTween = mDBFacade.mTween.tweenFromTo(mStarlingTintProxy, halfDuration, {"amount": 0}, {
			"repeat": -1,
			"yoyo": true,
			"amount": mTintAmount,
			"onUpdate": function() {
				parentView.applyStatusTint(tintColor, ASCompat.toNumberField(proxy, "amount"));
			}
		});
	}

	function assetLoaded(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass(mParentGameObject.className);
		if (mDBFacade == null) {
			return;
		}
		if (_loc2_ != null) {
			mBuff = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
			mMovieClipRenderer = new MovieClipRenderController(mDBFacade, mBuff, finishedCallback);
			mMovieClipRenderer.play((0 : UInt), true);
			mParentView.buildBuff(mBuff, mSortLayer);
			if (mTintColor != -1) {
				mTintStarted = true;
				startTintTweens(mMovieClipRenderer.durationInSeconds * 0.5);
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
			mDBFacade.mTween.tweenMaxTo(mParentView.body, mScaleUpIncrementTime / 2, {
				"tint": mTintColor,
				"onCompleteListener": function() {
					mDBFacade.mTween.tweenMaxTo(mParentView.body, 0, {"removeTint": true});
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
		if (mDBFacade == null) {
			return;
		}
		if (ASCompat.floatAsBool(mNewScale)) {
			mDBFacade.mTween.tweenMaxTo(mParentView.root, 0.3, {
				"scaleX": mOriginalScale,
				"scaleY": mOriginalScale
			});
		}
		if (mEffectView != null) {
			mEffectView.artResolvedCallback = null;
			mEffectView = null;
		}
		if (mEffectManager != null) {
			mEffectManager.endManagedEffect(mManagedEffectId);
			mEffectManager = null;
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
			mDBFacade.mTween.completeTween(mTween);
			mDBFacade.mTween.killTween(mTween);
			mTween = null;
		}
		if (mStarlingTintTween != null) {
			mDBFacade.mTween.completeTween(mStarlingTintTween);
			mDBFacade.mTween.killTween(mStarlingTintTween);
			mStarlingTintTween = null;
			mStarlingTintProxy = null;
			if (mParentView != null) {
				mParentView.clearStatusTint();
			}
		}
		if (mHideTween != null) {
			mDBFacade.mTween.completeTween(mHideTween);
			mDBFacade.mTween.killTween(mHideTween);
			mHideTween = null;
		}
		if (mShowTween != null) {
			mDBFacade.mTween.completeTween(mShowTween);
			mDBFacade.mTween.killTween(mShowTween);
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

	@:isVar var fadeTarget(get, never):DisplayObject;

	function get_fadeTarget():DisplayObject {
		if (mBuff != null) {
			return mBuff;
		}
		return ASCompat.coerce(mEffectView != null ? mEffectView.root : null, flash.display.DisplayObject);
	}

	public function hide(transitionTime:Float) {
		var target:DisplayObject;
		if (mShowTween != null) {
			mDBFacade.mTween.killTween(mShowTween);
			mShowTween = null;
		}
		target = fadeTarget;
		if (target != null) {
			mHideTween = mDBFacade.mTween.tweenMaxTo(target, transitionTime, {
				"alpha": 0,
				"onCompleteListener": function() {
					target.visible = false;
					target.alpha = 1;
				}
			});
		}
	}

	public function show(transitionTime:Float) {
		if (mHideTween != null) {
			mDBFacade.mTween.killTween(mHideTween);
			mHideTween = null;
		}
		var _loc2_ = fadeTarget;
		if (_loc2_ == null) {
			return;
		}
		_loc2_.alpha = 0;
		_loc2_.visible = true;
		mShowTween = mDBFacade.mTween.tweenMaxTo(_loc2_, transitionTime, {"alpha": 1});
	}
}
