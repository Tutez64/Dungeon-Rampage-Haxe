package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.ConsoleConfig;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Mouse;

class Ruler extends Sprite {
	public var background:Sprite;

	public var _zoom:Bitmap;

	public var _posTxt:TextField;

	public var _points:Array<ASAny>;

	public var _pointerTop:Shape;

	public var _pointerRight:Shape;

	public var _pointerLeft:Shape;

	public var _pointerBottom:Shape;

	public var _pointer:Shape;

	public var _master:Console;

	public var _config:ConsoleConfig;

	public var _area:Rectangle;

	public function new(console:Console = /*undefined*/ null) {
		super();
		_master = console;
		_config = console.get_config();
		buttonMode = true;
		_points = [];
		_pointer = new Shape();
		addChild(_pointer);
		var _loc2_ = new Point();
		_loc2_ = globalToLocal(_loc2_);
		_area = new Rectangle(-console.stage.stageWidth * 1.5 + _loc2_.x, -console.stage.stageHeight * 1.5 + _loc2_.y, console.stage.stageWidth * 3,
			console.stage.stageHeight * 3);
		graphics.beginFill(_config.get_style().backgroundColor, 0.2);
		graphics.drawRect(_area.x, _area.y, _area.width, _area.height);
		graphics.endFill();
		_posTxt = _master.get_panels().get_mainPanel().makeTF("positionText", true);
		_posTxt.autoSize = TextFieldAutoSize.LEFT;
		addChild(_posTxt);
		_zoom = new Bitmap();
		_zoom.scaleY = _zoom.scaleX = 2;
		addChild(_zoom);
		addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		onMouseMove();
		if (_config.rulerHidesMouse) {
			Mouse.hide();
		}
		_master.report("<b>Ruler started. Click on two locations to measure.</b>", -1);
	}

	public function updateSize() {
		var _loc1_ = new Point();
		_loc1_ = globalToLocal(_loc1_);
		_area = new Rectangle(-_loc1_.x, -_loc1_.y, _master.stage.stageWidth, _master.stage.stageHeight);
		var _loc2_ = Math.floor(_master.stage.stageHeight);
		var _loc3_ = Math.floor(_master.stage.stageWidth);
		_pointerRight.graphics.clear();
		_pointerRight.graphics.lineStyle(1, (11193344 : UInt), 1);
		_pointerRight.graphics.moveTo(_loc1_.x, 0);
		_pointerRight.graphics.lineTo(_loc1_.x - _loc3_, 0);
		_pointerLeft.graphics.clear();
		_pointerLeft.graphics.lineStyle(1, (11193344 : UInt), 1);
		_pointerLeft.graphics.moveTo(_loc3_ - _loc1_.x, 0);
		_pointerLeft.graphics.lineTo(_loc1_.x, 0);
		_pointerTop.graphics.clear();
		_pointerTop.graphics.lineStyle(1, (11193344 : UInt), 1);
		_pointerTop.graphics.moveTo(0, _loc1_.y - _loc2_);
		_pointerTop.graphics.lineTo(0, _loc1_.y);
		_pointerBottom.graphics.clear();
		_pointerBottom.graphics.lineStyle(1, (11193344 : UInt), 1);
		_pointerBottom.graphics.moveTo(0, _loc1_.y);
		_pointerBottom.graphics.lineTo(0, _loc2_ - _loc1_.y);
	}

	public function round(n:Float, d:UInt = (10 : UInt)):Float {
		return ASCompat.floatToInt(Math.fround(d * n)) / d;
	}

	public function onMouseMove(e:MouseEvent = /*undefined*/ null) {
		var _loc4_ = ASCompat.dynamicAs(null, Matrix);
		var _loc5_ = ASCompat.dynamicAs(null, Error);
		_pointer.graphics.clear();
		_pointer.graphics.lineStyle(1, (11193344 : UInt), 1);
		_pointer.graphics.moveTo(_area.x, mouseY);
		_pointer.graphics.lineTo(_area.x + _area.width, mouseY);
		_pointer.graphics.moveTo(mouseX, _area.y);
		_pointer.graphics.lineTo(mouseX, _area.y + _area.height);
		_pointer.blendMode = BlendMode.INVERT;
		_posTxt.text = "<low>" + mouseX + "," + mouseY + "</low>";
		var _loc3_ = new BitmapData(30, 30);
		try {
			_loc4_ = new Matrix();
			ASCompat.setProperty(_loc4_, "tx", -_master.stage.mouseX + 15);
			ASCompat.setProperty(_loc4_, "ty", -_master.stage.mouseY + 15);
			_loc3_.draw(_master.stage, _loc4_);
		} catch (_loc_e_:Dynamic) {
			_loc5_ = _loc_e_;
			_loc3_ = null;
		}
		_zoom.bitmapData = _loc3_;
		var _loc6_ = 10;
		_posTxt.x = mouseX - _posTxt.width - _loc6_;
		_posTxt.y = mouseY - _posTxt.height - _loc6_;
		_zoom.x = _posTxt.x + _posTxt.width - _zoom.width;
		_zoom.y = _posTxt.y - _zoom.height;
		if (_posTxt.x < 16) {
			_posTxt.x = mouseX + _loc6_;
			_zoom.x = _posTxt.x;
		}
		if (_posTxt.y < 38) {
			_posTxt.y = mouseY + _loc6_;
			_zoom.y = _posTxt.y + _posTxt.height;
		}
	}

	public function onMouseClick(e:MouseEvent) {
		var _loc2_:ASAny = ASCompat.dynamicAs(null, Point);
		var _loc4_ = ASCompat.dynamicAs(null, Point);
		var _loc5_ = ASCompat.dynamicAs(null, Point);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, Point);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, Point);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, Point);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, Point);
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = ASCompat.dynamicAs(null, TextField);
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		e.stopPropagation();
		var _loc3_ = _config.get_style();
		if (_points.length == 0) {
			_loc2_ = new Point(e.localX, e.localY);
			graphics.lineStyle(1, (16711680 : UInt));
			graphics.drawCircle(ASCompat.toNumberField(_loc2_, "x"), ASCompat.toNumberField(_loc2_, "y"), 3);
			_points.push(_loc2_);
		} else if (_points.length == 1) {
			_zoom.bitmapData = null;
			if (_config.rulerHidesMouse) {
				Mouse.show();
			}
			removeChild(_pointer);
			removeChild(_posTxt);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_loc2_ = _points[0];
			_loc4_ = new Point(e.localX, e.localY);
			_points.push(_loc4_);
			graphics.clear();
			graphics.beginFill(_loc3_.backgroundColor, 0.4);
			graphics.drawRect(_area.x, _area.y, _area.width, _area.height);
			graphics.endFill();
			graphics.lineStyle(1.5, (16711680 : UInt));
			graphics.drawCircle(ASCompat.toNumberField(_loc2_, "x"), ASCompat.toNumberField(_loc2_, "y"), 4);
			graphics.lineStyle(1.5, (16750848 : UInt));
			graphics.drawCircle(ASCompat.toNumberField(_loc4_, "x"), ASCompat.toNumberField(_loc4_, "y"), 4);
			_loc5_ = Point.interpolate(ASCompat.coerce(_loc2_, flash.geom.Point), _loc4_, 0.5);
			graphics.lineStyle(1, (11184810 : UInt));
			graphics.drawCircle(ASCompat.toNumberField(_loc5_, "x"), ASCompat.toNumberField(_loc5_, "y"), 4);
			_loc6_ = _loc2_;
			_loc7_ = _loc4_;
			if (_loc2_.x > _loc4_.x) {
				_loc6_ = _loc4_;
				_loc7_ = _loc2_;
			}
			_loc8_ = _loc2_;
			_loc9_ = _loc4_;
			if (_loc2_.y > _loc4_.y) {
				_loc8_ = _loc4_;
				_loc9_ = _loc2_;
			}
			_loc10_ = ASCompat.toNumberField(_loc7_, "x") - ASCompat.toNumberField(_loc6_, "x");
			_loc11_ = ASCompat.toNumberField(_loc9_, "y") - ASCompat.toNumberField(_loc8_, "y");
			_loc12_ = Point.distance(ASCompat.coerce(_loc2_, flash.geom.Point), _loc4_);
			_loc13_ = makeTxtField((_loc3_.highColor : Int));
			ASCompat.setProperty(_loc13_, "text", round(ASCompat.toNumberField(_loc2_, "x")) + "," + round(ASCompat.toNumberField(_loc2_, "y")));
			ASCompat.setProperty(_loc13_, "x", _loc2_.x);
			ASCompat.setProperty(_loc13_, "y", ASCompat.toNumberField(_loc2_, "y") - (_loc8_ == _loc2_ ? 14 : 0));
			addChild(_loc13_);
			_loc13_ = makeTxtField((_loc3_.highColor : Int));
			ASCompat.setProperty(_loc13_, "text", round(ASCompat.toNumberField(_loc4_, "x")) + "," + round(ASCompat.toNumberField(_loc4_, "y")));
			ASCompat.setProperty(_loc13_, "x", _loc4_.x);
			ASCompat.setProperty(_loc13_, "y", ASCompat.toNumberField(_loc4_, "y") - (_loc8_ == _loc4_ ? 14 : 0));
			addChild(_loc13_);
			if (_loc10_ > 40 || _loc11_ > 25) {
				_loc13_ = makeTxtField((_loc3_.lowColor : Int));
				ASCompat.setProperty(_loc13_, "text", round(ASCompat.toNumberField(_loc5_, "x")) + "," + round(ASCompat.toNumberField(_loc5_, "y")));
				ASCompat.setProperty(_loc13_, "x", _loc5_.x);
				ASCompat.setProperty(_loc13_, "y", _loc5_.y);
				addChild(_loc13_);
			}
			graphics.lineStyle(1, (11193344 : UInt), 0.5);
			graphics.moveTo(_area.x, ASCompat.toNumberField(_loc8_, "y"));
			graphics.lineTo(_area.x + _area.width, ASCompat.toNumberField(_loc8_, "y"));
			graphics.moveTo(_area.x, ASCompat.toNumberField(_loc9_, "y"));
			graphics.lineTo(_area.x + _area.width, ASCompat.toNumberField(_loc9_, "y"));
			graphics.moveTo(ASCompat.toNumberField(_loc6_, "x"), _area.y);
			graphics.lineTo(ASCompat.toNumberField(_loc6_, "x"), _area.y + _area.height);
			graphics.moveTo(ASCompat.toNumberField(_loc7_, "x"), _area.y);
			graphics.lineTo(ASCompat.toNumberField(_loc7_, "x"), _area.y + _area.height);
			_loc14_ = round(angle(ASCompat.coerce(_loc2_, flash.geom.Point), _loc4_), (100 : UInt));
			_loc15_ = round(angle(_loc4_, ASCompat.coerce(_loc2_, flash.geom.Point)), (100 : UInt));
			graphics.lineStyle(1, (11141120 : UInt), 0.8);
			drawCircleSegment(graphics, 10, ASCompat.coerce(_loc2_, flash.geom.Point), _loc14_, -90);
			graphics.lineStyle(1, (13404160 : UInt), 0.8);
			drawCircleSegment(graphics, 10, _loc4_, _loc15_, -90);
			graphics.lineStyle(2, (65280 : UInt), 0.7);
			graphics.moveTo(ASCompat.toNumberField(_loc2_, "x"), ASCompat.toNumberField(_loc2_, "y"));
			graphics.lineTo(ASCompat.toNumberField(_loc4_, "x"), ASCompat.toNumberField(_loc4_, "y"));
			_master.report("Ruler results: (red) <b>[" + Std.string(_loc2_.x) + "," + Std.string(_loc2_.y) + "]</b> to (orange) <b>[" + Std.string(_loc4_.x)
				+ "," + Std.string(_loc4_.y) + "]</b>",
				-2);
			_master.report("Distance: <b>" + round(_loc12_, (100 : UInt)) + "</b>", -2);
			_master.report("Mid point: <b>[" + Std.string(_loc5_.x) + "," + Std.string(_loc5_.y) + "]</b>", -2);
			_master.report("Width:<b>" + _loc10_ + "</b>, Height: <b>" + _loc11_ + "</b>", -2);
			_master.report("Angle from first point (red): <b>" + _loc14_ + "°</b>", -2);
			_master.report("Angle from second point (orange): <b>" + _loc15_ + "°</b>", -2);
		} else {
			exit();
		}
	}

	public function makeTxtField(col:Int, b:Bool = true):TextField {
		var _loc3_ = new TextFormat(_config.get_style().menuFont, _config.get_style().menuFontSize, col, b, true, null, null, null, TextFormatAlign.RIGHT);
		var _loc4_ = new TextField();
		_loc4_.autoSize = TextFieldAutoSize.RIGHT;
		_loc4_.selectable = false;
		_loc4_.defaultTextFormat = _loc3_;
		return _loc4_;
	}

	public function getPointOnCircle(radius:Float, rad:Float):Point {
		return new Point(radius * Math.cos(rad), radius * Math.sin(rad));
	}

	public function exit() {
		_master = null;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	public function drawCircleSegment(g:Graphics, radius:Float, pos:Point, deg:Float = 180, startDeg:Float = 0):Point {
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = ASCompat.dynamicAs(null, Point);
		var _loc6_ = false;
		if (deg < 0) {
			_loc6_ = true;
			deg = Math.abs(deg);
		}
		var _loc7_ = deg * Math.PI / 180;
		var _loc8_ = startDeg * Math.PI / 180;
		var _loc9_ = getPointOnCircle(radius, _loc8_);
		_loc9_.offset(pos.x, pos.y);
		g.moveTo(_loc9_.x, _loc9_.y);
		var _loc10_:Float = 0;
		var _loc11_ = 1;
		while (_loc11_ <= _loc7_ + 1) {
			_loc12_ = _loc11_ <= _loc7_ ? _loc11_ : _loc7_;
			_loc13_ = _loc12_ - _loc10_;
			_loc14_ = 1 + 0.12 * _loc13_ * _loc13_;
			_loc15_ = getPointOnCircle(radius * _loc14_, (_loc12_ - _loc13_ / 2) * (_loc6_ ? -1 : 1) + _loc8_);
			_loc15_.offset(pos.x, pos.y);
			_loc9_ = getPointOnCircle(radius, _loc12_ * (_loc6_ ? -1 : 1) + _loc8_);
			_loc9_.offset(pos.x, pos.y);
			g.curveTo(ASCompat.toNumberField(_loc15_, "x"), ASCompat.toNumberField(_loc15_, "y"), _loc9_.x, _loc9_.y);
			_loc10_ = _loc12_;
			_loc11_++;
		}
		return _loc9_;
	}

	public function angle(srcP:Point, point:Point):Float {
		var _loc3_ = Math.atan2(point.y - srcP.y, point.x - srcP.x) / Math.PI * 180;
		_loc3_ += 90;
		if (_loc3_ > 180) {
			_loc3_ -= 360;
		}
		return _loc3_;
	}
}
