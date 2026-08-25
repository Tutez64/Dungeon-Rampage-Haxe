package box2D.collision;

import box2D.common.math.B2Vec2;

interface IBroadPhase {
	function CreateProxy(aabb:B2AABB, userData:ASAny):ASAny;

	function DestroyProxy(proxy:ASAny):Void;

	function MoveProxy(proxy:ASAny, aabb:B2AABB, displacement:B2Vec2):Void;

	function TestOverlap(proxyA:ASAny, proxyB:ASAny):Bool;

	function GetUserData(proxy:ASAny):ASAny;

	function GetFatAABB(proxy:ASAny):B2AABB;

	function GetProxyCount():Int;

	function UpdatePairs(callback:ASFunction):Void;

	function Query(callback:ASFunction, aabb:B2AABB):Void;

	function RayCast(callback:ASFunction, input:B2RayCastInput):Void;

	function Validate():Void;

	function Rebalance(iterations:Int):Void;
}
