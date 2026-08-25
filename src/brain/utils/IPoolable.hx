package brain.utils;

interface IPoolable {
	function postCheckout(isNewObject:Bool):Void;

	function postCheckin():Void;

	function destroy():Void;

	function getPoolKey():String;
}
