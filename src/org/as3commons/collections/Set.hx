package org.as3commons.collections;

import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.ISet;
import org.as3commons.collections.framework.core.SetIterator;

class Set implements ISet {
	var _size:UInt = (0 : UInt);

	var _items:ASDictionary<ASAny, ASAny>;

	var _stringItems:ASObject;

	public function new() {
		this._items = new ASDictionary<ASAny, ASAny>();
		this._stringItems = new ASObject();
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return this._size;
	}

	public function remove(item:ASAny):Bool {
		if (Std.isOfType(item, String)) {
			if (!ASCompat.hasProperty(this._stringItems, item)) {
				return false;
			}
			ASCompat.deleteProperty(this._stringItems, item);
		} else {
			if (!this._items.exists(item)) {
				return false;
			}
			this._items.remove(item);
		}
		--this._size;
		return true;
	}

	public function clear():Bool {
		if (this._size == 0) {
			return false;
		}
		this._items = new ASDictionary<ASAny, ASAny>();
		this._stringItems = new ASObject();
		this._size = (0 : UInt);
		return true;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		return new SetIterator(this);
	}

	public function add(item:ASAny):Bool {
		if (Std.isOfType(item, String)) {
			if (ASCompat.hasProperty(this._stringItems, item)) {
				return false;
			}
			this._stringItems[item] = item;
		} else {
			if (this._items.exists(item)) {
				return false;
			}
			this._items[item] = item;
		}
		++this._size;
		return true;
	}

	public function has(item:ASAny):Bool {
		if (Std.isOfType(item, String)) {
			return ASCompat.hasProperty(this._stringItems, item);
		}
		return this._items.exists(item);
	}

	public function toArray():Array<ASAny> {
		var _loc2_:ASAny = /*undefined*/ null;
		var _loc1_ = new Array<ASAny>();
		final __ax4_iter_174:ASObject = this._stringItems;
		if (checkNullIteratee(__ax4_iter_174))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_174)) {
				_loc2_ = _tmp_;
				_loc1_.push(_loc2_);
			}
		final __ax4_iter_175 = this._items;
		if (checkNullIteratee(__ax4_iter_175))
			for (_tmp_ in __ax4_iter_175) {
				_loc2_ = _tmp_;
				_loc1_.push(_loc2_);
			}
		return _loc1_;
	}
}
