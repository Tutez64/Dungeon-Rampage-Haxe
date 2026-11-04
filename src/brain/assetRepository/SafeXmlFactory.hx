package brain.assetRepository;

import starling.assets.AssetFactoryHelper;
import starling.assets.AssetReference;
import starling.assets.XmlFactory;

class SafeXmlFactory extends XmlFactory {
	public static inline final PRIORITY = 1;

	public function new() {
		super();
	}

	override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		super.create(reference, helper, function(param1:String, param2:compat.XML) {
			var textureName:String;
			var name = param1;
			var xml = param2;
			if (xml.localName() == "TextureAtlas") {
				textureName = helper.getNameFromUrl(xml.attribute("imagePath").toString());
				helper.addPostProcessor(function(param1:starling.assets.AssetManager) {
					if (param1.getTexture(textureName) == null) {
						onError("Cannot create atlas: texture \'" + textureName + "\' is missing");
					}
				}, 99);
			}
			onComplete(name, xml);
		}, onError);
	}
}
