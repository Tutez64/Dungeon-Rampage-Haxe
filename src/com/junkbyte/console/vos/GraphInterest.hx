package com.junkbyte.console.vos;

import com.junkbyte.console.core.Executer;
import com.junkbyte.console.utils.FlashRegex;
import flash.utils.ByteArray;

class GraphInterest {
	public var v:Float = Math.NaN;

	public var useExec:Bool = false;

	public var key:String;

	public var col:Int = 0;

	public var avg:Float = Math.NaN;

	public var _ref:WeakRef;

	public var _prop:String;

	public function new(keystr:String = /*undefined*/ null, color:Int = 0) {
		if (keystr == null) {
			keystr = "";
		}
		avg = Math.NaN;
		v = Math.NaN;
		col = 0;
		key = null;
		useExec = false;
		_prop = null;
		_ref = null;
		col = color;
		key = keystr;
	}

	public static function FromBytes(bytes:ByteArray):GraphInterest {
		var _loc2_ = new GraphInterest(bytes.readUTF(), (bytes.readUnsignedInt() : Int));
		_loc2_.v = bytes.readDouble();
		_loc2_.avg = bytes.readDouble();
		return _loc2_;
	}

	public function toBytes(bytes:ByteArray) {
		bytes.writeUTF(key);
		bytes.writeUnsignedInt((col : UInt));
		bytes.writeDouble(v);
		bytes.writeDouble(avg);
	}

	public function setValue(val:Float, averaging:UInt = (0 : UInt)) {
		var _loc3_ = Math.NaN;
		v = val;
		if (averaging > 0) {
			_loc3_ = avg;
			if (_loc3_ != _loc3_) {
				avg = v;
			} else {
				avg += (v - avg) / averaging;
			}
		}
	}

	public function setObject(object:ASAny, property:String):Float {
		_ref = new WeakRef(object);
		_prop = property;
		useExec = FlashRegex.search(_prop, new EReg("[^\\w\\d]", "")) >= 0;
		v = getCurrentValue();
		return v;
	}

	@:isVar public var prop(get, never):String;

	public function get_prop():String {
		return _prop;
	}

	@:isVar public var obj(get, never):ASAny;

	public function get_obj():ASAny {
		if (_ref != null) {
			return _ref.get_reference();
		}
		return null;
	}

	public function getCurrentValue():Float {
		if (useExec) {
			return ASCompat.toNumber(Executer.Exec(get_obj(), _prop));
		}
		return ASCompat.toNumber(get_obj()[_prop]);
	}
}
