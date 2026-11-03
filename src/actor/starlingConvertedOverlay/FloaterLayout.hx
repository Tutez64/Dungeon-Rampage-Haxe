package actor.starlingConvertedOverlay;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.text.TextField;

/*internal*/
class FloaterLayout {
	static inline final GUTTER:Float = 2;

	public var labelX:Float = 0;

	public var labelY:Float = 0;

	public var labelWidth:Float = 0;

	public var labelScaleX:Float = 1;

	public var labelScaleY:Float = 1;

	var mAlign:String = "left";

	var mAutoSize:String = "none";

	var mOther:Rectangle;

	public var inkX:Float = 0;

	public var inkY:Float = 0;

	public var left:Float = 0;

	public var top:Float = 0;

	public var bitmapWidth:Int = 0;

	public function new() {}

	public function measure(clip:DisplayObjectContainer, label:TextField) {
		var _loc5_ = 0;
		var _loc6_:DisplayObject = null;
		var _loc4_:Rectangle = null;
		labelX = label.x;
		labelY = label.y;
		labelWidth = label.width;
		labelScaleX = label.scaleX;
		labelScaleY = label.scaleY;
		var _loc3_ = label.length > 0 ? label.getTextFormat(0, 1) : label.defaultTextFormat;
		mAlign = _loc3_.align ?? "left";
		mAutoSize = label.autoSize;
		mOther = null;
		_loc5_ = 0;
		while (_loc5_ < clip.numChildren) {
			_loc6_ = clip.getChildAt(_loc5_);
			if (_loc6_ != label) {
				_loc4_ = _loc6_.getBounds(clip);
				mOther = mOther == null ? _loc4_ : mOther.union(_loc4_);
			}
			_loc5_++;
		}
	}

	public function place(rowWidth:Float) {
		var _loc2_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc3_:Float = 2;
		if (mAutoSize == "none") {
			_loc2_ = labelWidth / labelScaleX;
			_loc4_ = labelX;
			if (mAlign == "center") {
				_loc3_ = (_loc2_ - rowWidth) / 2;
			} else if (mAlign == "right" || mAlign == "end") {
				_loc3_ = _loc2_ - 2 - rowWidth;
			}
		} else {
			_loc2_ = rowWidth + 2 * 2;
			_loc5_ = _loc2_ * labelScaleX;
			if (mAutoSize == "center") {
				_loc4_ = labelX + (labelWidth - _loc5_) / 2;
			} else if (mAutoSize == "right") {
				_loc4_ = labelX + labelWidth - _loc5_;
			} else {
				_loc4_ = labelX;
			}
		}
		inkX = _loc4_ + _loc3_ * labelScaleX;
		inkY = labelY + 2 * labelScaleY;
		var _loc6_ = _loc4_ + _loc2_ * labelScaleX;
		left = _loc4_;
		top = labelY;
		if (mOther != null) {
			left = Math.min(left, mOther.left);
			top = Math.min(top, mOther.top);
			_loc6_ = Math.max(_loc6_, mOther.right);
		}
		bitmapWidth = ASCompat.floatToInt(_loc6_ - left);
	}
}
