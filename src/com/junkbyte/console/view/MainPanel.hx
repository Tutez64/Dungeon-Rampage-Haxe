package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.compat.ConsoleLib;
import com.junkbyte.console.core.LogReferences;
import com.junkbyte.console.utils.FlashRegex;
import com.junkbyte.console.utils.RegexResult;
import com.junkbyte.console.vos.Log;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.net.FileReference;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class MainPanel extends ConsolePanel {
	public static var NAME:String = "mainPanel";

	public static var CL_HISTORY:String = "clhistory";

	public static var VIEWING_CH_HISTORY:String = "viewingChannels";

	public static var IGNORED_CH_HISTORY:String = "ignoredChannels";

	public static var PRIORITY_HISTORY:String = "priority";

	public var _viewingChannels:Array<ASAny>;

	public var _traceField:TextField;

	public var _shift:Bool = false;

	public var _selectionStart:Int = 0;

	public var _selectionEnd:Int = 0;

	public var _scrolling:Bool = false;

	public var _scroller:Sprite;

	public var _scrolldir:Int = 0;

	public var _scrolldelay:UInt = 0;

	public var _scrollHeight:Float = Math.NaN;

	public var _scroll:Sprite;

	public var _priority:Int = 0;

	public var _needUpdateTrace:Bool = false;

	public var _needUpdateMenu:Bool = false;

	public var _mini:Bool = false;

	public var _lockScrollUpdate:Bool = false;

	public var _ignoredChannels:Array<ASAny>;

	public var _hintField:TextField;

	public var _hint:String;

	public var _filterText:String;

	public var _filterRegExp:EReg;

	public var _extraMenus:IMap<ASAny, ASAny>;

	public var _enteringLogin:Bool = false;

	public var _ctrl:Bool = false;

	public var _cmdsInd:Int = 0;

	public var _cmdsHistory:Array<ASAny>;

	public var _cmdPrefx:TextField;

	public var _cmdField:TextField;

	public var _cmdBG:Shape;

	public var _clScope:String;

	public var _bottomLine:Shape;

	public var _atBottom:Bool = false;

	public var _alt:Bool = false;

	public function new(m:Console = /*undefined*/ null) {
		var _loc4_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		_cmdsHistory = null;
		_hint = null;
		_enteringLogin = false;
		_atBottom = true;
		_lockScrollUpdate = false;
		_needUpdateTrace = false;
		_needUpdateMenu = false;
		_clScope = "";
		_filterText = null;
		_priority = 0;
		_cmdsInd = -1;
		_extraMenus = new StringMap<ASAny>();
		_ignoredChannels = null;
		_viewingChannels = null;
		_selectionEnd = 0;
		_selectionStart = 0;
		_scrollHeight = 0;
		_scrolling = false;
		_scrolldir = 0;
		_scrolldelay = (0 : UInt);
		_scroller = null;
		_scroll = null;
		_alt = false;
		_ctrl = false;
		_shift = false;
		_mini = false;
		_bottomLine = null;
		_cmdBG = null;
		_hintField = null;
		_cmdField = null;
		_cmdPrefx = null;
		_traceField = null;
		super(m);
		var _loc2_ = get_style().menuFontSize;
		console.get_cl().addCLCmd("filter", setFilterText, "Filter console logs to matching string. When done, click on the * (global channel) at top.", true);
		console.get_cl().addCLCmd("filterexp", setFilterRegExp, "Filter console logs to matching regular expression", true);
		console.get_cl().addCLCmd("clearhistory", clearCommandLineHistory, "Clear history of commands you have entered.", true);
		name = "mainPanel";
		minWidth = 50;
		minHeight = 18;
		_traceField = makeTF("traceField");
		_traceField.wordWrap = true;
		_traceField.multiline = true;
		_traceField.y = _loc2_;
		_traceField.addEventListener(Event.SCROLL, onTraceScroll);
		addChild(_traceField);
		txtField = makeTF("menuField");
		txtField.wordWrap = true;
		txtField.multiline = true;
		txtField.autoSize = TextFieldAutoSize.RIGHT;
		txtField.height = _loc2_ + 6;
		txtField.y = -2;
		registerTFRoller(txtField, onMenuRollOverEvent);
		addChild(txtField);
		_cmdBG = new Shape();
		_cmdBG.name = "commandBackground";
		_cmdBG.graphics.beginFill(get_style().commandLineColor, 0.1);
		_cmdBG.graphics.drawRoundRect(0, 0, 100, 18, _loc2_, _loc2_);
		_cmdBG.scale9Grid = new Rectangle(9, 9, 80, 1);
		addChild(_cmdBG);
		var _loc3_ = new TextFormat(get_style().menuFont, get_style().menuFontSize, ASCompat.toInt(get_style().highColor));
		_cmdField = new TextField();
		_cmdField.name = "commandField";
		_cmdField.type = TextFieldType.INPUT;
		_cmdField.x = 40;
		_cmdField.height = _loc2_ + 6;
		_cmdField.addEventListener(KeyboardEvent.KEY_DOWN, commandKeyDown);
		_cmdField.addEventListener(KeyboardEvent.KEY_UP, commandKeyUp);
		_cmdField.addEventListener(FocusEvent.FOCUS_IN, updateCmdHint);
		_cmdField.addEventListener(FocusEvent.FOCUS_OUT, onCmdFocusOut);
		_cmdField.defaultTextFormat = _loc3_;
		addChild(_cmdField);
		_hintField = makeTF("hintField", true);
		_hintField.mouseEnabled = false;
		_hintField.x = _cmdField.x;
		_hintField.autoSize = TextFieldAutoSize.LEFT;
		addChild(_hintField);
		setHints();
		_loc3_.color = get_style().commandLineColor;
		_cmdPrefx = new TextField();
		_cmdPrefx.name = "commandPrefx";
		_cmdPrefx.type = TextFieldType.DYNAMIC;
		_cmdPrefx.x = 2;
		_cmdPrefx.height = _loc2_ + 6;
		_cmdPrefx.selectable = false;
		_cmdPrefx.defaultTextFormat = _loc3_;
		_cmdPrefx.addEventListener(MouseEvent.MOUSE_DOWN, onCmdPrefMouseDown);
		_cmdPrefx.addEventListener(MouseEvent.MOUSE_MOVE, onCmdPrefRollOverOut);
		_cmdPrefx.addEventListener(MouseEvent.ROLL_OUT, onCmdPrefRollOverOut);
		addChild(_cmdPrefx);
		_bottomLine = new Shape();
		_bottomLine.name = "blinkLine";
		_bottomLine.alpha = 0.2;
		addChild(_bottomLine);
		_scroll = new Sprite();
		_scroll.name = "scroller";
		_scroll.tabEnabled = false;
		_scroll.y = _loc2_ + 4;
		_scroll.buttonMode = true;
		_scroll.addEventListener(MouseEvent.MOUSE_DOWN, onScrollbarDown, false, 0, true);
		_scroller = new Sprite();
		_scroller.name = "scrollbar";
		_scroller.tabEnabled = false;
		_scroller.y = get_style().controlSize;
		_scroller.graphics.beginFill(get_style().controlColor, 1);
		_scroller.graphics.drawRect(-get_style().controlSize, 0, get_style().controlSize, 30);
		_scroller.graphics.beginFill((0 : UInt), 0);
		_scroller.graphics.drawRect(-get_style().controlSize * 2, 0, get_style().controlSize * 2, 30);
		_scroller.graphics.endFill();
		_scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown, false, 0, true);
		_scroll.addChild(_scroller);
		addChild(_scroll);
		_cmdField.visible = false;
		_cmdPrefx.visible = false;
		_cmdBG.visible = false;
		updateCLScope("");
		init(640, 100, true);
		registerDragger(txtField);
		if (Std.isOfType(Reflect.field(console.get_so(), "clhistory"), Array)) {
			_cmdsHistory = ASCompat.coerce(Reflect.field(console.get_so(), "clhistory"), Array);
		} else {
			console.get_so()["clhistory"] = _cmdsHistory = [];
		}
		if (get_config().rememberFilterSettings && Std.isOfType(Reflect.field(console.get_so(), "viewingChannels"), Array)) {
			_viewingChannels = ASCompat.coerce(Reflect.field(console.get_so(), "viewingChannels"), Array);
		} else {
			console.get_so()["viewingChannels"] = _viewingChannels = [];
		}
		if (get_config().rememberFilterSettings && Std.isOfType(Reflect.field(console.get_so(), "ignoredChannels"), Array)) {
			_ignoredChannels = ASCompat.coerce(Reflect.field(console.get_so(), "ignoredChannels"), Array);
		}
		if (_viewingChannels.length > 0 || _ignoredChannels == null) {
			console.get_so()["ignoredChannels"] = _ignoredChannels = [];
		}
		if (get_config().rememberFilterSettings && Std.isOfType(Reflect.field(console.get_so(), "priority"), Int)) {
			_priority = ASCompat.toInt(Reflect.field(console.get_so(), "priority"));
		}
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
		addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
		addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle, false, 0, true);
		addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle, false, 0, true);
	}

	public function updateTraceFHeight() {
		var _loc1_ = _mini || !get_style().topMenu;
		_traceField.y = _loc1_ ? 0 : txtField.y + txtField.height - 6;
		_traceField.height = Math.max(0, get_height() - (_cmdField.visible ? get_style().menuFontSize + 4 : 0) - _traceField.y);
	}

	public function updateToBottom() {
		_atBottom = true;
		_needUpdateTrace = true;
	}

	public function updateScroller() {
		if (_traceField.maxScrollV <= 1) {
			_scroll.visible = false;
		} else {
			_scroll.visible = true;
			if (_atBottom) {
				set_scrollPercent(1);
			} else {
				set_scrollPercent((_traceField.scrollV - 1) / (_traceField.maxScrollV - 1));
			}
		}
	}

	public function updateMenu(instant:Bool = false) {
		if (instant) {
			_updateMenu();
		} else {
			_needUpdateMenu = true;
		}
	}

	public function updateFull() {
		var _loc1_ = "";
		var _loc2_ = console.get_logs().first;
		var _loc3_ = _viewingChannels.length != 1;
		var _loc4_ = _priority == 0 && _viewingChannels.length == 0;
		while (_loc2_ != null) {
			if (_loc4_ || lineShouldShow(_loc2_)) {
				_loc1_ += makeLine(_loc2_, _loc3_);
			}
			_loc2_ = _loc2_.next;
		}
		_lockScrollUpdate = true;
		_traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
		_lockScrollUpdate = false;
		updateScroller();
	}

	public function updateCmdHint(e:Event = /*undefined*/ null) {
		var _loc4_ = ASCompat.dynamicAs(null, Error);
		var _loc3_ = _cmdField.text;
		if (_loc3_ != null
			&& _loc3_ != ""
			&& get_config().commandLineAutoCompleteEnabled
			&& console.get_remoter().get_remoting() != 2) {
			try {
				setHints(console.get_cl().getHintsFor(_loc3_, 10));
				return;
			} catch (_loc_e_:Dynamic) {
				_loc4_ = ASCompat.asError(_loc_e_);
			}
		}
		setHints();
	}

	public function updateCLSize() {
		var _loc1_ = get_width() - 48;
		if (_cmdPrefx.width > 120 || _cmdPrefx.width > _loc1_) {
			_cmdPrefx.autoSize = TextFieldAutoSize.NONE;
			_cmdPrefx.width = _loc1_ > 120 ? 120 : _loc1_;
			_cmdPrefx.scrollH = _cmdPrefx.maxScrollH;
		}
		_cmdField.x = _cmdPrefx.width + 2;
		_cmdField.width = get_width() - 15 - _cmdField.x;
		_hintField.x = _cmdField.x;
	}

	public function updateCLScope(str:String) {
		if (_enteringLogin) {
			_enteringLogin = false;
			requestLogin(false);
		}
		_cmdPrefx.autoSize = TextFieldAutoSize.LEFT;
		_cmdPrefx.text = str;
		updateCLSize();
	}

	public function updateBottom() {
		var _loc6_ = 0;
		var _loc1_ = "";
		var _loc2_ = ASCompat.floatToInt(Math.fround(_traceField.height / get_style().traceFontSize));
		var _loc3_ = Math.round(_traceField.width * 5 / get_style().traceFontSize);
		var _loc4_ = console.get_logs().last;
		var _loc5_ = _viewingChannels.length != 1;
		while (_loc4_ != null) {
			if (lineShouldShow(_loc4_)) {
				_loc6_ = Math.ceil(_loc4_.text.length / _loc3_);
				if (!(_loc4_.html || _loc2_ >= _loc6_)) {
					_loc4_ = _loc4_.clone();
					_loc4_.text = _loc4_.text.substring(ASCompat.floatToInt(Math.max(0, _loc4_.text.length - _loc3_ * _loc2_)));
					_loc1_ = makeLine(_loc4_, _loc5_) + _loc1_;
					break;
				}
				_loc1_ = makeLine(_loc4_, _loc5_) + _loc1_;
				_loc2_ -= _loc6_;
				if (_loc2_ <= 0) {
					break;
				}
			}
			_loc4_ = _loc4_.prev;
		}
		_lockScrollUpdate = true;
		_traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
		_traceField.scrollV = _traceField.maxScrollV;
		_lockScrollUpdate = false;
		updateScroller();
	}

	public function update(changed:Bool) {
		var __tmpAssignObj73:Shape;
		var _loc2_ = ASCompat.dynamicAs(null, Shape);
		if (_bottomLine.alpha > 0) {
			_loc2_ = _bottomLine;
			__tmpAssignObj73 = _loc2_;
			ASCompat.setProperty(__tmpAssignObj73, "alpha", __tmpAssignObj73.alpha - 0.25);
		}
		if (get_style().showCommandLineScope) {
			if (_clScope != console.get_cl().get_scopeString()) {
				_clScope = console.get_cl().get_scopeString();
				updateCLScope(_clScope);
			}
		} else if (_clScope != null) {
			_clScope = "";
			updateCLScope("");
		}
		if (changed) {
			_bottomLine.alpha = 1;
			_needUpdateMenu = true;
			_needUpdateTrace = true;
		}
		if (_needUpdateTrace) {
			_needUpdateTrace = false;
			_updateTraces(true);
		}
		if (_needUpdateMenu) {
			_needUpdateMenu = false;
			_updateMenu();
		}
	}

	public function toggleCHList(current:Array<ASAny>, chn:String):Array<ASAny> {
		current = current.concat([]);
		var _loc3_ = current.indexOf(chn);
		if (_loc3_ >= 0) {
			current.splice(_loc3_, (1 : UInt));
			if (current.length == 0) {
				current.push(" * ");
			}
		} else {
			current.push(chn);
		}
		return current;
	}

	public function startFilter() {
		console.clear("~");
		console.get_logs().addChannel("~");
		if (["~"].length == 0) {
			setViewingChannels();
		} else if (["~"].length == 1) {
			setViewingChannels(["~"][0]);
		} else if (["~"].length == 2) {
			setViewingChannels(["~"][0], ["~"][1]);
		} else if (["~"].length == 3) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2]);
		} else if (["~"].length == 4) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3]);
		} else if (["~"].length == 5) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4]);
		} else if (["~"].length == 6) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5]);
		} else if (["~"].length == 7) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6]);
		} else if (["~"].length == 8) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7]);
		} else if (["~"].length == 9) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8]);
		} else if (["~"].length == 10) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9]);
		} else if (["~"].length == 11) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10]);
		} else if (["~"].length == 12) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11]);
		} else if (["~"].length == 13) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12]);
		} else if (["~"].length == 14) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13]);
		} else if (["~"].length == 15) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14]);
		} else if (["~"].length == 16) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14], ["~"][15]);
		} else if (["~"].length == 17) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14], ["~"][15], ["~"][16]);
		} else if (["~"].length == 18) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14], ["~"][15], ["~"][16], ["~"][17]);
		} else if (["~"].length == 19) {
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14], ["~"][15], ["~"][16], ["~"][17], ["~"][18]);
		} else {
			if (["~"].length != 20) {
				throw "Too many rest arguments";
			}
			setViewingChannels(["~"][0], ["~"][1], ["~"][2], ["~"][3], ["~"][4], ["~"][5], ["~"][6], ["~"][7], ["~"][8], ["~"][9], ["~"][10], ["~"][11],
				["~"][12], ["~"][13], ["~"][14], ["~"][15], ["~"][16], ["~"][17], ["~"][18], ["~"][19]);
		}
	}

	public function stageRemovedHandle(e:Event = /*undefined*/ null) {
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true);
		stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	}

	public function stageAddedHandle(e:Event = /*undefined*/ null) {
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, true, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
	}

	override public function set_width(value:Float):Float {
		_lockScrollUpdate = true;
		super.set_width(value);
		_traceField.width = value - 4;
		txtField.width = value - 6;
		_cmdField.width = get_width() - 15 - _cmdField.x;
		_cmdBG.width = value;
		_bottomLine.graphics.clear();
		_bottomLine.graphics.lineStyle(1, get_style().controlColor);
		_bottomLine.graphics.moveTo(10, -1);
		_bottomLine.graphics.lineTo(value - 10, -1);
		_scroll.x = value;
		_atBottom = true;
		updateCLSize();
		_needUpdateMenu = true;
		_needUpdateTrace = true;
		_lockScrollUpdate = false;
		return value;
	}

	public function set_scrollPercent(per:Float):Float {
		_scroller.y = get_style().controlSize + (_scrollHeight - 30 - get_style().controlSize * 2) * per;
		return per;
	}

	@:isVar public var priority(get, set):UInt;

	public function set_priority(p:UInt):UInt {
		_priority = (p : Int);
		console.get_so()["priority"] = _priority;
		updateToBottom();
		updateMenu();
		return p;
	}

	override public function set_height(value:Float):Float {
		_lockScrollUpdate = true;
		var _loc2_ = get_style().menuFontSize;
		var _loc3_:Float = _loc2_ + 6 + get_style().traceFontSize;
		if (get_height() != value) {
			_mini = value < (_cmdField.visible ? _loc3_ + _loc2_ + 4 : _loc3_);
		}
		super.set_height(value);
		var _loc4_ = _mini || !get_style().topMenu;
		updateTraceFHeight();
		_traceField.y = _loc4_ ? 0 : _loc2_;
		_traceField.height = value - (_cmdField.visible ? _loc2_ + 4 : 0) - (_loc4_ ? 0 : _loc2_);
		var _loc5_ = value - (_loc2_ + 6);
		_cmdField.y = _loc5_;
		_cmdPrefx.y = _loc5_;
		_hintField.y = _cmdField.y - _hintField.height;
		_cmdBG.y = _loc5_;
		_bottomLine.y = _cmdField.visible ? _loc5_ : value;
		_scroll.y = _loc4_ ? 6 : _loc2_ + 4;
		var _loc6_ = get_style().controlSize;
		_scrollHeight = _bottomLine.y - (_cmdField.visible ? 0 : _loc6_ * 2) - _scroll.y;
		_scroller.visible = _scrollHeight > 40;
		_scroll.graphics.clear();
		if (_scrollHeight >= 10) {
			_scroll.graphics.beginFill(get_style().controlColor, 0.7);
			_scroll.graphics.drawRect(-_loc6_, 0, _loc6_, _loc6_);
			_scroll.graphics.drawRect(-_loc6_, _scrollHeight - _loc6_, _loc6_, _loc6_);
			_scroll.graphics.beginFill(get_style().controlColor, 0.25);
			_scroll.graphics.drawRect(-_loc6_, _loc6_, _loc6_, _scrollHeight - _loc6_ * 2);
			_scroll.graphics.beginFill((0 : UInt), 0);
			_scroll.graphics.drawRect(-_loc6_ * 2, _loc6_ * 2, _loc6_ * 2, _scrollHeight - _loc6_ * 2);
			_scroll.graphics.endFill();
		}
		_atBottom = true;
		_needUpdateTrace = true;
		_lockScrollUpdate = false;
		return value;
	}

	@:isVar public var commandLine(get, set):Bool;

	public function set_commandLine(b:Bool):Bool {
		if (b) {
			_cmdField.visible = true;
			_cmdPrefx.visible = true;
			_cmdBG.visible = true;
		} else {
			_cmdField.visible = false;
			_cmdPrefx.visible = false;
			_cmdBG.visible = false;
		}
		_needUpdateMenu = true;
		var _loc2_ = get_height();
		set_height(_loc2_);
		return b;
	}

	public function setViewingChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc4_ = 0;
		var _loc6_:ASAny = null;
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc3_:Array<ASAny> = [];
		_loc4_ = 0;
		var _loc5_ = rest;
		while (_loc4_ < _loc5_.length) {
			_loc6_ = _loc5_[_loc4_++];
			_loc3_.push(Console.MakeChannelName(_loc6_));
		}
		if (_viewingChannels[0] == "⌂" && (_loc3_ == null || _loc3_[0] != _viewingChannels[0])) {
			console.get_refs().exitFocus();
		}
		_ignoredChannels.splice(0, (_ignoredChannels.length : UInt));
		_viewingChannels.splice(0, (_viewingChannels.length : UInt));
		if (_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.length) {
				_loc7_ = _loc3_[_loc4_];
				_loc4_++;
				if (_loc7_ != null) {
					_viewingChannels.push(_loc7_);
				}
			}
		}
		updateToBottom();
		console.get_panels().updateMenu();
	}

	public function setPaused(b:Bool) {
		if (b && _atBottom) {
			_atBottom = false;
			_updateTraces();
			_traceField.scrollV = _traceField.maxScrollV;
		} else if (!b) {
			_atBottom = true;
			updateBottom();
		}
		updateMenu();
	}

	public function setIgnoredChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc4_ = 0;
		var _loc6_:ASAny = null;
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc3_:Array<ASAny> = [];
		_loc4_ = 0;
		var _loc5_ = rest;
		while (_loc4_ < _loc5_.length) {
			_loc6_ = _loc5_[_loc4_++];
			_loc3_.push(Console.MakeChannelName(_loc6_));
		}
		if (_viewingChannels[0] == "⌂") {
			console.get_refs().exitFocus();
		}
		_ignoredChannels.splice(0, (_ignoredChannels.length : UInt));
		_viewingChannels.splice(0, (_viewingChannels.length : UInt));
		if (_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.length) {
				_loc7_ = _loc3_[_loc4_];
				_loc4_++;
				if (_loc7_ != null) {
					_ignoredChannels.push(_loc7_);
				}
			}
		}
		updateToBottom();
		console.get_panels().updateMenu();
	}

	public function setHints(hints:Array<ASAny> = /*undefined*/ null) {
		var _loc2_:ASAny = ASCompat.asString(null);
		var _loc3_ = false;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc6_ = 0;
		var _loc7_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc8_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc9_ = ASCompat.dynamicAs(null, Rectangle);
		if (hints != null && hints.length != 0) {
			_hint = ASCompat.dynGetIndex(hints[0], 0);
			if (hints.length > 1) {
				_loc2_ = ASCompat.dynGetIndex(hints[1], 0);
				_loc3_ = false;
				_loc4_ = 0;
				_loc5_ = ASCompat.toInt(_loc2_.length);
				while (_loc4_ < _loc5_) {
					_loc6_ = _loc4_++;
					if (Std.string(_loc2_).charAt(_loc6_) != _hint.charAt(_loc6_)) {
						if (_loc3_ && _cmdField.text.length < _loc6_) {
							_hint = _hint.substring(0, _loc6_);
						}
						break;
					}
					_loc3_ = true;
				}
			}
			_loc7_ = [];
			_loc4_ = 0;
			while (_loc4_ < hints.length) {
				_loc8_ = hints[_loc4_];
				_loc4_++;
				_loc7_.push("<p3>" + Std.string(_loc8_[0]) + "</p3> <p0>" + Std.string((_loc8_[1] != null ? _loc8_[1] : "")) + "</p0>");
			}
			ASCompat.ASArray.reverse(_loc7_);
			_hintField.htmlText = "<p>" + Std.string(_loc7_.join("\n")) + "</p>";
			_hintField.visible = true;
			_loc9_ = _cmdField.getCharBoundaries(_cmdField.text.length - 1);
			if (_loc9_ == null) {
				_loc9_ = new Rectangle();
			}
			_hintField.x = ASCompat.toNumber(_cmdField.x + _loc9_.x + _loc9_.width + 30);
			_hintField.y = get_height() - _hintField.height;
		} else {
			_hintField.visible = false;
			_hint = null;
		}
	}

	public function setFilterText(str:String = /*undefined*/ null) {
		if (str == null) {
			str = "";
		}
		if (str != null && str != "") {
			_filterRegExp = null;
			_filterText = LogReferences.EscHTML(str.toLowerCase());
			startFilter();
		} else {
			endFilter();
		}
	}

	public function setFilterRegExp(expstr:String = /*undefined*/ null) {
		if (expstr == null) {
			expstr = "";
		}
		if (expstr != null && expstr != "") {
			_filterText = null;
			_filterRegExp = new EReg(LogReferences.EscHTML(expstr), "gi");
			startFilter();
		} else {
			endFilter();
		}
	}

	public function setCLSelectionAtEnd() {
		_cmdField.setSelection(_cmdField.text.length, _cmdField.text.length);
	}

	public function requestLogin(on:Bool = true) {
		var _loc2_ = new ColorTransform();
		if (on) {
			console.set_commandLine(true);
			console.report("//", -2);
			console.report("// <b>Enter remoting password</b> in CommandLine below...", -2);
			updateCLScope("Password");
			_loc2_.color = get_style().controlColor;
			_cmdBG.transform.colorTransform = _loc2_;
			_traceField.transform.colorTransform = new ColorTransform(0.7, 0.7, 0.7);
		} else {
			updateCLScope("");
			_cmdBG.transform.colorTransform = _loc2_;
			_traceField.transform.colorTransform = _loc2_;
		}
		_cmdField.displayAsPassword = on;
		_enteringLogin = on;
	}

	public function onTraceScroll(e:Event = /*undefined*/ null) {
		var _loc3_ = 0;
		if (_lockScrollUpdate || _shift) {
			return;
		}
		var _loc2_ = _traceField.scrollV >= _traceField.maxScrollV;
		if (!console.get_paused() && _atBottom != _loc2_) {
			_loc3_ = _traceField.maxScrollV - _traceField.scrollV;
			_selectionStart = _traceField.text.length - _traceField.selectionBeginIndex;
			_selectionEnd = _traceField.text.length - _traceField.selectionEndIndex;
			_atBottom = _loc2_;
			_updateTraces();
			_traceField.scrollV = _traceField.maxScrollV - _loc3_;
		}
		updateScroller();
	}

	public function onStageMouseDown(e:MouseEvent) {
		_shift = e.shiftKey;
		_ctrl = e.ctrlKey;
		_alt = e.altKey;
	}

	public function onScrollerUp(e:MouseEvent) {
		_scroller.stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
		_scrolling = false;
		onTraceScroll();
	}

	public function onScrollerMove(e:MouseEvent) {
		_lockScrollUpdate = true;
		_traceField.scrollV = ASCompat.floatToInt(Math.fround(get_scrollPercent() * (_traceField.maxScrollV - 1) + 1));
		_lockScrollUpdate = false;
	}

	public function onScrollerDown(e:MouseEvent) {
		var _loc2_ = Math.NaN;
		_scrolling = true;
		if (!console.get_paused() && _atBottom) {
			_atBottom = false;
			_loc2_ = get_scrollPercent();
			_updateTraces();
			set_scrollPercent(_loc2_);
		}
		_scroller.startDrag(false, new Rectangle(0, get_style().controlSize, 0, _scrollHeight - 30 - get_style().controlSize * 2));
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp, false, 0, true);
		e.stopPropagation();
	}

	public function onScrollbarDown(e:MouseEvent) {
		if (_scroller.visible && _scroller.mouseY > 0 || !_scroller.visible && _scroll.mouseY > _scrollHeight / 2) {
			_scrolldir = 3;
		} else {
			_scrolldir = -3;
		}
		var _loc2_ = _traceField;
		_loc2_.scrollV += _scrolldir;
		_scrolldelay = (0 : UInt);
		addEventListener(Event.ENTER_FRAME, onScrollBarFrame, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, onScrollBarUp, false, 0, true);
	}

	public function onScrollBarUp(e:Event) {
		removeEventListener(Event.ENTER_FRAME, onScrollBarFrame);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
	}

	public function onScrollBarFrame(e:Event) {
		var __tmpAssignObj74:TextField;
		var _loc2_ = ASCompat.dynamicAs(null, TextField);
		++_scrolldelay;
		if (_scrolldelay > 10) {
			_scrolldelay = (9 : UInt);
			if (_scrolldir < 0 && _scroller.y > _scroll.mouseY || _scrolldir > 0 && _scroller.y + _scroller.height < _scroll.mouseY) {
				_loc2_ = _traceField;
				__tmpAssignObj74 = _loc2_;
				ASCompat.setProperty(__tmpAssignObj74, "scrollV", __tmpAssignObj74.scrollV + _scrolldir);
			}
		}
	}

	public function onMouseWheel(e:MouseEvent) {
		var _loc2_ = 0;
		if (_shift) {
			_loc2_ = console.get_config().get_style().traceFontSize + (e.delta > 0 ? 1 : -1);
			if (_loc2_ > 10 && _loc2_ < 20) {
				console.get_config().get_style().traceFontSize = _loc2_;
				console.get_config().get_style().updateStyleSheet();
				updateToBottom();
				e.stopPropagation();
			}
		}
	}

	public function onMenuRollOverEvent(e:TextEvent) {
		onMenuRollOver(e);
	}

	public function onMenuRollOver(e:TextEvent, src:ConsolePanel = /*undefined*/ null) {
		var _loc4_ = ASCompat.dynamicAs(null, IMap);
		var _loc5_ = ASCompat.asString(null);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, StringMap);
		var _loc7_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc8_:ASObject = null;
		if (src == null) {
			src = this;
		}
		var _loc3_ = e.text != null ? StringTools.replace(e.text, "event:", "") : "";
		if (_loc3_ == "channel_" + " * ") {
			_loc3_ = "View all channels";
		} else if (_loc3_ == "channel_" + "-") {
			_loc3_ = "Default channel::Logs with no channel";
		} else if (_loc3_ == "channel_" + "C") {
			_loc3_ = "Console\'s channel::Logs generated from Console";
		} else if (_loc3_ == "channel_" + "~") {
			_loc3_ = _filterRegExp != null ? ConsoleLib.string(_filterRegExp.r) : _filterText;
			_loc3_ = "Filtering channel" + "::*" + _loc3_ + "*";
		} else if (_loc3_ == "channel_" + "⌂") {
			_loc3_ = "Inspecting channel";
		} else if (_loc3_.indexOf("channel_") == 0) {
			_loc3_ = "Change channel::shift: select multiple\nctrl: ignore channel";
		} else if (_loc3_ == "pause") {
			if (console.get_paused()) {
				_loc3_ = "Resume updates";
			} else {
				_loc3_ = "Pause updates";
			}
		} else if (_loc3_ == "close" && src == this) {
			_loc3_ = "Close::Type password to show again";
		} else if (_loc3_.indexOf("external_") == 0) {
			_loc4_ = _extraMenus;
			_loc5_ = _loc3_.substring(9);
			_loc6_ = _loc4_;
			_loc7_ = _loc6_.get(_loc5_);
			if (_loc7_ != null) {
				_loc3_ = _loc7_[2];
			}
		} else {
			_loc8_ = {
				"fps": "Frames Per Second",
				"mm": "Memory Monitor",
				"roller": "Display Roller::Map the display list under your mouse",
				"ruler": "Screen Ruler::Measure the distance and angle between two points on screen.",
				"command": "Command Line",
				"copy": "Save to clipboard::shift: no channel name\nctrl: use viewing filters\nalt: save to file",
				"clear": "Clear log",
				"priority": "Priority filter::shift: previous priority\n(skips unused priorites)",
				"channels": "Expand channels",
				"close": "Close"
			};
			_loc3_ = Reflect.field(_loc8_, _loc3_);
		}
		console.get_panels().tooltip(_loc3_, src);
	}

	public function onCmdPrefRollOverOut(e:MouseEvent) {
		console.get_panels().tooltip(e.type == MouseEvent.MOUSE_MOVE ? "Current scope::(CommandLine)" : "", this);
	}

	public function onCmdPrefMouseDown(e:MouseEvent) {
		var _loc3_ = ASCompat.dynamicAs(null, Error);
		try {
			stage.focus = _cmdField;
			setCLSelectionAtEnd();
		} catch (_loc_e_:Dynamic) {
			_loc3_ = ASCompat.asError(_loc_e_);
		}
	}

	public function onCmdFocusOut(e:Event) {
		setHints();
	}

	public function onChannelPressed(chn:String) {
		var _loc2_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		if (_ctrl && chn != " * ") {
			_loc2_ = toggleCHList(_ignoredChannels, chn);
			if (ASCompat.toInt(_loc2_.length) == 0) {
				setIgnoredChannels();
			} else if (ASCompat.toInt(_loc2_.length) == 1) {
				setIgnoredChannels(_loc2_[0]);
			} else if (ASCompat.toInt(_loc2_.length) == 2) {
				setIgnoredChannels(_loc2_[0], _loc2_[1]);
			} else if (ASCompat.toInt(_loc2_.length) == 3) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2]);
			} else if (ASCompat.toInt(_loc2_.length) == 4) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3]);
			} else if (ASCompat.toInt(_loc2_.length) == 5) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4]);
			} else if (ASCompat.toInt(_loc2_.length) == 6) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5]);
			} else if (ASCompat.toInt(_loc2_.length) == 7) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6]);
			} else if (ASCompat.toInt(_loc2_.length) == 8) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7]);
			} else if (ASCompat.toInt(_loc2_.length) == 9) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8]);
			} else if (ASCompat.toInt(_loc2_.length) == 10) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9]);
			} else if (ASCompat.toInt(_loc2_.length) == 11) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10]);
			} else if (ASCompat.toInt(_loc2_.length) == 12) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11]);
			} else if (ASCompat.toInt(_loc2_.length) == 13) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12]);
			} else if (ASCompat.toInt(_loc2_.length) == 14) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13]);
			} else if (ASCompat.toInt(_loc2_.length) == 15) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14]);
			} else if (ASCompat.toInt(_loc2_.length) == 16) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15]);
			} else if (ASCompat.toInt(_loc2_.length) == 17) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16]);
			} else if (ASCompat.toInt(_loc2_.length) == 18) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17]);
			} else if (ASCompat.toInt(_loc2_.length) == 19) {
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17], _loc2_[18]);
			} else {
				if (ASCompat.toInt(_loc2_.length) != 20) {
					throw "Too many rest arguments";
				}
				setIgnoredChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17], _loc2_[18], _loc2_[19]);
			}
		} else if (_shift && chn != " * " && _viewingChannels[0] != "⌂") {
			_loc2_ = toggleCHList(_viewingChannels, chn);
			if (ASCompat.toInt(_loc2_.length) == 0) {
				setViewingChannels();
			} else if (ASCompat.toInt(_loc2_.length) == 1) {
				setViewingChannels(_loc2_[0]);
			} else if (ASCompat.toInt(_loc2_.length) == 2) {
				setViewingChannels(_loc2_[0], _loc2_[1]);
			} else if (ASCompat.toInt(_loc2_.length) == 3) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2]);
			} else if (ASCompat.toInt(_loc2_.length) == 4) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3]);
			} else if (ASCompat.toInt(_loc2_.length) == 5) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4]);
			} else if (ASCompat.toInt(_loc2_.length) == 6) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5]);
			} else if (ASCompat.toInt(_loc2_.length) == 7) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6]);
			} else if (ASCompat.toInt(_loc2_.length) == 8) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7]);
			} else if (ASCompat.toInt(_loc2_.length) == 9) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8]);
			} else if (ASCompat.toInt(_loc2_.length) == 10) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9]);
			} else if (ASCompat.toInt(_loc2_.length) == 11) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10]);
			} else if (ASCompat.toInt(_loc2_.length) == 12) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11]);
			} else if (ASCompat.toInt(_loc2_.length) == 13) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12]);
			} else if (ASCompat.toInt(_loc2_.length) == 14) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13]);
			} else if (ASCompat.toInt(_loc2_.length) == 15) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14]);
			} else if (ASCompat.toInt(_loc2_.length) == 16) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15]);
			} else if (ASCompat.toInt(_loc2_.length) == 17) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16]);
			} else if (ASCompat.toInt(_loc2_.length) == 18) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17]);
			} else if (ASCompat.toInt(_loc2_.length) == 19) {
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17], _loc2_[18]);
			} else {
				if (ASCompat.toInt(_loc2_.length) != 20) {
					throw "Too many rest arguments";
				}
				setViewingChannels(_loc2_[0], _loc2_[1], _loc2_[2], _loc2_[3], _loc2_[4], _loc2_[5], _loc2_[6], _loc2_[7], _loc2_[8], _loc2_[9], _loc2_[10],
					_loc2_[11], _loc2_[12], _loc2_[13], _loc2_[14], _loc2_[15], _loc2_[16], _loc2_[17], _loc2_[18], _loc2_[19]);
			}
		} else {
			console.setViewingChannels(chn);
		}
	}

	public function makeLine(line:Log, showch:Bool):String {
		var _loc3_ = "<p>";
		if (showch) {
			_loc3_ += line.chStr;
		}
		if (get_config().showLineNumber) {
			_loc3_ += line.lineStr;
		}
		if (get_config().showTimestamp) {
			_loc3_ += line.timeStr;
		}
		var _loc4_ = "p" + line.priority;
		return _loc3_ + "<" + _loc4_ + ">" + addFilterText(line.text) + "</" + _loc4_ + "></p>";
	}

	public function linkHandler(e:TextEvent) {
		var _loc4_ = Math.NaN;
		var _loc5_:ASAny = null;
		var _loc6_ = ASCompat.asString(null);
		var _loc7_ = ASCompat.dynamicAs(null, FileReference);
		var _loc8_ = ASCompat.dynamicAs(null, Error);
		var _loc9_ = 0;
		var _loc10_ = ASCompat.dynamicAs(null, IMap);
		var _loc11_:ASAny = ASCompat.dynamicAs(null, StringMap);
		var _loc12_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		txtField.setSelection(0, 0);
		stopDrag();
		var _loc3_ = e.text;
		if (_loc3_ == "pause") {
			if (console.get_paused()) {
				console.set_paused(false);
			} else {
				console.set_paused(true);
			}
			console.get_panels().tooltip(null);
		} else if (_loc3_ == "hide") {
			console.get_panels().tooltip();
			_mini = true;
			console.get_config().get_style().topMenu = false;
			_loc4_ = get_height();
			set_height(_loc4_);
			updateMenu();
		} else if (_loc3_ == "show") {
			console.get_panels().tooltip();
			_mini = false;
			console.get_config().get_style().topMenu = true;
			_loc4_ = get_height();
			set_height(_loc4_);
			updateMenu();
		} else if (_loc3_ == "close") {
			console.get_panels().tooltip();
			set_visible(false);
			dispatchEvent(new Event(Event.CLOSE));
		} else if (_loc3_ == "channels") {
			console.get_panels().set_channelsPanel(!console.get_panels().get_channelsPanel());
		} else if (_loc3_ == "fps") {
			console.set_fpsMonitor(!console.get_fpsMonitor());
		} else if (_loc3_ == "priority") {
			incPriority(_shift);
		} else if (_loc3_ == "mm") {
			console.set_memoryMonitor(!console.get_memoryMonitor());
		} else if (_loc3_ == "roller") {
			console.set_displayRoller(!console.get_displayRoller());
		} else if (_loc3_ == "ruler") {
			console.get_panels().tooltip();
			console.get_panels().startRuler();
		} else if (_loc3_ == "command") {
			set_commandLine(!get_commandLine());
		} else if (_loc3_ == "copy") {
			_loc5_ = _ctrl ? lineShouldShow : null;
			_loc6_ = console.get_logs().getLogsAsString("\r\n", !_shift, _loc5_);
			if (_alt) {
				_loc7_ = new FileReference();
				try {
					_loc7_.save(_loc6_, "log.txt");
				} catch (_loc_e_:Dynamic) {
					_loc8_ = ASCompat.asError(_loc_e_);
					console.report("Save to file is not supported in your flash player.", 8);
				}
			} else {
				System.setClipboard(_loc6_);
				console.report("Copied log to clipboard.", -1);
			}
		} else if (_loc3_ == "clear") {
			console.clear();
		} else if (_loc3_ == "settings") {
			console.report("A new window should open in browser. If not, try searching for \'Flash Player Global Security Settings panel\' online :)", -1);
			Security.showSettings(SecurityPanel.SETTINGS_MANAGER);
		} else if (_loc3_ == "remote") {
			console.get_remoter().set_remoting((2 : UInt));
		} else if (_loc3_.indexOf("ref") == 0) {
			console.get_refs().handleRefEvent(_loc3_);
		} else if (_loc3_.indexOf("channel_") == 0) {
			onChannelPressed(_loc3_.substring(8));
		} else if (_loc3_.indexOf("cl_") == 0) {
			_loc9_ = _loc3_.indexOf("_", 3);
			console.get_cl().handleScopeEvent((ASCompat.toInt(ConsoleLib.parseInt(_loc3_.substring(3, _loc9_ < 0 ? _loc3_.length : _loc9_))) : UInt));
			if (_loc9_ >= 0) {
				_cmdField.text = _loc3_.substring(_loc9_ + 1);
			}
		} else if (_loc3_.indexOf("external_") == 0) {
			_loc10_ = _extraMenus;
			_loc6_ = _loc3_.substring(9);
			_loc11_ = _loc10_;
			_loc12_ = _loc11_.get(_loc6_);
			if (_loc12_ != null) {
				_loc5_ = null;
				Reflect.callMethod(_loc5_, _loc12_[0], _loc12_[1]);
			}
		}
		txtField.setSelection(0, 0);
		e.stopPropagation();
	}

	public function lineShouldShow(line:Log):Bool {
		if (_priority == 0 || line.priority >= _priority) {
			if (!(chShouldShow(line.ch)
				|| _filterText != null
				&& _viewingChannels.indexOf("~") >= 0
				&& line.text.toLowerCase().indexOf(_filterText) >= 0)) {
				if (_filterRegExp != null && _viewingChannels.indexOf("~") >= 0) {
					return FlashRegex.search(line.text, _filterRegExp) >= 0;
				}
				return false;
			}
			return true;
		}
		return false;
	}

	public function keyUpHandler(e:KeyboardEvent) {
		var _loc3_ = ASCompat.dynamicAs(null, Error);
		if (e.keyCode == Keyboard.SHIFT) {
			_shift = false;
		} else if (e.keyCode == Keyboard.CONTROL) {
			_ctrl = false;
		} else if (e.keyCode == 18) {
			_alt = false;
		}
		if ((e.keyCode == Keyboard.TAB || e.keyCode == Keyboard.ENTER) && parent.visible && visible && _cmdField.visible) {
			try {
				stage.focus = _cmdField;
				setCLSelectionAtEnd();
			} catch (_loc_e_:Dynamic) {
				_loc3_ = ASCompat.asError(_loc_e_);
			}
		}
	}

	public function keyDownHandler(e:KeyboardEvent) {
		if (e.keyCode == Keyboard.SHIFT) {
			_shift = true;
		}
		if (e.keyCode == Keyboard.CONTROL) {
			_ctrl = true;
		}
		if (e.keyCode == 18) {
			_alt = true;
		}
	}

	public function incPriority(down:Bool) {
		var _loc2_ = 10;
		var _loc3_ = 0;
		var _loc4_ = console.get_logs().last;
		var _loc5_ = _priority;
		_priority = 0;
		var _loc6_ = (32000 : UInt);
		while (_loc4_ != null && _loc6_ > 0) {
			_loc6_ -= (1 : UInt);
			if (lineShouldShow(_loc4_)) {
				if (_loc4_.priority > _loc5_ && _loc2_ > _loc4_.priority) {
					_loc2_ = _loc4_.priority;
				}
				if (_loc4_.priority < _loc5_ && _loc3_ < _loc4_.priority) {
					_loc3_ = _loc4_.priority;
				}
			}
			_loc4_ = _loc4_.prev;
		}
		if (down) {
			if (_loc3_ == _loc5_) {
				_loc5_ = 10;
			} else {
				_loc5_ = _loc3_;
			}
		} else if (_loc2_ == _loc5_) {
			_loc5_ = 0;
		} else {
			_loc5_ = _loc2_;
		}
		set_priority((_loc5_ : UInt));
	}

	@:isVar public var viewingChannels(get, never):Array<ASAny>;

	public function get_viewingChannels():Array<ASAny> {
		return _viewingChannels;
	}

	public function get_scrollPercent():Float {
		return (_scroller.y - get_style().controlSize) / (_scrollHeight - 30 - get_style().controlSize * 2);
	}

	@:isVar public var reportChannel(get, never):String;

	public function get_reportChannel():String {
		if (_viewingChannels.length == 1) {
			return _viewingChannels[0];
		}
		return "C";
	}

	public function get_priority():UInt {
		return (_priority : UInt);
	}

	@:isVar public var ignoredChannels(get, never):Array<ASAny>;

	public function get_ignoredChannels():Array<ASAny> {
		return _ignoredChannels;
	}

	public function get_commandLine():Bool {
		return _cmdField.visible;
	}

	public function getChannelsLink(limited:Bool = false):String {
		var _loc8_ = 0;
		var _loc9_:ASAny = ASCompat.asString(null);
		var _loc10_:ASAny = ASCompat.asString(null);
		var _loc2_ = "<chs>";
		var _loc3_ = console.get_logs().getChannels();
		var _loc4_ = _loc3_.length;
		if (limited && _loc4_ > get_style().maxChannelsInMenu) {
			_loc4_ = get_style().maxChannelsInMenu;
		}
		var _loc5_ = _viewingChannels.length > 0 || _ignoredChannels.length > 0;
		var _loc6_ = 0;
		var _loc7_ = _loc4_;
		while (_loc6_ < _loc7_) {
			_loc8_ = _loc6_++;
			_loc9_ = _loc3_[_loc8_];
			_loc10_ = !_loc5_
				&& _loc8_ == 0
				|| _loc5_
				&& _loc8_ != 0
				&& chShouldShow(_loc9_) ? "<ch><b>" + Std.string(_loc9_) + "</b></ch>" : _loc9_;
			_loc2_ += "<a href=\"event:channel_" + Std.string(_loc9_) + "\">[" + Std.string(_loc10_) + "]</a> ";
		}
		if (limited) {
			_loc2_ += "<ch><a href=\"event:channels\"><b>" + (_loc3_.length > _loc4_ ? "..." : "") + "</b>^^ </a></ch>";
		}
		return _loc2_ + "</chs> ";
	}

	public function endFilter() {
		_filterRegExp = null;
		_filterText = null;
		if (_viewingChannels.length == 1 && _viewingChannels[0] == "~") {
			if ([" * "].length == 0) {
				setViewingChannels();
			} else if ([" * "].length == 1) {
				setViewingChannels([" * "][0]);
			} else if ([" * "].length == 2) {
				setViewingChannels([" * "][0], [" * "][1]);
			} else if ([" * "].length == 3) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2]);
			} else if ([" * "].length == 4) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3]);
			} else if ([" * "].length == 5) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4]);
			} else if ([" * "].length == 6) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5]);
			} else if ([" * "].length == 7) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6]);
			} else if ([" * "].length == 8) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7]);
			} else if ([" * "].length == 9) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8]);
			} else if ([" * "].length == 10) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9]);
			} else if ([" * "].length == 11) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10]);
			} else if ([" * "].length == 12) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11]);
			} else if ([" * "].length == 13) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12]);
			} else if ([" * "].length == 14) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13]);
			} else if ([" * "].length == 15) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14]);
			} else if ([" * "].length == 16) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14], [" * "][15]);
			} else if ([" * "].length == 17) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14], [" * "][15], [" * "][16]);
			} else if ([" * "].length == 18) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14], [" * "][15], [" * "][16], [" * "][17]);
			} else if ([" * "].length == 19) {
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14], [" * "][15], [" * "][16], [" * "][17], [" * "][18]);
			} else {
				if ([" * "].length != 20) {
					throw "Too many rest arguments";
				}
				setViewingChannels([" * "][0], [" * "][1], [" * "][2], [" * "][3], [" * "][4], [" * "][5], [" * "][6], [" * "][7], [" * "][8], [" * "][9],
					[" * "][10], [" * "][11], [" * "][12], [" * "][13], [" * "][14], [" * "][15], [" * "][16], [" * "][17], [" * "][18], [" * "][19]);
			}
		}
	}

	public function doActive(str:String, b:Bool):String {
		if (b) {
			return "<menuHi>" + str + "</menuHi>";
		}
		return str;
	}

	public function commandKeyUp(e:KeyboardEvent) {
		var _loc2_:ASAny = ASCompat.asString(null);
		var _loc3_ = 0;
		e.stopPropagation();
		if (e.keyCode == Keyboard.ENTER) {
			updateToBottom();
			setHints();
			if (_enteringLogin) {
				console.get_remoter().login(_cmdField.text);
				_cmdField.text = "";
				requestLogin(false);
			} else {
				_loc2_ = _cmdField.text;
				if (ASCompat.toNumberField(_loc2_, "length") > 2) {
					_loc3_ = _cmdsHistory.indexOf(_loc2_);
					while (_loc3_ >= 0) {
						_cmdsHistory.splice(_loc3_, (1 : UInt));
						_loc3_ = _cmdsHistory.indexOf(_loc2_);
					}
					_cmdsHistory.unshift(_loc2_);
					_cmdsInd = -1;
					if (_cmdsHistory.length > 20) {
						_cmdsHistory.splice(20, (_cmdsHistory.length : UInt));
					}
					console.updateSO("clhistory");
				}
				_cmdField.text = "";
				if (get_config().commandLineInputPassThrough != null) {
					_loc2_ = get_config().commandLineInputPassThrough(_loc2_);
				}
				if (_loc2_ != null && _loc2_ != "") {
					console.get_cl().run(_loc2_);
				}
			}
		} else if (e.keyCode == Keyboard.ESCAPE) {
			if (stage != null) {
				stage.focus = null;
			}
		} else if (e.keyCode == Keyboard.UP) {
			setHints();
			if (_cmdField.text != null && _cmdField.text != "" && _cmdsInd < 0) {
				_cmdsHistory.unshift(_cmdField.text);
				++_cmdsInd;
			}
			if (_cmdsInd < _cmdsHistory.length - 1) {
				++_cmdsInd;
				_cmdField.text = _cmdsHistory[_cmdsInd];
				setCLSelectionAtEnd();
			} else {
				_cmdsInd = _cmdsHistory.length;
				_cmdField.text = "";
			}
		} else if (e.keyCode == Keyboard.DOWN) {
			setHints();
			if (_cmdsInd > 0) {
				--_cmdsInd;
				_cmdField.text = _cmdsHistory[_cmdsInd];
				setCLSelectionAtEnd();
			} else {
				_cmdsInd = -1;
				_cmdField.text = "";
			}
		} else if (e.keyCode == Keyboard.TAB) {
			setCLSelectionAtEnd();
		} else if (!_enteringLogin) {
			updateCmdHint();
		}
	}

	public function commandKeyDown(e:KeyboardEvent) {
		e.stopPropagation();
		if (e.keyCode == Keyboard.TAB) {
			if (_hint != null) {
				_cmdField.text = _hint;
				setCLSelectionAtEnd();
				setHints();
			}
		}
	}

	public function clearCommandLineHistory(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		_cmdsInd = -1;
		console.updateSO();
		_cmdsHistory = [];
	}

	public function chShouldShow(ch:String):Bool {
		if (_viewingChannels.length == 0 || _viewingChannels.indexOf(ch) >= 0) {
			if (_ignoredChannels.length != 0) {
				return _ignoredChannels.indexOf(ch) < 0;
			}
			return true;
		}
		return false;
	}

	public function addMenu(key:String, f:ASAny, args:Array<ASAny>, rollover:String) {
		var _loc5_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc6_ = ASCompat.dynamicAs(null, StringMap);
		if (key != null) {
			key = FlashRegex.replace(key, new EReg("[^\\w]*", "g"), "");
			if (f == null) {
				cast(_extraMenus, StringMap<Dynamic>).remove(key);
			} else {
				_loc5_ = ([f, args, rollover] : Array<ASAny>);
				_loc6_ = cast(_extraMenus, StringMap<Dynamic>);
				{
					_loc6_.set(key, _loc5_);
				}
			}
			_needUpdateMenu = true;
		} else {
			console.report("ERROR: Invalid add menu params.", 9);
		}
	}

	public function addFilterText(txt:String):String {
		var _loc3_ = ASCompat.dynamicAs(null, RegexResult);
		var _loc4_ = 0;
		var _loc5_:ASAny = ASCompat.asString(null);
		var _loc2_:Float = 0;
		if (_filterRegExp != null) {
			_loc2_ = 0;
			_loc3_ = FlashRegex.exec(txt, _filterRegExp, ASCompat.floatToInt(_loc2_));
			while (_loc3_ != null) {
				_loc4_ = ASCompat.toInt(_loc3_.index);
				_loc5_ = _loc3_.elements[0];
				_loc2_ = _loc4_ + (ASCompat.toNumberField(_loc5_, "length") > 0 ? _loc5_.length : 1);
				if (FlashRegex.search(_loc5_, new EReg("<|>", "")) >= 0) {
					_loc2_ -= ASCompat.toNumberField(_loc5_, "length") - FlashRegex.search(_loc5_, new EReg("<|>", ""));
				} else if (txt.lastIndexOf("<", _loc4_) <= txt.lastIndexOf(">", _loc4_)) {
					txt = txt.substring(0, _loc4_)
						+ "<u>"
						+ txt.substring(_loc4_, ASCompat.toInt(_loc4_ + _loc5_.length))
						+ "</u>"
						+ txt.substring(ASCompat.toInt(_loc4_ + _loc5_.length));
					_loc2_ += 7;
				}
				_loc3_ = FlashRegex.exec(txt, _filterRegExp, ASCompat.floatToInt(_loc2_));
			}
		} else if (_filterText != null) {
			_loc5_ = txt.toLowerCase();
			_loc4_ = ASCompat.toInt(_loc5_.lastIndexOf(_filterText));
			while (_loc4_ >= 0) {
				txt = txt.substring(0, _loc4_) + "<u>" + txt.substring(_loc4_, _loc4_ + _filterText.length) + "</u>"
					+ txt.substring(_loc4_ + _filterText.length);
				_loc4_ = ASCompat.toInt(_loc5_.lastIndexOf(_filterText, _loc4_ - 2));
			}
		}
		return txt;
	}

	public function _updateTraces(onlyBottom:Bool = false) {
		if (_atBottom) {
			updateBottom();
		} else if (!onlyBottom) {
			updateFull();
		}
		if (_selectionStart != _selectionEnd) {
			if (_atBottom) {
				_traceField.setSelection(_traceField.text.length - _selectionStart, _traceField.text.length - _selectionEnd);
			} else {
				_traceField.setSelection(_traceField.text.length - _selectionEnd, _traceField.text.length - _selectionStart);
			}
			_selectionEnd = -1;
			_selectionStart = -1;
		}
	}

	public function _updateMenu() {
		var _loc2_ = false;
		var _loc3_ = ASCompat.dynamicAs(null, StringMap);
		var _loc4_:ASAny = null;
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
		var _loc1_ = "<r><high>";
		if (_mini || !get_style().topMenu) {
			_loc1_ += "<menu><b> <a href=\"event:show\">‹</a>";
		} else {
			if (!console.get_panels().get_channelsPanel()) {
				_loc1_ += getChannelsLink(true);
			}
			_loc1_ += "<menu> <b>";
			_loc2_ = false;
			_loc3_ = cast(_extraMenus, StringMap<Dynamic>);
			_loc4_ = ASCompat.haxeMapStorage(_loc3_);
			_loc5_ = null;
			_loc6_ = 0;
			_loc7_ = false;
			_loc8_ = _loc4_;
			_loc9_ = _loc6_;
			_loc10_ = (_loc9_ = ASCompat.nextIndex(_loc8_, _loc9_)) != 0;
			if (!_loc10_ && _loc5_ != null) {
				_loc8_ = _loc4_ = _loc5_;
				_loc9_ = _loc6_ = 0;
				_loc5_ = null;
				_loc7_ = true;
				_loc10_ = (_loc9_ = ASCompat.nextIndex(_loc8_, _loc9_)) != 0;
			}
			_loc11_ = _loc9_;
			while (true) {
				_loc12_ = _loc4_;
				_loc13_ = _loc6_;
				_loc14_ = (_loc13_ = ASCompat.nextIndex(_loc12_, _loc13_)) != 0;
				if (!_loc14_ && _loc5_ != null) {
					_loc12_ = _loc4_ = _loc5_;
					_loc13_ = _loc6_ = 0;
					_loc5_ = null;
					_loc7_ = true;
					_loc14_ = (_loc13_ = ASCompat.nextIndex(_loc12_, _loc13_)) != 0;
				}
				_loc11_ = _loc13_;
				if (!_loc14_) {
					break;
				}
				_loc15_ = ASCompat.nextName(_loc4_, _loc11_);
				_loc6_ = _loc11_;
				if (_loc7_) {
					_loc15_ = Std.string(_loc15_).substr(1);
				}
				_loc16_ = _loc15_;
				_loc1_ += "<a href=\"event:external_" + Std.string(_loc16_) + "\">" + Std.string(_loc16_) + "</a> ";
				_loc2_ = true;
			}
			if (_loc2_) {
				_loc1_ += "¦ ";
			}
			_loc1_ += doActive("<a href=\"event:fps\">F</a>", console.get_fpsMonitor() == true);
			_loc1_ += doActive(" <a href=\"event:mm\">M</a>", console.get_memoryMonitor() == true);
			_loc1_ += doActive(" <a href=\"event:command\">CL</a>", get_commandLine());
			if (console.get_remoter().get_remoting() != 2) {
				if (get_config().displayRollerEnabled) {
					_loc1_ += doActive(" <a href=\"event:roller\">Ro</a>", console.get_displayRoller());
				}
				if (get_config().rulerToolEnabled) {
					_loc1_ += doActive(" <a href=\"event:ruler\">RL</a>", console.get_panels().get_rulerActive());
				}
			}
			_loc1_ += " ¦</b>";
			_loc1_ += " <a href=\"event:copy\">Sv</a>";
			_loc1_ += " <a href=\"event:priority\">P" + _priority + "</a>";
			_loc1_ += doActive(" <a href=\"event:pause\">P</a>", console.get_paused());
			_loc1_ += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a> <a href=\"event:hide\">›</a>";
		}
		_loc1_ += " </b></menu></high></r>";
		txtField.htmlText = _loc1_;
		txtField.scrollH = txtField.maxScrollH;
		updateTraceFHeight();
	}
}
