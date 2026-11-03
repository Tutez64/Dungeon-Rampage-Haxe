package collections;

import flash.Boot;

class SortedMapNode {
	public var key:ASAny;

	public var item:ASAny;

	public function new(key:ASAny = /*undefined*/ null, item:ASAny = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		this.key = key;
		this.item = item;
	}
}
