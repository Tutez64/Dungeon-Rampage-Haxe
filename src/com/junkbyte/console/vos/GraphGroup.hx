package com.junkbyte.console.vos;

import flash.Boot;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

class GraphGroup {
	public static var FPS:UInt = (1 : UInt);

	public static var MEM:UInt = (2 : UInt);

	public var type:UInt = 0;

	public var rect:Rectangle;

	public var name:String;

	public var low:Float = Math.NaN;

	public var inv:Bool = false;

	public var interests:Array<ASAny>;

	public var idle:Int = 0;

	public var hi:Float = Math.NaN;

	public var freq:Int = 0;

	public var fixed:Bool = false;

	public var averaging:UInt = 0;

	public function new(n:String = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		idle = 0;
		rect = null;
		interests = [];
		inv = false;
		averaging = (0 : UInt);
		fixed = false;
		hi = Math.NaN;
		low = Math.NaN;
		freq = 1;
		name = null;
		type = (0 : UInt);
		name = n;
	}

	public static function FromBytes(bytes:ByteArray):GraphGroup {
		var _loc2_ = new GraphGroup(bytes.readUTF());
		_loc2_.type = bytes.readUnsignedInt();
		_loc2_.idle = (bytes.readUnsignedInt() : Int);
		_loc2_.low = bytes.readDouble();
		_loc2_.hi = bytes.readDouble();
		_loc2_.inv = bytes.readBoolean();
		var _loc3_ = bytes.readUnsignedInt();
		while (_loc3_ != 0) {
			_loc2_.interests.push(GraphInterest.FromBytes(bytes));
			_loc3_ -= (1 : UInt);
		}
		return _loc2_;
	}

	public function updateMinMax(v:Float) {
		var _loc2_ = Math.NaN;
		if (v == v && !fixed) {
			_loc2_ = low;
			if (_loc2_ != _loc2_) {
				low = v;
				hi = v;
			}
			if (v > hi) {
				hi = v;
			}
			if (v < low) {
				low = v;
			}
		}
	}

	public function toBytes(bytes:ByteArray) {
		var _loc4_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		bytes.writeUTF(name);
		bytes.writeUnsignedInt(type);
		bytes.writeUnsignedInt((idle : UInt));
		bytes.writeDouble(low);
		bytes.writeDouble(hi);
		bytes.writeBoolean(inv);
		bytes.writeUnsignedInt((interests.length : UInt));
		var _loc2_ = 0;
		var _loc3_ = interests;
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc4_.toBytes(bytes);
		}
	}
}
