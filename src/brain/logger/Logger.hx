package brain.logger;

import brain.clock.GameClock;
import com.junkbyte.console.Cc;
import com.junkbyte.console.KeyBind;
import flash.display.Stage;
import flash.system.Capabilities;

class Logger {
	static var mReentrentLock:Bool = false;

	static var mWantConsole:Bool = false;

	static var mWantCommandLine:Bool = false;

	static var mWantThrowErrors:Bool = true;

	static var mShowDebug:Bool = true;

	static var mShowInfo:Bool = true;

	public static var errorCallback:ASFunction;

	public static var customLoggerString:String;

	static var mListSlashCommands:Array<ASAny> = [];

	public function new() {}

	public static function init(stageRef:Stage, wantConsole:Bool = false) {
		mWantConsole = wantConsole;
		if (mWantConsole) {
			Cc.startOnStage(stageRef, "0");
		}
	}

	public static function displayConsole() {
		Cc.visible = true;
	}

	public static function hideConsole() {
		Cc.visible = false;
	}

	public static function isConsoleVisible():Bool {
		if (Cc.visible) {
			return true;
		}
		return false;
	}

	public static function enableCommandLine() {
		mWantCommandLine = true;
		Cc.config.commandLineAllowed = mWantCommandLine;
		mShowDebug = true;
		mShowInfo = true;
	}

	public static function setDebugMessages(showThem:Bool) {
		mShowDebug = showThem;
	}

	public static function setInfoMessages(showThem:Bool) {
		mShowInfo = showThem;
	}

	public static function addSlashCommand(arg0:String, arg1:ASFunction, arg2:String = "", arg3:Bool = true) {
		Cc.addSlashCommand(arg0, arg1, arg2, arg3);
		mListSlashCommands.push(arg0);
	}

	public static function listSlashCommands() {
		var _loc1_:String;
		final __ax4_iter_122 = mListSlashCommands;
		if (checkNullIteratee(__ax4_iter_122))
			for (_tmp_ in __ax4_iter_122) {
				_loc1_ = _tmp_;
				log(_loc1_);
			}
	}

	public static function bindKey(bindKey:KeyBind, bindFunction:ASFunction, bindArray:Array<ASAny> = null) {
		Cc.bindKey(bindKey, bindFunction, bindArray);
	}

	@:isVar public static var CustomLoggerString(never, set):String;

	static public function set_CustomLoggerString(val:String):String {
		return customLoggerString = val;
	}

	static function pad(num:Float, digits:UInt):String {
		var _loc3_ = Std.string(num);
		while ((_loc3_.length : UInt) < digits) {
			_loc3_ = "0" + _loc3_;
		}
		return _loc3_;
	}

	@:isVar public static var errorsCanThrow(get, set):Bool;

	static public function set_errorsCanThrow(val:Bool):Bool {
		return mWantThrowErrors = val;
	}

	static function get_errorsCanThrow():Bool {
		return mWantThrowErrors;
	}

	static function getDateString():String {
		var _loc1_ = GameClock.date;
		return "[" + _loc1_.getFullYear() + "-" + pad(_loc1_.getMonth() + 1, (2 : UInt)) + "-" + pad(_loc1_.getDate(), (2 : UInt)) + " "
			+ pad(_loc1_.getHours(), (2 : UInt)) + ":" + pad(_loc1_.getMinutes(), (2 : UInt)) + ":" + pad(_loc1_.getSeconds(), (2 : UInt)) + "."
			+ pad(ASCompat.ASDate.getMilliseconds(_loc1_), (3 : UInt)) + "] ";
	}

	public static function log(logString:String) {
		logString = "" + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.log(logString);
		}
	}

	public static function debug(logString:String) {
		if (!mShowDebug || customLoggerString != null) {
			return;
		}
		logString = "[DEBUG] " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.debug(logString);
		}
	}

	public static function debugch(channel:String, logString:String) {
		if (!mShowDebug || customLoggerString != null) {
			return;
		}
		logString = "[DEBUG] " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.debugch(channel, logString);
		}
	}

	public static function info(logString:String) {
		if (!mShowInfo) {
			return;
		}
		logString = "[INFO]  " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.info(logString);
		}
	}

	public static function infoch(channel:String, logString:String) {
		if (!mShowInfo) {
			return;
		}
		logString = "[INFO] " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.infoch(channel, logString);
		}
	}

	public static function warn(logString:String) {
		if (customLoggerString != null) {
			return;
		}
		logString = "[WARN]  " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.warn(logString);
		}
	}

	public static function warnch(channel:String, logString:String) {
		if (customLoggerString != null) {
			return;
		}
		logString = "[WARN] " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.warnch(channel, logString);
		}
	}

	public static function error(logString:String, originalError:Error = null) {
		var _loc5_ = originalError != null ? originalError : new Error(logString);
		var _loc4_:String = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
		var _loc3_ = ASCompat.stringAsBool(_loc4_) ? logString + "\n" + _loc4_ : logString;
		tryErrorCallback(_loc3_);
		logString = "[ERROR] " + getDateString() + _loc3_;
		trace(logString);
		if (mWantConsole) {
			Cc.error(logString);
		}
		if (mWantThrowErrors && Capabilities.isDebugger) {
			displayConsole();
			Cc.minimumPriority = (8 : UInt);
			_loc5_.name = "LOGGED " + Std.string(_loc5_.name);
			throw _loc5_;
		}
	}

	static function tryErrorCallback(logString:String) {
		if (errorCallback != null && !mReentrentLock) {
			mReentrentLock = true;
			errorCallback(logString);
			mReentrentLock = false;
		}
	}

	public static function fatal(logString:String, originalError:Error = null) {
		var _loc5_ = originalError != null ? originalError : new Error(logString);
		var _loc4_:String = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
		logString = "[FATAL] " + getDateString() + logString;
		var _loc3_ = logString + "\n" + _loc4_;
		trace(_loc3_);
		if (mWantConsole) {
			displayConsole();
			Cc.minimumPriority = (8 : UInt);
			Cc.height = 250;
			Cc.warn(_loc3_);
			Cc.fatal(logString);
			Cc.warn("If you are reporting this error please click \'Sv\' at the top to copy the logs to your clipboard");
		}
		tryErrorCallback(logString);
		if (mWantThrowErrors) {
			_loc5_.name = "LOGGED " + Std.string(_loc5_.name);
			throw _loc5_;
		}
	}

	public static function reloadPage() {}

	public static function custom(myLoggerString:String, logString:String) {
		if (customLoggerString != myLoggerString) {
			return;
		}
		logString = "[" + customLoggerString + "]  " + getDateString() + logString;
		trace(logString);
		if (mWantConsole) {
			Cc.warn(logString);
		}
	}
}
