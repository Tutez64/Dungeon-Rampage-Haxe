package brain.workLoop;

import brain.utils.MemoryTracker;

class SimplePriorityQueue {
	var _heap:Array<ASAny>;

	var _size:Int = 0;

	var _count:Int = 0;

	var _posLookup:ASDictionary<ASAny, ASAny>;

	public function new(size:Int) {
		_heap = ASCompat.allocArray(_size = size + 1);
		_posLookup = new ASDictionary<ASAny, ASAny>(true);
		_count = 0;
		MemoryTracker.track(_heap, "Array - heap storage size=" + size + " in SimplePriorityQueue()", "brain");
		MemoryTracker.track(_posLookup, "Dictionary - position lookup in SimplePriorityQueue()", "brain");
	}

	@:isVar public var front(get, never):IPrioritizable;

	public function get_front():IPrioritizable {
		return ASCompat.dynamicAs(_heap[1], brain.workLoop.IPrioritizable);
	}

	@:isVar public var maxSize(get, never):Int;

	public function get_maxSize():Int {
		return _size;
	}

	public function enqueue(obj:IPrioritizable):Bool {
		if (_count + 1 < _size) {
			_count = _count + 1;
			_heap[_count] = obj;
			_posLookup[obj] = _count;
			walkUp(_count);
			return true;
		}
		return false;
	}

	public function dequeue():IPrioritizable {
		var _loc1_:ASAny = /*undefined*/ null;
		if (_count >= 1) {
			_loc1_ = _heap[1];
			_posLookup.remove(_loc1_);
			_heap[1] = _heap[_count];
			walkDown(1);
			_heap[_count] = null;
			_count = _count - 1;
			return ASCompat.dynamicAs(_loc1_, brain.workLoop.IPrioritizable);
		}
		return null;
	}

	public function reprioritize(obj:IPrioritizable, newPriority:Int):Bool {
		if (!ASCompat.toBool(_posLookup[obj])) {
			return false;
		}
		var _loc4_ = obj.priority;
		obj.priority = newPriority;
		var _loc3_ = ASCompat.toInt(_posLookup[obj]);
		newPriority > _loc4_ ? walkUp(_loc3_) : walkDown(_loc3_);
		return true;
	}

	public function remove(obj:IPrioritizable):Bool {
		var _loc2_ = 0;
		var _loc3_:ASAny = /*undefined*/ null;
		if (_count >= 1) {
			_loc2_ = ASCompat.toInt(_posLookup[obj]);
			_loc3_ = _heap[_loc2_];
			_posLookup.remove(_loc3_);
			_heap[_loc2_] = _heap[_count];
			walkDown(_loc2_);
			_heap[_count] = null;
			_posLookup.remove(_count);
			_count = _count - 1;
			return true;
		}
		return false;
	}

	public function contains(obj:ASAny):Bool {
		var _loc2_ = 0;
		_loc2_ = 1;
		while (_loc2_ <= _count) {
			if (_heap[_loc2_] == obj) {
				return true;
			}
			_loc2_++;
		}
		return false;
	}

	public function clear() {
		_heap = ASCompat.allocArray(_size);
		_posLookup = new ASDictionary<ASAny, ASAny>(true);
		_count = 0;
	}

	@:isVar public var size(get, never):Int;

	public function get_size():Int {
		return _count;
	}

	public function isEmpty():Bool {
		return _count == 0;
	}

	public function toArray():Array<ASAny> {
		return _heap.slice(1, _count + 1);
	}

	public function toString():String {
		return "[SimplePriorityQueue, size=" + _size + "]";
	}

	public function dump():String {
		var _loc2_ = 0;
		if (_count == 0) {
			return "SimplePriorityQueue (empty)";
		}
		var _loc1_ = "SimplePriorityQueue\n{\n";
		var _loc3_ = _count + 1;
		_loc2_ = 1;
		while (_loc2_ < _loc3_) {
			_loc1_ += "\t" + Std.string(_heap[_loc2_]) + "\n";
			_loc2_++;
		}
		return _loc1_ + "\n}";
	}

	function walkUp(index:Int) {
		var _loc5_:IPrioritizable = null;
		var _loc3_ = index >> 1;
		var _loc4_ = ASCompat.dynamicAs(_heap[index], brain.workLoop.IPrioritizable);
		var _loc2_ = _loc4_.priority;
		while (_loc3_ > 0) {
			_loc5_ = ASCompat.dynamicAs(_heap[_loc3_], brain.workLoop.IPrioritizable);
			if (_loc2_ - _loc5_.priority <= 0) {
				break;
			}
			_heap[index] = _loc5_;
			_posLookup[_loc5_] = index;
			index = _loc3_;
			_loc3_ = _loc3_ >> 1;
		}
		_heap[index] = _loc4_;
		_posLookup[_loc4_] = index;
	}

	function walkDown(index:Int) {
		var _loc3_:IPrioritizable = null;
		var _loc5_ = index << 1;
		var _loc4_ = ASCompat.dynamicAs(_heap[index], brain.workLoop.IPrioritizable);
		var _loc2_ = _loc4_.priority;
		while (_loc5_ < _count) {
			if (_loc5_ < _count - 1) {
				if (ASCompat.toNumber(ASCompat.toNumberField(_heap[_loc5_], "priority") - ASCompat.toNumberField(_heap[_loc5_ + 1], "priority")) < 0) {
					_loc5_++;
				}
			}
			_loc3_ = ASCompat.dynamicAs(_heap[_loc5_], brain.workLoop.IPrioritizable);
			if (_loc2_ - _loc3_.priority >= 0) {
				break;
			}
			_heap[index] = _loc3_;
			_posLookup[_loc3_] = index;
			_posLookup[_loc4_] = _loc5_;
			index = _loc5_;
			_loc5_ = _loc5_ << 1;
		}
		_heap[index] = _loc4_;
		_posLookup[_loc4_] = index;
	}
}
