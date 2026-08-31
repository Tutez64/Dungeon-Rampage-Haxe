package com.junkbyte.console;

import com.junkbyte.console.core.CommandLine;
import com.junkbyte.console.core.ConsoleTools;
import com.junkbyte.console.core.Graphing;
import com.junkbyte.console.core.KeyBinder;
import com.junkbyte.console.core.LogReferences;
import com.junkbyte.console.core.Logs;
import com.junkbyte.console.core.MemoryMonitor;
import com.junkbyte.console.core.Remoting;
import com.junkbyte.console.view.PanelsManager;
import com.junkbyte.console.view.RollerPanel;
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
	public static inline final VERSION:Float = 2.6;

	public static inline final VERSION_STAGE = "";

	public static inline final BUILD = 611;

	public static inline final BUILD_DATE = "2012/02/22 00:11";

	public static inline final LOG = (1 : UInt);

	public static inline final INFO = (3 : UInt);

	public static inline final DEBUG = (6 : UInt);

	public static inline final WARN = (8 : UInt);

	public static inline final ERROR_cpp /*cpp macro conflict*/ = (9 : UInt);

	public static inline final FATAL = (10 : UInt);

	public static inline final GLOBAL_CHANNEL = " * ";

	public static inline final DEFAULT_CHANNEL = "-";

	public static inline final CONSOLE_CHANNEL = "C";

	public static inline final FILTER_CHANNEL = "~";

	var _config:ConsoleConfig;

	var _panels:PanelsManager;

	var _cl:CommandLine;

	var _kb:KeyBinder;

	var _refs:LogReferences;

	var _mm:MemoryMonitor;

	var _graphing:Graphing;

	var _remoter:Remoting;

	var _tools:ConsoleTools;

	var _topTries:Int = 50;

	var _paused:Bool = false;

	var _rollerKey:KeyBind;

	var _logs:Logs;

	var _so:SharedObject;

	var _soData:ASObject;

	public function new(password:String = "", config:ConsoleConfig = null) {
		this._soData = {};
		super();
		name = "Console";
		if (config == null) {
			config = new ConsoleConfig();
		}
		this._config = config;
		if (ASCompat.stringAsBool(password)) {
			this._config.keystrokePassword = password;
		}
		this._remoter = new Remoting(this);
		this._logs = new Logs(this);
		this._refs = new LogReferences(this);
		this._cl = new CommandLine(this);
		this._tools = new ConsoleTools(this);
		this._graphing = new Graphing(this);
		this._mm = new MemoryMonitor(this);
		this._kb = new KeyBinder(this);
		this.cl.addCLCmd("remotingSocket", function(str:String = "") {
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+|\\:").split(str));
			remotingSocket(_loc2_[0], ASCompat.toInt(_loc2_[1]));
		}, "Connect to socket remote. /remotingSocket ip port");
		if (ASCompat.stringAsBool(this._config.sharedObjectName)) {
			try {
				this._so = SharedObject.getLocal(this._config.sharedObjectName, this._config.sharedObjectPath);
				this._soData = this._so.data;
			} catch (e:Dynamic) {}
		}
		this._config.style.updateStyleSheet();
		this._panels = new PanelsManager(this);
		if (ASCompat.stringAsBool(password)) {
			this.visible = false;
		}
		this.report("<b>Console v"
			+ VERSION
			+ VERSION_STAGE
			+ "</b> build "
			+ BUILD
			+ ". "
			+ Capabilities.playerType
			+ " "
			+ Capabilities.version
			+ ".", -2);
		addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
		addEventListener(Event.ADDED_TO_STAGE, this.stageAddedHandle);
	}

	public static function MakeChannelName(obj:ASAny):String {
		if (Std.isOfType(obj, String)) {
			return ASCompat.asString(obj);
		}
		if (ASCompat.toBool(obj)) {
			return LogReferences.ShortClassName(obj);
		}
		return DEFAULT_CHANNEL;
	}

	function stageAddedHandle(e:Event = null) {
		if (this._cl.base == null) {
			this._cl.base = parent;
		}
		if (loaderInfo != null) {
			this.listenUncaughtErrors(loaderInfo);
		}
		removeEventListener(Event.ADDED_TO_STAGE, this.stageAddedHandle);
		addEventListener(Event.REMOVED_FROM_STAGE, this.stageRemovedHandle);
		stage.addEventListener(Event.MOUSE_LEAVE, this.onStageMouseLeave, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, this._kb.keyDownHandler, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_UP, this._kb.keyUpHandler, false, 0, true);
	}

	function stageRemovedHandle(e:Event = null) {
		this._cl.base = null;
		removeEventListener(Event.REMOVED_FROM_STAGE, this.stageRemovedHandle);
		addEventListener(Event.ADDED_TO_STAGE, this.stageAddedHandle);
		stage.removeEventListener(Event.MOUSE_LEAVE, this.onStageMouseLeave);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, this._kb.keyDownHandler);
		stage.removeEventListener(KeyboardEvent.KEY_UP, this._kb.keyUpHandler);
	}

	function onStageMouseLeave(e:Event) {
		this._panels.tooltip(null);
	}

	public function listenUncaughtErrors(loaderinfo:LoaderInfo) {
		var uncaughtErrorEvents:IEventDispatcher = null;
		try {
			uncaughtErrorEvents = ASCompat.dynamicAs((loaderinfo : ASAny)["uncaughtErrorEvents"], flash.events.IEventDispatcher);
			if (uncaughtErrorEvents != null) {
				uncaughtErrorEvents.addEventListener("uncaughtError", this.uncaughtErrorHandle, false, 0, true);
			}
		} catch (err:Dynamic) {}
	}

	function uncaughtErrorHandle(e:Event) {
		var _loc3_:String = null;
		var _loc2_:ASAny = (e : ASAny).hasOwnProperty("error") ? (e : ASAny)["error"] : e;
		if (Std.isOfType(_loc2_, Error)) {
			_loc3_ = this._refs.makeString(_loc2_);
		} else if (Std.isOfType(_loc2_, ErrorEvent)) {
			_loc3_ = cast(_loc2_, ErrorEvent).text;
		}
		if (!ASCompat.stringAsBool(_loc3_)) {
			_loc3_ = ASCompat.toString(_loc2_);
		}
		this.report(_loc3_, (FATAL : Int), false);
	}

	public function addGraph(name:String, obj:ASObject, property:String, color:Float = -1, key:String = null, rect:Rectangle = null, inverse:Bool = false) {
		this._graphing.add(name, obj, property, color, key, rect, inverse);
	}

	public function fixGraphRange(name:String, min:Float = null, max:Float = null) {
		if (min == null)
			min = Math.NaN;
		if (max == null)
			max = Math.NaN;
		this._graphing.fixRange(name, min, max);
	}

	public function removeGraph(name:String, obj:ASObject = null, property:String = null) {
		this._graphing.remove(name, obj, property);
	}

	public function bindKey(key:KeyBind, callback:ASFunction, args:Array<ASAny> = null) {
		if (key != null) {
			this._kb.bindKey(key, callback, args);
		}
	}

	public function addMenu(key:String, callback:ASFunction, args:Array<ASAny> = null, rollover:String = null) {
		this.panels.mainPanel.addMenu(key, callback, args, rollover);
	}

	@:isVar public var displayRoller(get, set):Bool;

	public function get_displayRoller():Bool {
		return this._panels.displayRoller;
	}

	function set_displayRoller(b:Bool):Bool {
		return this._panels.displayRoller = b;
	}

	public function setRollerCaptureKey(char:String, shift:Bool = false, ctrl:Bool = false, alt:Bool = false) {
		if (this._rollerKey != null) {
			this.bindKey(this._rollerKey, null);
			this._rollerKey = null;
		}
		if (ASCompat.stringAsBool(char) && char.length == 1) {
			this._rollerKey = new KeyBind(char, shift, ctrl, alt);
			this.bindKey(this._rollerKey, this.onRollerCaptureKey);
		}
	}

	@:isVar public var rollerCaptureKey(get, never):KeyBind;

	public function get_rollerCaptureKey():KeyBind {
		return this._rollerKey;
	}

	function onRollerCaptureKey() {
		if (this.displayRoller) {
			this.report("Display Roller Capture:<br/>" + cast(this._panels.getPanel(RollerPanel.NAME), RollerPanel).getMapString(true), -1);
		}
	}

	@:isVar public var fpsMonitor(get, set):Bool;

	public function get_fpsMonitor():Bool {
		return this._graphing.fpsMonitor;
	}

	function set_fpsMonitor(b:Bool):Bool {
		return this._graphing.fpsMonitor = b;
	}

	@:isVar public var memoryMonitor(get, set):Bool;

	public function get_memoryMonitor():Bool {
		return this._graphing.memoryMonitor;
	}

	function set_memoryMonitor(b:Bool):Bool {
		return this._graphing.memoryMonitor = b;
	}

	public function watch(object:ASObject, name:String = null):String {
		return this._mm.watch(object, name);
	}

	public function unwatch(name:String) {
		this._mm.unwatch(name);
	}

	public function gc() {
		this._mm.gc();
	}

	public function store(name:String, obj:ASObject, strong:Bool = false) {
		this._cl.store(name, obj, strong);
	}

	public function map(container:DisplayObjectContainer, maxstep:UInt = (0 : UInt)) {
		this._tools.map(container, maxstep, DEFAULT_CHANNEL);
	}

	public function mapch(channel:ASAny, container:DisplayObjectContainer, maxstep:UInt = (0 : UInt)) {
		this._tools.map(container, maxstep, MakeChannelName(channel));
	}

	public function inspect(obj:ASObject, showInherit:Bool = true) {
		this._refs.inspect(obj, showInherit, DEFAULT_CHANNEL);
	}

	public function inspectch(channel:ASAny, obj:ASObject, showInherit:Bool = true) {
		this._refs.inspect(obj, showInherit, MakeChannelName(channel));
	}

	public function explode(obj:ASObject, depth:Int = 3) {
		this.addLine([this._tools.explode(obj, depth)], 1, null, false, true);
	}

	public function explodech(channel:ASAny, obj:ASObject, depth:Int = 3) {
		this.addLine([this._tools.explode(obj, depth)], 1, channel, false, true);
	}

	@:isVar public var paused(get, set):Bool;

	public function get_paused():Bool {
		return this._paused;
	}

	function set_paused(newV:Bool):Bool {
		if (this._paused == newV) {
			return newV;
		}
		if (newV) {
			this.report("Paused", 10);
		} else {
			this.report("Resumed", -1);
		}
		this._paused = newV;
		this._panels.mainPanel.setPaused(newV);
		return newV;
	}

	override public function get_width():Float {
		return this._panels.mainPanel.width;
	}

	override public function set_width(newW:Float) {
		return this._panels.mainPanel.width = newW;
	}

	override public function set_height(newW:Float) {
		return this._panels.mainPanel.height = newW;
	}

	override public function get_height():Float {
		return this._panels.mainPanel.height;
	}

	override public function get_x():Float {
		return this._panels.mainPanel.x;
	}

	override public function set_x(newW:Float) {
		return this._panels.mainPanel.x = newW;
	}

	override public function set_y(newW:Float) {
		return this._panels.mainPanel.y = newW;
	}

	override public function get_y():Float {
		return this._panels.mainPanel.y;
	}

	override public function set_visible(v:Bool) {
		super.visible = v;
		if (v) {
			this._panels.mainPanel.visible = true;
		}
		return v;
	}

	function _onEnterFrame(e:Event) {
		var _loc4_:Array<ASAny> = null;
		var _loc2_ = flash.Lib.getTimer();
		var _loc3_ = this._logs.update((_loc2_ : UInt));
		this._refs.update((_loc2_ : UInt));
		this._mm.update();
		if (this.remoter.remoting != Remoting.RECIEVER) {
			_loc4_ = this._graphing.update(stage != null ? stage.frameRate : 0);
		}
		this._remoter.update();
		if (visible && parent != null) {
			if (this.config.alwaysOnTop && parent.getChildAt(parent.numChildren - 1) != this && this._topTries > 0) {
				--this._topTries;
				parent.addChild(this);
				this.report("Moved console on top (alwaysOnTop enabled), " + this._topTries + " attempts left.", -1);
			}
			this._panels.update(this._paused, _loc3_);
			if (_loc4_ != null) {
				this._panels.updateGraphs(_loc4_);
			}
		}
	}

	@:isVar public var remoting(get, set):Bool;

	public function get_remoting():Bool {
		return this._remoter.remoting == Remoting.SENDER;
	}

	function set_remoting(b:Bool):Bool {
		this._remoter.remoting = b ? Remoting.SENDER : Remoting.NONE;
		return b;
	}

	public function remotingSocket(host:String, port:Int) {
		this._remoter.remotingSocket(host, port);
	}

	public function setViewingChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		Reflect.callMethod(this, this._panels.mainPanel.setViewingChannels, rest);
	}

	public function setIgnoredChannels(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		Reflect.callMethod(this, this._panels.mainPanel.setIgnoredChannels, rest);
	}

	@:isVar public var minimumPriority(never, set):UInt;

	public function set_minimumPriority(level:UInt):UInt {
		return this._panels.mainPanel.priority = level;
	}

	public function report(obj:ASAny, priority:Int = 0, skipSafe:Bool = true, channel:String = null) {
		if (!ASCompat.stringAsBool(channel)) {
			channel = this._panels.mainPanel.reportChannel;
		}
		this.addLine([obj], priority, channel, false, skipSafe, 0);
	}

	public function addLine(strings:Array<ASAny>, priority:Int = 0, channel:ASAny = null, isRepeating:Bool = false, html:Bool = false, stacks:Int = -1) {
		var _loc7_ = "";
		var _loc8_ = strings.length;
		var _loc9_ = 0;
		while (_loc9_ < _loc8_) {
			_loc7_ += (_loc9_ != 0 ? " " : "") + this._refs.makeString(strings[_loc9_], null, html);
			_loc9_ = ASCompat.toInt(_loc9_) + 1;
		}
		if (priority >= this._config.autoStackPriority && stacks < 0) {
			stacks = this._config.defaultStackDepth;
		}
		if (!html && stacks > 0) {
			_loc7_ += this._tools.getStack(stacks, priority);
		}
		this._logs.add(new Log(_loc7_, MakeChannelName(channel), priority, isRepeating, html));
	}

	@:isVar public var commandLine(get, set):Bool;

	public function set_commandLine(b:Bool):Bool {
		return this._panels.mainPanel.commandLine = b;
	}

	function get_commandLine():Bool {
		return this._panels.mainPanel.commandLine;
	}

	public function addSlashCommand(name:String, callback:ASFunction, desc:String = "", alwaysAvailable:Bool = true, endOfArgsMarker:String = ";") {
		this._cl.addSlashCommand(name, callback, desc, alwaysAvailable, endOfArgsMarker);
	}

	public function add(string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		this.addLine([string], priority, DEFAULT_CHANNEL, isRepeating);
	}

	public function stack(string:ASAny, depth:Int = -1, priority:Int = 5) {
		this.addLine([string], priority, DEFAULT_CHANNEL, false, false, depth >= 0 ? depth : this._config.defaultStackDepth);
	}

	public function stackch(channel:ASAny, string:ASAny, depth:Int = -1, priority:Int = 5) {
		this.addLine([string], priority, channel, false, false, depth >= 0 ? depth : this._config.defaultStackDepth);
	}

	public function log(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (LOG : Int));
	}

	public function info(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (INFO : Int));
	}

	public function debug(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (DEBUG : Int));
	}

	public function warn(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (WARN : Int));
	}

	public function error(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (ERROR_cpp : Int));
	}

	public function fatal(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (FATAL : Int));
	}

	public function ch(channel:ASAny, string:ASAny, priority:Int = 2, isRepeating:Bool = false) {
		this.addLine([string], priority, channel, isRepeating);
	}

	public function logch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (LOG : Int), channel);
	}

	public function infoch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (INFO : Int), channel);
	}

	public function debugch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (DEBUG : Int), channel);
	}

	public function warnch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (WARN : Int), channel);
	}

	public function errorch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (ERROR_cpp : Int), channel);
	}

	public function fatalch(channel:ASAny, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, (FATAL : Int), channel);
	}

	public function addCh(channel:ASAny, strings:Array<ASAny>, priority:Int = 2, isRepeating:Bool = false) {
		this.addLine(strings, priority, channel, isRepeating);
	}

	public function addHTML(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, 2, DEFAULT_CHANNEL, false, this.testHTML(rest));
	}

	public function addHTMLch(channel:ASAny, priority:Int, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		this.addLine(rest, priority, channel, false, this.testHTML(rest));
	}

	function testHTML(args:Array<ASAny>):Bool {
		try {
			new compat.XML("<p>" + args.join("") + "</p>");
		} catch (err:Dynamic) {
			return false;
		}
		return true;
	}

	public function clear(channel:String = null) {
		this._logs.clear(channel);
		if (!this._paused) {
			this._panels.mainPanel.updateToBottom();
		}
		this._panels.updateMenu();
	}

	public function getAllLog(splitter:String = "\r\n"):String {
		return this._logs.getLogsAsString(splitter);
	}

	@:isVar public var config(get, never):ConsoleConfig;

	public function get_config():ConsoleConfig {
		return this._config;
	}

	@:isVar public var panels(get, never):PanelsManager;

	public function get_panels():PanelsManager {
		return this._panels;
	}

	@:isVar public var cl(get, never):CommandLine;

	public function get_cl():CommandLine {
		return this._cl;
	}

	@:isVar public var remoter(get, never):Remoting;

	public function get_remoter():Remoting {
		return this._remoter;
	}

	@:isVar public var graphing(get, never):Graphing;

	public function get_graphing():Graphing {
		return this._graphing;
	}

	@:isVar public var refs(get, never):LogReferences;

	public function get_refs():LogReferences {
		return this._refs;
	}

	@:isVar public var logs(get, never):Logs;

	public function get_logs():Logs {
		return this._logs;
	}

	@:isVar public var mapper(get, never):ConsoleTools;

	public function get_mapper():ConsoleTools {
		return this._tools;
	}

	@:isVar public var so(get, never):ASObject;

	public function get_so():ASObject {
		return this._soData;
	}

	public function updateSO(key:String = null) {
		if (this._so != null) {
			if (ASCompat.stringAsBool(key)) {
				this._so.setDirty(key);
			} else {
				this._so.clear();
			}
		}
	}
}
