package brain.assetRepository;

import brain.logger.Logger;
import flash.filesystem.File;
import flash.filesystem.FileStream;

class StarlingPropManifest {
	public static inline final FORMAT = "dr-prop-manifest/2";

	var mRecipes:ASObject = {};

	var mScales:ASObject = {};

	public function new() {}

	public function load(manifestFile:File) {
		var _loc3_:ASObject = null;
		var _loc4_:Array<ASAny> = null;
		if (manifestFile == null || !manifestFile.exists) {
			return;
		}
		var _loc2_ = new FileStream();
		{
			try {
				try {
					_loc2_.open(manifestFile, flash.filesystem.FileMode.READ);
					_loc3_ = haxe.Json.parse(_loc2_.readUTFBytes(_loc2_.bytesAvailable));
				} catch (error:Dynamic) {
					Logger.error("StarlingPropManifest.load: could not read " + manifestFile.nativePath + ": " + Std.string(error.message));
					{
						{
							_loc2_.close();
						};
						return;
					};
				};
			} catch (__finallyError74:Dynamic) {
				{
					_loc2_.close();
				};
				throw __finallyError74;
			};
			{
				_loc2_.close();
			};
		}
		if (_loc3_ == null || _loc3_.format != "dr-prop-manifest/2") {
			Logger.error("StarlingPropManifest.load: refusing " + manifestFile.nativePath + " - expected format \'" + "dr-prop-manifest/2" + "\', got \'"
				+ Std.string((_loc3_ != null ? _loc3_.format : null)) + "\'");
			return;
		}
		var _loc5_ = ASCompat.toNumber(_loc3_.scale);
		if (_loc5_ <= 0) {
			_loc5_ = 1;
		}
		if (manifestFile.parent != null) {
			mScales[manifestFile.parent.nativePath] = _loc5_;
		}
		var _loc6_ = 0;
		var _loc7_:String;
		final __ax4_iter_375:ASAny = _loc3_.props;
		if (checkNullIteratee(__ax4_iter_375))
			for (_tmp_ in __ax4_iter_375.___keys()) {
				_loc7_ = _tmp_;
				_loc4_ = ASCompat.dynamicAs(_loc3_.props[_loc7_].parts, Array);
				if (!(_loc4_ == null || _loc4_.length == 0)) {
					mRecipes[_loc7_] = _loc4_;
					_loc6_++;
				}
			}
		Logger.debugch("Starling", "StarlingPropManifest: "
			+ _loc6_
			+ " prop recipes from "
			+ Std.string(_loc3_.library)
			+ " at "
			+ _loc5_
			+ "x");
	}

	public function clear() {
		mRecipes = {};
		mScales = {};
	}

	public function scaleForFolder(folder:File):Float {
		if (folder == null) {
			return 1;
		}
		var _loc2_:ASObject = mScales[folder.nativePath];
		return _loc2_ == null ? 1 : ASCompat.toNumber(_loc2_);
	}

	public function getParts(assetClassName:String):Array<ASAny> {
		if (assetClassName == null) {
			return null;
		}
		return ASCompat.dynamicAs(mRecipes[assetClassName], Array);
	}
}
