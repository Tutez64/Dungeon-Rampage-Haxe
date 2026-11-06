package generatedCode;

import brain.gameObject.GameObject;

interface IDistributedDungeonSummary {
	function setNetworkComponentDistributedDungeonSummary(iface:DistributedDungeonSummaryNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	@:isVar var map_node_id(never, set):UInt;

	@:isVar var report(never, set):Vector<DungeonReport>;

	@:isVar var dungeon_name(never, set):String;

	@:isVar var dungeonSuccess(never, set):UInt;

	@:isVar var dungeonMod1(never, set):UInt;

	@:isVar var dungeonMod2(never, set):UInt;

	@:isVar var dungeonMod3(never, set):UInt;

	@:isVar var dungeonMod4(never, set):UInt;

	function TransactionResponse(account_id:UInt, succeeded:UInt, offer_id:UInt, weapon_id:UInt):Void;
}
