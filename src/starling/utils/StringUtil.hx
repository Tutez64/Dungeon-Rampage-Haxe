package starling.utils;

import starling.errors.AbstractClassError;

class StringUtil {
	public function new() {
		throw new AbstractClassError();
	}

	public static function format(format:String, ..._rest:ASAny):String {
		var rest = ASCompat.restToArray(_rest);
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < rest.length) {
			format = new compat.RegExp("\\{" + _loc3_ + "\\}", "g").replace(format, rest[_loc3_]);
			_loc3_++;
		}
		return format;
	}

	public static function clean(string:String):String {
		return ("_" + string).substr(1);
	}

	public static function trimStart(string:String):String {
		var _loc2_ = 0;
		var _loc3_ = string.length;
		_loc2_ = 0;
		while (_loc2_ < _loc3_) {
			if (string.charCodeAt(_loc2_) > 32) {
				break;
			}
			_loc2_++;
		}
		return string.substring(_loc2_, _loc3_);
	}

	public static function trimEnd(string:String):String {
		var _loc2_ = 0;
		_loc2_ = string.length - 1;
		while (_loc2_ >= 0) {
			if (string.charCodeAt(_loc2_) > 32) {
				break;
			}
			_loc2_--;
		}
		return string.substring(0, _loc2_ + 1);
	}

	public static function trim(string:String):String {
		var _loc4_ = 0;
		var _loc3_ = 0;
		var _loc2_ = string.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			if (string.charCodeAt(_loc3_) > 32) {
				break;
			}
			_loc3_++;
		}
		_loc4_ = string.length - 1;
		while (_loc4_ >= _loc3_) {
			if (string.charCodeAt(_loc4_) > 32) {
				break;
			}
			_loc4_--;
		}
		return string.substring(_loc3_, _loc4_ + 1);
	}

	public static function parseBoolean(value:String):Bool {
		return value == "true" || value == "TRUE" || value == "True" || value == "1";
	}
}
