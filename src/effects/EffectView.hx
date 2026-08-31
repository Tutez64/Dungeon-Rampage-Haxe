package effects;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import facade.DBFacade;
import dr_floor.FloorView;
import flash.display.MovieClip;

class EffectView extends FloorView {
	var mAssetLoadingComponent:AssetLoadingComponent;

	var mEffect:MovieClip;

	var mEffectClassName:String;

	var mLoop:Bool = false;

	var mShouldBePlaying:ShouldBePlaying;

	var mAssetLoadedCallback:ASFunction;

	public function new(facade:DBFacade, effectGameObject:EffectGameObject, assetLoadedCallback:ASFunction = null) {
		super(facade, effectGameObject);
		mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
		mEffectClassName = effectGameObject.className;
		mAssetLoadedCallback = assetLoadedCallback;
		mAssetLoadingComponent.getSwfAsset(effectGameObject.swfPath, assetLoaded);
	}

	public function setPlayRate(val:Float) {
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.playRate = val;
		}
	}

	public function play(loop:Bool, finishedCallback:ASFunction) {
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.play((0 : UInt), loop, finishedCallback);
		} else {
			mShouldBePlaying = new ShouldBePlaying(loop, finishedCallback);
		}
	}

	public function stop() {
		mShouldBePlaying = null;
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.stop();
			mMovieClipRenderer.finishedCallback = null;
		}
		this.removeFromStage();
		if (mRoot.parent != null) {
			mRoot.parent.removeChild(mRoot);
		}
	}

	function assetLoaded(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass(mEffectClassName);
		if (_loc2_ == null) {
			Logger.error("Unable to find class: " + mEffectClassName);
			return;
		}
		mEffect = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
		mMovieClipRenderer = new MovieClipRenderController(mFacade, mEffect);
		if (mShouldBePlaying != null) {
			mMovieClipRenderer.play((0 : UInt), mShouldBePlaying.loop, mShouldBePlaying.finishedCallback);
		}
		mRoot.mouseChildren = false;
		mRoot.mouseEnabled = false;
		mRoot.addChild(mEffect);
		if (mAssetLoadedCallback != null) {
			mAssetLoadedCallback(mEffect);
		}
	}

	override public function destroy() {
		mEffect = null;
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		super.destroy();
	}
}

private class ShouldBePlaying {
	public var loop:Bool = false;

	public var finishedCallback:ASFunction;

	public function new(l:Bool, f:ASFunction) {
		loop = l;
		finishedCallback = f;
	}
}
