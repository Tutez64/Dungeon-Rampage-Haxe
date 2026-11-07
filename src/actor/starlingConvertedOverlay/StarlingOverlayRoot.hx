package actor.starlingConvertedOverlay;

import brain.starling.swfConverter.BakedRoot;
import starling.display.Sprite;

/*internal*/
class StarlingOverlayRoot extends BakedRoot {
	public final tags:Sprite = new Sprite();

	public final floaters:Sprite = new Sprite();

	public function new() {
		super();
		addChild(tags);
		addChild(floaters);
	}
}
