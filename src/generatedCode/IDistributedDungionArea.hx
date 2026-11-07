package generatedCode;

import brain.gameObject.GameObject;

interface IDistributedDungionArea {
	function setNetworkComponentDistributedDungionArea(iface:DistributedDungionAreaNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	function tileLibrary(tileLibrary:Vector<Swrapper>):Void;

	@:isVar var cacheNpc(never, set):Vector<UInt>;

	@:isVar var cacheSWC(never, set):Vector<Swrapper>;

	function floorReward(mapReward:UInt):Void;

	function floorEnding(timeUntilTransition:UInt):Void;

	function dungeonEnding(timeUntilTransition:UInt, victory:UInt):Void;

	function floorfailing(timeUntilTransition:UInt):Void;

	function tellClientInfiniteRewardData(avId:UInt, avScore:UInt, goldReward:UInt, infiniteRewards:Vector<InfiniteRewardData>):Void;
}
