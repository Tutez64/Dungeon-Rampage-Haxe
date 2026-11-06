package starling.text;

import flash.text.TextFormat;
import starling.events.EventDispatcher;
import starling.utils.Align;
import flash.errors.ArgumentError;

class TextFormat extends EventDispatcher {
	var _font:String;

	var _size:Float = Math.NaN;

	var _color:UInt = 0;

	var _bold:Bool = false;

	var _italic:Bool = false;

	var _underline:Bool = false;

	var _horizontalAlign:String;

	var _verticalAlign:String;

	var _kerning:Bool = false;

	var _leading:Float = Math.NaN;

	var _letterSpacing:Float = Math.NaN;

	public function new(font:String = "Verdana", size:Float = 12, color:UInt = (0 : UInt), horizontalAlign:String = "center", verticalAlign:String = "center") {
		super();
		_font = font;
		_size = size;
		_color = color;
		_horizontalAlign = horizontalAlign;
		_verticalAlign = verticalAlign;
		_kerning = true;
		_letterSpacing = _leading = 0;
	}

	public function copyFrom(format:TextFormat) {
		_font = format._font;
		_size = format._size;
		_color = format._color;
		_bold = format._bold;
		_italic = format._italic;
		_underline = format._underline;
		_horizontalAlign = format._horizontalAlign;
		_verticalAlign = format._verticalAlign;
		_kerning = format._kerning;
		_leading = format._leading;
		_letterSpacing = format._letterSpacing;
		dispatchEventWith("change");
	}

	public function clone():TextFormat {
		var _loc2_ = (ASCompat.constructorOf(this) : Dynamic);
		var _loc1_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), starling.text.TextFormat);
		_loc1_.copyFrom(this);
		return _loc1_;
	}

	public function setTo(font:String = "Verdana", size:Float = 12, color:UInt = (0 : UInt), horizontalAlign:String = "center",
			verticalAlign:String = "center") {
		_font = font;
		_size = size;
		_color = color;
		_horizontalAlign = horizontalAlign;
		_verticalAlign = verticalAlign;
		dispatchEventWith("change");
	}

	public function toNativeFormat(out:flash.text.TextFormat = null):flash.text.TextFormat {
		if (out == null) {
			out = new flash.text.TextFormat();
		}
		out.font = _font;
		out.size = ASCompat.toInt(_size);
		out.color = _color;
		out.bold = _bold;
		out.italic = _italic;
		out.underline = _underline;
		out.align = _horizontalAlign;
		out.kerning = _kerning;
		out.leading = ASCompat.toInt(_leading);
		out.letterSpacing = _letterSpacing;
		return out;
	}

	@:isVar public var font(get, set):String;

	public function get_font():String {
		return _font;
	}

	function set_font(value:String):String {
		if (value != _font) {
			_font = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var size(get, set):Float;

	public function get_size():Float {
		return _size;
	}

	function set_size(value:Float):Float {
		if (value != _size) {
			_size = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		return _color;
	}

	function set_color(value:UInt):UInt {
		if (value != _color) {
			_color = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var bold(get, set):Bool;

	public function get_bold():Bool {
		return _bold;
	}

	function set_bold(value:Bool):Bool {
		if (value != _bold) {
			_bold = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var italic(get, set):Bool;

	public function get_italic():Bool {
		return _italic;
	}

	function set_italic(value:Bool):Bool {
		if (value != _italic) {
			_italic = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var underline(get, set):Bool;

	public function get_underline():Bool {
		return _underline;
	}

	function set_underline(value:Bool):Bool {
		if (value != _underline) {
			_underline = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var horizontalAlign(get, set):String;

	public function get_horizontalAlign():String {
		return _horizontalAlign;
	}

	function set_horizontalAlign(value:String):String {
		if (!Align.isValidHorizontal(value)) {
			throw new ArgumentError("Invalid horizontal alignment");
		}
		if (value != _horizontalAlign) {
			_horizontalAlign = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var verticalAlign(get, set):String;

	public function get_verticalAlign():String {
		return _verticalAlign;
	}

	function set_verticalAlign(value:String):String {
		if (!Align.isValidVertical(value)) {
			throw new ArgumentError("Invalid vertical alignment");
		}
		if (value != _verticalAlign) {
			_verticalAlign = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var kerning(get, set):Bool;

	public function get_kerning():Bool {
		return _kerning;
	}

	function set_kerning(value:Bool):Bool {
		if (value != _kerning) {
			_kerning = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var leading(get, set):Float;

	public function get_leading():Float {
		return _leading;
	}

	function set_leading(value:Float):Float {
		if (value != _leading) {
			_leading = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var letterSpacing(get, set):Float;

	public function get_letterSpacing():Float {
		return _letterSpacing;
	}

	function set_letterSpacing(value:Float):Float {
		if (value != _letterSpacing) {
			_letterSpacing = value;
			dispatchEventWith("change");
		}
		return value;
	}
}
