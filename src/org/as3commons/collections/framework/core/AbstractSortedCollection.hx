package org.as3commons.collections.framework.core;

import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.ISortOrder;

/*use*/ /*namespace*/ /*as3commons_collections*/ class AbstractSortedCollection implements ISortOrder {
	var _root:SortedNode;

	var _size:UInt = (0 : UInt);

	var _comparator:IComparator;

	public function new(comparator:IComparator) {
		this._comparator = comparator;
	}

	function addNode(newNode:SortedNode) {
		var _loc3_ = 0;
		if (this._root == null) {
			this._comparator.compare(newNode.item, newNode.item);
			this._root = newNode;
			++this._size;
			return;
		}
		var _loc2_ = this._root;
		while (_loc2_ != null) {
			_loc3_ = this._comparator.compare(newNode.item, _loc2_.item);
			if (_loc3_ == 0) {
				_loc3_ = newNode.order < _loc2_.order ? -1 : 1;
			}
			if (_loc3_ == -1) {
				if (_loc2_.left == null) {
					newNode.parent = _loc2_;
					_loc2_.left = newNode;
					_loc2_ = _loc2_.left;
					break;
				}
				_loc2_ = _loc2_.left;
			} else {
				if (_loc3_ != 1) {
					return;
				}
				if (_loc2_.right == null) {
					newNode.parent = _loc2_;
					_loc2_.right = newNode;
					_loc2_ = _loc2_.right;
					break;
				}
				_loc2_ = _loc2_.right;
			}
		}
		while (_loc2_.parent != null) {
			if (_loc2_.parent.priority >= _loc2_.priority) {
				break;
			}
			this.rotate(_loc2_.parent, _loc2_);
		}
		++this._size;
	}

	public function remove(item:ASAny):Bool {
		var _loc2_ = this.firstEqualNode(item);
		if (_loc2_ == null) {
			return false;
		}
		if (_loc2_.item == item) {
			this.removeNode(_loc2_);
			return true;
		}
		_loc2_ = this.nextNode_internal(_loc2_);
		while (_loc2_ != null) {
			if (this._comparator.compare(item, _loc2_.item) != 0) {
				break;
			}
			if (_loc2_.item == item) {
				this.removeNode(_loc2_);
				return true;
			}
			_loc2_ = this.nextNode_internal(_loc2_);
		}
		return false;
	}

	function firstEqualNode(item:ASAny):SortedNode {
		var _loc3_:SortedNode = null;
		var _loc4_ = 0;
		var _loc2_ = this._root;
		while (_loc2_ != null) {
			_loc4_ = this._comparator.compare(item, _loc2_.item);
			if (_loc4_ == -1) {
				if (_loc3_ != null) {
					return _loc3_;
				}
				_loc2_ = _loc2_.left;
			} else if (_loc4_ == 1) {
				_loc2_ = _loc2_.right;
			} else {
				_loc3_ = _loc2_;
				_loc2_ = _loc2_.left;
			}
		}
		return _loc3_;
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return this._size;
	}

	public function removeLast():ASAny {
		var _loc1_ = this.mostRightNode_internal();
		if (_loc1_ == null) {
			return /*undefined*/ null;
		}
		this.removeNode(_loc1_);
		return _loc1_.item;
	}

	public function removeFirst():ASAny {
		var _loc1_ = this.mostLeftNode_internal();
		if (_loc1_ == null) {
			return /*undefined*/ null;
		}
		this.removeNode(_loc1_);
		return _loc1_.item;
	}

	public function clear():Bool {
		if (this._size == 0) {
			return false;
		}
		this._root = null;
		this._size = (0 : UInt);
		return true;
	}

	public function hasEqual(item:ASAny):Bool {
		var _loc3_ = 0;
		var _loc2_ = this._root;
		while (_loc2_ != null) {
			_loc3_ = this._comparator.compare(item, _loc2_.item);
			if (_loc3_ == -1) {
				_loc2_ = _loc2_.left;
			} else {
				if (_loc3_ != 1) {
					return true;
				}
				_loc2_ = _loc2_.right;
			}
		}
		return false;
	}

	@:isVar public var last(get, never):ASAny;

	public function get_last():ASAny {
		if (this._root == null) {
			return /*undefined*/ null;
		}
		return this.mostRightNode_internal().item;
	}

	/*as3commons_collections*/
	public function mostLeftNode_internal(node:SortedNode = null):SortedNode {
		if (this._root == null) {
			return null;
		}
		if (node == null) {
			node = this._root;
		}
		while (node.left != null) {
			node = node.left;
		}
		return node;
	}

	/*as3commons_collections*/
	public function mostRightNode_internal(node:SortedNode = null):SortedNode {
		if (this._root == null) {
			return null;
		}
		if (node == null) {
			node = this._root;
		}
		while (node.right != null) {
			node = node.right;
		}
		return node;
	}

	function rotate(parent:SortedNode, child:SortedNode) {
		var _loc3_ = parent.parent;
		var _loc4_ = "right";
		var _loc5_ = "left";
		if (child == parent.left) {
			_loc4_ = "left";
			_loc5_ = "right";
		}
		(parent : ASAny)[_loc4_] = (child : ASAny)[_loc5_];
		if (ASCompat.toBool((child : ASAny)[_loc5_])) {
			cast((child : ASAny)[_loc5_], SortedNode).parent = parent;
		}
		parent.parent = child;
		(child : ASAny)[_loc5_] = parent;
		child.parent = _loc3_;
		if (_loc3_ != null) {
			if ((_loc3_ : ASAny)[_loc5_] == parent) {
				(_loc3_ : ASAny)[_loc5_] = child;
			} else {
				(_loc3_ : ASAny)[_loc4_] = child;
			}
		} else {
			this._root = child;
		}
	}

	public function has(item:ASAny):Bool {
		var _loc2_ = this.firstEqualNode(item);
		if (_loc2_ == null) {
			return false;
		}
		if (_loc2_.item == item) {
			return true;
		}
		_loc2_ = this.nextNode_internal(_loc2_);
		while (_loc2_ != null) {
			if (this._comparator.compare(item, _loc2_.item) != 0) {
				break;
			}
			if (_loc2_.item == item) {
				return true;
			}
			_loc2_ = this.nextNode_internal(_loc2_);
		}
		return false;
	}

	/*as3commons_collections*/
	public function previousNode_internal(node:SortedNode):SortedNode {
		var _loc2_:SortedNode = null;
		if (node.left != null) {
			node = this.mostRightNode_internal(node.left);
		} else {
			_loc2_ = node.parent;
			while (_loc2_ != null && node == _loc2_.left) {
				node = _loc2_;
				_loc2_ = _loc2_.parent;
			}
			node = _loc2_;
		}
		return node;
	}

	public function toArray():Array<ASAny> {
		var _loc1_ = new Array<ASAny>();
		var _loc2_ = this.mostLeftNode_internal();
		while (_loc2_ != null) {
			_loc1_.push(_loc2_.item);
			_loc2_ = this.nextNode_internal(_loc2_);
		}
		return _loc1_;
	}

	function removeNode(node:SortedNode) {
		var _loc2_:SortedNode = null;
		while (node.left != null || node.right != null) {
			if (node.left != null && node.right != null) {
				_loc2_ = node.left.priority < node.right.priority ? node.left : node.right;
			} else if (node.left != null) {
				_loc2_ = node.left;
			} else {
				if (node.right == null) {
					break;
				}
				_loc2_ = node.right;
			}
			this.rotate(node, _loc2_);
		}
		if (node.parent != null) {
			if (node.parent.left == node) {
				node.parent.left = null;
			} else {
				node.parent.right = null;
			}
			node.parent = null;
		} else {
			this._root = null;
		}
		--this._size;
	}

	/*as3commons_collections*/
	public function nextNode_internal(node:SortedNode):SortedNode {
		var _loc2_:SortedNode = null;
		if (node.right != null) {
			node = this.mostLeftNode_internal(node.right);
		} else {
			_loc2_ = node.parent;
			while (_loc2_ != null && node == _loc2_.right) {
				node = _loc2_;
				_loc2_ = _loc2_.parent;
			}
			node = _loc2_;
		}
		return node;
	}

	function lesserNode(item:ASAny):SortedNode {
		var _loc3_:SortedNode = null;
		var _loc4_ = 0;
		var _loc2_ = this._root;
		while (_loc2_ != null) {
			_loc4_ = this._comparator.compare(item, _loc2_.item);
			if (_loc4_ == -1) {
				_loc2_ = _loc2_.left;
			} else if (_loc4_ == 1) {
				_loc3_ = _loc2_;
				_loc2_ = _loc2_.right;
			} else {
				_loc2_ = _loc2_.left;
			}
		}
		return _loc3_;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return null;
	}

	function higherNode(item:ASAny):SortedNode {
		var _loc3_:SortedNode = null;
		var _loc4_ = 0;
		var _loc2_ = this._root;
		while (_loc2_ != null) {
			_loc4_ = this._comparator.compare(item, _loc2_.item);
			if (_loc4_ == -1) {
				_loc3_ = _loc2_;
				_loc2_ = _loc2_.left;
			} else if (_loc4_ == 1) {
				_loc2_ = _loc2_.right;
			} else {
				_loc2_ = _loc2_.right;
			}
		}
		return _loc3_;
	}

	/*as3commons_collections*/
	public function removeNode_internal(node:SortedNode) {
		this.removeNode(node);
	}

	@:isVar public var first(get, never):ASAny;

	public function get_first():ASAny {
		if (this._root == null) {
			return /*undefined*/ null;
		}
		return this.mostLeftNode_internal().item;
	}
}
