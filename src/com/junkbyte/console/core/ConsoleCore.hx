package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.ConsoleConfig;
import flash.events.EventDispatcher;

class ConsoleCore extends EventDispatcher {
	public var console:Console;

	public var config:ConsoleConfig;

	public function new(c:Console = /*undefined*/ null) {
		super();
		console = c;
		config = console.get_config();
	}

	public function report(obj:ASAny = /*undefined*/ null, priority:Int = 0, skipSafe:Bool = true, ch:String = /*undefined*/ null) {
		if (obj == null) {
			obj = "";
		}
		console.report(obj, priority, skipSafe, ch);
	}

	@:isVar public var remoter(get, never):Remoting;

	public function get_remoter():Remoting {
		return console.get_remoter();
	}
}
