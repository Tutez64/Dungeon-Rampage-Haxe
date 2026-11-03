package collections;

import flash.Boot;

class ArrayListIterator implements IListIterator {
	public var _next:Int = 0;

	public var _array:Array<ASAny>;

	public function new(array:Array<ASAny> = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		_array = array;
		_next = _array.length == 0 ? -1 : 0;
	}

	public function next():ASAny {
		if (_next == -1) {
			return /*undefined*/ null;
		}
		var _loc1_ = _next;
		_next = _next >= _array.length - 1 ? -1 : _next + 1;
		return _array[_loc1_];
	}

	public function hasNext():Bool {
		return _next > -1;
	}
}
