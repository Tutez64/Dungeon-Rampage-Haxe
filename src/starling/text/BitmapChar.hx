package starling.text;

import starling.display.Image;
import starling.textures.Texture;

class BitmapChar {
	var _texture:Texture;

	var _charID:Int = 0;

	var _xOffset:Float = Math.NaN;

	var _yOffset:Float = Math.NaN;

	var _xAdvance:Float = Math.NaN;

	var _kernings:ASDictionary<ASAny, ASAny>;

	public function new(id:Int, texture:Texture, xOffset:Float, yOffset:Float, xAdvance:Float) {
		_charID = id;
		_texture = texture;
		_xOffset = xOffset;
		_yOffset = yOffset;
		_xAdvance = xAdvance;
		_kernings = null;
	}

	public function addKerning(charID:Int, amount:Float) {
		if (_kernings == null) {
			_kernings = new ASDictionary<ASAny, ASAny>();
		}
		_kernings[charID] = amount;
	}

	public function getKerning(charID:Int):Float {
		if (_kernings == null || !_kernings.exists(charID)) {
			return 0;
		}
		return ASCompat.toNumber(ASDictionary.getInt(_kernings, charID));
	}

	public function createImage():Image {
		return new Image(_texture);
	}

	@:isVar public var charID(get, never):Int;

	public function get_charID():Int {
		return _charID;
	}

	@:isVar public var xOffset(get, never):Float;

	public function get_xOffset():Float {
		return _xOffset;
	}

	@:isVar public var yOffset(get, never):Float;

	public function get_yOffset():Float {
		return _yOffset;
	}

	@:isVar public var xAdvance(get, never):Float;

	public function get_xAdvance():Float {
		return _xAdvance;
	}

	@:isVar public var texture(get, never):Texture;

	public function get_texture():Texture {
		return _texture;
	}

	@:isVar public var width(get, never):Float;

	public function get_width():Float {
		return _texture != null ? _texture.width : 0;
	}

	@:isVar public var height(get, never):Float;

	public function get_height():Float {
		return _texture != null ? _texture.height : 0;
	}
}
