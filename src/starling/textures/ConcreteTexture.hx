package starling.textures;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display3D.textures.TextureBase;
import flash.media.Camera;
import flash.net.NetStream;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.errors.AbstractClassError;
import starling.errors.AbstractMethodError;
import starling.errors.NotSupportedError;
import starling.utils.Color;
import starling.utils.Execute;

/*use*/ /*namespace*/ /*starling_internal*/ class ConcreteTexture extends Texture {
	var _base:TextureBase;

	var _format:String;

	var _width:Int = 0;

	var _height:Int = 0;

	var _mipMapping:Bool = false;

	var _premultipliedAlpha:Bool = false;

	var _optimizedForRenderTexture:Bool = false;

	var _scale:Float = Math.NaN;

	var _onRestore:ASFunction;

	var _dataUploaded:Bool = false;

	public function new(base:TextureBase, format:String, width:Int, height:Int, mipMapping:Bool, premultipliedAlpha:Bool,
			optimizedForRenderTexture:Bool = false, scale:Float = 1) {
		super();
		if (Capabilities.isDebugger && ASCompat.getQualifiedClassName(this) == "starling.textures::ConcreteTexture") {
			throw new AbstractClassError();
		}
		_scale = scale <= 0 ? 1 : scale;
		_base = base;
		_format = format;
		_width = width;
		_height = height;
		_mipMapping = mipMapping;
		_premultipliedAlpha = premultipliedAlpha;
		_optimizedForRenderTexture = optimizedForRenderTexture;
		_onRestore = null;
		_dataUploaded = false;
	}

	override public function dispose() {
		if (_base != null) {
			_base.dispose();
		}
		this.onRestore = null;
		super.dispose();
	}

	public function uploadBitmap(bitmap:Bitmap, async:ASAny = null) {
		uploadBitmapData(bitmap.bitmapData, async);
	}

	public function uploadBitmapData(data:BitmapData, async:ASAny = null) {
		throw new NotSupportedError();
	}

	public function uploadAtfData(data:ByteArray, offset:Int = 0, async:ASAny = null) {
		throw new NotSupportedError();
	}

	public function attachNetStream(netStream:NetStream, onComplete:ASFunction = null) {
		attachVideo("NetStream", netStream, onComplete);
	}

	public function attachCamera(camera:Camera, onComplete:ASFunction = null) {
		attachVideo("Camera", camera, onComplete);
	}

	@:allow(starling.textures) function attachVideo(type:String, attachment:ASObject, onComplete:ASFunction = null) {
		throw new NotSupportedError();
	}

	function onContextCreated() {
		_dataUploaded = false;
		_base = createBase();
		Execute.execute(_onRestore, this);
		if (!_dataUploaded) {
			clear();
		}
	}

	function createBase():TextureBase {
		throw new AbstractMethodError();
		return null;
	}

	/*starling_internal*/
	public function recreateBase() {
		_base = createBase();
	}

	public function clear(color:UInt = (0 : UInt), alpha:Float = 0) {
		if (_premultipliedAlpha && alpha < 1) {
			color = Color.rgb(ASCompat.floatToInt(Color.getRed(color) * alpha), ASCompat.floatToInt(Color.getGreen(color) * alpha),
				ASCompat.floatToInt(Color.getBlue(color) * alpha));
		}
		var _loc3_ = Starling.painter;
		_loc3_.pushState();
		_loc3_.state.renderTarget = this;
		try {
			_loc3_.clear(color, alpha);
		} catch (e:Dynamic) {}
		_loc3_.popState();
		setDataUploaded();
	}

	function setDataUploaded() {
		_dataUploaded = true;
	}

	@:isVar public var optimizedForRenderTexture(get, never):Bool;

	public function get_optimizedForRenderTexture():Bool {
		return _optimizedForRenderTexture;
	}

	@:isVar public var isPotTexture(get, never):Bool;

	public function get_isPotTexture():Bool {
		return false;
	}

	@:isVar public var onRestore(get, set):ASFunction;

	public function get_onRestore():ASFunction {
		return _onRestore;
	}

	function set_onRestore(value:ASFunction):ASFunction {
		Starling.current.removeEventListener("context3DCreate", (cast onContextCreated));
		if (value != null) {
			_onRestore = value;
			Starling.current.addEventListener("context3DCreate", (cast onContextCreated));
		} else {
			_onRestore = null;
		}
		return value;
	}

	override public function get_base():TextureBase {
		return _base;
	}

	override public function get_root():ConcreteTexture {
		return this;
	}

	override public function get_format():String {
		return _format;
	}

	override public function get_width():Float {
		return _width / _scale;
	}

	override public function get_height():Float {
		return _height / _scale;
	}

	override public function get_nativeWidth():Float {
		return _width;
	}

	override public function get_nativeHeight():Float {
		return _height;
	}

	override public function get_scale():Float {
		return _scale;
	}

	override public function get_mipMapping():Bool {
		return _mipMapping;
	}

	override public function get_premultipliedAlpha():Bool {
		return _premultipliedAlpha;
	}
}
