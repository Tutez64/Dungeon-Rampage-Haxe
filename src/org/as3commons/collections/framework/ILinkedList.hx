package org.as3commons.collections.framework;

interface ILinkedList extends IInsertionOrder extends IDuplicates {
	function add(item:ASAny):Void;

	function addLast(item:ASAny):Void;

	function addFirst(item:ASAny):Void;
}
