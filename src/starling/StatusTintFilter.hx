package starling;

import starling.extensions.animate.styles.ColorTransformStyle;

class StatusTintFilter {
	var mMatrix:Vector<Float>;

	var mActive:Bool = false;

	public function new() {}

	@:isVar public var matrix(get, never):Vector<Float>;

	public function get_matrix():Vector<Float> {
		return mActive ? mMatrix : null;
	}

	@:isVar public var active(get, never):Bool;

	public function get_active():Bool {
		return mActive;
	}

	public function set(color:UInt, amount:Float) {
		if (amount <= 0) {
			mActive = false;
			return;
		}
		mMatrix = ColorTransformStyle.tintMatrix(color, amount, mMatrix);
		mActive = true;
	}

	public function clear() {
		mActive = false;
	}

	public function dispose() {
		mMatrix = null;
		mActive = false;
	}
}
