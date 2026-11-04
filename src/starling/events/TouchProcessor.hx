package starling.events;

import flash.geom.Point;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.utils.Pool;

class TouchProcessor {
	static inline final TOP = 0;

	static inline final BOTTOM = 1;

	static inline final LEFT = 2;

	static inline final RIGHT = 3;

	static var sUpdatedTouches:Vector<Touch> = new Vector((0 : UInt));

	static var sHoveringTouchData:Array<Dynamic> = ASCompat.allocArray((0 : UInt));

	static var sHelperPoint:Point = new Point();

	var _stage:Stage;

	var _root:DisplayObject;

	var _elapsedTime:Float = Math.NaN;

	var _lastTaps:Vector<Touch>;

	var _shiftDown:Bool = false;

	var _ctrlDown:Bool = false;

	var _multitapTime:Float = 0.3;

	var _multitapDistance:Float = 25;

	var _touchEvent:TouchEvent;

	var _isProcessing:Bool = false;

	var _cancelRequested:Bool = false;

	var _touchMarker:TouchMarker;

	var _simulateMultitouch:Bool = false;

	var _occlusionTest:ASFunction;

	var _discardSystemGestures:Bool = false;

	var _systemGestureTouchID:Int = -1;

	var _systemGestureMargins:Array<ASAny> = [15, 15, 15, 0];

	var _queue:Vector<TouchData>;

	var _currentTouches:Vector<Touch>;

	public function new(stage:Stage) {
		_root = _stage = stage;
		_elapsedTime = 0;
		_currentTouches = new Vector<Touch>((0 : UInt));
		_queue = new Vector<TouchData>((0 : UInt));
		_lastTaps = new Vector<Touch>((0 : UInt));
		_touchEvent = new TouchEvent("touch");
		_stage.addEventListener("keyDown", onKey);
		_stage.addEventListener("keyUp", onKey);
		monitorInterruptions(true);
	}

	public function dispose() {
		monitorInterruptions(false);
		_stage.removeEventListener("keyDown", onKey);
		_stage.removeEventListener("keyUp", onKey);
		if (_touchMarker != null) {
			_touchMarker.dispose();
		}
	}

	public function advanceTime(passedTime:Float) {
		var __ax4_iter_150:Vector<Touch>;
		var _loc3_ = 0;
		var _loc4_:Touch = null;
		var _loc5_:TouchData = null;
		if (_isProcessing) {
			return;
		}
		_isProcessing = true;
		var _loc2_ = 0;
		_elapsedTime += passedTime;
		sUpdatedTouches.length = 0;
		if (_lastTaps.length > 0) {
			_loc3_ = _lastTaps.length - 1;
			while (_loc3_ >= 0) {
				if (_elapsedTime - _lastTaps[_loc3_].timestamp > _multitapTime) {
					_lastTaps.removeAt(_loc3_);
				}
				_loc3_--;
			}
		}
		while (_queue.length > 0 || _loc2_ == 0) {
			_loc2_++;
			__ax4_iter_150 = _currentTouches;
			if (checkNullIteratee(__ax4_iter_150))
				for (_tmp_ in __ax4_iter_150) {
					_loc4_ = _tmp_;
					if (_loc4_.phase == "began" || _loc4_.phase == "moved") {
						_loc4_.phase = "stationary";
					}
				}
			while (_queue.length > 0 && !containsTouchWithID(sUpdatedTouches, _queue[_queue.length - 1].id)) {
				_loc5_ = _queue.pop();
				_loc4_ = createOrUpdateTouch(_loc5_);
				sUpdatedTouches[sUpdatedTouches.length] = _loc4_;
				TouchData.toPool(_loc5_);
			}
			_loc3_ = _currentTouches.length - 1;
			while (_loc3_ >= 0) {
				_loc4_ = _currentTouches[_loc3_];
				if (_loc4_.phase == "hover" && !containsTouchWithID(sUpdatedTouches, _loc4_.id)) {
					sHelperPoint.setTo(_loc4_.globalX, _loc4_.globalY);
					if (_loc4_.target != _root.hitTest(sHelperPoint)) {
						sUpdatedTouches[sUpdatedTouches.length] = _loc4_;
					}
				}
				_loc3_--;
			}
			if (sUpdatedTouches.length != 0) {
				processTouches(sUpdatedTouches, _shiftDown, _ctrlDown);
			}
			_loc3_ = _currentTouches.length - 1;
			while (_loc3_ >= 0) {
				if (_currentTouches[_loc3_].phase == "ended") {
					_currentTouches.removeAt(_loc3_);
				}
				_loc3_--;
			}
			sUpdatedTouches.length = 0;
		}
		_isProcessing = false;
		if (_cancelRequested) {
			cancelTouches();
		}
	}

	function processTouches(touches:Vector<Touch>, shiftDown:Bool, ctrlDown:Bool) {
		var _loc4_:Touch = null;
		sHoveringTouchData.resize(0);
		_touchEvent.resetTo("touch", _currentTouches, shiftDown, ctrlDown);
		if (checkNullIteratee(touches))
			for (_tmp_ in touches) {
				_loc4_ = _tmp_;
				if (_loc4_.phase == "hover" && _loc4_.target != null) {
					sHoveringTouchData[sHoveringTouchData.length] = {
						"touch": _loc4_,
						"target": _loc4_.target,
						"bubbleChain": _loc4_.bubbleChain
					};
				}
				if (_loc4_.phase == "hover" || _loc4_.phase == "began") {
					sHelperPoint.setTo(_loc4_.globalX, _loc4_.globalY);
					if (_occlusionTest != null && ASCompat.toBool(_occlusionTest(_loc4_.globalX, _loc4_.globalY))) {
						_loc4_.target = null;
					} else {
						_loc4_.target = _root.hitTest(sHelperPoint);
					}
				}
			}
		var _loc5_:ASObject;
		final __ax4_iter_151 = sHoveringTouchData;
		if (checkNullIteratee(__ax4_iter_151))
			for (_tmp_ in __ax4_iter_151) {
				_loc5_ = _tmp_;
				if (_loc5_.touch.target != _loc5_.target) {
					_touchEvent.dispatch((_loc5_.bubbleChain : Vector<EventDispatcher>));
				}
			}
		if (checkNullIteratee(touches))
			for (_tmp_ in touches) {
				_loc4_ = _tmp_;
				_loc4_.dispatchEvent(_touchEvent);
			}
		_touchEvent.resetTo("touch");
	}

	function checkForSystemGesture(touchID:Int, phase:String, globalX:Float, globalY:Float):Bool {
		var _loc5_ = false;
		var _loc6_:Rectangle = null;
		if (!_discardSystemGestures || phase == "hover") {
			return false;
		}
		if (_systemGestureTouchID == touchID) {
			if (phase == "ended") {
				_systemGestureTouchID = -1;
			}
			return true;
		}
		if (_systemGestureTouchID >= 0) {
			return false;
		}
		if (phase == "began") {
			_loc6_ = _stage.getScreenBounds(_stage, Pool.getRectangle());
			_loc5_ = globalX < ASCompat.toNumber(_loc6_.left + _systemGestureMargins[2])
				|| globalX > _loc6_.right - ASCompat.toNumber(_systemGestureMargins[3])
				|| globalY < ASCompat.toNumber(_loc6_.top + _systemGestureMargins[0])
				|| globalY > _loc6_.bottom - ASCompat.toNumber(_systemGestureMargins[1]);
			Pool.putRectangle(_loc6_);
			if (_loc5_) {
				_systemGestureTouchID = touchID;
			}
			return _loc5_;
		}
		return false;
	}

	public function enqueue(touchID:Int, phase:String, globalX:Float, globalY:Float, pressure:Float = 1, width:Float = 1, height:Float = 1) {
		if (checkForSystemGesture(touchID, phase, globalX, globalY)) {
			return;
		}
		queue_unshift(touchID, phase, globalX, globalY, pressure, width, height);
		if (_ctrlDown && _touchMarker != null && touchID == 0) {
			_touchMarker.moveMarker(globalX, globalY, _shiftDown);
			queue_unshift(1, phase, _touchMarker.mockX, _touchMarker.mockY);
		}
	}

	function queue_unshift(touchID:Int, phase:String, globalX:Float, globalY:Float, pressure:Float = 1, width:Float = 1, height:Float = 1) {
		_queue.unshift(TouchData.fromPool(touchID, phase, globalX, globalY, pressure, width, height));
	}

	public function enqueueMouseLeftStage() {
		var _loc1_ = getCurrentTouch(0);
		if (_loc1_ == null || _loc1_.phase != "hover") {
			return;
		}
		var _loc2_ = 1;
		var _loc8_ = _loc1_.globalX;
		var _loc6_ = _loc1_.globalY;
		var _loc4_ = _loc1_.globalX;
		var _loc7_ = _stage.stageWidth - _loc4_;
		var _loc3_ = _loc1_.globalY;
		var _loc9_ = _stage.stageHeight - _loc3_;
		var _loc5_ = Math.min(_loc4_, Math.min(Math.min(_loc7_, _loc3_), _loc9_));
		if (_loc5_ == _loc4_) {
			_loc8_ = -_loc2_;
		} else if (_loc5_ == _loc7_) {
			_loc8_ = _stage.stageWidth + _loc2_;
		} else if (_loc5_ == _loc3_) {
			_loc6_ = -_loc2_;
		} else {
			_loc6_ = _stage.stageHeight + _loc2_;
		}
		enqueue(0, "hover", _loc8_, _loc6_);
	}

	public function cancelTouches() {
		var _loc1_:Touch;
		var __ax4_iter_152:Vector<Touch>;
		if (_isProcessing) {
			_cancelRequested = true;
			return;
		}
		_cancelRequested = false;
		if (_currentTouches.length > 0) {
			__ax4_iter_152 = _currentTouches;
			if (checkNullIteratee(__ax4_iter_152))
				for (_tmp_ in __ax4_iter_152) {
					_loc1_ = _tmp_;
					if (_loc1_.phase == "began" || _loc1_.phase == "moved" || _loc1_.phase == "stationary") {
						_loc1_.phase = "ended";
						_loc1_.cancelled = true;
					}
				}
			processTouches(_currentTouches, _shiftDown, _ctrlDown);
		}
		_currentTouches.length = 0;
		_systemGestureTouchID = -1;
		while (_queue.length != 0) {
			TouchData.toPool(_queue.pop());
		}
	}

	function createOrUpdateTouch(touchData:TouchData):Touch {
		var _loc2_ = getCurrentTouch(touchData.id);
		if (_loc2_ == null) {
			_loc2_ = new Touch(touchData.id);
			addCurrentTouch(_loc2_);
		}
		_loc2_.update(_elapsedTime, touchData.phase, touchData.globalX, touchData.globalY, touchData.pressure, touchData.width, touchData.height);
		if (touchData.phase == "began") {
			updateTapCount(_loc2_);
		}
		return _loc2_;
	}

	function updateTapCount(touch:Touch) {
		var _loc4_ = Math.NaN;
		var _loc5_:Touch = null;
		var _loc2_ = _multitapDistance * _multitapDistance;
		var _loc3_:Touch;
		final __ax4_iter_153 = _lastTaps;
		if (checkNullIteratee(__ax4_iter_153))
			for (_tmp_ in __ax4_iter_153) {
				_loc3_ = _tmp_;
				_loc4_ = Math.pow(_loc3_.globalX - touch.globalX, 2) + Math.pow(_loc3_.globalY - touch.globalY, 2);
				if (_loc4_ <= _loc2_) {
					_loc5_ = _loc3_;
					break;
				}
			}
		if (_loc5_ != null) {
			touch.tapCount = _loc5_.tapCount + 1;
			_lastTaps.removeAt(_lastTaps.indexOf(_loc5_));
		} else {
			touch.tapCount = 1;
		}
		_lastTaps[_lastTaps.length] = touch.clone();
	}

	function addCurrentTouch(touch:Touch) {
		var _loc2_ = 0;
		_loc2_ = _currentTouches.length - 1;
		while (_loc2_ >= 0) {
			if (_currentTouches[_loc2_].id == touch.id) {
				_currentTouches.removeAt(_loc2_);
			}
			_loc2_--;
		}
		_currentTouches[_currentTouches.length] = touch;
	}

	function getCurrentTouch(touchID:Int):Touch {
		var _loc2_:Touch;
		final __ax4_iter_154 = _currentTouches;
		if (checkNullIteratee(__ax4_iter_154))
			for (_tmp_ in __ax4_iter_154) {
				_loc2_ = _tmp_;
				if (_loc2_.id == touchID) {
					return _loc2_;
				}
			}
		return null;
	}

	function containsTouchWithID(touches:Vector<Touch>, touchID:Int):Bool {
		var _loc3_:Touch;
		if (checkNullIteratee(touches))
			for (_tmp_ in touches) {
				_loc3_ = _tmp_;
				if (_loc3_.id == touchID) {
					return true;
				}
			}
		return false;
	}

	public function setSystemGestureMargins(topMargin:Float = 10, bottomMargin:Float = 10, leftMargin:Float = 0, rightMargin:Float = 0) {
		_systemGestureMargins[0] = topMargin;
		_systemGestureMargins[1] = bottomMargin;
		_systemGestureMargins[2] = leftMargin;
		_systemGestureMargins[3] = rightMargin;
	}

	@:isVar public var simulateMultitouch(get, set):Bool;

	public function get_simulateMultitouch():Bool {
		return _simulateMultitouch;
	}

	function set_simulateMultitouch(value:Bool):Bool {
		var createTouchMarker:() -> Void = null;
		var target:Starling = null;
		createTouchMarker = function() {
			target.removeEventListener("context3DCreate", (cast createTouchMarker));
			if (_touchMarker == null) {
				_touchMarker = new TouchMarker();
				_touchMarker.visible = false;
				_stage.addChild(_touchMarker);
			}
		};
		if (simulateMultitouch == value) {
			return value;
		}
		_simulateMultitouch = value;
		target = Starling.current;
		if (value && _touchMarker == null) {
			if (Starling.current.contextValid) {
				createTouchMarker();
			} else {
				target.addEventListener("context3DCreate", (cast createTouchMarker));
			}
		} else if (!value && _touchMarker != null) {
			_touchMarker.removeFromParent(true);
			_touchMarker = null;
		}
		return value;
	}

	@:isVar public var multitapTime(get, set):Float;

	public function get_multitapTime():Float {
		return _multitapTime;
	}

	function set_multitapTime(value:Float):Float {
		return _multitapTime = value;
	}

	@:isVar public var multitapDistance(get, set):Float;

	public function get_multitapDistance():Float {
		return _multitapDistance;
	}

	function set_multitapDistance(value:Float):Float {
		return _multitapDistance = value;
	}

	@:isVar public var root(get, set):DisplayObject;

	public function get_root():DisplayObject {
		return _root;
	}

	function set_root(value:DisplayObject):DisplayObject {
		return _root = value;
	}

	@:isVar public var stage(get, never):Stage;

	public function get_stage():Stage {
		return _stage;
	}

	@:isVar public var numCurrentTouches(get, never):Int;

	public function get_numCurrentTouches():Int {
		return _currentTouches.length;
	}

	@:isVar public var occlusionTest(get, set):ASFunction;

	public function set_occlusionTest(value:ASFunction):ASFunction {
		return _occlusionTest = value;
	}

	function get_occlusionTest():ASFunction {
		return _occlusionTest;
	}

	@:isVar public var discardSystemGestures(get, set):Bool;

	public function get_discardSystemGestures():Bool {
		return _discardSystemGestures;
	}

	function set_discardSystemGestures(value:Bool):Bool {
		if (_discardSystemGestures != value) {
			_discardSystemGestures = value;
			_systemGestureTouchID = -1;
		}
		return value;
	}

	function onKey(event:KeyboardEvent) {
		var _loc2_ = false;
		var _loc4_:Touch = null;
		var _loc3_:Touch = null;
		if (event.keyCode == 17 || event.keyCode == 15) {
			_loc2_ = _ctrlDown;
			_ctrlDown = event.type == "keyDown";
			if (_touchMarker != null && _loc2_ != _ctrlDown) {
				_touchMarker.visible = _ctrlDown;
				_touchMarker.moveCenter(_stage.stageWidth / 2, _stage.stageHeight / 2);
				_loc4_ = getCurrentTouch(0);
				_loc3_ = getCurrentTouch(1);
				if (_loc4_ != null) {
					_touchMarker.moveMarker(_loc4_.globalX, _loc4_.globalY);
				}
				if (_loc2_ && _loc3_ != null && _loc3_.phase != "ended") {
					queue_unshift(1, "ended", _loc3_.globalX, _loc3_.globalY);
				} else if (_ctrlDown && _loc4_ != null) {
					if (_loc4_.phase == "hover" || _loc4_.phase == "ended") {
						queue_unshift(1, "hover", _touchMarker.mockX, _touchMarker.mockY);
					} else {
						queue_unshift(1, "began", _touchMarker.mockX, _touchMarker.mockY);
					}
				}
			}
		} else if (event.keyCode == 16) {
			_shiftDown = event.type == "keyDown";
		}
	}

	function monitorInterruptions(enable:Bool) {
		var _loc3_:ASObject = null;
		var _loc2_:ASObject = null;
		try {
			_loc3_ = ASCompat.getDefinitionByName("flash.desktop::NativeApplication");
			_loc2_ = _loc3_["nativeApplication"];
			if (enable) {
				_loc2_.addEventListener("deactivate", onInterruption, false, 0, true);
			} else {
				_loc2_.removeEventListener("deactivate", onInterruption);
			}
		} catch (e:Dynamic) {}
	}

	function onInterruption(event:ASObject) {
		cancelTouches();
	}
}
