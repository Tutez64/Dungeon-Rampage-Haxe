package com.junkbyte.console.utils;

import flash.Boot;

class RegexResult {
	public var index:Int = 0;

	public var elements:Array<ASAny>;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		index = 0;
		elements = [];
	}
}
