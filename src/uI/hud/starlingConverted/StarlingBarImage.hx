package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import starling.rendering.Painter;

class StarlingBarImage extends BakedImage {
	var mLeft:Float = Math.NEGATIVE_INFINITY;

	var mRight:Float = Math.POSITIVE_INFINITY;

	var mDirty:Bool = true;

	var mEmpty:Bool = false;

	public function new(cell:BakedCell = null) {
		super(cell);
	}

	override public function set_cell(value:BakedCell):BakedCell {
		super.cell = value;
		mDirty = true;
		return value;
	}

	public function setCut(left:Float, right:Float) {
		if (left == mLeft && right == mRight) {
			return;
		}
		mLeft = left;
		mRight = right;
		mDirty = true;
		setRequiresRedraw();
	}

	override public function render(painter:Painter) {
		if (cell == null || !cell.alive) {
			return;
		}
		if (mDirty) {
			applyCut();
		}
		if (mEmpty) {
			return;
		}
		super.render(painter);
	}

	function applyCut() {
		mDirty = false;
		var _loc2_ = texture.width;
		var _loc3_ = texture.height;
		var _loc4_ = mLeft + pivotX;
		var _loc1_ = mRight + pivotX;
		if (_loc4_ < 0) {
			_loc4_ = 0;
		}
		if (_loc1_ > _loc2_) {
			_loc1_ = _loc2_;
		}
		mEmpty = _loc1_ <= _loc4_;
		if (mEmpty) {
			return;
		}
		setVertexPosition(0, _loc4_, 0);
		setVertexPosition(1, _loc1_, 0);
		setVertexPosition(2, _loc4_, _loc3_);
		setVertexPosition(3, _loc1_, _loc3_);
		setTexCoords(0, _loc4_ / _loc2_, 0);
		setTexCoords(1, _loc1_ / _loc2_, 0);
		setTexCoords(2, _loc4_ / _loc2_, 1);
		setTexCoords(3, _loc1_ / _loc2_, 1);
	}
}
