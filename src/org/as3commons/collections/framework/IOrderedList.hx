package org.as3commons.collections.framework;

interface IOrderedList extends IList extends IInsertionOrder {
	function addAt(index:UInt, item:ASAny):Bool;

	function replaceAt(index:UInt, item:ASAny):Bool;

	function addAllAt(index:UInt, items:Array<ASAny>):Bool;

	function addLast(item:ASAny):Void;

	function addFirst(item:ASAny):Void;
}
