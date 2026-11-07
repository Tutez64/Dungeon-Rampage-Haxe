package collections;

import collections.StringKeyStore;

class Set {
	public var _stringItems:StringKeyStore;

	public var _size:UInt = 0;

	public var _items:ASDictionary<ASAny, ASAny>;

	public function new() {
		_size = (0 : UInt);
		_items = new ASDictionary<ASAny, ASAny>();
		_stringItems = new StringKeyStore();
	}

	public function toArray():Array<ASAny> {
		var _loc4_:ASAny = null;
		var _loc7_:ASAny = null;
		var _loc1_:Array<ASAny> = [];
		var _loc2_ = 0;
		var _loc3_ = _stringItems.keys();
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc1_.push(_stringItems.get(_loc4_));
		}
		_loc2_ = 0;
		_loc4_ = _items;
		var _loc6_:ASAny = 0;
		var _loc5_:Array<ASAny> = [];
		_loc7_ = _loc4_;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_.___keys()) {
				_loc6_ = _tmp_;
				_loc5_.push(_loc6_);
			}
		_loc3_ = _loc5_;
		while (_loc2_ < _loc3_.length) {
			_loc7_ = _loc3_[_loc2_];
			_loc2_++;
			_loc1_.push(_items[_loc7_]);
		}
		return _loc1_;
	}

	public function remove(item:ASAny):Bool {
		var _loc2_:ASDictionary<ASAny, ASAny> = null;
		var _loc3_:ASDictionary<ASAny, ASAny> = null;
		if (Std.isOfType(item, String)) {
			if (!_stringItems.hasKey(item)) {
				return false;
			}
			_stringItems.remove(item);
		} else {
			_loc2_ = _items;
			if (!_loc2_.exists(item)) {
				return false;
			}
			_loc3_ = _items;
			ASCompat.deleteProperty(_loc3_, item);
		}
		_size -= (1 : UInt);
		return true;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new SetIterator(this);
	}

	public function has(item:ASAny):Bool {
		if (Std.isOfType(item, String)) {
			return _stringItems.hasKey(item);
		}
		var _loc2_ = _items;
		return _loc2_.exists(item);
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return _size;
	}

	public function clear():Bool {
		if (_size == 0) {
			return false;
		}
		_items = new ASDictionary<ASAny, ASAny>();
		_stringItems.clear();
		_size = (0 : UInt);
		return true;
	}

	public function add(item:ASAny):Bool {
		var _loc2_:ASDictionary<ASAny, ASAny> = null;
		if (Std.isOfType(item, String)) {
			if (_stringItems.hasKey(item)) {
				return false;
			}
			_stringItems.set(item, item);
		} else {
			_loc2_ = _items;
			if (_loc2_.exists(item)) {
				return false;
			}
			_items[item] = item;
		}
		_size += (1 : UInt);
		return true;
	}
}
