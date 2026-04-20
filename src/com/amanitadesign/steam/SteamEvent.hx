package com.amanitadesign.steam;

import flash.events.Event;

class SteamEvent extends Event {
    public static var STEAM_RESPONSE:String = "steamResponse";

    public var req_type:Int;
    public var response:Int;
    public var data:ASAny;

    public function new(type:String, reqType:Int, responseCode:Int, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);
        this.req_type = reqType;
        this.response = responseCode;
        this.data = null;
    }

    override public function clone():Event {
        var e = new SteamEvent(type, req_type, response, bubbles, cancelable);
        e.data = data;
        return e;
    }
}
