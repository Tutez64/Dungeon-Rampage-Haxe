package org.as3commons.collections.framework;

interface ILinkedListIterator extends ICollectionIterator {
	function addBefore(item:ASAny):Void;

	function replace(item:ASAny):Bool;

	@:isVar var nextItem(get, never):ASAny;

	@:isVar var previousItem(get, never):ASAny;

	function addAfter(item:ASAny):Void;
}
