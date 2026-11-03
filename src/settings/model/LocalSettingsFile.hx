package settings.model;

import brain.logger.Logger;
import flash.filesystem.File;
import flash.filesystem.FileStream;

class LocalSettingsFile {
	static inline final FILE_NAME = "settings.json";

	public function new() {}

	static function resolveFile():File {
		return File.applicationStorageDirectory.resolvePath("settings.json");
	}

	public function read():ASObject {
		var __finallyReturn3:ASObject;
		var _loc3_:String = null;
		var _loc4_:ASObject = null;
		var _loc1_ = resolveFile();
		if (!_loc1_.exists) {
			return null;
		}
		var _loc2_ = new FileStream();
		{
			var __finallyReturn3:ASObject;
			try {
				try {
					_loc2_.open(_loc1_, flash.filesystem.FileMode.READ);
					_loc3_ = _loc2_.readUTFBytes(_loc2_.bytesAvailable);
				} catch (error:Dynamic) {
					Logger.warn("Could not read settings.json, falling back to defaults: " + Std.string(error.message));
					{
						__finallyReturn3 = null;
						{
							_loc2_.close();
						};
						return __finallyReturn3;
					};
				};
			} catch (__finallyError4:Dynamic) {
				{
					_loc2_.close();
				};
				throw __finallyError4;
			};
			{
				_loc2_.close();
			};
		}
		try {
			_loc4_ = haxe.Json.parse(_loc3_);
			if (_loc4_ != null) {
				return _loc4_;
			}
		} catch (parseError:Dynamic) {
			Logger.warn("Could not parse settings.json, falling back to defaults: " + Std.string(parseError.message));
		}
		return null;
	}

	public function write(blob:ASObject) {
		var _loc2_ = new FileStream();
		{
			try {
				try {
					_loc2_.open(resolveFile(), flash.filesystem.FileMode.WRITE);
					_loc2_.writeUTFBytes(haxe.Json.stringify(blob));
				} catch (error:Dynamic) {
					Logger.error("Could not write settings.json: " + Std.string(error.message));
				};
			} catch (__finallyError5:Dynamic) {
				{
					_loc2_.close();
				};
				throw __finallyError5;
			};
			{
				_loc2_.close();
			};
		}
	}
}
