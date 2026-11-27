package com.junkbyte.console.vos;

import haxe.Constraints.IMap;
import haxe.ds.IntMap;

class WeakObject {
	public var _dict:IMap<ASAny, ASAny>;

	public function new() {
		_dict = new IntMap<ASAny>();
	}

	public function set(_tmp_n:ASObject, obj:ASAny, strong:Bool = false) {
		var _loc5_ = ASCompat.dynamicAs(null, IMap);
		var _loc6_ = ASCompat.dynamicAs(null, WeakRef);
		var _loc4_:ASObject = _tmp_n;
		remove(_loc4_);
		if (obj != null) {
			_loc5_ = _dict;
			_loc6_ = new WeakRef(obj, strong);
			_loc5_.set(ASCompat.toInt(_loc4_), _loc6_);
		}
	}

	public function remove(_tmp_n:ASObject) {
		var _loc2_:ASObject = _tmp_n;
		cast(_dict, IntMap<Dynamic>).remove(ASCompat.toInt(_loc2_));
	}

	public function keys():Array<ASAny> {
		var _loc3_:ASAny = (null : ASObject);
		var _loc1_:Array<ASAny> = [];
		var _loc2_:ASAny = cast(_dict, IntMap<Dynamic>).keys();
		while (ASCompat.toBool(_loc2_.hasNext())) {
			_loc3_ = _loc2_.next();
			_loc1_.push(_loc3_);
		}
		return _loc1_;
	}

	public function getWeakRef(_tmp_n:ASObject):WeakRef {
		var _loc2_:ASObject = _tmp_n;
		return ASCompat.coerce(cast(_dict, IntMap<Dynamic>).get(ASCompat.toInt(_loc2_)), com.junkbyte.console.vos.WeakRef);
	}

	public function getReferenceIndex(reference:ASAny):ASObject {
		var _loc3_:ASAny = (null : ASObject);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, WeakRef);
		var _loc2_:ASAny = cast(_dict, IntMap<Dynamic>).keys();
		while (ASCompat.toBool(_loc2_.hasNext())) {
			_loc3_ = _loc2_.next();
			_loc4_ = cast(_dict, IntMap<Dynamic>).get(ASCompat.toInt(_loc3_));
			if (_loc4_.get_reference() == reference) {
				return _loc3_;
			}
		}
		return null;
	}

	public function get(_tmp_n:ASObject):ASAny {
		var _loc2_:ASObject = _tmp_n;
		var _loc3_ = getWeakRef(_loc2_);
		if (_loc3_ != null) {
			return _loc3_.get_reference();
		}
		return null;
	}

	public function exists(_tmp_n:ASObject):Bool {
		var _loc2_:ASObject = _tmp_n;
		var _loc3_ = _dict;
		if (cast(_loc3_, IntMap<Dynamic>).exists(ASCompat.toInt(_loc2_))) {
			return get(_loc2_) != null;
		}
		return false;
	}
}
