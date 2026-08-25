package com.adobe.serialization.json;

final class JSONToken {
	@:allow(com.adobe.serialization.json) static final token:JSONToken = new JSONToken();

	public var type:Int = 0;

	public var value:ASObject;

	public function new(type:Int = -1, value:ASObject = null) {
		this.type = type;
		this.value = value;
	}

	@:allow(com.adobe.serialization.json) static function create(type:Int = -1, value:ASObject = null):JSONToken {
		token.type = type;
		token.value = value;
		return token;
	}
}
