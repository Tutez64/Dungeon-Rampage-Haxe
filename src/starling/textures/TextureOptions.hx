package starling.textures;

import starling.core.Starling;

class TextureOptions {
	var _scale:Float = Math.NaN;

	var _format:String;

	var _mipMapping:Bool = false;

	var _optimizeForRenderToTexture:Bool = false;

	var _premultipliedAlpha:Bool = false;

	var _forcePotTexture:Bool = false;

	var _onReady:ASFunction = null;

	public function new(scale:Float = 1, mipMapping:Bool = false, format:String = "bgra", premultipliedAlpha:Bool = true, forcePotTexture:Bool = false) {
		_scale = scale;
		_format = format;
		_mipMapping = mipMapping;
		_forcePotTexture = forcePotTexture;
		_premultipliedAlpha = premultipliedAlpha;
	}

	public function clone():TextureOptions {
		var _loc1_ = new TextureOptions();
		_loc1_.copyFrom(this);
		return _loc1_;
	}

	public function copyFrom(other:TextureOptions) {
		_scale = other._scale;
		_mipMapping = other._mipMapping;
		_format = other._format;
		_optimizeForRenderToTexture = other._optimizeForRenderToTexture;
		_premultipliedAlpha = other._premultipliedAlpha;
		_forcePotTexture = other._forcePotTexture;
		_onReady = other._onReady;
	}

	@:isVar public var scale(get, set):Float;

	public function get_scale():Float {
		return _scale;
	}

	function set_scale(value:Float):Float {
		_scale = value > 0 ? value : Starling.contentScaleFactor;
		return value;
	}

	@:isVar public var format(get, set):String;

	public function get_format():String {
		return _format;
	}

	function set_format(value:String):String {
		return _format = value;
	}

	@:isVar public var mipMapping(get, set):Bool;

	public function get_mipMapping():Bool {
		return _mipMapping;
	}

	function set_mipMapping(value:Bool):Bool {
		return _mipMapping = value;
	}

	@:isVar public var optimizeForRenderToTexture(get, set):Bool;

	public function get_optimizeForRenderToTexture():Bool {
		return _optimizeForRenderToTexture;
	}

	function set_optimizeForRenderToTexture(value:Bool):Bool {
		return _optimizeForRenderToTexture = value;
	}

	@:isVar public var forcePotTexture(get, set):Bool;

	public function get_forcePotTexture():Bool {
		return _forcePotTexture;
	}

	function set_forcePotTexture(value:Bool):Bool {
		return _forcePotTexture = value;
	}

	@:isVar public var onReady(get, set):ASFunction;

	public function get_onReady():ASFunction {
		return _onReady;
	}

	function set_onReady(value:ASFunction):ASFunction {
		return _onReady = value;
	}

	@:isVar public var premultipliedAlpha(get, set):Bool;

	public function get_premultipliedAlpha():Bool {
		return _premultipliedAlpha;
	}

	function set_premultipliedAlpha(value:Bool):Bool {
		return _premultipliedAlpha = value;
	}
}
