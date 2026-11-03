package brain.starling.swfConverter;

import starling.textures.Texture;

class BakedCell {
	@:allow(Brain.Starling.SwfConverter) var mKey:String;

	@:allow(Brain.Starling.SwfConverter) var mPage:BakedPage;

	@:allow(Brain.Starling.SwfConverter) var mTexture:Texture;

	@:allow(Brain.Starling.SwfConverter) var mRefCount:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mPixelScale:Float = 1;

	@:allow(Brain.Starling.SwfConverter) var mOriginX:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mOriginY:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mEmpty:Bool = false;

	@:allow(Brain.Starling.SwfConverter) var mSlotX:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mSlotY:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mSlotWidth:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mWidth:Int = 0;

	@:allow(Brain.Starling.SwfConverter) var mHeight:Int = 0;

	public function new() {}

	@:isVar public var key(get, never):String;

	public function get_key():String {
		return mKey;
	}

	@:isVar public var texture(get, never):Texture;

	public function get_texture():Texture {
		return mTexture;
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
		return mTexture != null;
	}

	public function opaqueAt(localX:Float, localY:Float, threshold:UInt = (16 : UInt)):Bool {
		if (mTexture == null || mPage == null || mPage.pixels == null) {
			return false;
		}
		var _loc4_ = Math.floor(localX * mPixelScale);
		var _loc5_ = Math.floor(localY * mPixelScale);
		if (_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= mWidth || _loc5_ >= mHeight) {
			return false;
		}
		return ((mPage.pixels.getPixel32(mSlotX + _loc4_, mSlotY + _loc5_) : Int) >>> 24 : UInt) > threshold;
	}
}
