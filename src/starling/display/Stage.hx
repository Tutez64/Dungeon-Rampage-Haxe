package starling.display;

import flash.errors.IllegalOperationError;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.core.Starling;
import starling.events.EnterFrameEvent;
import starling.filters.FragmentFilter;
import starling.utils.MatrixUtil;
import starling.utils.RectangleUtil;

/*use*/ /*namespace*/ /*starling_internal*/ class Stage extends DisplayObjectContainer {
	static var sMatrix:Matrix = new Matrix();

	static var sMatrix3D:Matrix3D = new Matrix3D();

	var _width:Int = 0;

	var _height:Int = 0;

	var _color:UInt = 0;

	var _fieldOfView:Float = Math.NaN;

	var _projectionOffset:Point;

	var _cameraPosition:Vector3D;

	var _enterFrameEvent:EnterFrameEvent;

	var _enterFrameListeners:Vector<DisplayObject>;

	public function new(width:Int, height:Int, color:UInt = (0 : UInt)) {
		super();
		_width = width;
		_height = height;
		_color = color;
		_fieldOfView = 1;
		_projectionOffset = new Point();
		_cameraPosition = new Vector3D();
		_enterFrameEvent = new EnterFrameEvent("enterFrame", 0);
		_enterFrameListeners = new Vector<DisplayObject>((0 : UInt));
	}

	public function advanceTime(passedTime:Float) {
		_enterFrameEvent.reset("enterFrame", false, passedTime);
		broadcastEvent(_enterFrameEvent);
	}

	override public function hitTest(localPoint:Point):DisplayObject {
		if (!visible || !touchable) {
			return null;
		}
		if (localPoint.x < 0 || localPoint.x > _width || localPoint.y < 0 || localPoint.y > _height) {
			return null;
		}
		var _loc2_ = super.hitTest(localPoint);
		return ASCompat.coerce(_loc2_ != null ? _loc2_ : this, DisplayObject);
	}

	public function getStageBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		if (out == null) {
			out = new Rectangle();
		}
		out.setTo(0, 0, _width, _height);
		getTransformationMatrix(targetSpace, sMatrix);
		return RectangleUtil.getBounds(out, sMatrix, out);
	}

	public function getScreenBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		var _loc9_ = this.starling;
		if (_loc9_ == null) {
			return getStageBounds(targetSpace, out);
		}
		if (out == null) {
			out = new Rectangle();
		}
		var _loc4_:ASObject = _loc9_.nativeStage;
		var _loc6_ = _loc9_.viewPort;
		var _loc3_ = _width / _loc6_.width;
		var _loc5_ = _height / _loc6_.height;
		var _loc7_ = -_loc6_.x * _loc3_;
		var _loc8_ = -_loc6_.y * _loc5_;
		out.setTo(_loc7_, _loc8_, ASCompat.toNumberField(_loc4_, "stageWidth") * _loc3_, ASCompat.toNumberField(_loc4_, "stageHeight") * _loc5_);
		getTransformationMatrix(targetSpace, sMatrix);
		return RectangleUtil.getBounds(out, sMatrix, out);
	}

	public function getCameraPosition(space:DisplayObject = null, out:Vector3D = null):Vector3D {
		getTransformationMatrix3D(space, sMatrix3D);
		return MatrixUtil.transformCoords3D(sMatrix3D, _width / 2 + _projectionOffset.x, _height / 2 + _projectionOffset.y, -focalLength, out);
	}

	@:allow(starling.display) function addEnterFrameListener(listener:DisplayObject) {
		var _loc2_ = _enterFrameListeners.indexOf(listener);
		if (_loc2_ < 0) {
			_enterFrameListeners[_enterFrameListeners.length] = listener;
		}
	}

	@:allow(starling.display) function removeEnterFrameListener(listener:DisplayObject) {
		var _loc2_ = _enterFrameListeners.indexOf(listener);
		if (_loc2_ >= 0) {
			_enterFrameListeners.removeAt(_loc2_);
		}
	}

	@:allow(starling.display)
	override function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector<DisplayObject>) {
		var _loc5_ = 0;
		var _loc4_ = 0;
		if (eventType == "enterFrame" && object == this) {
			_loc5_ = 0;
			_loc4_ = _enterFrameListeners.length;
			while (_loc5_ < _loc4_) {
				listeners[listeners.length] = _enterFrameListeners[_loc5_];
				_loc5_++;
			}
		} else {
			super.getChildEventListeners(object, eventType, listeners);
		}
	}

	override public function set_width(value:Float):Float {
		throw new IllegalOperationError("Cannot set width of stage");
		return value;
	}

	override public function set_height(value:Float):Float {
		throw new IllegalOperationError("Cannot set height of stage");
		return value;
	}

	override public function set_x(value:Float):Float {
		throw new IllegalOperationError("Cannot set x-coordinate of stage");
		return value;
	}

	override public function set_y(value:Float):Float {
		throw new IllegalOperationError("Cannot set y-coordinate of stage");
		return value;
	}

	override public function set_scaleX(value:Float):Float {
		throw new IllegalOperationError("Cannot scale stage");
		return value;
	}

	override public function set_scaleY(value:Float):Float {
		throw new IllegalOperationError("Cannot scale stage");
		return value;
	}

	override public function set_rotation(value:Float):Float {
		throw new IllegalOperationError("Cannot rotate stage");
		return value;
	}

	override public function set_skewX(value:Float):Float {
		throw new IllegalOperationError("Cannot skew stage");
		return value;
	}

	override public function set_skewY(value:Float):Float {
		throw new IllegalOperationError("Cannot skew stage");
		return value;
	}

	override public function set_filter(value:FragmentFilter):FragmentFilter {
		throw new IllegalOperationError("Cannot add filter to stage. Add it to \'root\' instead!");
		return value;
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		return _color;
	}

	function set_color(value:UInt):UInt {
		if (_color != value) {
			_color = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var stageWidth(get, set):Int;

	public function get_stageWidth():Int {
		return _width;
	}

	function set_stageWidth(value:Int):Int {
		if (_width != value) {
			_width = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var stageHeight(get, set):Int;

	public function get_stageHeight():Int {
		return _height;
	}

	function set_stageHeight(value:Int):Int {
		if (_height != value) {
			_height = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var starling(get, never):Starling;

	public function get_starling():Starling {
		var _loc3_ = 0;
		var _loc1_ = Starling.all;
		var _loc2_ = _loc1_.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			if (_loc1_[_loc3_].stage == this) {
				return _loc1_[_loc3_];
			}
			_loc3_++;
		}
		return null;
	}

	@:isVar public var focalLength(get, set):Float;

	public function get_focalLength():Float {
		return _width / (2 * Math.tan(_fieldOfView / 2));
	}

	function set_focalLength(value:Float):Float {
		_fieldOfView = 2 * Math.atan(stageWidth / (2 * value));
		setRequiresRedraw();
		return value;
	}

	@:isVar public var fieldOfView(get, set):Float;

	public function get_fieldOfView():Float {
		return _fieldOfView;
	}

	function set_fieldOfView(value:Float):Float {
		_fieldOfView = value;
		setRequiresRedraw();
		return value;
	}

	@:isVar public var projectionOffset(get, set):Point;

	public function get_projectionOffset():Point {
		return _projectionOffset;
	}

	function set_projectionOffset(value:Point):Point {
		_projectionOffset.setTo(value.x, value.y);
		setRequiresRedraw();
		return value;
	}

	@:isVar public var cameraPosition(get, never):Vector3D;

	public function get_cameraPosition():Vector3D {
		return getCameraPosition(null, _cameraPosition);
	}
}
