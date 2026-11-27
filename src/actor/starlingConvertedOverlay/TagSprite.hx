package actor.starlingConvertedOverlay;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.rendering.Painter;

/*internal*/
class TagSprite extends Sprite {
	public var owner:StarlingNametag;

	public function new() {
		super();
	}

	public static function compare(a:DisplayObject, b:DisplayObject):Int {
		var _loc3_ = cast(a, TagSprite).owner;
		var _loc4_ = cast(b, TagSprite).owner;
		if (_loc3_ == null || _loc4_ == null) {
			return _loc3_ == _loc4_ ? 0 : (_loc3_ == null ? -1 : 1);
		}
		return _loc3_.compareInFlash(_loc4_);
	}

	override public function render(painter:Painter) {
		if (owner != null) {
			owner.snapToScreen(painter.pixelSize);
		}
		super.render(painter);
	}
}
