package doobers;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import starling.display.Sprite;
import starling.extensions.animate.Animation;

class StarlingDooberRenderer {
	var mDBFacade:DBFacade;

	var mContainer:Sprite;

	var mContent:Sprite;

	var mLayerIndex:Int = 0;

	var mAnimation:Animation;

	var mLabel:String;

	var mVisible:Bool = true;

	public function new(dbFacade:DBFacade, holderName:String, layerIndex:Int, animation:Animation, label:String) {
		mDBFacade = dbFacade;
		mLayerIndex = layerIndex;
		mAnimation = animation;
		mLabel = label;
		mAnimation.touchable = false;
		mAnimation.stop();
		mContainer = new Sprite();
		mContainer.touchable = false;
		mContainer.name = "StarlingDooberRenderer_" + holderName;
		mContent = new Sprite();
		mContent.touchable = false;
		mContainer.addChild(mContent);
		mContent.addChild(mAnimation);
		MemoryTracker.track(mContainer, "StarlingDooberRenderer - holder: " + holderName, "starling");
		setLayer(layerIndex);
	}

	public function play() {
		if (mAnimation == null) {
			return;
		}
		if (mLabel != null) {
			mAnimation.gotoLabel(mLabel, true);
		} else {
			mAnimation.loop = true;
			mAnimation.currentFrame = 0;
			mAnimation.play();
		}
		joinJuggler();
	}

	public function rewindAndStop() {
		if (mAnimation == null) {
			return;
		}
		leaveJuggler();
		var _loc1_ = mLabel != null ? mAnimation.getFrame(mLabel) : 0;
		mAnimation.currentFrame = _loc1_ >= 0 ? _loc1_ : 0;
		mAnimation.pause();
	}

	@:isVar public var visible(get, set):Bool;

	public function get_visible():Bool {
		return mVisible;
	}

	function set_visible(value:Bool):Bool {
		if (mVisible == value) {
			return value;
		}
		mVisible = value;
		mContainer.visible = value;
		if (value) {
			joinJuggler();
		} else {
			leaveJuggler();
		}
		return value;
	}

	public function setLayer(layerIndex:Int) {
		if (mContainer == null || mDBFacade == null) {
			return;
		}
		if (mLayerIndex == layerIndex && (layerIndex == 0 || mContainer.parent != null)) {
			return;
		}
		if (mContainer.parent != null) {
			mContainer.removeFromParent();
		}
		if (layerIndex == 0) {
			mLayerIndex = 0;
			return;
		}
		mLayerIndex = layerIndex;
		var _loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		if (_loc2_ == null) {
			Logger.warn("StarlingDooberRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
			mLayerIndex = 20;
			_loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		}
		if (_loc2_ != null) {
			_loc2_.addChild(mContainer);
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setTransform(x:Float, y:Float, scaleX:Float, scaleY:Float, alpha:Float = 1, sortX:Float = null, sortY:Float = null) {
		if (sortX == null)
			sortX = Math.NaN;
		if (sortY == null)
			sortY = Math.NaN;
		if (Math.isNaN(sortX)) {
			sortX = x;
		}
		if (Math.isNaN(sortY)) {
			sortY = y;
		}
		mContainer.x = sortX;
		mContainer.y = sortY;
		mContainer.alpha = alpha;
		mContent.x = x - sortX;
		mContent.y = y - sortY;
		mContent.scaleX = scaleX;
		mContent.scaleY = scaleY;
		mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
	}

	public function destroy() {
		leaveJuggler();
		if (mAnimation != null) {
			mAnimation.stop();
			mAnimation.removeFromParent(true);
			mAnimation = null;
		}
		if (mContent != null) {
			mContent.removeFromParent(true);
			mContent = null;
		}
		if (mContainer != null) {
			mContainer.removeFromParent(true);
			mContainer = null;
		}
		mDBFacade = null;
	}

	function joinJuggler() {
		if (mAnimation == null || !mVisible || !mAnimation.isPlaying) {
			return;
		}
		if (!mDBFacade.starlingLayerManager.juggler.contains(mAnimation)) {
			mDBFacade.starlingLayerManager.juggler.add(mAnimation);
		}
	}

	function leaveJuggler() {
		if (mAnimation == null || mDBFacade == null) {
			return;
		}
		mDBFacade.starlingLayerManager.juggler.remove(mAnimation);
	}
}
