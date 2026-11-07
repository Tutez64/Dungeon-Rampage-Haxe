package uI.hud.starlingConverted;

import actor.ChatBalloonOverlay;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Mesh;

class StarlingWorldCut {
	static inline final FAR:Float = 100000;

	static inline final GRID:Float = 4;

	final mBounds:Rectangle = new Rectangle();

	final mMatrix:Matrix = new Matrix();

	var mChatOverlay:ChatBalloonOverlay;

	var mWorld:flash.display.DisplayObject;

	var mHud:DisplayObject;

	var mMask:Shape;

	var mOn:Bool = false;

	var mDirty:Bool = true;

	var mDynamicDirty:Bool = true;

	var mStaticRects:Vector<Float> = new Vector((0 : UInt));

	var mStaticCount:Int = 0;

	var mDynamic:Vector<DisplayObject> = new Vector((0 : UInt));

	var mDynamicSet:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mRects:Vector<Float> = new Vector((0 : UInt));

	var mDrawn:Vector<Float> = new Vector((0 : UInt));

	var mCount:Int = 0;

	var mDrawnCount:Int = -1;

	var mYs:Vector<Float> = new Vector((0 : UInt));

	var mSpans:Vector<Float> = new Vector((0 : UInt));

	final mFade:HudCutFade = new HudCutFade();

	final mPixels:Vector<Float> = new Vector((0 : UInt));

	final mDevice:Matrix = new Matrix();

	public function new(world:flash.display.DisplayObject, designSpace:flash.display.DisplayObjectContainer, hud:DisplayObject,
			fadeLayer:flash.display.DisplayObject = null) {
		mWorld = world;
		mHud = hud;
		mMask = new Shape();
		mMask.name = "StarlingWorldCut";
		mMask.visible = false;
		designSpace.addChildAt(mMask, 0);
		mChatOverlay = new ChatBalloonOverlay(ASCompat.reinterpretAs(world, flash.display.DisplayObjectContainer), designSpace, fadeLayer);
	}

	@:isVar public var enabled(get, set):Bool;

	public function set_enabled(on:Bool):Bool {
		if (on == mOn) {
			return on;
		}
		mOn = on;
		mDrawnCount = -1;
		mDirty = true;
		if (!on) {
			mChatOverlay.update(false);
			useMask(false);
			mMask.graphics.clear();
			mFade.clear();
			mFade.hide();
			return on;
		}
		update();
		return on;
	}

	function useMask(on:Bool) {
		var _loc2_ = on ? mMask : null;
		if (mWorld.mask == _loc2_) {
			return;
		}
		mWorld.mask = _loc2_;
		mMask.visible = on;
	}

	function get_enabled():Bool {
		return mOn;
	}

	public function invalidate() {
		mDirty = true;
	}

	@:allow(uI.hud.starlingConverted) function invalidateDynamic() {
		mDynamicDirty = true;
	}

	@:allow(uI.hud.starlingConverted) function addDynamic(node:DisplayObject) {
		mDynamic.push(node);
		mDynamicSet[node] = true;
		mDirty = mDynamicDirty = true;
	}

	@:allow(uI.hud.starlingConverted) function removeDynamic(node:DisplayObject) {
		var _loc2_ = mDynamic.indexOf(node);
		if (_loc2_ >= 0) {
			mDynamic.removeAt(_loc2_);
		}
		mDynamicSet.remove(node);
		mDirty = mDynamicDirty = true;
	}

	public function update() {
		var _loc4_ = 0;
		var _loc5_:DisplayObject = null;
		var _loc3_:DisplayObject = null;
		var _loc6_ = false;
		var _loc2_ = mFade.designMoved(mMask);
		if (!mDirty && !mDynamicDirty && !_loc2_) {
			return;
		}
		if (!mOn || mHud.stage == null) {
			return;
		}
		if (mDirty) {
			mCount = 0;
			collect(mHud);
			mStaticCount = mCount;
			_loc4_ = 0;
			while (_loc4_ < mCount) {
				mStaticRects[_loc4_] = mRects[_loc4_];
				_loc4_++;
			}
			mDirty = false;
		}
		mDynamicDirty = false;
		mCount = mStaticCount;
		_loc4_ = 0;
		while (_loc4_ < mCount) {
			mRects[_loc4_] = mStaticRects[_loc4_];
			_loc4_++;
		}
		final __ax4_iter_187 = mDynamic;
		if (checkNullIteratee(__ax4_iter_187))
			for (_tmp_ in __ax4_iter_187) {
				_loc5_ = _tmp_;
				_loc6_ = true;
				_loc3_ = _loc5_;
				while (_loc3_ != null) {
					if (!_loc3_.visible || _loc3_.alpha <= 0) {
						_loc6_ = false;
						break;
					}
					_loc3_ = _loc3_.parent;
				}
				if (_loc6_) {
					collectLive(_loc5_);
				}
			}
		if (!_loc2_ && same()) {
			return;
		}
		draw();
		useMask(mCount > 0);
		var _loc1_ = mDrawn;
		mDrawn = mRects;
		mRects = _loc1_;
		mDrawnCount = mCount;
	}

	public function syncChatOverlay(fadeAlpha:Float = 0, fadeColor:UInt = (0 : UInt)) {
		if (mChatOverlay != null) {
			mChatOverlay.update(mOn && mHud.stage != null && mWorld.mask == mMask, fadeAlpha, fadeColor);
		}
	}

	public function fade(alpha:Float, color:UInt) {
		if (mOn && mHud != null) {
			mFade.sync(mHud, mHud, alpha, color);
		} else {
			mFade.hide();
		}
	}

	public function dispose() {
		if (mChatOverlay != null) {
			mChatOverlay.dispose();
		}
		mChatOverlay = null;
		mFade.dispose();
		if (mWorld != null && mWorld.mask == mMask) {
			mWorld.mask = null;
		}
		if (mMask != null && mMask.parent != null) {
			mMask.parent.removeChild(mMask);
		}
		mMask = null;
		mWorld = null;
		mHud = null;
		mOn = false;
	}

	function collect(node:DisplayObject) {
		var _loc6_:Rectangle = null;
		var _loc5_ = 0;
		var _loc7_:BakedCell = null;
		if (!node.visible || ArtDisplay.isClipMask(node) || node.alpha <= 0 || ASCompat.toBool(mDynamicSet[node])) {
			return;
		}
		var _loc3_ = ASCompat.reinterpretAs(node, ArtDisplay);
		if (_loc3_ != null && _loc3_.mask != null && !ArtDisplay.isClipMask(_loc3_.mask)) {
			_loc3_.mask.getBounds(mHud, mBounds);
			appendBounds();
			return;
		}
		if (_loc3_ != null && _loc3_.art.kind == "text") {
			collectLive(_loc3_);
			return;
		}
		if (_loc3_ != null && _loc3_.art.kind != "container" && _loc3_.art.maximalBounds != null) {
			_loc6_ = _loc3_.art.maximalBounds;
			_loc3_.getTransformationMatrix(mHud, mMatrix);
			boundsOf(_loc6_.left, _loc6_.top, _loc6_.right, _loc6_.bottom);
			appendBounds();
			collectLive(_loc3_);
			return;
		}
		var _loc4_ = ASCompat.reinterpretAs(node, starling.display.DisplayObjectContainer);
		if (_loc4_ != null) {
			_loc5_ = 0;
			while (_loc5_ < _loc4_.numChildren) {
				collect(_loc4_.getChildAt(_loc5_));
				_loc5_++;
			}
			return;
		}
		var _loc8_ = ASCompat.reinterpretAs(node, Mesh);
		if (_loc8_ == null || _loc8_.texture == null || _loc8_.numVertices == 0) {
			return;
		}
		var _loc2_ = ASCompat.reinterpretAs(node, BakedImage);
		if (_loc2_ != null) {
			_loc7_ = _loc2_.cell;
			if (_loc7_ == null || !_loc7_.alive || _loc7_.isEmpty) {
				return;
			}
			_loc2_.getTransformationMatrix(mHud, mMatrix);
			boundsOf(0, 0, _loc7_.pixelWidth / _loc7_.pixelScale, _loc7_.pixelHeight / _loc7_.pixelScale);
		} else {
			_loc8_.getBounds(mHud, mBounds);
		}
		appendBounds();
	}

	function collectLive(node:DisplayObject) {
		var _loc4_ = 0;
		if (!node.visible || ArtDisplay.isClipMask(node) || node.alpha <= 0 || node.scaleX == 0 || node.scaleY == 0) {
			return;
		}
		if (node.mask != null && !ArtDisplay.isClipMask(node.mask)) {
			node.mask.getBounds(mHud, mBounds);
			appendBounds();
			return;
		}
		var _loc2_ = ASCompat.reinterpretAs(node, starling.display.DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc2_.numChildren) {
				collectLive(_loc2_.getChildAt(_loc4_));
				_loc4_++;
			}
			return;
		}
		var _loc5_ = ASCompat.reinterpretAs(node, Mesh);
		var _loc3_ = ASCompat.reinterpretAs(node, BakedImage);
		if (_loc5_ == null || _loc5_.texture == null || _loc5_.numVertices == 0) {
			return;
		}
		if (_loc3_ != null && (_loc3_.cell == null || !_loc3_.cell.alive || _loc3_.cell.isEmpty)) {
			return;
		}
		_loc5_.getBounds(mHud, mBounds);
		appendBounds();
	}

	function appendBounds() {
		if (!(mBounds.width > 0 && mBounds.height > 0)) {
			return;
		}
		mRects[mCount++] = Math.ffloor(mBounds.left / 4) * 4;
		mRects[mCount++] = Math.ffloor(mBounds.top / 4) * 4;
		mRects[mCount++] = Math.fceil(mBounds.right / 4) * 4;
		mRects[mCount++] = Math.fceil(mBounds.bottom / 4) * 4;
	}

	function boundsOf(left:Float, top:Float, right:Float, bottom:Float) {
		var _loc5_ = mMatrix;
		var _loc9_ = _loc5_.a * left + _loc5_.c * top + _loc5_.tx;
		var _loc8_ = _loc5_.b * left + _loc5_.d * top + _loc5_.ty;
		var _loc11_ = _loc5_.a * right + _loc5_.c * top + _loc5_.tx;
		var _loc10_ = _loc5_.b * right + _loc5_.d * top + _loc5_.ty;
		var _loc13_ = _loc5_.a * left + _loc5_.c * bottom + _loc5_.tx;
		var _loc12_ = _loc5_.b * left + _loc5_.d * bottom + _loc5_.ty;
		var _loc15_ = _loc5_.a * right + _loc5_.c * bottom + _loc5_.tx;
		var _loc14_ = _loc5_.b * right + _loc5_.d * bottom + _loc5_.ty;
		var _loc7_ = Math.min(Math.min(_loc9_, _loc11_), Math.min(_loc13_, _loc15_));
		var _loc6_ = Math.min(Math.min(_loc8_, _loc10_), Math.min(_loc12_, _loc14_));
		mBounds.setTo(_loc7_, _loc6_, Math.max(Math.max(_loc9_, _loc11_), Math.max(_loc13_, _loc15_)) - _loc7_,
			Math.max(Math.max(_loc8_, _loc10_), Math.max(_loc12_, _loc14_)) - _loc6_);
	}

	function same():Bool {
		var _loc1_ = 0;
		if (mCount != mDrawnCount) {
			return false;
		}
		_loc1_ = 0;
		while (_loc1_ < mCount) {
			if (mRects[_loc1_] != mDrawn[_loc1_]) {
				return false;
			}
			_loc1_++;
		}
		return true;
	}

	function draw() {
		var _loc4_:Float;
		var _loc8_ = 0;
		var _loc2_ = 0;
		var _loc3_ = Math.NaN;
		var _loc1_ = 0;
		var _loc7_ = Math.NaN;
		var _loc10_ = Math.NaN;
		mFade.remember(mMask);
		var _loc5_ = mMask.graphics;
		_loc5_.clear();
		_loc5_.beginFill((0 : UInt));
		mFade.clear();
		var _loc6_ = HudCutFade.toDevicePixels(mRects, mCount, mPixels, HudCutFade.stageMatrix(mMask, mDevice));
		var _loc9_ = 0;
		_loc8_ = 0;
		while (_loc8_ < mCount) {
			mYs[_loc9_++] = _loc6_[_loc8_ + 1];
			mYs[_loc9_++] = _loc6_[_loc8_ + 3];
			_loc8_ += 4;
		}
		mYs[_loc9_++] = -100000;
		mYs[_loc9_++] = 100000;
		mYs.length = _loc9_;
		sortYs();
		_loc2_ = 0;
		while (_loc2_ + 1 < _loc9_) {
			_loc3_ = mYs[_loc2_];
			_loc4_ = mYs[_loc2_ + 1];
			if (_loc4_ > _loc3_) {
				_loc1_ = 0;
				_loc8_ = 0;
				while (_loc8_ < mCount) {
					if (_loc6_[_loc8_ + 1] <= _loc3_ && _loc6_[_loc8_ + 3] >= _loc4_) {
						mSpans[_loc1_++] = _loc6_[_loc8_];
						mSpans[_loc1_++] = _loc6_[_loc8_ + 2];
					}
					_loc8_ += 4;
				}
				sortSpans(_loc1_);
				_loc7_ = -100000;
				_loc10_ = -100000;
				_loc8_ = 0;
				while (_loc8_ < _loc1_) {
					if (mSpans[_loc8_] > _loc7_) {
						if (_loc10_ > -100000) {
							mFade.add(_loc10_, _loc3_, _loc7_, _loc4_);
						}
						_loc5_.drawRect(_loc7_, _loc3_, mSpans[_loc8_] - _loc7_, _loc4_ - _loc3_);
						_loc10_ = mSpans[_loc8_];
					}
					if (mSpans[_loc8_ + 1] > _loc7_) {
						_loc7_ = mSpans[_loc8_ + 1];
					}
					_loc8_ += 2;
				}
				if (_loc10_ > -100000) {
					mFade.add(_loc10_, _loc3_, _loc7_, _loc4_);
				}
				_loc5_.drawRect(_loc7_, _loc3_, 100000 - _loc7_, _loc4_ - _loc3_);
			}
			_loc2_++;
		}
		_loc5_.endFill();
	}

	function sortYs() {
		var _loc1_ = 0;
		var _loc2_ = Math.NaN;
		var _loc3_ = 0;
		_loc1_ = 1;
		while (_loc1_ < mYs.length) {
			_loc2_ = mYs[_loc1_];
			_loc3_ = _loc1_ - 1;
			while (_loc3_ >= 0 && mYs[_loc3_] > _loc2_) {
				mYs[_loc3_ + 1] = mYs[_loc3_];
				_loc3_--;
			}
			mYs[_loc3_ + 1] = _loc2_;
			_loc1_++;
		}
	}

	function sortSpans(count:Int) {
		var _loc2_:Float;
		var _loc3_ = 0;
		var _loc5_ = Math.NaN;
		var _loc4_ = 0;
		_loc3_ = 2;
		while (_loc3_ < count) {
			_loc5_ = mSpans[_loc3_];
			_loc2_ = mSpans[_loc3_ + 1];
			_loc4_ = _loc3_ - 2;
			while (_loc4_ >= 0 && mSpans[_loc4_] > _loc5_) {
				mSpans[_loc4_ + 2] = mSpans[_loc4_];
				mSpans[_loc4_ + 3] = mSpans[_loc4_ + 1];
				_loc4_ -= 2;
			}
			mSpans[_loc4_ + 2] = _loc5_;
			mSpans[_loc4_ + 3] = _loc2_;
			_loc3_ += 2;
		}
	}
}
