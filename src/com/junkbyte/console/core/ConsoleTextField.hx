package com.junkbyte.console.core;

import flash.Boot;
import flash.text.TextField;

class ConsoleTextField extends TextField {
	public function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}
}
