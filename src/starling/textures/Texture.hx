package starling.textures;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.textures.RectangleTexture;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.display3D.textures.VideoTexture;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Camera;
import flash.net.NetStream;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.errors.AbstractClassError;
import starling.errors.MissingContextError;
import starling.errors.NotSupportedError;
import starling.rendering.VertexData;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.SystemUtil;
import starling.utils.Execute;
import flash.errors.ArgumentError;

class Texture {
	static var sDefaultOptions:TextureOptions = new TextureOptions();

	static var sRectangle:Rectangle = new Rectangle();

	static var sMatrix:Matrix = new Matrix();

	static var sPoint:Point = new Point();

	public function new() {
		if (Capabilities.isDebugger && ASCompat.getQualifiedClassName(this) == "starling.textures::Texture") {
			throw new AbstractClassError();
		}
	}

	public static function fromData(data:ASObject, options:TextureOptions = null):Texture {
		if (Std.isOfType(data, Bitmap)) {
			data = ASCompat.dynamicAs(data, Bitmap).bitmapData;
		}
		if (options == null) {
			options = sDefaultOptions;
		}
		if (Std.isOfType(data, Class)) {
			return fromEmbeddedAsset((data : Dynamic), options.mipMapping, options.optimizeForRenderToTexture, options.scale, options.format,
				options.forcePotTexture);
		}
		if (Std.isOfType(data, BitmapData)) {
			return fromBitmapData(ASCompat.dynamicAs(data, BitmapData), options.mipMapping, options.optimizeForRenderToTexture, options.scale, options.format,
				options.forcePotTexture, options.onReady);
		}
		if (ASCompat.isByteArray(data)) {
			return fromAtfData((data : ByteArray), options.scale, options.mipMapping, options.onReady);
		}
		throw new ArgumentError("Unsupported \'data\' type: " + ASCompat.getQualifiedClassName(data));
		return null;
	}

	public static function fromTextureBase(base:TextureBase, width:Int, height:Int, options:TextureOptions = null):ConcreteTexture {
		if (options == null) {
			options = sDefaultOptions;
		}
		if (Std.isOfType(base, flash.display3D.textures.Texture)) {
			return new ConcretePotTexture(ASCompat.reinterpretAs(base, flash.display3D.textures.Texture), options.format, width, height, options.mipMapping,
				options.premultipliedAlpha, options.optimizeForRenderToTexture, options.scale);
		}
		if (Std.isOfType(base, RectangleTexture)) {
			return new ConcreteRectangleTexture(ASCompat.reinterpretAs(base, RectangleTexture), options.format, width, height, options.premultipliedAlpha,
				options.optimizeForRenderToTexture, options.scale);
		}
		if (Std.isOfType(base, VideoTexture)) {
			return new ConcreteVideoTexture(ASCompat.reinterpretAs(base, VideoTexture), options.scale);
		}
		throw new ArgumentError("Unsupported \'base\' type: " + ASCompat.getQualifiedClassName(base));
		return null;
	}

	public static function fromEmbeddedAsset(assetClass:Dynamic, mipMapping:Bool = false, optimizeForRenderToTexture:Bool = false, scale:Float = 1,
			format:String = "bgra", forcePotTexture:Bool = false):Texture {
		var texture:Texture;
		var asset:ASObject = ASCompat.createInstance(assetClass, []);
		if (Std.isOfType(asset, Bitmap)) {
			texture = starling.textures.Texture.fromBitmap(ASCompat.dynamicAs(asset, Bitmap), mipMapping, optimizeForRenderToTexture, scale, format,
				forcePotTexture);
			texture.root.onRestore = function() {
				texture.root.uploadBitmap(ASCompat.coerce(ASCompat.createInstance(assetClass, []), flash.display.Bitmap));
			};
		} else if (Std.isOfType(asset, BitmapData)) {
			texture = starling.textures.Texture.fromBitmapData(ASCompat.dynamicAs(asset, BitmapData), mipMapping, optimizeForRenderToTexture, scale, format,
				forcePotTexture);
			texture.root.onRestore = function() {
				texture.root.uploadBitmapData(ASCompat.coerce(ASCompat.createInstance(assetClass, []), flash.display.BitmapData));
			};
		} else {
			if (!ASCompat.isByteArray(asset)) {
				throw new ArgumentError("Invalid asset type: " + ASCompat.getQualifiedClassName(asset));
			}
			texture = starling.textures.Texture.fromAtfData((asset : ByteArray), scale, mipMapping, null);
			texture.root.onRestore = function() {
				texture.root.uploadAtfData(ASCompat.asByteArray(ASCompat.createInstance(assetClass, [])));
			};
		}
		asset = null;
		return texture;
	}

	public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Bool = false, optimizeForRenderToTexture:Bool = false, scale:Float = 1,
			format:String = "bgra", forcePotTexture:Bool = false, async:ASFunction = null):Texture {
		return fromBitmapData(bitmap.bitmapData, generateMipMaps, optimizeForRenderToTexture, scale, format, forcePotTexture, async);
	}

	public static function fromBitmapData(data:BitmapData, generateMipMaps:Bool = false, optimizeForRenderToTexture:Bool = false, scale:Float = 1,
			format:String = "bgra", forcePotTexture:Bool = false, async:ASFunction = null):Texture {
		var texture = starling.textures.Texture.empty(data.width / scale, data.height / scale, true, generateMipMaps, optimizeForRenderToTexture, scale,
			format, forcePotTexture);
		texture.root.uploadBitmapData(data, async != null ? function() {
			Execute.execute(async, texture);
		} : null);
		texture.root.onRestore = function() {
			texture.root.uploadBitmapData(data);
		};
		return texture;
	}

	public static function fromAtfData(data:ByteArray, scale:Float = 1, useMipMaps:Bool = true, async:ASFunction = null,
			premultipliedAlpha:Bool = false):Texture {
		var atfData:AtfData;
		var nativeTexture:flash.display3D.textures.Texture;
		var concreteTexture:ConcreteTexture;
		var context = Starling.context;
		if (context == null) {
			throw new MissingContextError();
		}
		atfData = new AtfData(data);
		nativeTexture = context.createTexture(atfData.width, atfData.height, atfData.format, false);
		concreteTexture = new ConcretePotTexture(nativeTexture, atfData.format, atfData.width, atfData.height, useMipMaps && atfData.numTextures > 1,
			premultipliedAlpha, false, scale);
		concreteTexture.uploadAtfData(data, 0, async);
		concreteTexture.onRestore = function() {
			concreteTexture.uploadAtfData(data, 0);
		};
		return concreteTexture;
	}

	public static function fromNetStream(stream:NetStream, scale:Float = 1, onComplete:ASFunction = null):Texture {
		if (stream.client == stream && !(stream : ASAny).hasOwnProperty("onMetaData")) {
			stream.client = {
				"onMetaData": function(param1:ASObject) {}
			};
		}
		return fromVideoAttachment("NetStream", stream, scale, onComplete);
	}

	public static function fromCamera(camera:Camera, scale:Float = 1, onComplete:ASFunction = null):Texture {
		return fromVideoAttachment("Camera", camera, scale, onComplete);
	}

	static function fromVideoAttachment(type:String, attachment:ASObject, scale:Float, onComplete:ASFunction):Texture {
		var context:Context3D;
		var base:VideoTexture;
		var texture:ConcreteTexture;
		if (!SystemUtil.supportsVideoTexture) {
			throw new NotSupportedError("Video Textures are not supported on this platform");
		}
		context = Starling.context;
		if (context == null) {
			throw new MissingContextError();
		}
		base = context.createVideoTexture();
		texture = new ConcreteVideoTexture(base, scale);
		texture.attachVideo(type, attachment, onComplete);
		texture.onRestore = function() {
			texture.root.attachVideo(type, attachment);
		};
		return texture;
	}

	public static function fromColor(width:Float, height:Float, color:UInt = (16777215 : UInt), alpha:Float = 1, optimizeForRenderToTexture:Bool = false,
			scale:Float = -1, format:String = "bgra", forcePotTexture:Bool = false):Texture {
		var texture = starling.textures.Texture.empty(width, height, true, false, optimizeForRenderToTexture, scale, format, forcePotTexture);
		texture.root.clear(color, alpha);
		texture.root.onRestore = function() {
			texture.root.clear(color, alpha);
		};
		return texture;
	}

	public static function empty(width:Float, height:Float, premultipliedAlpha:Bool = true, mipMapping:Bool = false, optimizeForRenderToTexture:Bool = false,
			scale:Float = -1, format:String = "bgra", forcePotTexture:Bool = false):Texture {
		var _loc11_ = 0;
		var _loc10_ = 0;
		var _loc13_:TextureBase = null;
		var _loc14_:ConcreteTexture = null;
		if (scale <= 0) {
			scale = Starling.contentScaleFactor;
		}
		var _loc15_ = Starling.context;
		if (_loc15_ == null) {
			throw new MissingContextError();
		}
		var _loc16_ = width * scale;
		var _loc9_ = height * scale;
		var _loc12_ = !forcePotTexture
			&& !mipMapping
			&& Starling.current.profile != "baselineConstrained"
			&& format.indexOf("compressed") == -1;
		if (_loc12_) {
			_loc10_ = Math.ceil(_loc16_ - 1e-9);
			_loc11_ = Math.ceil(_loc9_ - 1e-9);
			_loc13_ = _loc15_.createRectangleTexture(_loc10_, _loc11_, format, optimizeForRenderToTexture);
			_loc14_ = new ConcreteRectangleTexture(ASCompat.reinterpretAs(_loc13_, RectangleTexture), format, _loc10_, _loc11_, premultipliedAlpha,
				optimizeForRenderToTexture, scale);
		} else {
			_loc10_ = MathUtil.getNextPowerOfTwo(_loc16_);
			_loc11_ = MathUtil.getNextPowerOfTwo(_loc9_);
			_loc13_ = _loc15_.createTexture(_loc10_, _loc11_, format, optimizeForRenderToTexture);
			_loc14_ = new ConcretePotTexture(ASCompat.reinterpretAs(_loc13_, flash.display3D.textures.Texture), format, _loc10_, _loc11_, mipMapping,
				premultipliedAlpha, optimizeForRenderToTexture, scale);
		}
		_loc14_.onRestore = _loc14_.clear;
		if (_loc10_ - _loc16_ < 0.001 && _loc11_ - _loc9_ < 0.001) {
			return _loc14_;
		}
		return new SubTexture(_loc14_, new Rectangle(0, 0, width, height), true);
	}

	public static function fromTexture(texture:Texture, region:Rectangle = null, frame:Rectangle = null, rotated:Bool = false,
			scaleModifier:Float = 1):Texture {
		return new SubTexture(texture, region, false, frame, rotated, scaleModifier);
	}

	@:isVar public static var maxSize(get, never):Int;

	static public function get_maxSize():Int {
		return getMaxSize();
	}

	public static function getMaxSize(textureFormat:String = "bgra"):Int {
		var _loc5_ = Starling.current;
		var _loc3_ = _loc5_._context;
		var _loc2_ = _loc5_ != null ? _loc5_.profile : "baseline";
		var _loc4_ = textureFormat == "compressed" || textureFormat == "compressedAlpha";
		if (_loc2_ == "baseline" || _loc2_ == "baselineConstrained") {
			return 2048;
		}
		if (!_loc4_
			&& _loc3_ != null
			&& (_loc3_ : ASAny).hasOwnProperty("supports8kTexture") && ASCompat.toBool((_loc3_ : ASAny)["supports8kTexture"])) {
			return 8192;
		}
		return 4096;
	}

	@:isVar public static var asyncBitmapUploadEnabled(get, set):Bool;

	static public function get_asyncBitmapUploadEnabled():Bool {
		return ConcreteRectangleTexture.asyncUploadEnabled;
	}

	static function set_asyncBitmapUploadEnabled(value:Bool):Bool {
		ConcreteRectangleTexture.asyncUploadEnabled = value;
		return ConcretePotTexture.asyncUploadEnabled = value;
	}

	public function dispose() {}

	public function setupVertexPositions(vertexData:VertexData, vertexID:Int = 0, attrName:String = "position", bounds:Rectangle = null) {
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc8_ = this.frame;
		var _loc7_ = this.width;
		var _loc9_ = this.height;
		if (_loc8_ != null) {
			sRectangle.setTo(-_loc8_.x, -_loc8_.y, _loc7_, _loc9_);
		} else {
			sRectangle.setTo(0, 0, _loc7_, _loc9_);
		}
		vertexData.setPoint(vertexID, attrName, sRectangle.left, sRectangle.top);
		vertexData.setPoint(vertexID + 1, attrName, sRectangle.right, sRectangle.top);
		vertexData.setPoint(vertexID + 2, attrName, sRectangle.left, sRectangle.bottom);
		vertexData.setPoint(vertexID + 3, attrName, sRectangle.right, sRectangle.bottom);
		if (bounds != null) {
			_loc5_ = bounds.width / frameWidth;
			_loc6_ = bounds.height / frameHeight;
			if (_loc5_ != 1 || _loc6_ != 1 || bounds.x != 0 || bounds.y != 0) {
				sMatrix.identity();
				sMatrix.scale(_loc5_, _loc6_);
				sMatrix.translate(bounds.x, bounds.y);
				vertexData.transformPoints(attrName, sMatrix, vertexID, 4);
			}
		}
	}

	public function setupTextureCoordinates(vertexData:VertexData, vertexID:Int = 0, attrName:String = "texCoords") {
		setTexCoords(vertexData, vertexID, attrName, 0, 0);
		setTexCoords(vertexData, vertexID + 1, attrName, 1, 0);
		setTexCoords(vertexData, vertexID + 2, attrName, 0, 1);
		setTexCoords(vertexData, vertexID + 3, attrName, 1, 1);
	}

	public function localToGlobal(u:Float, v:Float, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		if (this == root) {
			out.setTo(u, v);
		} else {
			MatrixUtil.transformCoords(transformationMatrixToRoot, u, v, out);
		}
		return out;
	}

	public function globalToLocal(u:Float, v:Float, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		if (this == root) {
			out.setTo(u, v);
		} else {
			sMatrix.identity();
			sMatrix.copyFrom(transformationMatrixToRoot);
			sMatrix.invert();
			MatrixUtil.transformCoords(sMatrix, u, v, out);
		}
		return out;
	}

	public function setTexCoords(vertexData:VertexData, vertexID:Int, attrName:String, u:Float, v:Float) {
		localToGlobal(u, v, sPoint);
		vertexData.setPoint(vertexID, attrName, sPoint.x, sPoint.y);
	}

	public function getTexCoords(vertexData:VertexData, vertexID:Int, attrName:String = "texCoords", out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		vertexData.getPoint(vertexID, attrName, out);
		return globalToLocal(out.x, out.y, out);
	}

	@:isVar public var frame(get, never):Rectangle;

	public function get_frame():Rectangle {
		return null;
	}

	@:isVar public var frameWidth(get, never):Float;

	public function get_frameWidth():Float {
		return frame != null ? frame.width : width;
	}

	@:isVar public var frameHeight(get, never):Float;

	public function get_frameHeight():Float {
		return frame != null ? frame.height : height;
	}

	@:isVar public var width(get, never):Float;

	public function get_width():Float {
		return 0;
	}

	@:isVar public var height(get, never):Float;

	public function get_height():Float {
		return 0;
	}

	@:isVar public var nativeWidth(get, never):Float;

	public function get_nativeWidth():Float {
		return 0;
	}

	@:isVar public var nativeHeight(get, never):Float;

	public function get_nativeHeight():Float {
		return 0;
	}

	@:isVar public var scale(get, never):Float;

	public function get_scale():Float {
		return 1;
	}

	@:isVar public var base(get, never):TextureBase;

	public function get_base():TextureBase {
		return null;
	}

	@:isVar public var root(get, never):ConcreteTexture;

	public function get_root():ConcreteTexture {
		return null;
	}

	@:isVar public var format(get, never):String;

	public function get_format():String {
		return "bgra";
	}

	@:isVar public var mipMapping(get, never):Bool;

	public function get_mipMapping():Bool {
		return false;
	}

	@:isVar public var premultipliedAlpha(get, never):Bool;

	public function get_premultipliedAlpha():Bool {
		return false;
	}

	@:isVar public var transformationMatrix(get, never):Matrix;

	public function get_transformationMatrix():Matrix {
		return null;
	}

	@:isVar public var transformationMatrixToRoot(get, never):Matrix;

	public function get_transformationMatrixToRoot():Matrix {
		return null;
	}
}
