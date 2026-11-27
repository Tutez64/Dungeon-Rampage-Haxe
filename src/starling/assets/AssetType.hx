package starling.assets;

import flash.media.Sound;
import starling.errors.AbstractClassError;
import starling.text.BitmapFont;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class AssetType {
	public static inline final TEXTURE = "texture";

	public static inline final TEXTURE_ATLAS = "textureAtlas";

	public static inline final SOUND = "sound";

	public static inline final XML_DOCUMENT = "xml";

	public static inline final OBJECT = "object";

	public static inline final BYTE_ARRAY = "byteArray";

	public static inline final BITMAP_FONT = "bitmapFont";

	public static inline final ASSET_MANAGER = "assetManager";

	public function new() {
		throw new AbstractClassError();
	}

	public static function fromAsset(asset:ASObject):String {
		if (Std.isOfType(asset, Texture)) {
			return "texture";
		}
		if (Std.isOfType(asset, TextureAtlas)) {
			return "textureAtlas";
		}
		if (Std.isOfType(asset, Sound)) {
			return "sound";
		}
		if (Std.isOfType(asset, compat.XML.typeReference())) {
			return "xml";
		}
		if (ASCompat.isByteArray(asset)) {
			return "byteArray";
		}
		if (Std.isOfType(asset, BitmapFont)) {
			return "bitmapFont";
		}
		if (Std.isOfType(asset, AssetManager)) {
			return "assetManager";
		}
		return "object";
	}
}
