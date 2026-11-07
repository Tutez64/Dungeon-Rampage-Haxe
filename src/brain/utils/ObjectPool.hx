package brain.utils;

class ObjectPool {
	var mPool:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mStats:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new() {
		MemoryTracker.track(mPool, "Dictionary - pool storage in ObjectPool()", "pool");
	}

	public function toString():String {
		var _loc2_:Vector<IPoolable> = /*undefined*/ null;
		var _loc1_ = "";
		var _loc3_:String;
		final __ax4_iter_41 = mPool;
		if (checkNullIteratee(__ax4_iter_41))
			for (_tmp_ in __ax4_iter_41.keys()) {
				_loc3_ = _tmp_;
				_loc2_ = (ASDictionary.getString(mPool, _loc3_) : Vector<IPoolable>);
				_loc1_ += Std.string(_loc2_.length) + "\t: " + _loc3_ + "\n";
			}
		return _loc1_;
	}

	function construct(parameters:Array<ASAny>):IPoolable {
		return null;
	}

	function reset(poolable:IPoolable, parameters:Array<ASAny>) {}

	function getPoolKey(parameters:Array<ASAny>):String {
		return "";
	}

	function getPool(key:String):Vector<IPoolable> {
		var _loc2_:Vector<IPoolable> = /*undefined*/ null;
		if (mPool.exists(key)) {
			return (ASDictionary.getString(mPool, key) : Vector<IPoolable>);
		}
		_loc2_ = new Vector<IPoolable>();
		mPool[key] = _loc2_;
		MemoryTracker.track(_loc2_, "Vector.<IPoolable> - pool key \'" + key + "\' in ObjectPool.getPool()", "pool");
		return _loc2_;
	}

	function statsFor(key:String):PoolStats {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mStats, key), PoolStats);
		if (_loc2_ == null) {
			_loc2_ = new PoolStats();
			mStats[key] = _loc2_;
		}
		return _loc2_;
	}

	public function checkout(..._rest:ASAny):IPoolable {
		var rest = ASCompat.restToArray(_rest);
		var _loc2_:IPoolable = null;
		var _loc3_ = false;
		var _loc6_ = getPoolKey(rest);
		var _loc5_ = getPool(_loc6_);
		var _loc4_ = statsFor(_loc6_);
		_loc4_.checkouts++;
		if (_loc5_.length != 0) {
			_loc2_ = _loc5_.pop();
			reset(_loc2_, rest);
			_loc3_ = false;
			_loc4_.reuses++;
		} else {
			_loc2_ = construct(rest);
			_loc3_ = true;
			_loc4_.constructed++;
		}
		_loc2_.postCheckout(_loc3_);
		return _loc2_;
	}

	public function checkin(object:IPoolable) {
		object.postCheckin();
		var _loc4_ = object.getPoolKey();
		var _loc3_ = getPool(_loc4_);
		var _loc2_ = statsFor(_loc4_);
		_loc2_.checkins++;
		_loc3_.push(object);
	}

	public function stats():Array<ASAny> {
		var _loc1_:PoolStats = null;
		var _loc2_:Vector<IPoolable> = /*undefined*/ null;
		var _loc3_:Array<ASAny> = [];
		var _loc4_:String;
		final __ax4_iter_42 = mStats;
		if (checkNullIteratee(__ax4_iter_42))
			for (_tmp_ in __ax4_iter_42.keys()) {
				_loc4_ = _tmp_;
				_loc1_ = ASCompat.coerce(ASDictionary.getString(mStats, _loc4_), PoolStats);
				_loc2_ = (ASDictionary.getString(mPool, _loc4_) : Vector<IPoolable>);
				_loc3_.push({
					"key": _loc4_,
					"pooled": (_loc2_ != null ? _loc2_.length : 0),
					"constructed": _loc1_.constructed,
					"checkouts": _loc1_.checkouts,
					"reuses": _loc1_.reuses,
					"checkins": _loc1_.checkins,
					"out": _loc1_.checkouts - _loc1_.checkins,
					"dupes": _loc1_.dupes
				});
			}
		ASCompat.ASArray.sortOn(_loc3_, "key", 0);
		return _loc3_;
	}

	public function clear() {
		var _loc2_:IPoolable;
		var _loc1_:Vector<IPoolable>;
		final __ax4_iter_43 = mPool;
		if (checkNullIteratee(__ax4_iter_43))
			for (_tmp_ in __ax4_iter_43) {
				_loc1_ = (_tmp_ : Vector<IPoolable>);
				if (checkNullIteratee(_loc1_))
					for (_tmp_ in _loc1_) {
						_loc2_ = _tmp_;
						_loc2_.destroy();
					}
			}
		mPool = new ASDictionary<ASAny, ASAny>();
		mStats = new ASDictionary<ASAny, ASAny>();
	}

	public function destroy() {
		this.clear();
		mPool = null;
		mStats = null;
	}
}

private class PoolStats {
	public var constructed:Int = 0;

	public var checkouts:Int = 0;

	public var reuses:Int = 0;

	public var checkins:Int = 0;

	public var dupes:Int = 0;

	public function new() {}
}
