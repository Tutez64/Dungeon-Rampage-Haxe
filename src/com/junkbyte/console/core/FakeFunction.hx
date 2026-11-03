package com.junkbyte.console.core;

import flash.Boot;

class FakeFunction {
	public var run:ASAny;

	public var line:String;

	public function new(r:ASAny = /*undefined*/ null, l:String = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		run = r;
		line = l;
	}

	public function exec(..._rest:ASAny):ASAny {
		var rest = ASCompat.restToArray(_rest);
		return run(line, rest);
	}
}
