package collections;

class ArrayList {
	public var _array:Array<ASAny>;

	public function new() {
		_array = [];
	}

	public function remove(item:ASAny):Bool {
		var _loc2_ = _array.indexOf(item);
		if (_loc2_ == -1) {
			return false;
		}
		_array.splice(_loc2_, (1 : UInt));
		return true;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new ArrayListIterator(_array);
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return (_array.length : UInt);
	}

	public function clear():Bool {
		if (_array.length == 0) {
			return false;
		}
		_array = [];
		return true;
	}

	public function add(item:ASAny):UInt {
		_array.push(item);
		return (_array.length - 1:UInt);
	}
}
