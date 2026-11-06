package brain.assetRepository;

import flash.display3D.textures.TextureBase;
import flash.events.ErrorEvent;
import starling.assets.AssetFactoryHelper;
import starling.assets.AssetReference;
import starling.assets.AtfTextureFactory;
import starling.textures.Texture;
import starling.utils.Execute;

class SafeAtfTextureFactory extends AtfTextureFactory {
	public static inline final PRIORITY = 1;

	public function new() {
		super();
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var createTexture = function() {
			var onUploadError:ErrorEvent->Void = null;
			var onReloadError:String->Void = null;
			var onReady:ASFunction = null;
			var texture:Texture = null;
			var base:TextureBase = null;
			var settled = false;
			var url:String = null;
			var settle = function():Bool {
				if (settled) {
					return false;
				}
				settled = true;
				return true;
			};
			var onUploadReady = function() {
				base.removeEventListener("error", onUploadError);
				if (ASCompat.toBool(settle())) {
					Execute.execute(onReady, texture);
					onComplete(reference.name, texture);
				} else {
					texture.dispose();
				}
			};
			onUploadError = function(param1:ErrorEvent) {
				base.removeEventListener("error", onUploadError);
				texture.dispose();
				if (ASCompat.toBool(settle())) {
					onError("Error #" + param1.errorID + ": " + param1.text);
				}
			};
			var restoreTexture = function() {
				helper.onBeginRestore();
				helper.loadDataFromUrl(url, function(param1:flash.utils.ByteArray) {
					var data = param1;
					helper.executeWhenContextReady(function() {
						try {
							texture.root.uploadAtfData(data);
						} catch (e:Dynamic) {
							helper.log("Texture restoration failed: " + ASCompat.asError(e).message);
						}
						helper.onEndRestore();
					});
				}, onReloadError);
			};
			onReloadError = function(param1:String) {
				helper.log("Texture restoration failed for " + url + ". " + param1);
				helper.onEndRestore();
			};
			onReady = ASCompat.asFunction(reference.textureOptions.onReady);
			texture = null;
			base = null;
			settled = false;
			url = reference.url;
			reference.textureOptions.onReady = onUploadReady;
			try {
				texture = Texture.fromData(reference.data, reference.textureOptions);
			} catch (e:Dynamic) {
				onError(ASCompat.asError(e).message);
			}
			if (texture != null) {
				base = texture.root.base;
				base.addEventListener("error", onUploadError);
				if (ASCompat.stringAsBool(url)) {
					texture.root.onRestore = restoreTexture;
				}
			}
			reference.data = null;
		};
		helper.executeWhenContextReady(createTexture);
	}
}
