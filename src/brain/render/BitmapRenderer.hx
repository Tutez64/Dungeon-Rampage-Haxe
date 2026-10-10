package brain.render;

import brain.clock.GameClock;
import brain.utils.MemoryTracker;
import brain.workLoop.Task;
import brain.workLoop.WorkComponent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

class BitmapRenderer {
	var mWorkComponent:WorkComponent;

	var mOnFrameTask:Task;

	var mBitmap:Bitmap = new Bitmap();

	var mSmoothing:Bool = true;

	var mCenter:Point = new Point(0.5, 0.5);

	public function new(workComponent:WorkComponent) {
		mBitmap.smoothing = mSmoothing;
		mBitmap.pixelSnapping = "auto";
		mWorkComponent = workComponent;
		mBitmap.addEventListener("addedToStage", onAdd);
		mBitmap.addEventListener("removedFromStage", onRemove);
		MemoryTracker.track(this, "BitmapRenderer - created in BitmapRenderer()", "brain");
	}

	public function destroy() {
		mBitmap.removeEventListener("addedToStage", onAdd);
		mBitmap.removeEventListener("removedFromStage", onRemove);
		onRemove();
		mWorkComponent.destroy();
		mWorkComponent = null;
		mBitmap = null;
	}

	function onAdd(event:Event = null) {
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
		}
		mOnFrameTask = mWorkComponent.doEveryFrame(onFrame);
	}

	function onRemove(event:Event = null) {
		if (mOnFrameTask != null) {
			mOnFrameTask.destroy();
			mOnFrameTask = null;
		}
	}

	@:isVar public var center(get, set):Point;

	public function set_center(value:Point):Point {
		mCenter = value;
		mBitmap.x = -mCenter.x;
		mBitmap.y = -mCenter.y;
		return value;
	}

	function get_center():Point {
		return mCenter;
	}

	@:isVar public var smoothing(get, set):Bool;

	public function set_smoothing(value:Bool):Bool {
		mSmoothing = value;
		mBitmap.smoothing = mSmoothing;
		return value;
	}

	function get_smoothing():Bool {
		return mSmoothing;
	}

	@:isVar public var displayObject(get, never):DisplayObject;

	public function get_displayObject():DisplayObject {
		return mBitmap;
	}

	@:isVar public var bitmapData(get, set):BitmapData;

	public function set_bitmapData(value:BitmapData):BitmapData {
		if (value == mBitmap.bitmapData) {
			return value;
		}
		mBitmap.bitmapData = value;
		mBitmap.smoothing = mSmoothing;
		mBitmap.x = -mCenter.x;
		mBitmap.y = -mCenter.y;
		return value;
	}

	function onFrame(gameClock:GameClock) {}

	function get_bitmapData():BitmapData {
		return mBitmap.bitmapData;
	}
}
