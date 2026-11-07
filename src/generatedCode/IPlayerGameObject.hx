package generatedCode;

import brain.gameObject.GameObject;

interface IPlayerGameObject {
	function setNetworkComponentPlayerGameObject(iface:PlayerGameObjectNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	@:isVar var screenName(never, set):String;

	@:isVar var heroPreloadLook(never, set):HeroPreloadLook;

	function Chat(text:String):Void;

	function ShowPlayerIsTyping(value:UInt):Void;
}
