package org.as3commons.collections.framework;

interface ICollection extends IIterable {
	@:isVar var size(get, never):UInt;

	function remove(item:ASAny):Bool;

	function has(item:ASAny):Bool;

	function clear():Bool;

	function toArray():Array<ASAny>;
}
