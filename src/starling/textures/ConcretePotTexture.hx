package starling.textures;

import flash.display.BitmapData;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.utils.MathUtil;
import starling.utils.Execute;
import flash.errors.ArgumentError;

/*internal*/
class ConcretePotTexture extends ConcreteTexture {
	static var sAsyncUploadEnabled:Bool = false;

	static var sMatrix:Matrix = new Matrix();

	static var sRectangle:Rectangle = new Rectangle();

	static var sOrigin:Point = new Point();

	var _textureReadyCallback:ASFunction;

	public function new(base:Texture, format:String, width:Int, height:Int, mipMapping:Bool, premultipliedAlpha:Bool, optimizedForRenderTexture:Bool = false,
			scale:Float = 1) {
		super(base, format, width, height, mipMapping, premultipliedAlpha, optimizedForRenderTexture, scale);
		if (width != MathUtil.getNextPowerOfTwo(width)) {
			throw new ArgumentError("width must be a power of two");
		}
		if (height != MathUtil.getNextPowerOfTwo(height)) {
			throw new ArgumentError("height must be a power of two");
		}
	}

	@:allow(starling.textures) @:allow(starling.textures) @:isVar static var asyncUploadEnabled(get, set):Bool;

	static function get_asyncUploadEnabled():Bool {
		return sAsyncUploadEnabled;
	}

	static function set_asyncUploadEnabled(value:Bool):Bool {
		return sAsyncUploadEnabled = value;
	}

	override public function dispose() {
		base.removeEventListener("textureReady", onTextureReady);
		super.dispose();
	}

	override function createBase():TextureBase {
		return Starling.context.createTexture(ASCompat.floatToInt(nativeWidth), ASCompat.floatToInt(nativeHeight), format, optimizedForRenderTexture);
	}

	override public function uploadBitmapData(data:BitmapData, async:ASAny = null) {
		var _loc4_ = 0;
		var _loc7_ = 0;
		var _loc10_:BitmapData = null;
		var _loc5_ = 0;
		var _loc9_:Matrix = null;
		var _loc3_:BitmapData = null;
		var _loc8_:BitmapData = null;
		var _loc6_ = Reflect.isFunction(async) || async == true;
		if (Reflect.isFunction(async)) {
			_textureReadyCallback = ASCompat.asFunction(async);
		}
		if (data.width != nativeWidth || data.height != nativeHeight) {
			_loc8_ = new BitmapData(ASCompat.floatToInt(nativeWidth), ASCompat.floatToInt(nativeHeight), true, (0 : UInt));
			_loc8_.copyPixels(data, data.rect, sOrigin);
			data = _loc8_;
		}
		upload(data, (0 : UInt), _loc6_);
		if (mipMapping && data.width > 1 && data.height > 1) {
			_loc4_ = data.width >> 1;
			_loc7_ = data.height >> 1;
			_loc10_ = null;
			_loc5_ = 1;
			_loc9_ = sMatrix;
			_loc9_.setTo(0.5, 0, 0, 0.5, 0, 0);
			while (_loc4_ >= 1 || _loc7_ >= 1) {
				_loc3_ = new BitmapData(ASCompat.floatToInt(Math.max(1, _loc4_)), ASCompat.floatToInt(Math.max(1, _loc7_)), true, (0 : UInt));
				if (_loc5_ == 1) {
					_loc3_.draw(data, _loc9_, null, null, null, true);
				} else {
					_loc3_.draw(_loc10_, _loc9_, null, null, null, true);
					_loc10_.dispose();
				}
				_loc10_ = _loc3_;
				upload(_loc3_, (_loc5_++ : UInt), false);
				_loc4_ = _loc4_ >> 1;
				_loc7_ = _loc7_ >> 1;
			}
			if (_loc10_ != null) {
				_loc10_.dispose();
			}
		}
		if (_loc8_ != null) {
			_loc8_.dispose();
		}
		setDataUploaded();
	}

	override public function get_isPotTexture():Bool {
		return true;
	}

	override public function uploadAtfData(data:ByteArray, offset:Int = 0, async:ASAny = null) {
		var _loc4_ = Reflect.isFunction(async) || async == true;
		if (Reflect.isFunction(async)) {
			_textureReadyCallback = ASCompat.asFunction(async);
			base.addEventListener("textureReady", onTextureReady);
		}
		potBase.uploadCompressedTextureFromByteArray(data, (offset : UInt), _loc4_);
		setDataUploaded();
	}

	function upload(source:BitmapData, mipLevel:UInt, isAsync:Bool) {
		if (isAsync) {
			uploadAsync(source, mipLevel);
			base.addEventListener("textureReady", onTextureReady);
			base.addEventListener("error", onTextureReady);
		} else {
			potBase.uploadFromBitmapData(source, mipLevel);
		}
	}

	function uploadAsync(source:BitmapData, mipLevel:UInt) {
		if (sAsyncUploadEnabled) {
			try {
				(base : ASAny)["uploadFromBitmapDataAsync"](source, mipLevel);
			} catch (error:Dynamic) {
				if (!(error.errorID == 3708 || error.errorID == 1069)) {
					throw error;
				}
				sAsyncUploadEnabled = false;
			}
		}
		if (!sAsyncUploadEnabled) {
			ASCompat.setTimeout(base.dispatchEvent, 1, new Event("textureReady"));
			potBase.uploadFromBitmapData(source);
		}
	}

	function onTextureReady(event:Event) {
		base.removeEventListener("textureReady", onTextureReady);
		base.removeEventListener("error", onTextureReady);
		Execute.execute(_textureReadyCallback, this, ASCompat.reinterpretAs(event, ErrorEvent));
		_textureReadyCallback = null;
	}

	@:isVar var potBase(get, never):Texture;

	function get_potBase():Texture {
		return ASCompat.reinterpretAs(base, flash.display3D.textures.Texture);
	}
}
