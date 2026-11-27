package starling.assets;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import starling.textures.Texture;
import starling.textures.TextureOptions;
import starling.utils.ByteArrayUtil;
import starling.utils.Execute;

class BitmapTextureFactory extends AssetFactory {
	static var MAGIC_NUMBERS_JPG:Array<ASAny>;

	static var MAGIC_NUMBERS_PNG:Array<ASAny>;

	static var MAGIC_NUMBERS_GIF:Array<ASAny>;

	public function new() {
		super();
		addMimeTypes("image/png", "image/jpg", "image/jpeg", "image/gif");
		addExtensions("png", "jpg", "jpeg", "gif");
	}

	override public function canHandle(reference:AssetReference):Bool {
		var _loc2_:ByteArray = null;
		if (super.canHandle(reference) || Std.isOfType(reference.data, Bitmap) || Std.isOfType(reference.data, BitmapData)) {
			return true;
		}
		if (ASCompat.isByteArray(reference.data)) {
			_loc2_ = (reference.data : ByteArray);
			return ByteArrayUtil.startsWithBytes(_loc2_, MAGIC_NUMBERS_PNG)
				|| ByteArrayUtil.startsWithBytes(_loc2_, MAGIC_NUMBERS_JPG)
				|| ByteArrayUtil.startsWithBytes(_loc2_, MAGIC_NUMBERS_GIF);
		}
		return false;
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var createFromBitmapData:BitmapData->Void = null;
		var complete:() -> Void = null;
		var restoreTexture:() -> Void = null;
		var reload:(String, ASFunction) -> Void = null;
		var onReloadError:String->Void = null;
		var texture:Texture = null;
		var url:String = null;
		var name:String = null;
		var options:TextureOptions = null;
		var onReady:ASFunction = null;
		var onBitmapDataCreated = function(param1:BitmapData) {
			helper.executeWhenContextReady(createFromBitmapData, param1);
		};
		createFromBitmapData = function(param1:BitmapData) {
			options.onReady = complete;
			try {
				texture = Texture.fromData(param1, options);
			} catch (e:Dynamic) {
				onError(ASCompat.asError(e).message);
			}
			if (texture != null && ASCompat.stringAsBool(url)) {
				texture.root.onRestore = restoreTexture;
			}
		};
		complete = function() {
			Execute.execute(onReady, texture);
			onComplete(name, texture);
		};
		restoreTexture = function() {
			helper.onBeginRestore();
			reload(url, function(param1:BitmapData) {
				var bitmapData = param1;
				helper.executeWhenContextReady(function() {
					try {
						texture.root.uploadBitmapData(bitmapData);
					} catch (e:Dynamic) {
						helper.log("Texture restoration failed: " + ASCompat.asError(e).message);
					}
					helper.onEndRestore();
				});
			});
		};
		reload = function(param1:String, param2:ASFunction) {
			var url = param1;
			var onComplete = param2;
			helper.loadDataFromUrl(url, function(param1:ByteArray) {
				createBitmapDataFromByteArray(param1, onComplete, onReloadError);
			}, onReloadError);
		};
		onReloadError = function(param1:String) {
			helper.log("Texture restoration failed for " + url + ". " + param1);
			helper.onEndRestore();
		};
		texture = null;
		url = reference.url;
		var data:ASObject = reference.data;
		name = reference.name;
		options = reference.textureOptions;
		onReady = ASCompat.asFunction(reference.textureOptions.onReady);
		if (Std.isOfType(data, Bitmap)) {
			onBitmapDataCreated(ASCompat.dynamicAs(data, Bitmap).bitmapData);
		} else if (Std.isOfType(data, BitmapData)) {
			onBitmapDataCreated(ASCompat.dynamicAs(data, BitmapData));
		} else if (ASCompat.isByteArray(data)) {
			createBitmapDataFromByteArray((data : ByteArray), onBitmapDataCreated, onError);
		}
		reference.data = data = null;
	}

	function createBitmapDataFromByteArray(data:ByteArray, onComplete:ASFunction, onError:ASFunction) {
		var complete:BitmapData->Void = null;
		var cleanup:() -> Void = null;
		var loaderInfo:LoaderInfo = null;
		var loaderContext:LoaderContext;
		var onIoError = function(param1:flash.events.IOErrorEvent) {
			cleanup();
			Execute.execute(onError, param1.text);
		};
		var onLoaderComplete = function(param1:ASObject) {
			complete(param1.target.content.bitmapData);
		};
		complete = function(param1:BitmapData) {
			cleanup();
			Execute.execute(onComplete, param1);
		};
		cleanup = function() {
			loaderInfo.removeEventListener("ioError", onIoError);
			loaderInfo.removeEventListener("complete", onLoaderComplete);
		};
		var loader = new Loader();
		loaderInfo = loader.contentLoaderInfo;
		loaderInfo.addEventListener("ioError", onIoError);
		loaderInfo.addEventListener("complete", onLoaderComplete);
		loaderContext = new LoaderContext();
		loaderContext.imageDecodingPolicy = "onLoad";
		loader.loadBytes(data, loaderContext);
	}

	static function __init__() {
		MAGIC_NUMBERS_JPG = [255, 216];
		MAGIC_NUMBERS_PNG = [137, 80, 78, 71, 13, 10, 26, 10];
		MAGIC_NUMBERS_GIF = [71, 73, 70, 56];
	}
}
