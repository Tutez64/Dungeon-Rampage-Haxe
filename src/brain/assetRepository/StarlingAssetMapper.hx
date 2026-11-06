package brain.assetRepository;

import flash.filesystem.File;

class StarlingAssetMapper {
	public static inline final SHARED_KEY = "shared";

	public static inline final PROPS_ONLY_KEY_PREFIX = "props:";

	static inline final mSharedPropDir = "Resources/Art2D/Environments/shared/props/db_prop_shared_library/";

	public static inline final PROP_MANIFEST_FILE = "flattened_registration.json";

	static var mBiomeMap:ASObject;

	static var mPropMap:ASObject;

	static var mActorAtlasFilePathCache:ASObject;

	static var mPropAtlasFolders:ASObject;

	public function new() {}

	public static function getBiomeKeyFromPath(inPath:String):String {
		var _loc4_ = inPath.lastIndexOf("/");
		var _loc2_ = inPath.lastIndexOf("_");
		var _loc3_ = inPath.substring(_loc4_ + 1, _loc2_);
		var _loc5_ = _loc3_.indexOf("_", _loc3_.indexOf("_") + 1);
		return _loc3_.substring(_loc5_ + 1);
	}

	public static function isPropLibraryPath(inPath:String):Bool {
		if (inPath == null || inPath.substring(inPath.lastIndexOf("/") + 1).indexOf("db_prop_") != 0) {
			return false;
		}
		var _loc2_ = getBiomeKeyFromPath(inPath);
		return _loc2_ == "shared" || mPropMap.hasOwnProperty(_loc2_);
	}

	public static function getPropLibraryKey(libraryPath:String, floorBiomeKey:String):String {
		var _loc3_ = getBiomeKeyFromPath(libraryPath);
		if (floorBiomeKey == null || _loc3_ == floorBiomeKey || _loc3_ == "shared" || !isPropLibraryPath(libraryPath)) {
			return _loc3_;
		}
		return getPropsOnlyKey(_loc3_);
	}

	public static function getPropsOnlyKey(biomeKey:String):String {
		return "props:" + biomeKey;
	}

	static function getPropsOnlyBiome(key:String):String {
		return key.indexOf("props:") == 0 ? key.substring("props:".length) : null;
	}

	public static function isKnownBiome(biomeKey:String):Bool {
		var _loc2_ = getPropsOnlyBiome(biomeKey);
		if (_loc2_ != null) {
			return mPropMap.hasOwnProperty(_loc2_);
		}
		return mBiomeMap.hasOwnProperty(biomeKey) || mPropMap.hasOwnProperty(biomeKey) || biomeKey == "shared";
	}

	public static function getAssetFilesForBiome(biomeKey:String, includeShared:Bool):Array<ASAny> {
		var _loc4_:Array<ASAny> = [];
		var _loc3_ = getPropsOnlyBiome(biomeKey);
		if (_loc3_ != null) {
			_loc4_.push(AssetLoader.resolveFile(mPropMap[_loc3_]));
			return _loc4_;
		}
		if (mBiomeMap.hasOwnProperty(biomeKey)) {
			_loc4_.push(AssetLoader.resolveFile(mBiomeMap[biomeKey]));
		}
		if (mPropMap.hasOwnProperty(biomeKey)) {
			_loc4_.push(AssetLoader.resolveFile(mPropMap[biomeKey]));
		}
		if (includeShared || biomeKey == "shared") {
			_loc4_.push(AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/"));
		}
		return _loc4_;
	}

	public static function getActorAtlasKeyFromPath(assetClassPath:String):String {
		if (assetClassPath == null || new compat.RegExp("\\.swf$", "i").match(assetClassPath) == null) {
			return null;
		}
		var _loc2_ = assetClassPath.lastIndexOf("/") + 1;
		var _loc3_ = assetClassPath.lastIndexOf(".");
		return assetClassPath.substring(_loc2_, _loc3_);
	}

	public static function isArt3DPath(path:String):Bool {
		return path != null && new compat.RegExp("(^|[\\/\\\\])Art3D[\\/\\\\]", "i").search(path) != -1;
	}

	public static function isEnvironmentArtPath(path:String):Bool {
		return path != null && new compat.RegExp("(^|[\\/\\\\])Art2D[\\/\\\\]Environments[\\/\\\\]", "i").search(path) != -1;
	}

	public static function getActorAtlasFile(assetClassPath:String, allowMultiClipFolder:Bool = false):File {
		var _loc4_:File;
		var _loc5_:Array<ASAny> = null;
		var _loc8_ = getActorAtlasKeyFromPath(assetClassPath);
		if (_loc8_ == null) {
			return null;
		}
		var _loc7_ = assetClassPath + "|" + allowMultiClipFolder;
		if (mActorAtlasFilePathCache.hasOwnProperty(_loc7_)) {
			return ASCompat.coerce(mActorAtlasFilePathCache[_loc7_], flash.filesystem.File);
		}
		var _loc3_ = assetClassPath.substring(0, assetClassPath.lastIndexOf("."));
		var _loc6_ = AssetLoader.resolveFile(_loc3_);
		if (_loc6_.exists && _loc6_.isDirectory) {
			if (_loc6_.resolvePath("Animation.json").exists) {
				mActorAtlasFilePathCache[_loc7_] = _loc6_;
				return _loc6_;
			}
			if (allowMultiClipFolder && !isMappedLibraryFolder(_loc6_)) {
				_loc5_ = _loc6_.getDirectoryListing();
				if (checkNullIteratee(_loc5_))
					for (_tmp_ in _loc5_) {
						_loc4_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
						if (_loc4_.isDirectory && _loc4_.resolvePath("Animation.json").exists) {
							mActorAtlasFilePathCache[_loc7_] = _loc6_;
							return _loc6_;
						}
					}
			}
		}
		mActorAtlasFilePathCache[_loc7_] = null;
		return null;
	}

	public static function getPropAtlasFile(libraryKey:String, assetClassName:String):File {
		var _loc6_:String = null;
		var _loc3_:File = null;
		var _loc5_ = false;
		if (assetClassName == null || assetClassName == "") {
			return null;
		}
		var _loc4_ = libraryKey + "/" + assetClassName;
		if (!mPropAtlasFolders.hasOwnProperty(_loc4_)) {
			_loc6_ = libraryKey == "shared" ? "Resources/Art2D/Environments/shared/props/db_prop_shared_library/" : mPropMap[libraryKey];
			_loc3_ = _loc6_ != null ? AssetLoader.resolveFile(_loc6_ + assetClassName) : null;
			_loc5_ = _loc3_ != null && _loc3_.exists && _loc3_.isDirectory && _loc3_.resolvePath("Animation.json").exists;
			mPropAtlasFolders[_loc4_] = _loc5_ ? (_loc3_ : ASAny) : (false : ASAny);
		}
		return ASCompat.dynamicAs(mPropAtlasFolders[_loc4_], File);
	}

	static function isMappedLibraryFolder(folder:File):Bool {
		var _loc2_ = new compat.RegExp("\\/$").replace(folder.url, "");
		var _loc3_:String;
		final __ax4_iter_408:ASObject = mBiomeMap;
		if (checkNullIteratee(__ax4_iter_408))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_408)) {
				_loc3_ = _tmp_;
				if (new compat.RegExp("\\/$").replace(AssetLoader.resolveFile(_loc3_).url, "") == _loc2_) {
					return true;
				}
			}
		var _loc4_:String;
		final __ax4_iter_409:ASObject = mPropMap;
		if (checkNullIteratee(__ax4_iter_409))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_409)) {
				_loc4_ = _tmp_;
				if (new compat.RegExp("\\/$").replace(AssetLoader.resolveFile(_loc4_).url, "") == _loc2_) {
					return true;
				}
			}
		return new compat.RegExp("\\/$").replace(AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/").url,
			"") == _loc2_;
	}

	public static function getPropManifestFilesForBiome(biomeKey:String, includeShared:Bool):Array<ASAny> {
		var _loc5_:Array<ASAny> = [];
		var _loc4_ = getPropsOnlyBiome(biomeKey);
		var _loc3_ = _loc4_ != null ? _loc4_ : biomeKey;
		if (mPropMap.hasOwnProperty(_loc3_)) {
			_loc5_.push(AssetLoader.resolveFile(Std.string(mPropMap[_loc3_]) + "flattened_registration.json"));
		}
		if (includeShared || biomeKey == "shared") {
			_loc5_.push(AssetLoader.resolveFile("Resources/Art2D/Environments/shared/props/db_prop_shared_library/" + "flattened_registration.json"));
		}
		return _loc5_;
	}

	static function __init__() {
		mBiomeMap = {
			"castle_arena": "Resources/Art2D/Environments/castle/ground_castle_arena/db_grd_castle_arena_library/",
			"castle_catacomb": "Resources/Art2D/Environments/castle/ground_castle_catacomb/db_grd_castle_catacomb_library/",
			"castle_prison": "Resources/Art2D/Environments/castle/ground_castle_prison/db_grd_castle_prison_library/",
			"nordic_caves": "Resources/Art2D/Environments/nordic/ground_nordic_caves/db_grd_nordic_caves_library/",
			"nordic_temple": "Resources/Art2D/Environments/nordic/ground_nordic_temple/db_grd_nordic_temple_library/",
			"nordic_village": "Resources/Art2D/Environments/nordic/ground_nordic_village/db_grd_nordic_village_library/",
			"jurassic_aztec": "Resources/Art2D/Environments/jurassic/ground_jurassic_aztec/db_grd_jurassic_aztec_library/",
			"jurassic_dino": "Resources/Art2D/Environments/jurassic/ground_jurassic_dino/db_grd_jurassic_dino_library/",
			"jurassic_tribal": "Resources/Art2D/Environments/jurassic/ground_jurassic_tribal/db_grd_jurassic_tribal_library/"
		};
		mPropMap = {
			"castle_arena": "Resources/Art2D/Environments/castle/prop_castle_arena/db_prop_castle_arena_library/",
			"castle_catacomb": "Resources/Art2D/Environments/castle/prop_castle_catacomb/db_prop_castle_catacomb_library/",
			"castle_prison": "Resources/Art2D/Environments/castle/prop_castle_prison/db_prop_castle_prison_library/",
			"jurassic_aztec": "Resources/Art2D/Environments/jurassic/prop_jurassic_aztec/db_prop_jurassic_aztec_library/",
			"jurassic_dino": "Resources/Art2D/Environments/jurassic/prop_jurassic_dino/db_prop_jurassic_dino_library/",
			"jurassic_tribal": "Resources/Art2D/Environments/jurassic/prop_jurassic_tribal/db_prop_jurassic_tribal_library/",
			"nordic_caves": "Resources/Art2D/Environments/nordic/prop_nordic_caves/db_prop_nordic_caves_library/",
			"nordic_temple": "Resources/Art2D/Environments/nordic/prop_nordic_temple/db_prop_nordic_temple_library/",
			"nordic_village": "Resources/Art2D/Environments/nordic/prop_nordic_village/db_prop_nordic_village_library/"
		};
		mActorAtlasFilePathCache = {};
		mPropAtlasFolders = {};
	}
}
