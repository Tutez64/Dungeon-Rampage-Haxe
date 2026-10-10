package org.as3commons.collections.framework.core;

import org.as3commons.collections.framework.IListIterator;
import org.as3commons.collections.iterators.ArrayIterator;

/*use*/ /*namespace*/ /*as3commons_collections*/ class AbstractListIterator extends ArrayIterator implements IListIterator {
	var _list:AbstractList;

	public function new(list:AbstractList, index:UInt = (0 : UInt)) {
		this._list = list;
		super(this._list.array_internal, index);
	}

	override function removeCurrent() {
		this._list.removeAt((_current : UInt));
	}
}
