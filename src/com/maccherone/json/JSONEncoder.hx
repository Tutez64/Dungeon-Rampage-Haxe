package com.maccherone.json;

class JSONEncoder {
	static inline final tabWidth = 4;

	var jsonString:String;

	var level:Int = 0;

	var maxLength:Int = 0;

	var pretty:Bool = false;

	public function new(value:ASAny, pretty:Bool = false, maxLength:Int = 60) {
		level = 0;
		this.pretty = pretty;
		if (pretty) {
			this.maxLength = maxLength;
		} else {
			this.maxLength = ASCompat.MAX_INT;
		}
		jsonString = convertToString(value);
	}

	static function getPadding(level:Int):String {
		var _loc2_ = level * tabWidth;
		var _loc3_ = "";
		var _loc4_ = 1;
		while (_loc4_ <= _loc2_) {
			_loc3_ += " ";
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc3_;
	}

	function objectToStringPretty(o:ASObject):String {
		var __ax4_iter_37:compat.XMLList;
		var s:String;
		var classInfo:compat.XML;
		var value:ASObject = null;
		var key:String = null;
		var v:compat.XML = null;
		++level;
		s = "";
		classInfo = ASCompat.describeType(o);
		if (classInfo.attribute("name").toString() == "Object") {
			if (checkNullIteratee(o))
				for (_tmp_ in o.___keys()) {
					key = _tmp_;
					value = o[key];
					if (!Reflect.isFunction(value)) {
						if (s.length > 0) {
							s += ",\n";
						}
						s += getPadding(level) + escapeString(key) + ":";
						if (pretty) {
							s += " ";
						}
						s += convertToString(value);
					}
				}
		} else {
			__ax4_iter_37 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool {
				return __xml.name() == "variable" || __xml.name() == "accessor";
			});
			if (checkNullIteratee(__ax4_iter_37))
				for (_tmp_ in __ax4_iter_37) {
					v = _tmp_;
					if (s.length > 0) {
						s += ",\n";
					}
					s += getPadding(level) + escapeString(v.attribute("name").toString()) + ":";
					if (pretty) {
						s += " ";
					}
					s += convertToString(o[v.attribute("name")]);
				}
		}
		--level;
		return "{" + "\n" + s + "\n" + getPadding(level) + "}";
	}

	function arrayToString(a:Array<ASAny>):String {
		var _loc2_ = "";
		var _loc3_ = 0;
		while (_loc3_ < a.length) {
			if (_loc2_.length > 0) {
				_loc2_ += ",";
				if (pretty) {
					_loc2_ += " ";
				}
			}
			_loc2_ += convertToString(a[_loc3_]);
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		return "[" + _loc2_ + "]";
	}

	public function getString():String {
		return jsonString;
	}

	function objectToString(o:ASObject):String {
		var __ax4_iter_38:compat.XMLList;
		var value:ASObject = null;
		var key:String = null;
		var v:compat.XML = null;
		var s = "";
		var classInfo = ASCompat.describeType(o);
		if (classInfo.attribute("name").toString() == "Object") {
			if (checkNullIteratee(o))
				for (_tmp_ in o.___keys()) {
					key = _tmp_;
					value = o[key];
					if (!Reflect.isFunction(value)) {
						if (s.length > 0) {
							s += ",";
							if (pretty) {
								s += " ";
							}
						}
						s += escapeString(key) + ":";
						if (pretty) {
							s += " ";
						}
						s += convertToString(value);
					}
				}
		} else {
			__ax4_iter_38 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool {
				return __xml.name() == "variable" || __xml.name() == "accessor";
			});
			if (checkNullIteratee(__ax4_iter_38))
				for (_tmp_ in __ax4_iter_38) {
					v = _tmp_;
					if (s.length > 0) {
						s += ",";
						if (pretty) {
							s += " ";
						}
					}
					s += escapeString(v.attribute("name").toString()) + ":";
					if (pretty) {
						s += " ";
					}
					s += convertToString(o[v.attribute("name")]);
				}
		}
		return "{" + s + "}";
	}

	function escapeString(str:String):String {
		var _loc3_:String = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc2_ = "";
		var _loc4_:Float = str.length;
		var _loc5_ = 0;
		while (_loc5_ < _loc4_) {
			_loc3_ = str.charAt(_loc5_);
			switch (_loc3_) {
				case "\"":
					_loc2_ += "\\\"";

				case "\\":
					_loc2_ += "\\\\";

				case "\x08":
					_loc2_ += "\\b";

				case "\x0C":
					_loc2_ += "\\f";

				case "\n":
					_loc2_ += "\\n";

				case "\r":
					_loc2_ += "\\r";

				case "\t":
					_loc2_ += "\\t";

				default:
					if (_loc3_ < " ") {
						_loc6_ = ASCompat.toRadix(_loc3_.charCodeAt(0), (16 : UInt));
						_loc7_ = _loc6_.length == 2 ? "00" : "000";
						_loc2_ += "\\u" + _loc7_ + _loc6_;
					} else {
						_loc2_ += _loc3_;
					}
			}
			_loc5_ = ASCompat.toInt(_loc5_) + 1;
		}
		return "\"" + _loc2_ + "\"";
	}

	function arrayToStringPretty(a:Array<ASAny>):String {
		++level;
		var _loc2_ = "";
		var _loc3_ = 0;
		while (_loc3_ < a.length) {
			if (_loc2_.length > 0) {
				_loc2_ += ",\n";
			}
			_loc2_ += getPadding(level) + convertToString(a[_loc3_]);
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		--level;
		return "[" + "\n" + _loc2_ + "\n" + getPadding(level) + "]";
	}

	function convertToString(value:ASAny):String {
		var _loc2_:String = null;
		if (Std.isOfType(value, String)) {
			return escapeString(ASCompat.asString(value));
		}
		if (Std.isOfType(value, Float)) {
			return Math.isFinite(ASCompat.asNumber(value)) ? Std.string(value) : "null";
		}
		if (Std.isOfType(value, Bool)) {
			return ASCompat.toBool(value) ? "true" : "false";
		}
		if (Std.isOfType(value, Array)) {
			if (maxLength <= 2) {
				_loc2_ = arrayToStringPretty(ASCompat.dynamicAs(value, Array));
			} else {
				_loc2_ = arrayToString(ASCompat.dynamicAs(value, Array));
				if (_loc2_.length > maxLength) {
					_loc2_ = arrayToStringPretty(ASCompat.dynamicAs(value, Array));
				}
			}
			return _loc2_;
		}
		if (value != null && value != null) {
			if (maxLength <= 2) {
				_loc2_ = objectToStringPretty(value);
			} else {
				_loc2_ = objectToString(value);
				if (_loc2_.length > maxLength) {
					_loc2_ = objectToStringPretty(value);
				}
			}
			return _loc2_;
		}
		return "null";
	}
}
