package brain.starling;

import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.MaskRole;
import starling.display.Sprite;
import starling.rendering.Painter;

class StarlingScenerySprite extends Sprite {
	public static inline final CULL_MARGIN:Float = 256;

	static final sBounds:Rectangle = new Rectangle();

	var mBoundsValid:Bool = false;

	var mLeft:Float = 0;

	var mTop:Float = 0;

	var mRight:Float = 0;

	var mBottom:Float = 0;

	var mShown:Bool = true;

	var mCulled:Bool = false;

	var mRun:StarlingBakedRun;

	var mSlot:Int = 0;

	var mSlotImage:Image;

	var mQuiet:Bool = false;

	@:allow(brain.starling) var bakeQueued:Bool = false;

	@:allow(brain.starling) var bakeShownOnly:Bool = true;

	@:allow(brain.starling) var slotShown:Bool = false;

	public function new() {
		super();
	}

	static function nearZero(value:Float):Bool {
		return value != 0 && value < 0.001 && value > -0.001;
	}

	@:isVar var cullReach(get, never):Float;

	function get_cullReach():Float {
		return 0;
	}

	@:allow(brain.starling) function overlaps(left:Float, top:Float, right:Float, bottom:Float):Bool {
		if (filter != null) {
			return true;
		}
		if (numChildren == 1 && getChildAt(0).filter != null) {
			return true;
		}
		if (isLead) {
			return mRun.right >= left && mRun.left <= right && mRun.bottom >= top && mRun.top <= bottom;
		}
		if (!mBoundsValid || !(numChildren == 1 && Std.isOfType(getChildAt(0), StarlingSceneryImage))) {
			cacheBounds();
		}
		return mRight >= left && mLeft <= right && mBottom >= top && mTop <= bottom;
	}

	@:allow(brain.starling) function setCulled(value:Bool) {
		if (mCulled == value) {
			return;
		}
		mCulled = value;
		applyVisible();
	}

	function cacheBounds() {
		getBounds(parent, sBounds);
		var _loc1_ = cullReach * Math.max(Math.abs(scaleX), Math.abs(scaleY));
		mLeft = Math.min(sBounds.left, x - _loc1_) - 256;
		mTop = Math.min(sBounds.top, y - _loc1_) - 256;
		mRight = Math.max(sBounds.right, x + _loc1_) + 256;
		mBottom = Math.max(sBounds.bottom, y + _loc1_) + 256;
		mBoundsValid = true;
	}

	@:allow(brain.starling) @:isVar var bakeImage(get, never):Image;

	function get_bakeImage():Image {
		if (numChildren != 1 || filter != null || mask != null || MaskRole.isMask(this) || nearZero(scaleX) || nearZero(scaleY)) {
			return null;
		}
		var _loc2_ = transformationMatrix;
		var _loc3_ = _loc2_.a * _loc2_.d - _loc2_.b * _loc2_.c;
		if (_loc3_ == 0 || !Math.isFinite(_loc3_)) {
			return null;
		}
		var _loc1_:Image = ASCompat.reinterpretAs(getChildAt(0), StarlingSceneryImage);
		if (_loc1_ == null || _loc1_.filter != null || _loc1_.mask != null || MaskRole.isMask(_loc1_) || _loc1_.pixelSnapping) {
			return null;
		}
		return ASCompat.coerce(_loc1_.numVertices == 4 && _loc1_.numIndices == 6 ? _loc1_ : null, starling.display.Image);
	}

	@:allow(brain.starling) @:isVar var hasMaskRole(get, never):Bool;

	function get_hasMaskRole():Bool {
		return MaskRole.isMask(this) || numChildren == 1 && MaskRole.isMask(getChildAt(0));
	}

	@:allow(brain.starling) function maskRoleCleared() {
		setRequiresRedraw();
		if (numChildren == 1) {
			getChildAt(0).setRequiresRedraw();
		}
	}

	@:allow(brain.starling) @:isVar var bakeShown(get, never):Bool;

	function get_bakeShown():Bool {
		return mShown && alpha != 0 && scaleX != 0 && scaleY != 0 && mSlotImage.visible && mSlotImage.alpha != 0;
	}

	@:allow(brain.starling) @:isVar var canLead(get, never):Bool;

	function get_canLead():Bool {
		return alpha != 0 && scaleX != 0 && scaleY != 0;
	}

	@:allow(brain.starling) @:isVar var run(get, never):StarlingBakedRun;

	function get_run():StarlingBakedRun {
		return mRun;
	}

	@:allow(brain.starling) @:isVar var slot(get, never):Int;

	function get_slot():Int {
		return mSlot;
	}

	@:allow(brain.starling) @:isVar var slotImage(get, never):Image;

	function get_slotImage():Image {
		return mSlotImage;
	}

	@:allow(brain.starling) @:isVar var isLead(get, never):Bool;

	function get_isLead():Bool {
		return mRun != null && mRun.lead == this;
	}

	@:allow(brain.starling) @:isVar var isMember(get, never):Bool;

	function get_isMember():Bool {
		return mRun != null;
	}

	@:allow(brain.starling) function joinRun(run:StarlingBakedRun, slot:Int, image:Image) {
		mRun = run;
		mSlot = slot;
		mSlotImage = image;
		slotShown = false;
		mCulled = false;
		if (!mBoundsValid) {
			cacheBounds();
		}
		if (run.lead == this) {
			run.left = mLeft;
			run.top = mTop;
			run.right = mRight;
			run.bottom = mBottom;
		} else {
			if (mLeft < run.left) {
				run.left = mLeft;
			}
			if (mTop < run.top) {
				run.top = mTop;
			}
			if (mRight > run.right) {
				run.right = mRight;
			}
			if (mBottom > run.bottom) {
				run.bottom = mBottom;
			}
		}
		applyVisible();
	}

	@:allow(brain.starling) function leaveRun() {
		if (mRun == null) {
			return;
		}
		mRun = null;
		mSlotImage = null;
		mCulled = false;
		applyVisible();
	}

	function queueBake(reason:Int) {
		var _loc2_ = ASCompat.reinterpretAs(parent, StarlingLayer);
		if (_loc2_ != null) {
			_loc2_.queueBake(this, reason);
		}
	}

	@:allow(brain.starling) function imageChanged(shownOnly:Bool) {
		mBoundsValid = false;
		queueBake(shownOnly ? 1 : 3);
	}

	function applyVisible() {
		mQuiet = true;
		super.visible = mRun != null ? mRun.lead == this && !mCulled : mShown && !mCulled;
		setRequiresRedraw();
		mQuiet = false;
	}

	override public function setRequiresRedraw() {
		mBoundsValid = false;
		super.setRequiresRedraw();
		if (!mQuiet) {
			queueBake(3);
		}
	}

	override public function render(painter:Painter) {
		if (!isLead || MaskRole.isMask(this)) {
			super.render(painter);
			return;
		}
		painter.excludeFromCache(this);
		if (mRun.shownCount == 0) {
			return;
		}
		var _loc2_ = mRun.batch;
		painter.state.blendMode = _loc2_.blendMode;
		if (alpha != 1) {
			painter.state.alpha /= alpha;
		}
		_loc2_.render(painter);
	}

	override public function dispose() {
		if (mRun != null || Std.isOfType(parent, StarlingLayer)) {
			removeFromParent();
		}
		super.dispose();
	}

	override public function get_visible():Bool {
		return mShown;
	}

	override public function set_visible(value:Bool):Bool {
		if (mShown == value) {
			return value;
		}
		mShown = value;
		applyVisible();
		queueBake(2);
		return value;
	}

	override public function set_x(value:Float):Float {
		super.x = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_y(value:Float):Float {
		super.y = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_scaleX(value:Float):Float {
		super.scaleX = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_scaleY(value:Float):Float {
		super.scaleY = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_skewX(value:Float):Float {
		super.skewX = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_skewY(value:Float):Float {
		super.skewY = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_rotation(value:Float):Float {
		super.rotation = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_pivotX(value:Float):Float {
		super.pivotX = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_pivotY(value:Float):Float {
		super.pivotY = value;
		mBoundsValid = false;
		return value;
	}

	override public function set_transformationMatrix(matrix:Matrix):Matrix {
		super.transformationMatrix = matrix;
		mBoundsValid = false;
		return matrix;
	}

	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		mBoundsValid = false;
		var _loc3_ = super.addChildAt(child, index);
		queueBake(3);
		return _loc3_;
	}

	override public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject {
		mBoundsValid = false;
		var _loc3_ = super.removeChildAt(index, dispose);
		queueBake(3);
		return _loc3_;
	}
}
