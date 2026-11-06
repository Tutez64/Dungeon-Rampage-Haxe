package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPages;
import brain.starling.swfConverter.BakedPicture;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import starling.textures.Texture;
import brain.starling.swfConverter.BakedCell;
import starling.textures.Texture;

/*internal*/
class StarlingGlyphFont {
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

	var mTable:HudGlyphTable;

	public function new() {}

	@:allow(uI.hud.starlingConverted) static function acquire(pages:BakedPages, key:String):StarlingGlyphFont {
		var _loc3_:ASObject = sTables[pages];
		var _loc4_ = _loc3_ != null ? ASCompat.dynamicAs(_loc3_[key], HudGlyphTable) : null;
		if (_loc4_ == null || !_loc4_.mCell.alive || pages.acquire(key) != _loc4_.mCell) {
			return null;
		}
		var _loc5_ = new StarlingGlyphFont();
		_loc5_.mPages = pages;
		_loc5_.mKey = key;
		_loc5_.mTable = _loc4_;
		return _loc5_;
	}

	public static function build(pages:BakedPages, keyPrefix:String, model:TextField, pixelScale:Float, chars:String, layer:Int):StarlingGlyphFont {
		var __finallyReturn0:StarlingGlyphFont;
		pixelScale = Math.fround(pixelScale * 1000) / 1000;
		var _loc15_ = model.htmlText;
		var _loc7_ = model.textColor;
		var _loc10_ = model.filters;
		var _loc13_ = model.autoSize;
		var _loc8_ = model.wordWrap;
		var _loc11_ = model.transform.matrix;
		var _loc9_ = model.getBounds(model);
		var _loc12_ = model.defaultTextFormat;
		var _loc14_ = model.length > 0 ? model.getTextFormat(0, model.length) : model.defaultTextFormat;
		{
			var __finallyReturn0:StarlingGlyphFont;
			try {
				_loc14_.align = "left";
				model.defaultTextFormat = _loc14_;
				model.transform.matrix = new Matrix();
				model.wordWrap = false;
				model.autoSize = "left";
				{
					__finallyReturn0 = buildFrom(pages, keyPrefix, model, pixelScale, chars, layer);
					{
						model.defaultTextFormat = _loc12_;
						model.filters = cast(_loc10_);
						model.autoSize = _loc13_;
						model.wordWrap = _loc8_;
						model.htmlText = _loc15_;
						model.textColor = _loc7_;
						model.transform.matrix = new Matrix();
						model.width = _loc9_.width;
						model.height = _loc9_.height;
						model.transform.matrix = _loc11_;
					};
					return __finallyReturn0;
				};
			} catch (__finallyError1:Dynamic) {
				{
					model.defaultTextFormat = _loc12_;
					model.filters = cast(_loc10_);
					model.autoSize = _loc13_;
					model.wordWrap = _loc8_;
					model.htmlText = _loc15_;
					model.textColor = _loc7_;
					model.transform.matrix = new Matrix();
					model.width = _loc9_.width;
					model.height = _loc9_.height;
					model.transform.matrix = _loc11_;
				};
				ASCompat.rethrowKeepingStack(__finallyError1);
				throw __finallyError1;
			};
			{
				model.defaultTextFormat = _loc12_;
				model.filters = cast(_loc10_);
				model.autoSize = _loc13_;
				model.wordWrap = _loc8_;
				model.htmlText = _loc15_;
				model.textColor = _loc7_;
				model.transform.matrix = new Matrix();
				model.width = _loc9_.width;
				model.height = _loc9_.height;
				model.transform.matrix = _loc11_;
			};
		}
		return null;
	}

	static function buildFrom(pages:BakedPages, keyPrefix:String, field:TextField, pixelScale:Float, chars:String, layer:Int):StarlingGlyphFont {
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
		var _loc10_ = new StarlingGlyphFont();
		_loc10_.mPages = pages;
		_loc10_.mKey = _loc8_;
		var _loc9_ = ASCompat.dynamicAs(_loc7_[_loc8_], HudGlyphTable);
		if (_loc9_ != null && _loc9_.mCell.alive && pages.acquire(_loc8_) == _loc9_.mCell) {
			_loc10_.mTable = _loc9_;
			return _loc10_;
		}
		_loc7_[_loc8_] = false;
		try {
			_loc9_ = bakeTable(pages, _loc8_, field, pixelScale, chars, layer == 1);
		} catch (error:Dynamic) {
			ASCompat.deleteProperty(_loc7_, _loc8_);
			if (!HudArt.ready) {
				throw error;
			}
			StarlingHud.reportError(error);
			return null;
		}
		if (_loc9_ == null) {
			ASCompat.deleteProperty(_loc7_, _loc8_);
			return null;
		}
		_loc7_[_loc8_] = _loc9_;
		_loc10_.mTable = _loc9_;
		return _loc10_;
	}

	static function bakeTable(pages:BakedPages, key:String, field:TextField, pixelScale:Float, chars:String, white:Bool):HudGlyphTable {
		var __finallyReturn0:HudGlyphTable;
		var __finallyReturn1:HudGlyphTable;
		var __finallyReturn2:HudGlyphTable;
		var __finallyReturn3:HudGlyphTable;
		var __finallyReturn4:HudGlyphTable;
		var __ax4_iter_222:Vector<Texture>;
		var __finallyReturn5:HudGlyphTable;
		var _loc21_ = 0;
		var _loc9_ = 0;
		var _loc22_ = 0;
		var _loc19_ = 0;
		var _loc23_:BakedPicture = null;
		var _loc17_:BakedPicture = null;
		var _loc11_:BakedCell = null;
		var _loc12_:BakedPicture = null;
		var _loc18_:Texture = null;
		var _loc27_:BakedPicture = null;
		var _loc10_:Rectangle = null;
		var _loc15_ = new HudGlyphTable();
		_loc15_.mPixelScale = pixelScale;
		var _loc20_ = new Vector<BakedPicture>((0 : UInt));
		var _loc8_ = new Vector<Int>((0 : UInt));
		var _loc26_ = new Vector<Int>((0 : UInt));
		var _loc14_ = new Vector<Int>((0 : UInt));
		var _loc13_ = pages.pageWidth - 1;
		var _loc24_ = 0;
		var _loc25_ = 0;
		var _loc16_ = 0;
		var _loc7_ = 0;
		{
			var __finallyReturn0:HudGlyphTable;
			var __finallyReturn1:HudGlyphTable;
			var __finallyReturn2:HudGlyphTable;
			var __finallyReturn3:HudGlyphTable;
			var __finallyReturn4:HudGlyphTable;
			var __ax4_iter_222:Vector<Texture>;
			var __finallyReturn5:HudGlyphTable;
			try {
				try {
					_loc21_ = 0;
					while (true) {
						if (_loc21_ >= chars.length) {
							if (_loc20_.length == 0) {
								{
									__finallyReturn0 = null;
									{
										if (checkNullIteratee(_loc20_))
											for (_tmp_ in _loc20_) {
												_loc27_ = _tmp_;
												_loc27_.dispose();
											}
										if (_loc12_ != null) {
											_loc12_.dispose();
										}
									};
									return __finallyReturn0;
								};
							}
							field.text = " ";
							_loc15_.mSpaceAdvance = Math.fround(field.textWidth * pixelScale) / pixelScale;
							_loc12_ = new BakedPicture();
							_loc12_.bitmap = new BitmapData(ASCompat.floatToInt(Math.max(1, _loc7_)), ASCompat.floatToInt(Math.max(1, _loc25_ + _loc16_)),
								true, (0 : UInt));
							_loc12_.pixelScale = pixelScale;
							_loc21_ = 0;
							while (_loc21_ < _loc20_.length) {
								sPoint.setTo(_loc26_[_loc21_], _loc14_[_loc21_]);
								_loc12_.bitmap.copyPixels(_loc20_[_loc21_].bitmap, _loc20_[_loc21_].bitmap.rect, sPoint);
								_loc21_++;
							}
							_loc11_ = pages.add(key, _loc12_, true);
							if (_loc11_ == null) {
								{
									__finallyReturn1 = null;
									{
										if (checkNullIteratee(_loc20_))
											for (_tmp_ in _loc20_) {
												_loc27_ = _tmp_;
												_loc27_.dispose();
											}
										if (_loc12_ != null) {
											_loc12_.dispose();
										}
									};
									return __finallyReturn1;
								};
							}
							_loc15_.mCell = _loc11_;
							_loc21_ = 0;
							while (_loc21_ < _loc20_.length) {
								_loc17_ = _loc20_[_loc21_];
								_loc9_ = _loc8_[_loc21_];
								_loc15_.mTextures[_loc9_] = Texture.fromTexture(_loc11_.texture,
									new Rectangle(_loc26_[_loc21_] / pixelScale, _loc14_[_loc21_] / pixelScale, _loc17_.bitmap.width / pixelScale,
										_loc17_.bitmap.height / pixelScale));
								_loc15_.mOffsetsX[_loc9_] = -_loc17_.originX / pixelScale - _loc15_.mOriginsX[_loc9_];
								_loc15_.mOffsetsY[_loc9_] = -_loc17_.originY / pixelScale - _loc15_.mOriginsY[_loc9_];
								_loc21_++;
							}
							{
								__finallyReturn2 = _loc15_;
								{
									if (checkNullIteratee(_loc20_))
										for (_tmp_ in _loc20_) {
											_loc27_ = _tmp_;
											_loc27_.dispose();
										}
									if (_loc12_ != null) {
										_loc12_.dispose();
									}
								};
								return __finallyReturn2;
							};
						}
						_loc9_ = chars.charCodeAt(_loc21_);
						if (!(_loc9_ >= 128 || _loc8_.indexOf(_loc9_) >= 0)) {
							field.text = chars.charAt(_loc21_);
							field.setTextFormat(field.defaultTextFormat);
							if (white) {
								field.textColor = (16777215 : UInt);
							}
							_loc10_ = field.getBounds(field);
							_loc23_ = StarlingRaster.bake(field, pixelScale);
							if (_loc23_ == null) {
								{
									__finallyReturn3 = null;
									{
										if (checkNullIteratee(_loc20_))
											for (_tmp_ in _loc20_) {
												_loc27_ = _tmp_;
												_loc27_.dispose();
											}
										if (_loc12_ != null) {
											_loc12_.dispose();
										}
									};
									return __finallyReturn3;
								};
							}
							if (_loc23_.empty && _loc9_ != 32) {
								_loc23_.dispose();
								if (_loc9_ >= 48 && _loc9_ <= 57) {
									{
										__finallyReturn4 = null;
										{
											if (checkNullIteratee(_loc20_))
												for (_tmp_ in _loc20_) {
													_loc27_ = _tmp_;
													_loc27_.dispose();
												}
											if (_loc12_ != null) {
												_loc12_.dispose();
											}
										};
										return __finallyReturn4;
									};
								}
							} else {
								_loc22_ = _loc23_.bitmap.width;
								_loc19_ = _loc23_.bitmap.height;
								if (_loc24_ > 0 && _loc24_ + _loc22_ > _loc13_) {
									_loc24_ = 0;
									_loc25_ += _loc16_ + 1;
									_loc16_ = 0;
								}
								_loc20_.push(_loc23_);
								_loc8_.push(_loc9_);
								_loc26_.push(_loc24_);
								_loc14_.push(_loc25_);
								_loc15_.mOriginsX[_loc9_] = _loc10_.x;
								_loc15_.mOriginsY[_loc9_] = _loc10_.y;
								_loc15_.mAdvances[_loc9_] = Math.fround(field.textWidth * pixelScale) / pixelScale;
								_loc24_ += _loc22_ + 1;
								_loc7_ = ASCompat.floatToInt(Math.max(_loc7_, _loc24_ - 1));
								_loc16_ = ASCompat.floatToInt(Math.max(_loc16_, _loc19_));
							}
						}
						_loc21_++;
					}
				} catch (error:Dynamic) {
					__ax4_iter_222 = _loc15_.mTextures;
					if (checkNullIteratee(__ax4_iter_222))
						for (_tmp_ in __ax4_iter_222) {
							_loc18_ = _tmp_;
							if (_loc18_ != null) {
								_loc18_.dispose();
							}
						}
					if (_loc15_.mCell != null) {
						pages.release(_loc15_.mCell);
					}
					if (!HudArt.ready) {
						throw error;
					}
					StarlingHud.reportError(error);
					{
						__finallyReturn5 = null;
						{
							if (checkNullIteratee(_loc20_))
								for (_tmp_ in _loc20_) {
									_loc27_ = _tmp_;
									_loc27_.dispose();
								}
							if (_loc12_ != null) {
								_loc12_.dispose();
							}
						};
						return __finallyReturn5;
					};
				};
			} catch (__finallyError6:Dynamic) {
				{
					if (checkNullIteratee(_loc20_))
						for (_tmp_ in _loc20_) {
							_loc27_ = _tmp_;
							_loc27_.dispose();
						}
					if (_loc12_ != null) {
						_loc12_.dispose();
					}
				};
				ASCompat.rethrowKeepingStack(__finallyError6);
				throw __finallyError6;
			};
			{
				if (checkNullIteratee(_loc20_))
					for (_tmp_ in _loc20_) {
						_loc27_ = _tmp_;
						_loc27_.dispose();
					}
				if (_loc12_ != null) {
					_loc12_.dispose();
				}
			};
		}
		return null;
	}

	static function signature(field:TextField):String {
		var __ax4_iter_224:Array<ASAny>;
		var _loc2_:ASObject = null;
		var _loc4_:String = null;
		var _loc7_:String = null;
		var _loc8_:ASAny = ASCompat.UNDEFINED;
		var _loc3_ = field.defaultTextFormat;
		var _loc6_ = field.getBounds(field);
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
			_loc3_.rightMargin,
			_loc3_.indent,
			_loc3_.blockIndent,
			_loc3_.align,
			_loc6_.x,
			_loc6_.y,
			field.textColor,
			field.embedFonts,
			field.antiAliasType,
			field.gridFitType,
			field.sharpness,
			field.thickness
		];
		final __ax4_iter_223 = field.filters;
		if (checkNullIteratee(__ax4_iter_223))
			for (_tmp_ in __ax4_iter_223) {
				_loc2_ = _tmp_;
				_loc7_ = ASCompat.getQualifiedClassName(_loc2_);
				_loc5_.push(_loc7_);
				__ax4_iter_224 = filterProps(_loc2_, _loc7_);
				if (checkNullIteratee(__ax4_iter_224))
					for (_tmp_ in __ax4_iter_224) {
						_loc4_ = _tmp_;
						_loc8_ = _loc2_[_loc4_];
						if (Std.isOfType(_loc8_, Array)) {
							_loc5_.push(((ASCompat.dynamicAs(_loc8_, Array) : Array<ASAny>)).join(","));
						} else if (_loc8_ != null && ASCompat.typeof(_loc8_) == "object") {
							_loc5_.push("#" + objectId(_loc8_));
						} else {
							_loc5_.push(ASCompat.toString(_loc8_));
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
		var _loc3_:compat.XML = null;
		var _loc4_:compat.XML = null;
		var _loc6_:Array<ASAny> = ASCompat.coerce(sFilterProps[type], Array);
		if (_loc6_ != null) {
			return _loc6_;
		}
		_loc6_ = [];
		var _loc5_ = ASCompat.describeType(filter);
		final __ax4_iter_225 = _loc5_.child("accessor");
		if (checkNullIteratee(__ax4_iter_225))
			for (_tmp_ in __ax4_iter_225) {
				_loc3_ = _tmp_;
				if (_loc3_.attribute("access") != "writeonly") {
					_loc6_.push(_loc3_.attribute("name"));
				}
			}
		final __ax4_iter_226 = _loc5_.child("variable");
		if (checkNullIteratee(__ax4_iter_226))
			for (_tmp_ in __ax4_iter_226) {
				_loc4_ = _tmp_;
				_loc6_.push(_loc4_.attribute("name"));
			}
		_loc6_.sort(Reflect.compare);
		sFilterProps[type] = _loc6_;
		return _loc6_;
	}

	@:isVar public var alive(get, never):Bool;

	public function get_alive():Bool {
		return mTable != null && mTable.mCell.alive;
	}

	@:isVar public var cell(get, never):BakedCell;

	public function get_cell():BakedCell {
		return mTable != null ? mTable.mCell : null;
	}

	public function hasGlyph(charCode:Int):Bool {
		return mTable != null && charCode >= 0 && charCode < 128 && mTable.mTextures[charCode] != null;
	}

	public function advance(charCode:Int):Float {
		if (hasGlyph(charCode)) {
			return mTable.mAdvances[charCode];
		}
		return charCode == 32 && mTable != null ? mTable.mSpaceAdvance : 0;
	}

	@:isVar public var pixelScale(get, never):Float;

	public function get_pixelScale():Float {
		return mTable != null ? mTable.mPixelScale : 1;
	}

	public function release() {
		var _loc1_:ASObject = null;
		if (mTable == null) {
			return;
		}
		var _loc2_ = mTable.mCell;
		mPages.release(_loc2_);
		if (!_loc2_.alive) {
			_loc1_ = sTables[mPages];
			if (_loc1_ != null && _loc1_[mKey] == mTable) {
				ASCompat.deleteProperty(_loc1_, mKey);
			}
		}
		mTable = null;
	}

	@:allow(uI.hud.starlingConverted) function glyphTexture(charCode:Int):Texture {
		return hasGlyph(charCode) ? mTable.mTextures[charCode] : null;
	}

	@:allow(uI.hud.starlingConverted) function glyphOffsetX(charCode:Int):Float {
		return mTable != null ? mTable.mOffsetsX[charCode] : 0;
	}

	@:allow(uI.hud.starlingConverted) function glyphOffsetY(charCode:Int):Float {
		return mTable != null ? mTable.mOffsetsY[charCode] : 0;
	}
}

private class HudGlyphTable {
	public var mCell:BakedCell;

	public var mPixelScale:Float = 1;

	public var mSpaceAdvance:Float = 0;

	public var mTextures:Vector<Texture> = new Vector((128 : UInt), true);

	public var mAdvances:Vector<Float> = new Vector((128 : UInt), true);

	public var mOffsetsX:Vector<Float> = new Vector((128 : UInt), true);

	public var mOffsetsY:Vector<Float> = new Vector((128 : UInt), true);

	public var mOriginsX:Vector<Float> = new Vector((128 : UInt), true);

	public var mOriginsY:Vector<Float> = new Vector((128 : UInt), true);

	public function new() {}
}
