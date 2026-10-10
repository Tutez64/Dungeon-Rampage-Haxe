package org.as3commons.collections;

import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.IOrderedList;
import org.as3commons.collections.framework.core.AbstractList;
import org.as3commons.collections.framework.core.ArrayListIterator;
import org.as3commons.collections.utils.ArrayUtils;

class ArrayList extends AbstractList implements IOrderedList {
	public function new() {
		super();
	}

	public function reverse():Bool {
		if (_array.length < 2) {
			return false;
		}
		ASCompat.ASArray.reverse(_array);
		return true;
	}

	public function sort(comparator:IComparator):Bool {
		if (_array.length < 2) {
			return false;
		}
		ArrayUtils.mergeSort(_array, comparator);
		return true;
	}

	public function addAllAt(index:UInt, items:Array<ASAny>):Bool {
		if (index <= (_array.length : UInt)) {
			_array = _array.slice(0, (index : Int)).concat(items).concat(_array.slice((index : Int)));
			return true;
		}
		return false;
	}

	public function replaceAt(index:UInt, item:ASAny):Bool {
		if (index < (_array.length:UInt)) {
			if (_array[(index : Int)] == item) {
				return false;
			}
			_array[(index : Int)] = item;
			return true;
		}
		return false;
	}

	public function addFirst(item:ASAny) {
		_array.unshift(item);
	}

	public function addAt(index:UInt, item:ASAny):Bool {
		if (index <= (_array.length : UInt)) {
			ASCompat.arraySplice(_array, (index : Int), (0 : UInt), [item]);
			return true;
		}
		return false;
	}

	override public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		var _loc2_ = (Std.isOfType(cursor, Int) ? (ASCompat.toInt(cursor) : UInt) : (0 : UInt):UInt);
		return new ArrayListIterator(this, _loc2_);
	}

	public function addLast(item:ASAny) {
		_array.push(item);
	}
}
