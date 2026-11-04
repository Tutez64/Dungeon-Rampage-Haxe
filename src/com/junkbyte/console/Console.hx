package com.junkbyte.console;

import com.junkbyte.console.compat.ConsoleLib;
import com.junkbyte.console.core.CommandLine;
import com.junkbyte.console.core.ConsoleTools;
import com.junkbyte.console.core.Graphing;
import com.junkbyte.console.core.KeyBinder;
import com.junkbyte.console.core.LogReferences;
import com.junkbyte.console.core.Logs;
import com.junkbyte.console.core.MemoryMonitor;
import com.junkbyte.console.core.Remoting;
import com.junkbyte.console.utils.FlashRegex;
import com.junkbyte.console.view.PanelsManager;
import com.junkbyte.console.vos.Log;
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.system.Capabilities;

class Console extends Sprite {
	public static var VERSION:Float = 2.6;

	public static var VERSION_STAGE:String = "";

	public static var BUILD:UInt = (611 : UInt);

	public static var BUILD_DATE:String = "2012/02/22 00:11";

	public static var LOG:UInt = (1 : UInt);

	public static var INFO:UInt = (3 : UInt);

	public static var DEBUG:UInt = (6 : UInt);

	public static var WARN:UInt = (8 : UInt);

	public static var ERROR_cpp /*cpp macro conflict*/:UInt = (9 : UInt);

	public static var FATAL:UInt = (10 : UInt);

	public static var GLOBAL_CHANNEL:String = " * ";

	public static var DEFAULT_CHANNEL:String = "-";

	public static var CONSOLE_CHANNEL:String = "C";

	public static var FILTER_CHANNEL:String = "~";

	public var _topTries:Int = 0;

	public var _tools:ConsoleTools;

	public var _soData:ASAny;

	public var _so:SharedObject;

	public var _rollerKey:KeyBind;

	public var _remoter:Remoting;

	public var _refs:LogReferences;

	public var _paused:Bool = false;

	public var _panels:PanelsManager;

	public var _mm:MemoryMonitor;

	public var _logs:Logs;

	public var _kb:KeyBinder;

	public var _graphing:Graphing;

	public var _config:ConsoleConfig;

	public var _cl:CommandLine;

	public function new(password:String = /*undefined*/ null, config:ConsoleConfig = /*undefined*/ null) {
		var _gthis:Console;
		var _loc4_ = ASCompat.dynamicAs(null, Error);
		if (password == null) {
			password = "";
		}
		_soData = {};
		_topTries = 50;
		_gthis = this;
		super();
		name = "Console";
		if (config == null) {
			config = new ConsoleConfig();
		}
		_config = config;
		if (password != null && password != "") {
			_config.keystrokePassword = password;
		}
		_remoter = new Remoting(this);
		_logs = new Logs(this);
		_refs = new LogReferences(this);
		_cl = new CommandLine(this);
		_tools = new ConsoleTools(this);
		_graphing = new Graphing(this);
		_mm = new MemoryMonitor(this);
		_kb = new KeyBinder(this);
		get_cl().addCLCmd("remotingSocket", function(str:String = /*undefined*/ null) {
			if (str == null) {
				str = "";
			}
			var _loc2_ = FlashRegex.split(str, new EReg("\\s+|:", ""));
			_gthis.remotingSocket(_loc2_[0], ASCompat.toInt(ConsoleLib.parseInt(_loc2_[1])));
		}, "Connect to socket remote. /remotingSocket ip port");
		if (_config.sharedObjectName != null) {
			try {
				_so = SharedObject.getLocal(_config.sharedObjectName, _config.sharedObjectPath);
				_soData = _so.data;
			} catch (_loc_e_:Dynamic) {
				_loc4_ = _loc_e_;
			}
		}
		_config.get_style().updateStyleSheet();
		_panels = new PanelsManager(this);
		if (password != null && password != "") {
			set_visible(false);
		}
		report("<b>Console v" + 2.6 + "" + "</b> build " + "611" + ". " + Capabilities.playerType + " " + Capabilities.version + ".", -2);
		addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
	}

	public static function MakeChannelName(obj:ASAny):String {
		var _temp_1:ASAny;
		if (Std.isOfType(obj, String)) {
			_temp_1 = obj;
			if (!Std.isOfType(_temp_1, String)) {
				throw "Class cast error";
			}
			return _temp_1;
		}
		if (ASCompat.toBool(obj)) {
			return LogReferences.ShortClassName(obj);
		}
		return "-";
	}

	public function watch(object:ASAny, name:String = /*undefined*/ null):String {
		return _mm.watch(object, name);
	}

	public function warnch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 8, channel);
	}

	public function warn(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 8);
	}

	public function updateSO(key:String = /*undefined*/ null) {
		if (_so != null) {
			if (key != null) {
				_so.setDirty(key);
			} else {
				_so.clear();
			}
		}
	}

	public function unwatch(name:String) {
		_mm.unwatch(name);
	}

	public function uncaughtErrorHandle(e:Event) {
		var _loc2_:ASAny = Reflect.hasField(e, "error") ? Reflect.field(e, "error") : e;
		var _loc3_:String = null;
		if (Std.isOfType(_loc2_, Error)) {
			_loc3_ = _refs.makeString(_loc2_);
		} else if (Std.isOfType(_loc2_, ErrorEvent)) {
			_loc3_ = _loc2_.text;
		}
		if (_loc3_ == null) {
			_loc3_ = Std.string(_loc2_);
		}
		report(_loc3_, 10, false);
	}

	public function testHTML(args:Array<ASAny>):Bool {
		var _loc3_:ASAny = null;
		try {
			new compat.XML("<p>" + args.join("") + "</p>");
		} catch (_loc_e_:ASAny) {
			_loc3_ = _loc_e_;
			null;
			return false;
		}
		return true;
	}

	public function store(name:String, obj:ASAny, strong:Bool = false) {
		_cl.store(name, obj, strong);
	}

	public function stageRemovedHandle(e:Event = /*undefined*/ null) {
		_cl.set_base(null);
		removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
		addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler);
		stage.removeEventListener(KeyboardEvent.KEY_UP, _kb.keyUpHandler);
	}

	public function stageAddedHandle(e:Event = /*undefined*/ null) {
		if (_cl.get_base() == null) {
			_cl.set_base(parent);
		}
		if (loaderInfo != null) {
			listenUncaughtErrors(loaderInfo);
		}
		removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
		addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
		stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_UP, _kb.keyUpHandler, false, 0, true);
	}

	public function stackch(channel:ASAny, string:ASAny, depth:Int = -1, priority:Int = 5) {
		addLine([string], priority, channel, false, false, depth >= 0 ? depth : _config.defaultStackDepth);
	}

	public function stack(string:ASAny, depth:Int = -1, priority:Int = 5) {
		addLine([string], priority, "-", false, false, depth >= 0 ? depth : _config.defaultStackDepth);
	}

	override public function set_y(value:Float) {
		_panels.get_mainPanel().y = value;
		return value;
	}

	override public function set_x(value:Float) {
		_panels.get_mainPanel().x = value;
		return value;
	}

	override public function set_width(value:Float) {
		_panels.get_mainPanel().set_width(value);
		return value;
	}

	override public function set_visible(value:Bool) {
		super.visible = value;
		if (value) {
			_panels.get_mainPanel().set_visible(true);
		}
		return value;
	}

	@:isVar public var remoting(get, set):Bool;

	public function set_remoting(b:Bool):Bool {
		_remoter.set_remoting((b ? (1 : UInt) : (0 : UInt) : UInt));
		return b;
	}

	@:isVar public var paused(get, set):Bool;

	public function set_paused(newV:Bool):Bool {
		if (_paused == newV) {
			return newV;
		}
		if (newV) {
			report("Paused", 10);
		} else {
			report("Resumed", -1);
		}
		_paused = newV;
		_panels.get_mainPanel().setPaused(newV);
		return newV;
	}

	@:isVar public var minimumPriority(never, set):UInt;

	public function set_minimumPriority(level:UInt):UInt {
		_panels.get_mainPanel().set_priority(level);
		return level;
	}

	@:isVar public var memoryMonitor(get, set):Bool;

	public function set_memoryMonitor(b:Bool):Bool {
		_graphing.set_memoryMonitor(b);
		return b;
	}

	override public function set_height(value:Float) {
		_panels.get_mainPanel().set_height(value);
		return value;
	}

	@:isVar public var fpsMonitor(get, set):Bool;

	public function set_fpsMonitor(b:Bool):Bool {
		_graphing.set_fpsMonitor(b);
		return b;
	}

	@:isVar public var displayRoller(get, set):Bool;

	public function set_displayRoller(b:Bool):Bool {
		_panels.set_displayRoller(b);
		return b;
	}

	@:isVar public var commandLine(get, set):Bool;

	public function set_commandLine(b:Bool):Bool {
		_panels.get_mainPanel().set_commandLine(b);
		return b;
	}

	public function setViewingChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (rest.length == 0) {
			_panels.get_mainPanel().setViewingChannels();
		} else if (rest.length == 1) {
			_panels.get_mainPanel().setViewingChannels(rest[0]);
		} else if (rest.length == 2) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1]);
		} else if (rest.length == 3) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2]);
		} else if (rest.length == 4) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3]);
		} else if (rest.length == 5) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4]);
		} else if (rest.length == 6) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
		} else if (rest.length == 7) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
		} else if (rest.length == 8) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
		} else if (rest.length == 9) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
		} else if (rest.length == 10) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
		} else if (rest.length == 11) {
			_panels.get_mainPanel().setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
		} else if (rest.length == 12) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
		} else if (rest.length == 13) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
		} else if (rest.length == 14) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
		} else if (rest.length == 15) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
		} else if (rest.length == 16) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
		} else if (rest.length == 17) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
		} else if (rest.length == 18) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
		} else if (rest.length == 19) {
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
		} else {
			if (rest.length != 20) {
				throw "Too many rest arguments";
			}
			_panels.get_mainPanel()
				.setViewingChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
		}
	}

	public function setRollerCaptureKey(char:String, shift:Bool = false, ctrl:Bool = false, alt:Bool = false) {
		if (_rollerKey != null) {
			bindKey(_rollerKey, null);
			_rollerKey = null;
		}
		if (char != null && char.length == 1) {
			_rollerKey = new KeyBind(char, shift, ctrl, alt);
			bindKey(_rollerKey, onRollerCaptureKey);
		}
	}

	public function setIgnoredChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (rest.length == 0) {
			_panels.get_mainPanel().setIgnoredChannels();
		} else if (rest.length == 1) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0]);
		} else if (rest.length == 2) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1]);
		} else if (rest.length == 3) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2]);
		} else if (rest.length == 4) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3]);
		} else if (rest.length == 5) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4]);
		} else if (rest.length == 6) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
		} else if (rest.length == 7) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
		} else if (rest.length == 8) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
		} else if (rest.length == 9) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
		} else if (rest.length == 10) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
		} else if (rest.length == 11) {
			_panels.get_mainPanel().setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10]);
		} else if (rest.length == 12) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11]);
		} else if (rest.length == 13) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12]);
		} else if (rest.length == 14) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13]);
		} else if (rest.length == 15) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14]);
		} else if (rest.length == 16) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15]);
		} else if (rest.length == 17) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16]);
		} else if (rest.length == 18) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17]);
		} else if (rest.length == 19) {
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18]);
		} else {
			if (rest.length != 20) {
				throw "Too many rest arguments";
			}
			_panels.get_mainPanel()
				.setIgnoredChannels(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9], rest[10], rest[11], rest[12],
					rest[13], rest[14], rest[15], rest[16], rest[17], rest[18], rest[19]);
		}
	}

	public function report(obj:ASAny, priority:Int = 0, skipSafe:Bool = true, channel:String = /*undefined*/ null) {
		if (channel == null) {
			channel = _panels.get_mainPanel().get_reportChannel();
		}
		addLine([obj], priority, channel, false, skipSafe, 0);
	}

	public function removeGraph(name:String, obj:ASAny = /*undefined*/ null, property:String = /*undefined*/ null) {
		_graphing.remove(name, obj, property);
	}

	public function remotingSocket(host:String, port:Int) {
		_remoter.remotingSocket(host, port);
	}

	public function onStageMouseLeave(e:Event) {
		_panels.tooltip(null);
	}

	public function onRollerCaptureKey() {
		if (get_displayRoller()) {
			report("Display Roller Capture:<br/>" + Std.string((_panels.getPanel("rollerPanel") : ASAny).getMapString(true)), -1);
		}
	}

	public function mapch(channel:ASAny, container:DisplayObjectContainer, maxstep:UInt = (0 : UInt)) {
		_tools.map(container, (maxstep : Int), Console.MakeChannelName(channel));
	}

	public function map(container:DisplayObjectContainer, maxstep:UInt = (0 : UInt)) {
		_tools.map(container, (maxstep : Int), "-");
	}

	public function logch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 1, channel);
	}

	public function log(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 1);
	}

	public function listenUncaughtErrors(loaderinfo:LoaderInfo) {
		var _loc3_:ASAny = ASCompat.dynamicAs(null, IEventDispatcher);
		var _loc4_ = ASCompat.dynamicAs(null, Error);
		try {
			_loc3_ = Reflect.field(loaderinfo, "uncaughtErrorEvents");
			if (_loc3_ != null) {
				_loc3_.addEventListener("uncaughtError", uncaughtErrorHandle, false, 0, true);
			}
		} catch (_loc_e_:Dynamic) {
			_loc4_ = _loc_e_;
		}
	}

	public function inspectch(channel:ASAny, obj:ASAny, showInherit:Bool = true) {
		_refs.inspect(obj, showInherit, Console.MakeChannelName(channel));
	}

	public function inspect(obj:ASAny, showInherit:Bool = true) {
		_refs.inspect(obj, showInherit, "-");
	}

	public function infoch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 3, channel);
	}

	public function info(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 3);
	}

	override public function get_y():Float {
		return _panels.get_mainPanel().y;
	}

	override public function get_x():Float {
		return _panels.get_mainPanel().x;
	}

	override public function get_width():Float {
		return _panels.get_mainPanel().get_width();
	}

	@:isVar public var so(get, never):ASAny;

	public function get_so():ASAny {
		return _soData;
	}

	@:isVar public var rollerCaptureKey(get, never):KeyBind;

	public function get_rollerCaptureKey():KeyBind {
		return _rollerKey;
	}

	public function get_remoting():Bool {
		return _remoter.get_remoting() == 1;
	}

	@:isVar public var remoter(get, never):Remoting;

	public function get_remoter():Remoting {
		return _remoter;
	}

	@:isVar public var refs(get, never):LogReferences;

	public function get_refs():LogReferences {
		return _refs;
	}

	public function get_paused():Bool {
		return _paused;
	}

	@:isVar public var panels(get, never):PanelsManager;

	public function get_panels():PanelsManager {
		return _panels;
	}

	public function get_memoryMonitor():Bool {
		return _graphing.get_memoryMonitor();
	}

	@:isVar public var mapper(get, never):ConsoleTools;

	public function get_mapper():ConsoleTools {
		return _tools;
	}

	@:isVar public var logs(get, never):Logs;

	public function get_logs():Logs {
		return _logs;
	}

	override public function get_height():Float {
		return _panels.get_mainPanel().get_height();
	}

	@:isVar public var graphing(get, never):Graphing;

	public function get_graphing():Graphing {
		return _graphing;
	}

	public function get_fpsMonitor():Bool {
		return _graphing.get_fpsMonitor();
	}

	public function get_displayRoller():Bool {
		return _panels.get_displayRoller();
	}

	@:isVar public var config(get, never):ConsoleConfig;

	public function get_config():ConsoleConfig {
		return _config;
	}

	public function get_commandLine():Bool {
		return _panels.get_mainPanel().get_commandLine();
	}

	@:isVar public var cl(get, never):CommandLine;

	public function get_cl():CommandLine {
		return _cl;
	}

	public function getAllLog(splitter:String = /*undefined*/ null):String {
		if (splitter == null) {
			splitter = "\r\n";
		}
		return _logs.getLogsAsString(splitter);
	}

	public function gc() {
		_mm.gc();
	}

	public function fixGraphRange(name:String, min:ASObject = /*undefined*/ null, max:ASObject = /*undefined*/ null) {
		if (min == null) {
			min = Math.NaN;
		}
		if (max == null) {
			max = Math.NaN;
		}
		_graphing.fixRange(name, min, max);
	}

	public function fatalch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 10, channel);
	}

	public function fatal(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 10);
	}

	public function explodech(channel:ASAny, obj:ASAny, depth:Int = 3) {
		addLine([_tools.explode(obj, depth)], 1, channel, false, true);
	}

	public function explode(obj:ASAny, depth:Int = 3) {
		addLine([_tools.explode(obj, depth)], 1, null, false, true);
	}

	public function errorch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 9, channel);
	}

	public function error(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 9);
	}

	public function debugch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 6, channel);
	}

	public function debug(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		addLine(ASCompat.coerce(rest.copy(), Array), 6);
	}

	public function clear(channel:String = /*undefined*/ null) {
		_logs.clear(channel);
		if (!_paused) {
			_panels.get_mainPanel().updateToBottom();
		}
		_panels.updateMenu();
	}

	public function ch(channel:ASAny, string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		addLine([string], priority, channel, isRepeating);
	}

	public function bindKey(key:KeyBind, callback:ASAny, args:Array<ASAny> = /*undefined*/ null) {
		if (key != null) {
			_kb.bindKey(key, callback, args);
		}
	}

	public function addSlashCommand(name:String, callback:ASAny, desc:String = /*undefined*/ null, alwaysAvailable:Bool = true,
			endOfArgsMarker:String = /*undefined*/ null) {
		if (desc == null) {
			desc = "";
		}
		if (endOfArgsMarker == null) {
			endOfArgsMarker = ";";
		}
		_cl.addSlashCommand(name, callback, desc, alwaysAvailable, endOfArgsMarker);
	}

	public function addMenu(key:String, callback:ASAny, args:Array<ASAny> = /*undefined*/ null, rollover:String = /*undefined*/ null) {
		get_panels().get_mainPanel().addMenu(key, callback, args, rollover);
	}

	public function addLine(strings:Array<ASAny>, priority:Int = 0, channel:ASAny = /*undefined*/ null, isRepeating:Bool = false, html:Bool = false,
			stacks:Int = -1) {
		var _loc11_ = 0;
		var _loc7_ = "";
		var _loc8_ = strings.length;
		var _loc9_ = 0;
		var _loc10_ = _loc8_;
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc7_ += (_loc11_ != 0 ? " " : "") + _refs.makeString(strings[_loc11_], null, html);
		}
		if (priority >= _config.autoStackPriority && stacks < 0) {
			stacks = _config.defaultStackDepth;
		}
		if (!html && stacks > 0) {
			_loc7_ += _tools.getStack(stacks, priority);
		}
		_logs.add(new Log(_loc7_, Console.MakeChannelName(channel), priority, isRepeating, html));
	}

	public function addHTMLch(channel:ASAny, priority:Int, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc5_:Array<ASAny> = ASCompat.coerce(rest.copy(), Array);
		addLine(_loc5_, priority, channel, false, testHTML(_loc5_));
	}

	public function addHTML(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc3_:Array<ASAny> = ASCompat.coerce(rest.copy(), Array);
		addLine(_loc3_, 2, "-", false, testHTML(_loc3_));
	}

	public function addGraph(name:String, obj:ASAny, property:String, color:Int = -1, key:String = /*undefined*/ null, rect:Rectangle = /*undefined*/ null,
			inverse:Bool = false) {
		_graphing.add(name, obj, property, color, key, rect, inverse);
	}

	public function addCh(channel:ASAny, strings:Array<ASAny>, priority:Int = 2, isRepeating:Bool = false) {
		addLine(strings, priority, channel, isRepeating);
	}

	public function add(string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		addLine([string], priority, "-", isRepeating);
	}

	public function _onEnterFrame(e:Event) {
		var _loc2_ = flash.Lib.getTimer();
		_logs.update((_loc2_ : UInt));
		_refs.update((_loc2_ : UInt));
		_mm.update();
		var _loc3_:Array<ASAny> = null;
		if (get_remoter().get_remoting() != 2) {
			_loc3_ = _graphing.update(stage != null ? ASCompat.floatToInt(stage.frameRate) : 0);
		}
		_remoter.update();
		if (visible && parent != null) {
			if (get_config().alwaysOnTop && _topTries > 0 && parent.numChildren > parent.getChildIndex(this) + 1) {
				--_topTries;
				parent.addChild(this);
				report("Moved console on top (alwaysOnTop enabled), " + _topTries + " attempts left.", -1);
			}
			_panels.update(_paused, _logs.hasNewLog);
			_logs.hasNewLog = false;
			if (_loc3_ != null) {
				_panels.updateGraphs(_loc3_);
			}
		}
	}
}
