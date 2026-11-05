package brain.starling.swfConverter;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import starling.textures.Texture;
import brain.starling.swfConverter.BakedCell;
import starling.textures.Texture;

class BakedGlyphFont {
	public static inline final LAYER_FULL = 0;

	public static inline final LAYER_FILL = 1;

	public static inline final GUTTER:Float = 2;

	static inline final GAP = 1;

	static var sNextObjectId:Int = 0;

	static final sPoint:Point = new Point();

	static final sTables:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	static final sFilterProps:ASDictionary<ASAny, ASAny> = new ASDictionary();

	static final sObjectIds:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mPages:BakedPages;

	var mKey:String;

	var mTable:GlyphTable;

	public function new() {}

	public static function build(pages:BakedPages, keyPrefix:String, model:TextField, pixelScale:Float, chars:String, layer:Int):BakedGlyphFont {
		var __finallyReturn0:BakedGlyphFont;
		pixelScale = Math.fround(pixelScale * 1000) / 1000;
		var _loc16_ = model.text;
		var _loc7_ = model.textColor;
		var _loc9_ = model.filters;
		var _loc11_ = model.autoSize;
		var _loc8_ = model.wordWrap;
		var _loc14_ = model.x;
		var _loc15_ = model.y;
		var _loc13_ = model.width;
		var _loc17_ = model.height;
		var _loc10_ = model.defaultTextFormat;
		var _loc12_ = model.length > 0 ? model.getTextFormat(0, model.length) : null;
		{
			var __finallyReturn0:BakedGlyphFont;
			try {
				if (_loc12_ != null) {
					model.defaultTextFormat = _loc12_;
				}
				model.wordWrap = false;
				model.autoSize = "left";
				{
					__finallyReturn0 = buildFrom(pages, keyPrefix, model, pixelScale, chars, layer);
					{
						model.text = _loc16_;
						if (_loc12_ != null) {
							model.setTextFormat(_loc12_);
						}
						model.textColor = _loc7_;
						model.defaultTextFormat = _loc10_;
						model.filters = cast(_loc9_);
						model.autoSize = _loc11_;
						model.wordWrap = _loc8_;
						model.x = _loc14_;
						model.y = _loc15_;
						model.width = _loc13_;
						model.height = _loc17_;
					};
					return __finallyReturn0;
				};
			} catch (__finallyError1:Dynamic) {
				{
					model.text = _loc16_;
					if (_loc12_ != null) {
						model.setTextFormat(_loc12_);
					}
					model.textColor = _loc7_;
					model.defaultTextFormat = _loc10_;
					model.filters = cast(_loc9_);
					model.autoSize = _loc11_;
					model.wordWrap = _loc8_;
					model.x = _loc14_;
					model.y = _loc15_;
					model.width = _loc13_;
					model.height = _loc17_;
				};
				throw __finallyError1;
			};
			{
				model.text = _loc16_;
				if (_loc12_ != null) {
					model.setTextFormat(_loc12_);
				}
				model.textColor = _loc7_;
				model.defaultTextFormat = _loc10_;
				model.filters = cast(_loc9_);
				model.autoSize = _loc11_;
				model.wordWrap = _loc8_;
				model.x = _loc14_;
				model.y = _loc15_;
				model.width = _loc13_;
				model.height = _loc17_;
			};
		}
		return null;
	}

	static function buildFrom(pages:BakedPages, keyPrefix:String, field:TextField, pixelScale:Float, chars:String, layer:Int):BakedGlyphFont {
		field.text = " ";
		if (layer == 1) {
			field.textColor = (16777215 : UInt);
			field.filters = cast([]);
		}
		var _loc8_ = keyPrefix + "|glyphs|" + signature(field) + "|" + layer + "|" + chars + "|" + BakedPages.scaleKey(pixelScale);
		var _loc7_:ASObject = sTables[pages];
		if (_loc7_ == null) {
			sTables[pages] = _loc7_ = {};
		}
		var _loc10_ = new BakedGlyphFont();
		_loc10_.mPages = pages;
		_loc10_.mKey = _loc8_;
		var _loc9_ = ASCompat.coerce(_loc7_[_loc8_], GlyphTable);
		if (_loc9_ != null && _loc9_.cell.alive && pages.acquire(_loc8_) == _loc9_.cell) {
			_loc10_.mTable = _loc9_;
			return _loc10_;
		}
		ASCompat.deleteProperty(_loc7_, _loc8_);
		_loc9_ = bakeTable(pages, _loc8_, field, pixelScale, chars, layer == 1);
		if (_loc9_ == null) {
			return null;
		}
		_loc7_[_loc8_] = _loc9_;
		_loc10_.mTable = _loc9_;
		return _loc10_;
	}

	static function bakeTable(pages:BakedPages, key:String, field:TextField, pixelScale:Float, chars:String, white:Bool):GlyphTable {
		var _loc26_:BakedPicture;
		var _loc19_:Int;
		var _loc10_:BakedPicture;
		var _loc20_ = 0;
		var _loc9_ = 0;
		var _loc21_:BakedPicture = null;
		var _loc22_ = 0;
		var _loc17_:BakedPicture = null;
		var _loc15_ = new GlyphTable();
		_loc15_.pixelScale = pixelScale;
		var _loc18_ = new Vector<BakedPicture>((0 : UInt));
		var _loc8_ = new Vector<Int>((0 : UInt));
		var _loc25_ = new Vector<Int>((0 : UInt));
		var _loc14_ = new Vector<Int>((0 : UInt));
		var _loc13_ = pages.pageWidth - 1;
		var _loc23_ = 0;
		var _loc24_ = 0;
		var _loc16_ = 0;
		var _loc7_ = 0;
		_loc20_ = 0;
		while (_loc20_ < chars.length) {
			_loc9_ = chars.charCodeAt(_loc20_);
			if (!(_loc9_ >= 128 || _loc8_.indexOf(_loc9_) >= 0)) {
				field.text = chars.charAt(_loc20_);
				if (white) {
					field.textColor = (16777215 : UInt);
				}
				_loc21_ = FlashBaker.bake(field, pixelScale);
				if (_loc21_ == null || _loc21_.empty && _loc9_ != 32) {
					if (checkNullIteratee(_loc18_))
						for (_tmp_ in _loc18_) {
							_loc26_ = _tmp_;
							_loc26_.dispose();
						}
					return null;
				}
				_loc22_ = _loc21_.bitmap.width;
				_loc19_ = _loc21_.bitmap.height;
				if (_loc23_ > 0 && _loc23_ + _loc22_ > _loc13_) {
					_loc23_ = 0;
					_loc24_ += _loc16_ + 1;
					_loc16_ = 0;
				}
				_loc18_.push(_loc21_);
				_loc8_.push(_loc9_);
				_loc25_.push(_loc23_);
				_loc14_.push(_loc24_);
				_loc15_.advances[_loc9_] = Math.fround(field.textWidth * pixelScale) / pixelScale;
				_loc23_ += _loc22_ + 1;
				_loc7_ = ASCompat.floatToInt(Math.max(_loc7_, _loc23_ - 1));
				_loc16_ = ASCompat.floatToInt(Math.max(_loc16_, _loc19_));
			}
			_loc20_++;
		}
		if (_loc18_.length == 0) {
			return null;
		}
		field.text = " ";
		_loc15_.spaceAdvance = Math.fround(field.textWidth * pixelScale) / pixelScale;
		var _loc12_ = new BakedPicture();
		_loc12_.bitmap = new BitmapData(ASCompat.floatToInt(Math.max(1, _loc7_)), ASCompat.floatToInt(Math.max(1, _loc24_ + _loc16_)), true, (0 : UInt));
		_loc12_.pixelScale = pixelScale;
		_loc20_ = 0;
		while (_loc20_ < _loc18_.length) {
			sPoint.setTo(_loc25_[_loc20_], _loc14_[_loc20_]);
			_loc12_.bitmap.copyPixels(_loc18_[_loc20_].bitmap, _loc18_[_loc20_].bitmap.rect, sPoint);
			_loc20_++;
		}
		var _loc11_ = pages.add(key, _loc12_, false);
		if (_loc11_ == null) {
			if (checkNullIteratee(_loc18_))
				for (_tmp_ in _loc18_) {
					_loc10_ = _tmp_;
					_loc10_.dispose();
				}
			return null;
		}
		_loc15_.cell = _loc11_;
		_loc20_ = 0;
		while (_loc20_ < _loc18_.length) {
			_loc17_ = _loc18_[_loc20_];
			_loc9_ = _loc8_[_loc20_];
			_loc15_.textures[_loc9_] = Texture.fromTexture(_loc11_.texture,
				new Rectangle(_loc25_[_loc20_] / pixelScale, _loc14_[_loc20_] / pixelScale, _loc17_.bitmap.width / pixelScale,
					_loc17_.bitmap.height / pixelScale));
			_loc15_.offsetsX[_loc9_] = -_loc17_.originX / pixelScale;
			_loc15_.offsetsY[_loc9_] = -_loc17_.originY / pixelScale;
			_loc17_.dispose();
			_loc20_++;
		}
		return _loc15_;
	}

	static function signature(field:TextField):String {
		var _loc4_:String;
		var __ax4_iter_505:Array<ASAny>;
		var _loc6_:String = null;
		var _loc7_:ASAny = /*undefined*/ null;
		var _loc3_ = field.defaultTextFormat;
		var _loc5_:Array<ASAny> = [
			_loc3_.font,
			_loc3_.size,
			_loc3_.bold,
			_loc3_.italic,
			_loc3_.underline,
			_loc3_.letterSpacing,
			_loc3_.kerning,
			_loc3_.leading,
			_loc3_.leftMargin,
			_loc3_.indent,
			_loc3_.blockIndent,
			field.textColor,
			field.embedFonts,
			field.antiAliasType,
			field.gridFitType,
			field.sharpness,
			field.thickness
		];
		var _loc2_:ASObject;
		final __ax4_iter_504 = field.filters;
		if (checkNullIteratee(__ax4_iter_504))
			for (_tmp_ in __ax4_iter_504) {
				_loc2_ = _tmp_;
				_loc6_ = ASCompat.getQualifiedClassName(_loc2_);
				_loc5_.push(_loc6_);
				__ax4_iter_505 = filterProps(_loc2_, _loc6_);
				if (checkNullIteratee(__ax4_iter_505))
					for (_tmp_ in __ax4_iter_505) {
						_loc4_ = _tmp_;
						_loc7_ = _loc2_[_loc4_];
						if (Std.isOfType(_loc7_, Array)) {
							_loc5_.push(((ASCompat.dynamicAs(_loc7_, Array) : Array<ASAny>)).join(","));
						} else if (_loc7_ != null && ASCompat.typeof(_loc7_) == "object") {
							_loc5_.push("#" + objectId(_loc7_));
						} else {
							_loc5_.push(ASCompat.toString(_loc7_));
						}
					}
			}
		return _loc5_.join(";");
	}

	static function objectId(value:ASObject):Int {
		if (!sObjectIds.exists(value)) {
			sObjectIds[value] = ++sNextObjectId;
		}
		return ASCompat.toInt(sObjectIds[value]);
	}

	static function filterProps(filter:ASObject, type:String):Array<ASAny> {
		var _loc6_:Array<ASAny> = ASCompat.coerce(sFilterProps[type], Array);
		if (_loc6_ != null) {
			return _loc6_;
		}
		_loc6_ = [];
		var _loc5_ = ASCompat.describeType(filter);
		var _loc3_:compat.XML;
		final __ax4_iter_506 = _loc5_.child("accessor");
		if (checkNullIteratee(__ax4_iter_506))
			for (_tmp_ in __ax4_iter_506) {
				_loc3_ = _tmp_;
				if (_loc3_.attribute("access") != "writeonly") {
					_loc6_.push(_loc3_.attribute("name"));
				}
			}
		var _loc4_:compat.XML;
		final __ax4_iter_507 = _loc5_.child("variable");
		if (checkNullIteratee(__ax4_iter_507))
			for (_tmp_ in __ax4_iter_507) {
				_loc4_ = _tmp_;
				_loc6_.push(_loc4_.attribute("name"));
			}
		_loc6_.sort(Reflect.compare);
		sFilterProps[type] = _loc6_;
		return _loc6_;
	}

	@:isVar public var alive(get, never):Bool;

	public function get_alive():Bool {
		return mTable != null && mTable.cell.alive;
	}

	@:isVar public var cell(get, never):BakedCell;

	public function get_cell():BakedCell {
		return mTable != null ? mTable.cell : null;
	}

	public function hasGlyph(charCode:Int):Bool {
		return mTable != null && charCode >= 0 && charCode < 128 && mTable.textures[charCode] != null;
	}

	public function advance(charCode:Int):Float {
		if (hasGlyph(charCode)) {
			return mTable.advances[charCode];
		}
		return charCode == 32 && mTable != null ? mTable.spaceAdvance : 0;
	}

	@:isVar public var pixelScale(get, never):Float;

	public function get_pixelScale():Float {
		return mTable != null ? mTable.pixelScale : 1;
	}

	public function release() {
		var _loc1_:ASObject = null;
		if (mTable == null) {
			return;
		}
		var _loc2_ = mTable.cell;
		mPages.release(_loc2_);
		if (!_loc2_.alive) {
			_loc1_ = sTables[mPages];
			if (_loc1_ != null && _loc1_[mKey] == mTable) {
				ASCompat.deleteProperty(_loc1_, mKey);
			}
		}
		mTable = null;
	}

	@:allow(brain.starling.swfConverter) function glyphTexture(charCode:Int):Texture {
		return hasGlyph(charCode) ? mTable.textures[charCode] : null;
	}

	@:allow(brain.starling.swfConverter) function glyphOffsetX(charCode:Int):Float {
		return mTable != null ? mTable.offsetsX[charCode] : 0;
	}

	@:allow(brain.starling.swfConverter) function glyphOffsetY(charCode:Int):Float {
		return mTable != null ? mTable.offsetsY[charCode] : 0;
	}
}

private class GlyphTable {
	public var cell:BakedCell;

	public var pixelScale:Float = 1;

	public var spaceAdvance:Float = 0;

	public var textures:Vector<Texture> = new Vector((128 : UInt), true);

	public var advances:Vector<Float> = new Vector((128 : UInt), true);

	public var offsetsX:Vector<Float> = new Vector((128 : UInt), true);

	public var offsetsY:Vector<Float> = new Vector((128 : UInt), true);

	public function new() {}
}
