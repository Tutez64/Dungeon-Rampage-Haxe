package com.junkbyte.console.vos;

import flash.geom.Rectangle;
import flash.utils.ByteArray;

class GraphGroup {
	public static inline final FPS = (1 : UInt);

	public static inline final MEM = (2 : UInt);

	public var type:UInt = 0;

	public var name:String;

	public var freq:Int = 1;

	public var low:Float = Math.NaN;

	public var hi:Float = Math.NaN;

	public var fixed:Bool = false;

	public var averaging:UInt = 0;

	public var inv:Bool = false;

	public var interests:Array<ASAny> = [];

	public var rect:Rectangle;

	public var idle:Int = 0;

	public function new(n:String) {
		this.name = n;
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
			_loc3_--;
		}
		return _loc2_;
	}

	public function updateMinMax(v:Float) {
		if (!Math.isNaN(v) && !this.fixed) {
			if (Math.isNaN(this.low)) {
				this.low = v;
				this.hi = v;
			}
			if (v > this.hi) {
				this.hi = v;
			}
			if (v < this.low) {
				this.low = v;
			}
		}
	}

	public function toBytes(bytes:ByteArray) {
		var _loc2_:GraphInterest = null;
		bytes.writeUTF(this.name);
		bytes.writeUnsignedInt(this.type);
		bytes.writeUnsignedInt((this.idle : UInt));
		bytes.writeDouble(this.low);
		bytes.writeDouble(this.hi);
		bytes.writeBoolean(this.inv);
		bytes.writeUnsignedInt((this.interests.length : UInt));
		final __ax4_iter_47 = this.interests;
		if (checkNullIteratee(__ax4_iter_47))
			for (_tmp_ in __ax4_iter_47) {
				_loc2_ = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
				_loc2_.toBytes(bytes);
			}
	}
}
