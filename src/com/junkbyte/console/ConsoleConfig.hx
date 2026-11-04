package com.junkbyte.console;

class ConsoleConfig {
	public var useObjectLinking:Bool = false;

	public var tracing:Bool = false;

	public var traceCall:ASAny;

	public var timeStampFormatter:ASAny;

	public var showTimestamp:Bool = false;

	public var showLineNumber:Bool = false;

	public var sharedObjectPath:String;

	public var sharedObjectName:String;

	public var rulerToolEnabled:Bool = false;

	public var rulerHidesMouse:Bool = false;

	public var remotingPassword:String;

	public var remotingConnectionName:String;

	public var rememberFilterSettings:Bool = false;

	public var objectHardReferenceTimer:UInt = 0;

	public var maxRepeats:Int = 0;

	public var maxLines:UInt = 0;

	public var keystrokePassword:String;

	public var keyBindsEnabled:Bool = false;

	public var displayRollerTilemapCapturingEnabled:Bool = false;

	public var displayRollerEnabled:Bool = false;

	public var defaultStackDepth:Int = 0;

	public var commandLineInputPassThrough:ASAny;

	public var commandLineAutoScope:Bool = false;

	public var commandLineAutoCompleteEnabled:Bool = false;

	public var commandLineAllowed:Bool = false;

	public var autoStackPriority:Int = 0;

	public var alwaysOnTop:Bool = false;

	public var allowedRemoteDomain:String;

	public var _style:ConsoleStyle;

	public function new() {
		alwaysOnTop = true;
		sharedObjectPath = "/";
		sharedObjectName = "com.junkbyte/Console/UserData";
		rulerHidesMouse = true;
		rulerToolEnabled = true;
		displayRollerTilemapCapturingEnabled = false;
		displayRollerEnabled = true;
		keyBindsEnabled = true;
		commandLineAutoCompleteEnabled = true;
		allowedRemoteDomain = "*";
		remotingConnectionName = "_Console";
		showLineNumber = false;
		timeStampFormatter = function(timer:UInt):String {
			var _loc2_ = (ASCompat.floatToInt(timer * 0.001) : UInt);
			return ConsoleConfig.makeTimeDigit((ASCompat.floatToInt(_loc2_ / 60) : UInt)) + ":" + ConsoleConfig.makeTimeDigit((_loc2_ % 60 : UInt));
		};
		showTimestamp = false;
		traceCall = Reflect.makeVarArgs(function(__args:Array<ASAny>) {
			var ch:String = __args[0];
			var line:String = __args[1];
			var _rest = __args.slice(2);
			var rest = ASCompat.restToArray(_rest);
			trace("[" + ch + "] " + line);
		});
		objectHardReferenceTimer = (0 : UInt);
		useObjectLinking = true;
		defaultStackDepth = 2;
		autoStackPriority = 10;
		maxRepeats = 75;
		maxLines = (1000 : UInt);
		_style = new ConsoleStyle();
	}

	public static function makeTimeDigit(v:UInt):String {
		if (v < 10) {
			return "0" + ("" + v);
		}
		return "" + v;
	}

	@:isVar public var style(get, never):ConsoleStyle;

	public function get_style():ConsoleStyle {
		return _style;
	}
}
