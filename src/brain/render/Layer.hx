package brain.render;

import brain.utils.MemoryTracker;
import collections.ArrayUtils;
import flash.display.DisplayObject;
import flash.display.Sprite;
import collections.IComparator;

class Layer extends Sprite {
	var mComparator:ChildComparator;

	var mSortIndex:Int = 0;

	public function new(sortIndex:Int = 0) {
		super();
		mComparator = new ChildComparator();
		this.mouseEnabled = false;
		mSortIndex = sortIndex;
		MemoryTracker.track(this, "Layer sortIndex=" + sortIndex + " - created in Layer()", "brain");
	}

	@:isVar public var sortIndex(get, never):Int;

	public function get_sortIndex():Int {
		return mSortIndex;
	}

	function fixChildIndex(child:DisplayObject, i:Int, children:Array<ASAny>) {
		if (this.getChildAt(i) != child) {
			this.setChildIndex(child, i);
		}
	}

	public function sortLayer() {
		var _loc2_ = (0 : UInt);
		if (this.numChildren == 0) {
			return;
		}
		var _loc1_ = ASCompat.allocArray(this.numChildren);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (this.numChildren:UInt)) {
			_loc1_[(_loc2_ : Int)] = getChildAt((_loc2_ : Int));
			_loc2_++;
		}
		ArrayUtils.insertionSort(_loc1_, mComparator);
		ASCompat.ASArray.forEach(_loc1_, fixChildIndex, this);
	}

	public function render() {}

	public function destroy() {
		mComparator = null;
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
}

private class ChildComparator implements IComparator {
	public function new() {}

	public function compare(a:ASAny, b:ASAny):Int {
		var a:DisplayObject = a;
		var b:DisplayObject = b;
		if (a.y == b.y) {
			if (a.x == b.x) {
				if (a.height == b.height) {
					return 0;
				}
				return a.height > b.height ? -1 : 1;
			}
			return b.x < a.x ? -1 : 1;
		}
		return a.y < b.y ? -1 : 1;
	}
}
