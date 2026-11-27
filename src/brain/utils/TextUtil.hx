package brain.utils;

import brain.logger.Logger;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.errors.ArgumentError;

class TextUtil {
	static inline final GUTTER = 4;

	public static inline final DEFAULT_MIN_FONT_SIZE = 11;

	static var sMinFontSize:Int = 11;

	static var sFeatureFlags:FeatureFlags;

	static inline final CAP_RATIO:Float = 0.667;

	static inline final DEFAULT_LOWERCASE_RATIO:Float = 0.47;

	static inline final OVERHANG_SPACE = " ";

	static var LOWERCASE_RATIOS:ASObject;

	public function new() {}

	@:isVar public static var featureFlags(never, set):FeatureFlags;

	static public function set_featureFlags(value:FeatureFlags):FeatureFlags {
		return sFeatureFlags = value;
	}

	@:isVar public static var enabled(get, never):Bool;

	static public function get_enabled():Bool {
		return sFeatureFlags == null || sFeatureFlags.getFlagValue("auto-size-text");
	}

	@:isVar public static var minFontSize(get, set):Int;

	static public function get_minFontSize():Int {
		return sMinFontSize;
	}

	static function set_minFontSize(value:Int):Int {
		return sMinFontSize = value;
	}

	public static function fitToField(textField:TextField, sizeModifier:Float = 1) {
		requirePositive(sizeModifier);
		if (!enabled || textField == null || textField.text == "") {
			return;
		}
		var _loc6_ = floorFor(sizeModifier);
		var _loc3_ = textField.getTextFormat();
		if (_loc3_ == null || _loc3_.size == null) {
			return;
		}
		var _loc7_ = ASCompat.toInt(_loc3_.size);
		var _loc4_ = Math.abs(textField.scaleX);
		if (_loc4_ == 0) {
			return;
		}
		var _loc8_ = textField.width / _loc4_ - 4;
		if (_loc7_ < _loc6_) {
			_loc7_ = _loc6_;
			_loc3_.size = _loc7_;
			textField.setTextFormat(_loc3_);
		}
		var _loc5_ = !textField.wordWrap;
		while (_loc7_ > _loc6_ && (_loc5_ && textField.textWidth > _loc8_ || textField.bottomScrollV < textField.numLines)) {
			_loc7_--;
			_loc3_.size = _loc7_;
			textField.setTextFormat(_loc3_);
		}
	}

	public static function scaleToFloor(authoredSize:Float, sizeModifier:Float = 1):Float {
		requirePositive(sizeModifier);
		if (!enabled || authoredSize <= 0) {
			return 1;
		}
		return Math.max(1, floorFor(sizeModifier) / authoredSize);
	}

	public static function modifierForSize(pointSize:Float):Float {
		return pointSize / sMinFontSize;
	}

	static function floorFor(sizeModifier:Float):Int {
		return ASCompat.floatToInt(Math.max(1, Math.fround(sMinFontSize * sizeModifier)));
	}

	static function requirePositive(sizeModifier:Float) {
		if (sizeModifier <= 0) {
			throw new ArgumentError("sizeModifier must be a positive number, got " + sizeModifier);
		}
	}

	public static function traceScaleChain(textField:TextField, tag:String) {
		var _loc3_:DisplayObject = null;
		if (textField == null) {
			return;
		}
		var _loc4_ = "";
		_loc3_ = textField;
		while (_loc3_ != null) {
			_loc4_ = _loc3_.name + "(" + ASCompat.toFixed(_loc3_.scaleX, (3 : UInt)) + ")" + (_loc4_ == "" ? "" : " > ") + _loc4_;
			_loc3_ = _loc3_.parent;
		}
		var _loc5_ = textField.transform.concatenatedMatrix.a;
		var _loc7_ = textField.getTextFormat();
		var _loc6_ = _loc7_ != null && _loc7_.size != null ? ASCompat.toNumber(_loc7_.size) : Math.NaN;
		Logger.debugch("font",
			tag
			+ ": "
			+ _loc4_
			+ " | concatenated "
			+ ASCompat.toFixed(_loc5_, (3 : UInt))
			+ " | "
			+ _loc6_
			+ "pt = "
			+ ASCompat.toFixed((_loc6_ * _loc5_), (1 : UInt))
			+ "px em"
			+ " | onStage "
			+ (textField.stage != null));
	}

	public static function glyphHeightPx(textField:TextField, useLowercase:Bool = false):Float {
		if (textField == null || textField.stage == null) {
			return Math.NaN;
		}
		var _loc4_ = textField.getTextFormat();
		if (_loc4_ == null) {
			return Math.NaN;
		}
		var _loc3_:ASObject = _loc4_.size ?? textField.defaultTextFormat.size;
		if (_loc3_ == null) {
			return Math.NaN;
		}
		var _loc7_ = textField.transform.concatenatedMatrix;
		var _loc5_ = Math.sqrt(_loc7_.c * _loc7_.c + _loc7_.d * _loc7_.d);
		var _loc6_ = textField.text;
		var _loc8_:Float = 0.667;
		if (useLowercase && _loc6_ != _loc6_.toUpperCase()) {
			if (_loc4_.font != null && LOWERCASE_RATIOS.hasOwnProperty(_loc4_.font)) {
				_loc8_ = ASCompat.toNumber(LOWERCASE_RATIOS[_loc4_.font]);
			} else {
				_loc8_ = 0.47;
			}
		}
		return ASCompat.toNumber(_loc3_) * _loc5_ * _loc8_;
	}

	public static function setText(textField:TextField, text:String, sizeModifier:Float = 1) {
		textField.text = text;
		fitToField(textField, sizeModifier);
	}

	public static function addOverhangSlack(textField:TextField) {
		var _loc3_:TextFormat = null;
		if (textField == null || textField.embedFonts) {
			return;
		}
		var _loc4_ = textField.length;
		if (_loc4_ == 0 || textField.text.charAt(_loc4_ - 1) == " ") {
			return;
		}
		var _loc2_ = textField.textWidth;
		textField.replaceText(_loc4_, _loc4_, " ");
		if (textField.autoSize == "center" || textField.getTextFormat(0, 1).align == "center") {
			_loc3_ = new TextFormat();
			_loc3_.indent = ASCompat.toInt(ASCompat.toNumber(textField.defaultTextFormat.indent) + textField.textWidth - _loc2_);
			textField.setTextFormat(_loc3_, 0, textField.length);
		}
	}

	static function __init__() {
		LOWERCASE_RATIOS = {
			"Futura Bold": 0.458,
			"Futura": 0.458
		};
	}
}
