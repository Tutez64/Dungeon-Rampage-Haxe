package generatedCode;

import brain.gameObject.GameObject;

interface IMatchMaker {
	function setNetworkComponentMatchMaker(iface:MatchMakerNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	function InfiniteDetails(value_0:Vector<InfiniteMapNodeDetail>):Void;

	function ClientRequestEntryResponce(ResponceCode:UInt, truenode:UInt):Void;

	function ClientExitComplete(ResponceCode:UInt):Void;

	function ClientInformPartyComposition(partyMembers:Vector<GameServerPartyMember>):Void;
}
