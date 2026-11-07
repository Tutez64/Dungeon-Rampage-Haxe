package uI.hud.starlingConverted;

import facade.DBFacade;
import flash.geom.Matrix;
import starling.core.Starling;
import starling.display.DisplayObject;

/*internal*/
class HudTransform {
	public function new() {}

	@:allow(uI.hud.starlingConverted) static function sync(facade:DBFacade, root:DisplayObject):Bool {
		var _loc4_ = Starling.current;
		if (_loc4_ == null || root == null) {
			return false;
		}
		var _loc6_ = _loc4_.viewPort;
		var _loc7_ = _loc6_.width / _loc4_.stage.stageWidth;
		var _loc8_ = _loc6_.height / _loc4_.stage.stageHeight;
		if (!(_loc7_ > 0 && _loc8_ > 0)) {
			return false;
		}
		var _loc3_ = facade.scalingRoot.scaleX / _loc7_;
		var _loc5_ = facade.scalingRoot.scaleY / _loc8_;
		var _loc9_ = (facade.scalingRoot.x - _loc4_.stage3D.x) / _loc7_;
		var _loc10_ = (facade.scalingRoot.y - _loc4_.stage3D.y) / _loc8_;
		if (root.x == _loc9_ && root.y == _loc10_ && root.scaleX == _loc3_ && root.scaleY == _loc5_) {
			return false;
		}
		root.x = _loc9_;
		root.y = _loc10_;
		root.scaleX = _loc3_;
		root.scaleY = _loc5_;
		return true;
	}

	@:allow(uI.hud.starlingConverted) static function inverse(facade:DBFacade, matrix:Matrix) {
		matrix.setTo(1 / facade.scalingRoot.scaleX, 0, 0, 1 / facade.scalingRoot.scaleY, -facade.scalingRoot.x / facade.scalingRoot.scaleX,
			-facade.scalingRoot.y / facade.scalingRoot.scaleY);
	}
}
