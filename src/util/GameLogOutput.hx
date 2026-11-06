package util;

import brain.logger.Logger;
import com.junkbyte.console.Cc;
import com.junkbyte.console.vos.Log;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.net.Socket;
import flash.utils.IDataOutput;

class GameLogOutput {
	static var mConfigured:Bool = false;

	static var mInstalled:Bool = false;

	static var mPreviousTracing:Bool = false;

	static var mPreviousTrace:ASFunction;

	static var mFile:FileStream;

	static var mOutput:IDataOutput;

	static var mWriting:Bool = false;

	static var mDestination:String;

	public function new() {}

	public static function configure(arguments:Array<ASAny>) {
		var _loc7_ = false;
		var _loc2_:String = null;
		var _loc9_:String = null;
		var _loc3_ = false;
		var _loc6_:File = null;
		var _loc5_:File = null;
		var _loc8_:String = null;
		if (mConfigured) {
			return;
		}
		var _loc4_:String;
		if (checkNullIteratee(arguments))
			for (_tmp_ in arguments) {
				_loc4_ = _tmp_;
				_loc4_ = unquote(_loc4_);
				if (!(_loc4_ != "--log" && _loc4_.indexOf("--log=") != 0)) {
					mConfigured = true;
					_loc7_ = _loc4_ == "--log";
					_loc2_ = _loc7_ ? "dungeon-rampage.log" : unquote(_loc4_.substr(6));
					_loc9_ = "resolve log path";
					try {
						_loc3_ = _loc7_ || isDirectoryDestination(_loc2_, resolveDestination(_loc2_));
						_loc6_ = resolveFile(_loc2_);
						_loc2_ = _loc6_.nativePath;
						if (_loc6_.isDirectory) {
							throw new Error("Log file \"" + _loc2_ + "\" is a directory");
						}
						if (_loc3_ && _loc6_.exists) {
							_loc5_ = _loc6_.parent.resolvePath("dungeon-rampage.previous.log");
							_loc9_ = "rotate log to \"" + _loc5_.nativePath + "\"";
							_loc6_.moveTo(_loc5_, true);
						}
						_loc9_ = null;
						openFile(_loc6_, true);
					} catch (error:Dynamic) {
						close();
						_loc8_ = ASCompat.stringAsBool(_loc9_) ? "Could not " + _loc9_ + " \"" + _loc2_ + "\": " + ASCompat.asError(error)
							.message : ASCompat.asError(error).message;
						warn("Log output unavailable: " + new compat.RegExp("\\.+$").replace(_loc8_, "") + ". Continuing without file logging.");
					}
					return;
				}
			}
	}

	static function unquote(value:String):String {
		if (ASCompat.stringAsBool(value) && value.length >= 2 && value.charAt(0) == "\"" && value.charAt(value.length - 1) == "\"") {
			return value.substring(1, value.length - 1);
		}
		return value;
	}

	public static function resolveFile(path:String):File {
		var _loc2_ = resolveDestination(path);
		if (isDirectoryDestination(path, _loc2_)) {
			_loc2_ = _loc2_.resolvePath("dungeon-rampage.log");
		}
		validatePath(_loc2_.nativePath);
		return _loc2_;
	}

	static function isDirectoryDestination(path:String, destination:File):Bool {
		return new compat.RegExp("[\\\\/]$").test(unquote(path)) || destination.isDirectory;
	}

	static function resolveDestination(path:String):File {
		var _loc4_:String = null;
		var _loc5_:String = null;
		path = unquote(path);
		validatePath(path, true);
		var _loc2_ = new compat.RegExp("^([A-Za-z]:[\\\\/]|[\\\\/])").test(path);
		var _loc3_ = _loc2_ ? new File(path) : File.applicationStorageDirectory.resolvePath(path);
		validatePath(_loc3_.nativePath, true);
		if (!_loc2_) {
			_loc4_ = new compat.RegExp("\\\\", "g").replace(File.applicationStorageDirectory.nativePath, "/");
			_loc5_ = new compat.RegExp("\\\\", "g").replace(_loc3_.nativePath, "/");
			if (_loc5_ != _loc4_ && _loc5_.indexOf(_loc4_ + "/") != 0) {
				throw new Error("Relative log paths must stay within application storage");
			}
		}
		return _loc3_;
	}

	static function validatePath(path:String, allowDirectory:Bool = false) {
		if (!ASCompat.stringAsBool(path) || new compat.RegExp("[\\x00-\\x1f]").test(path)) {
			throw new Error("Expected a nonempty log file path");
		}
		if (path.indexOf("\"") >= 0) {
			throw new Error("Unexpected quote in log path; Use forward slashes, for example --log=\"C:/logs folder/\"");
		}
		var _loc4_ = new compat.RegExp("\\\\", "g").replace(path, "/");
		if (new compat.RegExp("^\\/\\/[.?]\\/").test(_loc4_)) {
			throw new Error("Device paths and named pipes are not supported for logging");
		}
		if (new compat.RegExp("^[A-Za-z]:\\/").replace(_loc4_, "").indexOf(":") >= 0) {
			throw new Error("Expected a native file path");
		}
		var _loc6_:Array<ASAny> = (cast _loc4_.split("/"));
		var _loc5_:String;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc5_ = _tmp_;
				if (new compat.RegExp("^\\.\\.[ .]*$").test(_loc5_)) {
					throw new Error("Parent traversal is not allowed in log paths");
				}
			}
		var _loc3_ = new compat.RegExp("[ .]+$", "g").replace(ASCompat.toString(_loc6_[_loc6_.length - 1]), "");
		if (!allowDirectory && (!ASCompat.stringAsBool(_loc3_) || new compat.RegExp("\\.json$", "i").test(_loc3_))) {
			throw new Error("Log destination must be a file or folder and must not end in .json");
		}
	}

	public static function setFile(path:String, includeHistory:Bool = false) {
		openFile(resolveFile(path), includeHistory);
	}

	static function openFile(destination:File, includeHistory:Bool) {
		var _loc5_:Log = null;
		if (Cc.instance == null) {
			throw new Error("Could not open log file \"" + destination.nativePath + "\": game console is not initialized");
		}
		if (destination.isDirectory) {
			throw new Error("Log file \"" + destination.nativePath + "\" is a directory");
		}
		var _loc3_ = destination.parent;
		try {
			_loc3_.createDirectory();
		} catch (error:Dynamic) {
			throw new Error("Could not create log directory \"" + _loc3_.nativePath + "\" for log file \"" + destination.nativePath + "\": "
				+ ASCompat.asError(error).message);
		}
		releaseOutput();
		var _loc4_:FileStream;
		mFile = _loc4_ = new FileStream();
		mDestination = destination.nativePath;
		try {
			_loc4_.open(destination, flash.filesystem.FileMode.WRITE);
			_loc4_.close();
			_loc4_.open(destination, flash.filesystem.FileMode.APPEND);
		} catch (openError:Dynamic) {
			close();
			throw new Error("Could not open log file \"" + destination.nativePath + "\": " + ASCompat.asError(openError).message);
		}
		useStream(_loc4_);
		if (includeHistory) {
			_loc5_ = Cc.instance.logs.first;
			while (_loc5_ != null) {
				write(_loc5_.ch, _loc5_.plainText());
				_loc5_ = _loc5_.next;
			}
		}
		Logger.info("Log file: " + destination.nativePath);
	}

	public static function useStream(output:IDataOutput) {
		if (output == null) {
			throw new Error("Log stream must not be null");
		}
		if (output == mOutput) {
			return;
		}
		if (Cc.instance == null) {
			throw new Error("Game console is not initialized");
		}
		mConfigured = true;
		if (mFile != output) {
			releaseOutput();
		}
		mOutput = output;
		if (!mInstalled) {
			mPreviousTracing = Cc.config.tracing;
			mPreviousTrace = ASCompat.coerceFunction(Cc.config.traceCall);
			Cc.config.traceCall = onTrace;
			Cc.config.tracing = true;
			mInstalled = true;
		}
	}

	static function onTrace(channel:String, line:String, priority:Int) {
		var _loc4_ = mPreviousTracing ? mPreviousTrace : null;
		write(channel, line);
		if (_loc4_ != null) {
			_loc4_(channel, line, priority);
		}
	}

	static function write(channel:String, line:String) {
		var _loc3_:String = null;
		var _loc4_:String = null;
		if (mOutput == null || mWriting) {
			return;
		}
		mWriting = true;
		{
			try {
				try {
					_loc3_ = "[" + channel + "] ";
					mOutput.writeUTFBytes(_loc3_ + new compat.RegExp("\\r?\\n", "g").replace(line, "\n" + _loc3_) + "\n");
					if (Std.isOfType(mOutput, Socket)) {
						ASCompat.reinterpretAs(mOutput, Socket).flush();
					}
				} catch (error:Dynamic) {
					_loc4_ = ASCompat.stringAsBool(mDestination) ? "file \"" + mDestination + "\"" : "stream";
					close();
					warn("Log output disabled after write failure to "
						+ _loc4_
						+ ": "
						+ Std.string(new compat.RegExp("\\.+$").replace(ASCompat.asError(error).message, ""))
						+ ". Continuing without this log output.");
				};
			} catch (__finallyError0:Dynamic) {
				{
					mWriting = false;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				mWriting = false;
			};
		}
	}

	static function warn(message:String) {
		try {
			Logger.warn(message);
		} catch (ignored:Dynamic) {}
	}

	static function releaseOutput() {
		mOutput = null;
		mDestination = null;
		if (mFile != null) {
			try {
				mFile.close();
			} catch (ignored:Dynamic) {}
			mFile = null;
		}
	}

	public static function close() {
		mConfigured = true;
		releaseOutput();
		if (mInstalled) {
			Cc.config.traceCall = mPreviousTrace;
			Cc.config.tracing = mPreviousTracing;
			mInstalled = false;
			mPreviousTrace = null;
		}
	}
}
