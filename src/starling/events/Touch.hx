package starling.events;

import flash.geom.Point;
import starling.display.DisplayObject;
import starling.utils.Pool;
import starling.utils.StringUtil;

class Touch {
	static var sHelperPoint:Point = new Point();

	var _id:Int = 0;

	var _globalX:Float = Math.NaN;

	var _globalY:Float = Math.NaN;

	var _previousGlobalX:Float = Math.NaN;

	var _previousGlobalY:Float = Math.NaN;

	var _startGlobalX:Float = Math.NaN;

	var _startGlobalY:Float = Math.NaN;

	var _startTimestamp:Float = Math.NaN;

	var _tapCount:Int = 0;

	var _phase:String;

	var _target:DisplayObject;

	var _timestamp:Float = Math.NaN;

	var _pressure:Float = Math.NaN;

	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	var _cancelled:Bool = false;

	var _bubbleChain:Vector<EventDispatcher>;

	public function new(id:Int) {
		_id = id;
		_tapCount = 0;
		_phase = "hover";
		_pressure = _width = _height = 1;
		_bubbleChain = new Vector<EventDispatcher>((0 : UInt));
		_timestamp = _startTimestamp = -1;
	}

	static function getMovementBetween(startX:Float, startY:Float, endX:Float, endY:Float, space:DisplayObject, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		var _loc7_ = Pool.getPoint(startX, startY);
		var _loc8_ = Pool.getPoint(endX, endY);
		space.globalToLocal(_loc7_, _loc7_);
		space.globalToLocal(_loc8_, _loc8_);
		out.setTo(_loc8_.x - _loc7_.x, _loc8_.y - _loc7_.y);
		Pool.putPoint(_loc7_);
		Pool.putPoint(_loc8_);
		return out;
	}

	public function getLocation(space:DisplayObject, out:Point = null):Point {
		sHelperPoint.setTo(_globalX, _globalY);
		return space.globalToLocal(sHelperPoint, out);
	}

	public function getPreviousLocation(space:DisplayObject, out:Point = null):Point {
		sHelperPoint.setTo(_previousGlobalX, _previousGlobalY);
		return space.globalToLocal(sHelperPoint, out);
	}

	public function getStartLocation(space:DisplayObject, out:Point = null):Point {
		sHelperPoint.setTo(_startGlobalX, _startGlobalY);
		return space.globalToLocal(sHelperPoint, out);
	}

	public function getMovement(space:DisplayObject, out:Point = null):Point {
		return getMovementBetween(_previousGlobalX, _previousGlobalY, _globalX, _globalY, space, out);
	}

	public function getMovementSinceStart(space:DisplayObject, out:Point = null):Point {
		return getMovementBetween(_startGlobalX, _startGlobalY, _globalX, _globalY, space, out);
	}

	public function isTouching(target:DisplayObject):Bool {
		return _bubbleChain.indexOf(target) != -1;
	}

	public function toString():String {
		return StringUtil.format("[Touch {0}: globalX={1}, globalY={2}, phase={3}]", _id, _globalX, _globalY, _phase);
	}

	public function clone():Touch {
		var _loc1_ = new Touch(_id);
		_loc1_._globalX = _globalX;
		_loc1_._globalY = _globalY;
		_loc1_._previousGlobalX = _previousGlobalX;
		_loc1_._previousGlobalY = _previousGlobalY;
		_loc1_._startGlobalX = _startGlobalX;
		_loc1_._startGlobalY = _startGlobalY;
		_loc1_._startTimestamp = _startTimestamp;
		_loc1_._phase = _phase;
		_loc1_._tapCount = _tapCount;
		_loc1_._timestamp = _timestamp;
		_loc1_._pressure = _pressure;
		_loc1_._width = _width;
		_loc1_._height = _height;
		_loc1_._cancelled = _cancelled;
		_loc1_.target = _target;
		return _loc1_;
	}

	function updateBubbleChain() {
		var _loc1_ = 0;
		var _loc2_:DisplayObject = null;
		if (_target != null) {
			_loc1_ = 1;
			_loc2_ = _target;
			_bubbleChain.length = 1;
			_bubbleChain[0] = _loc2_;
			while (true) {
				_loc2_ = _loc2_.parent;
				if (_loc2_ == null) {
					break;
				}
				_bubbleChain[_loc1_++] = _loc2_;
			}
		} else {
			_bubbleChain.length = 0;
		}
	}

	@:isVar public var id(get, never):Int;

	public function get_id():Int {
		return _id;
	}

	@:isVar public var previousGlobalX(get, never):Float;

	public function get_previousGlobalX():Float {
		return _previousGlobalX;
	}

	@:isVar public var previousGlobalY(get, never):Float;

	public function get_previousGlobalY():Float {
		return _previousGlobalY;
	}

	@:isVar public var startGlobalX(get, never):Float;

	public function get_startGlobalX():Float {
		return _startGlobalX;
	}

	@:isVar public var startGlobalY(get, never):Float;

	public function get_startGlobalY():Float {
		return _startGlobalY;
	}

	@:isVar public var globalX(get, set):Float;

	public function get_globalX():Float {
		return _globalX;
	}

	function set_globalX(value:Float):Float {
		if (_globalX != _globalX) {
			_previousGlobalX = _startGlobalX = value;
		} else {
			_previousGlobalX = _globalX;
		}
		return _globalX = value;
	}

	@:isVar public var globalY(get, set):Float;

	public function get_globalY():Float {
		return _globalY;
	}

	function set_globalY(value:Float):Float {
		if (_globalY != _globalY) {
			_previousGlobalY = _startGlobalY = value;
		} else {
			_previousGlobalY = _globalY;
		}
		return _globalY = value;
	}

	@:isVar public var tapCount(get, set):Int;

	public function get_tapCount():Int {
		return _tapCount;
	}

	function set_tapCount(value:Int):Int {
		return _tapCount = value;
	}

	@:isVar public var phase(get, set):String;

	public function get_phase():String {
		return _phase;
	}

	function set_phase(value:String):String {
		_phase = value;
		if (value == "began") {
			_startGlobalX = _globalX;
			_startGlobalY = _globalY;
			_startTimestamp = _timestamp;
		}
		return value;
	}

	@:isVar public var target(get, set):DisplayObject;

	public function get_target():DisplayObject {
		return _target;
	}

	function set_target(value:DisplayObject):DisplayObject {
		if (_target != value) {
			_target = value;
			updateBubbleChain();
		}
		return value;
	}

	@:isVar public var timestamp(get, set):Float;

	public function get_timestamp():Float {
		return _timestamp;
	}

	function set_timestamp(value:Float):Float {
		if (_startTimestamp < 0) {
			_startTimestamp = value;
		}
		return _timestamp = value;
	}

	@:isVar public var pressure(get, set):Float;

	public function get_pressure():Float {
		return _pressure;
	}

	function set_pressure(value:Float):Float {
		return _pressure = value;
	}

	@:isVar public var width(get, set):Float;

	public function get_width():Float {
		return _width;
	}

	function set_width(value:Float):Float {
		return _width = value;
	}

	@:isVar public var height(get, set):Float;

	public function get_height():Float {
		return _height;
	}

	function set_height(value:Float):Float {
		return _height = value;
	}

	@:isVar public var cancelled(get, set):Bool;

	public function get_cancelled():Bool {
		return _cancelled;
	}

	function set_cancelled(value:Bool):Bool {
		return _cancelled = value;
	}

	@:isVar public var duration(get, never):Float;

	public function get_duration():Float {
		if (_timestamp < 0 || _startTimestamp < 0 || _startTimestamp > _timestamp) {
			return -1;
		}
		return _timestamp - _startTimestamp;
	}

	@:allow(starling.events) function update(timestamp:Float, phase:String, globalX:Float, globalY:Float, pressure:Float = 1, width:Float = 1,
			height:Float = 1) {
		_pressure = pressure;
		_width = width;
		_height = height;
		this.timestamp = timestamp;
		this.globalX = globalX;
		this.globalY = globalY;
		this.phase = phase;
	}

	@:allow(starling.events) function dispatchEvent(event:TouchEvent) {
		if (_target != null) {
			event.dispatch(_bubbleChain);
		}
	}

	@:allow(starling.events) @:isVar var bubbleChain(get, never):Vector<EventDispatcher>;

	function get_bubbleChain():Vector<EventDispatcher> {
		return _bubbleChain.concat();
	}
}
