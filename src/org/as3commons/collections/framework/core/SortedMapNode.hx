package org.as3commons.collections.framework.core;

class SortedMapNode extends SortedNode {
	public var key:ASAny;

	public function new(theKey:ASAny, theItem:ASAny) {
		super(theItem);
		this.key = theKey;
	}
}
