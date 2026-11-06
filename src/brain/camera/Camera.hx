package brain.camera;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.render.tweens.TweenHandle;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class Camera {
	static final sInverse:Matrix = new Matrix();

	var mTargetObject:DisplayObject;

	var mBounds:Rectangle;

	var mMaxZoom:Float = 10;

	var mMinZoom:Float = 0.01;

	var mZoom:Float = 1;

	var mRotation:Float = 0;

	var mTransformDirty:Bool = false;

	var mRootPosition:Vector3D = new Vector3D();

	var mPrevRootPosition:Vector3D = new Vector3D();

	var mRootTransform:Matrix = new Matrix();

	var mApplied:Matrix = new Matrix(0, 0, 0, 0);

	var mShakePosition:Vector3D = new Vector3D();

	var mShakeRotation:Float = 0;

	var mBackgroundFader:BackgroundFader;

	var mLetterboxEffect:LetterboxEffect;

	var mVisibleRect:Rectangle;

	var mCullRect:Rectangle = new Rectangle();

	var mHasCullRect:Bool = false;

	var mDefaultZoom:Float = Math.NaN;

	var mTweenZoom:TweenHandle;

	var mTweenRotation:TweenHandle;

	var mOffset:Point;

	var mYClippingFromBottom:UInt = 0;

	var mWantScrollRectCulling:Bool = false;

	var mFacade:Facade;

	public function new(facade:Facade, backgroundFader:BackgroundFader, letterboxEffect:LetterboxEffect) {
		mFacade = facade;
		mOffset = new Point();
		mBackgroundFader = backgroundFader;
		mLetterboxEffect = letterboxEffect;
	}

	public static function viewBoundsInWorld(cameraMatrix:Matrix, parentX:Float, parentY:Float, viewWidth:Float, viewHeight:Float, out:Rectangle) {
		var _loc14_ = 0;
		var _loc9_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		sInverse.copyFrom(cameraMatrix);
		sInverse.invert();
		var _loc15_ = Math.POSITIVE_INFINITY;
		var _loc13_ = Math.POSITIVE_INFINITY;
		var _loc12_ = Math.NEGATIVE_INFINITY;
		var _loc10_ = Math.NEGATIVE_INFINITY;
		_loc14_ = 0;
		while (_loc14_ < 4) {
			_loc9_ = ((_loc14_ & 1) != 0 ? viewWidth : 0) - parentX;
			_loc11_ = ((_loc14_ & 2) != 0 ? viewHeight : 0) - parentY;
			_loc7_ = sInverse.a * _loc9_ + sInverse.c * _loc11_ + sInverse.tx;
			_loc8_ = sInverse.b * _loc9_ + sInverse.d * _loc11_ + sInverse.ty;
			if (_loc7_ < _loc15_) {
				_loc15_ = _loc7_;
			}
			if (_loc7_ > _loc12_) {
				_loc12_ = _loc7_;
			}
			if (_loc8_ < _loc13_) {
				_loc13_ = _loc8_;
			}
			if (_loc8_ > _loc10_) {
				_loc10_ = _loc8_;
			}
			_loc14_++;
		}
		out.setTo(_loc15_, _loc13_, _loc12_ - _loc15_, _loc10_ - _loc13_);
	}

	public function destroy() {
		if (mTweenZoom != null) {
			mFacade.mTween.killTween(mTweenZoom);
		}
		if (mTweenRotation != null) {
			mFacade.mTween.killTween(mTweenRotation);
		}
		if (mBackgroundFader != null) {
			mBackgroundFader.forceStop();
			mBackgroundFader = null;
		}
		if (mLetterboxEffect != null) {
			mLetterboxEffect.forceStop();
			mLetterboxEffect = null;
		}
		if (mVisibleRect != null) {
			mVisibleRect = null;
		}
		mTargetObject = null;
	}

	public function removeShakes() {
		mShakePosition.x = mShakePosition.y = 0;
		mTransformDirty = false;
	}

	@:isVar public var bounds(get, set):Rectangle;

	public function set_bounds(bounds:Rectangle):Rectangle {
		return mBounds = bounds;
	}

	function get_bounds():Rectangle {
		return mBounds;
	}

	public function getDeltaToPoint(targetX:Float, targetY:Float):Vector3D {
		if (mWantScrollRectCulling) {
			return new Vector3D((-targetX - mRootPosition.x) / mZoom, (-targetY - mRootPosition.y) / mZoom);
		}
		return new Vector3D(-targetX - mRootPosition.x, -targetY - mRootPosition.y);
	}

	public function centerCameraOnPoint(focusPoint:Vector3D) {
		var _loc2_ = getDeltaToPoint(focusPoint.x, focusPoint.y);
		if (!_loc2_.equals(mRootPosition)) {
			mRootPosition = _loc2_;
			mPrevRootPosition.x = mRootPosition.x;
			mPrevRootPosition.y = mRootPosition.y;
			mTransformDirty = true;
		}
	}

	public function update(gameClock:GameClock = null) {
		var _loc4_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc3_ = Math.NaN;
		if (mTransformDirty && mTargetObject != null) {
			mRootTransform.identity();
			if (mWantScrollRectCulling) {
				mRootTransform.scale(mZoom, mZoom);
				mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
				mTargetObject.transform.matrix = mRootTransform;
				mTargetObject.x = -mFacade.viewWidth * 0.5;
				mTargetObject.y = -mFacade.viewHeight * 0.5;
				_loc4_ = Math.fround(-mRootPosition.x - mFacade.viewWidth / mZoom * 0.5);
				_loc2_ = Math.fround(-mRootPosition.y - mFacade.viewHeight / mZoom * 0.5 + mOffset.y / mZoom);
				_loc5_ = Math.fround(mFacade.viewWidth / mZoom);
				_loc3_ = Math.fround(mFacade.viewHeight / mZoom - mYClippingFromBottom / mZoom);
				mTargetObject.scrollRect = new Rectangle(_loc4_, _loc2_, _loc5_, _loc3_);
			} else {
				mRootTransform.translate(mRootPosition.x + mOffset.x + mShakePosition.x, mRootPosition.y + mOffset.y + mShakePosition.y);
				mRootTransform.scale(mZoom, mZoom);
				mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
				mTargetObject.transform.matrix = mRootTransform;
			}
			mTransformDirty = false;
			mApplied.setTo(0, 0, 0, 0, 0, 0);
		}
	}

	public function beginTick() {
		mPrevRootPosition.x = mRootPosition.x;
		mPrevRootPosition.y = mRootPosition.y;
	}

	public function renderInterpolated(alpha:Float) {
		var _loc7_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc5_ = Math.NaN;
		if (mTargetObject == null) {
			return;
		}
		var _loc2_ = mPrevRootPosition.x + (mRootPosition.x - mPrevRootPosition.x) * alpha;
		var _loc3_ = mPrevRootPosition.y + (mRootPosition.y - mPrevRootPosition.y) * alpha;
		mRootTransform.identity();
		if (mWantScrollRectCulling) {
			mRootTransform.scale(mZoom, mZoom);
			mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
			mTargetObject.transform.matrix = mRootTransform;
			mTargetObject.x = -mFacade.viewWidth * 0.5;
			mTargetObject.y = -mFacade.viewHeight * 0.5;
			_loc7_ = Math.fround(-_loc2_ - mFacade.viewWidth / mZoom * 0.5);
			_loc4_ = Math.fround(-_loc3_ - mFacade.viewHeight / mZoom * 0.5 + mOffset.y / mZoom);
			_loc9_ = Math.fround(mFacade.viewWidth / mZoom);
			_loc6_ = Math.fround(mFacade.viewHeight / mZoom - mYClippingFromBottom / mZoom);
			mTargetObject.scrollRect = new Rectangle(_loc7_, _loc4_, _loc9_, _loc6_);
			mApplied.setTo(0, 0, 0, 0, 0, 0);
		} else {
			mRootTransform.translate(_loc2_ + mOffset.x + mShakePosition.x, _loc3_ + mOffset.y + mShakePosition.y);
			mRootTransform.scale(mZoom, mZoom);
			mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
			if (!sameAsApplied()) {
				mTargetObject.transform.matrix = mRootTransform;
				mApplied.copyFrom(mRootTransform);
			}
		}
		mTransformDirty = false;
		mHasCullRect = mWantScrollRectCulling || mTargetObject.parent != null;
		if (!mHasCullRect) {
			return;
		}
		if (mWantScrollRectCulling) {
			mCullRect.copyFrom(visibleRectangle);
			_loc8_ = Math.abs(Math.sin((mRotation + mShakeRotation) * 3.141592653589793 / 180));
			if (_loc8_ > 0) {
				_loc5_ = 0.5 * (mCullRect.width + mCullRect.height) * _loc8_;
				mCullRect.inflate(_loc5_, _loc5_);
			}
		} else {
			viewBoundsInWorld(mRootTransform, mTargetObject.parent.x, mTargetObject.parent.y, mFacade.viewWidth, mFacade.viewHeight, mCullRect);
		}
	}

	public function isInCullView(x:Float, y:Float, margin:Float):Bool {
		if (!mHasCullRect) {
			return true;
		}
		return x >= mCullRect.x - margin
			&& x <= mCullRect.x + mCullRect.width + margin
			&& y >= mCullRect.y - margin
			&& y <= mCullRect.y + mCullRect.height + margin;
	}

	function sameAsApplied():Bool {
		return mApplied.a == mRootTransform.a && mApplied.b == mRootTransform.b && mApplied.c == mRootTransform.c && mApplied.d == mRootTransform.d
			&& mApplied.tx == mRootTransform.tx && mApplied.ty == mRootTransform.ty;
	}

	public function translateTo(point:Vector3D) {
		mRootPosition = point;
		mPrevRootPosition.x = mRootPosition.x;
		mPrevRootPosition.y = mRootPosition.y;
		mTransformDirty = true;
	}

	public function translateBy(dx:Float, dy:Float) {
		mRootPosition.x += dx;
		mRootPosition.y += dy;
		mTransformDirty = true;
	}

	@:isVar public var targetObject(get, set):DisplayObject;

	public function set_targetObject(target:DisplayObject):DisplayObject {
		mTargetObject = target;
		mHasCullRect = false;
		mApplied.setTo(0, 0, 0, 0, 0, 0);
		return target;
	}

	function get_targetObject():DisplayObject {
		return mTargetObject;
	}

	@:isVar public var rotation(get, set):Float;

	public function set_rotation(value:Float):Float {
		mRotation = value;
		mTransformDirty = true;
		return value;
	}

	function get_rotation():Float {
		return mRotation;
	}

	@:isVar public var _shakeRotation(get, set):Float;

	public function set__shakeRotation(value:Float):Float {
		mShakeRotation = value;
		mTransformDirty = true;
		return value;
	}

	function get__shakeRotation():Float {
		return mShakeRotation;
	}

	@:isVar public var _shakeX(get, set):Float;

	public function set__shakeX(value:Float):Float {
		mShakePosition.x = value;
		mTransformDirty = true;
		return value;
	}

	@:isVar public var _shakeY(get, set):Float;

	public function set__shakeY(value:Float):Float {
		mShakePosition.y = value;
		mTransformDirty = true;
		return value;
	}

	function get__shakeX():Float {
		return mShakePosition.x;
	}

	function get__shakeY():Float {
		return mShakePosition.y;
	}

	public function tweenRotation(duration:Float, value:Float) {
		if (mTweenRotation != null) {
			mFacade.mTween.killTween(mTweenRotation);
		}
		if (mFacade.featureFlags.getFlagValue("want-zoom")) {
			mTweenRotation = mFacade.mTween.tweenLiteTo(this, duration, {"rotation": value});
		}
	}

	@:isVar public var zoom(get, set):Float;

	public function set_zoom(value:Float):Float {
		if (mFacade.featureFlags.getFlagValue("want-zoom")) {
			value = Math.min(mMaxZoom, Math.max(mMinZoom, value));
			if (mZoom == value) {
				return value;
			}
			mZoom = value;
			mTransformDirty = true;
		}
		return value;
	}

	function get_zoom():Float {
		return mZoom;
	}

	public function killTweenZooms() {
		if (mTweenZoom != null) {
			mFacade.mTween.killTween(mTweenZoom);
			mTweenZoom = null;
		}
	}

	function shakeFunction(createTween:ASFunction, duration:Float, strength:Float, numShakes:UInt):TweenHandle {
		var _loc6_ = Math.NaN;
		var _loc8_ = (0 : UInt);
		var _loc7_ = mFacade.mTween.createTimeline();
		var _loc5_ = duration / numShakes;
		_loc8_ = (0 : UInt);
		while (_loc8_ < numShakes) {
			strength = -strength;
			_loc6_ = _loc8_ == 0 ? _loc5_ * 0.5 : _loc5_;
			mFacade.mTween.appendTween(_loc7_, ASCompat.coerce(createTween(_loc6_, strength), brain.render.tweens.TweenHandle));
			_loc8_++;
		}
		mFacade.mTween.appendTween(_loc7_, ASCompat.coerce(createTween(_loc5_ * 0.5, 0), brain.render.tweens.TweenHandle));
		return _loc7_;
	}

	public function shakeRotation(duration:Float, strength:Float, numShakes:UInt):TweenHandle {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenHandle {
			return mFacade.mTween.tweenMaxTo(self, param1, {
				"_shakeRotation": param2,
				"onUpdate": update
			});
		};
		return this.shakeFunction(createTween, duration, strength, numShakes);
	}

	public function shakeX(duration:Float, strength:Float, numShakes:UInt):TweenHandle {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenHandle {
			return mFacade.mTween.tweenMaxTo(self, param1, {
				"_shakeX": param2,
				"onUpdate": update
			});
		};
		return this.shakeFunction(createTween, duration, strength, numShakes);
	}

	public function shakeY(duration:Float, strength:Float, numShakes:UInt):TweenHandle {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenHandle {
			return mFacade.mTween.tweenMaxTo(self, param1, {
				"_shakeY": param2,
				"onUpdate": update
			});
		};
		return this.shakeFunction(createTween, duration, strength, numShakes);
	}

	@:isVar public var defaultZoom(get, set):Float;

	public function set_defaultZoom(defaultZoom:Float):Float {
		return mDefaultZoom = defaultZoom;
	}

	function get_defaultZoom():Float {
		return mDefaultZoom;
	}

	public function tweenToDefaultZoom(duration:Float):TweenHandle {
		return tweenZoom(duration, defaultZoom);
	}

	public function tweenZoom(duration:Float, value:Float, setAsDefault:Bool = false):TweenHandle {
		if (setAsDefault) {
			mDefaultZoom = value;
		}
		killTweenZooms();
		mTweenZoom = mFacade.mTween.tweenMaxTo(this, duration, {
			"zoom": value,
			"onUpdate": update
		});
		return mTweenZoom;
	}

	public function fadeBackground(excludes:Array<ASAny>, duration:UInt, transitionDur:Float, color:Vector3D, alpha:Float) {
		mBackgroundFader.doFade(excludes, duration, transitionDur, color, alpha);
	}

	public function doLetterboxEffect(duration:UInt, transitionDur:Float, color:Vector3D, alpha:Float) {
		mLetterboxEffect.doFade(duration, transitionDur, color, alpha);
	}

	@:isVar public var backgroundFadeAlpha(get, never):Float;

	public function get_backgroundFadeAlpha():Float {
		return mBackgroundFader != null ? mBackgroundFader.alpha : 0;
	}

	@:isVar public var backgroundFadeColor(get, never):UInt;

	public function get_backgroundFadeColor():UInt {
		return mBackgroundFader != null ? mBackgroundFader.color : (0 : UInt);
	}

	public function killBackgroundFader() {
		mBackgroundFader.forceStop();
	}

	public function killLetterboxEffect() {
		mLetterboxEffect.forceStop();
	}

	@:isVar public var rootPosition(get, never):Vector3D;

	public function get_rootPosition():Vector3D {
		return mRootPosition;
	}

	@:isVar public var visibleRectangle(get, never):Rectangle;

	public function get_visibleRectangle():Rectangle {
		var _loc3_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc1_ = Math.NaN;
		if (mWantScrollRectCulling) {
			_loc3_ = mFacade.viewWidth / mZoom;
			_loc4_ = mFacade.viewHeight / mZoom;
			_loc2_ = -mRootPosition.x - _loc3_ * 0.5 + mOffset.x / mZoom;
			_loc1_ = -mRootPosition.y - _loc4_ * 0.5 + mOffset.y / mZoom;
		} else {
			_loc2_ = (-mTargetObject.x - mTargetObject.parent.x) / mZoom;
			_loc1_ = (-mTargetObject.y - mTargetObject.parent.y) / mZoom;
			_loc3_ = mFacade.viewWidth / mZoom;
			_loc4_ = mFacade.viewHeight / mZoom;
		}
		if (mVisibleRect == null) {
			mVisibleRect = new Rectangle(_loc2_, _loc1_, _loc3_, _loc4_);
		} else {
			mVisibleRect.setTo(_loc2_, _loc1_, _loc3_, _loc4_);
		}
		return mVisibleRect;
	}

	public function isPointOnScreen(position:Vector3D):Bool {
		return this.visibleRectangle.contains(position.x, position.y);
	}

	@:isVar public var offset(get, set):Point;

	public function get_offset():Point {
		return mOffset;
	}

	function set_offset(val:Point):Point {
		return mOffset = val;
	}

	@:isVar public var yCilppingFromBottom(get, set):Float;

	public function get_yCilppingFromBottom():Float {
		return mYClippingFromBottom;
	}

	function set_yCilppingFromBottom(val:Float):Float {
		mYClippingFromBottom = (ASCompat.floatToInt(val) : UInt);
		return val;
	}

	public function forceRedraw() {
		mPrevRootPosition.x = mRootPosition.x;
		mPrevRootPosition.y = mRootPosition.y;
		mTransformDirty = true;
		update(null);
	}

	public function getWorldCoordinateFromMouse(mouseX:Float, mouseY:Float):Vector3D {
		return new Vector3D(mouseX / zoom + visibleRectangle.x, mouseY / zoom + visibleRectangle.y);
	}
}
