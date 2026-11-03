package actor.starlingConvertedOverlay;

import brain.starling.swfConverter.BakedImage;
import flash.geom.Matrix;
import starling.display.DisplayObject;
import starling.display.Sprite;

/*internal*/
class TagView {
	public static inline final BAR = 0;

	public static inline final NAME = 1;

	public static inline final AFK = 2;

	public final tag:TagSprite = new TagSprite();

	public final art:Sprite = new Sprite();

	public final bar:Sprite = new Sprite();

	public final under:BakedImage = newImage();

	public final fill:BakedImage = newImage();

	public final over:BakedImage = newImage();

	public final name:BakedImage = newImage();

	public final afk:BakedImage = newImage();

	final mScreen:Matrix = new Matrix();

	final mParentScreen:Matrix = new Matrix();

	public function new() {
		bar.addChild(under);
		bar.addChild(fill);
		bar.addChild(over);
		tag.addChild(art);
	}

	static function newImage():BakedImage {
		var _loc1_ = new BakedImage();
		_loc1_.visible = false;
		return _loc1_;
	}

	public function order(back:Int, middle:Int, front:Int) {
		art.removeChildren();
		art.addChild(part(back));
		art.addChild(part(middle));
		art.addChild(part(front));
	}

	public function snapToScreen(text:BakedImage, pixelSize:Float, baseX:Float, baseY:Float, cameraOffsetX:Float, cameraOffsetY:Float) {
		art.x = baseX;
		art.y = baseY;
		if (text == null || tag.stage == null || pixelSize <= 0 || !Math.isFinite(pixelSize)) {
			return;
		}
		text.getTransformationMatrix(tag.stage, mScreen);
		tag.getTransformationMatrix(tag.stage, mParentScreen);
		var _loc9_ = mParentScreen.a * mParentScreen.d - mParentScreen.b * mParentScreen.c;
		if (_loc9_ == 0 || !Math.isFinite(_loc9_)) {
			return;
		}
		var _loc7_ = Math.fround((mScreen.tx + cameraOffsetX) / pixelSize) * pixelSize - mScreen.tx;
		var _loc8_ = Math.fround((mScreen.ty + cameraOffsetY) / pixelSize) * pixelSize - mScreen.ty;
		if (!Math.isFinite(_loc7_) || !Math.isFinite(_loc8_)) {
			return;
		}
		art.x = baseX + (mParentScreen.d * _loc7_ - mParentScreen.c * _loc8_) / _loc9_;
		art.y = baseY + (mParentScreen.a * _loc8_ - mParentScreen.b * _loc7_) / _loc9_;
	}

	function part(id:Int):DisplayObject {
		return ASCompat.coerce(id == 0 ? bar : (id == 1 ? name : afk), starling.display.DisplayObject);
	}
}
