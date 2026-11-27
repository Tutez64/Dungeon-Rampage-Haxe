package settings.model;

import input.keyBindings.KeyBindings;

class KeyBindingValue {
	public static inline final PRIMARY = "primary";

	public static inline final ALTERNATE = "alternate";

	public function new() {}

	public static function make(primary:Int, alternate:Int):ASObject {
		var _loc3_:ASObject = {};
		_loc3_["primary"] = primary;
		_loc3_["alternate"] = alternate;
		return _loc3_;
	}

	public static function primary(value:ASObject):Int {
		return slot(value, "primary");
	}

	public static function alternate(value:ASObject):Int {
		return slot(value, "alternate");
	}

	public static function slot(value:ASObject, name:String):Int {
		if (value == null || !value.hasOwnProperty(name)) {
			return 0;
		}
		var _loc3_ = ASCompat.toNumber(value[name]);
		return Math.isNaN(_loc3_) ? 0 : ASCompat.floatToInt(_loc3_);
	}

	public static function withSlot(value:ASObject, name:String, keyCode:Int):ASObject {
		return name == "primary" ? make(keyCode, alternate(value)) : make(primary(value), keyCode);
	}

	public static function equals(a:ASObject, b:ASObject):Bool {
		return primary(a) == primary(b) && alternate(a) == alternate(b);
	}

	public static function coerce(raw:ASAny, fallback:ASObject):ASObject {
		if (raw == null || ASCompat.typeof(raw) != "object") {
			return fallback;
		}
		var _loc4_ = slot(raw, "primary");
		var _loc3_ = slot(raw, "alternate");
		return make(KeyBindings.isBindable(_loc4_) ? _loc4_ : 0, KeyBindings.isBindable(_loc3_) ? _loc3_ : 0);
	}
}
