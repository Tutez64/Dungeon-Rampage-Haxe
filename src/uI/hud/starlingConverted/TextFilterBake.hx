package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedPicture;
import brain.starling.swfConverter.FlashBaker;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.text.TextField;

/*internal*/
class TextFilterBake {
	public function new() {}

	@:allow(UI.Hud.StarlingConverted) static function bake(field:TextField, ancestors:Vector<ArtDisplay>, variant:Int, scale:Float,
			placement:Matrix):BakedPicture {
		var __ax4_iter_165:Array<ASAny>;
		var _loc11_:Sprite = null;
		var _loc6_:ArtDisplay = null;
		var _loc12_:Array<ASAny> = null;
		var _loc13_:BitmapFilter = null;
		var _loc16_ = 0;
		var _loc8_ = 0;
		var _loc15_ = FlashBaker.textCopy(field);
		var _loc10_ = field.getBounds(field);
		_loc15_.autoSize = field.autoSize;
		_loc15_.multiline = field.multiline;
		_loc15_.wordWrap = field.wordWrap;
		_loc15_.width = _loc10_.width;
		_loc15_.height = _loc10_.height;
		_loc15_.htmlText = field.htmlText;
		_loc15_.transform.matrix = field.transform.matrix;
		var _loc7_ = _loc15_.transform.matrix.clone();
		var _loc17_:DisplayObject = _loc15_;
		if (checkNullIteratee(ancestors))
			for (_tmp_ in ancestors) {
				_loc6_ = _tmp_;
				_loc8_ = _loc6_.art.filterStates.length;
				_loc16_ = _loc8_ > 0 ? variant % _loc8_ : 0;
				if (_loc8_ > 0) {
					variant = ASCompat.floatToInt(variant / _loc8_);
				}
				_loc12_ = [];
				if (_loc8_ > 0) {
					__ax4_iter_165 = _loc6_.art.filterStates[_loc16_];
					if (checkNullIteratee(__ax4_iter_165))
						for (_tmp_ in __ax4_iter_165) {
							_loc13_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
							_loc12_.push(_loc13_.clone());
						}
				}
				_loc11_ = new Sprite();
				_loc11_.filters = cast(_loc12_);
				_loc11_.addChild(_loc17_);
				_loc11_.transform.matrix = _loc6_.art.matrix;
				_loc7_.concat(_loc6_.art.matrix);
				_loc17_ = _loc11_;
			}
		_loc11_ = new Sprite();
		_loc11_.addChild(_loc17_);
		var _loc9_ = scale / BakeScale.magnitude(_loc7_);
		var _loc14_ = StarlingRaster.bake(_loc11_, _loc9_);
		_loc7_.invert();
		_loc7_.concat(placement);
		placement.copyFrom(_loc7_);
		return _loc14_;
	}
}
