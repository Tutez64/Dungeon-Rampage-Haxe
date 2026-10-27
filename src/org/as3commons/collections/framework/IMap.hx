package org.as3commons.collections.framework;

interface IMap extends IDuplicates {
	function add(key:ASAny, item:ASAny):Bool;

	function hasKey(key:ASAny):Bool;

	function itemFor(key:ASAny):ASAny;

	function keysToArray():Array<ASAny>;

	function removeKey(key:ASAny):ASAny;

	function replaceFor(key:ASAny, item:ASAny):Bool;

	function keyIterator():IIterator;
}
