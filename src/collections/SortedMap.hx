package collections;

import collections.StringKeyStore;

class SortedMap {
	public var _stringMap:StringKeyStore;

	public var _nodes:Array<ASAny>;

	public var _items:ASDictionary<ASAny, ASAny>;

	public var _comparator:IComparator;

	public function new(comparator:IComparator = /*undefined*/ null) {
		_comparator = comparator;
		_nodes = [];
		_items = new ASDictionary<ASAny, ASAny>();
		_stringMap = new StringKeyStore();
	}

	public function removeNodeAt(index:Int) {
		var _loc4_:ASDictionary<ASAny, ASAny> = null;
		var _loc5_:ASAny = null;
		var _loc2_ = ASCompat.coerce(_nodes[index], collections.SortedMapNode);
		_nodes.splice(index, (1 : UInt));
		var _loc3_:ASAny = _loc2_.key;
		if (Std.isOfType(_loc3_, String)) {
			_stringMap.remove(_loc2_.key);
		} else {
			_loc4_ = _items;
			_loc5_ = _loc2_.key;
			ASCompat.deleteProperty(_loc4_, _loc5_);
		}
	}

	public function removeKey(key:ASAny):ASAny {
		var _loc2_:ASAny = nodeFor(key);
		if (ASCompat.typeof(_loc2_) == "undefined") {
			return ASCompat.UNDEFINED;
		}
		removeNodeAt(_nodes.indexOf(_loc2_));
		return _loc2_.item;
	}

	public function remove(item:ASAny):Bool {
		var _loc4_ = 0;
		var _loc5_:ASAny = null;
		var _loc2_ = 0;
		var _loc3_ = _nodes.length;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			_loc5_ = _nodes[_loc4_].item;
			if (ASCompat.typeof(_loc5_) == ASCompat.typeof(item) && _loc5_ == item) {
				removeNodeAt(_loc4_);
				return true;
			}
		}
		return false;
	}

	public function nodeFor(key:ASAny):ASAny {
		if (Std.isOfType(key, String)) {
			if (_stringMap.hasKey(key)) {
				return _stringMap.get(key);
			}
			return ASCompat.UNDEFINED;
		}
		var _loc2_ = _items;
		if (_loc2_.exists(key)) {
			return _items[key];
		}
		return ASCompat.UNDEFINED;
	}

	public function nodeAt(index:Int):SortedMapNode {
		if (index >= 0 && index < _nodes.length) {
			return ASCompat.coerce(_nodes[index], collections.SortedMapNode);
		}
		return null;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new SortedMapIterator(this);
	}

	public function itemFor(key:ASAny):ASAny {
		var _loc2_:ASAny = nodeFor(key);
		if (ASCompat.typeof(_loc2_) == "undefined") {
			return ASCompat.UNDEFINED;
		}
		return _loc2_.item;
	}

	public function indexOfNode(node:SortedMapNode, hint:Int):Int {
		if (hint >= 0 && hint < _nodes.length && _nodes[hint] == node) {
			return hint;
		}
		return _nodes.indexOf(node);
	}

	public function has(item:ASAny):Bool {
		var _loc4_:ASAny = ASCompat.dynamicAs(null, SortedMapNode);
		var _loc5_:ASAny = null;
		var _loc2_ = 0;
		var _loc3_ = _nodes;
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc5_ = _loc4_.item;
			if (ASCompat.typeof(_loc5_) == ASCompat.typeof(item) && _loc5_ == item) {
				return true;
			}
		}
		return false;
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return (_nodes.length : UInt);
	}

	public function clear():Bool {
		if (_nodes.length == 0) {
			return false;
		}
		_nodes = [];
		_items = new ASDictionary<ASAny, ASAny>();
		_stringMap.clear();
		return true;
	}

	public function add(key:ASAny, item:ASAny):Bool {
		var _loc6_ = 0;
		var _loc3_:ASAny = nodeFor(key);
		if (ASCompat.typeof(_loc3_) != "undefined") {
			return false;
		}
		var _loc4_ = 0;
		var _loc5_ = _nodes.length;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_ + _loc5_ >> 1;
			if (_comparator.compare(item, _nodes[_loc6_].item) == -1) {
				_loc5_ = _loc6_;
			} else {
				_loc4_ = _loc6_ + 1;
			}
		}
		var _loc7_ = new SortedMapNode(key, item);
		_nodes.insert(_loc4_, _loc7_);
		if (Std.isOfType(key, String)) {
			_stringMap.set(key, _loc7_);
		} else {
			_items[key] = _loc7_;
		}
		return true;
	}
}
