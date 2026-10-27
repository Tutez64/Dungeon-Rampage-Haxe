package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.ConsoleConfig;
import flash.events.EventDispatcher;

class ConsoleCore extends EventDispatcher {
	var console:Console;

	var config:ConsoleConfig;

	public function new(c:Console) {
		super();
		this.console = c;
		this.config = this.console.config;
	}

	@:isVar var remoter(get, never):Remoting;

	function get_remoter():Remoting {
		return this.console.remoter;
	}

	function report(obj:ASAny = "", priority:Int = 0, skipSafe:Bool = true, ch:String = null) {
		this.console.report(obj, priority, skipSafe, ch);
	}
}
