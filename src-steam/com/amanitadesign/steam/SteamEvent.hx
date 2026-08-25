package com.amanitadesign.steam;

import flash.events.Event;

class SteamEvent extends Event {
	public static var STEAM_RESPONSE:String = "steamResponse";

	var _req_type:Int = -1;

	var _response:Int = -1;

	var _data:ASAny = null;

	public function new(type:String, req_type:Int, response:Int, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		_response = response;
		_req_type = req_type;
	}

	@:isVar public var response(get, never):Int;

	public function get_response():Int {
		return _response;
	}

	@:isVar public var data(get, set):ASAny;

	public function get_data():ASAny {
		return _data;
	}

	function set_data(value:ASAny):ASAny {
		return _data = value;
	}

	@:isVar public var req_type(get, never):Int;

	public function get_req_type():Int {
		return _req_type;
	}

	override public function clone():Event {
		var _loc1_ = new SteamEvent(type, req_type, response, bubbles, cancelable);
		_loc1_.data = data;

		return _loc1_;
	}
}
