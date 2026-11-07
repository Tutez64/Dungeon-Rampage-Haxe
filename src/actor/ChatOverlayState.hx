package actor;

import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

/*internal*/
class ChatOverlayState {
	public var frame:UInt = 0;

	final mMatrix:Matrix = new Matrix();

	final mColor:ColorTransform = new ColorTransform();

	var mFilters:Array<ASAny> = [];

	var mFirst:Bool = true;

	public function new() {}

	public function apply(content:Sprite, matrix:Matrix, color:ColorTransform, filters:Array<ASAny>) {
		if (mFirst || matrix.a != mMatrix.a || matrix.b != mMatrix.b || matrix.c != mMatrix.c || matrix.d != mMatrix.d || matrix.tx != mMatrix.tx
			|| matrix.ty != mMatrix.ty) {
			content.transform.matrix = matrix;
			mMatrix.copyFrom(matrix);
		}
		if (mFirst
			|| color.redMultiplier != mColor.redMultiplier
			|| color.greenMultiplier != mColor.greenMultiplier
			|| color.blueMultiplier != mColor.blueMultiplier
			|| color.alphaMultiplier != mColor.alphaMultiplier
			|| color.redOffset != mColor.redOffset
			|| color.greenOffset != mColor.greenOffset
			|| color.blueOffset != mColor.blueOffset
			|| color.alphaOffset != mColor.alphaOffset) {
			content.transform.colorTransform = color;
			mColor.redMultiplier = color.redMultiplier;
			mColor.greenMultiplier = color.greenMultiplier;
			mColor.blueMultiplier = color.blueMultiplier;
			mColor.alphaMultiplier = color.alphaMultiplier;
			mColor.redOffset = color.redOffset;
			mColor.greenOffset = color.greenOffset;
			mColor.blueOffset = color.blueOffset;
			mColor.alphaOffset = color.alphaOffset;
		}
		if (mFirst || !sameFilters(filters)) {
			content.filters = cast(filters);
			mFilters = filters.copy();
		}
		mFirst = false;
	}

	function sameFilters(filters:Array<ASAny>):Bool {
		var _loc7_:Array<ASAny>;
		var _loc5_ = 0;
		var _loc2_:ColorMatrixFilter = null;
		var _loc3_:ColorMatrixFilter = null;
		var _loc4_:Array<ASAny> = null;
		var _loc6_ = 0;
		if (filters.length != mFilters.length) {
			return false;
		}
		_loc5_ = 0;
		while (_loc5_ < filters.length) {
			if (filters[_loc5_] != mFilters[_loc5_]) {
				_loc2_ = ASCompat.dynamicAs(filters[_loc5_], ColorMatrixFilter);
				_loc3_ = ASCompat.dynamicAs(mFilters[_loc5_], ColorMatrixFilter);
				if (_loc2_ == null || _loc3_ == null) {
					return false;
				}
				_loc4_ = _loc2_.matrix;
				_loc7_ = _loc3_.matrix;
				_loc6_ = 0;
				while (_loc6_ < _loc4_.length) {
					if (_loc4_[_loc6_] != _loc7_[_loc6_]) {
						return false;
					}
					_loc6_++;
				}
			}
			_loc5_++;
		}
		return true;
	}
}
