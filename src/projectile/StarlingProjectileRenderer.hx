package projectile;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import starling.display.Sprite;
import starling.extensions.animate.Animation;
import starling.filters.GlowFilter;

class StarlingProjectileRenderer {
	var mDBFacade:DBFacade;

	var mContainer:Sprite;

	var mLayerIndex:Int = 0;

	var mBodyAnimation:Animation;

	var mEffectAnimation:Animation;

	var mBodyLabel:String;

	var mEffectLabel:String;

	var mVisible:Bool = true;

	var mBodyColorMatrix:Vector<Float>;

	var mBodyGlowFilter:GlowFilter;

	var mEffectColorMatrix:Vector<Float>;

	var mEffectGlowFilter:GlowFilter;

	public function new(dbFacade:DBFacade, holderName:String, layerIndex:Int, bodyAnimation:Animation, bodyLabel:String, effectAnimation:Animation = null,
			effectLabel:String = null) {
		mDBFacade = dbFacade;
		mLayerIndex = layerIndex;
		mBodyAnimation = bodyAnimation;
		mBodyLabel = bodyLabel;
		mEffectAnimation = effectAnimation;
		mEffectLabel = effectLabel;
		mContainer = new Sprite();
		mContainer.touchable = false;
		mContainer.name = "StarlingProjectileRenderer_" + holderName;
		if (mEffectAnimation != null) {
			mEffectAnimation.touchable = false;
			mEffectAnimation.stop();
			mContainer.addChild(mEffectAnimation);
		}
		if (mBodyAnimation != null) {
			mBodyAnimation.touchable = false;
			mBodyAnimation.stop();
			mContainer.addChild(mBodyAnimation);
		}
		MemoryTracker.track(mContainer, "StarlingProjectileRenderer - holder: " + holderName, "starling");
		setLayer(layerIndex);
	}

	public function attachEffect(effectAnimation:Animation, effectLabel:String):Bool {
		if (mContainer == null || mEffectAnimation != null) {
			return false;
		}
		mEffectAnimation = effectAnimation;
		mEffectLabel = effectLabel;
		mEffectAnimation.touchable = false;
		mEffectAnimation.stop();
		mEffectAnimation.setColorMatrix(mEffectColorMatrix);
		mContainer.addChildAt(mEffectAnimation, 0);
		return true;
	}

	public function play() {
		playAnimation(mBodyAnimation, mBodyLabel);
		if (mEffectAnimation != null && mEffectAnimation.visible) {
			playAnimation(mEffectAnimation, mEffectLabel);
		}
		joinJuggler();
	}

	public function stop() {
		stopAnimation(mBodyAnimation);
		stopAnimation(mEffectAnimation);
		leaveJuggler();
	}

	public function setBodyVisible(visible:Bool) {
		if (mBodyAnimation != null) {
			mBodyAnimation.visible = visible;
		}
	}

	public function setEffectVisible(visible:Bool) {
		if (mEffectAnimation != null) {
			mEffectAnimation.visible = visible;
		}
		if (visible) {
			playAnimation(mEffectAnimation, mEffectLabel);
			joinJuggler();
		}
	}

	public function playEffect() {
		playAnimation(mEffectAnimation, mEffectLabel);
		joinJuggler();
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
			Logger.warn("StarlingProjectileRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
			mLayerIndex = 20;
			_loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		}
		if (_loc2_ != null) {
			_loc2_.addChild(mContainer);
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setTransform(x:Float, y:Float, scaleX:Float, scaleY:Float, alpha:Float = 1) {
		mContainer.x = x;
		mContainer.y = y;
		mContainer.alpha = alpha;
		if (mBodyAnimation != null) {
			mBodyAnimation.scaleX = scaleX;
			mBodyAnimation.scaleY = scaleY;
		}
		mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
	}

	public function setBodyRotation(rotationDegrees:Float) {
		if (mBodyAnimation != null) {
			mBodyAnimation.rotation = rotationDegrees * 3.141592653589793 / 180;
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setEffectRotation(rotationDegrees:Float) {
		if (mEffectAnimation != null) {
			mEffectAnimation.rotation = rotationDegrees * 3.141592653589793 / 180;
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setBodyColorFilter(matrix:Array<ASAny>) {
		mBodyColorMatrix = toColorMatrix(matrix);
		if (mBodyAnimation != null) {
			mBodyAnimation.setColorMatrix(mBodyColorMatrix);
		}
	}

	public function clearBodyColorFilter() {
		mBodyColorMatrix = null;
		if (mBodyAnimation != null) {
			mBodyAnimation.setColorMatrix(null);
		}
	}

	public function setBodyGlowFilter(color:UInt, alpha:Float, blur:Float, quality:Float = 1) {
		if (mBodyAnimation == null) {
			return;
		}
		if (mBodyGlowFilter == null) {
			mBodyGlowFilter = new GlowFilter(color, alpha, blur, quality);
		} else {
			mBodyGlowFilter.color = color;
			mBodyGlowFilter.alpha = alpha;
			mBodyGlowFilter.blur = blur;
			mBodyGlowFilter.quality = quality;
		}
		updateBodyFilters();
	}

	public function clearBodyGlowFilter() {
		var _loc1_:GlowFilter = null;
		if (mBodyGlowFilter != null) {
			_loc1_ = mBodyGlowFilter;
			mBodyGlowFilter = null;
			updateBodyFilters();
			_loc1_.dispose();
		}
	}

	public function setEffectColorFilter(matrix:Array<ASAny>) {
		mEffectColorMatrix = toColorMatrix(matrix);
		if (mEffectAnimation != null) {
			mEffectAnimation.setColorMatrix(mEffectColorMatrix);
		}
	}

	public function clearEffectColorFilter() {
		mEffectColorMatrix = null;
		if (mEffectAnimation != null) {
			mEffectAnimation.setColorMatrix(null);
		}
	}

	public function setEffectGlowFilter(color:UInt, alpha:Float, blur:Float, quality:Float = 1) {
		if (mEffectAnimation == null) {
			return;
		}
		if (mEffectGlowFilter == null) {
			mEffectGlowFilter = new GlowFilter(color, alpha, blur, quality);
		} else {
			mEffectGlowFilter.color = color;
			mEffectGlowFilter.alpha = alpha;
			mEffectGlowFilter.blur = blur;
			mEffectGlowFilter.quality = quality;
		}
		updateEffectFilters();
	}

	public function clearEffectGlowFilter() {
		var _loc1_:GlowFilter = null;
		if (mEffectGlowFilter != null) {
			_loc1_ = mEffectGlowFilter;
			mEffectGlowFilter = null;
			updateEffectFilters();
			_loc1_.dispose();
		}
	}

	public function destroy() {
		leaveJuggler();
		if (mBodyAnimation != null) {
			mBodyAnimation.stop();
			mBodyAnimation.filter = null;
			mBodyAnimation.removeFromParent(true);
			mBodyAnimation = null;
		}
		if (mEffectAnimation != null) {
			mEffectAnimation.stop();
			mEffectAnimation.filter = null;
			mEffectAnimation.removeFromParent(true);
			mEffectAnimation = null;
		}
		mBodyColorMatrix = null;
		mEffectColorMatrix = null;
		if (mBodyGlowFilter != null) {
			mBodyGlowFilter.dispose();
			mBodyGlowFilter = null;
		}
		if (mEffectGlowFilter != null) {
			mEffectGlowFilter.dispose();
			mEffectGlowFilter = null;
		}
		if (mContainer != null) {
			mContainer.removeFromParent(true);
			mContainer = null;
		}
		mDBFacade = null;
	}

	function playAnimation(animation:Animation, label:String) {
		if (animation == null) {
			return;
		}
		if (label != null && animation.getFrame(label) >= 0) {
			animation.gotoLabel(label, true);
		} else {
			animation.loop = true;
			animation.currentFrame = 0;
			animation.play();
		}
	}

	function stopAnimation(animation:Animation) {
		if (animation == null) {
			return;
		}
		animation.stop();
	}

	function joinJuggler() {
		if (mContainer == null || !mVisible || mDBFacade == null) {
			return;
		}
		if (mBodyAnimation != null && mBodyAnimation.isPlaying && !mDBFacade.starlingLayerManager.juggler.contains(mBodyAnimation)) {
			mDBFacade.starlingLayerManager.juggler.add(mBodyAnimation);
		}
		if (mEffectAnimation != null && mEffectAnimation.isPlaying && !mDBFacade.starlingLayerManager.juggler.contains(mEffectAnimation)) {
			mDBFacade.starlingLayerManager.juggler.add(mEffectAnimation);
		}
	}

	function leaveJuggler() {
		if (mDBFacade == null) {
			return;
		}
		if (mBodyAnimation != null) {
			mDBFacade.starlingLayerManager.juggler.remove(mBodyAnimation);
		}
		if (mEffectAnimation != null) {
			mDBFacade.starlingLayerManager.juggler.remove(mEffectAnimation);
		}
	}

	function toColorMatrix(matrix:Array<ASAny>):Vector<Float> {
		var _loc2_ = 0;
		if (matrix == null || matrix.length != 20) {
			return null;
		}
		var _loc3_ = new Vector<Float>((20 : UInt), true);
		_loc2_ = 0;
		while (_loc2_ < 20) {
			_loc3_[_loc2_] = ASCompat.toNumber(matrix[_loc2_]);
			_loc2_++;
		}
		return _loc3_;
	}

	function updateBodyFilters() {
		if (mBodyAnimation != null) {
			mBodyAnimation.filter = mBodyGlowFilter;
		}
	}

	function updateEffectFilters() {
		if (mEffectAnimation != null) {
			mEffectAnimation.filter = mEffectGlowFilter;
		}
	}
}
