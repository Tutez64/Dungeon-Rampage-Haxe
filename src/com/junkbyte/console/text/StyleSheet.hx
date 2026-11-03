package com.junkbyte.console.text;

import flash.Boot;
import flash.text.StyleSheet;

class StyleSheet extends flash.text.StyleSheet {
	public override function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}
}
