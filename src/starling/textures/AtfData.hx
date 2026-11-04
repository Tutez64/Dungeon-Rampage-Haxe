package starling.textures;

import flash.utils.ByteArray;
import flash.errors.ArgumentError;

class AtfData {
	var _format:String;

	var _width:Int = 0;

	var _height:Int = 0;

	var _numTextures:Int = 0;

	var _isCubeMap:Bool = false;

	var _data:ByteArray;

	public function new(data:ByteArray) {
		var _loc4_ = false;
		var _loc2_ = 0;

		if (!isAtfData(data)) {
			throw new ArgumentError("Invalid ATF data");
		}
		if (data[6] == 255) {
			data.position = (12 : UInt);
		} else {
			data.position = (6 : UInt);
		}
		var _loc3_ = data.readUnsignedByte();
		switch ((_loc3_ : Int) & 0x7F) {
			case 0 | 1:
				_format = "bgra";

			case 2 | 3 | 12:
				_format = "compressed";

			case 4 | 5 | 13:
				_format = "compressedAlpha";

			default:
				throw new Error("Invalid ATF format");
		}
		_width = ASCompat.floatToInt(Math.pow(2, data.readUnsignedByte()));
		_height = ASCompat.floatToInt(Math.pow(2, data.readUnsignedByte()));
		_numTextures = (data.readUnsignedByte() : Int);
		_isCubeMap = ((_loc3_ : Int) & 0x80) != 0;
		_data = data;
		if (data[5] != 0 && data[6] == 255) {
			_loc4_ = ((data[5] : Int) & 1) == 1;
			_loc2_ = (data[5] : Int) >> 1 & 0x7F;
			_numTextures = _loc4_ ? 1 : _loc2_;
		}
	}

	public static function isAtfData(data:ByteArray):Bool {
		var _loc2_:String = null;
		if (data.length < 3) {
			return false;
		}
		_loc2_ = String.fromCharCode((data[0] : Int)) + String.fromCharCode(ASCompat.toInt(data[1])) + String.fromCharCode(ASCompat.toInt(data[2]));
		return _loc2_ == "ATF";
	}

	@:isVar public var format(get, never):String;

	public function get_format():String {
		return _format;
	}

	@:isVar public var width(get, never):Int;

	public function get_width():Int {
		return _width;
	}

	@:isVar public var height(get, never):Int;

	public function get_height():Int {
		return _height;
	}

	@:isVar public var numTextures(get, never):Int;

	public function get_numTextures():Int {
		return _numTextures;
	}

	@:isVar public var isCubeMap(get, never):Bool;

	public function get_isCubeMap():Bool {
		return _isCubeMap;
	}

	@:isVar public var data(get, never):ByteArray;

	public function get_data():ByteArray {
		return _data;
	}
}
