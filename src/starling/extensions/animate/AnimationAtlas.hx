package starling.extensions.animate;

import starling.display.Image;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import flash.errors.ArgumentError;

class AnimationAtlas {
	public static inline final ASSET_TYPE = "animationAtlas";

	static var STD_MATRIX3D_DATA:ASObject;

	static var JsonKeys:ASObject;

	var _atlas:TextureAtlas;

	var _symbolData:ASDictionary<ASAny, ASAny>;

	var _sourceWidth:Float = 0;

	var _sourceHeight:Float = 0;

	var _symbolPool:ASDictionary<ASAny, ASAny>;

	var _imagePool:Array<ASAny>;

	var _frameRate:Float = Math.NaN;

	var _defaultSymbolName:String;

	var _labelSymbols:ASDictionary<ASAny, ASAny>;

	var _labelTables:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new(data:ASObject, atlas:TextureAtlas) {
		if (data == null) {
			throw new ArgumentError("data must not be null");
		}
		if (atlas == null) {
			throw new ArgumentError("atlas must not be null");
		}
		data = normalizeJsonKeys(data);
		parseData(data);
		_atlas = atlas;
		_symbolPool = new ASDictionary<ASAny, ASAny>();
		_imagePool = [];
	}

	static function preprocessSymbolData(symbolData:ASObject):ASObject {
		var _loc5_ = 0;
		var _loc12_:ASObject = null;
		var _loc2_:Array<ASAny> = null;
		var _loc8_ = 0;
		var _loc4_ = 0;
		var _loc11_:Array<ASAny> = null;
		var _loc6_ = 0;
		var _loc3_ = 0;
		var _loc13_:ASObject = null;
		var _loc10_:ASObject = symbolData.timeline;
		var _loc9_:Array<ASAny> = ASCompat.coerce(_loc10_.layers, Array);
		if (!ASCompat.toBool(_loc10_.sortedForRender)) {
			ASCompat.setProperty(_loc10_, "sortedForRender", true);
			ASCompat.ASArray.reverse(_loc9_);
		}
		var _loc7_ = _loc9_.length;
		_loc5_ = 0;
		while (_loc5_ < _loc7_) {
			_loc12_ = _loc9_[_loc5_];
			_loc2_ = ASCompat.dynamicAs(_loc12_.frames, Array);
			_loc8_ = _loc2_.length;
			_loc4_ = 0;
			while (_loc4_ < _loc8_) {
				_loc11_ = ASCompat.dynamicAs(_loc2_[_loc4_].elements, Array);
				_loc6_ = _loc11_.length;
				_loc3_ = 0;
				while (_loc3_ < _loc6_) {
					_loc13_ = _loc11_[_loc3_];
					if (_loc13_ == null || !_loc13_.hasOwnProperty("atlasSpriteInstance") && !_loc13_.hasOwnProperty("symbolInstance")) {
						_loc11_.splice(_loc3_, (1 : UInt));
						_loc3_--;
						_loc6_--;
					} else {
						if (_loc13_.hasOwnProperty("atlasSpriteInstance")) {
							_loc13_ = _loc11_[_loc3_] = {
								"symbolInstance": {
									"symbolName": "___atlas_sprite___",
									"instanceName": "InstName",
									"bitmap": _loc13_.atlasSpriteInstance,
									"symbolType": "graphic",
									"firstFrame": 0,
									"loop": "loop",
									"transformationPoint": {
										"x": 0,
										"y": 0
									},
									"matrix3D": if (ASCompat.toBool(_loc13_.atlasSpriteInstance.matrix3D)) _loc13_.atlasSpriteInstance.matrix3D else
										STD_MATRIX3D_DATA
								}
							};
						}
						if (_loc13_.symbolInstance.hasOwnProperty("decomposedMatrix")) {
							ASCompat.deleteProperty(_loc13_.symbolInstance, "decomposedMatrix");
						}
					}
					_loc3_++;
				}
				_loc4_++;
			}
			_loc5_++;
		}
		return symbolData;
	}

	static function normalizeJsonKeys(data:ASObject):ASObject {
		var _loc3_:Array<ASAny> = null;
		var _loc2_ = (0 : UInt);
		var _loc4_ = 0;
		var _loc7_:ASObject = null;
		var _loc5_:ASObject = null;
		if (Std.isOfType(data, String) || Std.isOfType(data, Float) || Std.isOfType(data, Int)) {
			return data;
		}
		if (Std.isOfType(data, Array)) {
			_loc3_ = [];
			_loc2_ = (ASCompat.toInt(data.length) : UInt);
			_loc4_ = 0;
			while ((_loc4_ : UInt) < _loc2_) {
				_loc3_[_loc4_] = normalizeJsonKeys(data[Std.string(_loc4_)]);
				_loc4_++;
			}
			return _loc3_;
		}
		_loc7_ = {};
		var _loc6_:String;
		if (checkNullIteratee(data))
			for (_tmp_ in data.___keys()) {
				_loc6_ = _tmp_;
				_loc5_ = normalizeJsonKeys(data[_loc6_]);
				if (JsonKeys.hasOwnProperty(_loc6_)) {
					_loc6_ = JsonKeys[_loc6_];
				}
				_loc7_[_loc6_] = _loc5_;
			}
		return _loc7_;
	}

	public function hasAnimation(name:String):Bool {
		return hasSymbol(name);
	}

	public function createAnimation(name:String = null):Animation {
		if (!ASCompat.stringAsBool(name)) {
			name = _defaultSymbolName;
		}
		if (!hasSymbol(name)) {
			throw new ArgumentError("Animation not found: " + name);
		}
		return new Animation(name, this);
	}

	public function getLabelSymbolName(label:String):String {
		return ASCompat.asString(_labelSymbols[label]);
	}

	public function getClipLabels(out:Vector<String>):Vector<String> {
		if (out == null) {
			out = new Vector<String>();
		}
		var _loc2_:String;
		final __ax4_iter_512 = _labelSymbols;
		if (checkNullIteratee(__ax4_iter_512))
			for (_tmp_ in __ax4_iter_512.keys()) {
				_loc2_ = _tmp_;
				out[out.length] = _loc2_;
			}
		return out;
	}

	@:isVar public var hasClipLabels(get, never):Bool;

	public function get_hasClipLabels():Bool {
		var _loc3_ = 0;
		var _loc2_ = _labelSymbols;
		var _loc1_:String;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_.keys()) {
				_loc1_ = _tmp_;
				return true;
			}
		return false;
	}

	public function getAnimationNames(prefix:String = "", out:Vector<String> = null):Vector<String> {
		if (out == null) {
			out = new Vector<String>();
		}
		var _loc3_:String;
		final __ax4_iter_513 = _symbolData;
		if (checkNullIteratee(__ax4_iter_513))
			for (_tmp_ in __ax4_iter_513.keys()) {
				_loc3_ = _tmp_;
				if (_loc3_ != "___atlas_sprite___" && _loc3_.indexOf(prefix) == 0) {
					out[out.length] = _loc3_;
				}
			}
		ASCompat.ASVector.sortWithOptions(out, 1);
		return out;
	}

	@:allow(starling.extensions.animate) function getTexture(name:String):Texture {
		return _atlas.getTexture(name);
	}

	@:allow(starling.extensions.animate) function getImage(texture:Texture):Image {
		var _loc2_:Image = null;
		if (_imagePool.length == 0) {
			return new Image(texture);
		}
		_loc2_ = ASCompat.dynamicAs(_imagePool.pop(), Image);
		_loc2_.x = _loc2_.y = 0;
		_loc2_.pivotX = _loc2_.pivotY = 0;
		_loc2_.scaleX = _loc2_.scaleY = 1;
		_loc2_.skewX = _loc2_.skewY = 0;
		_loc2_.rotation = 0;
		_loc2_.texture = texture;
		_loc2_.readjustSize();
		return _loc2_;
	}

	@:allow(starling.extensions.animate) function putImage(image:Image) {
		if (Std.isOfType(image.style, ColorTransformStyle)) {
			image.setStyle();
		}
		_imagePool[_imagePool.length] = image;
	}

	@:allow(starling.extensions.animate) function hasSymbol(name:String):Bool {
		return _symbolData.exists(name);
	}

	@:allow(starling.extensions.animate) function getFallbackSymbolName(name:String):String {
		if (name == null || hasSymbol(name)) {
			return null;
		}
		var _loc4_ = name.indexOf("/");
		if (_loc4_ < 0) {
			return null;
		}
		var _loc3_ = name.substr(0, _loc4_ + 1);
		var _loc2_:String = null;
		var _loc5_:String;
		final __ax4_iter_514 = _symbolData;
		if (checkNullIteratee(__ax4_iter_514))
			for (_tmp_ in __ax4_iter_514.keys()) {
				_loc5_ = _tmp_;
				if (_loc5_ != "___atlas_sprite___") {
					if (_loc5_.indexOf(_loc3_) == 0 && _loc5_.length >= 4 && _loc5_.indexOf(".png", _loc5_.length - 4) != -1) {
						if (_loc2_ != null) {
							return null;
						}
						_loc2_ = _loc5_;
					}
				}
			}
		return _loc2_;
	}

	@:allow(starling.extensions.animate) function getSymbol(name:String):Symbol {
		var _loc2_ = getSymbolPool(name);
		if (_loc2_.length == 0) {
			return new Symbol(getSymbolData(name), this);
		}
		return ASCompat.coerce(_loc2_.pop(), starling.extensions.animate.Symbol);
	}

	@:allow(starling.extensions.animate) function putSymbol(symbol:Symbol) {
		symbol.releaseLayers();
		symbol.reset();
		var _loc2_ = getSymbolPool(symbol.symbolName);
		_loc2_[_loc2_.length] = symbol;
	}

	@:allow(starling.extensions.animate) function getSymbolData(name:String):ASObject {
		return _symbolData[name];
	}

	@:allow(starling.extensions.animate) function getLabelTable(data:ASObject):LabelTable {
		var _loc2_ = ASCompat.dynamicAs(_labelTables[data], LabelTable);
		if (_loc2_ == null) {
			_loc2_ = ASCompat.coerce(_labelTables[data] = new LabelTable(data), starling.extensions.animate.LabelTable);
		}
		return _loc2_;
	}

	function parseData(data:ASObject) {
		var _loc3_:ASObject;
		var __ax4_iter_517:ASAny;
		var _loc5_:Array<ASAny> = null;
		var _loc6_:String = null;
		var _loc2_:ASObject = data.metadata;
		if (ASCompat.toBool(_loc2_)) {
			if (ASCompat.toBool(_loc2_.W)) {
				_sourceWidth = ASCompat.toNumber(_loc2_.W);
			}
			if (ASCompat.toBool(_loc2_.H)) {
				_sourceHeight = ASCompat.toNumber(_loc2_.H);
			}
			if (ASCompat.toNumberField(_loc2_, "frameRate") > 0) {
				_frameRate = ASCompat.toInt(_loc2_.frameRate);
			} else {
				_frameRate = 24;
			}
		} else {
			_frameRate = 24;
		}
		_symbolData = new ASDictionary<ASAny, ASAny>();
		var _loc4_:ASObject;
		final __ax4_iter_515:ASAny = data.symbolDictionary.symbols;
		if (checkNullIteratee(__ax4_iter_515))
			for (_tmp_ in __ax4_iter_515) {
				_loc4_ = _tmp_;
				_symbolData[_loc4_.symbolName] = preprocessSymbolData(_loc4_);
			}
		var _loc8_:ASObject = preprocessSymbolData(data.animation);
		_defaultSymbolName = _loc8_.symbolName;
		_symbolData[_defaultSymbolName] = _loc8_;
		_symbolData["___atlas_sprite___"] = {
			"symbolName": "___atlas_sprite___",
			"timeline": {"layers": []}
		};
		_labelSymbols = new ASDictionary<ASAny, ASAny>();
		var _loc7_:ASObject;
		final __ax4_iter_516:ASAny = _loc8_.timeline.layers;
		if (checkNullIteratee(__ax4_iter_516))
			for (_tmp_ in __ax4_iter_516) {
				_loc7_ = _tmp_;
				__ax4_iter_517 = _loc7_.frames;
				if (checkNullIteratee(__ax4_iter_517))
					for (_tmp_ in __ax4_iter_517) {
						_loc3_ = _tmp_;
						if (!(!_loc3_.hasOwnProperty("name") || _labelSymbols.exists(_loc3_.name))) {
							_loc5_ = ASCompat.dynamicAs(_loc3_.elements, Array);
							if (!(_loc5_ == null || _loc5_.length != 1)) {
								_loc6_ = _loc5_[0].symbolInstance.symbolName;
								if (_loc6_ != "___atlas_sprite___" && _loc6_ != _defaultSymbolName && hasSymbol(_loc6_)) {
									_labelSymbols[_loc3_.name] = _loc6_;
								}
							}
						}
					}
			}
	}

	function getSymbolPool(name:String):Array<ASAny> {
		var _loc2_:Array<ASAny> = ASCompat.coerce(_symbolPool[name], Array);
		if (_loc2_ == null) {
			_loc2_ = ASCompat.coerce(_symbolPool[name] = [], Array);
		}
		return _loc2_;
	}

	@:isVar public var frameRate(get, set):Float;

	public function get_frameRate():Float {
		return _frameRate;
	}

	function set_frameRate(value:Float):Float {
		return _frameRate = value;
	}

	@:isVar public var sourceWidth(get, never):Float;

	public function get_sourceWidth():Float {
		return _sourceWidth;
	}

	@:isVar public var sourceHeight(get, never):Float;

	public function get_sourceHeight():Float {
		return _sourceHeight;
	}

	static function __init__() {
		STD_MATRIX3D_DATA = {
			"m00": 1,
			"m01": 0,
			"m02": 0,
			"m03": 0,
			"m10": 0,
			"m11": 1,
			"m12": 0,
			"m13": 0,
			"m20": 0,
			"m21": 0,
			"m22": 1,
			"m23": 0,
			"m30": 0,
			"m31": 0,
			"m32": 0,
			"m33": 1
		};
		JsonKeys = {
			"ANIMATION": "animation",
			"ATLAS_SPRITE_instance": "atlasSpriteInstance",
			"DecomposedMatrix": "decomposedMatrix",
			"Frames": "frames",
			"framerate": "frameRate",
			"Instance_Name": "instanceName",
			"Layer_name": "layerName",
			"LAYERS": "layers",
			"Matrix": "matrix3D",
			"Matrix3D": "matrix3D",
			"Position": "position",
			"Rotation": "rotation",
			"Scaling": "scaling",
			"SYMBOL_DICTIONARY": "symbolDictionary",
			"SYMBOL_Instance": "symbolInstance",
			"SYMBOL_name": "symbolName",
			"Symbols": "symbols",
			"TIMELINE": "timeline",
			"AN": "animation",
			"AM": "alphaMultiplier",
			"ASI": "atlasSpriteInstance",
			"B": "blend",
			"BM": "bitmap",
			"C": "color",
			"DU": "duration",
			"E": "elements",
			"FF": "firstFrame",
			"FR": "frames",
			"FRT": "frameRate",
			"I": "index",
			"IN": "instanceName",
			"L": "layers",
			"LN": "layerName",
			"LP": "loop",
			"M3D": "matrix3D",
			"MX": "matrix3D",
			"MD": "metadata",
			"M": "mode",
			"N": "name",
			"POS": "position",
			"S": "symbols",
			"SD": "symbolDictionary",
			"SI": "symbolInstance",
			"SN": "symbolName",
			"ST": "symbolType",
			"TL": "timeline",
			"TRP": "transformationPoint",
			"A": "angle",
			"AO": "alphaOffset",
			"BLX": "blurX",
			"BLY": "blurY",
			"BO": "blueOffset",
			"BRT": "brightness",
			"CT": "contrast",
			"D": "distance",
			"F": "filters",
			"GM": "greenMultiplier",
			"GO": "greenOffset",
			"HO": "hideObject",
			"KK": "knockout",
			"Q": "quality",
			"RM": "redMultiplier",
			"RO": "redOffset",
			"SAT": "saturation",
			"STR": "strength",
			"TC": "tintColor",
			"TM": "tintMultiplier"
		};
	}
}
