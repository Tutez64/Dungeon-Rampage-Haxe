package com.junkbyte.console;

import flash.Boot;

class KeyBind {
	public var _key:String;

	public var _code:Bool = false;

	public function new(v:ASAny = /*undefined*/ null, shift:Bool = false, ctrl:Bool = false, alt:Bool = false, onUp:Bool = false) {
		if (Boot.skip_constructor) {
			return;
		}
		_key = Std.string(v).toUpperCase();
		if (Std.isOfType(v, Int)) {
			_code = true;
		} else if (v == null || _key.length != 1) {
			throw new Error("KeyBind: character (first char) must be a single character. You gave [" + Std.string(v) + "]");
		}
		if (_code) {
			_key = "keycode:" + _key;
		}
		if (shift) {
			_key += "+shift";
		}
		if (ctrl) {
			_key += "+ctrl";
		}
		if (alt) {
			_key += "+alt";
		}
		if (onUp) {
			_key += "+up";
		}
	}

	public function get_useKeyCode():Bool {
		return _code;
	}

	@:isVar public var useKeyCode(get, never):Bool;

	public function get_useKeyCode():Bool {
		return get_useKeyCode();
	}

	public function get_key():String {
		return _key;
	}

	@:isVar public var key(get, never):String;

	public function get_key():String {
		return get_key();
	}
}
