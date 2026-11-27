package uI.hud.starlingConverted;

import flash.geom.Matrix;
import starling.core.Starling;
import starling.display.DisplayObject;

/*internal*/
class BakeScale {
	public function new() {}

	@:allow(uI.hud.starlingConverted) static function magnitude(matrix:Matrix):Float {
		return Math.max(Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b), Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d));
	}

	@:allow(uI.hud.starlingConverted) static function forDisplay(node:DisplayObject):Float {
		return magnitude(node.getTransformationMatrix(Starling.current.stage)) * HudArt.pixelScale;
	}

	@:allow(uI.hud.starlingConverted) static function forArt(node:ArtNode, path:String):Float {
		var _loc7_:ArtNode = null;
		var _loc6_:Matrix = null;
		var _loc3_:String = null;
		var _loc4_:Array<ASAny> = ASCompat.coerce(path.length > 0 ? (cast path.split(".")) : [], Array);
		var _loc5_ = node.matrix.clone();
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc3_ = _tmp_;
				_loc7_ = node.find(_loc3_);
				if (_loc7_ == null) {
					return 1;
				}
				_loc6_ = _loc7_.matrix.clone();
				_loc6_.concat(_loc5_);
				_loc5_ = _loc6_;
				node = _loc7_;
			}
		return magnitude(_loc5_);
	}
}
