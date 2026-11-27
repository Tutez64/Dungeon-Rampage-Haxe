package gameMasterDictionary;

class GMMapIterator {
	public var mMap:GMMap;

	public var mKeys:Array<ASAny>;

	public var mIndex:Int = 0;

	public function new(map:GMMap = /*undefined*/ null, keys:Array<ASAny> = /*undefined*/ null) {
		mMap = map;
		mKeys = ASCompat.coerce(keys.copy(), Array);
		mIndex = -1;
	}

	public function next():ASAny {
		if (!hasNext()) {
			mIndex = mKeys.length;
			return null;
		}
		++mIndex;
		return mMap.itemFor(mKeys[mIndex]);
	}

	public function hasNext():Bool {
		return mIndex + 1 < mKeys.length;
	}

	@:isVar public var key(get, never):ASAny;

	public function get_key():ASAny {
		if (mIndex >= 0 && mIndex < mKeys.length) {
			return mKeys[mIndex];
		}
		return null;
	}

	@:isVar public var current(get, never):ASAny;

	public function get_current():ASAny {
		if (mIndex >= 0 && mIndex < mKeys.length) {
			return mMap.itemFor(mKeys[mIndex]);
		}
		return null;
	}
}
