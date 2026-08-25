package org.as3commons.collections.framework;

interface IList extends IOrder extends IDuplicates {
	function removeAllAt(index:UInt, numItems:UInt):Array<ASAny>;

	function add(item:ASAny):UInt;

	@:isVar var array(never, set):Array<ASAny>;

	function lastIndexOf(item:ASAny):Int;

	function itemAt(index:UInt):ASAny;

	function removeAt(index:UInt):ASAny;

	function firstIndexOf(item:ASAny):Int;
}
