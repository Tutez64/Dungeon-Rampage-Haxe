package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.GraphGroup;
import com.junkbyte.console.vos.GraphInterest;
import flash.display.Shape;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class GraphingPanel extends ConsolePanel {
	public static inline final FPS = "fpsPanel";

	public static inline final MEM = "memoryPanel";

	var _group:GraphGroup;

	var _interest:GraphInterest;

	var _infoMap:ASObject = new ASObject();

	var _menuString:String;

	var _type:String;

	var _needRedraw:Bool = false;

	var underlay:Shape;

	var graph:Shape;

	var lowTxt:TextField;

	var highTxt:TextField;

	public var startOffset:Int = 5;

	public function new(m:Console, W:Int, H:Int, type:String = null) {
		super(m);
		this._type = type;
		registerDragger(bg);
		minWidth = 32;
		minHeight = 26;
		var _loc5_ = new TextFormat();
		var _loc6_:ASObject = style.styleSheet.getStyle("low");
		_loc5_.font = _loc6_.fontFamily;
		_loc5_.size = _loc6_.fontSize;
		_loc5_.color = style.lowColor;
		this.lowTxt = new TextField();
		this.lowTxt.name = "lowestField";
		this.lowTxt.defaultTextFormat = _loc5_;
		this.lowTxt.mouseEnabled = false;
		this.lowTxt.height = style.menuFontSize + 2;
		addChild(this.lowTxt);
		this.highTxt = new TextField();
		this.highTxt.name = "highestField";
		this.highTxt.defaultTextFormat = _loc5_;
		this.highTxt.mouseEnabled = false;
		this.highTxt.height = style.menuFontSize + 2;
		this.highTxt.y = style.menuFontSize - 4;
		addChild(this.highTxt);
		txtField = makeTF("menuField");
		txtField.height = style.menuFontSize + 4;
		txtField.y = -3;
		registerTFRoller(txtField, this.onMenuRollOver, this.linkHandler);
		registerDragger(txtField);
		addChild(txtField);
		this.underlay = new Shape();
		addChild(this.underlay);
		this.graph = new Shape();
		this.graph.name = "graph";
		this.graph.y = style.menuFontSize;
		addChild(this.graph);
		this._menuString = "<menu>";
		if (this._type == MEM) {
			this._menuString += " <a href=\"event:gc\">G</a> ";
		}
		this._menuString += "<a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></low></r>";
		init(W, H, true);
	}

	function stop() {
		if (this._group != null) {
			console.graphing.remove(this._group.name);
		}
	}

	@:isVar public var group(get, never):GraphGroup;

	public function get_group():GraphGroup {
		return this._group;
	}

	public function reset() {
		this._infoMap = {};
		this.graph.graphics.clear();
		if (!this._group.fixed) {
			this._group.low = Math.NaN;
			this._group.hi = Math.NaN;
		}
	}

	override public function set_height(n:Float):Float {
		super.height = n;
		this.lowTxt.y = n - style.menuFontSize;
		this._needRedraw = true;
		var _loc2_ = this.underlay.graphics;
		_loc2_.clear();
		_loc2_.lineStyle(1, style.controlColor, 0.6);
		_loc2_.moveTo(0, this.graph.y);
		_loc2_.lineTo(width - this.startOffset, this.graph.y);
		_loc2_.lineTo(width - this.startOffset, n);
		return n;
	}

	override public function set_width(n:Float):Float {
		super.width = n;
		this.lowTxt.width = n;
		this.highTxt.width = n;
		txtField.width = n;
		txtField.scrollH = txtField.maxScrollH;
		this.graph.graphics.clear();
		this._needRedraw = true;
		return n;
	}

	public function update(group:GraphGroup, draw:Bool) {
		var _loc11_:GraphInterest = null;
		var _loc12_:String = null;
		var _loc13_:String = null;
		var _loc14_:Array<ASAny> = null;
		var _loc15_:Array<ASAny> = null;
		var _loc16_ = 0;
		var _loc17_ = 0;
		var _loc18_ = 0;
		var _loc19_ = 0;
		var _loc20_ = 0;
		var _loc21_ = Math.NaN;
		var _loc22_ = false;
		this._group = group;
		var _loc3_ = 1;
		if (group.idle > 0) {
			_loc3_ = 0;
			if (!this._needRedraw) {
				return;
			}
		}
		if (this._needRedraw) {
			draw = true;
		}
		this._needRedraw = false;
		var _loc4_ = group.interests;
		var _loc5_ = Std.int(width - this.startOffset);
		var _loc6_ = Std.int(height - this.graph.y);
		var _loc7_ = group.low;
		var _loc8_ = group.hi;
		var _loc9_ = _loc8_ - _loc7_;
		var _loc10_ = false;
		if (draw) {
			group.inv ? this.highTxt : this.lowTxt.text = Std.string(group.low);
			group.inv ? this.lowTxt : this.highTxt.text = Std.string(group.hi);
			this.graph.graphics.clear();
		}
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc11_ = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
				this._interest = _loc11_;
				_loc13_ = this._interest.key;
				_loc14_ = ASCompat.dynamicAs(this._infoMap[_loc13_], Array);
				if (_loc14_ == null) {
					_loc10_ = true;
					_loc14_ = [ASCompat.toRadix(this._interest.col, (16 : UInt)), new Array<ASAny>()];
					this._infoMap[_loc13_] = _loc14_;
				}
				_loc15_ = ASCompat.dynamicAs(_loc14_[1], Array);
				if (_loc3_ == 1) {
					if (group.type == GraphGroup.FPS) {
						_loc17_ = Std.int(Math.ffloor(group.hi / this._interest.v));
						if (_loc17_ > 30) {
							_loc17_ = 30;
						}
						while (_loc17_ > 0) {
							_loc15_.push(this._interest.v);
							_loc17_ = ASCompat.toInt(_loc17_) - 1;
						}
					} else {
						_loc15_.push(this._interest.v);
					}
				}
				_loc16_ = Std.int(Math.ffloor(_loc5_) + 10);
				while (_loc15_.length > _loc16_) {
					_loc15_.shift();
				}
				if (draw) {
					_loc18_ = _loc15_.length;
					this.graph.graphics.lineStyle(1, (Std.int(this._interest.col) : UInt));
					_loc19_ = _loc5_ > _loc18_ ? _loc18_ : _loc5_;
					_loc20_ = 1;
					while (_loc20_ < _loc19_) {
						_loc21_ = (ASCompat.floatAsBool(_loc9_) ? ASCompat.toNumber(ASCompat.toNumber(_loc15_[ASCompat.toInt(_loc18_ - _loc20_)])
							- _loc7_) / _loc9_ : 0.5) * _loc6_;
						if (!group.inv) {
							_loc21_ = _loc6_ - _loc21_;
						}
						if (_loc21_ < 0) {
							_loc21_ = 0;
						}
						if (_loc21_ > _loc6_) {
							_loc21_ = _loc6_;
						}
						if (_loc20_ == 1) {
							this.graph.graphics.moveTo(width, _loc21_);
						}
						this.graph.graphics.lineTo(ASCompat.toNumber(_loc5_ - _loc20_), _loc21_);
						_loc20_ = ASCompat.toInt(_loc20_) + 1;
					}
					if (Math.isNaN(this._interest.avg) && ASCompat.floatAsBool(_loc9_)) {
						_loc21_ = (this._interest.avg - _loc7_) / _loc9_ * _loc6_;
						if (!group.inv) {
							_loc21_ = _loc6_ - _loc21_;
						}
						if (_loc21_ < 0) {
							_loc21_ = 0;
						}
						if (_loc21_ > _loc6_) {
							_loc21_ = _loc6_;
						}
						this.graph.graphics.lineStyle(1, (Std.int(this._interest.col) : UInt), 0.3);
						this.graph.graphics.moveTo(0, _loc21_);
						this.graph.graphics.lineTo(_loc5_, _loc21_);
					}
				}
			}
		final __ax4_iter_125:ASObject = this._infoMap;
		if (checkNullIteratee(__ax4_iter_125))
			for (_tmp_ in __ax4_iter_125.___keys()) {
				_loc12_ = _tmp_;
				if (checkNullIteratee(_loc4_))
					for (_tmp_ in _loc4_) {
						_loc11_ = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
						if (_loc11_.key == _loc12_) {
							_loc22_ = true;
						}
					}
				if (!_loc22_) {
					_loc10_ = true;
					ASCompat.deleteProperty(this._infoMap, _loc12_);
				}
			}
		if (draw && (_loc10_ || ASCompat.stringAsBool(this._type))) {
			this.updateKeyText();
		}
	}

	public function updateKeyText() {
		var __ax4_iter_126:ASObject;
		var _loc2_:String = null;
		var _loc1_ = "<r><low>";
		if (ASCompat.stringAsBool(this._type)) {
			if (Math.isNaN(this._interest.v)) {
				_loc1_ += "no input";
			} else if (this._type == FPS) {
				_loc1_ += ASCompat.toFixed(this._interest.avg, (1 : UInt));
			} else {
				_loc1_ += this._interest.v + "mb";
			}
		} else {
			__ax4_iter_126 = this._infoMap;
			if (checkNullIteratee(__ax4_iter_126))
				for (_tmp_ in __ax4_iter_126.___keys()) {
					_loc2_ = _tmp_;
					_loc1_ += " <font color=\'#" + Std.string(ASCompat.dynGetIndex(this._infoMap[_loc2_], 0)) + "\'>" + _loc2_ + "</font>";
				}
			_loc1_ += " |";
		}
		txtField.htmlText = _loc1_ + this._menuString;
		txtField.scrollH = txtField.maxScrollH;
	}

	function linkHandler(e:TextEvent) {
		cast(e.currentTarget, TextField).setSelection(0, 0);
		if (e.text == "reset") {
			this.reset();
		} else if (e.text == "close") {
			if (this._type == FPS) {
				console.fpsMonitor = false;
			} else if (this._type == MEM) {
				console.memoryMonitor = false;
			} else {
				this.stop();
			}
			console.panels.removeGraph(this._group);
		} else if (e.text == "gc") {
			console.gc();
		}
		e.stopPropagation();
	}

	function onMenuRollOver(e:TextEvent) {
		var _loc2_:String = ASCompat.stringAsBool(e.text) ? StringTools.replace(e.text, "event:", "") : null;
		if (_loc2_ == "gc") {
			_loc2_ = "Garbage collect::Requires debugger version of flash player";
		}
		console.panels.tooltip(_loc2_, this);
	}
}
