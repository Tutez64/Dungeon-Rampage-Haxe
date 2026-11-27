package starling.events;

import starling.display.DisplayObject;

/*use*/ /*namespace*/ /*starling_internal*/ class EventDispatcher {
	static var sBubbleChains:Array<ASAny>;

	var _eventListeners:ASDictionary<ASAny, ASAny>;

	var _eventStack:Vector<String> = new Vector((0 : UInt));

	public function new() {}

	public function addEventListener(type:String, listener:ASFunction) {
		if (_eventListeners == null) {
			_eventListeners = new ASDictionary<ASAny, ASAny>();
		}
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(ASDictionary.getString(_eventListeners, type), Array);
		if (_loc3_ == null) {
			_eventListeners[type] = [listener];
		} else if (_loc3_.indexOf(listener) == -1) {
			_loc3_[_loc3_.length] = listener;
		}
	}

	public function removeEventListener(type:String, listener:ASFunction) {
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc7_:Array<ASAny> = null;
		var _loc6_ = 0;
		if (_eventListeners != null) {
			_loc3_ = ASCompat.dynamicAs(ASDictionary.getString(_eventListeners, type), Array);
			_loc4_ = _loc3_ != null ? _loc3_.length : 0;
			if (_loc4_ > 0) {
				_loc5_ = _loc3_.indexOf(listener);
				if (_loc5_ != -1) {
					if (_eventStack.indexOf(type) == -1) {
						_loc3_.splice(_loc5_, 1);
					} else {
						_loc7_ = _loc3_.slice(0, _loc5_);
						_loc6_ = _loc5_ + 1;
						while (_loc6_ < _loc4_) {
							_loc7_[_loc6_ - 1] = _loc3_[_loc6_];
							_loc6_++;
						}
						_eventListeners[type] = _loc7_;
					}
				}
			}
		}
	}

	public function removeEventListeners(type:String = null) {
		if (ASCompat.stringAsBool(type) && _eventListeners != null) {
			_eventListeners.remove(type);
		} else {
			_eventListeners = null;
		}
	}

	public function dispatchEvent(event:Event) {
		var _loc2_ = event.bubbles;
		if (!_loc2_ && (_eventListeners == null || !_eventListeners.exists(event.type))) {
			return;
		}
		var _loc3_ = event.target;
		event.setTarget(this);
		if (_loc2_ && Std.isOfType(this, DisplayObject)) {
			bubbleEvent(event);
		} else {
			invokeEvent(event);
		}
		if (_loc3_ != null) {
			event.setTarget(_loc3_);
		}
	}

	@:allow(starling.events) function invokeEvent(event:Event):Bool {
		var _loc6_ = 0;
		var _loc5_:ASFunction = null;
		var _loc2_ = 0;
		var _loc3_ = _eventListeners != null ? ASCompat.dynamicAs(ASDictionary.getString(_eventListeners, event.type), Array) : null;
		var _loc4_ = ASCompat.toInt(_loc3_?.length);
		if (_loc4_ != 0) {
			event.setCurrentTarget(this);
			_eventStack[_eventStack.length] = event.type;
			_loc6_ = 0;
			while (_loc6_ < _loc4_) {
				_loc5_ = ASCompat.asFunction(_loc3_[_loc6_]);
				_loc2_ = (_loc5_.length : Int);
				if (_loc2_ == 0) {
					_loc5_();
				} else if (_loc2_ == 1) {
					_loc5_(event);
				} else {
					_loc5_(event, event.data);
				}
				if (event.stopsImmediatePropagation) {
					_eventStack.pop();
					return true;
				}
				_loc6_++;
			}
			_eventStack.pop();
			return event.stopsPropagation;
		}
		return false;
	}

	@:allow(starling.events) function bubbleEvent(event:Event) {
		var _loc2_:Vector<EventDispatcher> = /*undefined*/ null;
		var _loc4_ = 0;
		var _loc5_ = false;
		var _loc6_ = ASCompat.reinterpretAs(this, DisplayObject);
		var _loc3_ = 1;
		if (sBubbleChains.length > 0) {
			_loc2_ = (sBubbleChains.pop() : Vector<EventDispatcher>);
			_loc2_[0] = _loc6_;
		} else {
			_loc2_ = Vector.ofArray(([_loc6_] : Array<EventDispatcher>));
		}
		while (true) {
			_loc6_ = _loc6_.parent;
			if (_loc6_ == null) {
				break;
			}
			_loc2_[_loc3_++] = _loc6_;
		}
		_loc4_ = 0;
		while (_loc4_ < _loc3_) {
			_loc5_ = _loc2_[_loc4_].invokeEvent(event);
			if (_loc5_) {
				break;
			}
			_loc4_++;
		}
		_loc2_.length = 0;
		sBubbleChains[sBubbleChains.length] = _loc2_;
	}

	public function dispatchEventWith(type:String, bubbles:Bool = false, data:ASObject = null) {
		var _loc4_:Event = null;
		if (bubbles || hasEventListener(type)) {
			_loc4_ = Event.fromPool(type, bubbles, data);
			dispatchEvent(_loc4_);
			Event.toPool(_loc4_);
		}
	}

	public function hasEventListener(type:String, listener:ASFunction = null):Bool {
		var _loc3_ = _eventListeners != null ? ASCompat.dynamicAs(ASDictionary.getString(_eventListeners, type), Array) : null;
		if (_loc3_ == null) {
			return false;
		}
		if (listener != null) {
			return _loc3_.indexOf(listener) != -1;
		}
		return _loc3_.length != 0;
	}

	static function __init__() {
		sBubbleChains = [];
	}
}
