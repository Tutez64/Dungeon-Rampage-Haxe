package json;

class JsonCodec {
	public function new() {}

	public static function encode(value:ASAny, pretty:Bool = false, maxLength:Int = 60):String {
		return new JsonEncoder(value, pretty, maxLength).getString();
	}

	public static function decode(text:String):ASAny {
		return haxe.Json.parse(text);
	}
}
