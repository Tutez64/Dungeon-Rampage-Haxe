package starling.rendering;

import flash.display3D.VertexBuffer3D;
import starling.core.Starling;
import starling.utils.StringUtil;
import flash.errors.ArgumentError;

class VertexDataFormat {
	static var sFormats:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var _format:String;

	var _vertexSize:Int = 0;

	var _attributes:Vector<VertexDataAttribute>;

	public function new() {
		_attributes = new Vector<VertexDataAttribute>();
	}

	public static function fromString(format:String):VertexDataFormat {
		var _loc2_:VertexDataFormat = null;
		var _loc3_:String = null;
		if (sFormats.exists(format)) {
			return ASCompat.coerce(ASDictionary.getString(sFormats, format), VertexDataFormat);
		}
		_loc2_ = new VertexDataFormat();
		_loc2_.parseFormat(format);
		_loc3_ = _loc2_._format;
		if (sFormats.exists(_loc3_)) {
			_loc2_ = ASCompat.coerce(ASDictionary.getString(sFormats, _loc3_), VertexDataFormat);
		}
		sFormats[format] = _loc2_;
		sFormats[_loc3_] = _loc2_;
		return _loc2_;
	}

	public function extend(format:String):VertexDataFormat {
		return fromString(_format + ", " + format);
	}

	public function getSize(attrName:String):Int {
		return getAttribute(attrName).size;
	}

	public function getSizeIn32Bits(attrName:String):Int {
		return ASCompat.floatToInt(getAttribute(attrName).size / 4);
	}

	public function getOffset(attrName:String):Int {
		return getAttribute(attrName).offset;
	}

	public function getOffsetIn32Bits(attrName:String):Int {
		return ASCompat.floatToInt(getAttribute(attrName).offset / 4);
	}

	public function getFormat(attrName:String):String {
		return getAttribute(attrName).format;
	}

	public function getName(attrIndex:Int):String {
		return _attributes[attrIndex].name;
	}

	public function hasAttribute(attrName:String):Bool {
		var _loc3_ = 0;
		var _loc2_ = _attributes.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			if (_attributes[_loc3_].name == attrName) {
				return true;
			}
			_loc3_++;
		}
		return false;
	}

	public function setVertexBufferAt(index:Int, buffer:VertexBuffer3D, attrName:String) {
		var _loc4_ = getAttribute(attrName);
		Starling.context.setVertexBufferAt(index, buffer, ASCompat.floatToInt(_loc4_.offset / 4), _loc4_.format);
	}

	function parseFormat(format:String) {
		var _loc5_:Array<ASAny> = null;
		var _loc4_ = 0;
		var _loc3_ = 0;
		var _loc6_ = 0;
		var _loc10_:String = null;
		var _loc7_:Array<ASAny> = null;
		var _loc9_:String = null;
		var _loc2_:String = null;
		var _loc8_:VertexDataAttribute = null;
		if (format != null && format != "") {
			_attributes.length = 0;
			_format = "";
			_loc5_ = (cast format.split(","));
			_loc4_ = _loc5_.length;
			_loc3_ = 0;
			_loc6_ = 0;
			while (_loc6_ < _loc4_) {
				_loc10_ = _loc5_[_loc6_];
				_loc7_ = (cast _loc10_.split(":"));
				if (_loc7_.length != 2) {
					throw new ArgumentError("Missing colon: " + _loc10_);
				}
				_loc9_ = StringUtil.trim(_loc7_[0]);
				_loc2_ = StringUtil.trim(_loc7_[1]);
				if (_loc9_.length == 0 || _loc2_.length == 0) {
					throw new ArgumentError("Invalid format string: " + _loc10_);
				}
				_loc8_ = new VertexDataAttribute(_loc9_, _loc2_, _loc3_);
				_loc3_ += _loc8_.size;
				_format += (_loc6_ == 0 ? "" : ", ") + _loc8_.name + ":" + _loc8_.format;
				_attributes[_attributes.length] = _loc8_;
				_loc6_++;
			}
			_vertexSize = _loc3_;
		} else {
			_format = "";
		}
	}

	public function toString():String {
		return _format;
	}

	@:allow(starling.rendering) function getAttribute(attrName:String):VertexDataAttribute {
		var _loc4_:VertexDataAttribute = null;
		var _loc3_ = 0;
		var _loc2_ = _attributes.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			_loc4_ = _attributes[_loc3_];
			if (_loc4_.name == attrName) {
				return _loc4_;
			}
			_loc3_++;
		}
		return null;
	}

	@:allow(starling.rendering) @:isVar var attributes(get, never):Vector<VertexDataAttribute>;

	function get_attributes():Vector<VertexDataAttribute> {
		return _attributes;
	}

	@:isVar public var formatString(get, never):String;

	public function get_formatString():String {
		return _format;
	}

	@:isVar public var vertexSize(get, never):Int;

	public function get_vertexSize():Int {
		return _vertexSize;
	}

	@:isVar public var vertexSizeIn32Bits(get, never):Int;

	public function get_vertexSizeIn32Bits():Int {
		return ASCompat.floatToInt(_vertexSize / 4);
	}

	@:isVar public var numAttributes(get, never):Int;

	public function get_numAttributes():Int {
		return _attributes.length;
	}
}
