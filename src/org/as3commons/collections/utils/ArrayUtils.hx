package org.as3commons.collections.utils;

import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IMap;

class ArrayUtils {
	public function new() {}

	public static function shuffle(array:Array<ASAny>):Bool {
		var _loc3_ = (0 : UInt);
		var _loc4_:ASAny = /*undefined*/ null;
		var _loc2_ = (array.length : UInt);
		if (_loc2_ < 2) {
			return false;
		}
		while (--_loc2_ != 0) {
			_loc3_ = (Math.floor(Math.random() * (_loc2_ + 1)) : UInt);
			_loc4_ = array[(_loc2_ : Int)];
			array[(_loc2_ : Int)] = array[(_loc3_ : Int)];
			array[(_loc3_ : Int)] = _loc4_;
		}
		return true;
	}

	public static function arraysEqual(array1:Array<ASAny>, array2:Array<ASAny>):Bool {
		if (array1 == array2) {
			return true;
		}
		var _loc3_:Float = array1.length;
		if (_loc3_ != array2.length) {
			return false;
		}
		while (ASCompat.floatAsBool(_loc3_--)) {
			if (array1[Std.int(_loc3_)] != array2[Std.int(_loc3_)]) {
				return false;
			}
		}
		return true;
	}

	public static function arraysMatch(array1:Array<ASAny>, array2:Array<ASAny>):Bool {
		if (array1 == array2) {
			return true;
		}
		var _loc3_:Float = array1.length;
		if (_loc3_ != array2.length) {
			return false;
		}
		var _loc4_:IMap = new Map();
		while (ASCompat.floatAsBool(_loc3_--)) {
			if (_loc4_.hasKey(array1[Std.int(_loc3_)])) {
				_loc4_.replaceFor(array1[Std.int(_loc3_)], _loc4_.itemFor(array1[Std.int(_loc3_)]) + 1);
			} else {
				_loc4_.add(array1[Std.int(_loc3_)], 1);
			}
		}
		_loc3_ = array2.length;
		while (ASCompat.floatAsBool(_loc3_--)) {
			if (!_loc4_.hasKey(array2[Std.int(_loc3_)])) {
				return false;
			}
			if (ASCompat.toNumber(_loc4_.itemFor(array2[Std.int(_loc3_)])) == 1) {
				_loc4_.removeKey(array2[Std.int(_loc3_)]);
			} else {
				_loc4_.replaceFor(array2[Std.int(_loc3_)], ASCompat.toNumber(_loc4_.itemFor(array2[Std.int(_loc3_)])) - 1);
			}
		}
		return _loc4_.size == 0;
	}

	public static function insertionSort(array:Array<ASAny>, comparator:IComparator):Bool {
		var _loc5_:ASAny = /*undefined*/ null;
		var _loc6_ = (0 : UInt);
		if (array.length < 2) {
			return false;
		}
		var _loc3_ = (array.length : UInt);
		var _loc4_ = (1 : UInt);
		while (_loc4_ < _loc3_) {
			_loc5_ = array[(_loc4_ : Int)];
			_loc6_ = _loc4_;
			while (_loc6_ > 0 && comparator.compare(array[(_loc6_ - 1 : Int)], _loc5_) == 1) {
				array[(_loc6_ : Int)] = array[(_loc6_ - 1 : Int)];
				_loc6_--;
			}
			array[(_loc6_ : Int)] = _loc5_;
			_loc4_++;
		}
		return true;
	}

	public static function mergeSort(array:Array<ASAny>, comparator:IComparator):Bool {
		if (array.length < 2) {
			return false;
		}
		var _loc3_ = (Math.floor(array.length / 2) : UInt);
		var _loc4_ = array.length - _loc3_;
		var _loc5_ = ASCompat.allocArray(_loc3_);
		var _loc6_ = ASCompat.allocArray(_loc4_);
		var _loc7_ = (0 : UInt);
		_loc7_ = (0 : UInt);
		while (_loc7_ < _loc3_) {
			_loc5_[(_loc7_ : Int)] = array[(_loc7_ : Int)];
			_loc7_++;
		}
		_loc7_ = _loc3_;
		while (_loc7_ < _loc3_ + _loc4_) {
			_loc6_[(_loc7_ - _loc3_ : Int)] = array[(_loc7_ : Int)];
			_loc7_++;
		}
		mergeSort(_loc5_, comparator);
		mergeSort(_loc6_, comparator);
		_loc7_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		var _loc9_ = (0 : UInt);
		while ((_loc5_.length : UInt) != _loc8_ && (_loc6_.length : UInt) != _loc9_) {
			if (comparator.compare(_loc5_[(_loc8_ : Int)], _loc6_[(_loc9_ : Int)]) != 1) {
				array[(_loc7_ : Int)] = _loc5_[(_loc8_ : Int)];
				_loc7_++;
				_loc8_++;
			} else {
				array[(_loc7_ : Int)] = _loc6_[(_loc9_ : Int)];
				_loc7_++;
				_loc9_++;
			}
		}
		while ((_loc5_.length : UInt) != _loc8_) {
			array[(_loc7_ : Int)] = _loc5_[(_loc8_ : Int)];
			_loc7_++;
			_loc8_++;
		}
		while ((_loc6_.length : UInt) != _loc9_) {
			array[(_loc7_ : Int)] = _loc6_[(_loc9_ : Int)];
			_loc7_++;
			_loc9_++;
		}
		return true;
	}
}
