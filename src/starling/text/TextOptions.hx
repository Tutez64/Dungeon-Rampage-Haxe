package starling.text;

import flash.text.StyleSheet;
import starling.core.Starling;
import starling.events.EventDispatcher;

class TextOptions extends EventDispatcher {
	var _wordWrap:Bool = false;

	var _autoScale:Bool = false;

	var _autoSize:String;

	var _isHtmlText:Bool = false;

	var _textureScale:Float = Math.NaN;

	var _textureFormat:String;

	var _styleSheet:StyleSheet;

	var _padding:Float = Math.NaN;

	public function new(wordWrap:Bool = true, autoScale:Bool = false) {
		super();
		_wordWrap = wordWrap;
		_autoScale = autoScale;
		_autoSize = "none";
		_textureScale = Starling.contentScaleFactor;
		_textureFormat = TextField.defaultTextureFormat;
		_isHtmlText = false;
		_padding = 0;
	}

	public function copyFrom(options:TextOptions) {
		_wordWrap = options._wordWrap;
		_autoScale = options._autoScale;
		_autoSize = options._autoSize;
		_isHtmlText = options._isHtmlText;
		_textureScale = options._textureScale;
		_textureFormat = options._textureFormat;
		_styleSheet = options._styleSheet;
		_padding = options._padding;
		dispatchEventWith("change");
	}

	public function clone():TextOptions {
		var _loc2_ = (ASCompat.constructorOf(this) : Dynamic);
		var _loc1_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), TextOptions);
		_loc1_.copyFrom(this);
		return _loc1_;
	}

	@:isVar public var wordWrap(get, set):Bool;

	public function get_wordWrap():Bool {
		return _wordWrap;
	}

	function set_wordWrap(value:Bool):Bool {
		if (_wordWrap != value) {
			_wordWrap = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var autoSize(get, set):String;

	public function get_autoSize():String {
		return _autoSize;
	}

	function set_autoSize(value:String):String {
		if (_autoSize != value) {
			_autoSize = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var autoScale(get, set):Bool;

	public function get_autoScale():Bool {
		return _autoScale;
	}

	function set_autoScale(value:Bool):Bool {
		if (_autoScale != value) {
			_autoScale = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var isHtmlText(get, set):Bool;

	public function get_isHtmlText():Bool {
		return _isHtmlText;
	}

	function set_isHtmlText(value:Bool):Bool {
		if (_isHtmlText != value) {
			_isHtmlText = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var styleSheet(get, set):StyleSheet;

	public function get_styleSheet():StyleSheet {
		return _styleSheet;
	}

	function set_styleSheet(value:StyleSheet):StyleSheet {
		_styleSheet = value;
		dispatchEventWith("change");
		return value;
	}

	@:isVar public var textureScale(get, set):Float;

	public function get_textureScale():Float {
		return _textureScale;
	}

	function set_textureScale(value:Float):Float {
		return _textureScale = value;
	}

	@:isVar public var textureFormat(get, set):String;

	public function get_textureFormat():String {
		return _textureFormat;
	}

	function set_textureFormat(value:String):String {
		if (_textureFormat != value) {
			_textureFormat = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var padding(get, set):Float;

	public function get_padding():Float {
		return _padding;
	}

	function set_padding(value:Float):Float {
		if (value < 0) {
			value = 0;
		}
		if (_padding != value) {
			_padding = value;
			dispatchEventWith("change");
		}
		return value;
	}
}
