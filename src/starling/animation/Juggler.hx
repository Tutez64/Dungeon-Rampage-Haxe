package starling.animation;

import starling.events.Event;
import starling.events.EventDispatcher;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class Juggler implements IAnimatable {
	static var sCurrentObjectID:UInt = 0;

	var _objects:Vector<IAnimatable>;

	var _objectIDs:Vector<UInt>;

	var _elapsedTime:Float = Math.NaN;

	var _timeScale:Float = Math.NaN;

	public function new() {
		_elapsedTime = 0;
		_timeScale = 1;
		_objects = new Vector<IAnimatable>((0 : UInt));
		_objectIDs = new Vector<UInt>((0 : UInt));
	}

	static function getNextID():UInt {
		return ++sCurrentObjectID;
	}

	public function add(object:IAnimatable):UInt {
		return addWithID(object, getNextID());
	}

	function addWithID(object:IAnimatable, objectID:UInt):UInt {
		var _loc3_:EventDispatcher = null;
		if (object != null && !contains(object)) {
			_loc3_ = ASCompat.reinterpretAs(object, EventDispatcher);
			if (_loc3_ != null) {
				_loc3_.addEventListener("removeFromJuggler", onRemoveRequested);
			}
			_objects[_objects.length] = object;
			_objectIDs[_objectIDs.length] = objectID;
			return objectID;
		}
		return (0 : UInt);
	}

	public function contains(object:IAnimatable):Bool {
		return _objects.indexOf(object) != -1;
	}

	@:isVar public var isEmpty(get, never):Bool;

	public function get_isEmpty():Bool {
		return _objects.length == 0;
	}

	public function remove(object:IAnimatable):UInt {
		var _loc2_ = _objects.indexOf(object);
		if (_loc2_ != -1) {
			return removeByIndex(_loc2_);
		}
		return (0 : UInt);
	}

	function removeByIndex(index:Int):UInt {
		var _loc4_ = _objects[index];
		var _loc3_ = _objectIDs[index];
		_objects[index] = null;
		_objectIDs[index] = (0 : UInt);
		var _loc2_ = ASCompat.reinterpretAs(_loc4_, EventDispatcher);
		if (_loc2_ != null) {
			_loc2_.removeEventListener("removeFromJuggler", onRemoveRequested);
			_loc2_.dispatchEventWith("removedFromJuggler");
		}
		return _loc3_;
	}

	public function removeByID(objectID:UInt):UInt {
		var _loc2_ = _objectIDs.indexOf(objectID);
		if (_loc2_ != -1) {
			return removeByIndex(_loc2_);
		}
		return (0 : UInt);
	}

	public function removeTweens(target:ASObject) {
		var _loc3_ = 0;
		var _loc2_:Tween = null;
		if (target == null) {
			return;
		}
		_loc3_ = _objects.length - 1;
		while (_loc3_ >= 0) {
			_loc2_ = ASCompat.reinterpretAs(_objects[_loc3_], Tween);
			if (_loc2_ != null && _loc2_.target == target) {
				removeByIndex(_loc3_);
			}
			_loc3_--;
		}
	}

	public function removeDelayedCalls(callback:ASFunction) {
		var _loc2_ = 0;
		var _loc3_:DelayedCall = null;
		if (callback == null) {
			return;
		}
		_loc2_ = _objects.length - 1;
		while (_loc2_ >= 0) {
			_loc3_ = ASCompat.reinterpretAs(_objects[_loc2_], DelayedCall);
			if (_loc3_ != null && _loc3_.callback == callback) {
				removeByIndex(_loc2_);
			}
			_loc2_--;
		}
	}

	public function containsTweens(target:ASObject):Bool {
		var _loc3_ = 0;
		var _loc2_:Tween = null;
		if (ASCompat.toBool(target)) {
			_loc3_ = _objects.length - 1;
			while (_loc3_ >= 0) {
				_loc2_ = ASCompat.reinterpretAs(_objects[_loc3_], Tween);
				if (_loc2_ != null && _loc2_.target == target) {
					return true;
				}
				_loc3_--;
			}
		}
		return false;
	}

	public function containsDelayedCalls(callback:ASFunction):Bool {
		var _loc2_ = 0;
		var _loc3_:DelayedCall = null;
		if (callback != null) {
			_loc2_ = _objects.length - 1;
			while (_loc2_ >= 0) {
				_loc3_ = ASCompat.reinterpretAs(_objects[_loc2_], DelayedCall);
				if (_loc3_ != null && _loc3_.callback == callback) {
					return true;
				}
				_loc2_--;
			}
		}
		return false;
	}

	public function purge() {
		var _loc1_ = 0;
		_loc1_ = _objects.length - 1;
		while (_loc1_ >= 0) {
			removeByIndex(_loc1_);
			_loc1_--;
		}
	}

	public function delayCall(call:ASFunction, delay:Float, ..._rest:ASAny):UInt {
		var rest = ASCompat.restToArray(_rest);
		if (call == null) {
			throw new ArgumentError("call must not be null");
		}
		var _loc4_ = DelayedCall.fromPool(call, delay, rest);
		_loc4_.addEventListener("removedFromJuggler", onPooledDelayedCallRemovedFromJuggler);
		return add(_loc4_);
	}

	public function repeatCall(call:ASFunction, interval:Float, repeatCount:Int = 0, ..._rest:ASAny):UInt {
		var rest = ASCompat.restToArray(_rest);
		if (call == null) {
			throw new ArgumentError("call must not be null");
		}
		var _loc5_ = DelayedCall.fromPool(call, interval, rest);
		_loc5_.repeatCount = repeatCount;
		_loc5_.addEventListener("removedFromJuggler", onPooledDelayedCallRemovedFromJuggler);
		return add(_loc5_);
	}

	function onPooledDelayedCallRemovedFromJuggler(event:Event) {
		DelayedCall.toPool(ASCompat.reinterpretAs(event.target, DelayedCall));
	}

	public function tween(target:ASObject, time:Float, properties:ASObject):UInt {
		var _loc6_:ASObject = null;
		if (target == null) {
			throw new ArgumentError("target must not be null");
		}
		var _loc4_ = Tween.fromPool(target, time);
		var _loc5_:String;
		if (checkNullIteratee(properties))
			for (_tmp_ in properties.___keys()) {
				_loc5_ = _tmp_;
				_loc6_ = properties[_loc5_];
				if ((_loc4_ : ASAny).hasOwnProperty(_loc5_)) {
					(_loc4_ : ASAny)[_loc5_] = _loc6_;
				} else {
					if (!target.hasOwnProperty(Tween.getPropertyName(_loc5_))) {
						throw new ArgumentError("Invalid property: " + _loc5_);
					}
					_loc4_.animate(_loc5_, ASCompat.asNumber(_loc6_));
				}
			}
		_loc4_.addEventListener("removedFromJuggler", onPooledTweenRemovedFromJuggler);
		return add(_loc4_);
	}

	function onPooledTweenRemovedFromJuggler(event:Event) {
		Tween.toPool(ASCompat.reinterpretAs(event.target, Tween));
	}

	public function advanceTime(time:Float) {
		var _loc2_ = 0;
		var _loc5_:IAnimatable = null;
		var _loc4_ = _objects.length;
		var _loc3_ = 0;
		_elapsedTime += time;
		time *= _timeScale;
		if (_loc4_ == 0 || time == 0) {
			return;
		}
		_loc2_ = 0;
		while (_loc2_ < _loc4_) {
			_loc5_ = _objects[_loc2_];
			if (_loc5_ != null) {
				if (_loc3_ != _loc2_) {
					_objects[_loc3_] = _loc5_;
					_objectIDs[_loc3_] = _objectIDs[_loc2_];
					_objects[_loc2_] = null;
					_objectIDs[_loc2_] = (0 : UInt);
				}
				_loc5_.advanceTime(time);
				_loc3_++;
			}
			_loc2_++;
		}
		if (_loc3_ != _loc2_) {
			_loc4_ = _objects.length;
			while (_loc2_ < _loc4_) {
				_objects[_loc3_] = _objects[_loc2_];
				_objectIDs[_loc3_] = _objectIDs[_loc2_];
				_loc3_++;
				_loc2_++;
			}
			_objects.length = _loc3_;
			_objectIDs.length = _loc3_;
		}
	}

	function onRemoveRequested(event:Event) {
		var _loc2_:Tween = null;
		var _loc3_ = remove(ASCompat.reinterpretAs(event.target, IAnimatable));
		if (_loc3_ != 0) {
			_loc2_ = ASCompat.reinterpretAs(event.target, Tween);
			if (_loc2_ != null && _loc2_.isComplete) {
				addWithID(_loc2_.nextTween, _loc3_);
			}
		}
	}

	@:isVar public var elapsedTime(get, never):Float;

	public function get_elapsedTime():Float {
		return _elapsedTime;
	}

	@:isVar public var timeScale(get, set):Float;

	public function get_timeScale():Float {
		return _timeScale;
	}

	function set_timeScale(value:Float):Float {
		return _timeScale = value;
	}

	@:isVar var objects(get, never):Vector<IAnimatable>;

	function get_objects():Vector<IAnimatable> {
		return _objects;
	}
}
