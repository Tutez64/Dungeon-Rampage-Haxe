package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedImage;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Mesh;

class StarlingButton {
	var mRoot:DisplayObject;

	var mSpace:DisplayObject;

	var mStates:Vector<DisplayObject> = new Vector((0 : UInt));

	var mHit:DisplayObject;

	var mLabel:DisplayObject;

	var mEnabled:Bool = true;

	var mHovered:Bool = false;

	var mPressed:Bool = false;

	var mPressHandedToGame:Bool = false;

	var mUpOnly:Bool = false;

	var mPressCallback:ASFunction;

	var mReleaseCallback:ASFunction;

	var mRollOverCallback:ASFunction;

	var mRollOutCallback:ASFunction;

	var mPressRollOutCallback:ASFunction;

	var mMatrix:Matrix = new Matrix();

	var mLeafBounds:Rectangle = new Rectangle();

	public function new(view:ArtView, path:String = "", designSpace:DisplayObject = null) {
		mRoot = view.node(path);
		var _loc4_ = path.length > 0 ? path + "." : "";
		var _loc6_ = view.node(_loc4_ + "theButton");
		if (_loc6_ != null) {
			mRoot = _loc6_;
			_loc4_ += "theButton.";
		}
		mSpace = designSpace;
		var _loc5_ = view.node(_loc4_ + "up");
		mStates.push(_loc5_);
		mStates.push(ASCompat.thisOrDefault(view.node(_loc4_ + "over"), _loc5_));
		mStates.push(ASCompat.thisOrDefault(view.node(_loc4_ + "down"), _loc5_));
		mStates.push(ASCompat.thisOrDefault(view.node(_loc4_ + "disabled"), _loc5_));
		mStates.push(ASCompat.thisOrDefault(view.node(_loc4_ + "selected"), _loc5_));
		mHit = view.node(_loc4_ + "hit");
		mLabel = view.node(_loc4_ + "label");
		if (Std.isOfType(mHit, ArtDisplay)) {
			cast(mHit, ArtDisplay).setHudVisibility(false);
		} else if (mHit != null) {
			mHit.visible = false;
		}
		refresh();
	}

	function refresh() {
		var _loc2_ = 0;
		var _loc3_ = mUpOnly ? 0 : (!mEnabled ? 3 : (mPressed && mHovered ? 2 : (mHovered ? 1 : 0)));
		var _loc1_ = mStates[_loc3_];
		_loc2_ = 0;
		while (_loc2_ < mStates.length) {
			if (mStates[_loc2_] != null) {
				if (Std.isOfType(mStates[_loc2_], ArtDisplay)) {
					cast(mStates[_loc2_], ArtDisplay).setHudVisibility(false);
				} else {
					mStates[_loc2_].visible = false;
				}
				animate(mStates[_loc2_], false);
			}
			_loc2_++;
		}
		if (_loc1_ != null) {
			if (Std.isOfType(_loc1_, ArtDisplay)) {
				cast(_loc1_, ArtDisplay).setHudVisibility(true);
			} else {
				_loc1_.visible = true;
			}
			animate(_loc1_, true);
		}
	}

	function animate(display:DisplayObject, play:Bool) {
		var _loc4_ = 0;
		var _loc3_ = ASCompat.reinterpretAs(display, DisplayObjectContainer);
		if (Std.isOfType(display, TimelineView)) {
			if (play) {
				cast(display, TimelineView).play(0, true);
			} else {
				cast(display, TimelineView).stop();
			}
			return;
		}
		if (_loc3_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.numChildren) {
				animate(_loc3_.getChildAt(_loc4_), play);
				_loc4_++;
			}
		}
	}

	public function hitTest(designX:Float, designY:Float):Bool {
		if (!mEnabled || !showing) {
			return false;
		}
		return hit(mHit ?? mRoot, designX, designY, mHit != null);
	}

	@:allow(uI.hud.starlingConverted) @:isVar var showing(get, never):Bool;

	function get_showing():Bool {
		var _loc1_ = mRoot;
		while (_loc1_ != null) {
			if (!_loc1_.visible || _loc1_.scaleX == 0 || _loc1_.scaleY == 0) {
				return false;
			}
			_loc1_ = _loc1_.parent;
		}
		return mRoot != null && mRoot.stage != null;
	}

	function hit(display:DisplayObject, x:Float, y:Float, ignoreVisibility:Bool):Bool {
		var _loc8_ = 0;
		if (!ignoreVisibility && !display.visible) {
			return false;
		}
		if (display == mLabel) {
			return false;
		}
		var _loc7_ = ASCompat.reinterpretAs(display, ArtDisplay);
		if (_loc7_ != null && _loc7_.art.hitCell != null && !_loc7_.art.hitCell.isEmpty) {
			display.getTransformationMatrix(mSpace, mMatrix);
			mMatrix.invert();
			return _loc7_.art.hitCell.opaqueAt(mMatrix.a * x
				+ mMatrix.c * y
				+ mMatrix.tx
				+ _loc7_.art.hitCell.pivotX,
				mMatrix.b * x
				+ mMatrix.d * y
				+ mMatrix.ty
				+ _loc7_.art.hitCell.pivotY, (0 : UInt));
		}
		if (_loc7_ != null && _loc7_.art.kind == "text") {
			display.getTransformationMatrix(mSpace, mMatrix);
			mMatrix.invert();
			return _loc7_.art.textBounds.contains(mMatrix.a * x + mMatrix.c * y + mMatrix.tx, mMatrix.b * x + mMatrix.d * y + mMatrix.ty);
		}
		var _loc6_ = ASCompat.reinterpretAs(display, BakedImage);
		var _loc5_ = ASCompat.reinterpretAs(display, DisplayObjectContainer);
		if (_loc6_ != null && _loc6_.cell != null) {
			display.getTransformationMatrix(mSpace, mMatrix);
			mMatrix.invert();
			return _loc6_.cell.opaqueAt(mMatrix.a * x + mMatrix.c * y + mMatrix.tx, mMatrix.b * x + mMatrix.d * y + mMatrix.ty, (0 : UInt));
		}
		var _loc9_ = ASCompat.reinterpretAs(display, Mesh);
		if (_loc6_ == null && _loc9_ != null && _loc9_.texture != null) {
			display.getTransformationMatrix(mSpace, mMatrix);
			mMatrix.invert();
			_loc9_.getBounds(_loc9_, mLeafBounds);
			return mLeafBounds.contains(mMatrix.a * x + mMatrix.c * y + mMatrix.tx, mMatrix.b * x + mMatrix.d * y + mMatrix.ty);
		}
		if (_loc5_ != null) {
			_loc8_ = _loc5_.numChildren - 1;
			while (_loc8_ >= 0) {
				if (hit(_loc5_.getChildAt(_loc8_), x, y, ignoreVisibility)) {
					return true;
				}
				_loc8_--;
			}
		}
		return false;
	}

	public function setHover(value:Bool) {
		mHovered = value;
		refresh();
	}

	public function setPressed(value:Bool) {
		mPressed = value;
		refresh();
	}

	@:allow(uI.hud.starlingConverted) function restartState() {
		refresh();
	}

	public function onMouseDown() {
		if (!mEnabled || !visible) {
			return;
		}
		mPressHandedToGame = false;
		if (!mHovered) {
			onRollOver();
		}
		setPressed(true);
		if (mPressCallback != null) {
			mPressCallback();
		}
	}

	public function onMouseUp(inside:Bool) {
		var _loc2_ = mPressed;
		mHovered = inside;
		setPressed(false);
		if (_loc2_ && mEnabled && inside && mReleaseCallback != null) {
			mReleaseCallback();
		}
	}

	public function onRollOver() {
		if (!mEnabled || mHovered) {
			return;
		}
		setHover(true);
		if (mRollOverCallback != null) {
			mRollOverCallback();
		}
	}

	public function onRollOut() {
		if (!mHovered) {
			return;
		}
		if (mPressed && mPressRollOutCallback != null) {
			mPressRollOutCallback();
		}
		setHover(false);
		if (mRollOutCallback != null) {
			mRollOutCallback();
		}
	}

	@:isVar public var enabled(get, set):Bool;

	public function get_enabled():Bool {
		return mEnabled;
	}

	@:isVar public var upOnly(never, set):Bool;

	public function set_upOnly(value:Bool):Bool {
		mUpOnly = value;
		refresh();
		return value;
	}

	public function clearStateArt() {
		var _loc1_:DisplayObject = null;
		final __ax4_iter_177 = mStates;
		if (checkNullIteratee(__ax4_iter_177))
			for (_tmp_ in __ax4_iter_177) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					animate(_loc1_, false);
					if (Std.isOfType(_loc1_, ArtDisplay)) {
						cast(_loc1_, ArtDisplay).setHudVisibility(false);
					} else {
						_loc1_.visible = false;
					}
				}
			}
		mStates.length = 0;
		mStates.length = 5;
		mHit = null;
	}

	function set_enabled(value:Bool):Bool {
		mEnabled = value;
		if (!value) {
			mPressed = false;
			mHovered = false;
		}
		refresh();
		return value;
	}

	@:isVar public var visible(get, set):Bool;

	public function get_visible():Bool {
		return mRoot.visible;
	}

	function set_visible(value:Bool):Bool {
		return mRoot.visible = value;
	}

	@:isVar public var root(get, never):DisplayObject;

	public function get_root():DisplayObject {
		return mRoot;
	}

	@:allow(uI.hud.starlingConverted) function handPressToGame() {
		mPressHandedToGame = true;
	}

	@:allow(uI.hud.starlingConverted) @:isVar var pressHandedToGame(get, never):Bool;

	function get_pressHandedToGame():Bool {
		return mPressHandedToGame;
	}

	@:isVar public var pressCallback(never, set):ASFunction;

	public function set_pressCallback(value:ASFunction):ASFunction {
		return mPressCallback = value;
	}

	@:isVar public var releaseCallback(never, set):ASFunction;

	public function set_releaseCallback(value:ASFunction):ASFunction {
		return mReleaseCallback = value;
	}

	@:isVar public var rollOverCallback(never, set):ASFunction;

	public function set_rollOverCallback(value:ASFunction):ASFunction {
		return mRollOverCallback = value;
	}

	@:isVar public var rollOutCallback(never, set):ASFunction;

	public function set_rollOutCallback(value:ASFunction):ASFunction {
		return mRollOutCallback = value;
	}

	@:isVar public var pressRollOutCallback(never, set):ASFunction;

	public function set_pressRollOutCallback(value:ASFunction):ASFunction {
		return mPressRollOutCallback = value;
	}

	public function dispose() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mStates.length) {
			if (mStates[_loc1_] != null) {
				animate(mStates[_loc1_], false);
			}
			_loc1_++;
		}
		mPressCallback = mReleaseCallback = mRollOverCallback = mRollOutCallback = mPressRollOutCallback = null;
	}
}
