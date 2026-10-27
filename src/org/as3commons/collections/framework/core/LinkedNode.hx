package org.as3commons.collections.framework.core;

class LinkedNode {
	public var item:ASAny;

	public var left:LinkedNode;

	public var right:LinkedNode;

	public function new(theItem:ASAny) {
		this.item = theItem;
	}
}
