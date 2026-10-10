package org.as3commons.collections.framework;

interface IInsertionOrder extends IOrder {
	function reverse():Bool;

	function sort(comparator:IComparator):Bool;
}
