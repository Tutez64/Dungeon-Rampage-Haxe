package box2D.collision;

import box2D.common.math.B2Vec2;

interface IBroadPhase {
	function validate():Void;

	function updatePairs(callbackMethod:ASAny):Void;

	function testOverlap(proxyA:ASAny, proxyB:ASAny):Bool;

	function rebalance(iterations:Int):Void;

	function rayCast(callbackMethod:ASFunction, input:B2RayCastInput):Void;

	function query(callbackMethod:ASFunction, aabb:B2AABB):Void;

	function moveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2):Void;

	function getUserData(proxy:ASAny):ASAny;

	function getProxyCount():Int;

	function getFatAABB(proxy:ASAny):B2AABB;

	function destroyProxy(proxy:ASAny):Void;

	function createProxy(aabb:B2AABB, userData:ASAny):ASAny;

	function Validate():Void;

	function UpdatePairs(callbackMethod:ASAny):Void;

	function TestOverlap(proxyA:ASAny, proxyB:ASAny):Bool;

	function Rebalance(iterations:Int):Void;

	function RayCast(callbackMethod:ASFunction, input:B2RayCastInput):Void;

	function Query(callbackMethod:ASFunction, aabb:B2AABB):Void;

	function MoveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2):Void;

	function GetUserData(proxy:ASAny):ASAny;

	function GetProxyCount():Int;

	function GetFatAABB(proxy:ASAny):B2AABB;

	function DestroyProxy(proxy:ASAny):Void;

	function CreateProxy(aabb:B2AABB, userData:ASAny):ASAny;
}
