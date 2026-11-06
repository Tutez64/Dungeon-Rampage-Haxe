package uI.hud.starlingConverted;

import flash.display.DisplayObject;
import flash.geom.Matrix;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;

class HudCutFade {
	static inline final EPSILON:Float = 0.0001;

	var mHoles:Vector<Float> = new Vector((0 : UInt));

	var mCount:Int = 0;

	var mBuilt:Bool = false;

	var mColor:UInt = 0;

	var mWash:Sprite;

	final mQuads:Vector<Quad> = new Vector((0 : UInt));

	final mMatrix:Matrix = new Matrix();

	var mDesignX:Float = Math.NaN;

	var mDesignY:Float = Math.NaN;

	var mDesignScaleX:Float = Math.NaN;

	var mDesignScaleY:Float = Math.NaN;

	public function new() {}

	public static function toDevicePixels(rects:Vector<Float>, count:Int, out:Vector<Float>, device:Matrix):Vector<Float> {
		var _loc9_ = 0;
		var _loc7_ = device.a;
		var _loc8_ = device.d;
		var _loc5_ = device.tx;
		var _loc6_ = device.ty;
		var _loc10_ = _loc7_ > 0 && _loc8_ > 0 && device.b == 0 && device.c == 0;
		_loc9_ = 0;
		while (_loc9_ < count) {
			if (!_loc10_) {
				out[_loc9_] = rects[_loc9_];
				out[_loc9_ + 1] = rects[_loc9_ + 1];
				out[_loc9_ + 2] = rects[_loc9_ + 2];
				out[_loc9_ + 3] = rects[_loc9_ + 3];
			} else {
				out[_loc9_] = (Math.ffloor(rects[_loc9_] * _loc7_ + _loc5_ + 0.0001) - _loc5_) / _loc7_;
				out[_loc9_ + 1] = (Math.ffloor(rects[_loc9_ + 1] * _loc8_ + _loc6_ + 0.0001) - _loc6_) / _loc8_;
				out[_loc9_ + 2] = (Math.fceil(rects[_loc9_ + 2] * _loc7_ + _loc5_ - 0.0001) - _loc5_) / _loc7_;
				out[_loc9_ + 3] = (Math.fceil(rects[_loc9_ + 3] * _loc8_ + _loc6_ - 0.0001) - _loc6_) / _loc8_;
			}
			_loc9_ += 4;
		}
		return out;
	}

	public static function stageMatrix(node:flash.display.DisplayObject, out:Matrix):Matrix {
		out.identity();
		while (node != null) {
			out.concat(node.transform.matrix);
			node = node.parent;
		}
		return out;
	}

	public function designMoved(mask:flash.display.DisplayObject):Bool {
		var _loc2_:flash.display.DisplayObject = mask != null ? mask.parent : null;
		return _loc2_ != null
			&& (_loc2_.x != mDesignX || _loc2_.y != mDesignY || _loc2_.scaleX != mDesignScaleX || _loc2_.scaleY != mDesignScaleY);
	}

	public function remember(mask:flash.display.DisplayObject) {
		var _loc2_:flash.display.DisplayObject = mask != null ? mask.parent : null;
		if (_loc2_ == null) {
			return;
		}
		mDesignX = _loc2_.x;
		mDesignY = _loc2_.y;
		mDesignScaleX = _loc2_.scaleX;
		mDesignScaleY = _loc2_.scaleY;
	}

	public function clear() {
		mCount = 0;
		mBuilt = false;
	}

	public function add(left:Float, top:Float, right:Float, bottom:Float) {
		mHoles[mCount++] = left;
		mHoles[mCount++] = top;
		mHoles[mCount++] = right;
		mHoles[mCount++] = bottom;
		mBuilt = false;
	}

	public function sync(hud:DisplayObject, space:DisplayObject, alpha:Float, color:UInt) {
		var _loc5_ = hud.parent;
		if (alpha <= 0 || mCount == 0 || _loc5_ == null || space == null) {
			hide();
			return;
		}
		if (mWash == null) {
			mWash = new Sprite();
			mWash.name = "HudCutFade";
			mWash.touchable = false;
		}
		if (!mBuilt || color != mColor) {
			build(color);
		}
		if (mWash.parent != _loc5_ || _loc5_.getChildIndex(mWash) != _loc5_.getChildIndex(hud) - 1) {
			mWash.removeFromParent();
			_loc5_.addChildAt(mWash, _loc5_.getChildIndex(hud));
		}
		space.getTransformationMatrix(_loc5_, mMatrix);
		var _loc6_ = mWash.transformationMatrix;
		if (_loc6_.a != mMatrix.a || _loc6_.b != mMatrix.b || _loc6_.c != mMatrix.c || _loc6_.d != mMatrix.d || _loc6_.tx != mMatrix.tx
			|| _loc6_.ty != mMatrix.ty) {
			mWash.transformationMatrix = mMatrix;
		}
		if (mWash.alpha != alpha) {
			mWash.alpha = alpha;
		}
		if (!mWash.visible) {
			mWash.visible = true;
		}
	}

	public function hide() {
		if (mWash != null && mWash.visible) {
			mWash.visible = false;
		}
	}

	public function dispose() {
		if (mWash != null) {
			mWash.removeFromParent();
			mWash.removeChildren();
			mWash.dispose();
		}
		var _loc1_:Quad;
		final __ax4_iter_221 = mQuads;
		if (checkNullIteratee(__ax4_iter_221))
			for (_tmp_ in __ax4_iter_221) {
				_loc1_ = _tmp_;
				_loc1_.dispose();
			}
		mWash = null;
		mQuads.length = 0;
		clear();
	}

	function build(color:UInt) {
		var _loc2_:Quad = null;
		var _loc3_ = 0;
		var _loc4_ = ASCompat.floatToInt(mCount / 4);
		while (mQuads.length < _loc4_) {
			mQuads.push(new Quad(1, 1));
		}
		_loc3_ = 0;
		while (_loc3_ < mQuads.length) {
			_loc2_ = mQuads[_loc3_];
			if (_loc3_ >= _loc4_) {
				_loc2_.removeFromParent();
			} else {
				_loc2_.x = mHoles[_loc3_ * 4];
				_loc2_.y = mHoles[_loc3_ * 4 + 1];
				_loc2_.readjustSize(mHoles[_loc3_ * 4 + 2] - mHoles[_loc3_ * 4], mHoles[_loc3_ * 4 + 3] - mHoles[_loc3_ * 4 + 1]);
				_loc2_.color = color;
				if (_loc2_.parent != mWash) {
					mWash.addChild(_loc2_);
				}
			}
			_loc3_++;
		}
		mColor = color;
		mBuilt = true;
	}
}
