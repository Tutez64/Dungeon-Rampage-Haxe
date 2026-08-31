package generatedCode;

import brain.gameObject.GameObject;

interface IPresenceManager {
	function setNetworkComponentPresenceManager(iface:PresenceManagerNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	function friendState(yesno:UInt, who:UInt, state:UInt):Void;
}
