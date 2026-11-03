package brain.starling.swfConverter;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

class FlashBaker {
	public static inline final MAX_SIDE = 2048;

	public static inline final BORDER = 1;

	static final sMatrix:Matrix = new Matrix();

	static final sPoint:Point = new Point();

	static final sProbe:BitmapData = new BitmapData(4, 4, true, (0 : UInt));

	static final sProbeRect:Rectangle = new Rectangle(0, 0, 4, 4);

	public function new() {}

	public static function bake(source:DisplayObject, pixelScale:Float, hide:Vector<DisplayObject> = null, ownFilters:Bool = true, shrinkToFit:Bool = false,
			rethrow:Bool = false):BakedPicture {
		var _loc8_:DisplayObject;
		var _loc10_:DisplayObject;
		var _loc7_:BakedPicture = null;
		var _loc9_:Vector<DisplayObject> = null;
		var _loc11_ = !source.visible;
		{
			var _loc8_:DisplayObject;
			var _loc10_:DisplayObject;
			try {
				try {
					if (hide != null) {
						_loc9_ = new Vector<DisplayObject>((0 : UInt));
						if (checkNullIteratee(hide))
							for (_tmp_ in hide) {
								_loc8_ = _tmp_;
								if (_loc8_ != null && _loc8_.visible) {
									_loc8_.visible = false;
									_loc9_.push(_loc8_);
								}
							}
					}
					if (_loc11_) {
						source.visible = true;
					}
					_loc7_ = draw(source, pixelScale, ownFilters, shrinkToFit);
				} catch (error:Dynamic) {
					if (rethrow) {
						throw error;
					}
					_loc7_ = null;
				};
			} catch (__finallyError82:Dynamic) {
				{
					if (_loc11_) {
						source.visible = false;
					}
					if (_loc9_ != null) {
						if (checkNullIteratee(_loc9_))
							for (_tmp_ in _loc9_) {
								_loc10_ = _tmp_;
								_loc10_.visible = true;
							}
					}
				};
				throw __finallyError82;
			};
			{
				if (_loc11_) {
					source.visible = false;
				}
				if (_loc9_ != null) {
					if (checkNullIteratee(_loc9_))
						for (_tmp_ in _loc9_) {
							_loc10_ = _tmp_;
							_loc10_.visible = true;
						}
				}
			};
		}
		return _loc7_;
	}

	static function draw(source:DisplayObject, scale:Float, ownFilters:Bool, shrinkToFit:Bool):BakedPicture {
		var _loc8_ = 0;
		var _loc7_ = 0;
		var _loc10_ = 0;
		var _loc12_ = 0;
		var _loc5_ = 0;
		var _loc11_ = 0;
		if (scale <= 0 || !Math.isFinite(scale)) {
			return null;
		}
		var _loc9_ = new Rectangle();
		visibleBounds(source, source, _loc9_, true);
		if (_loc9_.width <= 0 || _loc9_.height <= 0) {
			return emptyBake(scale);
		}
		_loc11_ = 0;
		while (true) {
			_loc5_ = ASCompat.floatToInt(1 + 2 + Math.fceil(nestedPadding(source, !ownFilters) * Math.max(1, scale)));
			_loc8_ = ASCompat.floatToInt(Math.ffloor(_loc9_.left * scale) - _loc5_);
			_loc7_ = ASCompat.floatToInt(Math.ffloor(_loc9_.top * scale) - _loc5_);
			_loc10_ = ASCompat.floatToInt(Math.fceil(_loc9_.right * scale) + _loc5_ - _loc8_);
			_loc12_ = ASCompat.floatToInt(Math.fceil(_loc9_.bottom * scale) + _loc5_ - _loc7_);
			if (!shrinkToFit || _loc10_ <= 2048 && _loc12_ <= 2048 || _loc11_ >= 8) {
				break;
			}
			scale *= (2048 - 4) / Math.max(_loc10_, _loc12_);
			_loc11_++;
		}
		if (_loc10_ > 2048 || _loc12_ > 2048) {
			return null;
		}
		var _loc6_ = new BitmapData(_loc10_, _loc12_, true, (0 : UInt));
		try {
			return drawOnto(_loc6_, source, scale, ownFilters, _loc8_, _loc7_);
		} catch (error:Dynamic) {
			_loc6_.dispose();
			throw error;
		}
		return null;
	}

	static function drawOnto(canvas:BitmapData, source:DisplayObject, scale:Float, ownFilters:Bool, left:Int, top:Int):BakedPicture {
		sMatrix.setTo(scale, 0, 0, scale, -left, -top);
		var _loc7_:Array<ASAny> = ASCompat.coerce(ownFilters ? null : source.filters, Array);
		if (_loc7_ != null && _loc7_.length > 0) {
			source.filters = cast([]);
		}
		{
			try {
				canvas.draw(source, sMatrix, null, null, null, true);
			} catch (__finallyError83:Dynamic) {
				{
					if (_loc7_ != null && _loc7_.length > 0) {
						source.filters = cast(_loc7_);
					}
				};
				throw __finallyError83;
			};
			{
				if (_loc7_ != null && _loc7_.length > 0) {
					source.filters = cast(_loc7_);
				}
			};
		}
		var _loc9_ = canvas.getColorBoundsRect((ASCompat.floatToInt(4278190080) : UInt), (0 : UInt), false);
		if (_loc9_.width <= 0 || _loc9_.height <= 0) {
			canvas.dispose();
			return emptyBake(scale);
		}
		var _loc8_ = new BakedPicture();
		_loc8_.bitmap = new BitmapData(ASCompat.floatToInt(_loc9_.width + 1 * 2), ASCompat.floatToInt(_loc9_.height + 1 * 2), true, (0 : UInt));
		sPoint.setTo(1, 1);
		_loc8_.bitmap.copyPixels(canvas, _loc9_, sPoint);
		canvas.dispose();
		_loc8_.originX = ASCompat.floatToInt(-left - _loc9_.x + 1);
		_loc8_.originY = ASCompat.floatToInt(-top - _loc9_.y + 1);
		_loc8_.pixelScale = scale;
		return _loc8_;
	}

	static function visibleBounds(node:DisplayObject, space:DisplayObject, out:Rectangle, isRoot:Bool) {
		var _loc7_ = 0;
		var _loc10_:DisplayObject = null;
		var _loc9_ = false;
		if (!isRoot && !node.visible) {
			return;
		}
		var _loc5_ = ASCompat.reinterpretAs(node, DisplayObjectContainer);
		if (_loc5_ == null || _loc5_.numChildren == 0 || _loc5_.scrollRect != null) {
			unionInto(out, boundsIn(node, space));
			return;
		}
		var _loc6_ = new Rectangle();
		_loc7_ = 0;
		while (_loc7_ < _loc5_.numChildren) {
			_loc10_ = _loc5_.getChildAt(_loc7_);
			if (_loc10_ != null) {
				visibleBounds(_loc10_, space, _loc6_, false);
			}
			_loc7_++;
		}
		var _loc8_ = boundsIn(node, space);
		if (Std.isOfType(_loc5_, Sprite) && !(_loc6_.width > 0 && _loc6_.height > 0 && _loc6_.containsRect(_loc8_))) {
			try {
				_loc9_ = cast(_loc5_, Sprite).graphics.readGraphicsData(false).length > 0;
			} catch (error:Dynamic) {
				_loc9_ = true;
			}
			if (_loc9_) {
				unionInto(out, _loc8_);
				return;
			}
		}
		unionInto(out, _loc6_);
	}

	static function boundsIn(node:DisplayObject, space:DisplayObject):Rectangle {
		var _loc13_:Matrix = null;
		var _loc6_:DisplayObject = null;
		var _loc12_ = node.getBounds(space);
		if (_loc12_.width > 0 && _loc12_.height > 0 || node == space) {
			return _loc12_;
		}
		var _loc9_ = node.getBounds(node);
		if (_loc9_.width <= 0 && _loc9_.height <= 0) {
			return _loc12_;
		}
		var _loc8_ = new Matrix();
		_loc6_ = node;
		while (_loc6_ != null && _loc6_ != space) {
			if (_loc6_ != node && _loc6_.scrollRect != null) {
				_loc8_.translate(-_loc6_.scrollRect.x, -_loc6_.scrollRect.y);
			}
			_loc13_ = _loc6_.transform.matrix;
			if (_loc13_ == null) {
				return _loc12_;
			}
			_loc8_.concat(_loc13_);
			_loc6_ = _loc6_.parent;
		}
		var _loc3_ = _loc8_.transformPoint(_loc9_.topLeft);
		var _loc4_ = _loc8_.transformPoint(new Point(_loc9_.right, _loc9_.top));
		var _loc5_ = _loc8_.transformPoint(_loc9_.bottomRight);
		var _loc7_ = _loc8_.transformPoint(new Point(_loc9_.left, _loc9_.bottom));
		var _loc11_ = Math.min(_loc3_.x, Math.min(Math.min(_loc4_.x, _loc5_.x), _loc7_.x));
		var _loc10_ = Math.min(_loc3_.y, Math.min(Math.min(_loc4_.y, _loc5_.y), _loc7_.y));
		return new Rectangle(_loc11_, _loc10_, Math.max(_loc3_.x, Math.max(Math.max(_loc4_.x, _loc5_.x), _loc7_.x)) - _loc11_,
			Math.max(_loc3_.y, Math.max(Math.max(_loc4_.y, _loc5_.y), _loc7_.y)) - _loc10_);
	}

	static function unionInto(out:Rectangle, rect:Rectangle) {
		if (rect.width <= 0 || rect.height <= 0) {
			return;
		}
		if (out.width <= 0 || out.height <= 0) {
			out.copyFrom(rect);
		} else {
			out.copyFrom(out.union(rect));
		}
	}

	public static function textCopy(field:TextField, text:String = null):TextField {
		var _loc4_ = new TextField();
		var _loc3_ = ASCompat.coerce(field.length > 0 ? field.getTextFormat(0, field.length) : null, flash.text.TextFormat);
		_loc4_.defaultTextFormat = _loc3_ != null && _loc3_.size != null ? _loc3_ : field.defaultTextFormat;
		_loc4_.embedFonts = field.embedFonts;
		_loc4_.antiAliasType = field.antiAliasType;
		_loc4_.gridFitType = field.gridFitType;
		_loc4_.sharpness = field.sharpness;
		_loc4_.thickness = field.thickness;
		_loc4_.multiline = false;
		_loc4_.wordWrap = false;
		_loc4_.selectable = false;
		_loc4_.autoSize = "left";
		_loc4_.filters = cast(field.filters);
		_loc4_.text = text ?? field.text;
		_loc4_.textColor = field.textColor;
		return _loc4_;
	}

	static function emptyBake(scale:Float):BakedPicture {
		var _loc2_ = new BakedPicture();
		_loc2_.bitmap = new BitmapData(1 * 2, 1 * 2, true, (0 : UInt));
		_loc2_.originX = _loc2_.originY = 1;
		_loc2_.pixelScale = scale;
		_loc2_.empty = true;
		return _loc2_;
	}

	static function nestedPadding(node:DisplayObject, skipOwn:Bool):Int {
		var _loc3_:BitmapFilter;
		var __ax4_iter_498:Array<ASAny>;
		var _loc8_:Rectangle = null;
		var _loc7_ = 0;
		var _loc9_:DisplayObject = null;
		var _loc6_ = 0;
		if (!skipOwn && !node.visible) {
			return 0;
		}
		if (!skipOwn) {
			__ax4_iter_498 = node.filters;
			if (checkNullIteratee(__ax4_iter_498))
				for (_tmp_ in __ax4_iter_498) {
					_loc3_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
					_loc8_ = sProbe.generateFilterRect(sProbeRect, _loc3_);
					_loc6_ += Math.ceil(Math.max(-_loc8_.x, -_loc8_.y, _loc8_.right - sProbeRect.right, _loc8_.bottom - sProbeRect.bottom, estimate(_loc3_)));
				}
		}
		var _loc5_ = 0;
		var _loc4_ = ASCompat.reinterpretAs(node, DisplayObjectContainer);
		if (_loc4_ != null) {
			_loc7_ = 0;
			while (_loc7_ < _loc4_.numChildren) {
				_loc9_ = _loc4_.getChildAt(_loc7_);
				if (_loc9_ != null) {
					_loc5_ = ASCompat.floatToInt(Math.max(_loc5_, nestedPadding(_loc9_, false)));
				}
				_loc7_++;
			}
		}
		return _loc6_ + _loc5_;
	}

	static function estimate(filter:BitmapFilter):Float {
		var _loc3_ = (filter : ASAny).hasOwnProperty("blurX") ? Math.max(ASCompat.toNumber((filter : ASAny)["blurX"]),
			ASCompat.toNumber((filter : ASAny)["blurY"])) : 0;
		var _loc4_ = (filter : ASAny).hasOwnProperty("quality") ? Math.max(1, ASCompat.toNumber((filter : ASAny)["quality"])) : 1;
		var _loc2_ = (filter : ASAny).hasOwnProperty("distance") ? Math.abs(ASCompat.toNumber((filter : ASAny)["distance"])) : 0;
		return _loc3_ * _loc4_ / 2 + _loc2_ + 2;
	}
}
