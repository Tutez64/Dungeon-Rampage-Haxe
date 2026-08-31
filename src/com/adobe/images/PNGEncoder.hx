package com.adobe.images;

import flash.display.BitmapData;
import flash.geom.*;
import flash.utils.ByteArray;

class PNGEncoder {
	static var crcTable:Array<ASAny>;

	static var crcTableComputed:Bool = false;

	public function new() {}

	public static function encode(img:BitmapData):ByteArray {
		var _loc6_ = (0 : UInt);
		var _loc7_ = 0;
		var _loc2_ = new ByteArray();
		_loc2_.writeUnsignedInt((Std.int(2303741511) : UInt));
		_loc2_.writeUnsignedInt((218765834 : UInt));
		var _loc3_ = new ByteArray();
		_loc3_.writeInt(img.width);
		_loc3_.writeInt(img.height);
		_loc3_.writeUnsignedInt((134610944 : UInt));
		_loc3_.writeByte(0);
		writeChunk(_loc2_, (1229472850 : UInt), _loc3_);
		var _loc4_ = new ByteArray();
		var _loc5_ = 0;
		while (_loc5_ < img.height) {
			_loc4_.writeByte(0);
			if (!img.transparent) {
				_loc7_ = 0;
				while (_loc7_ < img.width) {
					_loc6_ = img.getPixel(_loc7_, _loc5_);
					_loc4_.writeUnsignedInt((((_loc6_ : Int) & 0xFFFFFF) << 8 | 0xFF : UInt));
					_loc7_ = ASCompat.toInt(_loc7_) + 1;
				}
			} else {
				_loc7_ = 0;
				while (_loc7_ < img.width) {
					_loc6_ = img.getPixel32(_loc7_, _loc5_);
					_loc4_.writeUnsignedInt((((_loc6_ : Int) & 0xFFFFFF) << 8 | (_loc6_ : Int) >>> 24 : UInt));
					_loc7_ = ASCompat.toInt(_loc7_) + 1;
				}
			}
			_loc5_ = ASCompat.toInt(_loc5_) + 1;
		}
		_loc4_.compress();
		writeChunk(_loc2_, (1229209940 : UInt), _loc4_);
		writeChunk(_loc2_, (1229278788 : UInt), null);
		return _loc2_;
	}

	static function writeChunk(png:ByteArray, type:UInt, data:ByteArray) {
		var _loc8_ = (0 : UInt);
		var _loc9_ = (0 : UInt);
		var _loc10_ = (0 : UInt);
		if (!crcTableComputed) {
			crcTableComputed = true;
			crcTable = [];
			_loc9_ = (0 : UInt);
			while (_loc9_ < 256) {
				_loc8_ = _loc9_;
				_loc10_ = (0 : UInt);
				while (_loc10_ < 8) {
					if (((_loc8_ : Int) & 1) != 0) {
						_loc8_ = (Std.int(3988292384) ^ (_loc8_ : Int) >>> 1:UInt);
					} else {
						_loc8_ = ((_loc8_ : Int) >>> 1 : UInt);
					}
					_loc10_++;
				}
				crcTable[(_loc9_ : Int)] = _loc8_;
				_loc9_++;
			}
		}
		var _loc4_ = (0 : UInt);
		if (data != null) {
			_loc4_ = data.length;
		}
		png.writeUnsignedInt(_loc4_);
		var _loc5_ = png.position;
		png.writeUnsignedInt(type);
		if (data != null) {
			png.writeBytes(data);
		}
		var _loc6_ = png.position;
		png.position = _loc5_;
		_loc8_ = (Std.int(4294967295) : UInt);
		var _loc7_ = 0;
		while ((_loc7_ : UInt) < _loc6_ - _loc5_) {
			_loc8_ = (ASCompat.toInt(crcTable[((_loc8_ : Int) ^ (png.readUnsignedByte() : Int)) & 255]) ^ (_loc8_ : Int) >>> 8:UInt);
			_loc7_ = ASCompat.toInt(_loc7_) + 1;
		}
		_loc8_ = ((_loc8_ : Int) ^ Std.int(4294967295) : UInt);
		png.position = _loc6_;
		png.writeUnsignedInt(_loc8_);
	}
}
