package org.as3commons.collections.framework;

interface IOrderedListIterator extends IListIterator {
	function addBefore(item:ASAny):UInt;

	function addAfter(item:ASAny):UInt;

	function replace(item:ASAny):Bool;
}
