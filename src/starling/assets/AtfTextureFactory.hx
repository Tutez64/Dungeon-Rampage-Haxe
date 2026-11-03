package starling.assets;

import flash.utils.ByteArray;
import starling.textures.AtfData;
import starling.textures.Texture;
import starling.utils.Execute;

class AtfTextureFactory extends AssetFactory {
	public function new() {
		super();
		addExtensions("atf");
	}

	override public function canHandle(reference:AssetReference):Bool {
		return ASCompat.isByteArray(reference.data) && AtfData.isAtfData((reference.data : ByteArray));
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var onReloadError:String->Void = null;
		var createTexture = function() {
			var texture:Texture = null;
			var url:String;
			var onReady = ASCompat.asFunction(reference.textureOptions.onReady);
			reference.textureOptions.onReady = function() {
				Execute.execute(onReady, texture);
				onComplete(reference.name, texture);
			};
			texture = null;
			url = reference.url;
			try {
				texture = Texture.fromData(reference.data, reference.textureOptions);
			} catch (e:Dynamic) {
				onError(e.message);
			}
			if (ASCompat.stringAsBool(url) && texture != null) {
				texture.root.onRestore = function() {
					helper.onBeginRestore();
					helper.loadDataFromUrl(url, function(param1:ByteArray) {
						var data = param1;
						helper.executeWhenContextReady(function() {
							try {
								texture.root.uploadAtfData(data);
							} catch (e:Dynamic) {
								helper.log("Texture restoration failed: " + Std.string(e.message));
							}
							helper.onEndRestore();
						});
					}, onReloadError);
				};
			}
			reference.data = null;
		};
		onReloadError = function(param1:String) {
			helper.log("Texture restoration failed for " + reference.url + ". " + param1);
			helper.onEndRestore();
		};
		helper.executeWhenContextReady(createTexture);
	}
}
