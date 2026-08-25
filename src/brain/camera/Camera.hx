package brain.camera;

import brain.clock.GameClock;
import brain.facade.Facade;
import com.greensock.TimelineMax;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class Camera {
	var mTargetObject:DisplayObject;

	var mBounds:Rectangle;

	var mMaxZoom:Float = 10;

	var mMinZoom:Float = 0.01;

	var mZoom:Float = 1;

	var mRotation:Float = 0;

	var mTransformDirty:Bool = false;

	var mRootPosition:Vector3D = new Vector3D();

	var mRootTransform:Matrix = new Matrix();

	var mShakePosition:Vector3D = new Vector3D();

	var mShakeRotation:Float = 0;

	var mBackgroundFader:BackgroundFader;

	var mLetterboxEffect:LetterboxEffect;

	var mVisibleRect:Rectangle;

	var mDefaultZoom:Float = Math.NaN;

	var mTweenZoom:TweenLite;

	var mTweenRotation:TweenLite;

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

	public function destroy() {
		if (mTweenZoom != null) {
			mTweenZoom.kill();
		}
		if (mTweenRotation != null) {
			mTweenRotation.kill();
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
		}
	}

	public function translateTo(point:Vector3D) {
		mRootPosition = point;
		mTransformDirty = true;
	}

	public function translateBy(dx:Float, dy:Float) {
		mRootPosition.x += dx;
		mRootPosition.y += dy;
		mTransformDirty = true;
	}

	@:isVar public var targetObject(get, set):DisplayObject;

	public function set_targetObject(target:DisplayObject):DisplayObject {
		return mTargetObject = target;
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
			mTweenRotation.kill();
		}
		if (mFacade.featureFlags.getFlagValue("want-zoom")) {
			mTweenRotation = TweenLite.to(this, duration, {"rotation": value});
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
			mTweenZoom.kill();
			mTweenZoom = null;
		}
	}

	function shakeFunction(createTween:ASFunction, duration:Float, strength:Float, numShakes:UInt):TimelineMax {
		var _loc6_ = Math.NaN;
		var _loc8_ = 0;
		var _loc7_ = new TimelineMax();
		var _loc5_ = duration / numShakes;
		_loc8_ = 0;
		while ((_loc8_ : UInt) < numShakes) {
			strength = -strength;
			_loc6_ = _loc8_ == 0 ? _loc5_ * 0.5 : _loc5_;
			_loc7_.append(ASCompat.dynamicAs(createTween(_loc6_, strength), com.greensock.core.TweenCore));
			_loc8_ = ASCompat.toInt(_loc8_) + 1;
		}
		_loc7_.append(ASCompat.dynamicAs(createTween(_loc5_ * 0.5, 0), com.greensock.core.TweenCore));
		return _loc7_;
	}

	public function shakeRotation(duration:Float, strength:Float, numShakes:UInt):TimelineMax {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax {
			return new TweenMax(self, param1, {
				"_shakeRotation": param2,
				"onUpdate": update
			});
		};
		return this.shakeFunction(createTween, duration, strength, numShakes);
	}

	public function shakeX(duration:Float, strength:Float, numShakes:UInt):TimelineMax {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax {
			return new TweenMax(self, param1, {
				"_shakeX": param2,
				"onUpdate": update
			});
		};
		return this.shakeFunction(createTween, duration, strength, numShakes);
	}

	public function shakeY(duration:Float, strength:Float, numShakes:UInt):TimelineMax {
		var self = this;
		var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax {
			return new TweenMax(self, param1, {
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

	public function tweenToDefaultZoom(duration:Float):TweenLite {
		return tweenZoom(duration, defaultZoom);
	}

	public function tweenZoom(duration:Float, value:Float, setAsDefault:Bool = false):TweenLite {
		if (setAsDefault) {
			mDefaultZoom = value;
		}
		killTweenZooms();
		mTweenZoom = TweenMax.to(this, duration, {
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
		mYClippingFromBottom = (Std.int(val) : UInt);
		return val;
	}

	public function forceRedraw() {
		mTransformDirty = true;
		update(null);
	}

	public function getWorldCoordinateFromMouse(mouseX:Float, mouseY:Float):Vector3D {
		return new Vector3D(mouseX / zoom + visibleRectangle.x, mouseY / zoom + visibleRectangle.y);
	}
}
