package com.adobe.serialization.json;

class JSONEncoder {
	var jsonString:String;

	public function new(value:ASAny) {
		this.jsonString = this.convertToString(value);
	}

	public function getString():String {
		return this.jsonString;
	}

	function convertToString(value:ASAny):String {
		if (Std.isOfType(value, String)) {
			return this.escapeString(ASCompat.asString(value));
		}
		if (Std.isOfType(value, Float)) {
			return Math.isFinite(ASCompat.asNumber(value)) ? Std.string(value) : "null";
		}
		if (Std.isOfType(value, Bool)) {
			return ASCompat.toBool(value) ? "true" : "false";
		}
		if (Std.isOfType(value, Array)) {
			return this.arrayToString(ASCompat.dynamicAs(value, Array));
		}
		if (value != null && value != null) {
			return this.objectToString(value);
		}
		return "null";
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

	function arrayToString(a:Array<ASAny>):String {
		var _loc2_ = "";
		var _loc3_ = a.length;
		var _loc4_ = 0;
		while (_loc4_ < _loc3_) {
			if (_loc2_.length > 0) {
				_loc2_ += ",";
			}
			_loc2_ += this.convertToString(a[_loc4_]);
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return "[" + _loc2_ + "]";
	}

	function objectToString(o:ASObject):String {
		var __ax4_iter_30:compat.XMLList;
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
						}
						s += this.escapeString(key) + ":" + this.convertToString(value);
					}
				}
		} else {
			__ax4_iter_30 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool {
				return __xml.name() == "variable" || __xml.name() == "accessor" && __xml.attribute("access").charAt(0) == "r";
			});
			if (checkNullIteratee(__ax4_iter_30))
				for (_tmp_ in __ax4_iter_30) {
					v = _tmp_;
					if (!(v.child("metadata") != null && ASCompat.filterXmlList(v.child("metadata"), function(__xml:compat.XML):Bool {
						return __xml.attribute("name") == "Transient";
					}).length() > 0)) {
						if (s.length > 0) {
							s += ",";
						}
						s += this.escapeString(v.attribute("name").toString()) + ":" + this.convertToString(o[v.attribute("name")]);
					}
				}
		}
		return "{" + s + "}";
	}
}
