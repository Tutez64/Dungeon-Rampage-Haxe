package brain.assetRepository;

import flash.display.Bitmap;

class ImageAsset extends Asset {
	var mImage:Bitmap;

	public function new(image:Bitmap) {
		super();
		mImage = image;
	}

	@:isVar public var image(get, never):Bitmap;

	public function get_image():Bitmap {
		return mImage;
	}

	override public function destroy() {
		mImage = null;
		super.destroy();
	}
}
