package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.compat.ConsoleLib;
import com.junkbyte.console.utils.FlashRegex;
import com.junkbyte.console.vos.WeakObject;
import com.junkbyte.console.vos.WeakRef;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.utils.ByteArray;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class CommandLine extends ConsoleCore {
	public static var DISABLED:String = "<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.";

	public static var RESERVED:Array<ASAny>;

	public var localCommands:Array<ASAny>;

	public var _slashCmds:IMap<ASAny, ASAny>;

	public var _scopeStr:String;

	public var _scope:ASAny;

	public var _saved:WeakObject;

	public var _prevScope:WeakRef;

	public var _hiddenCmds:Array<ASAny>;

	public function new(m:Console = /*undefined*/ null) {
		var _gthis:CommandLine;
		localCommands = ["filter", "filterexp"];
		_hiddenCmds = [];
		_scopeStr = "";
		_gthis = this;
		super(m);
		_saved = new WeakObject();
		_scope = m;
		_slashCmds = new StringMap<ASAny>();
		_prevScope = new WeakRef(m);
		_saved.set("C", m);
		get_remoter().registerCallback("cmd", function(bytes:ByteArray) {
			_gthis.run(bytes.readUTF());
		});
		get_remoter().registerCallback("scope", function(bytes:ByteArray) {
			_gthis.handleScopeEvent(bytes.readUnsignedInt());
		});
		get_remoter().registerCallback("cls", handleScopeString);
		get_remoter().addEventListener(Event.CONNECT, sendCmdScope2Remote);
		addCLCmd("help", printHelp, "How to use command line");
		addCLCmd("save|store", saveCmd, "Save current scope as weak reference. (same as Cc.store(...))");
		addCLCmd("savestrong|storestrong", saveStrongCmd, "Save current scope as strong reference");
		addCLCmd("saved|stored", savedCmd, "Show a list of all saved references");
		addCLCmd("string", stringCmd, "Create String, useful to paste complex strings without worrying about \" or \'", false, null);
		addCLCmd("commands", cmdsCmd, "Show a list of all slash commands", true);
		addCLCmd("inspect", inspectCmd, "Inspect current scope");
		addCLCmd("explode", explodeCmd, "Explode current scope to its properties and values (similar to JSON)");
		addCLCmd("map", mapCmd, "Get display list map starting from current scope");
		addCLCmd("function", funCmd, "Create function. param is the commandline string to create as function. (experimental)");
		addCLCmd("autoscope", autoscopeCmd, "Toggle autoscoping.");
		addCLCmd("base", baseCmd, "Return to base scope");
		addCLCmd("/", prevCmd, "Return to previous scope");
	}

	public function stringCmd(param:String) {
		report("String with " + param.length + " chars entered. Use /save <i>(name)</i> to save.", -2);
		setReturned(param, true);
	}

	public function store(n:String, obj:ASAny, strong:Bool = false) {
		if (n == null || n == "") {
			report("ERROR: Give a name to save.", 10);
			return;
		}
		if (Type.typeof(obj) == Type.ValueType.TFunction) {
			strong = true;
		}
		n = FlashRegex.replace(n, new EReg("[^\\w]*", "g"), "");
		if (CommandLine.RESERVED.indexOf(n) >= 0) {
			report("ERROR: The name [" + n + "] is reserved", 10);
			return;
		}
		_saved.set(n, obj, strong);
	}

	@:isVar public var base(get, set):ASAny;

	public function set_base(obj:ASAny):ASAny {
		if (ASCompat.toBool(get_base())) {
			report("Set new commandLine base from " + Std.string(get_base()) + " to " + Std.string(obj), 10);
		} else {
			_prevScope.set_reference(_scope);
			_scope = obj;
			_scopeStr = LogReferences.ShortClassName(obj, false);
		}
		_saved.set("base", obj);
		return obj;
	}

	public function setReturned(returned:ASAny, changeScope:Bool = false, say:Bool = true) {
		if (!config.commandLineAllowed) {
			report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",
				9);
			return;
		}
		if (ConsoleLib.typeOf(returned) != "undefined") {
			_saved.set("returned", returned, true);
			if (changeScope && !ConsoleLib.strictEquals(returned, _scope)) {
				_prevScope.set_reference(_scope);
				_scope = returned;
				if (get_remoter().get_remoting() != 2) {
					_scopeStr = LogReferences.ShortClassName(_scope, false);
					sendCmdScope2Remote();
				}
				report("Changed to " + console.get_refs().makeRefTyped(returned), -1);
			} else if (say) {
				report("Returned " + console.get_refs().makeString(returned), -1);
			}
		} else if (say) {
			report("Exec successful, undefined return.", -1);
		}
	}

	public function sendCmdScope2Remote(e:Event = /*undefined*/ null) {
		var _loc2_ = new ByteArray();
		_loc2_.writeUTF(_scopeStr);
		console.get_remoter().send("cls", _loc2_);
	}

	public function savedCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_ = ASCompat.dynamicAs(null, WeakRef);
		report("Saved vars: ", -1);
		var _loc3_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		var _loc5_ = 0;
		var _loc6_ = _saved.keys();
		while (_loc5_ < _loc6_.length) {
			_loc7_ = _loc6_[_loc5_];
			_loc5_++;
			_loc8_ = _saved.getWeakRef(_loc7_);
			_loc3_ += (1 : UInt);
			if (_loc8_.get_reference() == null) {
				_loc4_ += (1 : UInt);
			}
			report((ASCompat.toBool(_loc8_.get_strong()) ? "strong" : "weak")
				+ " <b>$"
				+ Std.string(_loc7_)
				+ "</b> = "
				+ console.get_refs().makeString(_loc8_.get_reference()),
				-2);
		}
		report("Found " + ("" + _loc3_) + " item(s), " + ("" + _loc4_) + " empty.", -1);
	}

	public function saveStrongCmd(param:String = /*undefined*/ null) {
		store(param, _scope, true);
	}

	public function saveCmd(param:String = /*undefined*/ null) {
		store(param, _scope, false);
	}

	public function run(str:String, saves:ASAny = /*undefined*/ null):ASAny {
		var _loc4_ = (null : ByteArray);
		var _loc6_ = ASCompat.dynamicAs(null, Executer);
		var _loc7_ = 0;
		var _loc8_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc9_:ASAny = ASCompat.asString(null);
		var _loc10_ = ASCompat.dynamicAs(null, Error);
		if (str == null || str == "") {
			return null;
		}
		str = FlashRegex.replace(str, new EReg("\\s*", ""), "");
		if (get_remoter().get_remoting() == 2) {
			if (str.charAt(0) == "~") {
				str = str.substring(1);
			} else if (FlashRegex.search(str, new EReg("\\/" + localCommands.join("|\\/"), "")) != 0) {
				report("Run command at remote: " + str, -2);
				_loc4_ = new ByteArray();
				_loc4_.writeUTF(str);
				if (!console.get_remoter().send("cmd", _loc4_)) {
					report("Command could not be sent to client.", 10);
				}
				return null;
			}
		}
		report("&gt; " + str, 4, false);
		var _loc5_:ASAny = null;
		try {
			if (str.charAt(0) == "/") {
				execCommand(str.substring(1));
			} else {
				if (!config.commandLineAllowed) {
					report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",
						9);
					return null;
				}
				_loc6_ = new Executer();
				_loc6_.addEventListener(Event.COMPLETE, onExecLineComplete, false, 0, true);
				if (saves != null) {
					_loc7_ = 0;
					_loc8_ = _saved.keys();
					while (_loc7_ < ASCompat.toInt(_loc8_.length)) {
						_loc9_ = _loc8_[_loc7_];
						_loc7_++;
						if (!ConsoleLib.truthy(Reflect.field(saves, _loc9_))) {
							saves[_loc9_] = _saved.get(_loc9_);
						}
					}
				} else {
					saves = _saved;
				}
				_loc6_.setStored(saves);
				_loc6_.setReserved(CommandLine.RESERVED);
				ASCompat.setProperty(_loc6_, "autoScope", config.commandLineAutoScope);
				_loc5_ = _loc6_.exec(_scope, str);
			}
		} catch (_loc_e_:Dynamic) {
			_loc10_ = _loc_e_;
			reportError(_loc10_);
		}
		return _loc5_;
	}

	public function reportError(e:Error) {
		var _loc11_ = 0;
		var _loc12_:ASAny = ASCompat.asString(null);
		var _loc2_ = console.get_refs().makeString(e);
		var _loc3_ = FlashRegex.split(_loc2_, new EReg("\n\\s*", ""));
		var _loc4_ = 10;
		var _loc5_ = 0;
		var _loc6_ = _loc3_.length;
		var _loc7_:Array<ASAny> = [];
		var _loc8_ = new EReg("\\s*at\\s+("
			+ "((com.junkbyte.console.core::)?(ExeValue|Executer))"
			+ "|"
			+ ConsoleLib.getQualifiedClassName(this)
			+ ")", "");
		var _loc9_ = 0;
		var _loc10_ = _loc6_;
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc12_ = _loc3_[_loc11_];
			if (FlashRegex.search(_loc12_, _loc8_) == 0) {
				if (_loc5_ > 0 && _loc11_ > 0) {
					break;
				}
				_loc5_++;
			}
			_loc7_.push("<p" + _loc4_ + "> " + Std.string(_loc12_) + "</p" + _loc4_ + ">");
			if (_loc4_ > 6) {
				_loc4_--;
			}
		}
		report(_loc7_.join("\n"), 9);
	}

	public function printHelp(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		report("____Command Line Help___", 10);
		report("/filter (text) = filter/search logs for matching text", 5);
		report("/commands to see all slash commands", 5);
		report("Press up/down arrow keys to recall previous line", 2);
		report("__Examples:", 10);
		report("<b>stage.stageWidth</b>", 5);
		report("<b>stage.scaleMode = " + "flash" + ".display.StageScaleMode.NO_SCALE</b>", 5);
		report("<b>stage.frameRate = 12</b>", 5);
		report("__________", 10);
	}

	public function prevCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		setReturned(_prevScope.get_reference(), true);
	}

	public function onExecLineComplete(e:Event) {
		var _loc2_ = cast(e.currentTarget, Executer);
		if (_scope == _loc2_.get_scope()) {
			setReturned(_loc2_.get_returned());
		} else if (_loc2_.get_scope() == _loc2_.get_returned()) {
			setReturned(_loc2_.get_scope(), true);
		} else {
			setReturned(_loc2_.get_returned());
			setReturned(_loc2_.get_scope(), true);
		}
	}

	public function mapCmd(param:String = /*undefined*/ null) {
		if (param == null) {
			param = "0";
		}
		var _loc2_ = console;
		var _loc3_ = console.get_panels().get_mainPanel().get_reportChannel();
		var _loc4_:ASAny = _scope;
		_loc2_.mapch(_loc3_, ASCompat.dynamicAs(_loc4_, DisplayObjectContainer), (ASCompat.toInt(ConsoleLib.parseInt(param)) : UInt));
	}

	public function inspectCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		console.get_refs().focus(_scope);
	}

	public function handleScopeString(bytes:ByteArray) {
		_scopeStr = bytes.readUTF();
	}

	public function handleScopeEvent(id:UInt) {
		var _loc2_ = (null : ByteArray);
		var _loc3_:ASAny = null;
		if (get_remoter().get_remoting() == 2) {
			_loc2_ = new ByteArray();
			_loc2_.writeUnsignedInt(id);
			get_remoter().send("scope", _loc2_);
		} else {
			_loc3_ = console.get_refs().getRefById(id);
			if (ConsoleLib.truthy(_loc3_)) {
				console.get_cl().setReturned(_loc3_, true, false);
			} else {
				console.report("Reference no longer exist.", -2);
			}
		}
	}

	@:isVar public var scopeString(get, never):String;

	public function get_scopeString():String {
		if (config.commandLineAllowed) {
			return _scopeStr;
		}
		return "";
	}

	public function get_base():ASAny {
		return _saved.get("base");
	}

	public function getHintsFor(str:String, max:Int):Array<ASAny> {
		var _loc7_ = 0;
		var _loc13_:ASAny = null;
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_:ASAny = ASCompat.asString(null);
		var _loc17_:ASAny = ASCompat.asString(null);
		var _loc18_ = ASCompat.dynamicAs(null, StringMap);
		var _loc19_:ASAny = ASCompat.dynamicAs(null, SlashCommand);
		var _loc20_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc21_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc3_:Array<ASAny> = [];
		var _loc4_ = cast(_slashCmds, StringMap<Dynamic>);
		var _loc5_:ASAny = ASCompat.haxeMapStorage(_loc4_);
		var _loc6_:ASAny = null;
		_loc7_ = 0;
		var _loc8_ = false;
		var _loc9_:ASAny = _loc5_;
		var _loc10_ = _loc7_;
		var _loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		if (!_loc11_ && _loc6_ != null) {
			_loc9_ = _loc5_ = _loc6_;
			_loc10_ = _loc7_ = 0;
			_loc6_ = null;
			_loc8_ = true;
			_loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		}
		var _loc12_ = _loc10_;
		while (true) {
			_loc13_ = _loc5_;
			_loc14_ = _loc7_;
			_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			if (!_loc15_ && _loc6_ != null) {
				_loc13_ = _loc5_ = _loc6_;
				_loc14_ = _loc7_ = 0;
				_loc6_ = null;
				_loc8_ = true;
				_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			}
			_loc12_ = _loc14_;
			if (!_loc15_) {
				break;
			}
			_loc16_ = ASCompat.nextName(_loc5_, _loc12_);
			_loc7_ = _loc12_;
			if (_loc8_) {
				_loc16_ = Std.string(_loc16_).substr(1);
			}
			_loc17_ = _loc16_;
			if (_hiddenCmds.indexOf(_loc17_) < 0) {
				_loc18_ = cast(_slashCmds, StringMap<Dynamic>);
				_loc19_ = _loc18_.get(_loc17_);
				if (config.commandLineAllowed || ASCompat.toBool(_loc19_.allow)) {
					_loc3_.push(([
						"/" + Std.string(_loc17_) + " ",
						_loc19_.d != null && _loc19_.d != "" ? _loc19_.d : null
					] : Array<ASAny>));
				}
			}
		}
		if (config.commandLineAllowed) {
			_loc7_ = 0;
			_loc20_ = _saved.keys();
			while (_loc7_ < ASCompat.toInt(_loc20_.length)) {
				_loc16_ = _loc20_[_loc7_];
				_loc7_++;
				_loc3_.push(["$" + Std.string(_loc16_), LogReferences.ShortClassName(_saved.get(_loc16_))]);
			}
			if (ASCompat.toBool(_scope)) {
				_loc3_.push(["this", LogReferences.ShortClassName(_scope)]);
				_loc7_ = 0;
				_loc20_ = console.get_refs().getPossibleCalls(_scope);
				while (_loc7_ < ASCompat.toInt(_loc20_.length)) {
					_loc21_ = _loc20_[_loc7_];
					_loc7_++;
					_loc3_.push(_loc21_);
				}
			}
		}
		str = str.toLowerCase();
		_loc20_ = [];
		_loc7_ = 0;
		while (_loc7_ < _loc3_.length) {
			_loc21_ = _loc3_[_loc7_];
			_loc7_++;
			if (ASCompat.toNumber(Std.string(_loc21_[0]).toLowerCase().indexOf(str)) == 0) {
				_loc20_.push(_loc21_);
			}
		}
		ASCompat.ASArray.sort(_loc20_, function(a:Array<ASAny>, b:Array<ASAny>):Int {
			if (a[0].length < b[0].length) {
				return -1;
			}
			if (a[0].length > b[0].length) {
				return 1;
			}
			return 0;
		});
		if (max > 0 && ASCompat.toInt(_loc20_.length) > max) {
			_loc20_.splice(max, ASCompat.toInt(_loc20_.length));
			_loc20_.push(["..."]);
		}
		return _loc20_;
	}

	public function funCmd(param:String = /*undefined*/ null) {
		if (param == null) {
			param = "";
		}
		var _loc2_ = new FakeFunction(run, param);
		report("Function created. Use /savestrong <i>(name)</i> to save.", -2);
		setReturned(_loc2_.exec, true);
	}

	public function explodeCmd(param:String = /*undefined*/ null) {
		if (param == null) {
			param = "0";
		}
		var _loc2_ = ASCompat.toInt(ConsoleLib.parseInt(param));
		console.explodech(console.get_panels().get_mainPanel().get_reportChannel(), _scope, _loc2_ <= 0 ? 3 : _loc2_);
	}

	public function execCommand(str:String) {
		var _loc7_ = ASCompat.dynamicAs(null, StringMap);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, SlashCommand);
		var _loc9_:ASAny = ASCompat.asString(null);
		var _loc10_ = 0;
		var _loc11_ = ASCompat.dynamicAs(null, Error);
		var _loc3_ = FlashRegex.search(str, new EReg("[^\\w]", ""));
		var _loc4_ = str.substring(0, _loc3_ > 0 ? _loc3_ : str.length);
		if (_loc4_ == "") {
			setReturned(_saved.get("returned"), true);
			return;
		}
		var _loc5_ = _loc3_ > 0 ? str.substring(_loc3_ + 1) : "";
		var _loc6_ = cast(_slashCmds, StringMap<Dynamic>);
		if (_loc6_.get(_loc4_) != null) {
			try {
				_loc7_ = cast(_slashCmds, StringMap<Dynamic>);
				_loc8_ = _loc7_.get(_loc4_);
				if (!config.commandLineAllowed && !ASCompat.toBool(_loc8_.allow)) {
					report("<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.",
						9);
					return;
				}
				_loc9_ = null;
				if (_loc8_.endMarker != null) {
					_loc10_ = _loc5_.indexOf(_loc8_.endMarker);
					if (_loc10_ >= 0) {
						_loc9_ = _loc5_.substring(ASCompat.toInt(_loc10_ + _loc8_.endMarker.length));
						_loc5_ = _loc5_.substring(0, _loc10_);
					}
				}
				if (_loc5_.length == 0) {
					_loc8_.f();
				} else {
					_loc8_.f(_loc5_);
				}
				if (_loc9_ != null && _loc9_ != "") {
					run(_loc9_);
				}
			} catch (_loc_e_:Dynamic) {
				_loc11_ = _loc_e_;
				reportError(_loc11_);
			}
		} else {
			report("Undefined command <b>/commands</b> for list of all commands.", 10);
		}
	}

	public function cmdsCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc8_ = 0;
		var _loc13_:ASAny = null;
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_:ASAny = ASCompat.dynamicAs(null, SlashCommand);
		var _loc17_:ASAny = ASCompat.dynamicAs(null, SlashCommand);
		var _loc3_:Array<ASAny> = [];
		var _loc4_:Array<ASAny> = [];
		var _loc5_ = cast(_slashCmds, StringMap<Dynamic>);
		var _loc6_:ASAny = ASCompat.haxeMapStorage(_loc5_);
		var _loc7_:ASAny = null;
		_loc8_ = 0;
		var _loc9_:ASAny = _loc6_;
		var _loc10_ = _loc8_;
		var _loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		if (!_loc11_ && _loc7_ != null) {
			_loc9_ = _loc6_ = _loc7_;
			_loc10_ = _loc8_ = 0;
			_loc7_ = null;
			_loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		}
		var _loc12_ = _loc10_;
		while (true) {
			_loc13_ = _loc6_;
			_loc14_ = _loc8_;
			_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			if (!_loc15_ && _loc7_ != null) {
				_loc13_ = _loc6_ = _loc7_;
				_loc14_ = _loc8_ = 0;
				_loc7_ = null;
				_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			}
			_loc12_ = _loc14_;
			if (!_loc15_) {
				break;
			}
			_loc16_ = ASCompat.nextValue(_loc6_, _loc12_);
			_loc8_ = _loc12_;
			_loc17_ = _loc16_;
			if (_hiddenCmds.indexOf(_loc17_.n) < 0) {
				if (config.commandLineAllowed || ASCompat.toBool(_loc17_.allow)) {
					if (ASCompat.toBool(_loc17_.user)) {
						_loc4_.push(_loc17_);
					} else {
						_loc3_.push(_loc17_);
					}
				}
			}
		}
		var _loc18_:ASFunction = function(a:SlashCommand, b:SlashCommand):Int {
			if (a.n < b.n) {
				return -1;
			}
			if (a.n > b.n) {
				return 1;
			}
			return 0;
		};
		ASCompat.ASArray.sort(_loc3_, _loc18_);
		report("Built-in commands:" + (!config.commandLineAllowed ? " (limited permission)" : ""), 4);
		_loc8_ = 0;
		while (_loc8_ < _loc3_.length) {
			_loc16_ = _loc3_[_loc8_];
			_loc8_++;
			report("<b>/" + Std.string(_loc16_.n) + "</b> <p-1>" + Std.string(_loc16_.d) + "</p-1>", -2);
		}
		if (_loc4_.length != 0) {
			ASCompat.ASArray.sort(_loc4_, _loc18_);
			report("User commands:", 4);
			_loc8_ = 0;
			while (_loc8_ < _loc4_.length) {
				_loc16_ = _loc4_[_loc8_];
				_loc8_++;
				report("<b>/" + Std.string(_loc16_.n) + "</b> <p-1>" + Std.string(_loc16_.d) + "</p-1>", -2);
			}
		}
	}

	public function baseCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		setReturned(get_base(), true);
	}

	public function autoscopeCmd(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		config.commandLineAutoScope = !config.commandLineAutoScope;
		report("Auto-scoping <b>" + (config.commandLineAutoScope ? "enabled" : "disabled") + "</b>.", 10);
	}

	public function addSlashCommand(n:String, callback:ASAny, desc:String = /*undefined*/ null, alwaysAvailable:Bool = true,
			endOfArgsMarker:String = /*undefined*/ null) {
		var _loc7_:ASAny = ASCompat.dynamicAs(null, StringMap);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, SlashCommand);
		var _loc9_ = ASCompat.dynamicAs(null, IMap);
		if (desc == null) {
			desc = "";
		}
		if (endOfArgsMarker == null) {
			endOfArgsMarker = ";";
		}
		n = FlashRegex.replace(n, new EReg("[^\\w]*", "g"), "");
		var _loc6_ = cast(_slashCmds, StringMap<Dynamic>);
		if (_loc6_.get(n) != null) {
			_loc7_ = cast(_slashCmds, StringMap<Dynamic>);
			_loc8_ = _loc7_.get(n);
			if (!ASCompat.toBool(_loc8_.user)) {
				throw new Error("Can not alter build-in slash command [" + n + "]");
			}
		}
		if (callback == null) {
			cast(_slashCmds, StringMap<Dynamic>).remove(n);
		} else {
			_loc9_ = _slashCmds;
			_loc8_ = new SlashCommand(n, callback, LogReferences.EscHTML(desc), true, alwaysAvailable, endOfArgsMarker);
			_loc7_ = _loc9_;
			{
				_loc7_.set(n, _loc8_);
			}
		}
	}

	public function addCLCmd(n:String, callback:ASAny, desc:String, allow:Bool = false, endOfArgsMarker:String = /*undefined*/ null) {
		var _loc9_ = 0;
		var _loc10_ = ASCompat.dynamicAs(null, IMap);
		var _loc11_ = ASCompat.dynamicAs(null, SlashCommand);
		var _loc12_:ASAny = ASCompat.dynamicAs(null, StringMap);
		if (endOfArgsMarker == null) {
			endOfArgsMarker = ";";
		}
		var _loc6_:Array<ASAny> = (cast n.split("|"));
		var _loc7_ = 0;
		var _loc8_ = _loc6_.length;
		while (_loc7_ < _loc8_) {
			_loc9_ = _loc7_++;
			n = _loc6_[_loc9_];
			_loc10_ = _slashCmds;
			_loc11_ = new SlashCommand(n, callback, desc, false, allow, endOfArgsMarker);
			_loc12_ = _loc10_;
			{
				_loc12_.set(n, _loc11_);
			}
			if (_loc9_ > 0 && _hiddenCmds.indexOf(n) < 0) {
				_hiddenCmds.push(n);
			}
		}
	}

	static function __init__() {
		RESERVED = ["returned", "base", "C"];
	}
}
