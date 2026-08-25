package com.facebook.graph.utils;

import flash.utils.ByteArray;
import flash.utils.Endian;

class PostRequest {
	public var boundary:String = "-----";

	var postData:ByteArray;

	public function new() {
		this.createPostData();
	}

	public function createPostData() {
		this.postData = new ByteArray();
		this.postData.endian = Endian.BIG_ENDIAN;
	}

	public function writePostData(name:String, value:String) {
		var _loc3_:String = null;
		this.writeBoundary();
		this.writeLineBreak();
		_loc3_ = "Content-Disposition: form-data; name=\"" + name + "\"";
		var _loc4_ = (_loc3_.length : UInt);
		var _loc5_:Float = 0;
		while (_loc5_ < _loc4_) {
			this.postData.writeByte(_loc3_.charCodeAt(Std.int(_loc5_)));
			_loc5_++;
		}
		this.writeLineBreak();
		this.writeLineBreak();
		this.postData.writeUTFBytes(value);
		this.writeLineBreak();
	}

	public function writeFileData(filename:String, fileData:ByteArray, contentType:String) {
		var _loc4_:String = null;
		var _loc5_ = 0;
		var _loc6_ = (0 : UInt);
		this.writeBoundary();
		this.writeLineBreak();
		_loc4_ = "Content-Disposition: form-data; name=\"" + filename + "\"; filename=\"" + filename + "\";";
		_loc5_ = _loc4_.length;
		_loc6_ = (0 : UInt);
		while (_loc6_ < (_loc5_:UInt)) {
			this.postData.writeByte(_loc4_.charCodeAt((_loc6_ : Int)));
			_loc6_++;
		}
		this.postData.writeUTFBytes(filename);
		this.writeQuotationMark();
		this.writeLineBreak();
		_loc4_ = if (ASCompat.stringAsBool(contentType)) contentType else "application/octet-stream";
		_loc5_ = _loc4_.length;
		_loc6_ = (0 : UInt);
		while (_loc6_ < (_loc5_:UInt)) {
			this.postData.writeByte(_loc4_.charCodeAt((_loc6_ : Int)));
			_loc6_++;
		}
		this.writeLineBreak();
		this.writeLineBreak();
		fileData.position = (0 : UInt);
		this.postData.writeBytes(fileData, (0 : UInt), fileData.length);
		this.writeLineBreak();
	}

	public function getPostData():ByteArray {
		this.postData.position = (0 : UInt);
		return this.postData;
	}

	public function close() {
		this.writeBoundary();
		this.writeDoubleDash();
	}

	function writeLineBreak() {
		this.postData.writeShort(3338);
	}

	function writeQuotationMark() {
		this.postData.writeByte(34);
	}

	function writeDoubleDash() {
		this.postData.writeShort(11565);
	}

	function writeBoundary() {
		this.writeDoubleDash();
		var _loc1_ = (this.boundary.length : UInt);
		var _loc2_ = (0 : UInt);
		while (_loc2_ < _loc1_) {
			this.postData.writeByte(this.boundary.charCodeAt((_loc2_ : Int)));
			_loc2_++;
		}
	}
}
