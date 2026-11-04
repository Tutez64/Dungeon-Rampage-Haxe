package starling.textures;

import flash.display.BitmapData;
import flash.display3D.textures.RectangleTexture;
import flash.display3D.textures.TextureBase;
import flash.events.ErrorEvent;
import flash.events.Event;
import starling.core.Starling;
import starling.utils.Execute;

/*internal*/
class ConcreteRectangleTexture extends ConcreteTexture {
	static var sAsyncUploadEnabled:Bool = false;

	var _textureReadyCallback:ASFunction;

	public function new(base:RectangleTexture, format:String, width:Int, height:Int, premultipliedAlpha:Bool, optimizedForRenderTexture:Bool = false,
			scale:Float = 1) {
		super(base, format, width, height, false, premultipliedAlpha, optimizedForRenderTexture, scale);
	}

	@:allow(starling.textures) @:allow(starling.textures) @:isVar static var asyncUploadEnabled(get, set):Bool;

	static function get_asyncUploadEnabled():Bool {
		return sAsyncUploadEnabled;
	}

	static function set_asyncUploadEnabled(value:Bool):Bool {
		return sAsyncUploadEnabled = value;
	}

	override public function uploadBitmapData(data:BitmapData, async:ASAny = null) {
		if (Reflect.isFunction(async)) {
			_textureReadyCallback = ASCompat.asFunction(async);
		}
		upload(data, async != null);
		setDataUploaded();
	}

	override function createBase():TextureBase {
		return Starling.context.createRectangleTexture(ASCompat.floatToInt(nativeWidth), ASCompat.floatToInt(nativeHeight), format, optimizedForRenderTexture);
	}

	@:isVar var rectBase(get, never):RectangleTexture;

	function get_rectBase():RectangleTexture {
		return ASCompat.reinterpretAs(base, RectangleTexture);
	}

	function upload(source:BitmapData, isAsync:Bool) {
		if (isAsync) {
			uploadAsync(source);
			base.addEventListener("textureReady", onTextureReady);
			base.addEventListener("error", onTextureReady);
		} else {
			rectBase.uploadFromBitmapData(source);
		}
	}

	function uploadAsync(source:BitmapData) {
		if (sAsyncUploadEnabled) {
			try {
				(base : ASAny)["uploadFromBitmapDataAsync"](source);
			} catch (error:Dynamic) {
				if (!(error.errorID == 3708 || error.errorID == 1069)) {
					throw error;
				}
				sAsyncUploadEnabled = false;
			}
		}
		if (!sAsyncUploadEnabled) {
			ASCompat.setTimeout(base.dispatchEvent, 1, new Event("textureReady"));
			rectBase.uploadFromBitmapData(source);
		}
	}

	function onTextureReady(event:Event) {
		base.removeEventListener("textureReady", onTextureReady);
		base.removeEventListener("error", onTextureReady);
		Execute.execute(_textureReadyCallback, this, ASCompat.reinterpretAs(event, ErrorEvent));
		_textureReadyCallback = null;
	}
}
