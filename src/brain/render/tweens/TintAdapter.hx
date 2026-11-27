package brain.render.tweens;

import flash.display.DisplayObject;
import flash.geom.ColorTransform;

/*internal*/
class TintAdapter {
	var mTarget:DisplayObject;

	var mTint:UInt = 0;

	var mRemove:Bool = false;

	var mStart:ColorTransform;

	var mEnd:ColorTransform;

	var mProgress:Float = 0;

	public function new(target:DisplayObject, tint:UInt, remove:Bool) {
		mTarget = target;
		mTint = tint;
		mRemove = remove;
	}

	static function lerp(from:Float, to:Float, ratio:Float):Float {
		return from + (to - from) * ratio;
	}

	@:isVar public var progress(get, set):Float;

	public function get_progress():Float {
		return mProgress;
	}

	function set_progress(value:Float):Float {
		mProgress = value;
		if (mStart == null) {
			capture();
		}
		mTarget.transform.colorTransform = new ColorTransform(lerp(mStart.redMultiplier, mEnd.redMultiplier, value),
			lerp(mStart.greenMultiplier, mEnd.greenMultiplier, value), lerp(mStart.blueMultiplier, mEnd.blueMultiplier, value), mStart.alphaMultiplier,
			lerp(mStart.redOffset, mEnd.redOffset, value), lerp(mStart.greenOffset, mEnd.greenOffset, value), lerp(mStart.blueOffset, mEnd.blueOffset, value),
			mStart.alphaOffset);
		return value;
	}

	public function revert() {
		if (mTarget != null && mStart != null) {
			mTarget.transform.colorTransform = mStart;
		}
	}

	function capture() {
		mStart = mTarget.transform.colorTransform;
		mEnd = new ColorTransform();
		if (!mRemove) {
			mEnd.color = mTint;
		}
		mEnd.alphaMultiplier = mStart.alphaMultiplier;
		mEnd.alphaOffset = mStart.alphaOffset;
	}
}
