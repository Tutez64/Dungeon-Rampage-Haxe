package effects;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import starling.StatusTintFilter;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.extensions.animate.Animation;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.textures.Texture;
import starling.utils.Pool;

class StarlingEffectRenderer {
	public static inline final FRONT_DRAW_ORDER_OFFSET:Float = 0.2;

	public static inline final BACK_DRAW_ORDER_OFFSET:Float = -0.2;

	static var sIconTextureCache:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mDBFacade:DBFacade;

	var mContainer:Sprite;

	var mContent:Sprite;

	var mAnimation:Animation;

	var mLabel:String;

	var mLayerIndex:Int = 0;

	var mVisible:Bool = true;

	var mBaseFrameRate:Float = Math.NaN;

	var mPlayRate:Float = 1;

	var mFinishedCallback:ASFunction;

	var mWantsToPlay:Bool = false;

	var mOneShot:Bool = false;

	var mSegmentFrames:Int = 0;

	var mMarkerName:String;

	var mMarkerLayer:DisplayObjectContainer;

	var mMarkerHolder:Sprite;

	var mMarkerContent:DisplayObject;

	var mPendingMarkerContent:DisplayObject;

	var mLastWorld:Matrix;

	var mLastSortX:Float = Math.NaN;

	var mLastSortY:Float = Math.NaN;

	var mLastAlpha:Float = Math.NaN;

	var mStatusTint:StatusTintFilter = new StatusTintFilter();

	public function new(dbFacade:DBFacade, holderName:String, layerIndex:Int, animation:Animation, label:String) {
		mDBFacade = dbFacade;
		mLayerIndex = layerIndex;
		mAnimation = animation;
		mLabel = label;
		mBaseFrameRate = animation.frameRate;
		mContainer = new Sprite();
		mContainer.touchable = false;
		mContainer.name = "StarlingEffectRenderer_" + holderName;
		mContent = new Sprite();
		mContent.touchable = false;
		mContainer.addChild(mContent);
		mAnimation.touchable = false;
		mAnimation.stop();
		mContent.addChild(mAnimation);
		MemoryTracker.track(mContainer, "StarlingEffectRenderer - holder: " + holderName, "starling");
		setLayer(layerIndex);
	}

	public static function createIconImage(cacheKey:String, iconClip:flash.display.DisplayObject):Image {
		var _loc6_:Rectangle = null;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc4_:BitmapData = null;
		var _loc5_:Matrix = null;
		var _loc3_ = ASCompat.dynamicAs(ASDictionary.getString(sIconTextureCache, cacheKey), Texture);
		if (_loc3_ == null) {
			_loc6_ = iconClip.getBounds(iconClip);
			_loc7_ = ASCompat.floatToInt(Math.max(1, Math.fceil(_loc6_.width)));
			_loc8_ = ASCompat.floatToInt(Math.max(1, Math.fceil(_loc6_.height)));
			_loc4_ = new BitmapData(_loc7_, _loc8_, true, (0 : UInt));
			_loc5_ = Pool.getMatrix();
			_loc5_.translate(-_loc6_.x, -_loc6_.y);
			_loc4_.draw(iconClip, _loc5_);
			Pool.putMatrix(_loc5_);
			_loc3_ = Texture.fromBitmapData(_loc4_);
			_loc4_.dispose();
			sIconTextureCache[cacheKey] = _loc3_;
			MemoryTracker.track(_loc3_, "StarlingEffectRenderer icon texture: " + cacheKey, "starling");
		}
		return new Image(_loc3_);
	}

	static function findMarkerContainer(node:DisplayObjectContainer, markerName:String):DisplayObjectContainer {
		var _loc5_ = 0;
		var _loc6_:DisplayObject = null;
		var _loc3_:DisplayObjectContainer = null;
		var _loc4_:DisplayObjectContainer = null;
		_loc5_ = 0;
		while (_loc5_ < node.numChildren) {
			_loc6_ = node.getChildAt(_loc5_);
			if (Std.isOfType(_loc6_, DisplayObjectContainer) && _loc6_.name == markerName) {
				return ASCompat.reinterpretAs(_loc6_, DisplayObjectContainer);
			}
			_loc5_++;
		}
		_loc5_ = 0;
		while (_loc5_ < node.numChildren) {
			_loc3_ = ASCompat.reinterpretAs(node.getChildAt(_loc5_), DisplayObjectContainer);
			if (_loc3_ != null) {
				_loc4_ = findMarkerContainer(_loc3_, markerName);
				if (_loc4_ != null) {
					return _loc4_;
				}
			}
			_loc5_++;
		}
		return null;
	}

	@:isVar public var animation(get, never):Animation;

	public function get_animation():Animation {
		return mAnimation;
	}

	@:isVar public var label(get, never):String;

	public function get_label():String {
		return mLabel;
	}

	public function play(loop:Bool, finishedCallback:ASFunction) {
		var _loc4_:Point = null;
		if (mAnimation == null) {
			return;
		}
		mFinishedCallback = finishedCallback;
		mWantsToPlay = true;
		mOneShot = !loop && finishedCallback != null;
		mAnimation.composing = mVisible || !mOneShot || mMarkerHolder != null || mPendingMarkerContent != null;
		if (!mVisible && !mOneShot) {
			leaveJuggler();
		}
		mAnimation.removeEventListener("complete", onAnimationComplete);
		mAnimation.resetMovieClips();
		var _loc3_ = !loop && finishedCallback != null;
		if (_loc3_) {
			mAnimation.setMovieClipsPlayOnce();
			mAnimation.addEventListener("complete", onAnimationComplete);
		} else {
			mAnimation.clearMovieClipsPlayOnce();
		}
		if (mLabel != null && mAnimation.getFrame(mLabel) >= 0) {
			_loc4_ = mAnimation.gotoLabel(mLabel, loop);
			mSegmentFrames = ASCompat.floatToInt(_loc4_.x >= 0 ? ASCompat.floatToInt(_loc4_.y - _loc4_.x + 1) : 0);
			if (_loc3_ && _loc4_.x >= 0 && _loc4_.y - _loc4_.x < 1) {
				parkStaticPooledEffect();
				return;
			}
		} else {
			mSegmentFrames = 0;
			mAnimation.loop = loop;
			mAnimation.currentFrame = 0;
			if (_loc3_ && mAnimation.deepestFrames <= 1) {
				parkStaticPooledEffect();
				return;
			}
			mAnimation.play();
		}
		joinJuggler();
	}

	function parkStaticPooledEffect() {
		mOneShot = false;
		mAnimation.composing = true;
		if (!mVisible) {
			leaveJuggler();
		}
		mAnimation.removeEventListener("complete", onAnimationComplete);
		mAnimation.pause();
	}

	public function stop() {
		mWantsToPlay = false;
		mOneShot = false;
		if (mAnimation != null) {
			mAnimation.removeEventListener("complete", onAnimationComplete);
			mAnimation.stop();
			mAnimation.dropSkippedSteps();
			mAnimation.composing = true;
		}
		if (mPendingMarkerContent != null) {
			Logger.warnch("Starling", "StarlingEffectRenderer: marker layer \'" + mMarkerName + "\' never appeared in effect animation");
		}
		mMarkerLayer = null;
		mFinishedCallback = null;
		leaveJuggler();
	}

	@:isVar public var artDurationInSeconds(get, never):Float;

	public function get_artDurationInSeconds():Float {
		if (mAnimation == null || mAnimation.frameRate <= 0) {
			return 0;
		}
		var _loc1_ = mSegmentFrames > 0 ? mSegmentFrames : mAnimation.deepestFrames;
		return _loc1_ / mAnimation.frameRate;
	}

	public function setPlayRate(value:Float) {
		mPlayRate = value > 0 ? value : 1;
		if (mAnimation != null && mBaseFrameRate > 0) {
			mAnimation.frameRate = mBaseFrameRate * mPlayRate;
		}
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
			if (mAnimation != null) {
				mAnimation.composing = true;
			}
			joinJuggler();
		} else if (!mOneShot) {
			leaveJuggler();
		} else if (mAnimation != null && mMarkerHolder == null && mPendingMarkerContent == null) {
			mAnimation.composing = false;
		}
		return value;
	}

	@:isVar public var layerIndex(get, never):Int;

	public function get_layerIndex():Int {
		return mLayerIndex;
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
			Logger.warn("StarlingEffectRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
			mLayerIndex = 20;
			_loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		}
		if (mLayerIndex == 5) {
			mContainer.blendMode = "normal";
		} else {
			mContainer.blendMode = "auto";
		}
		if (_loc2_ != null) {
			_loc2_.addChild(mContainer);
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setWorldTransform(worldMatrix:Matrix, sortX:Float, sortY:Float, alpha:Float) {
		var _loc6_:Matrix = null;
		var _loc5_ = false;
		if (mContainer == null || mDBFacade == null) {
			return;
		}
		if (mLastWorld == null || alpha < 0 || alpha > 1 || sortX != mLastSortX || sortY != mLastSortY || alpha != mLastAlpha
			|| worldMatrix.a != mLastWorld.a || worldMatrix.b != mLastWorld.b || worldMatrix.c != mLastWorld.c || worldMatrix.d != mLastWorld.d
			|| worldMatrix.tx != mLastWorld.tx || worldMatrix.ty != mLastWorld.ty) {
			mContainer.x = sortX;
			mContainer.y = sortY;
			mContainer.alpha = alpha;
			_loc6_ = Pool.getMatrix();
			_loc6_.copyFrom(worldMatrix);
			_loc6_.tx -= sortX;
			_loc6_.ty -= sortY;
			_loc5_ = mContent.scaleX == 0 || mContent.scaleY == 0;
			mContent.transformationMatrix = _loc6_;
			if (_loc5_ != (mContent.scaleX == 0 || mContent.scaleY == 0)) {
				mContent.setRequiresRedraw();
			}
			Pool.putMatrix(_loc6_);
			if (mLastWorld == null) {
				mLastWorld = new Matrix();
			}
			mLastWorld.copyFrom(worldMatrix);
			mLastSortX = sortX;
			mLastSortY = sortY;
			mLastAlpha = alpha;
		}
		syncMarker();
		mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
	}

	public function attachMarkerContent(markerName:String, content:DisplayObject):Bool {
		if (mContent == null || mAnimation == null || content == null) {
			return false;
		}
		mAnimation.composing = true;
		if (mMarkerName != markerName || mMarkerLayer == null) {
			mMarkerName = markerName;
			mMarkerLayer = findMarkerContainer(mAnimation, markerName);
		}
		if (mMarkerLayer == null) {
			if (mPendingMarkerContent != null && mPendingMarkerContent != content) {
				mPendingMarkerContent.removeFromParent(Std.isOfType(mPendingMarkerContent, Animation));
			}
			mPendingMarkerContent = content;
			return false;
		}
		if (mPendingMarkerContent != null && mPendingMarkerContent != content) {
			mPendingMarkerContent.removeFromParent(Std.isOfType(mPendingMarkerContent, Animation));
		}
		mPendingMarkerContent = null;
		clearMarkerContent();
		mMarkerHolder = new Sprite();
		mMarkerHolder.touchable = false;
		mMarkerHolder.addChild(content);
		mMarkerContent = content;
		mContent.addChild(mMarkerHolder);
		applyStatusTint();
		if (Std.isOfType(content, IAnimatable)) {
			joinJuggler();
		}
		syncMarker();
		return true;
	}

	public function setStatusTint(color:UInt, amount:Float) {
		if (mContainer == null) {
			return;
		}
		mStatusTint.set(color, amount);
		applyStatusTint();
	}

	public function clearStatusTint() {
		if (!mStatusTint.active) {
			return;
		}
		mStatusTint.clear();
		applyStatusTint();
	}

	function applyStatusTint() {
		var _loc1_ = mStatusTint.matrix;
		if (mAnimation != null) {
			mAnimation.setColorMatrix(_loc1_);
		}
		if (mMarkerContent != null) {
			ColorTransformStyle.applyTo(mMarkerContent, _loc1_);
		}
		if (mPendingMarkerContent != null) {
			ColorTransformStyle.applyTo(mPendingMarkerContent, _loc1_);
		}
	}

	public function clearMarkerContent() {
		if (mPendingMarkerContent != null) {
			mPendingMarkerContent.removeFromParent(Std.isOfType(mPendingMarkerContent, Animation));
			mPendingMarkerContent = null;
		}
		if (mMarkerContent != null) {
			if (Std.isOfType(mMarkerContent, IAnimatable) && mDBFacade != null) {
				mDBFacade.starlingLayerManager.juggler.remove(ASCompat.reinterpretAs(mMarkerContent, IAnimatable));
			}
			mMarkerContent.removeFromParent(Std.isOfType(mMarkerContent, Animation));
			mMarkerContent = null;
		}
		if (mMarkerHolder != null) {
			mMarkerHolder.removeFromParent(true);
			mMarkerHolder = null;
		}
	}

	public function destroy() {
		leaveJuggler();
		mStatusTint.dispose();
		clearMarkerContent();
		mMarkerLayer = null;
		mMarkerName = null;
		if (mAnimation != null) {
			mAnimation.stop();
			mAnimation.removeEventListener("complete", onAnimationComplete);
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
		mLastWorld = null;
		mFinishedCallback = null;
		mDBFacade = null;
	}

	function onAnimationComplete(event:Event) {
		mOneShot = false;
		mWantsToPlay = false;
		leaveJuggler();
		var _loc2_ = mFinishedCallback;
		mFinishedCallback = null;
		if (_loc2_ != null) {
			_loc2_();
		}
	}

	function syncMarker() {
		if (mMarkerHolder == null && mPendingMarkerContent != null) {
			attachMarkerContent(mMarkerName, mPendingMarkerContent);
			return;
		}
		if (mMarkerHolder == null || mMarkerLayer == null) {
			return;
		}
		if (mMarkerLayer.numChildren == 0) {
			mMarkerHolder.visible = false;
			return;
		}
		var _loc2_ = mMarkerLayer.getChildAt(0);
		var _loc1_ = Pool.getMatrix();
		_loc2_.getTransformationMatrix(mContent, _loc1_);
		mMarkerHolder.transformationMatrix = _loc1_;
		Pool.putMatrix(_loc1_);
		mMarkerHolder.alpha = _loc2_.alpha;
		mMarkerHolder.visible = _loc2_.visible && mMarkerLayer.visible;
	}

	function joinJuggler() {
		if (mContainer == null || mDBFacade == null) {
			return;
		}
		if (!mVisible && !mOneShot) {
			return;
		}
		if (mAnimation != null && mWantsToPlay && !mDBFacade.starlingLayerManager.juggler.contains(mAnimation)) {
			mDBFacade.starlingLayerManager.juggler.add(mAnimation);
		}
		if (Std.isOfType(mMarkerContent, IAnimatable)
			&& !mDBFacade.starlingLayerManager.juggler.contains(ASCompat.reinterpretAs(mMarkerContent, IAnimatable))) {
			mDBFacade.starlingLayerManager.juggler.add(ASCompat.reinterpretAs(mMarkerContent, IAnimatable));
		}
	}

	function leaveJuggler() {
		if (mDBFacade == null) {
			return;
		}
		if (mAnimation != null) {
			mDBFacade.starlingLayerManager.juggler.remove(mAnimation);
		}
		if (Std.isOfType(mMarkerContent, IAnimatable)) {
			mDBFacade.starlingLayerManager.juggler.remove(ASCompat.reinterpretAs(mMarkerContent, IAnimatable));
		}
	}
}
