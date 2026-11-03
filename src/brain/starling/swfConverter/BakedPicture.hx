package brain.starling.swfConverter;

import flash.display.BitmapData;

class BakedPicture {
	public var bitmap:BitmapData;

	public var originX:Int = 0;

	public var originY:Int = 0;

	public var pixelScale:Float = Math.NaN;

	public var requestedScale:Float = Math.NaN;

	public var empty:Bool = false;

	public function new() {}

	public function dispose() {
		if (bitmap != null) {
			bitmap.dispose();
		}
		bitmap = null;
	}
}
