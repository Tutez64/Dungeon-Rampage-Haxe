package collections;

class SortedMapIterator implements IMapIterator {
	public var _nextIndex:Int = 0;

	public var _next:SortedMapNode;

	public var _map:SortedMap;

	public var _current:SortedMapNode;

	public function new(map:SortedMap = /*undefined*/ null) {
		_nextIndex = 0;
		_map = map;
		_next = map.nodeAt(0);
	}

	public function next():ASAny {
		if (_next == null) {
			_current = null;
			return ASCompat.UNDEFINED;
		}
		_current = _next;
		var _loc1_ = _map.indexOfNode(_current, _nextIndex);
		_nextIndex = _loc1_ + 1;
		_next = _loc1_ == -1 ? null : _map.nodeAt(_nextIndex);
		return _current.item;
	}

	public function hasNext():Bool {
		return _next != null;
	}

	@:isVar public var key(get, never):ASAny;

	public function get_key():ASAny {
		if (_current != null) {
			return _current.key;
		}
		return ASCompat.UNDEFINED;
	}

	@:isVar public var current(get, never):ASAny;

	public function get_current():ASAny {
		if (_current != null) {
			return _current.item;
		}
		return ASCompat.UNDEFINED;
	}
}
