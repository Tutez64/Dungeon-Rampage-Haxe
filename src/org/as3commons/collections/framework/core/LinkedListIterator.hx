package org.as3commons.collections.framework.core;

import org.as3commons.collections.LinkedList;
import org.as3commons.collections.framework.ILinkedListIterator;

/*use*/ /*namespace*/ /*as3commons_collections*/ class LinkedListIterator extends AbstractLinkedCollectionIterator implements ILinkedListIterator {
	public function new(list:LinkedList) {
		super(list);
	}

	public function addBefore(item:ASAny) {
		_current = null;
		cast(_collection, LinkedList).addNodeBefore_internal(_next, new LinkedNode(item));
	}

	@:isVar public var previousItem(get, never):ASAny;

	public function get_previousItem():ASAny {
		return
			_next != null ? (_next.left != null ? _next.left.item : /*undefined*/ null) : (_collection.size != 0 ? _collection.lastNode_internal.item : /*undefined*/ null);
	}

	public function replace(item:ASAny):Bool {
		if (_current == null) {
			return false;
		}
		if (_current.item == item) {
			return false;
		}
		_current.item = item;
		return true;
	}

	override function removeCurrent() {
		cast(_collection, LinkedList).removeNode_internal(_current);
	}

	public function addAfter(item:ASAny) {
		_current = null;
		if (_next != null) {
			cast(_collection, LinkedList).addNodeBefore_internal(_next, new LinkedNode(item));
			_next = _next.left;
		} else {
			cast(_collection, LinkedList).addNodeBefore_internal(null, new LinkedNode(item));
			_next = _collection.lastNode_internal;
		}
	}

	@:isVar public var nextItem(get, never):ASAny;

	public function get_nextItem():ASAny {
		return _next != null ? _next.item : /*undefined*/ null;
	}
}
