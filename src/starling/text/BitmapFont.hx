package starling.text;

import flash.geom.Rectangle;
import starling.display.Image;
import starling.display.MeshBatch;
import starling.display.Sprite;
import starling.styles.DistanceFieldStyle;
import starling.styles.MeshStyle;
import starling.textures.Texture;
import starling.utils.StringUtil;
import flash.errors.ArgumentError;

class BitmapFont implements ITextCompositor {
	public static inline final NATIVE_SIZE = -1;

	public static inline final MINI = "mini";

	static inline final CHAR_MISSING = 0;

	static inline final CHAR_TAB = 9;

	static inline final CHAR_NEWLINE = 10;

	static inline final CHAR_CARRIAGE_RETURN = 13;

	static inline final CHAR_SPACE = 32;

	static var sLines:Array<ASAny>;

	static var sDefaultOptions:TextOptions = new TextOptions();

	var _texture:Texture;

	var _chars:ASDictionary<ASAny, ASAny>;

	var _name:String;

	var _size:Float = Math.NaN;

	var _lineHeight:Float = Math.NaN;

	var _baseline:Float = Math.NaN;

	var _offsetX:Float = Math.NaN;

	var _offsetY:Float = Math.NaN;

	var _padding:Float = Math.NaN;

	var _helperImage:Image;

	var _type:String;

	var _distanceFieldSpread:Float = Math.NaN;

	public function new(texture:Texture = null, fontData:ASAny = null) {
		if (texture == null && fontData == null) {
			texture = MiniBitmapFont.texture;
			fontData = MiniBitmapFont.xml;
		} else if (texture == null || fontData == null) {
			throw new ArgumentError("Set both of the \'texture\' and \'fontData\' arguments to valid objects or leave both of them null.");
		}
		_name = "unknown";
		_lineHeight = _size = _baseline = 14;
		_offsetX = _offsetY = _padding = 0;
		_texture = texture;
		_chars = new ASDictionary<ASAny, ASAny>();
		_helperImage = new Image(texture);
		_type = "standard";
		_distanceFieldSpread = 0;
		addChar(0, new BitmapChar(0, null, 0, 0, 0));
		parseFontData(fontData);
	}

	public function dispose() {
		if (_texture != null) {
			_texture.dispose();
		}
	}

	function parseFontData(data:ASAny) {
		if (Std.isOfType(data, compat.XML.typeReference())) {
			parseFontXml((data : compat.XML));
			return;
		}
		throw new ArgumentError("BitmapFont only supports XML data");
	}

	function parseFontXml(fontXml:compat.XML) {
		var _loc14_ = 0;
		var _loc4_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc15_:Rectangle = null;
		var _loc5_:Texture = null;
		var _loc8_:BitmapChar = null;
		var _loc16_ = 0;
		var _loc10_ = 0;
		var _loc3_ = Math.NaN;
		var _loc6_ = _texture.scale;
		var _loc17_ = _texture.frame;
		var _loc7_ = _loc17_ != null ? _loc17_.x : 0;
		var _loc9_ = _loc17_ != null ? _loc17_.y : 0;
		_name = StringUtil.clean(fontXml.child("info").attribute("face"));
		_size = Std.parseFloat(fontXml.child("info").attribute("size")) / _loc6_;
		_lineHeight = Std.parseFloat(fontXml.child("common").attribute("lineHeight")) / _loc6_;
		_baseline = Std.parseFloat(fontXml.child("common").attribute("base")) / _loc6_;
		if (fontXml.child("info").attribute("smooth").toString() == "0") {
			smoothing = "none";
		}
		if (_size <= 0) {
			_size = _size == 0 ? 16 : _size * -1;
		}
		if (fontXml.child("distanceField").length() != 0) {
			_distanceFieldSpread = Std.parseFloat(fontXml.child("distanceField").attribute("distanceRange"));
			_type = fontXml.child("distanceField").attribute("fieldType") == "msdf" ? "multiChannelDistanceField" : "distanceField";
		} else {
			_distanceFieldSpread = 0;
			_type = "standard";
		}
		var _loc11_:compat.XML;
		final __ax4_iter_126 = fontXml.child("chars").child("char");
		if (checkNullIteratee(__ax4_iter_126))
			for (_tmp_ in __ax4_iter_126) {
				_loc11_ = _tmp_;
				_loc14_ = ASCompat.parseInt(_loc11_.attribute("id"));
				_loc4_ = Std.parseFloat(_loc11_.attribute("xoffset")) / _loc6_;
				_loc2_ = Std.parseFloat(_loc11_.attribute("yoffset")) / _loc6_;
				_loc13_ = Std.parseFloat(_loc11_.attribute("xadvance")) / _loc6_;
				_loc15_ = new Rectangle();
				_loc15_.x = Std.parseFloat(_loc11_.attribute("x")) / _loc6_ + _loc7_;
				_loc15_.y = Std.parseFloat(_loc11_.attribute("y")) / _loc6_ + _loc9_;
				_loc15_.width = Std.parseFloat(_loc11_.attribute("width")) / _loc6_;
				_loc15_.height = Std.parseFloat(_loc11_.attribute("height")) / _loc6_;
				_loc5_ = Texture.fromTexture(_texture, _loc15_);
				_loc8_ = new BitmapChar(_loc14_, _loc5_, _loc4_, _loc2_, _loc13_);
				addChar(_loc14_, _loc8_);
			}
		var _loc12_:compat.XML;
		final __ax4_iter_127 = fontXml.child("kernings").child("kerning");
		if (checkNullIteratee(__ax4_iter_127))
			for (_tmp_ in __ax4_iter_127) {
				_loc12_ = _tmp_;
				_loc16_ = ASCompat.parseInt(_loc12_.attribute("first"));
				_loc10_ = ASCompat.parseInt(_loc12_.attribute("second"));
				_loc3_ = Std.parseFloat(_loc12_.attribute("amount")) / _loc6_;
				if (_chars.exists(_loc10_)) {
					getChar(_loc10_).addKerning(_loc16_, _loc3_);
				}
			}
	}

	public function getChar(charID:Int):BitmapChar {
		return ASCompat.coerce(ASDictionary.getInt(_chars, charID), starling.text.BitmapChar);
	}

	public function addChar(charID:Int, bitmapChar:BitmapChar) {
		_chars[charID] = bitmapChar;
	}

	public function getCharIDs(out:Vector<Int> = null):Vector<Int> {
		if (out == null) {
			out = new Vector<Int>((0 : UInt));
		}
		var _loc2_:ASAny;
		final __ax4_iter_128 = _chars;
		if (checkNullIteratee(__ax4_iter_128))
			for (_tmp_ in __ax4_iter_128.keys()) {
				_loc2_ = _tmp_;
				out[out.length] = ASCompat.toInt(_loc2_);
			}
		return out;
	}

	public function hasChars(text:String):Bool {
		var _loc2_ = 0;
		var _loc3_ = 0;
		if (text == null) {
			return true;
		}
		var _loc4_ = text.length;
		_loc3_ = 0;
		while (_loc3_ < _loc4_) {
			_loc2_ = text.charCodeAt(_loc3_);
			if (_loc2_ != 32 && _loc2_ != 9 && _loc2_ != 10 && _loc2_ != 13 && getChar(_loc2_) == null) {
				return false;
			}
			_loc3_++;
		}
		return true;
	}

	public function createSprite(width:Float, height:Float, text:String, format:TextFormat, options:TextOptions = null):Sprite {
		var _loc9_ = 0;
		var _loc10_:BitmapCharLocation = null;
		var _loc8_:Image = null;
		var _loc6_ = arrangeChars(width, height, text, format, options);
		var _loc12_ = _loc6_.length;
		var _loc11_ = this.smoothing;
		var _loc7_ = new Sprite();
		_loc9_ = 0;
		while (_loc9_ < _loc12_) {
			_loc10_ = _loc6_[_loc9_];
			_loc8_ = _loc10_.char.createImage();
			_loc8_.x = _loc10_.x;
			_loc8_.y = _loc10_.y;
			_loc8_.scale = _loc10_.scale;
			_loc8_.color = format.color;
			_loc8_.textureSmoothing = _loc11_;
			_loc7_.addChild(_loc8_);
			_loc9_++;
		}
		BitmapCharLocation.rechargePool();
		return _loc7_;
	}

	public function fillMeshBatch(meshBatch:MeshBatch, width:Float, height:Float, text:String, format:TextFormat, options:TextOptions = null) {
		var _loc8_ = 0;
		var _loc9_:BitmapCharLocation = null;
		var _loc7_ = arrangeChars(width, height, text, format, options);
		var _loc10_ = _loc7_.length;
		_helperImage.color = format.color;
		_loc8_ = 0;
		while (_loc8_ < _loc10_) {
			_loc9_ = _loc7_[_loc8_];
			_helperImage.texture = _loc9_.char.texture;
			_helperImage.readjustSize();
			_helperImage.x = _loc9_.x;
			_helperImage.y = _loc9_.y;
			_helperImage.scale = _loc9_.scale;
			meshBatch.addMeshAt(_helperImage);
			_loc8_++;
		}
		BitmapCharLocation.rechargePool();
	}

	public function clearMeshBatch(meshBatch:MeshBatch) {
		meshBatch.clear();
	}

	public function getDefaultMeshStyle(previousStyle:MeshStyle, format:TextFormat, options:TextOptions):MeshStyle {
		var _loc4_:DistanceFieldStyle = null;
		var _loc5_ = Math.NaN;
		if (_type == "standard") {
			return null;
		}
		_loc5_ = format.size < 0 ? format.size * -_size : format.size;
		_loc4_ = ASCompat.orValue(ASCompat.reinterpretAs(previousStyle, DistanceFieldStyle), new DistanceFieldStyle());
		_loc4_.multiChannel = _type == "multiChannelDistanceField";
		_loc4_.softness = _size / (_loc5_ * _distanceFieldSpread);
		return _loc4_;
	}

	public function arrangeChars(width:Float, height:Float, text:String, format:TextFormat, options:TextOptions):Vector<BitmapCharLocation> {
		var _loc39_:BitmapCharLocation = null;
		var _loc32_ = 0;
		var _loc18_ = Math.NaN;
		var _loc35_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc30_ = 0;
		var _loc28_ = 0;
		var _loc24_ = 0;
		var _loc37_ = 0;
		var _loc36_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc20_:Vector<BitmapCharLocation> = /*undefined*/ null;
		var _loc34_ = false;
		var _loc25_ = 0;
		var _loc38_:BitmapChar = null;
		var _loc33_ = 0;
		var _loc14_ = 0;
		var _loc12_:Vector<BitmapCharLocation> = /*undefined*/ null;
		var _loc22_ = 0;
		var _loc27_:BitmapCharLocation = null;
		var _loc31_ = Math.NaN;
		var _loc23_ = 0;
		if (text == null || text.length == 0) {
			return BitmapCharLocation.vectorFromPool();
		}
		if (options == null) {
			options = sDefaultOptions;
		}
		var _loc6_ = format.kerning;
		var _loc10_ = format.leading;
		var _loc19_ = format.letterSpacing;
		var _loc8_ = format.horizontalAlign;
		var _loc16_ = format.verticalAlign;
		var _loc40_ = format.size;
		var _loc17_ = options.autoScale;
		var _loc11_ = options.wordWrap;
		var _loc29_ = false;
		if (_loc40_ < 0) {
			_loc40_ *= -_size;
		}
		while (!_loc29_) {
			sLines.resize(0);
			_loc13_ = _loc40_ / _size;
			_loc18_ = (width - 2 * _padding) / _loc13_;
			_loc35_ = (height - 2 * _padding) / _loc13_;
			if (_size <= _loc35_) {
				_loc24_ = -1;
				_loc37_ = -1;
				_loc36_ = 0;
				_loc15_ = 0;
				_loc20_ = BitmapCharLocation.vectorFromPool();
				_loc32_ = text.length;
				_loc28_ = 0;
				while (_loc28_ < _loc32_) {
					_loc34_ = false;
					_loc25_ = text.charCodeAt(_loc28_);
					_loc38_ = getChar(_loc25_);
					if (_loc25_ == 10 || _loc25_ == 13) {
						_loc34_ = true;
					} else {
						if (_loc38_ == null) {
							_loc25_ = 0;
							_loc38_ = getChar(0);
						}
						if (_loc25_ == 32 || _loc25_ == 9) {
							_loc24_ = _loc28_;
						}
						if (_loc6_) {
							_loc36_ += _loc38_.getKerning(_loc37_);
						}
						_loc39_ = BitmapCharLocation.instanceFromPool(_loc38_);
						_loc39_.index = _loc28_;
						_loc39_.x = _loc36_ + _loc38_.xOffset;
						_loc39_.y = _loc15_ + _loc38_.yOffset;
						_loc20_[_loc20_.length] = _loc39_;
						_loc36_ += _loc38_.xAdvance + _loc19_;
						_loc37_ = _loc25_;
						if (_loc39_.x + _loc38_.width > _loc18_) {
							if (_loc11_) {
								if (_loc17_ && _loc24_ == -1) {
									break;
								}
								_loc33_ = _loc24_ == -1 ? 1 : _loc28_ - _loc24_;
								_loc30_ = 0;
								while (_loc30_ < _loc33_) {
									_loc20_.pop();
									_loc30_++;
								}
								if (_loc20_.length == 0) {
									break;
								}
								_loc28_ -= _loc33_;
							} else {
								if (_loc17_) {
									break;
								}
								_loc20_.pop();
								while (_loc28_ < _loc32_ - 1 && text.charCodeAt(_loc28_) != 10) {
									_loc28_++;
								}
							}
							_loc34_ = true;
						}
					}
					if (_loc28_ == _loc32_ - 1) {
						sLines[sLines.length] = _loc20_;
						_loc29_ = true;
					} else if (_loc34_) {
						sLines[sLines.length] = _loc20_;
						if (_loc24_ == _loc28_) {
							_loc20_.pop();
						}
						if (_loc15_ + _lineHeight + _loc10_ + _size > _loc35_) {
							break;
						}
						_loc20_ = BitmapCharLocation.vectorFromPool();
						_loc36_ = 0;
						_loc15_ += _lineHeight + _loc10_;
						_loc24_ = -1;
						_loc37_ = -1;
					}
					_loc28_++;
				}
			}
			if (_loc17_ && !_loc29_ && _loc40_ > 3) {
				_loc40_ -= 1;
			} else {
				_loc29_ = true;
			}
		}
		var _loc21_ = BitmapCharLocation.vectorFromPool();
		var _loc9_ = sLines.length;
		var _loc26_ = _loc15_ + _lineHeight;
		var _loc7_ = 0;
		if (_loc16_ == "bottom") {
			_loc7_ = ASCompat.floatToInt(_loc35_ - _loc26_);
		} else if (_loc16_ == "center") {
			_loc7_ = ASCompat.floatToInt((_loc35_ - _loc26_) / 2);
		}
		if (_loc7_ < 0) {
			_loc7_ = 0;
		}
		_loc14_ = 0;
		while (_loc14_ < _loc9_) {
			_loc12_ = (sLines[_loc14_] : Vector<BitmapCharLocation>);
			_loc32_ = _loc12_.length;
			if (_loc32_ != 0) {
				_loc22_ = 0;
				_loc27_ = _loc12_[_loc12_.length - 1];
				_loc31_ = _loc27_.x - _loc27_.char.xOffset + _loc27_.char.xAdvance;
				if (_loc8_ == "right") {
					_loc22_ = ASCompat.floatToInt(_loc18_ - _loc31_);
				} else if (_loc8_ == "center") {
					_loc22_ = ASCompat.floatToInt((_loc18_ - _loc31_) / 2);
				}
				_loc23_ = 0;
				while (_loc23_ < _loc32_) {
					_loc39_ = _loc12_[_loc23_];
					_loc39_.x = _loc13_ * (_loc39_.x + _loc22_ + _offsetX) + _padding;
					_loc39_.y = _loc13_ * (_loc39_.y + _loc7_ + _offsetY) + _padding;
					_loc39_.scale = _loc13_;
					if (_loc39_.char.width > 0 && _loc39_.char.height > 0) {
						_loc21_[_loc21_.length] = _loc39_;
					}
					_loc23_++;
				}
			}
			_loc14_++;
		}
		return _loc21_;
	}

	@:isVar public var name(get, set):String;

	public function get_name():String {
		return _name;
	}

	function set_name(value:String):String {
		return _name = value;
	}

	@:isVar public var size(get, set):Float;

	public function get_size():Float {
		return _size;
	}

	function set_size(value:Float):Float {
		return _size = value;
	}

	@:isVar public var type(get, set):String;

	public function get_type():String {
		return _type;
	}

	function set_type(value:String):String {
		return _type = value;
	}

	@:isVar public var distanceFieldSpread(get, set):Float;

	public function get_distanceFieldSpread():Float {
		return _distanceFieldSpread;
	}

	function set_distanceFieldSpread(value:Float):Float {
		return _distanceFieldSpread = value;
	}

	@:isVar public var lineHeight(get, set):Float;

	public function get_lineHeight():Float {
		return _lineHeight;
	}

	function set_lineHeight(value:Float):Float {
		return _lineHeight = value;
	}

	@:isVar public var smoothing(get, set):String;

	public function get_smoothing():String {
		return _helperImage.textureSmoothing;
	}

	function set_smoothing(value:String):String {
		return _helperImage.textureSmoothing = value;
	}

	@:isVar public var baseline(get, set):Float;

	public function get_baseline():Float {
		return _baseline;
	}

	function set_baseline(value:Float):Float {
		return _baseline = value;
	}

	@:isVar public var offsetX(get, set):Float;

	public function get_offsetX():Float {
		return _offsetX;
	}

	function set_offsetX(value:Float):Float {
		return _offsetX = value;
	}

	@:isVar public var offsetY(get, set):Float;

	public function get_offsetY():Float {
		return _offsetY;
	}

	function set_offsetY(value:Float):Float {
		return _offsetY = value;
	}

	@:isVar public var padding(get, set):Float;

	public function get_padding():Float {
		return _padding;
	}

	function set_padding(value:Float):Float {
		return _padding = value;
	}

	@:isVar public var texture(get, never):Texture;

	public function get_texture():Texture {
		return _texture;
	}

	static function __init__() {
		sLines = [];
	}
}
