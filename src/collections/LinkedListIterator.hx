package collections;

class LinkedListIterator implements ILinkedListIterator {
	public var _next:LinkedNode;

	public function new(first:LinkedNode = /*undefined*/ null) {
		_next = first;
	}

	public function next():ASAny {
		if (_next == null) {
			return ASCompat.UNDEFINED;
		}
		var _loc1_:ASAny = _next.item;
		_next = _next.right;
		return _loc1_;
	}

	public function hasNext():Bool {
		return _next != null;
	}
}
