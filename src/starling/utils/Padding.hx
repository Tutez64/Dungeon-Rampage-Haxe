package starling.utils;

import starling.events.EventDispatcher;

class Padding extends EventDispatcher {
	var _left:Float = Math.NaN;

	var _right:Float = Math.NaN;

	var _top:Float = Math.NaN;

	var _bottom:Float = Math.NaN;

	public function new(left:Float = 0, right:Float = 0, top:Float = 0, bottom:Float = 0) {
		super();
		setTo(left, right, top, bottom);
	}

	public function setTo(left:Float = 0, right:Float = 0, top:Float = 0, bottom:Float = 0) {
		var _loc5_ = _left != left || _right != right || _top != top || _bottom != bottom;
		_left = left;
		_right = right;
		_top = top;
		_bottom = bottom;
		if (_loc5_) {
			dispatchEventWith("change");
		}
	}

	public function setToUniform(value:Float) {
		setTo(value, value, value, value);
	}

	public function setToSymmetric(horizontal:Float, vertical:Float) {
		setTo(horizontal, horizontal, vertical, vertical);
	}

	public function copyFrom(padding:Padding) {
		if (padding == null) {
			setTo(0, 0, 0, 0);
		} else {
			setTo(padding._left, padding._right, padding._top, padding._bottom);
		}
	}

	public function clone():Padding {
		return new Padding(_left, _right, _top, _bottom);
	}

	@:isVar public var left(get, set):Float;

	public function get_left():Float {
		return _left;
	}

	function set_left(value:Float):Float {
		if (_left != value) {
			_left = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var right(get, set):Float;

	public function get_right():Float {
		return _right;
	}

	function set_right(value:Float):Float {
		if (_right != value) {
			_right = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var top(get, set):Float;

	public function get_top():Float {
		return _top;
	}

	function set_top(value:Float):Float {
		if (_top != value) {
			_top = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var bottom(get, set):Float;

	public function get_bottom():Float {
		return _bottom;
	}

	function set_bottom(value:Float):Float {
		if (_bottom != value) {
			_bottom = value;
			dispatchEventWith("change");
		}
		return value;
	}

	@:isVar public var horizontal(get, never):Float;

	public function get_horizontal():Float {
		return _left + _right;
	}

	@:isVar public var vertical(get, never):Float;

	public function get_vertical():Float {
		return _top + _bottom;
	}
}
