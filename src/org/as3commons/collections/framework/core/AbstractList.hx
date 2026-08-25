package org.as3commons.collections.framework.core;

import org.as3commons.collections.framework.IDataProvider;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.IList;

/*use*/ /*namespace*/ /*as3commons_collections*/ class AbstractList implements IList implements IDataProvider {
	var _array:Array<ASAny>;

	public function new() {
		this._array = new Array<ASAny>();
	}

	public function firstIndexOf(item:ASAny):Int {
		return this._array.indexOf(item);
	}

	@:isVar public var array(never, set):Array<ASAny>;

	public function set_array(array:Array<ASAny>):Array<ASAny> {
		this._array = array.copy();
		return array;
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return (this._array.length : UInt);
	}

	public function removeLast():ASAny {
		return this._array.pop();
	}

	public function remove(item:ASAny):Bool {
		var _loc2_ = this._array.indexOf(item);
		if (_loc2_ == -1) {
			return false;
		}
		this._array.splice(_loc2_, (1 : UInt));
		this.itemRemoved((_loc2_ : UInt), item);
		return true;
	}

	public function removeFirst():ASAny {
		return this._array.shift();
	}

	public function clear():Bool {
		if (this._array.length == 0) {
			return false;
		}
		this._array = new Array<ASAny>();
		return true;
	}

	public function removeAllAt(index:UInt, numItems:UInt):Array<ASAny> {
		return this._array.splice((index : Int), numItems);
	}

	function itemRemoved(index:UInt, item:ASAny) {}

	public function removeAt(index:UInt):ASAny {
		return this._array.splice((index : Int), (1 : UInt))[0];
	}

	@:isVar public var last(get, never):ASAny;

	public function get_last():ASAny {
		return this._array[this._array.length - 1];
	}

	public function count(item:ASAny):UInt {
		var _loc2_ = (0 : UInt);
		var _loc3_ = (this._array.length : UInt);
		var _loc4_ = 0;
		while ((_loc4_ : UInt) < _loc3_) {
			if (this._array[_loc4_] == item) {
				_loc2_++;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc2_;
	}

	public function add(item:ASAny):UInt {
		this._array.push(item);
		return (this._array.length - 1:UInt);
	}

	public function lastIndexOf(item:ASAny):Int {
		var _loc2_ = this._array.length - 1;
		while (_loc2_ >= 0) {
			if (item == this._array[_loc2_]) {
				return _loc2_;
			}
			_loc2_ = ASCompat.toInt(_loc2_) - 1;
		}
		return -1;
	}

	public function toArray():Array<ASAny> {
		return this._array.copy();
	}

	public function itemAt(index:UInt):ASAny {
		return this._array[(index : Int)];
	}

	public function has(item:ASAny):Bool {
		return this.firstIndexOf(item) > -1;
	}

	/*as3commons_collections*/ @:isVar public var array_internal(get, never):Array<ASAny>;

	public function get_array_internal():Array<ASAny> {
		return this._array;
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		var _loc2_ = (Std.isOfType(cursor, Int) ? (ASCompat.toInt(cursor) : UInt) : (0 : UInt):UInt);
		return new AbstractListIterator(this, _loc2_);
	}

	@:isVar public var first(get, never):ASAny;

	public function get_first():ASAny {
		return this._array[0];
	}

	public function removeAll(item:ASAny):UInt {
		var _loc2_ = (this._array.length : UInt);
		var _loc3_ = 0;
		while ((_loc3_ : UInt) < _loc2_) {
			if (this._array[_loc3_] == item) {
				this._array.splice(_loc3_, (1 : UInt));
				this.itemRemoved((_loc3_ : UInt), item);
				_loc3_ = ASCompat.toInt(_loc3_) - 1;
			}
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		return _loc2_ - this._array.length;
	}
}
