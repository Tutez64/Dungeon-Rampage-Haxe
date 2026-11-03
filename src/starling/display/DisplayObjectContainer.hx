package starling.display;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import starling.errors.AbstractClassError;
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.BatchToken;
import starling.rendering.Painter;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import flash.errors.RangeError;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class DisplayObjectContainer extends DisplayObject {
	static var sHitTestMatrix:Matrix = new Matrix();

	static var sBoundsMatrix:Matrix = new Matrix();

	static var sBoundsPoint:Point = new Point();

	static var sBroadcastListeners:Vector<DisplayObject> = new Vector((0 : UInt));

	static var sSortBuffer:Vector<DisplayObject> = new Vector((0 : UInt));

	static var sCacheToken:BatchToken = new BatchToken();

	var _children:Vector<DisplayObject>;

	var _touchGroup:Bool = false;

	public function new() {
		super();
		if (Capabilities.isDebugger && ASCompat.getQualifiedClassName(this) == "starling.display::DisplayObjectContainer") {
			throw new AbstractClassError();
		}
		_children = new Vector<DisplayObject>((0 : UInt));
	}

	static function mergeSort(input:Vector<DisplayObject>, compareFunc:ASFunction, startIndex:Int, length:Int, buffer:Vector<DisplayObject>) {
		var _loc9_ = 0;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc10_ = 0;
		var _loc6_ = 0;
		if (length > 1) {
			_loc7_ = startIndex + length;
			_loc8_ = ASCompat.floatToInt(length / 2);
			_loc10_ = startIndex;
			_loc6_ = startIndex + _loc8_;
			mergeSort(input, compareFunc, startIndex, _loc8_, buffer);
			mergeSort(input, compareFunc, startIndex + _loc8_, length - _loc8_, buffer);
			_loc9_ = 0;
			while (_loc9_ < length) {
				if (_loc10_ < startIndex + _loc8_
					&& (_loc6_ == _loc7_ || ASCompat.toNumber(compareFunc(input[_loc10_], input[_loc6_])) <= 0)) {
					buffer[_loc9_] = input[_loc10_];
					_loc10_++;
				} else {
					buffer[_loc9_] = input[_loc6_];
					_loc6_++;
				}
				_loc9_++;
			}
			_loc9_ = startIndex;
			while (_loc9_ < _loc7_) {
				input[_loc9_] = buffer[_loc9_ - startIndex];
				_loc9_++;
			}
		}
	}

	override public function dispose() {
		var _loc1_ = 0;
		_loc1_ = _children.length - 1;
		while (_loc1_ >= 0) {
			_children[_loc1_].dispose();
			_loc1_--;
		}
		super.dispose();
	}

	public function addChild(child:DisplayObject):DisplayObject {
		return addChildAt(child, _children.length);
	}

	public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		var _loc3_:DisplayObjectContainer = null;
		var _loc4_ = _children.length;
		if (index >= 0 && index <= _loc4_) {
			setRequiresRedraw();
			if (child.parent == this) {
				setChildIndex(child, index);
			} else {
				_children.insertAt(index, child);
				child.removeFromParent();
				child.setParent(this);
				child.dispatchEventWith("added", true);
				if (stage != null) {
					_loc3_ = ASCompat.reinterpretAs(child, DisplayObjectContainer);
					if (_loc3_ != null) {
						_loc3_.broadcastEventWith("addedToStage");
					} else {
						child.dispatchEventWith("addedToStage");
					}
				}
			}
			return child;
		}
		throw new RangeError("Invalid child index");
		return null;
	}

	public function removeChild(child:DisplayObject, dispose:Bool = false):DisplayObject {
		var _loc3_ = getChildIndex(child);
		if (_loc3_ != -1) {
			return removeChildAt(_loc3_, dispose);
		}
		return null;
	}

	public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject {
		var _loc4_:DisplayObject = null;
		var _loc3_:DisplayObjectContainer = null;
		if (index >= 0 && index < _children.length) {
			setRequiresRedraw();
			_loc4_ = _children[index];
			_loc4_.dispatchEventWith("removed", true);
			if (stage != null) {
				_loc3_ = ASCompat.reinterpretAs(_loc4_, DisplayObjectContainer);
				if (_loc3_ != null) {
					_loc3_.broadcastEventWith("removedFromStage");
				} else {
					_loc4_.dispatchEventWith("removedFromStage");
				}
			}
			_loc4_.setParent(null);
			if (index >= _children.length || _children[index] != _loc4_) {
				index = _children.indexOf(_loc4_);
			}
			if (index >= 0) {
				_children.removeAt(index);
			}
			if (dispose) {
				_loc4_.dispose();
			}
			return _loc4_;
		}
		throw new RangeError("Invalid child index");
		return null;
	}

	public function removeChildren(beginIndex:Int = 0, endIndex:Int = -1, dispose:Bool = false) {
		var _loc4_ = 0;
		if (endIndex < 0 || endIndex >= numChildren) {
			endIndex = numChildren - 1;
		}
		_loc4_ = beginIndex;
		while (_loc4_ <= endIndex) {
			removeChildAt(beginIndex, dispose);
			_loc4_++;
		}
	}

	public function getChildAt(index:Int):DisplayObject {
		var _loc2_ = _children.length;
		if (index < 0) {
			index = _loc2_ + index;
		}
		if (index >= 0 && index < _loc2_) {
			return _children[index];
		}
		throw new RangeError("Invalid child index");
		return null;
	}

	public function getChildByName(name:String):DisplayObject {
		var _loc3_ = 0;
		var _loc2_ = _children.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			if (_children[_loc3_].name == name) {
				return _children[_loc3_];
			}
			_loc3_++;
		}
		return null;
	}

	public function getChildIndex(child:DisplayObject):Int {
		return _children.indexOf(child);
	}

	public function setChildIndex(child:DisplayObject, index:Int) {
		var _loc3_ = getChildIndex(child);
		if (_loc3_ == index) {
			return;
		}
		if (_loc3_ == -1) {
			throw new ArgumentError("Not a child of this container");
		}
		_children.removeAt(_loc3_);
		_children.insertAt(index, child);
		setRequiresRedraw();
	}

	public function swapChildren(child1:DisplayObject, child2:DisplayObject) {
		var _loc3_ = getChildIndex(child1);
		var _loc4_ = getChildIndex(child2);
		if (_loc3_ == -1 || _loc4_ == -1) {
			throw new ArgumentError("Not a child of this container");
		}
		swapChildrenAt(_loc3_, _loc4_);
	}

	public function swapChildrenAt(index1:Int, index2:Int) {
		var _loc4_ = getChildAt(index1);
		var _loc3_ = getChildAt(index2);
		_children[index1] = _loc3_;
		_children[index2] = _loc4_;
		setRequiresRedraw();
	}

	public function sortChildren(compareFunction:ASFunction) {
		sSortBuffer.length = _children.length;
		mergeSort(_children, compareFunction, 0, _children.length, sSortBuffer);
		sSortBuffer.length = 0;
		setRequiresRedraw();
	}

	public function contains(child:DisplayObject):Bool {
		while (child != null) {
			if (child == this) {
				return true;
			}
			child = child.parent;
		}
		return false;
	}

	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		var _loc7_:Float;
		var _loc6_:Float;
		var _loc5_ = (0 : UInt);
		var _loc4_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc9_ = 0;
		if (out == null) {
			out = new Rectangle();
		}
		var _loc8_ = _children.length;
		if (_loc8_ == 0) {
			getTransformationMatrix(targetSpace, sBoundsMatrix);
			MatrixUtil.transformCoords(sBoundsMatrix, 0, 0, sBoundsPoint);
			out.setTo(sBoundsPoint.x, sBoundsPoint.y, 0, 0);
		} else if (_loc8_ == 1) {
			_children[0].getBounds(targetSpace, out);
		} else {
			_loc5_ = (0 : UInt);
			_loc4_ = 1.7976931348623157e+308;
			_loc7_ = -1.7976931348623157e+308;
			_loc3_ = 1.7976931348623157e+308;
			_loc6_ = -1.7976931348623157e+308;
			_loc9_ = 0;
			while (_loc9_ < _loc8_) {
				_children[_loc9_].getBounds(targetSpace, out);
				if (!(out.width == 0 && out.height == 0)) {
					_loc5_++;
					if (_loc4_ > out.x) {
						_loc4_ = out.x;
					}
					if (_loc7_ < out.right) {
						_loc7_ = out.right;
					}
					if (_loc3_ > out.y) {
						_loc3_ = out.y;
					}
					if (_loc6_ < out.bottom) {
						_loc6_ = out.bottom;
					}
				}
				_loc9_++;
			}
			if (_loc5_ == 0) {
				getTransformationMatrix(targetSpace, sBoundsMatrix);
				MatrixUtil.transformCoords(sBoundsMatrix, 0, 0, sBoundsPoint);
				out.setTo(sBoundsPoint.x, sBoundsPoint.y, 0, 0);
			} else {
				out.setTo(_loc4_, _loc3_, _loc7_ - _loc4_, _loc6_ - _loc3_);
			}
		}
		return out;
	}

	override public function hitTest(localPoint:Point):DisplayObject {
		var _loc5_ = 0;
		var _loc8_:DisplayObject = null;
		var _loc2_:Point = null;
		if (!visible || !touchable || !hitTestMask(localPoint)) {
			return null;
		}
		var _loc7_:DisplayObject = null;
		var _loc6_ = localPoint.x;
		var _loc3_ = localPoint.y;
		var _loc4_ = _children.length;
		_loc5_ = _loc4_ - 1;
		while (_loc5_ >= 0) {
			_loc8_ = _children[_loc5_];
			if (!_loc8_.isMask) {
				sHitTestMatrix.copyFrom(_loc8_.transformationMatrix);
				sHitTestMatrix.invert();
				_loc2_ = Pool.getPoint();
				MatrixUtil.transformCoords(sHitTestMatrix, _loc6_, _loc3_, _loc2_);
				_loc7_ = _loc8_.hitTest(_loc2_);
				Pool.putPoint(_loc2_);
				if (_loc7_ != null) {
					return ASCompat.coerce(_touchGroup ? this : _loc7_, starling.display.DisplayObject);
				}
			}
			_loc5_--;
		}
		return null;
	}

	override public function render(painter:Painter) {
		var _loc5_ = 0;
		var _loc12_:DisplayObject = null;
		var _loc6_:BatchToken = null;
		var _loc2_:BatchToken = null;
		var _loc7_:FragmentFilter = null;
		var _loc13_:DisplayObject = null;
		var _loc9_:DisplayObject = null;
		var _loc10_ = _children.length;
		var _loc4_ = painter.frameID;
		var _loc8_ = _loc4_ != 0;
		var _loc11_ = _lastParentOrSelfChangeFrameID == _loc4_;
		var _loc3_ = false;
		painter.pushState();
		_loc5_ = 0;
		while (_loc5_ < _loc10_) {
			_loc12_ = _children[_loc5_];
			if (_loc12_._hasVisibleArea) {
				if (_loc5_ != 0) {
					painter.restoreState();
				}
				if (_loc11_) {
					_loc12_._lastParentOrSelfChangeFrameID = _loc4_;
				}
				if (_loc12_._lastParentOrSelfChangeFrameID != _loc4_
					&& _loc12_._lastChildChangeFrameID != _loc4_
					&& _loc12_._tokenFrameID == (_loc4_ : Float) - 1 && _loc8_) {
					painter.fillToken(sCacheToken);
					painter.drawFromCache(_loc12_._pushToken, _loc12_._popToken);
					painter.fillToken(_loc12_._popToken);
					_loc12_._pushToken.copyFrom(sCacheToken);
				} else {
					_loc6_ = ASCompat.coerce(_loc8_ ? _loc12_._pushToken : null, starling.rendering.BatchToken);
					_loc2_ = ASCompat.coerce(_loc8_ ? _loc12_._popToken : null, starling.rendering.BatchToken);
					_loc7_ = _loc12_._filter;
					_loc13_ = _loc12_._mask;
					painter.fillToken(_loc6_);
					painter.setStateTo(_loc12_.transformationMatrix, _loc12_.alpha, _loc12_.blendMode);
					if (_loc13_ != null) {
						if (_loc3_) {
							painter.excludeFromCache(_loc12_);
						} else {
							painter.drawMask(_loc13_, _loc12_);
						}
					}
					if (_loc7_ != null) {
						_loc7_.render(painter);
					} else {
						_loc12_.render(painter);
					}
					if (_loc13_ != null) {
						_loc9_ = ASCompat.coerce(_loc5_ >= _loc10_ - 1 ? null : _children[_loc5_ + 1], starling.display.DisplayObject);
						if (_loc9_ != null
							&& _loc9_._mask == _loc13_
							&& _loc9_.maskInverted == _loc12_.maskInverted
							&& _loc9_._hasVisibleArea) {
							_loc3_ = true;
						} else {
							_loc3_ = false;
							painter.eraseMask(_loc13_, _loc12_);
						}
					}
					painter.fillToken(_loc2_);
				}
				if (_loc8_) {
					_loc12_._tokenFrameID = _loc4_;
				}
			}
			_loc5_++;
		}
		painter.popState();
	}

	public function broadcastEvent(event:Event) {
		var _loc3_ = 0;
		if (event.bubbles) {
			throw new ArgumentError("Broadcast of bubbling events is prohibited");
		}
		var _loc4_ = sBroadcastListeners.length;
		getChildEventListeners(this, event.type, sBroadcastListeners);
		var _loc2_ = sBroadcastListeners.length;
		_loc3_ = _loc4_;
		while (_loc3_ < _loc2_) {
			sBroadcastListeners[_loc3_].dispatchEvent(event);
			_loc3_++;
		}
		sBroadcastListeners.length = _loc4_;
	}

	public function broadcastEventWith(eventType:String, data:ASObject = null) {
		var _loc3_ = Event.fromPool(eventType, false, data);
		broadcastEvent(_loc3_);
		Event.toPool(_loc3_);
	}

	@:isVar public var numChildren(get, never):Int;

	public function get_numChildren():Int {
		return _children.length;
	}

	@:isVar public var touchGroup(get, set):Bool;

	public function get_touchGroup():Bool {
		return _touchGroup;
	}

	function set_touchGroup(value:Bool):Bool {
		return _touchGroup = value;
	}

	@:allow(starling.display) function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector<DisplayObject>) {
		var _loc5_:Vector<DisplayObject> = /*undefined*/ null;
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc4_ = ASCompat.reinterpretAs(object, DisplayObjectContainer);
		if (object.hasEventListener(eventType)) {
			listeners[listeners.length] = object;
		}
		if (_loc4_ != null) {
			_loc5_ = _loc4_._children;
			_loc6_ = _loc5_.length;
			_loc7_ = 0;
			while (_loc7_ < _loc6_) {
				getChildEventListeners(_loc5_[_loc7_], eventType, listeners);
				_loc7_++;
			}
		}
	}
}
