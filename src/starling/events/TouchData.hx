package starling.events;

class TouchData {
	static var sPool:Vector<TouchData> = new Vector((0 : UInt));

	var _id:Int = 0;

	var _phase:String;

	var _globalX:Float = Math.NaN;

	var _globalY:Float = Math.NaN;

	var _pressure:Float = Math.NaN;

	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	public function new() {}

	public static function fromPool(touchID:Int, phase:String, globalX:Float, globalY:Float, pressure:Float = 1, width:Float = 1, height:Float = 1):TouchData {
		var _loc8_ = sPool.length > 0 ? sPool.pop() : new TouchData();
		_loc8_.setTo(touchID, phase, globalX, globalY, pressure, width, height);
		return _loc8_;
	}

	public static function toPool(rawTouch:TouchData) {
		sPool[sPool.length] = rawTouch;
	}

	function setTo(touchID:Int, phase:String, globalX:Float, globalY:Float, pressure:Float = 1, width:Float = 1, height:Float = 1) {
		_id = touchID;
		_phase = phase;
		_globalX = globalX;
		_globalY = globalY;
		_pressure = pressure;
		_width = width;
		_height = height;
	}

	@:isVar public var id(get, never):Int;

	public function get_id():Int {
		return _id;
	}

	@:isVar public var phase(get, never):String;

	public function get_phase():String {
		return _phase;
	}

	@:isVar public var globalX(get, never):Float;

	public function get_globalX():Float {
		return _globalX;
	}

	@:isVar public var globalY(get, never):Float;

	public function get_globalY():Float {
		return _globalY;
	}

	@:isVar public var pressure(get, never):Float;

	public function get_pressure():Float {
		return _pressure;
	}

	@:isVar public var width(get, never):Float;

	public function get_width():Float {
		return _width;
	}

	@:isVar public var height(get, never):Float;

	public function get_height():Float {
		return _height;
	}
}
