package networkCode.transport;

import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

interface IGameTransport extends IEventDispatcher {
	function connect():Void;

	function send(bytes:ByteArray):Void;

	function sendText(text:String):Void;

	function close():Void;

	function abandon():Void;

	@:isVar var connected(get, never):Bool;

	@:isVar var supportsSessions(get, never):Bool;

	@:isVar var name(get, never):String;
}
