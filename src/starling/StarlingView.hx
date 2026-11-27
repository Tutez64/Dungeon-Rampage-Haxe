package starling;

import brain.facade.Facade;
import brain.starling.StarlingScenerySprite;
import brain.utils.MemoryTracker;
import starling.display.Image;
import starling.extensions.animate.Animation;

class StarlingView extends StarlingScenerySprite {
	static inline final FALLBACK_STAGE_REACH:Float = 1360;

	var mFacade:Facade;

	var mImage:Image;

	var mAnimation:Animation;

	var mImageKey:String;

	public function new(inFacade:Facade, inCacheKey:String) {
		super();
		mFacade = inFacade;
		mImageKey = inCacheKey;
		touchable = false;
		name = "StarlingView_" + inCacheKey;
		MemoryTracker.track(this, "StarlingView - view: " + inCacheKey, "starling");
	}

	@:isVar public var image(never, set):Image;

	public function set_image(inImage:Image):Image {
		if (mImage != null) {
			removeChild(mImage);
			mImage.dispose();
		}
		mImage = inImage;
		MemoryTracker.track(mImage, "StarlingView - Image: " + mImageKey, "starling");
		addChild(mImage);
		mImage.touchable = false;
		return inImage;
	}

	@:isVar public var animation(never, set):Animation;

	public function set_animation(inAnimation:Animation):Animation {
		if (mAnimation != null) {
			mFacade.starlingLayerManager.juggler.remove(mAnimation);
			removeChild(mAnimation);
			mAnimation.dispose();
		}
		mAnimation = inAnimation;
		mAnimation.play();
		mFacade.starlingLayerManager.juggler.add(mAnimation);
		addChild(mAnimation);
		return inAnimation;
	}

	override function get_cullReach():Float {
		if (mAnimation == null) {
			return 0;
		}
		var _loc1_ = mAnimation.sourceWidth + mAnimation.sourceHeight;
		return _loc1_ > 0 ? _loc1_ : 1360;
	}

	public function addToStage() {
		if (mImage != null && mAnimation == null) {
			mImage.visible = true;
		} else if (mAnimation != null) {
			mAnimation.visible = true;
			mFacade.starlingLayerManager.juggler.add(mAnimation);
		}
	}

	public function removeFromStage() {
		if (mImage != null && mAnimation == null) {
			mImage.visible = false;
		} else if (mAnimation != null) {
			mAnimation.visible = false;
			mFacade.starlingLayerManager.juggler.remove(mAnimation);
		}
	}

	override public function dispose() {
		if (mImage != null) {
			mImage.removeFromParent(true);
		}
		if (mAnimation != null) {
			mFacade.starlingLayerManager.juggler.remove(mAnimation);
			mAnimation.removeFromParent(true);
		}
		if (mFacade.starlingLayerManager != null && mImageKey != null) {
			mFacade.starlingLayerManager.sourceCache.releaseRef(mImageKey);
		}
		mImage = null;
		mImageKey = null;
		super.dispose();
	}
}
