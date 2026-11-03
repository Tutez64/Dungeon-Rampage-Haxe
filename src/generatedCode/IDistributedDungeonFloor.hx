package generatedCode;

import brain.gameObject.GameObject;

interface IDistributedDungeonFloor {
	function setNetworkComponentDistributedDungeonFloor(iface:DistributedDungeonFloorNetworkComponent):Void;

	function postGenerate():Void;

	function getTrueObject():GameObject;

	function destroy():Void;

	@:isVar var mapNodeId(never, set):UInt;

	@:isVar var coliseumTierConstant(never, set):String;

	function tileLibrary(tileLibrary:String):Void;

	function tiles(tiles:Vector<DungeonTileUsage>):Void;

	@:isVar var baseLining(never, set):UInt;

	@:isVar var introMovieSwfFilePath(never, set):String;

	@:isVar var introMovieAssetClassName(never, set):String;

	@:isVar var currentFloorNum(never, set):UInt;

	@:isVar var activeDungeonModifiers(never, set):Vector<DungeonModifier>;

	function show_text(textkey:String):Void;

	function play_sound(sound:String):Void;

	function trigger_camera_zoom(zoom:Float):Void;

	function trigger_camera_shake(shakeDuration:Float, shakeStrength:Float, shakeCount:UInt):Void;
}
