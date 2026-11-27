package settings.model;

import brain.logger.Logger;
import flash.filesystem.File;
import flash.filesystem.FileStream;

class GameLogFile {
	static var stream:FileStream;

	static var started:Bool = false;

	public static var failureCallback:ASFunction;

	public function new() {}

	@:isVar public static var enabled(get, set):Bool;

	static public function get_enabled():Bool {
		return stream != null;
	}

	@:isVar static var folder(get, never):File;

	static function get_folder():File {
		return File.applicationStorageDirectory.resolvePath("logs");
	}

	static function set_enabled(value:Bool):Bool {
		var _loc3_:File = null;
		if (value == enabled) {
			return value;
		}
		if (!value) {
			close();
			return value;
		}
		var _loc2_ = new FileStream();
		try {
			folder.createDirectory();
			_loc3_ = folder.resolvePath("game.log");
			if (!started && _loc3_.exists) {
				_loc3_.moveTo(folder.resolvePath("game.previous.log"), true);
			}
			_loc2_.open(_loc3_, started ? "append" : "write");
			stream = _loc2_;
			started = true;
			Logger.outputCallback = append;
		} catch (error:Dynamic) {
			try {
				_loc2_.close();
			} catch (ignored:Dynamic) {}
			if (failureCallback != null) {
				failureCallback();
			}
			Logger.warn("Could not save game logs: " + ASCompat.asError(error).message);
		}
		return value;
	}

	static function append(message:String) {
		try {
			stream.writeUTFBytes(message + "\n");
		} catch (error:Dynamic) {
			close();
			if (failureCallback != null) {
				failureCallback();
			}
		}
	}

	static function close() {
		Logger.outputCallback = null;
		var _loc1_ = stream;
		stream = null;
		if (_loc1_ != null) {
			try {
				_loc1_.close();
			} catch (error:Dynamic) {}
		}
	}

	public static function openFolder() {
		try {
			folder.createDirectory();
			folder.openWithDefaultApplication();
		} catch (error:Dynamic) {
			Logger.warn("Could not open logs folder: " + ASCompat.asError(error).message);
		}
	}
}
