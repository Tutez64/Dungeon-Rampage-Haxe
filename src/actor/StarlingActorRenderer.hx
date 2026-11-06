package actor;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import collections.IMapIterator;
import collections.Map;
import facade.DBFacade;
import starling.StatusTintFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.extensions.animate.Animation;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.filters.FilterChain;
import starling.filters.FragmentFilter;
import starling.filters.GlowFilter;
import starling.textures.Texture;

class StarlingActorRenderer {
	public static inline final STARLING_ACTOR_RENDERER_TYPE = "StarlingActorRenderer";

	static inline final NO_LOOP_LABEL = "noloop";

	static inline final SUFFIX_A = "_angA";

	static inline final SUFFIX_B = "_angB";

	static inline final SUFFIX_C = "_angC";

	static inline final SUFFIX_D = "_angD";

	static inline final SUFFIX_E = "_angE";

	static inline final DEBUG_HEADING = false;

	static inline final FACING_HYSTERESIS:Float = 10;

	static var DIRECTION_LABELS:Array<ASAny>;

	static var FIVE_DIRECTION_LABELS:Array<ASAny>;

	static var sWarnedMissingLabels:ASObject;

	var mDBFacade:DBFacade;

	var mHolderName:String;

	var mContainer:Sprite;

	var mContent:Sprite;

	var mLayerIndex:Int = 0;

	var mContentScaleX:Float = 1;

	var mContentScaleY:Float = 1;

	var mCanvasReach:Float = Math.NaN;

	var mAnimations:Map;

	var mBaseFrameRates:Map;

	var mCurrentAnimation:Animation;

	var mAnimName:String;

	var mLoop:Bool = false;

	var mPlayRate:Float = 1;

	var mStartingFrame:Float = 0;

	var mVisible:Bool = true;

	var mCulled:Bool = false;

	var mOffImage:Image;

	var mFrameImage:Image;

	var mStaticEnsemble:Sprite;

	var mHighlightFilter:GlowFilter;

	var mPersistentGlowFilter:GlowFilter;

	var mColorMatrix:Vector<Float>;

	var mStatusTint:StatusTintFilter = new StatusTintFilter();

	var mFilterChain:FilterChain;

	var mMultiDirectionMode:Bool = false;

	var mMultiDirectionAnimation:Animation;

	var mMultiDirectionBaseFrameRate:Float = 0;

	var mDirectionLabels:Array<ASAny>;

	var mHeading:Float = 0;

	var mCurrentDirectionLabel:String;

	var mFlipX:Float = 1;

	var mBuiltLabelAnim:String;

	var mBuiltLabelSuffix:String;

	var mBuiltLabel:String;

	var mHasMultiDirectionAnimCache:ASObject;

	var mDrawOrderOffsetY:Float = 0;

	var mTransformStale:Bool = true;

	public function new(dbFacade:DBFacade, holderName:String, layerIndex:Int) {
		mDBFacade = dbFacade;
		mHolderName = holderName;
		mLayerIndex = layerIndex;
		mAnimations = new Map();
		mBaseFrameRates = new Map();
		mDirectionLabels = DIRECTION_LABELS;
		mContainer = new Sprite();
		mContainer.touchable = false;
		mContainer.name = "StarlingActorRenderer_" + holderName;
		mContent = new Sprite();
		mContent.touchable = false;
		mContainer.addChild(mContent);
		MemoryTracker.track(mContainer, "StarlingActorRenderer - holder: " + holderName, "starling");
		var _loc4_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		if (_loc4_ == null) {
			Logger.warn("StarlingActorRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
			mLayerIndex = 20;
			_loc4_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		}
		if (_loc4_ != null) {
			_loc4_.addChild(mContainer);
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	@:isVar public var rendererType(get, never):String;

	public function get_rendererType():String {
		return "StarlingActorRenderer";
	}

	public function addAnimation(animName:String, animation:Animation) {
		if (animation == null) {
			return;
		}
		animation.touchable = false;
		animation.stop();
		animation.setColorMatrix(currentColorMatrix());
		mAnimations.add(animName, animation);
		mBaseFrameRates.add(animName, animation.frameRate);
		mCanvasReach = Math.NaN;
	}

	public function hasAnim(animName:String):Bool {
		if (mMultiDirectionMode) {
			return hasMultiDirectionAnim(animName);
		}
		return mAnimations.hasKey(animName);
	}

	@:isVar public var currentAnimName(get, never):String;

	public function get_currentAnimName():String {
		return mAnimName;
	}

	@:isVar public var currentDirectionLabel(get, never):String;

	public function get_currentDirectionLabel():String {
		return mCurrentDirectionLabel;
	}

	public function getLocalBounds():Rectangle {
		if (mContainer == null) {
			return new Rectangle();
		}
		return mContainer.getBounds(mContainer);
	}

	public function getWorldBounds():Rectangle {
		var _loc1_ = getLocalBounds();
		if (mContainer != null) {
			_loc1_.offset(mContainer.x, mContainer.y);
		}
		return _loc1_;
	}

	public function getAnimDurationInSeconds(animName:String):Float {
		if (mMultiDirectionMode && mMultiDirectionAnimation != null) {
			return getMultiDirectionSegmentDuration(animName);
		}
		var _loc2_ = ASCompat.dynamicAs(mAnimations.itemFor(animName), Animation);
		return _loc2_ != null ? _loc2_.deepestFrames / _loc2_.frameRate : 0;
	}

	public function getAnimFrameCount(animName:String):Float {
		if (mMultiDirectionMode && mMultiDirectionAnimation != null) {
			return getMultiDirectionSegmentFrames(animName);
		}
		var _loc2_ = ASCompat.dynamicAs(mAnimations.itemFor(animName), Animation);
		return _loc2_ != null ? _loc2_.deepestFrames : 0;
	}

	function clampFrame(frameNumber:Int, animation:Animation):Int {
		if (animation == null) {
			return frameNumber;
		}
		var _loc3_ = animation.numFrames - 1;
		if (frameNumber < 0) {
			return 0;
		}
		if (frameNumber > _loc3_) {
			return _loc3_;
		}
		return frameNumber;
	}

	public function play(animName:String, startingFrame:Int = 0, loop:Bool = true, playRate:Float = 1):Bool {
		if (mMultiDirectionMode) {
			return playMultiDirection(animName, startingFrame, loop, playRate);
		}
		var _loc5_ = ASCompat.dynamicAs(mAnimations.itemFor(animName), Animation);
		if (_loc5_ == null) {
			return false;
		}
		showOffImage(false);
		showFrameImage(false);
		if (mCurrentAnimation != null) {
			mCurrentAnimation.removeEventListener("complete", onAnimationComplete);
		}
		if (mCurrentAnimation != _loc5_) {
			deactivateCurrent();
			mCurrentAnimation = _loc5_;
			mContent.addChild(mCurrentAnimation);
		}
		mAnimName = animName;
		mLoop = loop;
		mCurrentAnimation.loop = loop;
		if (mCurrentAnimation.hasFrameLabel("noloop")) {
			mCurrentAnimation.loop = false;
			mCurrentAnimation.setMovieClipsPlayOnce();
			mCurrentAnimation.resetMovieClips();
			mCurrentAnimation.addEventListener("complete", onAnimationComplete);
		} else if (!mCurrentAnimation.loop) {
			mCurrentAnimation.setMovieClipsPlayOnce();
			mCurrentAnimation.resetMovieClips();
			mCurrentAnimation.addEventListener("complete", onAnimationComplete);
		} else {
			mCurrentAnimation.clearMovieClipsPlayOnce();
		}
		mCurrentAnimation.currentFrame = clampFrame(startingFrame, _loc5_);
		this.playRate = playRate;
		mCurrentAnimation.play();
		joinJuggler();
		return true;
	}

	public function setFrame(animName:String, frameNumber:Int) {
		if (mMultiDirectionMode) {
			setFrameMultiDirection(animName, frameNumber);
			return;
		}
		var _loc3_ = ASCompat.dynamicAs(mAnimations.itemFor(animName), Animation);
		if (_loc3_ == null) {
			stop();
			return;
		}
		if (mCurrentAnimation != _loc3_) {
			deactivateCurrent();
			mCurrentAnimation = _loc3_;
			mContent.addChild(mCurrentAnimation);
		}
		mAnimName = animName;
		mCurrentAnimation.currentFrame = clampFrame(frameNumber, _loc3_);
		mCurrentAnimation.pause();
		leaveJuggler();
		showOffImage(true);
		showFrameImage(true);
	}

	public function forceFrame(frameNumber:Int) {
		if (mCurrentAnimation != null) {
			mCurrentAnimation.currentFrame = clampFrame(frameNumber, mCurrentAnimation);
		}
	}

	public function stop() {
		deactivateCurrent();
		mAnimName = null;
		mLoop = false;
		showOffImage(true);
		showFrameImage(true);
	}

	public function enableMultiDirectionMode(singleAnimation:Animation) {
		if (singleAnimation == null) {
			return;
		}
		mMultiDirectionMode = true;
		mMultiDirectionAnimation = singleAnimation;
		mMultiDirectionBaseFrameRate = singleAnimation.frameRate;
		singleAnimation.setColorMatrix(currentColorMatrix());
		mHasMultiDirectionAnimCache = {};
		mCanvasReach = Math.NaN;
		if (singleAnimation.hasFrameLabelSuffix("_angA") || singleAnimation.hasFrameLabelSuffix("_angC")) {
			mDirectionLabels = FIVE_DIRECTION_LABELS;
		} else {
			mDirectionLabels = DIRECTION_LABELS;
		}
	}

	@:isVar public var heading(get, set):Float;

	public function get_heading():Float {
		return mHeading;
	}

	function set_heading(value:Float):Float {
		var _loc9_:String;
		var __ax4_iter_2:Array<ASAny>;
		var _loc11_:String = null;
		var _loc12_:Point = null;
		var _loc5_ = 0;
		var _loc2_ = 0;
		var _loc8_:Point = null;
		if (!mMultiDirectionMode || mMultiDirectionAnimation == null) {
			return value;
		}
		mHeading = value;
		if (mAnimName == null || mCurrentAnimation != mMultiDirectionAnimation) {
			return value;
		}
		var _loc7_ = buildDirectionLabel(mAnimName, value);
		if (_loc7_ != mCurrentDirectionLabel
			&& mCurrentDirectionLabel != null
			&& mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states")
			&& (buildDirectionLabel(mAnimName, value + 10) == mCurrentDirectionLabel
				|| buildDirectionLabel(mAnimName, value - 10) == mCurrentDirectionLabel)) {
			_loc7_ = mCurrentDirectionLabel;
		}
		if (_loc7_ == mCurrentDirectionLabel) {
			updateFlipForHeading(value);
			return value;
		}
		var _loc10_ = mMultiDirectionAnimation.getFrame(_loc7_);
		if (_loc10_ < 0) {
			__ax4_iter_2 = mDirectionLabels;
			if (checkNullIteratee(__ax4_iter_2))
				for (_tmp_ in __ax4_iter_2) {
					_loc9_ = _tmp_;
					_loc11_ = mAnimName + _loc9_;
					if (_loc11_ != _loc7_) {
						_loc10_ = mMultiDirectionAnimation.getFrame(_loc11_);
						if (_loc10_ >= 0) {
							_loc7_ = _loc11_;
							break;
						}
					}
				}
		}
		if (_loc10_ < 0) {
			return value;
		}
		if (_loc7_ == mCurrentDirectionLabel) {
			updateFlipForHeading(value);
			return value;
		}
		var _loc6_ = getRangeForLabel(_loc7_, _loc10_);
		if (_loc6_.x < 0) {
			return value;
		}
		var _loc3_ = 0;
		if (mCurrentDirectionLabel != null) {
			_loc5_ = mMultiDirectionAnimation.getFrame(mCurrentDirectionLabel);
			if (_loc5_ >= 0) {
				_loc12_ = getRangeForLabel(mCurrentDirectionLabel, _loc5_);
				_loc3_ = ASCompat.floatToInt(mMultiDirectionAnimation.currentFrame - _loc12_.x);
				if (_loc3_ < 0) {
					_loc3_ = 0;
				}
				_loc2_ = ASCompat.floatToInt(_loc12_.y - _loc12_.x);
				if (_loc3_ > _loc2_) {
					_loc3_ = _loc2_;
				}
				if (!mLoop && !mMultiDirectionAnimation.isPlaying && mMultiDirectionAnimation.currentFrame >= _loc12_.y) {
					_loc3_ = ASCompat.floatToInt(_loc6_.y - _loc6_.x);
				}
			}
		}
		var _loc4_ = ASCompat.floatToInt(_loc6_.x + _loc3_);
		if (_loc4_ < _loc6_.x) {
			_loc4_ = ASCompat.floatToInt(_loc6_.x);
		}
		if (_loc4_ > _loc6_.y) {
			_loc4_ = ASCompat.floatToInt(_loc6_.y);
		}
		if (mMultiDirectionAnimation.isPlaying) {
			_loc8_ = mMultiDirectionAnimation.gotoLabel(_loc7_, mLoop, _loc4_);
			if (_loc8_.x >= 0) {
				mCurrentDirectionLabel = _loc7_;
				updateFlipForHeading(value);
				joinJuggler();
			}
		} else {
			mMultiDirectionAnimation.clearLabel();
			mMultiDirectionAnimation.currentFrame = _loc4_;
			mMultiDirectionAnimation.pause();
			mCurrentDirectionLabel = _loc7_;
			updateFlipForHeading(value);
		}
		return value;
	}

	@:isVar public var currentFrame(get, never):Int;

	public function get_currentFrame():Int {
		var _loc1_ = 0;
		if (mCurrentAnimation == null) {
			return 0;
		}
		if (mMultiDirectionMode && mCurrentDirectionLabel != null) {
			_loc1_ = mMultiDirectionAnimation.getKeyframeIndex(mCurrentDirectionLabel, mMultiDirectionAnimation.currentFrame);
			if (_loc1_ >= 0) {
				return _loc1_;
			}
		}
		return mCurrentAnimation.currentFrame;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return mLoop;
	}

	function set_loop(value:Bool):Bool {
		var _loc3_:Point = null;
		if (mLoop == value || mCurrentAnimation == null) {
			mLoop = value;
			return value;
		}
		mLoop = value;
		if (mMultiDirectionMode) {
			if (mCurrentDirectionLabel != null) {
				_loc3_ = mMultiDirectionAnimation.gotoLabel(mCurrentDirectionLabel, value);
				if (_loc3_.x >= 0) {
					if (value) {
						mMultiDirectionAnimation.removeEventListener("complete", onAnimationComplete);
					} else {
						mMultiDirectionAnimation.addEventListener("complete", onAnimationComplete);
					}
					joinJuggler();
				}
			}
			return value;
		}
		var _loc2_ = value && !mCurrentAnimation.hasFrameLabel("noloop");
		var _loc4_ = _loc2_ && mCurrentAnimation.isFinished;
		mCurrentAnimation.loop = _loc2_;
		if (_loc2_) {
			mCurrentAnimation.clearMovieClipsPlayOnce();
			mCurrentAnimation.removeEventListener("complete", onAnimationComplete);
		} else {
			mCurrentAnimation.setMovieClipsPlayOnce();
			mCurrentAnimation.addEventListener("complete", onAnimationComplete);
		}
		if (_loc4_) {
			mCurrentAnimation.play();
		}
		joinJuggler();
		return value;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return mCurrentAnimation != null && mCurrentAnimation.isPlaying;
	}

	@:isVar public var playRate(get, set):Float;

	public function get_playRate():Float {
		return mPlayRate;
	}

	function set_playRate(value:Float):Float {
		mPlayRate = value > 0 ? value : 1;
		if (mCurrentAnimation == null) {
			return value;
		}
		var _loc2_ = mMultiDirectionMode ? mMultiDirectionBaseFrameRate : ASCompat.toNumber(mBaseFrameRates.itemFor(mAnimName));
		if (_loc2_ > 0) {
			mCurrentAnimation.frameRate = _loc2_ * mPlayRate;
		}
		return value;
	}

	@:isVar public var startingFrame(never, set):Int;

	public function set_startingFrame(value:Int):Int {
		mStartingFrame = value;
		if (mCurrentAnimation != null) {
			mCurrentAnimation.currentFrame = clampFrame(value, mCurrentAnimation);
		}
		return value;
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
		mContainer.visible = value && !mCulled;
		if (value) {
			joinJuggler();
		} else {
			leaveJuggler();
		}
		return value;
	}

	public function setVisibility(visible:Bool, culled:Bool) {
		if (mCulled != culled) {
			mCulled = culled;
			if (mVisible == visible) {
				joinJuggler();
			}
		}
		this.visible = visible;
		mContainer.visible = mVisible && !mCulled;
	}

	public function getContentRadius():Float {
		if (mContent == null) {
			return 0;
		}
		var _loc3_ = mContent.getBounds(mContent);
		var _loc1_ = Math.max(Math.abs(_loc3_.left), Math.abs(_loc3_.right)) * Math.abs(mContentScaleX);
		var _loc2_ = Math.max(Math.abs(_loc3_.top), Math.abs(_loc3_.bottom)) * Math.abs(mContentScaleY);
		return Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
	}

	@:isVar public var canvasReach(get, never):Float;

	public function get_canvasReach():Float {
		var _loc5_:Animation;
		var _loc4_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc2_:Array<ASAny> = null;
		var _loc3_:IMapIterator = null;
		if (Math.isNaN(mCanvasReach)) {
			_loc4_ = 0;
			_loc1_ = 0;
			_loc2_ = [mMultiDirectionAnimation];
			_loc3_ = ASCompat.reinterpretAs(mAnimations.iterator(), IMapIterator);
			while (_loc3_.hasNext()) {
				_loc2_.push(_loc3_.next());
			}
			if (checkNullIteratee(_loc2_))
				for (_tmp_ in _loc2_) {
					_loc5_ = ASCompat.coerce(_tmp_, starling.extensions.animate.Animation);
					if (_loc5_ != null) {
						if (_loc5_.sourceWidth > _loc4_) {
							_loc4_ = _loc5_.sourceWidth;
						}
						if (_loc5_.sourceHeight > _loc1_) {
							_loc1_ = _loc5_.sourceHeight;
						}
					}
				}
			mCanvasReach = Math.max(_loc4_ * Math.abs(mContentScaleX), _loc1_ * Math.abs(mContentScaleY));
		}
		return mCanvasReach;
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
			Logger.warn("StarlingActorRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
			mLayerIndex = 20;
			_loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
		}
		if (_loc2_ != null) {
			_loc2_.addChild(mContainer);
			mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
		}
	}

	public function setTransform(x:Float, y:Float, rotationRadians:Float, scaleX:Float, scaleY:Float, alpha:Float = 1, sortX:Float = null, sortY:Float = null) {
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
		sortY += mDrawOrderOffsetY;
		mContainer.x = sortX;
		mContainer.y = sortY;
		mContainer.alpha = alpha;
		var _loc9_ = x - sortX;
		var _loc12_ = y - sortY;
		var _loc10_ = scaleX * mContentScaleX * mFlipX;
		var _loc11_ = scaleY * mContentScaleY;
		mContent.x = _loc9_;
		mContent.y = _loc12_;
		mContent.rotation = rotationRadians;
		mContent.scaleX = _loc10_;
		mContent.scaleY = _loc11_;
		mTransformStale = _loc9_ != _loc9_ || _loc12_ != _loc12_ || _loc10_ != _loc10_ || _loc11_ != _loc11_ || !Math.isFinite(rotationRadians);
		markLayerDirty();
	}

	@:isVar public var transformStale(get, never):Bool;

	public function get_transformStale():Bool {
		return mTransformStale;
	}

	public function markLayerDirty() {
		mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
	}

	public function setContentScale(contentScaleX:Float, contentScaleY:Float) {
		if (mContentScaleX != contentScaleX || mContentScaleY != contentScaleY) {
			mTransformStale = true;
		}
		mContentScaleX = contentScaleX;
		mContentScaleY = contentScaleY;
		mCanvasReach = Math.NaN;
	}

	@:isVar public var drawOrderOffsetY(get, set):Float;

	public function get_drawOrderOffsetY():Float {
		return mDrawOrderOffsetY;
	}

	function set_drawOrderOffsetY(value:Float):Float {
		if (mDrawOrderOffsetY != value) {
			mTransformStale = true;
		}
		return mDrawOrderOffsetY = value;
	}

	function playMultiDirection(animName:String, startingFrame:Int, loop:Bool, playRate:Float):Bool {
		var _loc7_:String = null;
		if (mMultiDirectionAnimation == null) {
			return false;
		}
		var _loc6_ = resolveMultiDirectionLabel(animName, mHeading);
		if (_loc6_ == null && animName == "run") {
			_loc6_ = resolveMultiDirectionLabel("idle", mHeading);
			if (_loc6_ != null) {
				animName = "idle";
			}
		}
		if (_loc6_ == null) {
			_loc7_ = mContainer.name + "/" + animName;
			if (!ASCompat.toBool(sWarnedMissingLabels[_loc7_])) {
				sWarnedMissingLabels[_loc7_] = true;
				Logger.warnch("Starling", "Multi-direction animation for " + mContainer.name + " has no usable label for: " + animName);
			}
			return false;
		}
		showOffImage(false);
		showFrameImage(false);
		if (mCurrentAnimation != null) {
			mCurrentAnimation.removeEventListener("complete", onAnimationComplete);
		}
		if (mCurrentAnimation != mMultiDirectionAnimation) {
			deactivateCurrent();
			mCurrentAnimation = mMultiDirectionAnimation;
			mContent.addChild(mCurrentAnimation);
		}
		mAnimName = animName;
		mLoop = loop;
		if (!mLoop) {
			mMultiDirectionAnimation.addEventListener("complete", onAnimationComplete);
		}
		var _loc5_ = mMultiDirectionAnimation.gotoLabel(_loc6_, mLoop);
		if (_loc5_.x < 0) {
			Logger.warnch("Starling", "Multi-direction animation for " + mContainer.name + " failed to seek label: " + _loc6_);
			mMultiDirectionAnimation.removeEventListener("complete", onAnimationComplete);
			return false;
		}
		mCurrentDirectionLabel = _loc6_;
		updateFlipForHeading(mHeading);
		if (startingFrame > 0) {
			mMultiDirectionAnimation.currentFrame = mMultiDirectionAnimation.getKeyframe(_loc6_, startingFrame);
		}
		this.playRate = playRate;
		if (!mLoop && mMultiDirectionAnimation.hasFrameLabel("noloop")) {
			mMultiDirectionAnimation.loop = false;
		}
		joinJuggler();
		return true;
	}

	function resolveMultiDirectionLabel(animName:String, heading:Float):String {
		var _loc5_:String = null;
		var _loc3_ = buildDirectionLabel(animName, heading);
		if (mMultiDirectionAnimation.getFrame(_loc3_) >= 0) {
			return _loc3_;
		}
		var _loc4_:String;
		final __ax4_iter_3 = mDirectionLabels;
		if (checkNullIteratee(__ax4_iter_3))
			for (_tmp_ in __ax4_iter_3) {
				_loc4_ = _tmp_;
				_loc5_ = animName + _loc4_;
				if (_loc5_ != _loc3_) {
					if (mMultiDirectionAnimation.getFrame(_loc5_) >= 0) {
						return _loc5_;
					}
				}
			}
		return null;
	}

	function setFrameMultiDirection(animName:String, frameNumber:Int) {
		var _loc5_:String;
		var __ax4_iter_4:Array<ASAny>;
		var _loc6_:String = null;
		if (mMultiDirectionAnimation == null) {
			return;
		}
		var _loc4_ = buildDirectionLabel(animName, mHeading);
		var _loc3_ = mMultiDirectionAnimation.getFrame(_loc4_);
		if (_loc3_ < 0) {
			__ax4_iter_4 = mDirectionLabels;
			if (checkNullIteratee(__ax4_iter_4))
				for (_tmp_ in __ax4_iter_4) {
					_loc5_ = _tmp_;
					_loc6_ = animName + _loc5_;
					if (_loc6_ != _loc4_) {
						_loc3_ = mMultiDirectionAnimation.getFrame(_loc6_);
						if (_loc3_ >= 0) {
							_loc4_ = _loc6_;
							break;
						}
					}
				}
		}
		if (_loc3_ < 0) {
			stop();
			return;
		}
		if (mCurrentAnimation != mMultiDirectionAnimation) {
			deactivateCurrent();
			mCurrentAnimation = mMultiDirectionAnimation;
			mContent.addChild(mCurrentAnimation);
		}
		mAnimName = animName;
		mCurrentDirectionLabel = _loc4_;
		updateFlipForHeading(mHeading);
		mMultiDirectionAnimation.gotoFrame(mMultiDirectionAnimation.getKeyframe(_loc4_, frameNumber));
		mMultiDirectionAnimation.pause();
		leaveJuggler();
		showOffImage(true);
		showFrameImage(true);
	}

	function buildDirectionLabel(animName:String, heading:Float):String {
		var _loc3_ = directionSuffix(heading);
		if (_loc3_ != mBuiltLabelSuffix || animName != mBuiltLabelAnim) {
			mBuiltLabelAnim = animName;
			mBuiltLabelSuffix = _loc3_;
			mBuiltLabel = animName + _loc3_;
		}
		return mBuiltLabel;
	}

	function directionSuffix(heading:Float):String {
		var _loc2_:String = null;
		while (heading > 180) {
			heading -= 360;
		}
		while (heading <= -180) {
			heading += 360;
		}
		if (mDirectionLabels.length >= 5) {
			if (heading > 90) {
				heading = 180 - heading;
			} else if (heading < -90) {
				heading = -heading - 180;
			}
			if (heading >= 60 && heading <= 120) {
				_loc2_ = "_angE";
			} else if (heading >= 30 && heading < 60) {
				_loc2_ = "_angD";
			} else if (heading >= -30 && heading < 30) {
				_loc2_ = "_angC";
			} else if (heading >= -60 && heading < -30) {
				_loc2_ = "_angB";
			} else {
				_loc2_ = "_angA";
			}
		} else {
			if (heading > 90) {
				heading = 180 - heading;
			} else if (heading < -90) {
				heading = -heading - 180;
			}
			if (heading >= 60 && heading <= 90) {
				_loc2_ = "_angE";
			} else if (heading >= 0 && heading < 60) {
				_loc2_ = "_angD";
			} else if (heading >= -90 && heading < 0) {
				_loc2_ = "_angB";
			} else {
				_loc2_ = "_angE";
			}
		}
		return _loc2_;
	}

	function updateFlipForHeading(heading:Float) {
		var _loc3_ = mFlipX;
		var _loc2_ = Math.abs(heading);
		if (mDirectionLabels.length >= 5) {
			mFlipX = _loc2_ >= 90 ? -1 : 1;
		} else {
			mFlipX = _loc2_ >= 90 ? -1 : 1;
		}
		if (mFlipX != _loc3_) {
			mTransformStale = true;
		}
	}

	function hasMultiDirectionAnim(animName:String):Bool {
		if (mMultiDirectionAnimation == null) {
			return false;
		}
		var _loc3_:ASAny = mHasMultiDirectionAnimCache[animName];
		if (Std.isOfType(_loc3_, Bool)) {
			return ASCompat.toBool(_loc3_);
		}
		var _loc2_ = false;
		var _loc4_:String;
		final __ax4_iter_5 = mDirectionLabels;
		if (checkNullIteratee(__ax4_iter_5))
			for (_tmp_ in __ax4_iter_5) {
				_loc4_ = _tmp_;
				if (mMultiDirectionAnimation.getFrame(animName + _loc4_) >= 0) {
					_loc2_ = true;
					break;
				}
			}
		mHasMultiDirectionAnimCache[animName] = _loc2_;
		return _loc2_;
	}

	function getMultiDirectionSegmentDuration(animName:String):Float {
		var _loc2_ = getMultiDirectionSegmentRange(animName);
		if (_loc2_.x < 0 || mMultiDirectionAnimation == null || mMultiDirectionAnimation.frameRate <= 0) {
			return 0;
		}
		return (_loc2_.y - _loc2_.x + 1) / mMultiDirectionAnimation.frameRate;
	}

	function getMultiDirectionSegmentFrames(animName:String):Float {
		var _loc2_ = getMultiDirectionSegmentRange(animName);
		if (_loc2_.x < 0) {
			return 0;
		}
		return _loc2_.y - _loc2_.x + 1;
	}

	function getMultiDirectionSegmentRange(animName:String):Point {
		var _loc5_:String = null;
		if (mMultiDirectionAnimation == null) {
			return new Point(-1, -1);
		}
		var _loc3_ = buildDirectionLabel(animName, mHeading);
		var _loc2_ = mMultiDirectionAnimation.getFrame(_loc3_);
		if (_loc2_ >= 0) {
			return getRangeForLabel(_loc3_, _loc2_);
		}
		var _loc4_:String;
		final __ax4_iter_6 = mDirectionLabels;
		if (checkNullIteratee(__ax4_iter_6))
			for (_tmp_ in __ax4_iter_6) {
				_loc4_ = _tmp_;
				_loc5_ = animName + _loc4_;
				if (_loc5_ != _loc3_) {
					_loc2_ = mMultiDirectionAnimation.getFrame(_loc5_);
					if (_loc2_ >= 0) {
						return getRangeForLabel(_loc5_, _loc2_);
					}
				}
			}
		return new Point(-1, -1);
	}

	function getRangeForLabel(label:String, start:Int):Point {
		var _loc3_ = mMultiDirectionAnimation.getNextLabel(label);
		var _loc5_ = _loc3_ != null ? mMultiDirectionAnimation.getFrame(_loc3_) : -1;
		var _loc4_ = (_loc5_ > start ? _loc5_ : mMultiDirectionAnimation.numFrames) - 1;
		return new Point(start, _loc4_);
	}

	public function setFrameImage(texture:Texture) {
		if (mFrameImage != null) {
			mFrameImage.removeFromParent();
			mFrameImage = null;
		}
		if (texture == null) {
			return;
		}
		mFrameImage = new Image(texture);
		mFrameImage.touchable = false;
		mFrameImage.pixelSnapping = false;
		if (texture.frame != null) {
			mFrameImage.pivotX = -texture.frame.x + texture.width * 0.5;
			mFrameImage.pivotY = -texture.frame.y + texture.height;
		}
		mContent.addChild(mFrameImage);
		ColorTransformStyle.setColorTransform(mFrameImage, currentColorMatrix());
	}

	public function setOffImage(texture:Texture) {
		if (mOffImage != null) {
			mOffImage.removeFromParent();
			mOffImage = null;
		}
		if (texture == null) {
			return;
		}
		mOffImage = new Image(texture);
		mOffImage.touchable = false;
		mOffImage.pixelSnapping = false;
		if (texture.frame != null) {
			mOffImage.pivotX = -texture.frame.x + texture.width * 0.5;
			mOffImage.pivotY = -texture.frame.y + texture.height;
		} else {
			mOffImage.pivotX = texture.width * 0.5;
			mOffImage.pivotY = texture.height;
		}
		mContent.addChild(mOffImage);
		ColorTransformStyle.setColorTransform(mOffImage, currentColorMatrix());
	}

	public function setStaticEnsemble(parts:Array<ASAny>, libraryKey:String = null):Int {
		var _loc8_:String = null;
		var _loc5_:Texture = null;
		var _loc3_:Image = null;
		var _loc10_:Array<ASAny> = null;
		if (mStaticEnsemble != null) {
			mStaticEnsemble.removeFromParent(true);
			mStaticEnsemble = null;
		}
		if (parts == null || parts.length == 0) {
			return 0;
		}
		var _loc7_ = new Sprite();
		_loc7_.touchable = false;
		var _loc9_ = new Matrix();
		var _loc4_ = 0;
		var _loc6_:ASObject;
		if (checkNullIteratee(parts))
			for (_tmp_ in parts) {
				_loc6_ = _tmp_;
				_loc8_ = ASCompat.asString(_loc6_.tex);
				_loc5_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc8_, libraryKey);
				if (_loc5_ == null) {
					Logger.warnch("Starling", "StarlingActorRenderer.setStaticEnsemble: no atlas entry \'" + _loc8_ + "\'; part skipped");
				} else {
					_loc3_ = new Image(_loc5_);
					_loc3_.touchable = false;
					_loc3_.pixelSnapping = false;
					_loc10_ = ASCompat.dynamicAs(_loc6_.m, Array);
					if (_loc10_ != null && _loc10_.length == 6) {
						_loc9_.setTo(ASCompat.toNumber(_loc10_[0]), ASCompat.toNumber(_loc10_[1]), ASCompat.toNumber(_loc10_[2]),
							ASCompat.toNumber(_loc10_[3]), ASCompat.toNumber(_loc10_[4]), ASCompat.toNumber(_loc10_[5]));
						_loc3_.transformationMatrix = _loc9_;
					}
					if (_loc6_.a != /*undefined*/ null) {
						_loc3_.alpha = ASCompat.toNumber(_loc6_.a);
					}
					_loc7_.addChild(_loc3_);
					_loc4_++;
				}
			}
		if (_loc4_ == 0) {
			_loc7_.dispose();
			return 0;
		}
		mStaticEnsemble = _loc7_;
		mContent.addChildAt(mStaticEnsemble, 0);
		ColorTransformStyle.applyTo(mStaticEnsemble, currentColorMatrix());
		return _loc4_;
	}

	public function showOffImage(value:Bool) {
		if (mOffImage != null) {
			mOffImage.visible = value;
		}
		if (mStaticEnsemble != null) {
			mStaticEnsemble.visible = value;
		}
	}

	function showFrameImage(value:Bool) {
		if (mFrameImage != null) {
			mFrameImage.visible = value;
		}
	}

	public function alignStaticImagesToAnimation(reference:Animation) {
		if (reference == null) {
			return;
		}
		reference.currentFrame = 0;
		if (mFrameImage != null) {
			alignStaticImageToAnimationPart(mFrameImage, "frame", reference);
		}
		if (mOffImage != null) {
			alignStaticImageToAnimationPart(mOffImage, "static", reference);
		}
	}

	function alignStaticImageToAnimationPart(image:Image, role:String, reference:Animation) {
		var _loc4_ = image.texture.frameWidth;
		var _loc7_ = image.texture.frameHeight;
		var _loc5_ = findAnimationPartByCanvasSize(reference, _loc4_, _loc7_);
		if (_loc5_ == null) {
			Logger.debugch("Starling",
				"StarlingActorRenderer.alignStaticImagesToAnimation: \'"
				+ mHolderName
				+ "\' "
				+ role
				+ " image ("
				+ _loc4_
				+ "x"
				+ _loc7_
				+ ") matches no part on the animation\'s first frame (parts: "
				+ collectAnimationPartSizes(reference)
				+ "); keeping its default pivot");
			return;
		}
		var _loc14_ = _loc5_.getBounds(reference);
		image.pivotX = 0;
		image.pivotY = 0;
		var _loc8_ = getPartTextureFrame(_loc5_);
		var _loc6_ = image.texture.frame;
		var _loc12_ = _loc8_ != null ? _loc8_.x : 0;
		var _loc9_ = _loc8_ != null ? _loc8_.y : 0;
		var _loc10_ = _loc6_ != null ? _loc6_.x : 0;
		var _loc13_ = _loc6_ != null ? _loc6_.y : 0;
		var _loc11_ = (_loc14_.width - _loc4_) * 0.5;
		var _loc15_ = (_loc14_.height - _loc7_) * 0.5;
		if (_loc8_ == null) {
			image.x = _loc14_.x + _loc11_;
			image.y = _loc14_.y + _loc15_;
		} else {
			image.x = _loc14_.x + _loc11_ - _loc12_ + _loc10_;
			image.y = _loc14_.y + _loc15_ - _loc9_ + _loc13_;
		}
	}

	function getPartTextureFrame(part:DisplayObject):Rectangle {
		var _loc2_:DisplayObjectContainer = null;
		var _loc3_ = 0;
		var _loc4_:DisplayObject = null;
		var _loc5_:Rectangle = null;
		if (Std.isOfType(part, Image)) {
			return cast(part, Image).texture.frame;
		}
		if (Std.isOfType(part, DisplayObjectContainer)) {
			_loc2_ = ASCompat.reinterpretAs(part, DisplayObjectContainer);
			_loc3_ = 0;
			while (_loc3_ < _loc2_.numChildren) {
				_loc4_ = _loc2_.getChildAt(_loc3_);
				if (Std.isOfType(_loc4_, Image)) {
					return cast(_loc4_, Image).texture.frame;
				}
				_loc5_ = getPartTextureFrame(_loc4_);
				if (_loc5_ != null) {
					return _loc5_;
				}
				_loc3_++;
			}
		}
		return null;
	}

	function findAnimationPartByCanvasSize(root:DisplayObjectContainer, canvasWidth:Float, canvasHeight:Float):DisplayObject {
		var _loc5_:DisplayObject = null;
		var _loc4_:DisplayObjectContainer = null;
		var _loc7_ = 0;
		var _loc6_:DisplayObject = null;
		var _loc8_:Array<ASAny> = [root];
		while (_loc8_.length > 0) {
			_loc5_ = ASCompat.dynamicAs(_loc8_.shift(), DisplayObject);
			if (_loc5_ != root && boundsMatchCanvasSize(_loc5_, root, canvasWidth, canvasHeight)) {
				_loc6_ = _loc5_;
			}
			_loc4_ = ASCompat.reinterpretAs(_loc5_, DisplayObjectContainer);
			if (_loc4_ != null) {
				_loc7_ = 0;
				while (_loc7_ < _loc4_.numChildren) {
					_loc8_.push(_loc4_.getChildAt(_loc7_));
					_loc7_++;
				}
			}
		}
		return _loc6_;
	}

	function boundsMatchCanvasSize(node:DisplayObject, space:DisplayObject, canvasWidth:Float, canvasHeight:Float):Bool {
		var _loc7_ = node.getBounds(space);
		var _loc5_ = _loc7_.width - canvasWidth;
		var _loc6_ = _loc7_.height - canvasHeight;
		return _loc5_ >= -0.5 && _loc5_ <= 2.5 && _loc6_ >= -0.5 && _loc6_ <= 2.5;
	}

	function collectAnimationPartSizes(root:DisplayObjectContainer):String {
		var _loc3_:DisplayObject = null;
		var _loc2_:DisplayObjectContainer = null;
		var _loc5_:Rectangle = null;
		var _loc6_ = 0;
		var _loc4_:Array<ASAny> = [];
		var _loc7_:Array<ASAny> = [root];
		while (_loc7_.length > 0) {
			_loc3_ = ASCompat.dynamicAs(_loc7_.shift(), DisplayObject);
			_loc2_ = ASCompat.reinterpretAs(_loc3_, DisplayObjectContainer);
			if (_loc2_ == null) {
				_loc5_ = _loc3_.getBounds(root);
				_loc4_.push(ASCompat.floatToInt(_loc5_.width) + "x" + ASCompat.floatToInt(_loc5_.height));
			} else {
				_loc6_ = 0;
				while (_loc6_ < _loc2_.numChildren) {
					_loc7_.push(_loc2_.getChildAt(_loc6_));
					_loc6_++;
				}
			}
		}
		return _loc4_.join(", ");
	}

	public function setHighlightFilter(color:UInt, alpha:Float = 8, blur:Float = 2, quality:Float = 1) {
		if (mContainer == null) {
			return;
		}
		if (mHighlightFilter == null) {
			mHighlightFilter = new GlowFilter(color, alpha, blur, quality);
		} else {
			mHighlightFilter.color = color;
			mHighlightFilter.alpha = alpha;
			mHighlightFilter.blur = blur;
			mHighlightFilter.quality = quality;
		}
		updateFilters();
	}

	public function clearHighlightFilter() {
		var _loc1_:GlowFilter = null;
		if (mHighlightFilter != null) {
			_loc1_ = mHighlightFilter;
			mHighlightFilter = null;
			updateFilters();
			_loc1_.dispose();
		} else {
			updateFilters();
		}
	}

	public function setPersistentGlowFilter(color:UInt, alpha:Float = 8, blur:Float = 2, quality:Float = 1) {
		if (mContainer == null) {
			return;
		}
		if (mPersistentGlowFilter == null) {
			mPersistentGlowFilter = new GlowFilter(color, alpha, blur, quality);
		} else {
			mPersistentGlowFilter.color = color;
			mPersistentGlowFilter.alpha = alpha;
			mPersistentGlowFilter.blur = blur;
			mPersistentGlowFilter.quality = quality;
		}
		updateFilters();
	}

	public function clearPersistentGlowFilter() {
		var _loc1_:GlowFilter = null;
		if (mPersistentGlowFilter != null) {
			_loc1_ = mPersistentGlowFilter;
			mPersistentGlowFilter = null;
			updateFilters();
			_loc1_.dispose();
		} else {
			updateFilters();
		}
	}

	public function setColorFilter(matrix:Array<ASAny>) {
		var _loc2_ = 0;
		if (mContainer == null || matrix == null || matrix.length != 20) {
			return;
		}
		if (mColorMatrix == null) {
			mColorMatrix = new Vector<Float>((20 : UInt), true);
		}
		_loc2_ = 0;
		while (_loc2_ < 20) {
			mColorMatrix[_loc2_] = ASCompat.toNumber(matrix[_loc2_]);
			_loc2_++;
		}
		applyColorTransformToContent();
	}

	public function clearColorFilter() {
		if (mColorMatrix != null) {
			mColorMatrix = null;
			applyColorTransformToContent();
		}
	}

	public function setStatusTint(color:UInt, amount:Float) {
		if (mContainer == null) {
			return;
		}
		mStatusTint.set(color, amount);
		applyColorTransformToContent();
	}

	public function clearStatusTint() {
		mStatusTint.clear();
		applyColorTransformToContent();
	}

	function currentColorMatrix():Vector<Float> {
		var _loc1_ = mStatusTint.matrix;
		if (mColorMatrix == null) {
			return _loc1_;
		}
		if (_loc1_ == null) {
			return mColorMatrix;
		}
		return ColorTransformStyle.concat(mColorMatrix, _loc1_);
	}

	function applyColorTransformToContent() {
		if (mContainer == null) {
			return;
		}
		var _loc2_ = currentColorMatrix();
		var _loc1_ = ASCompat.reinterpretAs(mAnimations.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			ASCompat.dynamicAs(_loc1_.next(), Animation).setColorMatrix(_loc2_);
		}
		if (mMultiDirectionAnimation != null) {
			mMultiDirectionAnimation.setColorMatrix(_loc2_);
		}
		if (mOffImage != null) {
			ColorTransformStyle.setColorTransform(mOffImage, _loc2_);
		}
		if (mFrameImage != null) {
			ColorTransformStyle.setColorTransform(mFrameImage, _loc2_);
		}
		if (mStaticEnsemble != null) {
			ColorTransformStyle.applyTo(mStaticEnsemble, _loc2_);
		}
	}

	function updateFilters() {
		var _loc1_:FragmentFilter;
		if (mContainer == null) {
			return;
		}
		var _loc2_:Array<ASAny> = [];
		if (mPersistentGlowFilter != null) {
			_loc2_.push(mPersistentGlowFilter);
		}
		if (mHighlightFilter != null) {
			_loc2_.push(mHighlightFilter);
		}
		if (mFilterChain != null) {
			while (mFilterChain.numFilters > 0) {
				mFilterChain.removeFilterAt(0, false);
			}
		}
		if (_loc2_.length == 0) {
			mContainer.filter = null;
		} else if (_loc2_.length == 1) {
			mContainer.filter = ASCompat.coerce(_loc2_[0], starling.filters.FragmentFilter);
		} else {
			if (mFilterChain == null) {
				mFilterChain = new FilterChain();
			}
			if (checkNullIteratee(_loc2_))
				for (_tmp_ in _loc2_) {
					_loc1_ = ASCompat.coerce(_tmp_, starling.filters.FragmentFilter);
					mFilterChain.addFilter(_loc1_);
				}
			mContainer.filter = mFilterChain;
		}
	}

	public function destroy() {
		var _loc2_:Animation = null;
		leaveJuggler();
		mCurrentAnimation = null;
		var _loc1_ = ASCompat.reinterpretAs(mAnimations.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), Animation);
			_loc2_.stop();
			_loc2_.removeFromParent(true);
		}
		mAnimations.clear();
		mAnimations = null;
		mBaseFrameRates.clear();
		mBaseFrameRates = null;
		if (mOffImage != null) {
			mOffImage.removeFromParent();
			mOffImage = null;
		}
		if (mFrameImage != null) {
			mFrameImage.removeFromParent();
			mFrameImage = null;
		}
		if (mStaticEnsemble != null) {
			mStaticEnsemble.removeFromParent(true);
			mStaticEnsemble = null;
		}
		mContainer.filter = null;
		if (mFilterChain != null) {
			while (mFilterChain.numFilters > 0) {
				mFilterChain.removeFilterAt(0, false);
			}
			mFilterChain.dispose();
			mFilterChain = null;
		}
		mColorMatrix = null;
		mStatusTint.dispose();
		if (mHighlightFilter != null) {
			mHighlightFilter.dispose();
			mHighlightFilter = null;
		}
		if (mPersistentGlowFilter != null) {
			mPersistentGlowFilter.dispose();
			mPersistentGlowFilter = null;
		}
		mContainer.removeFromParent(true);
		mContainer = null;
		mContent = null;
		mDBFacade = null;
	}

	function deactivateCurrent() {
		if (mCurrentAnimation == null) {
			return;
		}
		mCurrentAnimation.removeEventListener("complete", onAnimationComplete);
		leaveJuggler();
		mCurrentAnimation.stop();
		mContent.removeChild(mCurrentAnimation);
		mCurrentAnimation = null;
	}

	function onAnimationComplete(event:Event) {
		var _loc2_ = ASCompat.reinterpretAs(event.target, Animation);
		if (_loc2_ != null) {
			_loc2_.removeEventListener("complete", onAnimationComplete);
			if (_loc2_ == mCurrentAnimation) {
				leaveJuggler();
			}
		}
	}

	function joinJuggler() {
		if (mCurrentAnimation == null || !mVisible || !mCurrentAnimation.isAnimating) {
			return;
		}
		if (mCulled && isLooping) {
			leaveJuggler();
			return;
		}
		if (!mDBFacade.starlingLayerManager.juggler.contains(mCurrentAnimation)) {
			mDBFacade.starlingLayerManager.juggler.add(mCurrentAnimation);
		}
	}

	@:isVar var isLooping(get, never):Bool;

	function get_isLooping():Bool {
		return mLoop && (mMultiDirectionMode || mCurrentAnimation.loop);
	}

	function leaveJuggler() {
		if (mCurrentAnimation == null || mDBFacade == null) {
			return;
		}
		mDBFacade.starlingLayerManager.juggler.remove(mCurrentAnimation);
	}

	static function __init__() {
		DIRECTION_LABELS = ["_angE", "_angD", "_angB"];
		FIVE_DIRECTION_LABELS = ["_angE", "_angD", "_angC", "_angB", "_angA"];
		sWarnedMissingLabels = {};
	}
}
