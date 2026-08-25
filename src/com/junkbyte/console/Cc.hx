package com.junkbyte.console;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Rectangle;

class Cc {
	static var _console:Console;

	static var _config:ConsoleConfig;

	public function new() {}

	@:isVar public static var config(get, never):ConsoleConfig;

	static public function get_config():ConsoleConfig {
		if (_config == null) {
			_config = new ConsoleConfig();
		}
		return _config;
	}

	public static function start(container:DisplayObjectContainer, password:String = "") {
		if (_console != null) {
			if (container != null && _console.parent == null) {
				container.addChild(_console);
			}
		} else {
			_console = new Console(password, config);
			if (container != null) {
				container.addChild(_console);
			}
		}
	}

	public static function startOnStage(display:DisplayObject, password:String = "") {
		if (_console != null) {
			if (display != null && display.stage != null && _console.parent != display.stage) {
				display.stage.addChild(_console);
			}
		} else if (display != null && display.stage != null) {
			start(display.stage, password);
		} else {
			_console = new Console(password, config);
			if (display != null) {
				display.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandle);
			}
		}
	}

	public static function add(string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		if (_console != null) {
			_console.add(string, priority, isRepeating);
		}
	}

	public static function ch(channel:ASAny, string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		if (_console != null) {
			_console.ch(channel, string, priority, isRepeating);
		}
	}

	public static function log(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "log", rest);
		}
	}

	public static function info(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "info", rest);
		}
	}

	public static function debug(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "debug", rest);
		}
	}

	public static function warn(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "warn", rest);
		}
	}

	public static function error(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "error", rest);
		}
	}

	public static function fatal(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "fatal", rest);
		}
	}

	public static function logch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.LOG : Int));
		}
	}

	public static function infoch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.INFO : Int));
		}
	}

	public static function debugch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.DEBUG : Int));
		}
	}

	public static function warnch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.WARN : Int));
		}
	}

	public static function errorch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.ERROR_cpp : Int));
		}
	}

	public static function fatalch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			_console.addCh(channel, rest, (Console.FATAL : Int));
		}
	}

	public static function stack(string:ASAny, depth:Int = -1, priority:Int = 5) {
		if (_console != null) {
			_console.stack(string, depth, priority);
		}
	}

	public static function stackch(channel:ASAny, string:ASAny, depth:Int = -1, priority:Int = 5) {
		if (_console != null) {
			_console.stackch(channel, string, depth, priority);
		}
	}

	public static function inspect(obj:ASObject, showInherit:Bool = true) {
		if (_console != null) {
			_console.inspect(obj, showInherit);
		}
	}

	public static function inspectch(channel:ASAny, obj:ASObject, showInherit:Bool = true) {
		if (_console != null) {
			_console.inspectch(channel, obj, showInherit);
		}
	}

	public static function explode(obj:ASObject, depth:Int = 3) {
		if (_console != null) {
			_console.explode(obj, depth);
		}
	}

	public static function explodech(channel:ASAny, obj:ASObject, depth:Int = 3) {
		if (_console != null) {
			_console.explodech(channel, obj, depth);
		}
	}

	public static function addHTML(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "addHTML", rest);
		}
	}

	public static function addHTMLch(channel:ASAny, priority:Int, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "addHTMLch", ([channel, priority] : Array<ASAny>).concat(rest));
		}
	}

	public static function map(container:DisplayObjectContainer, maxDepth:UInt = (0 : UInt)) {
		if (_console != null) {
			_console.map(container, maxDepth);
		}
	}

	public static function mapch(channel:ASAny, container:DisplayObjectContainer, maxDepth:UInt = (0 : UInt)) {
		if (_console != null) {
			_console.mapch(channel, container, maxDepth);
		}
	}

	public static function clear(channel:String = null) {
		if (_console != null) {
			_console.clear(channel);
		}
	}

	public static function bindKey(key:KeyBind, callback:ASFunction = null, args:Array<ASAny> = null) {
		if (_console != null) {
			_console.bindKey(key, callback, args);
		}
	}

	public static function addMenu(key:String, callback:ASFunction, args:Array<ASAny> = null, rollover:String = null) {
		if (_console != null) {
			_console.addMenu(key, callback, args, rollover);
		}
	}

	public static function listenUncaughtErrors(loaderinfo:LoaderInfo) {
		if (_console != null) {
			_console.listenUncaughtErrors(loaderinfo);
		}
	}

	public static function store(name:String, obj:ASObject, useStrong:Bool = false) {
		if (_console != null) {
			_console.store(name, obj, useStrong);
		}
	}

	public static function addSlashCommand(name:String, callback:ASFunction, description:String = "", alwaysAvailable:Bool = true,
			endOfArgsMarker:String = ";") {
		if (_console != null) {
			_console.addSlashCommand(name, callback, description, alwaysAvailable, endOfArgsMarker);
		}
	}

	public static function watch(obj:ASObject, name:String = null):String {
		if (_console != null) {
			return _console.watch(obj, name);
		}
		return null;
	}

	public static function unwatch(name:String) {
		if (_console != null) {
			_console.unwatch(name);
		}
	}

	public static function addGraph(panelName:String, obj:ASObject, property:String, color:Float = -1, idKey:String = null, rectArea:Rectangle = null,
			inverse:Bool = false) {
		if (_console != null) {
			_console.addGraph(panelName, obj, property, color, idKey, rectArea, inverse);
		}
	}

	public static function fixGraphRange(panelName:String, min:Float = null, max:Float = null) {
		if (min == null)
			min = Math.NaN;
		if (max == null)
			max = Math.NaN;
		if (_console != null) {
			_console.fixGraphRange(panelName, min, max);
		}
	}

	public static function removeGraph(panelName:String, obj:ASObject = null, property:String = null) {
		if (_console != null) {
			_console.removeGraph(panelName, obj, property);
		}
	}

	public static function setViewingChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "setViewingChannels", rest);
		}
	}

	public static function setIgnoredChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_console != null) {
			ASCompatMacro.applyBoundMethod(_console, "setIgnoredChannels", rest);
		}
	}

	@:isVar public static var minimumPriority(never, set):UInt;

	static public function set_minimumPriority(level:UInt):UInt {
		if (_console != null) {
			_console.minimumPriority = level;
		}
		return level;
	}

	@:isVar public static var width(get, set):Float;

	static public function get_width():Float {
		if (_console != null) {
			return _console.width;
		}
		return 0;
	}

	static function set_width(v:Float):Float {
		if (_console != null) {
			_console.width = v;
		}
		return v;
	}

	@:isVar public static var height(get, set):Float;

	static public function get_height():Float {
		if (_console != null) {
			return _console.height;
		}
		return 0;
	}

	static function set_height(v:Float):Float {
		if (_console != null) {
			_console.height = v;
		}
		return v;
	}

	@:isVar public static var x(get, set):Float;

	static public function get_x():Float {
		if (_console != null) {
			return _console.x;
		}
		return 0;
	}

	static function set_x(v:Float):Float {
		if (_console != null) {
			_console.x = v;
		}
		return v;
	}

	@:isVar public static var y(get, set):Float;

	static public function get_y():Float {
		if (_console != null) {
			return _console.y;
		}
		return 0;
	}

	static function set_y(v:Float):Float {
		if (_console != null) {
			_console.y = v;
		}
		return v;
	}

	@:isVar public static var visible(get, set):Bool;

	static public function get_visible():Bool {
		if (_console != null) {
			return _console.visible;
		}
		return false;
	}

	static function set_visible(v:Bool):Bool {
		if (_console != null) {
			_console.visible = v;
		}
		return v;
	}

	@:isVar public static var fpsMonitor(get, set):Bool;

	static public function get_fpsMonitor():Bool {
		if (_console != null) {
			return _console.fpsMonitor;
		}
		return false;
	}

	static function set_fpsMonitor(v:Bool):Bool {
		if (_console != null) {
			_console.fpsMonitor = v;
		}
		return v;
	}

	@:isVar public static var memoryMonitor(get, set):Bool;

	static public function get_memoryMonitor():Bool {
		if (_console != null) {
			return _console.memoryMonitor;
		}
		return false;
	}

	static function set_memoryMonitor(v:Bool):Bool {
		if (_console != null) {
			_console.memoryMonitor = v;
		}
		return v;
	}

	@:isVar public static var commandLine(get, set):Bool;

	static public function get_commandLine():Bool {
		if (_console != null) {
			return _console.commandLine;
		}
		return false;
	}

	static function set_commandLine(v:Bool):Bool {
		if (_console != null) {
			_console.commandLine = v;
		}
		return v;
	}

	@:isVar public static var displayRoller(get, set):Bool;

	static public function get_displayRoller():Bool {
		if (_console != null) {
			return _console.displayRoller;
		}
		return false;
	}

	static function set_displayRoller(v:Bool):Bool {
		if (_console != null) {
			_console.displayRoller = v;
		}
		return v;
	}

	public static function setRollerCaptureKey(character:String, ctrl:Bool = false, alt:Bool = false, shift:Bool = false) {
		if (_console != null) {
			_console.setRollerCaptureKey(character, shift, ctrl, alt);
		}
	}

	@:isVar public static var remoting(get, set):Bool;

	static public function get_remoting():Bool {
		if (_console != null) {
			return _console.remoting;
		}
		return false;
	}

	static function set_remoting(v:Bool):Bool {
		if (_console != null) {
			_console.remoting = v;
		}
		return v;
	}

	public static function remotingSocket(host:String, port:Int) {
		if (_console != null) {
			_console.remotingSocket(host, port);
		}
	}

	public static function remove() {
		if (_console != null) {
			if (_console.parent != null) {
				_console.parent.removeChild(_console);
			}
			_console = null;
		}
	}

	public static function getAllLog(splitter:String = "\r\n"):String {
		if (_console != null) {
			return _console.getAllLog(splitter);
		}
		return "";
	}

	@:isVar public static var instance(get, never):Console;

	static public function get_instance():Console {
		return _console;
	}

	static function addedToStageHandle(e:Event) {
		var _loc2_ = ASCompat.dynamicAs(e.currentTarget, DisplayObjectContainer);
		_loc2_.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandle);
		if (_console != null && _console.parent == null) {
			_loc2_.stage.addChild(_console);
		}
	}
}
