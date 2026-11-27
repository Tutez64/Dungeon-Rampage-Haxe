package brain.render;

import brain.utils.MemoryTracker;
import flash.display.DisplayObject;

class SortOnAddLayer extends Layer {
	var mNeedsSort:Bool = false;

	public function new(sortIndex:Int = 0) {
		super(sortIndex);
		MemoryTracker.track(this, "SortOnAddLayer sortIndex=" + sortIndex + " - created in SortOnAddLayer()", "brain");
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		super.addChild(child);
		mNeedsSort = true;
		return child;
	}

	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		super.addChildAt(child, index);
		mNeedsSort = true;
		return child;
	}

	override public function render() {
		if (mNeedsSort) {
			this.sortLayer();
			mNeedsSort = false;
		}
	}
}
