package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.GraphGroup;
import com.junkbyte.console.vos.GraphInterest;
import flash.display.Shape;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class GraphingPanel extends ConsolePanel {
	public static var FPS:String = "fpsPanel";

	public static var MEM:String = "memoryPanel";

	public var underlay:Shape;

	public var startOffset:Int = 0;

	public var lowTxt:TextField;

	public var highTxt:TextField;

	public var graph:Shape;

	public var _type:String;

	public var _needRedraw:Bool = false;

	public var _menuString:String;

	public var _interest:GraphInterest;

	public var _infoMap:IMap<ASAny, ASAny>;

	public var _group:GraphGroup;

	public function new(m:Console = /*undefined*/ null, W:Float = 0, H:Float = 0, type:String = /*undefined*/ null) {
		startOffset = 5;
		_infoMap = new StringMap<ASAny>();
		super(m);
		_type = type;
		registerDragger(bg);
		minWidth = 32;
		minHeight = 26;
		var _loc5_ = new TextFormat();
		var _loc6_:ASObject = get_style().get_styleSheet().getStyle("low");
		_loc5_.font = _loc6_.fontFamily;
		_loc5_.size = _loc6_.fontSize;
		_loc5_.color = get_style().lowColor;
		lowTxt = new TextField();
		lowTxt.name = "lowestField";
		lowTxt.defaultTextFormat = _loc5_;
		lowTxt.mouseEnabled = false;
		lowTxt.height = get_style().menuFontSize + 2;
		addChild(lowTxt);
		highTxt = new TextField();
		highTxt.name = "highestField";
		highTxt.defaultTextFormat = _loc5_;
		highTxt.mouseEnabled = false;
		highTxt.height = get_style().menuFontSize + 2;
		highTxt.y = get_style().menuFontSize - 4;
		addChild(highTxt);
		txtField = makeTF("menuField");
		txtField.height = get_style().menuFontSize + 4;
		txtField.y = -3;
		txtField.selectable = false;
		registerTFRoller(txtField, onMenuRollOver, linkHandler);
		registerDragger(txtField);
		addChild(txtField);
		underlay = new Shape();
		addChild(underlay);
		graph = new Shape();
		graph.name = "graph";
		graph.y = get_style().menuFontSize;
		addChild(graph);
		_menuString = "<menu>";
		if (_type == "memoryPanel") {
			_menuString += " <a href=\"event:gc\">G</a> ";
		}
		_menuString += "<a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></low></r>";
		init(W, H, true);
	}

	public function updateKeyText() {
		var _loc2_ = Math.NaN;
		var _loc3_:ASAny = null;
		var _loc4_ = ASCompat.dynamicAs(null, StringMap);
		var _loc5_:ASAny = null;
		var _loc6_ = 0;
		var _loc7_ = false;
		var _loc8_:ASAny = null;
		var _loc9_ = 0;
		var _loc10_ = false;
		var _loc11_ = 0;
		var _loc12_:ASAny = null;
		var _loc13_ = 0;
		var _loc14_ = false;
		var _loc15_:ASAny = ASCompat.asString(null);
		var _loc16_:ASAny = ASCompat.asString(null);
		var _loc17_ = ASCompat.dynamicAs(null, StringMap);
		var _loc1_ = "<r><low>";
		if (_type != null) {
			_loc2_ = _interest.v;
			if (_loc2_ != _loc2_) {
				_loc1_ += "no input";
			} else if (_type == "fpsPanel") {
				_loc3_ = _interest.avg;
				_loc1_ += Std.string(ASCompat.callNumberMethod(_loc3_, "toFixed", 1));
			} else if (_type == "memoryPanel") {
				_loc1_ += _interest.v + "mb";
			}
		} else {
			_loc4_ = cast(_infoMap, StringMap<Dynamic>);
			_loc3_ = ASCompat.haxeMapStorage(_loc4_);
			_loc5_ = null;
			_loc6_ = 0;
			_loc7_ = false;
			_loc8_ = _loc3_;
			_loc9_ = _loc6_;
			_loc10_ = (_loc9_ = ASCompat.nextIndex(_loc8_, _loc9_)) != 0;
			if (!_loc10_ && _loc5_ != null) {
				_loc3_ = _loc5_;
				_loc8_ = _loc3_;
				_loc9_ = _loc6_ = 0;
				_loc5_ = null;
				_loc7_ = true;
				_loc10_ = (_loc9_ = ASCompat.nextIndex(_loc8_, _loc9_)) != 0;
			}
			_loc11_ = _loc9_;
			while (true) {
				_loc12_ = _loc3_;
				_loc13_ = _loc6_;
				_loc14_ = (_loc13_ = ASCompat.nextIndex(_loc12_, _loc13_)) != 0;
				if (!_loc14_ && _loc5_ != null) {
					_loc3_ = _loc5_;
					_loc12_ = _loc3_;
					_loc13_ = _loc6_ = 0;
					_loc5_ = null;
					_loc7_ = true;
					_loc14_ = (_loc13_ = ASCompat.nextIndex(_loc12_, _loc13_)) != 0;
				}
				_loc11_ = _loc13_;
				if (!_loc14_) {
					break;
				}
				_loc15_ = ASCompat.nextName(_loc3_, _loc11_);
				_loc6_ = _loc11_;
				if (_loc7_) {
					_loc15_ = Std.string(_loc15_).substr(1);
				}
				_loc16_ = _loc15_;
				_loc17_ = cast(_infoMap, StringMap<Dynamic>);
				_loc1_ += " <font color=\'#" + Std.string(_loc17_.get(_loc16_)[0]) + "\'>" + Std.string(_loc16_) + "</font>";
			}
			_loc1_ += " |";
		}
		txtField.htmlText = _loc1_ + _menuString;
		txtField.scrollH = txtField.maxScrollH;
	}

	public function update(group:GraphGroup, draw:Bool) {
		var _loc12_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		var _loc13_:ASAny = ASCompat.asString(null);
		var _loc14_ = ASCompat.dynamicAs(null, StringMap);
		var _loc15_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc16_ = ASCompat.dynamicAs(null, StringMap);
		var _loc17_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc18_ = 0;
		var _loc19_ = 0;
		var _loc20_ = 0;
		var _loc21_ = Math.NaN;
		var _loc22_ = 0;
		var _loc23_ = 0;
		var _loc24_ = 0;
		var _loc25_ = Math.NaN;
		var _loc31_:ASAny = null;
		var _loc32_ = false;
		var _loc33_:ASAny = ASCompat.asString(null);
		var _loc34_ = false;
		_group = group;
		var _loc3_ = 1;
		if (group.idle > 0) {
			_loc3_ = 0;
			if (!_needRedraw) {
				return;
			}
		}
		if (_needRedraw) {
			draw = true;
		}
		_needRedraw = false;
		var _loc4_ = group.interests;
		var _loc5_ = ASCompat.floatToInt(get_width() - startOffset);
		var _loc6_ = ASCompat.floatToInt(get_height() - graph.y);
		var _loc7_ = group.low;
		var _loc8_ = group.hi;
		var _loc9_ = _loc8_ - _loc7_;
		var _loc10_ = false;
		if (draw) {
			(group.inv ? highTxt : lowTxt).text = "" + group.low;
			(group.inv ? lowTxt : highTxt).text = "" + group.hi;
			graph.graphics.clear();
		}
		var _loc11_ = 0;
		while (_loc11_ < _loc4_.length) {
			_loc12_ = _loc4_[_loc11_];
			_loc11_++;
			_interest = ASCompat.coerce(_loc12_, com.junkbyte.console.vos.GraphInterest);
			_loc13_ = _interest.key;
			_loc14_ = cast(_infoMap, StringMap<Dynamic>);
			_loc15_ = _loc14_.get(_loc13_);
			if (_loc15_ == null) {
				_loc10_ = true;
				_loc15_ = ([StringTools.hex(_interest.col), []] : Array<ASAny>);
				_loc16_ = cast(_infoMap, StringMap<Dynamic>);
				{
					_loc16_.set(_loc13_, _loc15_);
				}
			}
			_loc17_ = _loc15_[1];
			if (_loc3_ == 1) {
				if (group.type == 1) {
					_loc18_ = ASCompat.floatToInt(Math.ffloor(group.hi / _interest.v));
					if (_loc18_ > 30) {
						_loc18_ = 30;
					}
					while (_loc18_ > 0) {
						ASCompat.dynPush(_loc17_, _interest.v);
						_loc18_--;
					}
				} else {
					ASCompat.dynPush(_loc17_, _interest.v);
				}
			}
			_loc18_ = ASCompat.floatToInt(Math.ffloor(_loc5_)) + 10;
			while (ASCompat.toInt(_loc17_.length) > _loc18_) {
				ASCompat.dynShift(_loc17_);
			}
			if (draw) {
				_loc19_ = ASCompat.toInt(_loc17_.length);
				graph.graphics.lineStyle(1, (_interest.col : UInt));
				_loc20_ = _loc5_ > _loc19_ ? _loc19_ : _loc5_;
				_loc22_ = 1;
				_loc23_ = _loc20_;
				while (_loc22_ < _loc23_) {
					_loc24_ = _loc22_++;
					_loc21_ = (_loc9_ != 0 ? (ASCompat.toNumber(_loc17_[_loc19_ - _loc24_]) - _loc7_) / _loc9_ : 0.5) * _loc6_;
					if (!group.inv) {
						_loc21_ = _loc6_ - _loc21_;
					}
					if (_loc21_ < 0) {
						_loc21_ = 0;
					}
					if (_loc21_ > _loc6_) {
						_loc21_ = _loc6_;
					}
					if (_loc24_ == 1) {
						graph.graphics.moveTo(get_width(), _loc21_);
					}
					graph.graphics.lineTo(_loc5_ - _loc24_, _loc21_);
				}
				_loc25_ = _interest.avg;
				if (_loc25_ == _loc25_ && _loc9_ != 0) {
					_loc21_ = (_interest.avg - _loc7_) / _loc9_ * _loc6_;
					if (!group.inv) {
						_loc21_ = _loc6_ - _loc21_;
					}
					if (_loc21_ < 0) {
						_loc21_ = 0;
					}
					if (_loc21_ > _loc6_) {
						_loc21_ = _loc6_;
					}
					graph.graphics.lineStyle(1, (_interest.col : UInt), 0.3);
					graph.graphics.moveTo(0, _loc21_);
					graph.graphics.lineTo(_loc5_, _loc21_);
				}
			}
		}
		_loc14_ = cast(_infoMap, StringMap<Dynamic>);
		var _loc26_:ASAny = ASCompat.haxeMapStorage(_loc14_);
		var _loc27_:ASAny = null;
		_loc11_ = 0;
		var _loc28_ = false;
		var _loc29_:ASAny = _loc26_;
		_loc18_ = _loc11_;
		var _loc30_ = (_loc18_ = ASCompat.nextIndex(_loc29_, _loc18_)) != 0;
		if (!_loc30_ && _loc27_ != null) {
			_loc29_ = _loc26_ = _loc27_;
			_loc18_ = _loc11_ = 0;
			_loc27_ = null;
			_loc28_ = true;
			_loc30_ = (_loc18_ = ASCompat.nextIndex(_loc29_, _loc18_)) != 0;
		}
		_loc19_ = _loc18_;
		while (true) {
			_loc31_ = _loc26_;
			_loc20_ = _loc11_;
			_loc32_ = (_loc20_ = ASCompat.nextIndex(_loc31_, _loc20_)) != 0;
			if (!_loc32_ && _loc27_ != null) {
				_loc31_ = _loc26_ = _loc27_;
				_loc20_ = _loc11_ = 0;
				_loc27_ = null;
				_loc28_ = true;
				_loc32_ = (_loc20_ = ASCompat.nextIndex(_loc31_, _loc20_)) != 0;
			}
			_loc19_ = _loc20_;
			if (!_loc32_) {
				break;
			}
			_loc13_ = ASCompat.nextName(_loc26_, _loc19_);
			_loc11_ = _loc19_;
			if (_loc28_) {
				_loc13_ = Std.string(_loc13_).substr(1);
			}
			_loc33_ = _loc13_;
			_loc34_ = false;
			_loc22_ = 0;
			while (_loc22_ < _loc4_.length) {
				_loc12_ = _loc4_[_loc22_];
				_loc22_++;
				if (_loc12_.key == _loc33_) {
					_loc34_ = true;
				}
			}
			if (!_loc34_) {
				_loc10_ = true;
				cast(_infoMap, StringMap<Dynamic>).remove(_loc33_);
			}
		}
		if (draw && (_loc10_ || _type != null)) {
			updateKeyText();
		}
	}

	public function stop() {
		if (_group != null) {
			console.get_graphing().remove(_group.name);
		}
	}

	override public function set_width(value:Float):Float {
		super.set_width(value);
		lowTxt.width = value;
		highTxt.width = value;
		txtField.width = value;
		txtField.scrollH = txtField.maxScrollH;
		graph.graphics.clear();
		_needRedraw = true;
		return value;
	}

	override public function set_height(value:Float):Float {
		super.set_height(value);
		lowTxt.y = value - get_style().menuFontSize;
		_needRedraw = true;
		var _loc2_ = underlay.graphics;
		_loc2_.clear();
		_loc2_.lineStyle(1, get_style().controlColor, 0.6);
		_loc2_.moveTo(0, graph.y);
		_loc2_.lineTo(get_width() - startOffset, graph.y);
		_loc2_.lineTo(get_width() - startOffset, value);
		return value;
	}

	public function reset() {
		var _loc1_ = cast(_infoMap, StringMap<Dynamic>);
		_loc1_.clear();
		graph.graphics.clear();
		if (!_group.fixed) {
			_group.low = Math.NaN;
			_group.hi = Math.NaN;
		}
	}

	public function onMenuRollOver(e:TextEvent) {
		var _loc2_ = e.text != null ? StringTools.replace(e.text, "event:", "") : "";
		if (_loc2_ == "gc") {
			_loc2_ = "Garbage collect::Requires debugger version of flash player";
		}
		console.get_panels().tooltip(_loc2_, this);
	}

	public function linkHandler(e:TextEvent) {
		cast(e.currentTarget, TextField).setSelection(0, 0);
		if (e.text == "reset") {
			reset();
		} else if (e.text == "close") {
			if (_type == "fpsPanel") {
				console.set_fpsMonitor(false);
			} else if (_type == "memoryPanel") {
				console.set_memoryMonitor(false);
			} else {
				stop();
			}
			console.get_panels().removeGraph(_group);
		} else if (e.text == "gc") {
			console.gc();
		}
		e.stopPropagation();
	}

	@:isVar public var group(get, never):GraphGroup;

	public function get_group():GraphGroup {
		return _group;
	}
}
