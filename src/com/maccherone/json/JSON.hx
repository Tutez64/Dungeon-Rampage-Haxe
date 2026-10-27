package com.maccherone.json;

class JSON {
	public function new() {}

	public static function decode(s:String, strict:Bool = true):ASAny {
		return new JSONDecoder(s, strict).getValue();
	}

	public static function encode(o:ASObject, pretty:Bool = false, maxLength:Int = 60):String {
		return new JSONEncoder(o, pretty, maxLength).getString();
	}
}
