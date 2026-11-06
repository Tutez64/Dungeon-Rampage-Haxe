package collections;

class SetIterator implements ISetIterator {
	public var _set:Set;

	public var _next:Int = 0;

	public var _items:Array<ASAny>;

	public var _current:Int = 0;

	public function new(theSet:Set = /*undefined*/ null) {
		_current = -1;
		_set = theSet;
		_items = theSet.toArray();
		_next = _items.length == 0 ? -1 : 0;
	}

	public function remove():Bool {
		if (_current == -1) {
			return false;
		}
		if (_next > 0) {
			--_next;
		}
		_set.remove(_items[_current]);
		_items.splice(_current, (1 : UInt));
		_current = -1;
		return true;
	}

	public function next():ASAny {
		if (_next == -1) {
			_current = -1;
			return ASCompat.UNDEFINED;
		}
		_current = _next;
		_next = _next >= _items.length - 1 ? -1 : _next + 1;
		return _items[_current];
	}

	public function hasNext():Bool {
		return _next > -1;
	}
}
