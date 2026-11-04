package starling.utils;

import flash.display3D.Context3D;
import flash.events.EventDispatcher;
import flash.system.Capabilities;
import flash.text.Font;
import starling.errors.AbstractClassError;

class SystemUtil {
	static var sInitialized:Bool = false;

	static var sApplicationActive:Bool = true;

	static var sPlatform:String;

	static var sVersion:String;

	static var sAIR:Bool = false;

	static var sEmbeddedFonts:Array<ASAny> = null;

	static var sSupportsDepthAndStencil:Bool = true;

	static var sWaitingCalls:Array<ASAny>;

	public function new() {
		throw new AbstractClassError();
	}

	public static function initialize() {
		var _loc4_:ASObject = null;
		var _loc3_:EventDispatcher = null;
		var _loc1_:compat.XML = null;
		var _loc2_:ASAny = null;
		var _loc5_:String = null;
		if (sInitialized) {
			return;
		}
		sInitialized = true;
		sPlatform = Capabilities.version.substr(0, 3);
		sVersion = Capabilities.version.substr(4);
		try {
			_loc4_ = Type.resolveClass("flash.desktop::NativeApplication");
			_loc3_ = ASCompat.dynamicAs(_loc4_["nativeApplication"], EventDispatcher);
			_loc3_.addEventListener("activate", onActivate, false, 0, true);
			_loc3_.addEventListener("deactivate", onDeactivate, false, 0, true);
			_loc1_ = ((_loc3_ : ASAny)["applicationDescriptor"] : compat.XML);
			_loc2_ = _loc1_.namespace();
			_loc5_ = _loc1_ /*_loc2_::*/ .child("initialWindow") /*_loc2_::*/
				.child("depthAndStencil")
				.toString()
				.toLowerCase();
			sSupportsDepthAndStencil = _loc5_ == "true";
			sAIR = true;
		} catch (e:Dynamic) {
			sAIR = false;
		}
	}

	static function onActivate(event:ASObject) {
		sApplicationActive = true;
		var _loc2_:Array<ASAny>;
		final __ax4_iter_371 = sWaitingCalls;
		if (checkNullIteratee(__ax4_iter_371))
			for (_tmp_ in __ax4_iter_371) {
				_loc2_ = ASCompat.coerce(_tmp_, Array);
				try {
					ASCompatMacro.applyClosure(_loc2_[0], _loc2_[1]);
				} catch (e:Dynamic) {}
			}
		sWaitingCalls = [];
	}

	static function onDeactivate(event:ASObject) {
		sApplicationActive = false;
	}

	public static function executeWhenApplicationIsActive(call:ASFunction, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		initialize();
		if (sApplicationActive) {
			ASCompatMacro.applyClosure(call, rest);
		} else {
			sWaitingCalls.push(([call, rest] : Array<ASAny>));
		}
	}

	@:isVar public static var isApplicationActive(get, never):Bool;

	static public function get_isApplicationActive():Bool {
		initialize();
		return sApplicationActive;
	}

	@:isVar public static var isAIR(get, never):Bool;

	static public function get_isAIR():Bool {
		initialize();
		return sAIR;
	}

	@:isVar public static var version(get, never):String;

	static public function get_version():String {
		initialize();
		return sVersion;
	}

	@:isVar public static var platform(get, set):String;

	static public function get_platform():String {
		initialize();
		return sPlatform;
	}

	static function set_platform(value:String):String {
		initialize();
		return sPlatform = value;
	}

	@:isVar public static var supportsDepthAndStencil(get, never):Bool;

	static public function get_supportsDepthAndStencil():Bool {
		return sSupportsDepthAndStencil;
	}

	@:isVar public static var supportsVideoTexture(get, never):Bool;

	static public function get_supportsVideoTexture():Bool {
		return ASCompat.toBool((Context3D : ASAny)["supportsVideoTexture"]);
	}

	public static function updateEmbeddedFonts() {
		sEmbeddedFonts = null;
	}

	public static function isEmbeddedFont(fontName:String, bold:Bool = false, italic:Bool = false, fontType:String = "embedded"):Bool {
		var _loc6_:String = null;
		var _loc7_ = false;
		var _loc5_ = false;
		if (sEmbeddedFonts == null) {
			sEmbeddedFonts = Font.enumerateFonts(false);
		}
		var _loc8_:Font;
		final __ax4_iter_372 = sEmbeddedFonts;
		if (checkNullIteratee(__ax4_iter_372))
			for (_tmp_ in __ax4_iter_372) {
				_loc8_ = ASCompat.coerce(_tmp_, flash.text.Font);
				_loc6_ = _loc8_.fontStyle;
				_loc7_ = _loc6_ == "bold" || _loc6_ == "boldItalic";
				_loc5_ = _loc6_ == "italic" || _loc6_ == "boldItalic";
				if (fontName == _loc8_.fontName && bold == _loc7_ && italic == _loc5_ && fontType == _loc8_.fontType) {
					return true;
				}
			}
		return false;
	}

	@:isVar public static var isIOS(get, never):Bool;

	static public function get_isIOS():Bool {
		return platform == "IOS";
	}

	@:isVar public static var isAndroid(get, never):Bool;

	static public function get_isAndroid():Bool {
		return platform == "AND";
	}

	@:isVar public static var isMac(get, never):Bool;

	static public function get_isMac():Bool {
		return platform == "MAC";
	}

	@:isVar public static var isWindows(get, never):Bool;

	static public function get_isWindows():Bool {
		return platform == "WIN";
	}

	@:isVar public static var isDesktop(get, never):Bool;

	static public function get_isDesktop():Bool {
		return platform == "WIN" || platform == "MAC" || platform == "LNX";
	}

	static function __init__() {
		sWaitingCalls = [];
	}
}
