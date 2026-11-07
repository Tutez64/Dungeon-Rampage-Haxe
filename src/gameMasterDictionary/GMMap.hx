package gameMasterDictionary;

class GMMap {
	public var mKeys:Array<ASAny>;

	public var mDict:ASDictionary<ASAny, ASAny>;

	public function new() {
		mDict = new ASDictionary<ASAny, ASAny>();
		mKeys = [];
	}

	public function toArray():Array<ASAny> {
		var _loc4_:ASAny = null;
		var _loc1_:Array<ASAny> = [];
		var _loc2_ = 0;
		var _loc3_ = mKeys;
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc1_.push(itemFor(_loc4_));
		}
		return _loc1_;
	}

	public function removeKey(key:ASAny):ASAny {
		if (!hasKey(key)) {
			return null;
		}
		var _loc2_:ASAny = mDict[key];
		mDict.remove(key);
		mKeys.remove(key);
		return _loc2_;
	}

	public function keysToArray():Array<ASAny> {
		return ASCompat.coerce(mKeys.copy(), Array);
	}

	public function iterator(cursor:ASAny = /*undefined*/ null):GMMapIterator {
		return new GMMapIterator(this, mKeys);
	}

	public function itemFor(key:ASAny):ASAny {
		return mDict[key];
	}

	public function hasKey(key:ASAny):Bool {
		return mDict.exists(key);
	}

	@:isVar public var size(get, never):UInt;

	public function get_size():UInt {
		return (mKeys.length : UInt);
	}

	public function clear():Bool {
		if (mKeys.length == 0) {
			return false;
		}
		mDict = new ASDictionary<ASAny, ASAny>();
		mKeys = [];
		return true;
	}

	public function add(key:ASAny, item:ASAny):Bool {
		if (hasKey(key)) {
			return false;
		}
		mDict[key] = item;
		mKeys.push(key);
		return true;
	}
}
