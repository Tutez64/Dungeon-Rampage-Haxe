package com.junkbyte.console.vos;

import flash.utils.ByteArray;

class Log {
	public var line:UInt = 0;

	public var text:String;

	public var ch:String;

	public var priority:Int = 0;

	public var repeat:Bool = false;

	public var html:Bool = false;

	public var time:UInt = 0;

	public var timeStr:String;

	public var lineStr:String;

	public var chStr:String;

	public var next:Log;

	public var prev:Log;

	public function new(txt:String, cc:String, pp:Int, repeating:Bool = false, ishtml:Bool = false) {
		this.text = txt;
		this.ch = cc;
		this.priority = pp;
		this.repeat = repeating;
		this.html = ishtml;
	}

	public static function FromBytes(bytes:ByteArray):Log {
		var _loc2_ = bytes.readUTFBytes(bytes.readUnsignedInt());
		var _loc3_ = bytes.readUTF();
		var _loc4_ = bytes.readInt();
		var _loc5_ = bytes.readBoolean();
		return new Log(_loc2_, _loc3_, _loc4_, _loc5_, true);
	}

	public function toBytes(bytes:ByteArray) {
		var _loc2_ = new ByteArray();
		_loc2_.writeUTFBytes(this.text);
		bytes.writeUnsignedInt(_loc2_.length);
		bytes.writeBytes(_loc2_);
		bytes.writeUTF(this.ch);
		bytes.writeInt(this.priority);
		bytes.writeBoolean(this.repeat);
	}

	public function plainText():String {
		return new compat.RegExp("&gt;", "g").replace(new compat.RegExp("&lt;", "g").replace(new compat.RegExp("<.*?>", "g").replace(this.text, ""), "<"), ">");
	}

	public function toString():String {
		return "[" + this.ch + "] " + this.plainText();
	}

	public function clone():Log {
		var _loc1_ = new Log(this.text, this.ch, this.priority, this.repeat, this.html);
		_loc1_.line = this.line;
		_loc1_.time = this.time;
		return _loc1_;
	}
}
