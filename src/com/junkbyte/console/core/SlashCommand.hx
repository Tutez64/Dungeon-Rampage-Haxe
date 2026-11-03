package com.junkbyte.console.core;

import flash.Boot;

class SlashCommand {
	public var user:Bool = false;

	public var n:String;

	public var f:ASAny;

	public var endMarker:String;

	public var d:String;

	public var allow:Bool = false;

	public function new(nn:String = /*undefined*/ null, ff:ASAny = /*undefined*/ null, dd:String = /*undefined*/ null, cus:Bool = false, permit:Bool = false,
			argsMarker:String = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		n = nn;
		f = ff;
		d = dd != null ? dd : "";
		user = cus;
		allow = permit;
		endMarker = argsMarker;
	}
}
