package starling.extensions.animate;

import starling.assets.AssetFactoryHelper;
import starling.assets.AssetReference;
import starling.assets.JsonFactory;
import starling.textures.TextureAtlas;

/*internal*/
class AnimationAtlasFactory extends JsonFactory {
	public static inline final ANIMATION_SUFFIX = "_animation";

	public static inline final SPRITEMAP_SUFFIX = "_spritemap";

	static final SPRITEMAP_REGEX:compat.RegExp = new compat.RegExp("^spritemap(\\d*)$");

	static final ANIMATION_SUFFIX_REGEX:compat.RegExp = new compat.RegExp("_animation$");

	static final SPRITEMAP_SUFFIX_REGEX:compat.RegExp = new compat.RegExp("_spritemap\\d*$");

	public function new() {
		super();
	}

	@:allow(starling.extensions.animate) static function getName(url:String, stdName:String, addSuffix:Bool):String {
		var _loc5_:Array<ASAny> = null;
		var _loc7_:String = null;
		var _loc8_ = "/";
		if (url == null) {
			if (addSuffix) {
				return stdName;
			}
			stdName = ANIMATION_SUFFIX_REGEX.replace(stdName, "");
			stdName = SPRITEMAP_SUFFIX_REGEX.replace(stdName, "");
		}
		var _loc4_ = stdName == "Animation";
		var _loc6_:Array<ASAny> = (cast _loc4_ ? null : (cast SPRITEMAP_REGEX.match(stdName)));
		if ((_loc4_ || _loc6_ != null) && url.indexOf(_loc8_) != -1) {
			_loc5_ = (cast url.split(_loc8_));
			_loc7_ = _loc5_[_loc5_.length - 2];
			if (!addSuffix) {
				return _loc7_;
			}
			return _loc4_ ? _loc7_ + "_animation" : _loc7_ + "_spritemap" + Std.string(_loc6_[1]);
		}
		return stdName;
	}

	@:allow(starling.extensions.animate) static function isSpritemapName(stdName:String):Bool {
		return SPRITEMAP_REGEX.test(stdName);
	}

	static function describeMissingSheets(baseName:String, json:ASObject, atlas:TextureAtlas):String {
		var _loc5_ = declaredSheetCount(json);
		if (_loc5_ <= 0) {
			return null;
		}
		var _loc4_ = Std.isOfType(atlas, MultiTextureAtlas) ? cast(atlas, MultiTextureAtlas).numTextures : 1;
		if (_loc4_ == _loc5_) {
			return null;
		}
		return "\'" + baseName + "\' expected " + _loc5_ + " spritemap(s) but the atlas holds " + _loc4_;
	}

	static function declaredSheetCount(json:ASObject):Int {
		var _loc2_:ASObject = if (ASCompat.toBool(json.MD)) json.MD else json.metadata;
		return _loc2_ != null ? ASCompat.toInt(ASCompat.orValue(if (ASCompat.toBool(_loc2_.SMC)) _loc2_.SMC else _loc2_.spritemapCount, 0)) : 0;
	}

	override public function create(asset:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {
		var onObjectComplete = function(param1:String, param2:ASObject) {
			var name = param1;
			var json:ASObject = param2;
			var baseName = getName(asset.url, name, false);
			var fullName = getName(asset.url, name, true);
			if (ASCompat.toBool(json.ATLAS) && ASCompat.toBool(json.meta)) {
				helper.addPostProcessor(function(param1:starling.assets.AssetManager) {
					var _loc2_ = param1.getTexture(fullName);
					if (_loc2_ == null) {
						onError("Missing texture " + fullName);
						return;
					}
					var _loc3_ = ASCompat.reinterpretAs(param1.getTextureAtlas(baseName), MultiTextureAtlas);
					if (_loc3_ == null) {
						_loc3_ = new MultiTextureAtlas();
						param1.addAsset(baseName, _loc3_);
					}
					try {
						_loc3_.addSheet(fullName, _loc2_, json);
					} catch (e:Dynamic) {
						_loc3_.removeSheet(fullName);
						onError("Failed to add sheet \'" + fullName + "\': " + ASCompat.asError(e).message);
						return;
					}
					param1.removeObject(fullName);
				}, 100);
			} else if (ASCompat.toBool(json.ANIMATION)
				&& ASCompat.toBool(json.SYMBOL_DICTIONARY)
				|| ASCompat.toBool(json.AN)
				&& ASCompat.toBool(json.SD)) {
				helper.addPostProcessor(function(param1:starling.assets.AssetManager) {
					var _loc2_ = param1.getTextureAtlas(baseName);
					if (_loc2_ == null) {
						onError("Missing texture atlas " + baseName);
						return;
					}
					var _loc3_ = describeMissingSheets(baseName, json, _loc2_);
					if (_loc3_ != null) {
						onError(_loc3_);
						return;
					}
					if (Std.isOfType(_loc2_, MultiTextureAtlas)) {
						cast(_loc2_, MultiTextureAtlas).declaredSheets = declaredSheetCount(json);
					}
					try {
						param1.addAsset(baseName, new AnimationAtlas(json, _loc2_), "animationAtlas");
					} catch (e:Dynamic) {
						onError("Failed to create animation atlas \'" + baseName + "\': " + ASCompat.asError(e).message);
					}
				});
			}
			onComplete(fullName, json);
		};
		super.create(asset, helper, onObjectComplete, onError);
	}
}
