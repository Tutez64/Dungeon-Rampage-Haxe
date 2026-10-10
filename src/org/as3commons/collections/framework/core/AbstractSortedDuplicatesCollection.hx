package org.as3commons.collections.framework.core;

import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IDuplicates;

/*use*/ /*namespace*/ /*as3commons_collections*/ class AbstractSortedDuplicatesCollection extends AbstractSortedCollection implements IDuplicates {
	public function new(comparator:IComparator) {
		super(comparator);
	}

	public function removeAll(item:ASAny):UInt {
		var _loc4_:SortedNode = null;
		var _loc2_ = firstEqualNode(item);
		if (_loc2_ == null) {
			return (0 : UInt);
		}
		var _loc3_ = (0 : UInt);
		while (_loc2_ != null) {
			if (_comparator.compare(item, _loc2_.item) != 0) {
				break;
			}
			if (_loc2_.item == item) {
				_loc4_ = nextNode_internal(_loc2_);
				removeNode(_loc2_);
				_loc2_ = _loc4_;
				_loc3_++;
			} else {
				_loc2_ = nextNode_internal(_loc2_);
			}
		}
		return _loc3_;
	}

	public function count(item:ASAny):UInt {
		var _loc2_ = firstEqualNode(item);
		if (_loc2_ == null) {
			return (0 : UInt);
		}
		var _loc3_ = (0 : UInt);
		if (_loc2_.item == item) {
			_loc3_++;
		}
		_loc2_ = nextNode_internal(_loc2_);
		while (_loc2_ != null) {
			if (_comparator.compare(item, _loc2_.item) != 0) {
				break;
			}
			if (_loc2_.item == item) {
				_loc3_++;
			}
			_loc2_ = nextNode_internal(_loc2_);
		}
		return _loc3_;
	}
}
