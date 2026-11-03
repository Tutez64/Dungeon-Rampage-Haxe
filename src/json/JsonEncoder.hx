package json;

import flash.Boot;

class JsonEncoder {
	public static var TAB_WIDTH:Int = 4;

	public var _pretty:Bool = false;

	public var _maxLength:Int = 0;

	public var _level:Int = 0;

	public var _jsonString:String;

	public function new(value:ASAny = /*undefined*/ null, pretty:Bool = false, maxLength:Int = 0) {
		if (Boot.skip_constructor) {
			return;
		}
		_level = 0;
		_pretty = pretty;
		_maxLength = pretty ? maxLength : 2147483647;
		_jsonString = convertToString(value);
	}

	public static function memberNames(o:ASAny, classInfo:compat.XML, plainObject:Bool):Array<ASAny> {
		var _loc5_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc6_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc7_ = 0;
		var _loc8_:ASAny = null;
		var _loc9_ = ASCompat.asXMLList(null);
		var _loc10_ = 0;
		var _loc11_ = 0;
		var _loc12_:ASAny = ASCompat.asXML(null);
		var _loc13_ = ASCompat.asString(null);
		var _loc4_:Array<ASAny> = [];
		if (plainObject) {
			_loc7_ = 0;
			_loc6_ = [];
			_loc8_ = o;
			if (checkNullIteratee(_loc8_))
				for (_tmp_ in _loc8_.___keys()) {
					_loc7_ = ASCompat.toInt(_tmp_);
					_loc6_.push(_loc7_);
				}
			_loc5_ = _loc6_;
			_loc7_ = 0;
			while (_loc7_ < ASCompat.toInt(_loc5_.length)) {
				_loc8_ = _loc5_[_loc7_];
				_loc7_++;
				_loc4_.push(ASCompat.toString(_loc8_));
			}
		} else {
			_loc9_ = classInfo.descendants("*");
			_loc7_ = 0;
			_loc10_ = ASCompat.toInt(_loc9_.length());
			while (_loc7_ < _loc10_) {
				_loc11_ = _loc7_++;
				_loc12_ = _loc9_[_loc11_];
				_loc13_ = ASCompat.toString(_loc12_.name());
				if (_loc13_ == "variable" || _loc13_ == "accessor") {
					_loc4_.push(Std.string(_loc12_.attribute("name")));
				}
			}
		}
		return _loc4_;
	}

	public static function getPadding(level:Int):String {
		var _loc2_:Float = level * 4;
		var _loc3_ = "";
		var _loc4_ = 1;
		while (_loc4_ <= _loc2_) {
			_loc3_ += " ";
			_loc4_++;
		}
		return _loc3_;
	}

	public function objectToStringPretty(o:ASAny):String {
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_:ASAny = null;
		++_level;
		var _loc2_ = "";
		var _loc3_ = ASCompat.describeType(o);
		var _loc4_ = _loc3_.attribute("name").toString() == "Object";
		var _loc5_ = 0;
		var _loc6_ = JsonEncoder.memberNames(o, _loc3_, _loc4_);
		while (_loc5_ < _loc6_.length) {
			_loc7_ = _loc6_[_loc5_];
			_loc5_++;
			_loc8_ = o[_loc7_];
			if (!(_loc4_ && Reflect.isFunction(_loc8_))) {
				if (_loc2_.length > 0) {
					_loc2_ += ",\n";
				}
				_loc2_ += JsonEncoder.getPadding(_level) + escapeString(_loc7_) + ":";
				if (_pretty) {
					_loc2_ += " ";
				}
				_loc2_ += convertToString(_loc8_);
			}
		}
		--_level;
		return "{\n" + _loc2_ + "\n" + JsonEncoder.getPadding(_level) + "}";
	}

	public function objectToString(o:ASAny):String {
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_:ASAny = null;
		var _loc2_ = "";
		var _loc3_ = ASCompat.describeType(o);
		var _loc4_ = _loc3_.attribute("name").toString() == "Object";
		var _loc5_ = 0;
		var _loc6_ = JsonEncoder.memberNames(o, _loc3_, _loc4_);
		while (_loc5_ < _loc6_.length) {
			_loc7_ = _loc6_[_loc5_];
			_loc5_++;
			_loc8_ = o[_loc7_];
			if (!(_loc4_ && Reflect.isFunction(_loc8_))) {
				if (_loc2_.length > 0) {
					_loc2_ += ",";
					if (_pretty) {
						_loc2_ += " ";
					}
				}
				_loc2_ += escapeString(_loc7_) + ":";
				if (_pretty) {
					_loc2_ += " ";
				}
				_loc2_ += convertToString(_loc8_);
			}
		}
		return "{" + _loc2_ + "}";
	}

	public function getString():String {
		return _jsonString;
	}

	public function escapeString(str:String):String {
		var _loc5_ = 0;
		var _loc6_ = ASCompat.asString(null);
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_ = 0;
		var _loc9_ = ASCompat.asString(null);
		var _loc2_ = "";
		var _loc3_ = 0;
		var _loc4_ = str.length;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			_loc7_ = _loc6_ = str.charAt(_loc5_);
			if (_loc7_ == "\x08") {
				_loc2_ += "\\b";
			} else if (_loc7_ == "\t") {
				_loc2_ += "\\t";
			} else if (_loc7_ == "\n") {
				_loc2_ += "\\n";
			} else if (_loc7_ == "\x0C") {
				_loc2_ += "\\f";
			} else if (_loc7_ == "\r") {
				_loc2_ += "\\r";
			} else if (_loc7_ == "\"") {
				_loc2_ += "\\\"";
			} else if (_loc7_ == "\\") {
				_loc2_ += "\\\\";
			} else if (_loc6_ < " ") {
				_loc8_ = ASCompat.toInt(_loc6_.charCodeAt(0));
				_loc7_ = ASCompat.toRadix(_loc8_, (16 : UInt));
				_loc9_ = ASCompat.toNumberField(_loc7_, "length") == 2 ? "00" : "000";
				_loc2_ += "\\u" + _loc9_ + Std.string(_loc7_);
			} else {
				_loc2_ += _loc6_;
			}
		}
		return "\"" + _loc2_ + "\"";
	}

	public function convertToString(value:ASAny):String {
		var _loc2_ = ASCompat.asString(null);
		if (Std.isOfType(value, String)) {
			return escapeString(value);
		}
		if (Std.isOfType(value, Float)) {
			if (Math.isFinite(ASCompat.toNumber(value))) {
				return Std.string(value);
			}
			return "null";
		}
		if (Std.isOfType(value, Bool)) {
			if (ASCompat.toBool(value)) {
				return "true";
			}
			return "false";
		}
		if (Std.isOfType(value, Array)) {
			if (_maxLength <= 2) {
				return arrayToStringPretty(ASCompat.coerce(value, Array));
			}
			_loc2_ = arrayToString(ASCompat.coerce(value, Array));
			if (ASCompat.toNumberField(_loc2_, "length") > _maxLength) {
				return arrayToStringPretty(ASCompat.coerce(value, Array));
			}
			return _loc2_;
		}
		if (value != null && value != null) {
			if (_maxLength <= 2) {
				return objectToStringPretty(value);
			}
			_loc2_ = objectToString(value);
			if (ASCompat.toNumberField(_loc2_, "length") > _maxLength) {
				return objectToStringPretty(value);
			}
			return _loc2_;
		}
		return "null";
	}

	public function arrayToStringPretty(a:Array<ASAny>):String {
		var _loc5_ = 0;
		++_level;
		var _loc2_ = "";
		var _loc3_ = 0;
		var _loc4_ = a.length;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			if (_loc2_.length > 0) {
				_loc2_ += ",\n";
			}
			_loc2_ += JsonEncoder.getPadding(_level) + convertToString(a[_loc5_]);
		}
		--_level;
		return "[\n" + _loc2_ + "\n" + JsonEncoder.getPadding(_level) + "]";
	}

	public function arrayToString(a:Array<ASAny>):String {
		var _loc5_ = 0;
		var _loc2_ = "";
		var _loc3_ = 0;
		var _loc4_ = a.length;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			if (_loc2_.length > 0) {
				_loc2_ += ",";
				if (_pretty) {
					_loc2_ += " ";
				}
			}
			_loc2_ += convertToString(a[_loc5_]);
		}
		return "[" + _loc2_ + "]";
	}
}
