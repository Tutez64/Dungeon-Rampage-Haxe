package starling.geom;

import flash.geom.Point;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.utils.Earcut;
import starling.utils.MathUtil;
import starling.utils.Pool;
import flash.errors.IllegalOperationError;
import starling.geom.Polygon;
import starling.rendering.IndexData;
import flash.errors.RangeError;
import flash.errors.ArgumentError;

class Polygon {
	public static var useEarcut:Bool = true;

	static var sRestIndices:Vector<UInt> = new Vector((0 : UInt));

	var _coords:Vector<Float>;

	public function new(vertices:Array<ASAny> = null) {
		_coords = new Vector<Float>((0 : UInt));
		addVertices(...(vertices ?? []));
	}

	public static function fromVector(vector:Vector<Float>):Polygon {
		var _loc2_ = new Polygon();
		_loc2_._coords = vector;
		return _loc2_;
	}

	public static function createEllipse(x:Float, y:Float, radiusX:Float, radiusY:Float, numSides:Int = -1):Polygon {
		return new Ellipse(x, y, radiusX, radiusY, numSides);
	}

	public static function createCircle(x:Float, y:Float, radius:Float, numSides:Int = -1):Polygon {
		return new Ellipse(x, y, radius, radius, numSides);
	}

	public static function createRectangle(x:Float, y:Float, width:Float, height:Float):Polygon {
		return new Rectangle(x, y, width, height);
	}

	public static function createRoundRectangle(x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ellipseHeight:Float = null):Polygon {
		if (ellipseHeight == null)
			ellipseHeight = Math.NaN;
		return new RoundRectangle(x, y, width, height, ellipseWidth, ellipseHeight);
	}

	static function isConvexTriangle(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float):Bool {
		return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
	}

	static function areVectorsIntersecting(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float):Bool {
		if (ax == bx && ay == by || cx == dx && cy == dy) {
			return false;
		}
		var _loc12_ = bx - ax;
		var _loc14_ = by - ay;
		var _loc13_ = dx - cx;
		var _loc15_ = dy - cy;
		var _loc9_ = _loc15_ * _loc12_ - _loc13_ * _loc14_;
		if (_loc9_ == 0) {
			return false;
		}
		var _loc11_ = (_loc14_ * (cx - ax) - _loc12_ * (cy - ay)) / _loc9_;
		if (_loc11_ < 0 || _loc11_ > 1) {
			return false;
		}
		var _loc10_ = ASCompat.floatAsBool(_loc14_) ? (cy - ay + _loc11_ * _loc15_) / _loc14_ : (cx - ax + _loc11_ * _loc13_) / _loc12_;
		return _loc10_ >= 0 && _loc10_ <= 1;
	}

	public function clone():Polygon {
		var _loc3_ = 0;
		var _loc1_ = new Polygon();
		var _loc2_ = _coords.length;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			_loc1_._coords[_loc3_] = _coords[_loc3_];
			_loc3_++;
		}
		return _loc1_;
	}

	public function reverse() {
		var _loc2_ = Math.NaN;
		var _loc4_ = 0;
		var _loc3_ = _coords.length;
		var _loc1_ = ASCompat.floatToInt(_loc3_ / 2);
		_loc4_ = 0;
		while (_loc4_ < _loc1_) {
			_loc2_ = _coords[_loc4_];
			_coords[_loc4_] = _coords[_loc3_ - _loc4_ - 2];
			_coords[_loc3_ - _loc4_ - 2] = _loc2_;
			_loc2_ = _coords[_loc4_ + 1];
			_coords[_loc4_ + 1] = _coords[_loc3_ - _loc4_ - 1];
			_coords[_loc3_ - _loc4_ - 1] = _loc2_;
			_loc4_ += 2;
		}
	}

	public function addVertices(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc3_ = 0;
		var _loc2_ = rest.length;
		var _loc4_ = _coords.length;
		if (_loc2_ > 0) {
			if (Std.isOfType(rest[0], Point)) {
				_loc3_ = 0;
				while (_loc3_ < _loc2_) {
					_coords[_loc4_ + _loc3_ * 2] = ASCompat.dynamicAs(rest[_loc3_], Point).x;
					_coords[_loc4_ + _loc3_ * 2 + 1] = ASCompat.dynamicAs(rest[_loc3_], Point).y;
					_loc3_++;
				}
			} else {
				if (!Std.isOfType(rest[0], Float)) {
					throw new ArgumentError("Invalid type: " + ASCompat.getQualifiedClassName(rest[0]));
				}
				_loc3_ = 0;
				while (_loc3_ < _loc2_) {
					_coords[_loc4_ + _loc3_] = ASCompat.toNumber(rest[_loc3_]);
					_loc3_++;
				}
			}
		}
	}

	public function setVertex(index:Int, x:Float, y:Float) {
		if (index >= 0 && index <= numVertices) {
			_coords[index * 2] = x;
			_coords[index * 2 + 1] = y;
			return;
		}
		throw new RangeError("Invalid index: " + index);
	}

	public function getVertex(index:Int, out:Point = null):Point {
		if (index >= 0 && index < numVertices) {
			if (out == null) {
				out = new Point();
			}
			out.setTo(_coords[index * 2], _coords[index * 2 + 1]);
			return out;
		}
		throw new RangeError("Invalid index: " + index);
		return null;
	}

	public function contains(x:Float, y:Float):Bool {
		var _loc6_ = 0;
		var _loc9_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc3_ = this.numVertices;
		var _loc7_ = _loc3_ - 1;
		var _loc5_ = (0 : UInt);
		_loc6_ = 0;
		while (_loc6_ < _loc3_) {
			_loc9_ = _coords[_loc6_ * 2];
			_loc4_ = _coords[_loc6_ * 2 + 1];
			_loc8_ = _coords[_loc7_ * 2];
			_loc10_ = _coords[_loc7_ * 2 + 1];
			if ((_loc4_ < y && _loc10_ >= y || _loc10_ < y && _loc4_ >= y) && (_loc9_ <= x || _loc8_ <= x)) {
				_loc5_ = ((_loc5_ ^ (ASCompat.toInt(_loc9_ + (y - _loc4_) / (_loc10_ - _loc4_) * (_loc8_ - _loc9_) < x) : UInt) : UInt) : UInt);
			}
			_loc7_ = _loc6_;
			_loc6_++;
		}
		return _loc5_ != 0;
	}

	public function containsPoint(point:Point):Bool {
		return contains(point.x, point.y);
	}

	public function triangulate(indexData:IndexData = null, offset:Int = 0):IndexData {
		var _loc17_:Vector<UInt> = /*undefined*/ null;
		var _loc19_ = 0;
		var _loc18_ = 0;
		var _loc16_ = 0;
		var _loc13_ = 0;
		var _loc11_ = 0;
		var _loc9_ = (0 : UInt);
		var _loc6_ = false;
		var _loc7_ = (0 : UInt);
		var _loc10_ = (0 : UInt);
		var _loc12_ = (0 : UInt);
		if (useEarcut) {
			_loc17_ = Earcut.earcut(this._coords);
			if (indexData == null) {
				indexData = new IndexData(_loc17_.length);
			}
			if (_loc17_.length < 3) {
				return indexData;
			}
			_loc19_ = ASCompat.floatToInt(_loc17_.length / 3);
			_loc18_ = 0;
			while (_loc18_ < _loc19_) {
				indexData.addTriangle(_loc17_[_loc18_ * 3] + offset, _loc17_[_loc18_ * 3 + 1] + offset, _loc17_[_loc18_ * 3 + 2] + offset);
				_loc18_++;
			}
			return indexData;
		}
		var _loc14_ = this.numVertices;
		var _loc8_ = this.numTriangles;
		if (indexData == null) {
			indexData = new IndexData(_loc8_ * 3);
		}
		if (_loc8_ == 0) {
			return indexData;
		}
		sRestIndices.length = _loc14_;
		_loc11_ = 0;
		while (_loc11_ < _loc14_) {
			sRestIndices[_loc11_] = (_loc11_ : UInt);
			_loc11_++;
		}
		_loc16_ = 0;
		_loc13_ = _loc14_;
		var _loc3_ = Pool.getPoint();
		var _loc4_ = Pool.getPoint();
		var _loc5_ = Pool.getPoint();
		var _loc15_ = Pool.getPoint();
		while (_loc13_ > 3) {
			_loc6_ = false;
			_loc7_ = sRestIndices[_loc16_ % _loc13_];
			_loc10_ = sRestIndices[(_loc16_ + 1) % _loc13_];
			_loc12_ = sRestIndices[(_loc16_ + 2) % _loc13_];
			_loc3_.setTo(_coords[(2 * _loc7_ : Int)], _coords[(2 * _loc7_ + 1 : Int)]);
			_loc4_.setTo(_coords[(2 * _loc10_ : Int)], _coords[(2 * _loc10_ + 1 : Int)]);
			_loc5_.setTo(_coords[(2 * _loc12_ : Int)], _coords[(2 * _loc12_ + 1 : Int)]);
			if (isConvexTriangle(_loc3_.x, _loc3_.y, _loc4_.x, _loc4_.y, _loc5_.x, _loc5_.y)) {
				_loc6_ = true;
				_loc11_ = 3;
				while (_loc11_ < _loc13_) {
					_loc9_ = sRestIndices[(_loc16_ + _loc11_) % _loc13_];
					_loc15_.setTo(_coords[(2 * _loc9_ : Int)], _coords[(2 * _loc9_ + 1 : Int)]);
					if (MathUtil.isPointInTriangle(_loc15_, _loc3_, _loc4_, _loc5_)) {
						_loc6_ = false;
						break;
					}
					_loc11_++;
				}
			}
			if (_loc6_) {
				indexData.addTriangle(_loc7_ + offset, _loc10_ + offset, _loc12_ + offset);
				sRestIndices.removeAt((_loc16_ + 1) % _loc13_);
				_loc13_--;
				_loc16_ = 0;
			} else if (++_loc16_ == _loc13_) {
				break;
			}
		}
		Pool.putPoint(_loc3_);
		Pool.putPoint(_loc4_);
		Pool.putPoint(_loc5_);
		Pool.putPoint(_loc15_);
		indexData.addTriangle(sRestIndices[0] + offset, sRestIndices[1] + offset, sRestIndices[2] + offset);
		return indexData;
	}

	public function copyToVertexData(target:VertexData = null, targetVertexID:Int = 0, attrName:String = "position") {
		var _loc6_ = 0;
		var _loc4_ = this.numVertices;
		var _loc5_ = targetVertexID + _loc4_;
		if (target.numVertices < _loc5_) {
			target.numVertices = _loc5_;
		}
		_loc6_ = 0;
		while (_loc6_ < _loc4_) {
			target.setPoint(targetVertexID + _loc6_, attrName, _coords[_loc6_ * 2], _coords[_loc6_ * 2 + 1]);
			_loc6_++;
		}
	}

	public function toString():String {
		var _loc3_ = 0;
		var _loc1_ = "[Polygon";
		var _loc2_ = this.numVertices;
		if (_loc2_ > 0) {
			_loc1_ += "\n";
		}
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			_loc1_ += "  [Vertex " + _loc3_ + ": " + "x=" + ASCompat.toFixed(_coords[_loc3_ * 2], (1 : UInt)) + ", " + "y="
				+ ASCompat.toFixed(_coords[_loc3_ * 2 + 1], (1 : UInt)) + "]" + (_loc3_ == _loc2_ - 1 ? "\n" : ",\n");
			_loc3_++;
		}
		return _loc1_ + "]";
	}

	@:isVar public var isSimple(get, never):Bool;

	public function get_isSimple():Bool {
		var _loc11_ = 0;
		var _loc7_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc12_ = 0;
		var _loc3_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc10_ = _coords.length;
		if (_loc10_ <= 6) {
			return true;
		}
		_loc11_ = 0;
		while (_loc11_ < _loc10_) {
			_loc7_ = _coords[_loc11_];
			_loc9_ = _coords[_loc11_ + 1];
			_loc5_ = _coords[(_loc11_ + 2) % _loc10_];
			_loc8_ = _coords[(_loc11_ + 3) % _loc10_];
			_loc1_ = _loc11_ + _loc10_ - 2;
			_loc12_ = _loc11_ + 4;
			while (_loc12_ < _loc1_) {
				_loc3_ = _coords[_loc12_ % _loc10_];
				_loc6_ = _coords[(_loc12_ + 1) % _loc10_];
				_loc2_ = _coords[(_loc12_ + 2) % _loc10_];
				_loc4_ = _coords[(_loc12_ + 3) % _loc10_];
				if (areVectorsIntersecting(_loc7_, _loc9_, _loc5_, _loc8_, _loc3_, _loc6_, _loc2_, _loc4_)) {
					return false;
				}
				_loc12_ += 2;
			}
			_loc11_ += 2;
		}
		return true;
	}

	@:isVar public var isConvex(get, never):Bool;

	public function get_isConvex():Bool {
		var _loc2_ = 0;
		var _loc1_ = _coords.length;
		if (_loc1_ < 6) {
			return true;
		}
		_loc2_ = 0;
		while (_loc2_ < _loc1_) {
			if (!isConvexTriangle(_coords[_loc2_], _coords[_loc2_ + 1], _coords[(_loc2_ + 2) % _loc1_], _coords[(_loc2_ + 3) % _loc1_],
				_coords[(_loc2_ + 4) % _loc1_], _coords[(_loc2_ + 5) % _loc1_])) {
				return false;
			}
			_loc2_ += 2;
		}
		return true;
	}

	@:isVar public var area(get, never):Float;

	public function get_area():Float {
		var _loc3_ = 0;
		var _loc1_:Float = 0;
		var _loc2_ = _coords.length;
		if (_loc2_ >= 6) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_) {
				_loc1_ += _coords[_loc3_] * _coords[(_loc3_ + 3) % _loc2_];
				_loc1_ -= _coords[_loc3_ + 1] * _coords[(_loc3_ + 2) % _loc2_];
				_loc3_ += 2;
			}
		}
		return _loc1_ / 2;
	}

	@:isVar public var numVertices(get, set):Int;

	public function get_numVertices():Int {
		return ASCompat.floatToInt(_coords.length / 2);
	}

	function set_numVertices(value:Int):Int {
		var _loc3_ = 0;
		var _loc2_ = numVertices;
		_coords.length = value * 2;
		if (_loc2_ < value) {
			_loc3_ = _loc2_;
			while (_loc3_ < value) {
				_coords[_loc3_ * 2] = _coords[_loc3_ * 2 + 1] = 0;
				_loc3_++;
			}
		}
		return value;
	}

	@:isVar public var numTriangles(get, never):Int;

	public function get_numTriangles():Int {
		var _loc1_ = this.numVertices;
		return _loc1_ >= 3 ? _loc1_ - 2 : 0;
	}
}

private class ImmutablePolygon extends Polygon {
	var _frozen:Bool = false;

	public function new(vertices:Array<ASAny>) {
		super(vertices);
		_frozen = true;
	}

	override public function addVertices(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (_frozen) {
			throw getImmutableError();
		}
		super.addVertices(...(rest ?? []));
	}

	override public function setVertex(index:Int, x:Float, y:Float) {
		if (_frozen) {
			throw getImmutableError();
		}
		super.setVertex(index, x, y);
	}

	override public function reverse() {
		if (_frozen) {
			throw getImmutableError();
		}
		super.reverse();
	}

	override public function set_numVertices(value:Int):Int {
		if (_frozen) {
			throw getImmutableError();
		}
		super.reverse();
		return value;
	}

	function getImmutableError():Error {
		var _loc2_ = ASCompat.getQualifiedClassName(this).split("::").pop();
		var _loc1_ = _loc2_ + " cannot be modified. Call \'clone\' to create a mutable copy.";
		return new IllegalOperationError(_loc1_);
	}
}

private class Ellipse extends ImmutablePolygon {
	var _x:Float = Math.NaN;

	var _y:Float = Math.NaN;

	var _radiusX:Float = Math.NaN;

	var _radiusY:Float = Math.NaN;

	public function new(x:Float, y:Float, radiusX:Float, radiusY:Float, numSides:Int = -1) {
		_x = x;
		_y = y;
		_radiusX = radiusX;
		_radiusY = radiusY;
		super(getVertices(numSides));
	}

	function getVertices(numSides:Int):Array<ASAny> {
		var _loc5_ = 0;
		if (numSides < 0) {
			numSides = ASCompat.floatToInt(3.141592653589793 * (_radiusX + _radiusY) / 4);
		}
		if (numSides < 6) {
			numSides = 6;
		}
		var _loc2_:Array<ASAny> = [];
		var _loc3_ = 2 * 3.141592653589793 / numSides;
		var _loc4_:Float = 0;
		_loc5_ = 0;
		while (_loc5_ < numSides) {
			_loc2_[_loc5_ * 2] = Math.cos(_loc4_) * _radiusX + _x;
			_loc2_[_loc5_ * 2 + 1] = Math.sin(_loc4_) * _radiusY + _y;
			_loc4_ += _loc3_;
			_loc5_++;
		}
		return _loc2_;
	}

	override public function triangulate(indexData:IndexData = null, offset:Int = 0):IndexData {
		var _loc3_ = 0;
		if (indexData == null) {
			indexData = new IndexData((numVertices - 2) * 3);
		}
		var _loc4_ = (1 : UInt);
		var _loc5_ = (numVertices - 1 : UInt);
		_loc3_ = _loc4_;
		while ((_loc3_ : UInt) < _loc5_) {
			indexData.addTriangle((offset : UInt), (offset + _loc3_ : UInt), (offset + _loc3_ + 1 : UInt));
			_loc3_++;
		}
		return indexData;
	}

	override public function contains(x:Float, y:Float):Bool {
		var _loc4_ = x - _x;
		var _loc6_ = y - _y;
		var _loc3_ = _loc4_ / _radiusX;
		var _loc5_ = _loc6_ / _radiusY;
		return _loc3_ * _loc3_ + _loc5_ * _loc5_ <= 1;
	}

	override public function get_area():Float {
		return 3.141592653589793 * _radiusX * _radiusY;
	}

	override public function get_isSimple():Bool {
		return true;
	}

	override public function get_isConvex():Bool {
		return true;
	}
}

private class Rectangle extends ImmutablePolygon {
	var _x:Float = Math.NaN;

	var _y:Float = Math.NaN;

	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	public function new(x:Float, y:Float, width:Float, height:Float) {
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		super([x, y, x + width, y, x + width, y + height, x, y + height]);
	}

	override public function triangulate(indexData:IndexData = null, offset:Int = 0):IndexData {
		if (indexData == null) {
			indexData = new IndexData(6);
		}
		indexData.addTriangle((offset : UInt), (offset + 1 : UInt), (offset + 3 : UInt));
		indexData.addTriangle((offset + 1 : UInt), (offset + 2 : UInt), (offset + 3 : UInt));
		return indexData;
	}

	override public function contains(x:Float, y:Float):Bool {
		return x >= _x && x <= _x + _width && y >= _y && y <= _y + _height;
	}

	override public function get_area():Float {
		return _width * _height;
	}

	override public function get_isSimple():Bool {
		return true;
	}

	override public function get_isConvex():Bool {
		return true;
	}
}

private class RoundRectangle extends ImmutablePolygon {
	var _x:Float = Math.NaN;

	var _y:Float = Math.NaN;

	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	var _radiusX:Float = Math.NaN;

	var _radiusY:Float = Math.NaN;

	public function new(x:Float, y:Float, width:Float, height:Float, radiusX:Float, radiusY:Float) {
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		_radiusX = radiusX;
		_radiusY = Math.isNaN(radiusY) ? radiusX : radiusY;
		super(getVertices());
	}

	function getNumVerticesPerCorner():Int {
		var _loc1_ = Math.ceil(3.141592653589793 * (_radiusX + _radiusY) / 16);
		if (_loc1_ < 3) {
			_loc1_ = 3;
		}
		return _loc1_;
	}

	function getVertices():Array<ASAny> {
		var _loc10_ = 0;
		var _loc6_ = getNumVerticesPerCorner();
		var _loc1_ = _loc6_ * 4;
		var _loc7_:Array<ASAny> = [];
		var _loc8_ = 3.141592653589793 / 2 / (_loc6_ - 1);
		var _loc9_:Float = 0;
		var _loc2_ = _width - _radiusX - _radiusX;
		var _loc4_ = _height - _radiusY - _radiusY;
		var _loc3_ = true;
		var _loc11_ = 0;
		var _loc5_ = _loc6_;
		_loc10_ = 0;
		while (_loc10_ < 4) {
			while (_loc11_ < _loc5_) {
				_loc7_[_loc11_ * 2] = _loc2_ + Math.cos(_loc9_) * _radiusX + _x + _radiusX;
				_loc7_[_loc11_ * 2 + 1] = _loc4_ + Math.sin(_loc9_) * _radiusY + _y + _radiusY;
				_loc9_ += _loc8_;
				_loc11_++;
			}
			_loc9_ -= _loc8_;
			if (_loc3_) {
				if (_loc2_ == 0) {
					_loc2_ = _width - _radiusX - _radiusX;
				} else {
					_loc2_ = 0;
				}
			} else if (_loc4_ == 0) {
				_loc4_ = _height - _radiusY - _radiusY;
			} else {
				_loc4_ = 0;
			}
			_loc3_ = !_loc3_;
			_loc5_ += _loc6_;
			_loc10_++;
		}
		return _loc7_;
	}

	override public function triangulate(indexData:IndexData = null, offset:Int = 0):IndexData {
		var _loc6_ = 0;
		var _loc4_ = getNumVerticesPerCorner();
		var _loc3_ = _loc4_ * 4;
		var _loc5_ = _loc3_ - 2;
		if (indexData == null) {
			indexData = new IndexData(_loc5_ * 3);
		}
		_loc6_ = 0;
		while (_loc6_ < _loc5_) {
			indexData.addTriangle((0 : UInt), (_loc6_ + 1 : UInt), (_loc6_ + 2 : UInt));
			_loc6_++;
		}
		return indexData;
	}

	override public function contains(x:Float, y:Float):Bool {
		var _loc8_ = Math.NaN;
		var _loc4_ = Math.NaN;
		if (x < _x || y < _y || x > _x + _width || y > _y + _height) {
			return false;
		}
		if (x >= _x + _radiusX && x <= _x + _width - _radiusX) {
			return true;
		}
		if (y >= _y + _radiusY && y <= _y + _height - _radiusY) {
			return true;
		}
		if (x < _x + _radiusX) {
			_loc8_ = _x + _radiusX;
		} else {
			_loc8_ = _x + _width - _radiusX;
		}
		if (y < _y + _radiusY) {
			_loc4_ = _y + _radiusY;
		} else {
			_loc4_ = _y + _height - _radiusY;
		}
		var _loc5_ = x - _loc8_;
		var _loc7_ = y - _loc4_;
		var _loc3_ = _loc5_ / _radiusX;
		var _loc6_ = _loc7_ / _radiusY;
		return _loc3_ * _loc3_ + _loc6_ * _loc6_ <= 1;
	}

	override public function get_area():Float {
		return _width * _height - (4 - 3.141592653589793) * _radiusX * _radiusY;
	}

	override public function get_isSimple():Bool {
		return true;
	}

	override public function get_isConvex():Bool {
		return true;
	}
}
