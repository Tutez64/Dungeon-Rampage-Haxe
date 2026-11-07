package com.junkbyte.console.vos;

import com.junkbyte.console.utils.FlashRegex;
import flash.utils.ByteArray;

class Log {
	public var timeStr:String;

	public var time:UInt = 0;

	public var text:String;

	public var repeat:Bool = false;

	public var priority:Int = 0;

	public var prev:Log;

	public var next:Log;

	public var lineStr:String;

	public var line:UInt = 0;

	public var html:Bool = false;

	public var chStr:String;

	public var ch:String;

	public function new(txt:String = /*undefined*/ null, cc:String = /*undefined*/ null, pp:Int = 0, repeating:Bool = false, ishtml:Bool = false) {
		text = txt;
		ch = cc;
		priority = pp;
		repeat = repeating;
		html = ishtml;
	}

	public static function FromBytes(bytes:ByteArray):Log {
		var _loc2_ = bytes.readUTFBytes(bytes.readUnsignedInt());
		var _loc3_ = bytes.readUTF();
		var _loc4_ = bytes.readInt();
		var _loc5_ = bytes.readBoolean();
		return new Log(_loc2_, _loc3_, _loc4_, _loc5_, true);
	}

	public function toString():String {
		return "[" + ch + "] " + plainText();
	}

	public function toBytes(bytes:ByteArray) {
		var _loc2_ = new ByteArray();
		_loc2_.writeUTFBytes(text);
		bytes.writeUnsignedInt(_loc2_.length);
		bytes.writeBytes(_loc2_);
		bytes.writeUTF(ch);
		bytes.writeInt(priority);
		bytes.writeBoolean(repeat);
	}

	public function plainText():String {
		var _loc1_ = text;
		_loc1_ = FlashRegex.replace(_loc1_, new EReg("<.*?>", "g"), "");
		_loc1_ = FlashRegex.replace(_loc1_, new EReg("&lt;", "g"), "<");
		return FlashRegex.replace(_loc1_, new EReg("&gt;", "g"), ">");
	}

	public function clone():Log {
		var _loc1_ = new Log(text, ch, priority, repeat, html);
		_loc1_.line = line;
		_loc1_.time = time;
		return _loc1_;
	}
}
