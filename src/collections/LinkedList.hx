package collections;

class LinkedList {
	public var _last:LinkedNode;

	public var _first:LinkedNode;

	public function new() {}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new LinkedListIterator(_first);
	}

	public function clear():Bool {
		if (_first == null) {
			return false;
		}
		_first = _last = null;
		return true;
	}

	public function add(item:ASAny) {
		var _loc3_ = ASCompat.dynamicAs(null, LinkedNode);
		var _loc2_ = new LinkedNode(item);
		if (_first == null) {
			_first = _last = _loc2_;
		} else {
			_last.right = _loc2_;
			_last = _loc2_;
		}
	}
}
