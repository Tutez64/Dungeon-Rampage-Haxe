package brain.utils;

class ObjectPool {
	var mPool:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new() {
		MemoryTracker.track(mPool, "Dictionary - pool storage in ObjectPool()", "pool");
	}

	public function toString():String {
		var _loc2_:ASAny = /*undefined*/ null;
		var _loc1_ = "";
		var _loc3_:String;
		final __ax4_iter_64 = mPool;
		if (checkNullIteratee(__ax4_iter_64))
			for (_tmp_ in __ax4_iter_64.keys()) {
				_loc3_ = _tmp_;
				_loc2_ = mPool[_loc3_];
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
			return (mPool[key] : Vector<IPoolable>);
		}
		_loc2_ = new Vector<IPoolable>();
		mPool[key] = _loc2_;
		MemoryTracker.track(_loc2_, "Vector.<IPoolable> - pool key \'" + key + "\' in ObjectPool.getPool()", "pool");
		return _loc2_;
	}

	public function checkout(..._rest:ASAny):IPoolable {
		var rest = ASCompat.restToArray(_rest);
		var _loc2_:IPoolable = null;
		var _loc3_ = false;
		var _loc5_ = getPoolKey(rest);
		var _loc4_ = getPool(_loc5_);
		if (_loc4_.length != 0) {
			_loc2_ = _loc4_.pop();
			reset(_loc2_, rest);
			_loc3_ = false;
		} else {
			_loc2_ = construct(rest);
			_loc3_ = true;
		}
		_loc2_.postCheckout(_loc3_);
		return _loc2_;
	}

	public function checkin(object:IPoolable) {
		object.postCheckin();
		var _loc2_ = getPool(object.getPoolKey());
		_loc2_.push(object);
	}

	public function clear() {
		var _loc2_:IPoolable;
		var _loc1_:Vector<IPoolable>;
		final __ax4_iter_65 = mPool;
		if (checkNullIteratee(__ax4_iter_65))
			for (_tmp_ in __ax4_iter_65) {
				_loc1_ = (_tmp_ : Vector<IPoolable>);
				if (checkNullIteratee(_loc1_))
					for (_tmp_ in _loc1_) {
						_loc2_ = _tmp_;
						_loc2_.destroy();
					}
			}
		mPool = new ASDictionary<ASAny, ASAny>();
	}

	public function destroy() {
		this.clear();
		mPool = null;
	}
}
