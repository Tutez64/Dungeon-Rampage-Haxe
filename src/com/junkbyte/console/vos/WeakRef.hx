package com.junkbyte.console.vos;

import flash.Boot;
import haxe.ds.WeakMap;

class WeakRef {
	public var _val:ASAny;

	public var _strong:Bool = false;

	public function new(ref:ASAny = /*undefined*/ null, strong:Bool = false) {
		if (Boot.skip_constructor) {
			return;
		}
		_strong = strong;
		set_reference(ref);
	}

	public function set_reference(ref:ASAny):ASAny {
		var _loc2_ = ASCompat.dynamicAs(null, WeakMap);
		if (_strong) {
			_val = ref;
		} else {
			_loc2_ = new WeakMap();
			(_loc2_ : ASAny)[ref] = null;
			_val = _loc2_;
		}
		return ref;
	}

	@:isVar public var reference(get, set):ASAny;

	public function set_reference(value:ASAny):ASAny {
		set_reference(value);
		return value;
	}

	public function get_strong():Bool {
		return _strong;
	}

	@:isVar public var strong(get, never):Bool;

	public function get_strong():Bool {
		return get_strong();
	}

	public function get_reference():ASAny {
		var _loc1_:ASAny = ASCompat.dynamicAs(null, WeakMap);
		var _loc2_:ASAny = null;
		var _loc3_:ASAny = null;
		if (_strong) {
			return _val;
		}
		_loc1_ = _val;
		_loc2_ = _loc1_.keys();
		if (!ASCompat.toBool(_loc2_.hasNext())) {
			return null;
		}
		return _loc2_.next();
	}

	function get_reference():ASAny {
		return get_reference();
	}
}
