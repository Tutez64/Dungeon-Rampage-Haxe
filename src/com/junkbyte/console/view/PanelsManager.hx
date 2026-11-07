package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.GraphGroup;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class PanelsManager {
	public var console:Console;

	public var _tooltipField:TextField;

	public var _ruler:Ruler;

	public var _memPanel:GraphingPanel;

	public var _mainPanel:MainPanel;

	public var _graphsMap:IMap<ASAny, ASAny>;

	public var _graphPlaced:UInt = 0;

	public var _fpsPanel:GraphingPanel;

	public var _chsPanel:ChannelsPanel;

	public var _canDraw:Bool = false;

	public function new(master:Console = /*undefined*/ null) {
		_graphPlaced = (0 : UInt);
		_graphsMap = new StringMap<ASAny>();
		console = master;
		_mainPanel = new MainPanel(console);
		_tooltipField = get_mainPanel().makeTF("tooltip", true);
		_tooltipField.mouseEnabled = false;
		_tooltipField.autoSize = TextFieldAutoSize.CENTER;
		_tooltipField.multiline = true;
		addPanel(_mainPanel);
	}

	public function updateMenu() {
		_mainPanel.updateMenu();
		var _loc1_ = getPanel("channelsPanel");
		var _loc2_ = ASCompat.reinterpretAs(_loc1_, ChannelsPanel);
		if (_loc2_ != null) {
			_loc2_.update();
		}
	}

	public function updateGraphs(graphs:Array<ASAny>) {
		var _loc6_:ASAny = ASCompat.dynamicAs(null, GraphGroup);
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_ = ASCompat.dynamicAs(null, StringMap);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, GraphingPanel);
		var _loc10_:ASAny = ASCompat.dynamicAs(null, Rectangle);
		var _loc11_ = 0;
		var _loc12_ = false;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = 0;
		var _loc16_ = 0;
		var _loc17_ = 0;
		var _loc18_ = false;
		var _loc19_ = false;
		var _loc20_ = ASCompat.dynamicAs(null, StringMap);
		var _loc24_:ASAny = null;
		var _loc25_:ASAny = ASCompat.asString(null);
		var _loc2_:ASAny = null;
		var _loc3_:GraphGroup = null;
		var _loc4_:GraphGroup = null;
		_graphPlaced = (0 : UInt);
		var _loc5_ = 0;
		while (_loc5_ < graphs.length) {
			_loc6_ = graphs[_loc5_];
			_loc5_++;
			if (ASCompat.toNumberField(_loc6_, "type") == 1) {
				_loc3_ = ASCompat.coerce(_loc6_, com.junkbyte.console.vos.GraphGroup);
			} else if (ASCompat.toNumberField(_loc6_, "type") == 2) {
				_loc4_ = ASCompat.coerce(_loc6_, com.junkbyte.console.vos.GraphGroup);
			} else {
				_loc7_ = _loc6_.name;
				_loc8_ = cast(_graphsMap, StringMap<Dynamic>);
				_loc9_ = _loc8_.get(_loc7_);
				if (_loc9_ == null) {
					_loc10_ = _loc6_.rect;
					if (_loc10_ == null) {
						_loc10_ = new Rectangle(Math.NaN, Math.NaN, 0, 0);
					}
					_loc11_ = 100;
					_loc13_ = ASCompat.toNumberField(_loc10_, "x");
					if (_loc13_ == _loc13_) {
						_loc14_ = ASCompat.toNumberField(_loc10_, "y");
						_loc12_ = _loc14_ != _loc14_;
					} else {
						_loc12_ = true;
					}
					if (_loc12_) {
						if (_mainPanel.get_width() < 150) {
							_loc11_ = 50;
						}
						_loc15_ = ASCompat.floatToInt(Math.ffloor(_mainPanel.get_width() / _loc11_)) - 1;
						if (_loc15_ <= 1) {
							_loc15_ = 2;
						}
						_loc16_ = (_graphPlaced % _loc15_ : Int);
						_loc17_ = Math.floor(_graphPlaced / _loc15_);
						ASCompat.setProperty(_loc10_, "x", _mainPanel.x + _loc11_ + _loc16_ * _loc11_);
						ASCompat.setProperty(_loc10_, "y", _mainPanel.y + _loc11_ * 0.6 + _loc17_ * _loc11_);
						++_graphPlaced;
					}
					if (ASCompat.toNumberField(_loc10_, "width") > 0) {
						_loc14_ = ASCompat.toNumberField(_loc10_, "width");
						_loc18_ = _loc14_ != _loc14_;
					} else {
						_loc18_ = true;
					}
					if (_loc18_) {
						ASCompat.setProperty(_loc10_, "width", _loc11_);
					}
					if (ASCompat.toNumberField(_loc10_, "height") > 0) {
						_loc14_ = ASCompat.toNumberField(_loc10_, "height");
						_loc19_ = _loc14_ != _loc14_;
					} else {
						_loc19_ = true;
					}
					if (_loc19_) {
						ASCompat.setProperty(_loc10_, "height", _loc11_);
					}
					_loc9_ = new GraphingPanel(console, ASCompat.toNumberField(_loc10_, "width"), ASCompat.toNumberField(_loc10_, "height"));
					ASCompat.setProperty(_loc9_, "x", _loc10_.x);
					ASCompat.setProperty(_loc9_, "y", _loc10_.y);
					ASCompat.setProperty(_loc9_, "name", "graph_" + Std.string(_loc7_));
					_loc20_ = cast(_graphsMap, StringMap<Dynamic>);
					{
						_loc20_.set(_loc7_, _loc9_);
					}
					addPanel(ASCompat.coerce(_loc9_, com.junkbyte.console.view.ConsolePanel));
				}
				if (_loc2_ == null) {
					_loc2_ = {};
				}
				_loc2_[_loc7_] = true;
				_loc9_.update(_loc6_, _canDraw);
			}
		}
		_loc8_ = cast(_graphsMap, StringMap<Dynamic>);
		var _loc21_:ASAny = ASCompat.haxeMapStorage(_loc8_);
		var _loc22_:ASAny = null;
		_loc5_ = 0;
		_loc12_ = false;
		var _loc23_:ASAny = _loc21_;
		_loc11_ = _loc5_;
		_loc18_ = (_loc11_ = ASCompat.nextIndex(_loc23_, _loc11_)) != 0;
		if (!_loc18_ && _loc22_ != null) {
			_loc23_ = _loc21_ = _loc22_;
			_loc11_ = _loc5_ = 0;
			_loc22_ = null;
			_loc12_ = true;
			_loc18_ = (_loc11_ = ASCompat.nextIndex(_loc23_, _loc11_)) != 0;
		}
		_loc15_ = _loc11_;
		while (true) {
			_loc24_ = _loc21_;
			_loc16_ = _loc5_;
			_loc19_ = (_loc16_ = ASCompat.nextIndex(_loc24_, _loc16_)) != 0;
			if (!_loc19_ && _loc22_ != null) {
				_loc24_ = _loc21_ = _loc22_;
				_loc16_ = _loc5_ = 0;
				_loc22_ = null;
				_loc12_ = true;
				_loc19_ = (_loc16_ = ASCompat.nextIndex(_loc24_, _loc16_)) != 0;
			}
			_loc15_ = _loc16_;
			if (!_loc19_) {
				break;
			}
			_loc7_ = ASCompat.nextName(_loc21_, _loc15_);
			_loc5_ = _loc15_;
			if (_loc12_) {
				_loc7_ = Std.string(_loc7_).substr(1);
			}
			_loc25_ = _loc7_;
			if (_loc2_ == null || !Reflect.hasField(_loc2_, _loc25_)) {
				_loc20_ = cast(_graphsMap, StringMap<Dynamic>);
				_loc20_.get(_loc25_).close();
				cast(_graphsMap, StringMap<Dynamic>).remove(_loc25_);
			}
		}
		if (_loc3_ != null) {
			if (_fpsPanel == null) {
				_fpsPanel = new GraphingPanel(console, 80, 40, "fpsPanel");
				_fpsPanel.name = "fpsPanel";
				_fpsPanel.x = _mainPanel.x + _mainPanel.get_width() - 160;
				_fpsPanel.y = _mainPanel.y + 15;
				addPanel(_fpsPanel);
				_mainPanel.updateMenu();
			}
			_fpsPanel.update(_loc3_, _canDraw);
		} else if (_fpsPanel != null) {
			removePanel("fpsPanel");
			_fpsPanel = null;
		}
		if (_loc4_ != null) {
			if (_memPanel == null) {
				_memPanel = new GraphingPanel(console, 80, 40, "memoryPanel");
				_memPanel.name = "memoryPanel";
				_memPanel.x = _mainPanel.x + _mainPanel.get_width() - 80;
				_memPanel.y = _mainPanel.y + 15;
				addPanel(_memPanel);
				_mainPanel.updateMenu();
			}
			_memPanel.update(_loc4_, _canDraw);
		} else if (_memPanel != null) {
			removePanel("memoryPanel");
			_memPanel = null;
		}
		_canDraw = false;
	}

	public function update(paused:Bool, lineAdded:Bool) {
		_canDraw = !paused;
		_mainPanel.update(!paused && lineAdded);
		if (!paused) {
			if (lineAdded && _chsPanel != null) {
				_chsPanel.update();
			}
		}
	}

	public function tooltip(str:String = /*undefined*/ null, panel:ConsolePanel = /*undefined*/ null) {
		var __tmpAssignObj75:TextField;
		var __tmpAssignObj76:TextField;
		var __tmpAssignObj77:TextField;
		var _loc3_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc4_ = ASCompat.dynamicAs(null, Rectangle);
		var _loc5_ = ASCompat.dynamicAs(null, Rectangle);
		var _loc6_ = Math.NaN;
		var _loc7_ = ASCompat.dynamicAs(null, TextField);
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		if (str != null && str != "" && !get_rulerActive()) {
			_loc3_ = str.split("::");
			str = _loc3_[0];
			if (ASCompat.toInt(_loc3_.length) > 1) {
				str += "<br/><low>" + Std.string(_loc3_[1]) + "</low>";
			}
			console.addChild(_tooltipField);
			_tooltipField.wordWrap = false;
			_tooltipField.htmlText = "<tt>" + str + "</tt>";
			if (_tooltipField.width > 120) {
				_tooltipField.width = 120;
				_tooltipField.wordWrap = true;
			}
			_tooltipField.x = console.mouseX - _tooltipField.width / 2;
			_tooltipField.y = console.mouseY + 20;
			if (panel != null) {
				_loc4_ = _tooltipField.getBounds(console);
				_loc5_ = new Rectangle(panel.x, panel.y, panel.get_width(), panel.get_height());
				_loc6_ = ASCompat.toNumberField(_loc4_, "bottom") - ASCompat.toNumberField(_loc5_, "bottom");
				if (_loc6_ > 0) {
					if (_tooltipField.y - _loc6_ > console.mouseY + 15) {
						_loc7_ = _tooltipField;
						__tmpAssignObj75 = _loc7_;
						ASCompat.setProperty(__tmpAssignObj75, "y", __tmpAssignObj75.y - _loc6_);
					} else if (ASCompat.toNumberField(_loc5_, "y") < console.mouseY - 24 && _loc4_.y > _loc5_.bottom) {
						_tooltipField.y = console.mouseY - _tooltipField.height - 15;
					}
				}
				_loc8_ = ASCompat.toNumberField(_loc4_, "left") - ASCompat.toNumberField(_loc5_, "left");
				_loc9_ = ASCompat.toNumberField(_loc4_, "right") - ASCompat.toNumberField(_loc5_, "right");
				if (_loc8_ < 0) {
					_loc7_ = _tooltipField;
					__tmpAssignObj76 = _loc7_;
					ASCompat.setProperty(__tmpAssignObj76, "x", __tmpAssignObj76.x - _loc8_);
				} else if (_loc9_ > 0) {
					_loc7_ = _tooltipField;
					__tmpAssignObj77 = _loc7_;
					ASCompat.setProperty(__tmpAssignObj77, "x", __tmpAssignObj77.x - _loc9_);
				}
			}
		} else if (console.contains(_tooltipField)) {
			console.removeChild(_tooltipField);
		}
	}

	public function startRuler() {
		if (get_rulerActive()) {
			return;
		}
		_ruler = new Ruler(console);
		_ruler.addEventListener(Event.COMPLETE, onRulerExit, false, 0, true);
		console.addChild(_ruler);
		_mainPanel.updateMenu();
	}

	@:isVar public var displayRoller(get, set):Bool;

	public function set_displayRoller(n:Bool):Bool {
		var _loc2_ = ASCompat.dynamicAs(null, RollerPanel);
		if (get_displayRoller() != n) {
			if (n) {
				if (console.get_config().displayRollerEnabled) {
					_loc2_ = new RollerPanel(console);
					ASCompat.setProperty(_loc2_, "x", _mainPanel.x + _mainPanel.get_width() - 180);
					ASCompat.setProperty(_loc2_, "y", _mainPanel.y + 55);
					addPanel(_loc2_);
				} else {
					console.report("Display roller is disabled in config.", 9);
				}
			} else {
				removePanel("rollerPanel");
			}
			_mainPanel.updateMenu();
		}
		return n;
	}

	@:isVar public var channelsPanel(get, set):Bool;

	public function set_channelsPanel(b:Bool):Bool {
		if (get_channelsPanel() != b) {
			console.get_logs().cleanChannels();
			if (b) {
				_chsPanel = new ChannelsPanel(console);
				_chsPanel.x = _mainPanel.x + _mainPanel.get_width() - 332;
				_chsPanel.y = _mainPanel.y - 2;
				addPanel(_chsPanel);
				_chsPanel.update();
				updateMenu();
			} else {
				removePanel("channelsPanel");
				_chsPanel = null;
			}
			updateMenu();
		}
		return b;
	}

	public function setPanelArea(panelname:String, rect:Rectangle) {
		var _loc3_ = getPanel(panelname);
		if (_loc3_ != null) {
			_loc3_.x = rect.x;
			_loc3_.y = rect.y;
			if (rect.width != 0) {
				_loc3_.set_width(rect.width);
			}
			if (rect.height != 0) {
				_loc3_.set_height(rect.height);
			}
		}
	}

	public function removePanel(n:String) {
		var _loc2_ = console.getChildByName(n);
		var _loc3_ = ASCompat.reinterpretAs(_loc2_, ConsolePanel);
		if (_loc3_ != null) {
			_loc3_.close();
		}
	}

	public function removeGraph(group:GraphGroup) {
		var _loc2_ = ASCompat.asString(null);
		var _loc3_ = ASCompat.dynamicAs(null, StringMap);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, GraphingPanel);
		if (_fpsPanel != null && group == _fpsPanel.get_group()) {
			_fpsPanel.close();
			_fpsPanel = null;
		} else if (_memPanel != null && group == _memPanel.get_group()) {
			_memPanel.close();
			_memPanel = null;
		} else {
			_loc2_ = group.name;
			_loc3_ = cast(_graphsMap, StringMap<Dynamic>);
			_loc4_ = _loc3_.get(_loc2_);
			if (_loc4_ != null) {
				_loc4_.close();
				cast(_graphsMap, StringMap<Dynamic>).remove(group.name);
			}
		}
	}

	public function panelExists(n:String):Bool {
		if (Std.isOfType(console.getChildByName(n), ConsolePanel)) {
			return true;
		}
		return false;
	}

	public function onRulerExit(e:Event) {
		if (_ruler != null && console.contains(_ruler)) {
			console.removeChild(_ruler);
		}
		_ruler = null;
		_mainPanel.updateMenu();
	}

	public function onPanelStartDragScale(e:Event) {
		var _loc3_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc4_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc5_ = 0;
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc9_:ASAny = ASCompat.dynamicAs(null, ConsolePanel);
		var _loc2_ = cast(e.currentTarget, ConsolePanel);
		if (console.get_config().get_style().panelSnapping != 0) {
			_loc3_ = [0];
			_loc4_ = [0];
			if (console.stage != null) {
				ASCompat.dynPush(_loc3_, console.stage.stageWidth);
				ASCompat.dynPush(_loc4_, console.stage.stageHeight);
			}
			_loc5_ = console.numChildren;
			_loc6_ = 0;
			_loc7_ = _loc5_;
			while (_loc6_ < _loc7_) {
				_loc8_ = _loc6_++;
				if (Std.isOfType(console.getChildAt(_loc8_), ConsolePanel)) {
					_loc9_ = console.getChildAt(_loc8_);
					if (_loc9_ != null && ASCompat.toBool(_loc9_.visible)) {
						ASCompat.dynPush(_loc3_, _loc9_.x);
						ASCompat.dynPush(_loc3_, _loc9_.x + _loc9_.get_width());
						ASCompat.dynPush(_loc4_, _loc9_.y);
						ASCompat.dynPush(_loc4_, _loc9_.y + _loc9_.get_height());
					}
				}
			}
			_loc2_.registerSnaps(ASCompat.coerce(_loc3_, Array), ASCompat.coerce(_loc4_, Array));
		}
	}

	@:isVar public var rulerActive(get, never):Bool;

	public function get_rulerActive():Bool {
		if (_ruler != null && console.contains(_ruler)) {
			return true;
		}
		return false;
	}

	@:isVar public var memoryMonitor(get, never):Bool;

	public function get_memoryMonitor():Bool {
		return _memPanel != null;
	}

	@:isVar public var mainPanel(get, never):MainPanel;

	public function get_mainPanel():MainPanel {
		return _mainPanel;
	}

	@:isVar public var fpsMonitor(get, never):Bool;

	public function get_fpsMonitor():Bool {
		return _fpsPanel != null;
	}

	public function get_displayRoller():Bool {
		if (Std.isOfType(getPanel("rollerPanel"), RollerPanel)) {
			return true;
		}
		return false;
	}

	public function get_channelsPanel():Bool {
		return _chsPanel != null;
	}

	public function getPanel(n:String):ConsolePanel {
		var _loc2_ = console.getChildByName(n);
		return ASCompat.reinterpretAs(_loc2_, ConsolePanel);
	}

	public function addPanel(panel:ConsolePanel) {
		if (console.contains(_tooltipField)) {
			console.addChildAt(panel, console.getChildIndex(_tooltipField));
		} else {
			console.addChild(panel);
		}
		panel.addEventListener("draggingStarted", onPanelStartDragScale, false, 0, true);
		panel.addEventListener("scalingStarted", onPanelStartDragScale, false, 0, true);
	}
}
