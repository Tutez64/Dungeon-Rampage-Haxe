package collections;

import flash.Boot;

class StringKeyStore {
	public static var _reserved:ASAny = {};

	public var _overflow:ASAny;

	public var _main:ASAny;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		_main = {};
	}

	public function unescape(escapedKey:String):String {
		return escapedKey.substr(1);
	}

	public function set(key:String, value:ASAny) {
		if (isReserved(key)) {
			if (_overflow == null) {
				_overflow = {};
			}
			_overflow[ASCompat.escape(key)] = value;
		} else {
			_main[key] = value;
		}
	}

	public function remove(key:String) {
		var _loc2_:ASAny = null;
		var _loc3_:String = null;
		if (isReserved(key)) {
			if (_overflow != null) {
				_loc2_ = _overflow;
				_loc3_ = ASCompat.escape(key);
				ASCompat.deleteProperty(_loc2_, _loc3_);
			}
		} else {
			_loc2_ = _main;
			ASCompat.deleteProperty(_loc2_, key);
		}
	}

	public function keys():Array<ASAny> {
		var _loc3_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc4_ = 0;
		var _loc5_:ASAny = null;
		var _loc6_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc7_ = 0;
		var _loc8_:ASAny = null;
		var _loc1_:ASAny = _main;
		_loc4_ = 0;
		_loc3_ = [];
		_loc5_ = _loc1_;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_.___keys()) {
				_loc4_ = ASCompat.toInt(_tmp_);
				_loc3_.push(_loc4_);
			}
		var _loc2_ = _loc3_;
		if (_overflow != null) {
			_loc4_ = 0;
			_loc5_ = _overflow;
			_loc7_ = 0;
			_loc6_ = [];
			_loc8_ = _loc5_;
			if (checkNullIteratee(_loc8_))
				for (_tmp_ in _loc8_.___keys()) {
					_loc7_ = ASCompat.toInt(_tmp_);
					_loc6_.push(_loc7_);
				}
			_loc3_ = _loc6_;
			while (_loc4_ < ASCompat.toInt(_loc3_.length)) {
				_loc8_ = _loc3_[_loc4_];
				_loc4_++;
				_loc2_.push(ASCompat.unescape(_loc8_));
			}
		}
		return _loc2_;
	}

	public function isReserved(key:String):Bool {
		var _loc2_:ASAny = StringKeyStore._reserved;
		return _loc2_.hasOwnProperty(key);
	}

	public function hasKey(key:String):Bool {
		var _loc2_:ASAny = null;
		var _loc3_:String = null;
		if (isReserved(key)) {
			if (_overflow != null) {
				_loc2_ = _overflow;
				_loc3_ = ASCompat.escape(key);
				return _loc2_.hasOwnProperty(_loc3_);
			}
			return false;
		}
		_loc2_ = _main;
		return _loc2_.hasOwnProperty(key);
	}

	public function get(key:String):ASAny {
		if (isReserved(key)) {
			if (_overflow == null) {
				return /*undefined*/ null;
			}
			return _overflow[ASCompat.escape(key)];
		}
		return _main[key];
	}

	public function escape(key:String):String {
		return "$" + key;
	}

	public function clear() {
		_main = {};
		_overflow = null;
	}
}
