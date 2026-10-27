package com.junkbyte.console;

class KeyBind {
	var _code:Bool = false;

	var _key:String;

	public function new(v:ASAny, shift:Bool = false, ctrl:Bool = false, alt:Bool = false, onUp:Bool = false) {
		this._key = ASCompat.toString(v).toUpperCase();
		if (Std.isOfType(v, Int)) {
			this._code = true;
		} else if (!ASCompat.toBool(v) || this._key.length != 1) {
			throw new Error("KeyBind: character (first char) must be a single character. You gave [" + Std.string(v) + "]");
		}
		if (this._code) {
			this._key = "keycode:" + this._key;
		}
		if (shift) {
			this._key += "+shift";
		}
		if (ctrl) {
			this._key += "+ctrl";
		}
		if (alt) {
			this._key += "+alt";
		}
		if (onUp) {
			this._key += "+up";
		}
	}

	@:isVar public var useKeyCode(get, never):Bool;

	public function get_useKeyCode():Bool {
		return this._code;
	}

	@:isVar public var key(get, never):String;

	public function get_key():String {
		return this._key;
	}
}
