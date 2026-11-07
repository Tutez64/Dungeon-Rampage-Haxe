package collections;

class LinkedNode {
	public var right:LinkedNode;

	public var item:ASAny;

	public function new(item:ASAny = /*undefined*/ null) {
		this.item = item;
	}
}
