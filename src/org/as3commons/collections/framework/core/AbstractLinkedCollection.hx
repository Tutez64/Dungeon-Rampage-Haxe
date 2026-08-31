package org.as3commons.collections.framework.core;

import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IInsertionOrder;
import org.as3commons.collections.framework.IIterator;

/*use*/ /*namespace*/ /*as3commons_collections*/ class AbstractLinkedCollection implements IInsertionOrder {
	var _size:UInt = (0 : UInt);

	var _first:LinkedNode;

	var _last:LinkedNode;

	public function new() {}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return this._size;
	}

	public function reverse():Bool {
		var _loc2_:LinkedNode = null;
		var _loc3_:LinkedNode = null;
		if (this._size < 2) {
			return false;
		}
		var _loc1_ = this._last;
		while (_loc1_ != null) {
			_loc2_ = _loc1_.left;
			if (_loc1_.right == null) {
				_loc1_.right = _loc1_.left;
				_loc1_.left = null;
				this._first = _loc1_;
			} else if (_loc1_.left == null) {
				_loc1_.left = _loc1_.right;
				_loc1_.right = null;
				this._last = _loc1_;
			} else {
				_loc3_ = _loc1_.right;
				_loc1_.right = _loc1_.left;
				_loc1_.left = _loc3_;
			}
			_loc1_ = _loc2_;
		}
		return true;
	}

	function mergeSort(comparator:IComparator) {
		var _loc3_:LinkedNode = null;
		var _loc4_:LinkedNode = null;
		var _loc5_:LinkedNode = null;
		var _loc6_:LinkedNode = null;
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_ = 0;
		var _loc11_ = 0;
		var _loc2_ = this._first;
		var _loc7_ = 1;
		while (true) {
			_loc3_ = _loc2_;
			_loc2_ = _loc6_ = null;
			_loc8_ = 0;
			while (_loc3_ != null) {
				_loc8_ = ASCompat.toInt(_loc8_) + 1;
				_loc11_ = 0;
				_loc9_ = 0;
				_loc4_ = _loc3_;
				while (_loc11_ < _loc7_) {
					_loc9_ = ASCompat.toInt(_loc9_) + 1;
					_loc4_ = _loc4_.right;
					if (_loc4_ == null) {
						break;
					}
					_loc11_ = ASCompat.toInt(_loc11_) + 1;
				}
				_loc10_ = _loc7_;
				while (_loc9_ > 0 || _loc10_ > 0 && _loc4_ != null) {
					if (_loc9_ == 0) {
						_loc5_ = _loc4_;
						_loc4_ = _loc4_.right;
						_loc10_ = ASCompat.toInt(_loc10_) - 1;
					} else if (_loc10_ == 0 || _loc4_ == null) {
						_loc5_ = _loc3_;
						_loc3_ = _loc3_.right;
						_loc9_ = ASCompat.toInt(_loc9_) - 1;
					} else if (comparator.compare(_loc3_.item, _loc4_.item) <= 0) {
						_loc5_ = _loc3_;
						_loc3_ = _loc3_.right;
						_loc9_ = ASCompat.toInt(_loc9_) - 1;
					} else {
						_loc5_ = _loc4_;
						_loc4_ = _loc4_.right;
						_loc10_ = ASCompat.toInt(_loc10_) - 1;
					}
					if (_loc6_ != null) {
						_loc6_.right = _loc5_;
					} else {
						_loc2_ = _loc5_;
					}
					_loc5_.left = _loc6_;
					_loc6_ = _loc5_;
				}
				_loc3_ = _loc4_;
			}
			this._first.left = _loc6_;
			_loc6_.right = null;
			if (_loc8_ <= 1) {
				break;
			}
			_loc7_ = _loc7_ << 1;
		}
		this._first = _loc2_;
		this._last = _loc6_;
	}

	/*as3commons_collections*/ @:isVar public var firstNode_internal(get, never):LinkedNode;

	public function get_firstNode_internal():LinkedNode {
		return this._first;
	}

	public function remove(item:ASAny):Bool {
		var _loc2_ = this.firstNodeOf(item);
		if (_loc2_ == null) {
			return false;
		}
		this.removeNode(_loc2_);
		return true;
	}

	public function removeFirst():ASAny {
		if (this._size == 0) {
			return /*undefined*/ null;
		}
		var _loc1_:ASAny = this._first.item;
		this._first = this._first.right;
		if (this._first != null) {
			this._first.left = null;
		} else {
			this._last = null;
		}
		--this._size;
		return _loc1_;
	}

	public function clear():Bool {
		if (this._size == 0) {
			return false;
		}
		this._first = this._last = null;
		this._size = (0 : UInt);
		return true;
	}

	function addNodeBefore(next:LinkedNode, node:LinkedNode) {
		if (next == null) {
			this.addNodeLast(node);
			return;
		}
		if (next.left == null) {
			this._first = node;
		}
		node.left = next.left;
		node.right = next;
		if (next.left != null) {
			next.left.right = node;
		}
		next.left = node;
		++this._size;
	}

	function firstNodeOf(item:ASAny):LinkedNode {
		var _loc2_ = this._first;
		while (_loc2_ != null) {
			if (item == _loc2_.item) {
				return _loc2_;
			}
			_loc2_ = _loc2_.right;
		}
		return null;
	}

	@:isVar public var last(get, never):ASAny;

	public function get_last():ASAny {
		if (this._last != null) {
			return this._last.item;
		}
		return /*undefined*/ null;
	}

	function addNodeAfter(previous:LinkedNode, node:LinkedNode) {
		if (previous == null) {
			this.addNodeFirst(node);
			return;
		}
		if (previous.right == null) {
			this._last = node;
		}
		node.left = previous;
		node.right = previous.right;
		if (previous.right != null) {
			previous.right.left = node;
		}
		previous.right = node;
		++this._size;
	}

	public function sort(comparator:IComparator):Bool {
		if (this._size < 2) {
			return false;
		}
		this.mergeSort(comparator);
		return true;
	}

	public function has(item:ASAny):Bool {
		return this.firstNodeOf(item) != null;
	}

	/*as3commons_collections*/ @:isVar public var lastNode_internal(get, never):LinkedNode;

	public function get_lastNode_internal():LinkedNode {
		return this._last;
	}

	function removeNode(node:LinkedNode) {
		if (node.left != null) {
			node.left.right = node.right;
		} else {
			this._first = node.right;
		}
		if (node.right != null) {
			node.right.left = node.left;
		} else {
			this._last = node.left;
		}
		--this._size;
	}

	public function toArray():Array<ASAny> {
		var _loc1_ = this._first;
		var _loc2_ = new Array<ASAny>();
		while (_loc1_ != null) {
			_loc2_.push(_loc1_.item);
			_loc1_ = _loc1_.right;
		}
		return _loc2_;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return null;
	}

	@:isVar public var first(get, never):ASAny;

	public function get_first():ASAny {
		if (this._first != null) {
			return this._first.item;
		}
		return /*undefined*/ null;
	}

	function addNodeFirst(node:LinkedNode) {
		if (this._first == null) {
			this._first = this._last = node;
			this._size = (1 : UInt);
			return;
		}
		this._first.left = node;
		node.right = this._first;
		this._first = node;
		++this._size;
	}

	function addNodeLast(node:LinkedNode) {
		if (this._first == null) {
			this._first = this._last = node;
			this._size = (1 : UInt);
			return;
		}
		this._last.right = node;
		node.left = this._last;
		this._last = node;
		++this._size;
	}

	public function removeLast():ASAny {
		if (this._size == 0) {
			return /*undefined*/ null;
		}
		var _loc1_:ASAny = this._last.item;
		this._last = this._last.left;
		if (this._last != null) {
			this._last.right = null;
		} else {
			this._first = null;
		}
		--this._size;
		return _loc1_;
	}
}
