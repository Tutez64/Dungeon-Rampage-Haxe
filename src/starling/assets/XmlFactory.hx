package starling.assets;

import flash.utils.ByteArray;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.TextureAtlas;
import starling.utils.ByteArrayUtil;

class XmlFactory extends AssetFactory {
	public function new() {
		super();
		addMimeTypes("application/xml", "text/xml");
		addExtensions("xml", "fnt");
	}

	override public function canHandle(reference:AssetReference):Bool {
		return super.canHandle(reference)
			|| ASCompat.isByteArray(reference.data)
			&& ByteArrayUtil.startsWithString((reference.data : ByteArray), "<");
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var xml:compat.XML = null;
		var rootNode:String;
		var textureAtlasPostProcessor = function(param1:AssetManager) {
			var _loc3_ = helper.getNameFromUrl(xml.attribute("imagePath").toString());
			var _loc2_ = param1.getTexture(_loc3_);
			if (_loc2_ != null) {
				param1.addAsset(_loc3_, new TextureAtlas(_loc2_, xml));
			} else {
				helper.log("Cannot create atlas: texture \'" + _loc3_ + "\' is missing.");
			}
		};
		var bitmapFontPostProcessor = function(param1:AssetManager) {
			var _loc5_:BitmapFont = null;
			var _loc4_ = helper.getNameFromUrl(xml.child("pages").child("page").attribute("file").toString());
			var _loc3_ = param1.getTexture(_loc4_);
			var _loc2_ = param1.registerBitmapFontsWithFontFace ? xml.child("info").attribute("face").toString() : _loc4_;
			if (_loc3_ != null) {
				_loc5_ = new BitmapFont(_loc3_, xml);
				param1.addAsset(_loc2_, _loc5_);
				TextField.registerCompositor(_loc5_, _loc2_);
			} else {
				helper.log("Cannot create bitmap font: texture \'" + _loc4_ + "\' is missing.");
			}
		};
		xml = ASCompat.asXML(reference.data);
		var bytes = (reference.data : ByteArray);
		if (bytes != null) {
			try {
				xml = new compat.XML(ASCompat.toString(bytes));
			} catch (e:Dynamic) {
				onError("Could not parse XML: " + Std.string(e.message));
				return;
			}
		}
		rootNode = xml.localName();
		if (rootNode == "TextureAtlas") {
			helper.addPostProcessor(textureAtlasPostProcessor, 100);
		} else if (rootNode == "font") {
			helper.addPostProcessor(bitmapFontPostProcessor);
		}
		onComplete(reference.name, xml);
		reference.data = bytes = null;
	}
}
