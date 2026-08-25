package org.as3commons.collections;

import org.as3commons.collections.framework.IComparator;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.ISortedMap;
import org.as3commons.collections.framework.core.AbstractSortedDuplicatesCollection;
import org.as3commons.collections.framework.core.SortedMapIterator;
import org.as3commons.collections.framework.core.SortedMapNode;
import org.as3commons.collections.framework.core.SortedNode;
import org.as3commons.collections.SortedMap;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.core.SortedMapNode;
import org.as3commons.collections.framework.core.SortedNode;

/*use*/ /*namespace*/ /*as3commons_collections*/ class SortedMap extends AbstractSortedDuplicatesCollection implements ISortedMap {
	var _items:ASDictionary<ASAny, ASAny>;

	var _stringMap:ASObject;

	var _keys:ASDictionary<ASAny, ASAny>;

	public function new(comparator:IComparator) {
		super(comparator);
		this._items = new ASDictionary<ASAny, ASAny>();
		this._keys = new ASDictionary<ASAny, ASAny>();
		this._stringMap = new ASObject();
	}

	override function addNode(node:SortedNode) {
		super.addNode(node);
		var _loc2_:ASAny = cast(node, SortedMapNode).key;
		if (Std.isOfType(_loc2_, String)) {
			this._stringMap[_loc2_] = node;
		} else {
			this._keys[_loc2_] = _loc2_;
			this._items[_loc2_] = node;
		}
	}

	public function equalKeys(item:ASAny):Array<ASAny> {
		var _loc2_ = new Array<ASAny>();
		var _loc3_ = firstEqualNode(item);
		if (_loc3_ == null) {
			return _loc2_;
		}
		while (_loc3_ != null) {
			if (_comparator.compare(item, _loc3_.item) != 0) {
				break;
			}
			_loc2_.push(cast(_loc3_, SortedMapNode).key);
			_loc3_ = nextNode_internal(_loc3_);
		}
		return _loc2_;
	}

	public function keysToArray():Array<ASAny> {
		var _loc1_ = mostLeftNode_internal();
		var _loc2_ = new Array<ASAny>();
		while (_loc1_ != null) {
			_loc2_.push(cast(_loc1_, SortedMapNode).key);
			_loc1_ = nextNode_internal(_loc1_);
		}
		return _loc2_;
	}

	override public function clear():Bool {
		if (_size == 0) {
			return false;
		}
		this._keys = new ASDictionary<ASAny, ASAny>();
		this._items = new ASDictionary<ASAny, ASAny>();
		this._stringMap = new ASObject();
		super.clear();
		return true;
	}

	public function higherKey(item:ASAny):ASAny {
		var _loc2_ = ASCompat.reinterpretAs(higherNode(item), SortedMapNode);
		if (_loc2_ == null) {
			return /*undefined*/ null;
		}
		return _loc2_.key;
	}

	public function add(key:ASAny, item:ASAny):Bool {
		if (Std.isOfType(key, String)) {
			if (ASCompat.hasProperty(this._stringMap, key)) {
				return false;
			}
		} else if (this._keys.exists(key)) {
			return false;
		}
		this.addNode(new SortedMapNode(key, item));
		return true;
	}

	public function hasKey(key:ASAny):Bool {
		return Std.isOfType(key, String) ? ASCompat.hasProperty(this._stringMap, key) : this._keys.exists(key);
	}

	public function keyIterator():IIterator {
		return new KeyIterator(this);
	}

	override public function iterator(cursor:ASAny = /*undefined*/ null):IIterator {
		var _loc2_:SortedMapNode = null;
		if (Std.isOfType(cursor, String)) {
			_loc2_ = ASCompat.dynamicAs(this._stringMap[cursor], org.as3commons.collections.framework.core.SortedMapNode);
		} else {
			_loc2_ = ASCompat.dynamicAs(this._items[cursor], org.as3commons.collections.framework.core.SortedMapNode);
		}
		return new SortedMapIterator(this, _loc2_);
	}

	public function replaceFor(key:ASAny, item:ASAny):Bool {
		var _loc3_:SortedMapNode = null;
		if (Std.isOfType(key, String)) {
			_loc3_ = ASCompat.dynamicAs(this._stringMap[key], org.as3commons.collections.framework.core.SortedMapNode);
		} else {
			_loc3_ = ASCompat.dynamicAs(this._items[key], org.as3commons.collections.framework.core.SortedMapNode);
		}
		if (_loc3_ != null && _loc3_.item != item) {
			this.removeNode(_loc3_);
			_loc3_.item = item;
			this.addNode(_loc3_);
			return true;
		}
		return false;
	}

	public function itemFor(key:ASAny):ASAny {
		var _loc2_:SortedMapNode = null;
		if (Std.isOfType(key, String)) {
			_loc2_ = ASCompat.dynamicAs(this._stringMap[key], org.as3commons.collections.framework.core.SortedMapNode);
		} else {
			_loc2_ = ASCompat.dynamicAs(this._items[key], org.as3commons.collections.framework.core.SortedMapNode);
		}
		return _loc2_ != null ? _loc2_.item : /*undefined*/ null;
	}

	function getNode(key:ASAny):SortedMapNode {
		if (Std.isOfType(key, String)) {
			return ASCompat.dynamicAs(this._stringMap[key], org.as3commons.collections.framework.core.SortedMapNode);
		}
		return ASCompat.dynamicAs(this._items[key], org.as3commons.collections.framework.core.SortedMapNode);
	}

	public function lesserKey(item:ASAny):ASAny {
		var _loc2_ = ASCompat.reinterpretAs(lesserNode(item), SortedMapNode);
		if (_loc2_ == null) {
			return /*undefined*/ null;
		}
		return _loc2_.key;
	}

	public function removeKey(key:ASAny):ASAny {
		var _loc2_:SortedMapNode = null;
		if (Std.isOfType(key, String)) {
			if (!ASCompat.hasProperty(this._stringMap, key)) {
				return /*undefined*/ null;
			}
			_loc2_ = ASCompat.dynamicAs(this._stringMap[key], org.as3commons.collections.framework.core.SortedMapNode);
		} else {
			if (!this._keys.exists(key)) {
				return /*undefined*/ null;
			}
			_loc2_ = ASCompat.dynamicAs(this._items[key], org.as3commons.collections.framework.core.SortedMapNode);
		}
		this.removeNode(_loc2_);
		return _loc2_.item;
	}

	override function removeNode(node:SortedNode) {
		super.removeNode(node);
		var _loc2_:ASAny = cast(node, SortedMapNode).key;
		if (Std.isOfType(_loc2_, String)) {
			ASCompat.deleteProperty(this._stringMap, _loc2_);
		} else {
			this._keys.remove(_loc2_);
			this._items.remove(_loc2_);
		}
	}
}

private class KeyIterator implements IIterator {
	var _next:SortedNode;

	var _map:SortedMap;

	public function new(map:SortedMap) {
		this._map = map;
		this._next = map.mostLeftNode_internal();
	}

	public function next():ASAny {
		if (this._next == null) {
			return /*undefined*/ null;
		}
		var _loc1_ = this._next;
		this._next = this._map /*as3commons_collections::*/ .nextNode_internal(this._next);
		return cast(_loc1_, SortedMapNode).key;
	}

	public function hasNext():Bool {
		return this._next != null;
	}
}
