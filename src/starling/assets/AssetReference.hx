package starling.assets;

import starling.textures.TextureOptions;

class AssetReference {
	var _name:String;

	var _url:String;

	var _data:ASObject;

	var _mimeType:String;

	var _extension:String;

	var _textureOptions:TextureOptions;

	public function new(data:ASObject) {
		_data = data;
		_textureOptions = new TextureOptions();
		if (Std.isOfType(data, String)) {
			_url = ASCompat.asString(data);
		} else if (data.hasOwnProperty("url")) {
			_url = ASCompat.asString(data["url"]);
		}
	}

	@:isVar public var name(get, set):String;

	public function get_name():String {
		return _name;
	}

	function set_name(value:String):String {
		return _name = value;
	}

	@:isVar public var url(get, set):String;

	public function get_url():String {
		return _url;
	}

	function set_url(value:String):String {
		return _url = value;
	}

	@:isVar public var data(get, set):ASObject;

	public function get_data():ASObject {
		return _data;
	}

	function set_data(value:ASObject):ASObject {
		return _data = value;
	}

	@:isVar public var mimeType(get, set):String;

	public function get_mimeType():String {
		return _mimeType;
	}

	function set_mimeType(value:String):String {
		return _mimeType = value;
	}

	@:isVar public var extension(get, set):String;

	public function get_extension():String {
		return _extension;
	}

	function set_extension(value:String):String {
		return _extension = value;
	}

	@:isVar public var textureOptions(get, set):TextureOptions;

	public function get_textureOptions():TextureOptions {
		return _textureOptions;
	}

	function set_textureOptions(value:TextureOptions):TextureOptions {
		_textureOptions.copyFrom(value);
		return value;
	}
}
