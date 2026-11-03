package com.junkbyte.console.utils;

class FlashRegex {
	public function new() {}

	public static function search(text:String, regex:EReg, lastIndex:Int = 0):Int {
		var _loc4_ = FlashRegex.match(text, regex, lastIndex);
		if (_loc4_) {
			return ASCompat.toInt(regex.matchedPos().pos);
		}
		return -1;
	}

	public static function match(text:String, regex:EReg, lastIndex:Int = 0):Bool {
		if (lastIndex < 1) {
			return regex.match(text);
		}
		return regex.matchSub(text, lastIndex);
	}

	public static function replace(text:String, search:EReg, value:String):String {
		return search.replace(text, value);
	}

	public static function split(text:String, regex:EReg):Array<ASAny> {
		var _loc3_ = text;
		return ASCompat.coerce(regex.r.split(_loc3_), Array);
	}

	public static function exec(text:String, regex:EReg, lastIndex:Int = 0):RegexResult {
		var _loc7_:ASAny = null;
		if (lastIndex > text.length || !FlashRegex.match(text, regex, lastIndex)) {
			return null;
		}
		var _loc5_ = new RegexResult();
		_loc5_.index = ASCompat.toInt(regex.matchedPos().pos);
		var _loc6_ = 0;
		while (true) {
			try {
				_loc5_.elements.push(regex.matched(_loc6_));
			} catch (_loc_e_:ASAny) {
				_loc7_ = _loc_e_;
				null;
				break;
			}
			_loc6_++;
		}
		return _loc5_;
	}
}
