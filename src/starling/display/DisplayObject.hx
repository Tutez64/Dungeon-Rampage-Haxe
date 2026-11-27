package starling.display;

import flash.display.BitmapData;
import flash.errors.IllegalOperationError;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.system.Capabilities;
import flash.ui.Mouse;
import starling.core.Starling;
import starling.errors.AbstractClassError;
import starling.errors.AbstractMethodError;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.TouchEvent;
import starling.filters.FragmentFilter;
import starling.rendering.BatchToken;
import starling.rendering.Painter;
import starling.utils.Color;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import starling.utils.SystemUtil;
import starling.utils.Execute;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class DisplayObject extends EventDispatcher {
	static var sMaskWarningShown:Bool = false;

	static var sAncestors:Vector<DisplayObject> = new Vector((0 : UInt));

	static var sHelperPoint3D:Vector3D = new Vector3D();

	static var sHelperPointAlt3D:Vector3D = new Vector3D();

	static var sHelperRect:Rectangle = new Rectangle();

	static var sHelperMatrix:Matrix = new Matrix();

	static var sHelperMatrixAlt:Matrix = new Matrix();

	static var sHelperMatrix3D:Matrix3D = new Matrix3D();

	static var sHelperMatrixAlt3D:Matrix3D = new Matrix3D();

	var _x:Float = Math.NaN;

	var _y:Float = Math.NaN;

	var _pivotX:Float = Math.NaN;

	var _pivotY:Float = Math.NaN;

	var _scaleX:Float = Math.NaN;

	var _scaleY:Float = Math.NaN;

	var _skewX:Float = Math.NaN;

	var _skewY:Float = Math.NaN;

	var _rotation:Float = Math.NaN;

	var _alpha:Float = Math.NaN;

	var _visible:Bool = false;

	var _touchable:Bool = false;

	var _blendMode:String;

	var _name:String;

	var _useHandCursor:Bool = false;

	var _transformationMatrix:Matrix;

	var _transformationMatrix3D:Matrix3D;

	var _transformationChanged:Bool = false;

	var _is3D:Bool = false;

	var _maskee:DisplayObject;

	var _maskInverted:Bool = false;

	@:allow(starling.display) var _parent:DisplayObjectContainer;

	@:allow(starling.display) var _lastParentOrSelfChangeFrameID:UInt = 0;

	@:allow(starling.display) var _lastChildChangeFrameID:UInt = 0;

	@:allow(starling.display) var _tokenFrameID:UInt = 0;

	@:allow(starling.display) var _pushToken:BatchToken = new BatchToken();

	@:allow(starling.display) var _popToken:BatchToken = new BatchToken();

	@:allow(starling.display) var _hasVisibleArea:Bool = false;

	@:allow(starling.display) var _filter:FragmentFilter;

	@:allow(starling.display) var _mask:DisplayObject;

	public function new() {
		super();
		if (Capabilities.isDebugger && ASCompat.getQualifiedClassName(this) == "starling.display::DisplayObject") {
			throw new AbstractClassError();
		}
		_x = _y = _pivotX = _pivotY = _rotation = _skewX = _skewY = 0;
		_scaleX = _scaleY = _alpha = 1;
		_visible = _touchable = _hasVisibleArea = true;
		_blendMode = "auto";
		_transformationMatrix = new Matrix();
	}

	static function findCommonParent(object1:DisplayObject, object2:DisplayObject):DisplayObject {
		var _loc3_ = object1;
		while (_loc3_ != null) {
			sAncestors[sAncestors.length] = _loc3_;
			_loc3_ = _loc3_._parent;
		}
		_loc3_ = object2;
		while (_loc3_ != null && sAncestors.indexOf(_loc3_) == -1) {
			_loc3_ = _loc3_._parent;
		}
		sAncestors.length = 0;
		if (_loc3_ != null) {
			return _loc3_;
		}
		throw new ArgumentError("Object not connected to target");
		return null;
	}

	public function dispose() {
		if (_filter != null) {
			_filter.dispose();
		}
		if (_mask != null) {
			_mask.dispose();
		}
		removeEventListeners();
		mask = null;
	}

	public function removeFromParent(dispose:Bool = false) {
		if (_parent != null) {
			_parent.removeChild(this, dispose);
		} else if (dispose) {
			this.dispose();
		}
	}

	public function getTransformationMatrix(targetSpace:DisplayObject, out:Matrix = null):Matrix {
		var _loc3_:DisplayObject = null;
		var _loc4_:DisplayObject = null;
		if (out != null) {
			out.identity();
		} else {
			out = new Matrix();
		}
		if (targetSpace == this) {
			return out;
		}
		if (targetSpace == _parent || targetSpace == null && _parent == null) {
			out.copyFrom(transformationMatrix);
			return out;
		}
		if (targetSpace == null || targetSpace == base) {
			_loc4_ = this;
			while (_loc4_ != targetSpace) {
				out.concat(_loc4_.transformationMatrix);
				_loc4_ = _loc4_._parent;
			}
			return out;
		}
		if (targetSpace._parent == this) {
			targetSpace.getTransformationMatrix(this, out);
			out.invert();
			return out;
		}
		_loc3_ = findCommonParent(this, targetSpace);
		_loc4_ = this;
		while (_loc4_ != _loc3_) {
			out.concat(_loc4_.transformationMatrix);
			_loc4_ = _loc4_._parent;
		}
		if (_loc3_ == targetSpace) {
			return out;
		}
		sHelperMatrix.identity();
		_loc4_ = targetSpace;
		while (_loc4_ != _loc3_) {
			sHelperMatrix.concat(_loc4_.transformationMatrix);
			_loc4_ = _loc4_._parent;
		}
		sHelperMatrix.invert();
		out.concat(sHelperMatrix);
		return out;
	}

	public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		throw new AbstractMethodError();
		return null;
	}

	public function hitTest(localPoint:Point):DisplayObject {
		if (!_visible || !_touchable) {
			return null;
		}
		if (_mask != null && !hitTestMask(localPoint)) {
			return null;
		}
		if (getBounds(this, sHelperRect).containsPoint(localPoint)) {
			return this;
		}
		return null;
	}

	public function hitTestMask(localPoint:Point):Bool {
		var _loc2_:Point = null;
		var _loc3_ = false;
		if (_mask != null) {
			if (_mask.stage != null) {
				getTransformationMatrix(_mask, sHelperMatrixAlt);
			} else {
				sHelperMatrixAlt.copyFrom(_mask.transformationMatrix);
				sHelperMatrixAlt.invert();
			}
			_loc2_ = Pool.getPoint();
			MatrixUtil.transformPoint(sHelperMatrixAlt, localPoint, _loc2_);
			_loc3_ = _mask.hitTest(_loc2_) != null;
			Pool.putPoint(_loc2_);
			return _maskInverted ? !_loc3_ : _loc3_;
		}
		return true;
	}

	public function localToGlobal(localPoint:Point, out:Point = null):Point {
		if (is3D) {
			sHelperPoint3D.setTo(localPoint.x, localPoint.y, 0);
			return local3DToGlobal(sHelperPoint3D, out);
		}
		getTransformationMatrix(base, sHelperMatrixAlt);
		return MatrixUtil.transformPoint(sHelperMatrixAlt, localPoint, out);
	}

	public function globalToLocal(globalPoint:Point, out:Point = null):Point {
		if (is3D) {
			globalToLocal3D(globalPoint, sHelperPoint3D);
			stage.getCameraPosition(this, sHelperPointAlt3D);
			return MathUtil.intersectLineWithXYPlane(sHelperPointAlt3D, sHelperPoint3D, out);
		}
		getTransformationMatrix(base, sHelperMatrixAlt);
		sHelperMatrixAlt.invert();
		return MatrixUtil.transformPoint(sHelperMatrixAlt, globalPoint, out);
	}

	public function render(painter:Painter) {
		throw new AbstractMethodError();
	}

	public function alignPivot(horizontalAlign:String = "center", verticalAlign:String = "center") {
		var _loc3_ = getBounds(this, sHelperRect);
		if (horizontalAlign == "left") {
			pivotX = _loc3_.x;
		} else if (horizontalAlign == "center") {
			pivotX = _loc3_.x + _loc3_.width / 2;
		} else {
			if (horizontalAlign != "right") {
				throw new ArgumentError("Invalid horizontal alignment: " + horizontalAlign);
			}
			pivotX = _loc3_.x + _loc3_.width;
		}
		if (verticalAlign == "top") {
			pivotY = _loc3_.y;
		} else if (verticalAlign == "center") {
			pivotY = _loc3_.y + _loc3_.height / 2;
		} else {
			if (verticalAlign != "bottom") {
				throw new ArgumentError("Invalid vertical alignment: " + verticalAlign);
			}
			pivotY = _loc3_.y + _loc3_.height;
		}
	}

	public function drawToBitmapData(out:BitmapData = null, color:UInt = (0 : UInt), alpha:Float = 0):BitmapData {
		var _loc12_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc20_:Rectangle = null;
		var _loc9_ = Math.NaN;
		var _loc14_ = Starling.painter;
		var _loc17_ = Starling.current.stage;
		var _loc6_ = Starling.current.viewPort;
		var _loc4_:Float = _loc17_.stageWidth;
		var _loc19_:Float = _loc17_.stageHeight;
		var _loc15_ = _loc6_.width / _loc4_;
		var _loc16_ = _loc6_.height / _loc19_;
		var _loc18_ = _loc14_.backBufferScaleFactor;
		var _loc7_ = _loc15_ * _loc18_;
		var _loc5_ = _loc16_ * _loc18_;
		if (Std.isOfType(this, Stage)) {
			_loc11_ = _loc6_.x < 0 ? -_loc6_.x / _loc15_ : 0;
			_loc12_ = _loc6_.y < 0 ? -_loc6_.y / _loc16_ : 0;
			if (out == null) {
				out = new BitmapData(ASCompat.floatToInt(_loc14_.backBufferWidth * _loc18_), ASCompat.floatToInt(_loc14_.backBufferHeight * _loc18_));
			}
		} else {
			_loc20_ = getBounds(_parent, sHelperRect);
			_loc11_ = _loc20_.x;
			_loc12_ = _loc20_.y;
			if (out == null) {
				out = new BitmapData(Math.ceil(_loc20_.width * _loc7_), Math.ceil(_loc20_.height * _loc5_));
			}
		}
		color = Color.multiply(color, alpha);
		_loc14_.pushState();
		_loc14_.setupContextDefaults();
		_loc14_.state.renderTarget = null;
		_loc14_.state.setModelviewMatricesToIdentity();
		_loc14_.setStateTo(transformationMatrix);
		var _loc10_ = _loc12_;
		var _loc13_ = _loc14_.backBufferWidth / _loc15_;
		var _loc21_ = _loc14_.backBufferHeight / _loc16_;
		var _loc22_ = Pool.getPoint(0, 0);
		var _loc8_ = Pool.getRectangle(0, 0, _loc14_.backBufferWidth * _loc18_, _loc14_.backBufferHeight * _loc18_);
		while (_loc22_.y < out.height) {
			_loc9_ = _loc11_;
			_loc22_.x = 0;
			while (_loc22_.x < out.width) {
				_loc14_.clear(color, alpha);
				_loc14_.state.setProjectionMatrix(_loc9_, _loc10_, _loc13_, _loc21_, _loc4_, _loc19_, _loc17_.cameraPosition);
				if (_mask != null) {
					_loc14_.drawMask(mask, this);
				}
				if (_filter != null) {
					_filter.render(_loc14_);
				} else {
					render(_loc14_);
				}
				if (_mask != null) {
					_loc14_.eraseMask(mask, this);
				}
				_loc14_.finishMeshBatch();
				Execute.execute(_loc14_.context.drawToBitmapData, out, _loc8_, _loc22_);
				_loc9_ += _loc13_;
				_loc22_.x += _loc13_ * _loc7_;
			}
			_loc10_ += _loc21_;
			_loc22_.y += _loc21_ * _loc5_;
		}
		_loc14_.popState();
		Pool.putRectangle(_loc8_);
		Pool.putPoint(_loc22_);
		return out;
	}

	public function getTransformationMatrix3D(targetSpace:DisplayObject, out:Matrix3D = null):Matrix3D {
		var _loc3_:DisplayObject = null;
		var _loc4_:DisplayObject = null;
		if (out != null) {
			out.identity();
		} else {
			out = new Matrix3D();
		}
		if (targetSpace == this) {
			return out;
		}
		if (targetSpace == _parent || targetSpace == null && _parent == null) {
			out.copyFrom(transformationMatrix3D);
			return out;
		}
		if (targetSpace == null || targetSpace == base) {
			_loc4_ = this;
			while (_loc4_ != targetSpace) {
				out.append(_loc4_.transformationMatrix3D);
				_loc4_ = _loc4_._parent;
			}
			return out;
		}
		if (targetSpace._parent == this) {
			targetSpace.getTransformationMatrix3D(this, out);
			out.invert();
			return out;
		}
		_loc3_ = findCommonParent(this, targetSpace);
		_loc4_ = this;
		while (_loc4_ != _loc3_) {
			out.append(_loc4_.transformationMatrix3D);
			_loc4_ = _loc4_._parent;
		}
		if (_loc3_ == targetSpace) {
			return out;
		}
		sHelperMatrix3D.identity();
		_loc4_ = targetSpace;
		while (_loc4_ != _loc3_) {
			sHelperMatrix3D.append(_loc4_.transformationMatrix3D);
			_loc4_ = _loc4_._parent;
		}
		sHelperMatrix3D.invert();
		out.append(sHelperMatrix3D);
		return out;
	}

	public function local3DToGlobal(localPoint:Vector3D, out:Point = null):Point {
		var _loc3_ = this.stage;
		if (_loc3_ == null) {
			throw new IllegalOperationError("Object not connected to stage");
		}
		getTransformationMatrix3D(_loc3_, sHelperMatrixAlt3D);
		MatrixUtil.transformPoint3D(sHelperMatrixAlt3D, localPoint, sHelperPoint3D);
		return MathUtil.intersectLineWithXYPlane(_loc3_.cameraPosition, sHelperPoint3D, out);
	}

	public function globalToLocal3D(globalPoint:Point, out:Vector3D = null):Vector3D {
		var _loc3_ = this.stage;
		if (_loc3_ == null) {
			throw new IllegalOperationError("Object not connected to stage");
		}
		getTransformationMatrix3D(_loc3_, sHelperMatrixAlt3D);
		sHelperMatrixAlt3D.invert();
		return MatrixUtil.transformCoords3D(sHelperMatrixAlt3D, globalPoint.x, globalPoint.y, 0, out);
	}

	/*starling_internal*/
	public function setParent(value:DisplayObjectContainer) {
		var _loc2_:DisplayObject = value;
		while (_loc2_ != this && _loc2_ != null) {
			_loc2_ = _loc2_._parent;
		}
		if (_loc2_ == this) {
			throw new ArgumentError("An object cannot be added as a child to itself or one of its children (or children\'s children, etc.)");
		}
		_parent = value;
	}

	@:allow(starling.display) function setIs3D(value:Bool) {
		_is3D = value;
	}

	@:allow(starling.display) @:isVar var isMask(get, never):Bool;

	function get_isMask():Bool {
		return _maskee != null;
	}

	public function setRequiresRedraw() {
		var _loc1_ = ASCompat.coerce(if (_parent != null) _parent else _maskee, DisplayObject);
		var _loc2_:Int = Starling.frameID;
		_lastParentOrSelfChangeFrameID = (_loc2_ : UInt);
		_hasVisibleArea = _alpha != 0 && _visible && _maskee == null && _scaleX != 0 && _scaleY != 0;
		while (_loc1_ != null && _loc1_._lastChildChangeFrameID != (_loc2_ : UInt)) {
			_loc1_._lastChildChangeFrameID = (_loc2_ : UInt);
			_loc1_ = ASCompat.coerce(if (_loc1_._parent != null) _loc1_._parent else _loc1_._maskee, DisplayObject);
		}
	}

	@:isVar public var requiresRedraw(get, never):Bool;

	public function get_requiresRedraw():Bool {
		var _loc1_ = Starling.frameID;
		return _lastParentOrSelfChangeFrameID == _loc1_ || _lastChildChangeFrameID == _loc1_;
	}

	/*starling_internal*/
	public function excludeFromCache() {
		var _loc2_ = this;
		var _loc1_:Float = 4294967295;
		while (_loc2_ != null && _loc2_._tokenFrameID != _loc1_) {
			_loc2_._tokenFrameID = (ASCompat.floatToInt(_loc1_) : UInt);
			_loc2_ = _loc2_._parent;
		}
	}

	/*starling_internal*/
	public function setTransformationChanged() {
		_transformationChanged = true;
		setRequiresRedraw();
	}

	/*starling_internal*/
	public function updateTransformationMatrices(x:Float, y:Float, pivotX:Float, pivotY:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float,
			rotation:Float, out:Matrix, out3D:Matrix3D) {
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		if (skewX == 0 && skewY == 0) {
			if (rotation == 0) {
				out.setTo(scaleX, 0, 0, scaleY, x - pivotX * scaleX, y - pivotY * scaleY);
			} else {
				_loc18_ = Math.cos(rotation);
				_loc19_ = Math.sin(rotation);
				_loc12_ = scaleX * _loc18_;
				_loc13_ = scaleX * _loc19_;
				_loc14_ = scaleY * -_loc19_;
				_loc15_ = scaleY * _loc18_;
				_loc16_ = x - pivotX * _loc12_ - pivotY * _loc14_;
				_loc17_ = y - pivotX * _loc13_ - pivotY * _loc15_;
				out.setTo(_loc12_, _loc13_, _loc14_, _loc15_, _loc16_, _loc17_);
			}
		} else {
			out.identity();
			out.scale(scaleX, scaleY);
			MatrixUtil.skew(out, skewX, skewY);
			out.rotate(rotation);
			out.translate(x, y);
			if (pivotX != 0 || pivotY != 0) {
				out.tx = x - out.a * pivotX - out.c * pivotY;
				out.ty = y - out.b * pivotX - out.d * pivotY;
			}
		}
		if (out3D != null) {
			MatrixUtil.convertTo3D(out, out3D);
		}
	}

	override public function dispatchEvent(event:Event) {
		if (event.type == "removedFromStage" && stage == null) {
			return;
		}
		super.dispatchEvent(event);
	}

	override public function addEventListener(type:String, listener:ASFunction) {
		if (type == "enterFrame" && !hasEventListener(type)) {
			addEventListener("addedToStage", (cast addEnterFrameListenerToStage));
			addEventListener("removedFromStage", (cast removeEnterFrameListenerFromStage));
			if (this.stage != null) {
				addEnterFrameListenerToStage();
			}
		}
		super.addEventListener(type, listener);
	}

	override public function removeEventListener(type:String, listener:ASFunction) {
		super.removeEventListener(type, listener);
		if (type == "enterFrame" && !hasEventListener(type)) {
			removeEventListener("addedToStage", (cast addEnterFrameListenerToStage));
			removeEventListener("removedFromStage", (cast removeEnterFrameListenerFromStage));
			removeEnterFrameListenerFromStage();
		}
	}

	override public function removeEventListeners(type:String = null) {
		if ((type == null || type == "enterFrame") && hasEventListener("enterFrame")) {
			removeEventListener("addedToStage", (cast addEnterFrameListenerToStage));
			removeEventListener("removedFromStage", (cast removeEnterFrameListenerFromStage));
			removeEnterFrameListenerFromStage();
		}
		super.removeEventListeners(type);
	}

	function addEnterFrameListenerToStage() {
		Starling.current.stage.addEnterFrameListener(this);
	}

	function removeEnterFrameListenerFromStage() {
		Starling.current.stage.removeEnterFrameListener(this);
	}

	@:isVar public var transformationMatrix(get, set):Matrix;

	public function get_transformationMatrix():Matrix {
		if (_transformationChanged) {
			_transformationChanged = false;
			if (_transformationMatrix3D == null && _is3D) {
				_transformationMatrix3D = new Matrix3D();
			}
			updateTransformationMatrices(_x, _y, _pivotX, _pivotY, _scaleX, _scaleY, _skewX, _skewY, _rotation, _transformationMatrix, _transformationMatrix3D);
		}
		return _transformationMatrix;
	}

	function set_transformationMatrix(matrix:Matrix):Matrix {
		var _loc2_ = Math.NaN;
		_loc2_ = 0.7853981633974483;
		setRequiresRedraw();
		_transformationChanged = false;
		_transformationMatrix.copyFrom(matrix);
		_pivotX = _pivotY = 0;
		_x = matrix.tx;
		_y = matrix.ty;
		_skewX = Math.atan(-matrix.c / matrix.d);
		_skewY = Math.atan(matrix.b / matrix.a);
		if (_skewX != _skewX) {
			_skewX = 0;
		}
		if (_skewY != _skewY) {
			_skewY = 0;
		}
		_scaleY = _skewX > -0.7853981633974483 && _skewX < 0.7853981633974483 ? matrix.d / Math.cos(_skewX) : -matrix.c / Math.sin(_skewX);
		_scaleX = _skewY > -0.7853981633974483 && _skewY < 0.7853981633974483 ? matrix.a / Math.cos(_skewY) : matrix.b / Math.sin(_skewY);
		if (MathUtil.isEquivalent(_skewX, _skewY)) {
			_rotation = _skewX;
			_skewX = _skewY = 0;
		} else {
			_rotation = 0;
		}
		return matrix;
	}

	@:isVar public var transformationMatrix3D(get, never):Matrix3D;

	public function get_transformationMatrix3D():Matrix3D {
		if (_transformationMatrix3D == null) {
			_transformationMatrix3D = MatrixUtil.convertTo3D(_transformationMatrix);
		}
		if (_transformationChanged) {
			_transformationChanged = false;
			updateTransformationMatrices(_x, _y, _pivotX, _pivotY, _scaleX, _scaleY, _skewX, _skewY, _rotation, _transformationMatrix, _transformationMatrix3D);
		}
		return _transformationMatrix3D;
	}

	@:isVar public var is3D(get, never):Bool;

	public function get_is3D():Bool {
		return _is3D;
	}

	@:isVar public var useHandCursor(get, set):Bool;

	public function get_useHandCursor():Bool {
		return _useHandCursor;
	}

	function set_useHandCursor(value:Bool):Bool {
		if (value == _useHandCursor) {
			return value;
		}
		_useHandCursor = value;
		if (_useHandCursor) {
			addEventListener("touch", onTouch);
		} else {
			removeEventListener("touch", onTouch);
		}
		return value;
	}

	function onTouch(event:TouchEvent) {
		Mouse.cursor = event.interactsWith(this) ? "button" : "auto";
	}

	@:isVar public var bounds(get, never):Rectangle;

	public function get_bounds():Rectangle {
		return getBounds(_parent);
	}

	@:isVar public var width(get, set):Float;

	public function get_width():Float {
		return getBounds(_parent, sHelperRect).width;
	}

	function set_width(value:Float):Float {
		var _loc2_ = Math.NaN;
		var _loc4_ = _scaleX != _scaleX;
		var _loc3_ = _scaleX < 1e-8 && _scaleX > -1e-8;
		if (_loc3_ || _loc4_) {
			scaleX = 1;
			_loc2_ = width;
		} else {
			_loc2_ = Math.abs(width / _scaleX);
		}
		if (ASCompat.floatAsBool(_loc2_)) {
			scaleX = value / _loc2_;
		}
		return value;
	}

	@:isVar public var height(get, set):Float;

	public function get_height():Float {
		return getBounds(_parent, sHelperRect).height;
	}

	function set_height(value:Float):Float {
		var _loc2_ = Math.NaN;
		var _loc4_ = _scaleY != _scaleY;
		var _loc3_ = _scaleY < 1e-8 && _scaleY > -1e-8;
		if (_loc3_ || _loc4_) {
			scaleY = 1;
			_loc2_ = height;
		} else {
			_loc2_ = Math.abs(height / _scaleY);
		}
		if (ASCompat.floatAsBool(_loc2_)) {
			scaleY = value / _loc2_;
		}
		return value;
	}

	@:isVar public var x(get, set):Float;

	public function get_x():Float {
		return _x;
	}

	function set_x(value:Float):Float {
		if (_x != value) {
			_x = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var y(get, set):Float;

	public function get_y():Float {
		return _y;
	}

	function set_y(value:Float):Float {
		if (_y != value) {
			_y = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var pivotX(get, set):Float;

	public function get_pivotX():Float {
		return _pivotX;
	}

	function set_pivotX(value:Float):Float {
		if (_pivotX != value) {
			_pivotX = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var pivotY(get, set):Float;

	public function get_pivotY():Float {
		return _pivotY;
	}

	function set_pivotY(value:Float):Float {
		if (_pivotY != value) {
			_pivotY = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var scaleX(get, set):Float;

	public function get_scaleX():Float {
		return _scaleX;
	}

	function set_scaleX(value:Float):Float {
		if (_scaleX != value) {
			_scaleX = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var scaleY(get, set):Float;

	public function get_scaleY():Float {
		return _scaleY;
	}

	function set_scaleY(value:Float):Float {
		if (_scaleY != value) {
			_scaleY = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var scale(get, set):Float;

	public function get_scale():Float {
		return scaleX;
	}

	function set_scale(value:Float):Float {
		scaleX = scaleY = value;
		return value;
	}

	@:isVar public var skewX(get, set):Float;

	public function get_skewX():Float {
		return _skewX;
	}

	function set_skewX(value:Float):Float {
		value = MathUtil.normalizeAngle(value);
		if (_skewX != value) {
			_skewX = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var skewY(get, set):Float;

	public function get_skewY():Float {
		return _skewY;
	}

	function set_skewY(value:Float):Float {
		value = MathUtil.normalizeAngle(value);
		if (_skewY != value) {
			_skewY = value;
			setTransformationChanged();
		}
		return value;
	}

	@:isVar public var rotation(get, set):Float;

	public function get_rotation():Float {
		return _rotation;
	}

	function set_rotation(value:Float):Float {
		value = MathUtil.normalizeAngle(value);
		if (_rotation != value) {
			_rotation = value;
			setTransformationChanged();
		}
		return value;
	}

	@:allow(starling.display) @:isVar var isRotated(get, never):Bool;

	function get_isRotated():Bool {
		return _rotation != 0 || _skewX != 0 || _skewY != 0;
	}

	@:isVar public var alpha(get, set):Float;

	public function get_alpha():Float {
		return _alpha;
	}

	function set_alpha(value:Float):Float {
		if (value != _alpha) {
			_alpha = value < 0 ? 0 : (value > 1 ? 1 : value);
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var visible(get, set):Bool;

	public function get_visible():Bool {
		return _visible;
	}

	function set_visible(value:Bool):Bool {
		if (value != _visible) {
			_visible = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var touchable(get, set):Bool;

	public function get_touchable():Bool {
		return _touchable;
	}

	function set_touchable(value:Bool):Bool {
		return _touchable = value;
	}

	@:isVar public var blendMode(get, set):String;

	public function get_blendMode():String {
		return _blendMode;
	}

	function set_blendMode(value:String):String {
		if (value != _blendMode) {
			_blendMode = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var name(get, set):String;

	public function get_name():String {
		return _name;
	}

	function set_name(value:String):String {
		return _name = value;
	}

	@:isVar public var filter(get, set):FragmentFilter;

	public function get_filter():FragmentFilter {
		return _filter;
	}

	function set_filter(value:FragmentFilter):FragmentFilter {
		if (value != _filter) {
			if (_filter != null) {
				_filter.setTarget(null);
			}
			if (value != null) {
				value.setTarget(this);
			}
			_filter = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var mask(get, set):DisplayObject;

	public function get_mask():DisplayObject {
		return _mask;
	}

	function set_mask(value:DisplayObject):DisplayObject {
		if (_mask != value) {
			if (!sMaskWarningShown) {
				if (SystemUtil.supportsDepthAndStencil) {}
				sMaskWarningShown = true;
			}
			if (_mask != null) {
				_mask._maskee = null;
			}
			if (value != null) {
				value._maskee = this;
				value._hasVisibleArea = false;
			}
			_mask = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var maskInverted(get, set):Bool;

	public function get_maskInverted():Bool {
		return _maskInverted;
	}

	function set_maskInverted(value:Bool):Bool {
		if (value != _maskInverted) {
			_maskInverted = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var parent(get, never):DisplayObjectContainer;

	public function get_parent():DisplayObjectContainer {
		return _parent;
	}

	@:isVar public var base(get, never):DisplayObject;

	public function get_base():DisplayObject {
		var _loc1_ = this;
		while (_loc1_._parent != null) {
			_loc1_ = _loc1_._parent;
		}
		return _loc1_;
	}

	@:isVar public var root(get, never):DisplayObject;

	public function get_root():DisplayObject {
		var _loc1_ = this;
		while (_loc1_._parent != null) {
			if (Std.isOfType(_loc1_._parent, Stage)) {
				return _loc1_;
			}
			_loc1_ = _loc1_.parent;
		}
		return null;
	}

	@:isVar public var stage(get, never):Stage;

	public function get_stage():Stage {
		return ASCompat.reinterpretAs(this.base, Stage);
	}
}
