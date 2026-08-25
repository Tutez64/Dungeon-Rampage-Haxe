package com.junkbyte.console;

class ConsoleConfig {
	public var keystrokePassword:String;

	public var remotingPassword:String;

	public var maxLines:UInt = (1000 : UInt);

	public var maxRepeats:Int = 75;

	public var autoStackPriority:Int = (Console.FATAL : Int);

	public var defaultStackDepth:Int = 2;

	public var useObjectLinking:Bool = true;

	public var objectHardReferenceTimer:UInt = (0 : UInt);

	public var tracing:Bool = false;

	public function traceCall(ch:String, line:String, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		trace("[" + ch + "] " + line);
	}

	public var showTimestamp:Bool = false;

	public function timeStampFormatter(timer:UInt):String {
		var _loc2_ = (Std.int(timer * 0.001) : UInt);
		return this.makeTimeDigit((Std.int(_loc2_ / 60) : UInt)) + ":" + this.makeTimeDigit(_loc2_ % 60);
	}

	public var showLineNumber:Bool = false;

	public var remotingConnectionName:String = "_Console";

	public var allowedRemoteDomain:String = "*";

	public var commandLineAllowed:Bool = false;

	public var commandLineAutoScope:Bool = false;

	public var commandLineInputPassThrough:ASFunction;

	public var commandLineAutoCompleteEnabled:Bool = true;

	public var keyBindsEnabled:Bool = true;

	public var displayRollerEnabled:Bool = true;

	public var rulerToolEnabled:Bool = true;

	public var rulerHidesMouse:Bool = true;

	public var sharedObjectName:String = "com.junkbyte/Console/UserData";

	public var sharedObjectPath:String = "/";

	public var rememberFilterSettings:Bool = false;

	public var alwaysOnTop:Bool = true;

	var _style:ConsoleStyle;

	public function new() {
		this._style = new ConsoleStyle();
	}

	function makeTimeDigit(v:UInt):String {
		if (v < 10) {
			return "0" + v;
		}
		return Std.string(v);
	}

	@:isVar public var style(get, never):ConsoleStyle;

	public function get_style():ConsoleStyle {
		return this._style;
	}
}
