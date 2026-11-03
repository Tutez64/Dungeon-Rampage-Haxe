package collections;

import collections.StringKeyStore;
import flash.Boot;

class Map {
	public var _stringMap:StringKeyStore;

	public var _size:UInt = 0;

	public var _keys:ASDictionary<ASAny, ASAny>;

	public var _items:ASDictionary<ASAny, ASAny>;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		_size = (0 : UInt);
		_items = new ASDictionary<ASAny, ASAny>();
		_keys = new ASDictionary<ASAny, ASAny>();
		_stringMap = new StringKeyStore();
	}

	public function toArray():Array<ASAny> {
		var _loc4_:ASAny = null;
		var _loc7_:ASAny = null;
		var _loc1_:Array<ASAny> = [];
		var _loc2_ = 0;
		var _loc3_ = _stringMap.keys();
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc1_.push(_stringMap.get(_loc4_));
		}
		_loc2_ = 0;
		_loc4_ = _items;
		var _loc6_ = 0;
		var _loc5_:Array<ASAny> = [];
		_loc7_ = _loc4_;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_.___keys()) {
				_loc6_ = ASCompat.toInt(_tmp_);
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

	public function replaceFor(key:ASAny, item:ASAny):Bool {
		var _loc3_:ASAny = null;
		var _loc4_:ASAny = null;
		if (Std.isOfType(key, String)) {
			if (!_stringMap.hasKey(key)) {
				return false;
			}
			_loc3_ = _stringMap.get(key);
			if (ASCompat.typeof(_loc3_) == ASCompat.typeof(item) && _loc3_ == item) {
				return false;
			}
			_stringMap.set(key, item);
		} else {
			_loc3_ = _keys;
			if (!_loc3_.hasOwnProperty(key)) {
				return false;
			}
			_loc4_ = _items[key];
			if (ASCompat.typeof(_loc4_) == ASCompat.typeof(item) && _loc4_ == item) {
				return false;
			}
			_items[key] = item;
		}
		return true;
	}

	public function removeKey(key:ASAny):ASAny {
		var _loc2_:ASAny = null;
		var _loc3_:ASDictionary<ASAny, ASAny> = null;
		var _loc4_:ASDictionary<ASAny, ASAny> = null;
		if (Std.isOfType(key, String)) {
			if (!_stringMap.hasKey(key)) {
				return /*undefined*/ null;
			}
			_loc2_ = _stringMap.get(key);
			_stringMap.remove(key);
		} else {
			_loc3_ = _keys;
			if (!_loc3_.exists(key)) {
				return /*undefined*/ null;
			}
			_loc2_ = _items[key];
			_loc4_ = _keys;
			ASCompat.deleteProperty(_loc4_, key);
			_loc4_ = _items;
			ASCompat.deleteProperty(_loc4_, key);
		}
		_size -= (1 : UInt);
		return _loc2_;
	}

	public function remove(item:ASAny):Bool {
		var _loc4_:ASAny = null;
		var _loc5_:ASAny = null;
		var _loc8_:ASAny = null;
		var _loc9_:ASDictionary<ASAny, ASAny> = null;
		var _loc2_ = 0;
		var _loc3_ = _stringMap.keys();
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc5_ = _stringMap.get(_loc4_);
			if (ASCompat.typeof(_loc5_) == ASCompat.typeof(item) && _loc5_ == item) {
				_stringMap.remove(_loc4_);
				_size -= (1 : UInt);
				return true;
			}
		}
		_loc2_ = 0;
		_loc4_ = _items;
		var _loc7_ = 0;
		var _loc6_:Array<ASAny> = [];
		_loc5_ = _loc4_;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_.___keys()) {
				_loc7_ = ASCompat.toInt(_tmp_);
				_loc6_.push(_loc7_);
			}
		_loc3_ = _loc6_;
		while (_loc2_ < _loc3_.length) {
			_loc5_ = _loc3_[_loc2_];
			_loc2_++;
			_loc8_ = _items[_loc5_];
			if (ASCompat.typeof(_loc8_) == ASCompat.typeof(item) && _loc8_ == item) {
				_loc9_ = _keys;
				ASCompat.deleteProperty(_loc9_, _loc5_);
				_loc9_ = _items;
				ASCompat.deleteProperty(_loc9_, _loc5_);
				_size -= (1 : UInt);
				return true;
			}
		}
		return false;
	}

	public function keysToArray():Array<ASAny> {
		var _loc7_:ASAny = null;
		var _loc1_ = _stringMap.keys();
		var _loc2_ = 0;
		var _loc3_ = _keys;
		var _loc6_ = 0;
		var _loc5_:Array<ASAny> = [];
		_loc7_ = _loc3_;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_.___keys()) {
				_loc6_ = ASCompat.toInt(_tmp_);
				_loc5_.push(_loc6_);
			}
		var _loc4_ = _loc5_;
		while (_loc2_ < _loc4_.length) {
			_loc7_ = _loc4_[_loc2_];
			_loc2_++;
			_loc1_.push(_keys[_loc7_]);
		}
		return _loc1_;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new MapIterator(this);
	}

	public function itemFor(key:ASAny):ASAny {
		if (Std.isOfType(key, String)) {
			return _stringMap.get(key);
		}
		return _items[key];
	}

	public function hasKey(key:ASAny):Bool {
		if (Std.isOfType(key, String)) {
			return _stringMap.hasKey(key);
		}
		var _loc2_ = _keys;
		return _loc2_.exists(key);
	}

	public function has(item:ASAny):Bool {
		var _loc4_:ASAny = null;
		var _loc5_:ASAny = null;
		var _loc8_:ASAny = null;
		var _loc2_ = 0;
		var _loc3_ = _stringMap.keys();
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc5_ = _stringMap.get(_loc4_);
			if (ASCompat.typeof(_loc5_) == ASCompat.typeof(item) && _loc5_ == item) {
				return true;
			}
		}
		_loc2_ = 0;
		_loc4_ = _items;
		var _loc7_ = 0;
		var _loc6_:Array<ASAny> = [];
		_loc5_ = _loc4_;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_.___keys()) {
				_loc7_ = ASCompat.toInt(_tmp_);
				_loc6_.push(_loc7_);
			}
		_loc3_ = _loc6_;
		while (_loc2_ < _loc3_.length) {
			_loc5_ = _loc3_[_loc2_];
			_loc2_++;
			_loc8_ = _items[_loc5_];
			if (ASCompat.typeof(_loc8_) == ASCompat.typeof(item) && _loc8_ == item) {
				return true;
			}
		}
		return false;
	}

	public function get_size():UInt {
		return _size;
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return get_size();
	}

	public function clear():Bool {
		if (_size == 0) {
			return false;
		}
		_keys = new ASDictionary<ASAny, ASAny>();
		_items = new ASDictionary<ASAny, ASAny>();
		_stringMap.clear();
		_size = (0 : UInt);
		return true;
	}

	public function add(key:ASAny, item:ASAny):Bool {
		var _loc3_:ASDictionary<ASAny, ASAny> = null;
		if (Std.isOfType(key, String)) {
			if (_stringMap.hasKey(key)) {
				return false;
			}
			_stringMap.set(key, item);
		} else {
			_loc3_ = _keys;
			if (_loc3_.exists(key)) {
				return false;
			}
			_keys[key] = key;
			_items[key] = item;
		}
		_size += (1 : UInt);
		return true;
	}
}
