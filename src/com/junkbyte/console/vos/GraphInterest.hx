package com.junkbyte.console.vos;

import com.junkbyte.console.core.Executer;
import flash.utils.ByteArray;

class GraphInterest {
	var _ref:WeakRef;

	public var _prop:String;

	var useExec:Bool = false;

	public var key:String;

	public var col:Float = Math.NaN;

	public var v:Float = Math.NaN;

	public var avg:Float = Math.NaN;

	public function new(keystr:String = "", color:Float = 0) {
		this.col = color;
		this.key = keystr;
	}

	public static function FromBytes(bytes:ByteArray):GraphInterest {
		var _loc2_ = new GraphInterest(bytes.readUTF(), bytes.readUnsignedInt());
		_loc2_.v = bytes.readDouble();
		_loc2_.avg = bytes.readDouble();
		return _loc2_;
	}

	public function setObject(object:ASObject, property:String):Float {
		this._ref = new WeakRef(object);
		this._prop = property;
		this.useExec = new compat.RegExp("[^\\w\\d]").search(this._prop) >= 0;
		this.v = this.getCurrentValue();
		this.avg = this.v;
		return this.v;
	}

	@:isVar public var obj(get, never):ASObject;

	public function get_obj():ASObject {
		return this._ref != null ? this._ref.reference : /*undefined*/ null;
	}

	@:isVar public var prop(get, never):String;

	public function get_prop():String {
		return this._prop;
	}

	public function getCurrentValue():Float {
		return this.useExec ? ASCompat.toNumber(Executer.Exec(this.obj, this._prop)) : ASCompat.toNumber(this.obj[this._prop]);
	}

	public function setValue(val:Float, averaging:UInt = (0 : UInt)) {
		this.v = val;
		if (averaging > 0) {
			if (Math.isNaN(this.avg)) {
				this.avg = this.v;
			} else {
				this.avg += (this.v - this.avg) / averaging;
			}
		}
	}

	public function toBytes(bytes:ByteArray) {
		bytes.writeUTF(this.key);
		bytes.writeUnsignedInt((Std.int(this.col) : UInt));
		bytes.writeDouble(this.v);
		bytes.writeDouble(this.avg);
	}
}
