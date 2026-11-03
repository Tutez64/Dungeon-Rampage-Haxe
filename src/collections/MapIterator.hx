package collections;

import flash.Boot;

class MapIterator implements IMapIterator {
	public var _next:Int = 0;

	public var _map:Map;

	public var _keys:Array<ASAny>;

	public var _current:Int = 0;

	public function new(map:Map = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		_current = -1;
		_map = map;
		_keys = map.keysToArray();
		_next = _keys.length == 0 ? -1 : 0;
	}

	public function next():ASAny {
		if (_next == -1) {
			_current = -1;
			return _map.itemFor(/*undefined*/ null);
		}
		_current = _next;
		_next = _next >= _keys.length - 1 ? -1 : _next + 1;
		return _map.itemFor(_keys[_current]);
	}

	public function hasNext():Bool {
		return _next > -1;
	}

	public function get_key():ASAny {
		return _keys[_current];
	}

	@:isVar public var key(get, never):ASAny;

	public function get_key():ASAny {
		return get_key();
	}

	public function get_current():ASAny {
		return _map.itemFor(_keys[_current]);
	}

	@:isVar public var current(get, never):ASAny;

	public function get_current():ASAny {
		return get_current();
	}
}
