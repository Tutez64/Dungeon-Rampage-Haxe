package org.as3commons.collections;

import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.ILinkedList;
import org.as3commons.collections.framework.core.AbstractLinkedDuplicatesCollection;
import org.as3commons.collections.framework.core.LinkedListIterator;
import org.as3commons.collections.framework.core.LinkedNode;

/*use*/ /*namespace*/ /*as3commons_collections*/ class LinkedList extends AbstractLinkedDuplicatesCollection implements ILinkedList {
	public function new() {
		super();
	}

	override public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new LinkedListIterator(this);
	}

	public function addFirst(item:ASAny) {
		addNodeFirst(new LinkedNode(item));
	}

	public function addLast(item:ASAny) {
		addNodeLast(new LinkedNode(item));
	}

	public function add(item:ASAny) {
		addNodeLast(new LinkedNode(item));
	}

	/*as3commons_collections*/
	public function addNodeBefore_internal(next:LinkedNode, node:LinkedNode) {
		addNodeBefore(next, node);
	}

	/*as3commons_collections*/
	public function removeNode_internal(node:LinkedNode) {
		removeNode(node);
	}
}
