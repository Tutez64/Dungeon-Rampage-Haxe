package com.junkbyte.console.core;

import com.junkbyte.console.vos.WeakObject;
import flash.Boot;

class ExeValue {
	public var prop:String;

	public var obj:ASAny;

	public function new(b:ASAny = /*undefined*/ null, p:String = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		obj = b;
		prop = p;
	}

	public function setValue(v:ASAny) {
		if (prop == null || prop == "") {
			obj = v;
		} else if (Std.isOfType(obj, WeakObject)) {
			obj.set(prop, v);
		} else {
			obj[prop] = v;
		}
	}

	public function get_value():ASAny {
		if (prop == null || prop == "") {
			return obj;
		}
		if (Std.isOfType(obj, WeakObject)) {
			return obj.get(prop);
		}
		return obj[prop];
	}

	@:isVar public var value(get, never):ASAny;

	public function get_value():ASAny {
		return get_value();
	}
}
