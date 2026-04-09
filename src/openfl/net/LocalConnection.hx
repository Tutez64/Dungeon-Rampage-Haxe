package openfl.net;

import openfl.events.EventDispatcher;
import openfl.events.StatusEvent;

class LocalConnection extends EventDispatcher {
	public var client:Dynamic;

	public function new() {
		super();
	}

	public function allowDomain(domain:String):Void {}

	public function allowInsecureDomain(domain:String):Void {}

	public function connect(connectionName:String):Void {}

	public function close():Void {}

	public function send(connectionName:String, methodName:String, args:haxe.extern.Rest<Dynamic>):Void {
		dispatchEvent(new StatusEvent(StatusEvent.STATUS, false, false, "", "error"));
	}
}
