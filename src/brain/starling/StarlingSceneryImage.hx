package brain.starling;

import starling.display.Image;
import starling.textures.Texture;

class StarlingSceneryImage extends Image {
	var mChangingVisibility:Bool = false;

	public function new(texture:Texture) {
		super(texture);
	}

	override public function setRequiresRedraw() {
		super.setRequiresRedraw();
		var _loc1_ = ASCompat.reinterpretAs(parent, StarlingScenerySprite);
		if (_loc1_ != null) {
			_loc1_.imageChanged(mChangingVisibility);
		}
	}

	override public function set_visible(value:Bool):Bool {
		mChangingVisibility = true;
		super.visible = value;
		mChangingVisibility = false;
		return value;
	}

	override public function set_pixelSnapping(value:Bool):Bool {
		if (super.pixelSnapping == value) {
			return value;
		}
		super.pixelSnapping = value;
		setRequiresRedraw();
		return value;
	}
}
