package brain.starling;

import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Sprite;

/**
	Holds the Starling layers of the world. A filter on it, the grey of the revive state, is drawn in one pass
	over the screen for all of them.
**/
class StarlingWorld extends Sprite {
	public function new() {
		super();
		name = "StarlingWorld";
		touchable = false;
	}

	// A filter asks its target for its bounds on every frame, then keeps the part of them the stage shows. The
	// world's own bounds are those of every prop and actor of the floor, so the stage's are given at once.
	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		if (stage != null && targetSpace == stage) {
			return stage.getStageBounds(targetSpace, out);
		}
		return super.getBounds(targetSpace, out);
	}
}
