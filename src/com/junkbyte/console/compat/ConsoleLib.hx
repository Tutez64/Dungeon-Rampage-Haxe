package com.junkbyte.console.compat;

class ConsoleLib {
	public function new() {}

	public static function getQualifiedClassName(value:ASAny):String {
		return ASCompat.getQualifiedClassName(value);
	}

	public static function getDefinitionByName(name:String):ASAny {
		return Type.resolveClass(name);
	}

	public static function isNaN(f:Float):Bool {
		return f != f;
	}

	public static function get_NAN():Float {
		return Math.NaN;
	}

	public static function parseInt(s:String):ASObject {
		var _loc2_:Float = ASCompat.parseInt(s);
		if (_loc2_ != _loc2_) {
			return null;
		}
		return ASCompat.floatToInt(_loc2_);
	}

	public static function now():Date {
		return Date.now();
	}

	public static function typeOf(v:ASAny):String {
		return ASCompat.typeof(v);
	}

	public static function truthy(v:ASAny):Bool {
		return ASCompat.toBool(v);
	}

	public static function toNumber(v:ASAny):Float {
		return ASCompat.toNumber(v);
	}

	public static function string(v:ASAny):String {
		return ASCompat.toString(v);
	}

	public static function strictEquals(a:ASAny, b:ASAny):Bool {
		if (ConsoleLib.typeOf(a) == ConsoleLib.typeOf(b)) {
			return a == b;
		}
		return false;
	}
}
