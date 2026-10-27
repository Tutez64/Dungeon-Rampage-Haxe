package com.maccherone.json;

class JSONParseError extends Error {
	var _location:Int = 0;

	var _text:String;

	public function new(message:String = "", location:Int = 0, text:String = "") {
		super(message);
		name = "JSONParseError";
		_location = location;
		_text = text;
	}

	@:isVar public var location(get, never):Int;

	public function get_location():Int {
		return _location;
	}

	@:isVar public var text(get, never):String;

	public function get_text():String {
		return _text;
	}
}
