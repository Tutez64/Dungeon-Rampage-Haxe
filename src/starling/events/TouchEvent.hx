package starling.events;

import starling.display.DisplayObject;

/*use*/ /*namespace*/ /*starling_internal*/ class TouchEvent extends Event {
	public static inline final TOUCH = "touch";

	static var sTouches:Vector<Touch> = new Vector((0 : UInt));

	var _shiftKey:Bool = false;

	var _ctrlKey:Bool = false;

	var _timestamp:Float = Math.NaN;

	var _visitedObjects:Vector<EventDispatcher>;

	public function new(type:String, touches:Vector<Touch> = null, shiftKey:Bool = false, ctrlKey:Bool = false, bubbles:Bool = true) {
		super(type, bubbles, touches);
		_shiftKey = shiftKey;
		_ctrlKey = ctrlKey;
		_visitedObjects = new Vector<EventDispatcher>((0 : UInt));
		updateTimestamp(touches);
	}

	@:allow(starling.events) function resetTo(type:String, touches:Vector<Touch> = null, shiftKey:Bool = false, ctrlKey:Bool = false,
			bubbles:Bool = true):TouchEvent {
		super /*starling_internal::*/ .reset(type, bubbles, touches);
		_shiftKey = shiftKey;
		_ctrlKey = ctrlKey;
		_visitedObjects.length = 0;
		updateTimestamp(touches);
		return this;
	}

	function updateTimestamp(touches:Vector<Touch>) {
		var _loc2_ = 0;
		_timestamp = -1;
		var _loc3_ = touches != null ? touches.length : 0;
		_loc2_ = 0;
		while (_loc2_ < _loc3_) {
			if (touches[_loc2_].timestamp > _timestamp) {
				_timestamp = touches[_loc2_].timestamp;
			}
			_loc2_++;
		}
	}

	public function getTouches(target:DisplayObject, phase:String = null, out:Vector<Touch> = null):Vector<Touch> {
		var _loc6_ = 0;
		var _loc7_:Touch = null;
		var _loc4_ = false;
		var _loc5_ = false;
		if (out == null) {
			out = new Vector<Touch>((0 : UInt));
		}
		var _loc8_ = ASCompat.asVector(data, (_ : Touch));
		var _loc9_ = _loc8_.length;
		_loc6_ = 0;
		while (_loc6_ < _loc9_) {
			_loc7_ = _loc8_[_loc6_];
			_loc4_ = _loc7_.isTouching(target);
			_loc5_ = phase == null || phase == _loc7_.phase;
			if (_loc4_ && _loc5_) {
				out[out.length] = _loc7_;
			}
			_loc6_++;
		}
		return out;
	}

	public function getTouch(target:DisplayObject, phase:String = null, id:Int = -1):Touch {
		var _loc4_:Touch = null;
		var _loc5_ = 0;
		getTouches(target, phase, sTouches);
		var _loc6_ = sTouches.length;
		if (_loc6_ > 0) {
			_loc4_ = null;
			if (id < 0) {
				_loc4_ = sTouches[0];
			} else {
				_loc5_ = 0;
				while (_loc5_ < _loc6_) {
					if (sTouches[_loc5_].id == id) {
						_loc4_ = sTouches[_loc5_];
						break;
					}
					_loc5_++;
				}
			}
			sTouches.length = 0;
			return _loc4_;
		}
		return null;
	}

	public function interactsWith(target:DisplayObject):Bool {
		var _loc3_ = 0;
		var _loc2_ = false;
		getTouches(target, null, sTouches);
		_loc3_ = sTouches.length - 1;
		while (_loc3_ >= 0) {
			if (sTouches[_loc3_].phase != "ended") {
				_loc2_ = true;
				break;
			}
			_loc3_--;
		}
		sTouches.length = 0;
		return _loc2_;
	}

	@:allow(starling.events) function dispatch(chain:Vector<EventDispatcher>) {
		var _loc2_ = 0;
		var _loc6_:EventDispatcher = null;
		var _loc4_ = 0;
		var _loc3_:EventDispatcher = null;
		var _loc5_ = false;
		if (chain != null && chain.length != 0) {
			_loc2_ = bubbles ? chain.length : 1;
			_loc6_ = target;
			setTarget(chain[0]);
			_loc4_ = 0;
			while (_loc4_ < _loc2_) {
				_loc3_ = chain[_loc4_];
				if (_visitedObjects.indexOf(_loc3_) == -1) {
					_loc5_ = _loc3_.invokeEvent(this);
					_visitedObjects[_visitedObjects.length] = _loc3_;
					if (_loc5_) {
						break;
					}
				}
				_loc4_++;
			}
			setTarget(_loc6_);
		}
	}

	@:isVar public var timestamp(get, never):Float;

	public function get_timestamp():Float {
		return _timestamp;
	}

	@:isVar public var touches(get, never):Vector<Touch>;

	public function get_touches():Vector<Touch> {
		return ASCompat.asVector(data, (_ : Touch)).concat();
	}

	@:isVar public var shiftKey(get, never):Bool;

	public function get_shiftKey():Bool {
		return _shiftKey;
	}

	@:isVar public var ctrlKey(get, never):Bool;

	public function get_ctrlKey():Bool {
		return _ctrlKey;
	}
}
