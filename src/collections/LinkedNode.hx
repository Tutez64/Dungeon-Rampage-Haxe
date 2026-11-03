package collections;

import flash.Boot;

class LinkedNode {
	public var right:LinkedNode;

	public var item:ASAny;

	public function new(item:ASAny = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		this.item = item;
	}
}
