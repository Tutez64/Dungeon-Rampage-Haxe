package brain.starling.swfConverter;

import starling.textures.Texture;

class BakedCell {
	@:allow(brain.starling.swfConverter) var mKey__Brain_Starling_SwfConverter_BakedCell /*redefined private*/:String;

	@:allow(brain.starling.swfConverter) var mPage__Brain_Starling_SwfConverter_BakedCell /*redefined private*/:BakedPage;

	@:allow(brain.starling.swfConverter) var mTexture__Brain_Starling_SwfConverter_BakedCell /*redefined private*/:Texture;

	@:allow(brain.starling.swfConverter) var mRefCount:Int = 0;

	@:allow(brain.starling.swfConverter) var mPixelScale:Float = 1;

	@:allow(brain.starling.swfConverter) var mOriginX:Int = 0;

	@:allow(brain.starling.swfConverter) var mOriginY:Int = 0;

	@:allow(brain.starling.swfConverter) var mEmpty:Bool = false;

	@:allow(brain.starling.swfConverter) var mSlotX:Int = 0;

	@:allow(brain.starling.swfConverter) var mSlotY:Int = 0;

	@:allow(brain.starling.swfConverter) var mSlotWidth__Brain_Starling_SwfConverter_BakedCell /*redefined private*/:Int = 0;

	@:allow(brain.starling.swfConverter) var mWidth:Int = 0;

	@:allow(brain.starling.swfConverter) var mHeight:Int = 0;

	public function new() {}

	@:isVar public var key(get, never):String;

	public function get_key():String {
		return mKey__Brain_Starling_SwfConverter_BakedCell;
	}

	@:isVar public var texture(get, never):Texture;

	public function get_texture():Texture {
		return mTexture__Brain_Starling_SwfConverter_BakedCell;
	}

	@:isVar public var pivotX(get, never):Float;

	public function get_pivotX():Float {
		return mOriginX / mPixelScale;
	}

	@:isVar public var pivotY(get, never):Float;

	public function get_pivotY():Float {
		return mOriginY / mPixelScale;
	}

	@:isVar public var pixelScale(get, never):Float;

	public function get_pixelScale():Float {
		return mPixelScale;
	}

	@:isVar public var pixelWidth(get, never):Int;

	public function get_pixelWidth():Int {
		return mWidth;
	}

	@:isVar public var pixelHeight(get, never):Int;

	public function get_pixelHeight():Int {
		return mHeight;
	}

	@:isVar public var isEmpty(get, never):Bool;

	public function get_isEmpty():Bool {
		return mEmpty;
	}

	@:isVar public var refCount(get, never):Int;

	public function get_refCount():Int {
		return mRefCount;
	}

	@:isVar public var alive(get, never):Bool;

	public function get_alive():Bool {
		return mTexture__Brain_Starling_SwfConverter_BakedCell != null;
	}

	public function opaqueAt(localX:Float, localY:Float, threshold:UInt = (16 : UInt)):Bool {
		if (mTexture__Brain_Starling_SwfConverter_BakedCell == null
			|| mPage__Brain_Starling_SwfConverter_BakedCell == null
			|| mPage__Brain_Starling_SwfConverter_BakedCell.pixels == null) {
			return false;
		}
		var _loc4_ = Math.floor(localX * mPixelScale);
		var _loc5_ = Math.floor(localY * mPixelScale);
		if (_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= mWidth || _loc5_ >= mHeight) {
			return false;
		}
		return ((mPage__Brain_Starling_SwfConverter_BakedCell.pixels.getPixel32(mSlotX + _loc4_, mSlotY + _loc5_) : Int) >>> 24 : UInt) > threshold;
	}
}
