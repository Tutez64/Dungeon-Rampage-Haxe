package com.maccherone.json;

class JSONToken {
	var _value:ASObject;

	var _type:Int = 0;

	public function new(type:Int = -1, value:ASObject = null) {
		_type = type;
		_value = value;
	}

	@:isVar public var value(get, set):ASObject;

	public function get_value():ASObject {
		return _value;
	}

	@:isVar public var type(get, set):Int;

	public function get_type():Int {
		return _type;
	}

	function set_type(value:Int):Int {
		return _type = value;
	}

	function set_value(v:ASObject):ASObject {
		return _value = v;
	}
}
