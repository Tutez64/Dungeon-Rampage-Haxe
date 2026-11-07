package box2D.collision.shapes;

import box2D.collision.B2AABB;
import box2D.collision.B2OBB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2dcompat.As3Array;

class B2PolygonShape extends B2Shape {
	public static var s_mat:B2Mat22 = new B2Mat22();

	public var m_vertices:Array<ASAny>;

	public var m_vertexCount:Int = 0;

	public var m_normals:Array<ASAny>;

	public var m_centroid:B2Vec2;

	public function new() {
		m_vertexCount = 0;
		super();
		m_type = 2;
		m_centroid = new B2Vec2();
		m_vertices = [];
		m_normals = [];
	}

	public static function asArray(vertices:Array<ASAny>, vertexCount:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.setAsArray(vertices, vertexCount);
		return _loc3_;
	}

	public static function asVector(vertices:Array<ASAny>, vertexCount:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.setAsVector(vertices, vertexCount);
		return _loc3_;
	}

	public static function asBox(hx:Float, hy:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.setAsBox(hx, hy);
		return _loc3_;
	}

	public static function asOrientedBox(hx:Float, hy:Float, center:B2Vec2 = /*undefined*/ null, angle:Float = 0):B2PolygonShape {
		var _loc5_ = new B2PolygonShape();
		_loc5_.setAsOrientedBox(hx, hy, center, angle);
		return _loc5_;
	}

	public static function asEdge(v1:B2Vec2, v2:B2Vec2):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.setAsEdge(v1, v2);
		return _loc3_;
	}

	public static function computeCentroid(vs:Array<ASAny>, count:Int):B2Vec2 {
		var _loc10_ = 0;
		var _loc11_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc12_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc3_ = new B2Vec2();
		var _loc4_:Float = 0;
		var _loc5_:Float = 0;
		var _loc6_:Float = 0;
		var _loc7_:Float = 0.3333333333333333;
		var _loc8_ = 0;
		var _loc9_ = count;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc11_ = vs[_loc10_];
			_loc12_ = _loc10_ + 1 < count ? vs[_loc10_ + 1] : vs[0];
			_loc13_ = ASCompat.toNumberField(_loc11_, "x") - _loc5_;
			_loc14_ = ASCompat.toNumberField(_loc11_, "y") - _loc6_;
			_loc15_ = ASCompat.toNumberField(_loc12_, "x") - _loc5_;
			_loc16_ = ASCompat.toNumberField(_loc12_, "y") - _loc6_;
			_loc17_ = _loc13_ * _loc16_ - _loc14_ * _loc15_;
			_loc18_ = 0.5 * _loc17_;
			_loc4_ += _loc18_;
			_loc3_.x += _loc18_ * _loc7_ * ASCompat.toNumber(_loc5_ + _loc11_.x + _loc12_.x);
			_loc3_.y += _loc18_ * _loc7_ * ASCompat.toNumber(_loc6_ + _loc11_.y + _loc12_.y);
		}
		_loc3_.x *= 1 / _loc4_;
		_loc3_.y *= 1 / _loc4_;
		return _loc3_;
	}

	public static function computeOBB(obb:B2OBB, vs:Array<ASAny>, count:Int) {
		var _loc8_ = 0;
		var _loc10_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc20_ = 0;
		var _loc21_ = 0;
		var _loc22_ = 0;
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc27_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc5_:Array<ASAny> = [];
		var _loc6_ = 0;
		var _loc7_ = count;
		while (_loc6_ < _loc7_) {
			_loc8_ = _loc6_++;
			_loc5_[_loc8_] = vs[_loc8_];
		}
		_loc5_[count] = _loc5_[0];
		var _loc9_ = ASCompat.MAX_FLOAT;
		_loc6_ = 1;
		_loc7_ = count + 1;
		while (_loc6_ < _loc7_) {
			_loc8_ = _loc6_++;
			_loc10_ = _loc5_[_loc8_ - 1];
			_loc11_ = ASCompat.toNumberField(_loc5_[_loc8_], "x") - ASCompat.toNumberField(_loc10_, "x");
			_loc12_ = ASCompat.toNumberField(_loc5_[_loc8_], "y") - ASCompat.toNumberField(_loc10_, "y");
			_loc13_ = Math.sqrt(_loc11_ * _loc11_ + _loc12_ * _loc12_);
			_loc11_ /= _loc13_;
			_loc12_ /= _loc13_;
			_loc14_ = -_loc12_;
			_loc15_ = _loc11_;
			_loc16_ = ASCompat.MAX_FLOAT;
			_loc17_ = ASCompat.MAX_FLOAT;
			_loc18_ = -ASCompat.MAX_FLOAT;
			_loc19_ = -ASCompat.MAX_FLOAT;
			_loc20_ = 0;
			_loc21_ = count;
			while (_loc20_ < _loc21_) {
				_loc22_ = _loc20_++;
				_loc23_ = ASCompat.toNumberField(_loc5_[_loc22_], "x") - ASCompat.toNumberField(_loc10_, "x");
				_loc24_ = ASCompat.toNumberField(_loc5_[_loc22_], "y") - ASCompat.toNumberField(_loc10_, "y");
				_loc25_ = _loc11_ * _loc23_ + _loc12_ * _loc24_;
				_loc26_ = _loc14_ * _loc23_ + _loc15_ * _loc24_;
				if (_loc25_ < _loc16_) {
					_loc16_ = _loc25_;
				}
				if (_loc26_ < _loc17_) {
					_loc17_ = _loc26_;
				}
				if (_loc25_ > _loc18_) {
					_loc18_ = _loc25_;
				}
				if (_loc26_ > _loc19_) {
					_loc19_ = _loc26_;
				}
			}
			_loc23_ = (_loc18_ - _loc16_) * (_loc19_ - _loc17_);
			if (_loc23_ < 0.95 * _loc9_) {
				_loc9_ = _loc23_;
				obb.R.col1.x = _loc11_;
				obb.R.col1.y = _loc12_;
				obb.R.col2.x = _loc14_;
				obb.R.col2.y = _loc15_;
				_loc24_ = 0.5 * (_loc16_ + _loc18_);
				_loc25_ = 0.5 * (_loc17_ + _loc19_);
				_loc27_ = obb.R;
				obb.center.x = ASCompat.toNumber(_loc10_.x
					+ (ASCompat.toNumberField(_loc27_.col1, "x") * _loc24_ + ASCompat.toNumberField(_loc27_.col2, "x") * _loc25_));
				obb.center.y = ASCompat.toNumber(_loc10_.y
					+ (ASCompat.toNumberField(_loc27_.col1, "y") * _loc24_ + ASCompat.toNumberField(_loc27_.col2, "y") * _loc25_));
				obb.extents.x = 0.5 * (_loc18_ - _loc16_);
				obb.extents.y = 0.5 * (_loc19_ - _loc17_);
			}
		}
	}

	public static function AsArray(vertices:ASAny, vertexCount:Float):B2PolygonShape {
		return B2PolygonShape.asArray(As3Array.of(vertices), vertexCount);
	}

	public static function AsVector(vertices:ASAny, vertexCount:Float):B2PolygonShape {
		return B2PolygonShape.asVector(As3Array.of(vertices), vertexCount);
	}

	public static function AsBox(hx:Float, hy:Float):B2PolygonShape {
		return B2PolygonShape.asBox(hx, hy);
	}

	public static function AsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = /*undefined*/ null, angle:Float = 0):B2PolygonShape {
		return B2PolygonShape.asOrientedBox(hx, hy, center, angle);
	}

	public static function AsEdge(v1:B2Vec2, v2:B2Vec2):B2PolygonShape {
		return B2PolygonShape.asEdge(v1, v2);
	}

	public static function ComputeCentroid(vs:ASAny, count:Int):B2Vec2 {
		return B2PolygonShape.computeCentroid(As3Array.of(vs), count);
	}

	public static function ComputeOBB(obb:B2OBB, vs:ASAny, count:Int) {
		B2PolygonShape.computeOBB(obb, As3Array.of(vs), count);
	}

	public function validate():Bool {
		return false;
	}

	override public function testPoint(xf:B2Transform, p:B2Vec2):Bool {
		return TestPoint(xf, p);
	}

	public function setAsVector(vertices:Array<ASAny>, vertexCount:Float = 0) {
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc9_ = ASCompat.dynamicAs(null, B2Vec2);
		if (vertexCount == 0) {
			vertexCount = vertices.length;
		}
		B2Settings.b2Assert(2 <= vertexCount);
		m_vertexCount = ASCompat.floatToInt(vertexCount);
		reserve(ASCompat.floatToInt(vertexCount));
		var _loc4_ = 0;
		var _loc5_ = m_vertexCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			m_vertices[_loc6_].setV(vertices[_loc6_]);
		}
		_loc4_ = 0;
		_loc5_ = m_vertexCount;
		while (_loc4_ < _loc5_) {
			_loc7_ = _loc6_ = _loc4_++;
			_loc8_ = _loc6_ + 1 < m_vertexCount ? _loc6_ + 1 : 0;
			_loc9_ = B2Math.subtractVV(ASCompat.coerce(m_vertices[_loc8_], box2D.common.math.B2Vec2),
				ASCompat.coerce(m_vertices[_loc7_], box2D.common.math.B2Vec2));
			B2Settings.b2Assert(ASCompat.toNumber(_loc9_.lengthSquared()) > ASCompat.MIN_FLOAT);
			m_normals[_loc6_].setV(B2Math.crossVF(_loc9_, 1));
			m_normals[_loc6_].normalize();
		}
		m_centroid = B2PolygonShape.computeCentroid(m_vertices, m_vertexCount);
	}

	public function setAsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = /*undefined*/ null, angle:Float = 0) {
		SetAsOrientedBox(hx, hy, center, angle);
	}

	public function setAsEdge(v1:B2Vec2, v2:B2Vec2) {
		SetAsEdge(v1, v2);
	}

	public function setAsBox(hx:Float, hy:Float) {
		SetAsBox(hx, hy);
	}

	public function setAsArray(vertices:Array<ASAny>, vertexCount:Float = 0) {
		var _loc5_:ASAny = null;
		var _loc3_:Array<ASAny> = [];
		var _loc4_ = 0;
		while (_loc4_ < vertices.length) {
			_loc5_ = vertices[_loc4_];
			_loc4_++;
			_loc3_.push(_loc5_);
		}
		setAsVector(_loc3_, vertexCount);
	}

	override public function set(other:B2Shape) {
		Set(other);
	}

	public function reserve(count:Int) {
		var _loc4_ = 0;
		var _loc2_ = m_vertices.length;
		var _loc3_ = count;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			m_vertices[_loc4_] = new B2Vec2();
			m_normals[_loc4_] = new B2Vec2();
		}
	}

	override public function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		return RayCast(output, input, transform);
	}

	public function getVertices():Array<ASAny> {
		return GetVertices();
	}

	public function getVertexCount():Int {
		return GetVertexCount();
	}

	public function getSupportVertex(d:B2Vec2):B2Vec2 {
		return GetSupportVertex(d);
	}

	public function getSupport(d:B2Vec2):Int {
		return GetSupport(d);
	}

	public function getNormals():Array<ASAny> {
		return GetNormals();
	}

	override public function copy():B2Shape {
		return Copy();
	}

	override public function computeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		return ComputeSubmergedArea(normal, offset, xf, c);
	}

	override public function computeMass(massData:B2MassData, density:Float) {
		ComputeMass(massData, density);
	}

	override public function computeAABB(aabb:B2AABB, xf:B2Transform) {
		ComputeAABB(aabb, xf);
	}

	override public function TestPoint(xf:B2Transform, p:B2Vec2):Bool {
		var _loc3_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc11_ = 0;
		var _loc12_ = Math.NaN;
		var _loc4_ = xf.R;
		var _loc5_ = p.x - xf.position.x;
		var _loc6_ = p.y - xf.position.y;
		var _loc7_ = _loc5_ * _loc4_.col1.x + _loc6_ * _loc4_.col1.y;
		var _loc8_ = _loc5_ * _loc4_.col2.x + _loc6_ * _loc4_.col2.y;
		var _loc9_ = 0;
		var _loc10_ = m_vertexCount;
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc3_ = m_vertices[_loc11_];
			_loc5_ = _loc7_ - ASCompat.toNumberField(_loc3_, "x");
			_loc6_ = _loc8_ - ASCompat.toNumberField(_loc3_, "y");
			_loc3_ = m_normals[_loc11_];
			_loc12_ = ASCompat.toNumberField(_loc3_, "x") * _loc5_ + ASCompat.toNumberField(_loc3_, "y") * _loc6_;
			if (_loc12_ > 0) {
				return false;
			}
		}
		return true;
	}

	public function SetAsVector(vertices:ASAny, vertexCount:Float = 0) {
		setAsVector(As3Array.of(vertices), vertexCount);
	}

	public function SetAsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = /*undefined*/ null, angle:Float = 0) {
		var _loc8_ = 0;
		m_vertexCount = 4;
		reserve(4);
		m_vertices[0].set(-hx, -hy);
		m_vertices[1].set(hx, -hy);
		m_vertices[2].set(hx, hy);
		m_vertices[3].set(-hx, hy);
		m_normals[0].set(0, -1);
		m_normals[1].set(1, 0);
		m_normals[2].set(0, 1);
		m_normals[3].set(-1, 0);
		m_centroid = center;
		var _loc5_ = new B2Transform();
		_loc5_.position = center;
		_loc5_.R.set(angle);
		var _loc6_ = 0;
		var _loc7_ = m_vertexCount;
		while (_loc6_ < _loc7_) {
			_loc8_ = _loc6_++;
			m_vertices[_loc8_] = B2Math.mulX(_loc5_, ASCompat.coerce(m_vertices[_loc8_], box2D.common.math.B2Vec2));
			m_normals[_loc8_] = B2Math.mulMV(_loc5_.R, ASCompat.coerce(m_normals[_loc8_], box2D.common.math.B2Vec2));
		}
	}

	public function SetAsEdge(v1:B2Vec2, v2:B2Vec2) {
		m_vertexCount = 2;
		reserve(2);
		m_vertices[0].setV(v1);
		m_vertices[1].setV(v2);
		m_centroid.x = 0.5 * (v1.x + v2.x);
		m_centroid.y = 0.5 * (v1.y + v2.y);
		m_normals[0] = B2Math.crossVF(B2Math.subtractVV(v2, v1), 1);
		m_normals[0].normalize();
		ASCompat.setProperty(m_normals[1], "x", -ASCompat.toNumberField(m_normals[0], "x"));
		ASCompat.setProperty(m_normals[1], "y", -ASCompat.toNumberField(m_normals[0], "y"));
	}

	public function SetAsBox(hx:Float, hy:Float) {
		m_vertexCount = 4;
		reserve(4);
		m_vertices[0].set(-hx, -hy);
		m_vertices[1].set(hx, -hy);
		m_vertices[2].set(hx, hy);
		m_vertices[3].set(-hx, hy);
		m_normals[0].set(0, -1);
		m_normals[1].set(1, 0);
		m_normals[2].set(0, 1);
		m_normals[3].set(-1, 0);
		m_centroid.setZero();
	}

	public function SetAsArray(vertices:ASAny, vertexCount:Float = 0) {
		setAsArray(As3Array.of(vertices), vertexCount);
	}

	override public function Set(other:B2Shape) {
		var _loc2_ = ASCompat.dynamicAs(null, B2PolygonShape);
		var _loc3_ = 0;
		var _loc4_ = 0;
		var _loc5_ = 0;
		super.Set(other);
		if (Std.isOfType(other, B2PolygonShape)) {
			_loc2_ = cast(other, B2PolygonShape);
			m_centroid.setV(ASCompat.coerce(_loc2_.m_centroid, box2D.common.math.B2Vec2));
			m_vertexCount = ASCompat.toInt(_loc2_.m_vertexCount);
			reserve(m_vertexCount);
			_loc3_ = 0;
			_loc4_ = m_vertexCount;
			while (_loc3_ < _loc4_) {
				_loc5_ = _loc3_++;
				m_vertices[_loc5_].setV(_loc2_.m_vertices[_loc5_]);
				m_normals[_loc5_].setV(_loc2_.m_normals[_loc5_]);
			}
		}
	}

	override public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc19_ = 0;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc4_:Float = 0;
		var _loc5_ = input.maxFraction;
		var _loc7_ = input.p1.x - transform.position.x;
		var _loc8_ = input.p1.y - transform.position.y;
		var _loc9_ = transform.R;
		var _loc10_ = _loc7_ * _loc9_.col1.x + _loc8_ * _loc9_.col1.y;
		var _loc11_ = _loc7_ * _loc9_.col2.x + _loc8_ * _loc9_.col2.y;
		_loc7_ = input.p2.x - transform.position.x;
		_loc8_ = input.p2.y - transform.position.y;
		_loc9_ = transform.R;
		var _loc12_ = _loc7_ * _loc9_.col1.x + _loc8_ * _loc9_.col1.y;
		var _loc13_ = _loc7_ * _loc9_.col2.x + _loc8_ * _loc9_.col2.y;
		var _loc14_ = _loc12_ - _loc10_;
		var _loc15_ = _loc13_ - _loc11_;
		var _loc16_ = -1;
		var _loc17_ = 0;
		var _loc18_ = m_vertexCount;
		while (_loc17_ < _loc18_) {
			_loc19_ = _loc17_++;
			_loc6_ = m_vertices[_loc19_];
			_loc7_ = ASCompat.toNumberField(_loc6_, "x") - _loc10_;
			_loc8_ = ASCompat.toNumberField(_loc6_, "y") - _loc11_;
			_loc6_ = m_normals[_loc19_];
			_loc20_ = ASCompat.toNumberField(_loc6_, "x") * _loc7_ + ASCompat.toNumberField(_loc6_, "y") * _loc8_;
			_loc21_ = ASCompat.toNumberField(_loc6_, "x") * _loc14_ + ASCompat.toNumberField(_loc6_, "y") * _loc15_;
			if (_loc21_ == 0) {
				if (_loc20_ < 0) {
					return false;
				}
			} else if (_loc21_ < 0 && _loc20_ < _loc4_ * _loc21_) {
				_loc4_ = _loc20_ / _loc21_;
				_loc16_ = _loc19_;
			} else if (_loc21_ > 0 && _loc20_ < _loc5_ * _loc21_) {
				_loc5_ = _loc20_ / _loc21_;
			}
			if (_loc5_ < _loc4_ - ASCompat.MIN_FLOAT) {
				return false;
			}
		}
		if (_loc16_ >= 0) {
			output.fraction = _loc4_;
			_loc9_ = transform.R;
			_loc6_ = m_normals[_loc16_];
			output.normal.x = _loc9_.col1.x * ASCompat.toNumberField(_loc6_, "x") + _loc9_.col2.x * ASCompat.toNumberField(_loc6_, "y");
			output.normal.y = _loc9_.col1.y * ASCompat.toNumberField(_loc6_, "x") + _loc9_.col2.y * ASCompat.toNumberField(_loc6_, "y");
			return true;
		}
		return false;
	}

	public function GetVertices():Array<ASAny> {
		return m_vertices;
	}

	public function GetVertexCount():Int {
		return m_vertexCount;
	}

	public function GetSupportVertex(d:B2Vec2):B2Vec2 {
		var _loc6_ = 0;
		var _loc7_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = ASCompat.toNumberField(m_vertices[0], "x") * d.x + ASCompat.toNumberField(m_vertices[0], "y") * d.y;
		var _loc4_ = 1;
		var _loc5_ = m_vertexCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = ASCompat.toNumberField(m_vertices[_loc6_], "x") * d.x + ASCompat.toNumberField(m_vertices[_loc6_], "y") * d.y;
			if (_loc7_ > _loc3_) {
				_loc2_ = _loc6_;
				_loc3_ = _loc7_;
			}
		}
		return ASCompat.coerce(m_vertices[_loc2_], box2D.common.math.B2Vec2);
	}

	public function GetSupport(d:B2Vec2):Int {
		var _loc6_ = 0;
		var _loc7_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = ASCompat.toNumberField(m_vertices[0], "x") * d.x + ASCompat.toNumberField(m_vertices[0], "y") * d.y;
		var _loc4_ = 1;
		var _loc5_ = m_vertexCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = ASCompat.toNumberField(m_vertices[_loc6_], "x") * d.x + ASCompat.toNumberField(m_vertices[_loc6_], "y") * d.y;
			if (_loc7_ > _loc3_) {
				_loc2_ = _loc6_;
				_loc3_ = _loc7_;
			}
		}
		return _loc2_;
	}

	public function GetNormals():Array<ASAny> {
		return m_normals;
	}

	override public function Copy():B2Shape {
		var _loc1_ = new B2PolygonShape();
		_loc1_.set(this);
		return _loc1_;
	}

	override public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_ = ASCompat.dynamicAs(null, B2MassData);
		var _loc24_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc25_ = Math.NaN;
		var _loc5_ = B2Math.mulTMV(xf.R, normal);
		var _loc6_ = offset - B2Math.dot(normal, xf.position);
		var _loc7_:Array<ASAny> = [];
		var _loc8_ = 0;
		var _loc9_ = -1;
		var _loc10_ = -1;
		var _loc11_ = false;
		var _loc12_ = 0;
		var _loc13_ = m_vertexCount;
		while (_loc12_ < _loc13_) {
			_loc14_ = _loc12_++;
			_loc7_[_loc14_] = B2Math.dot(_loc5_, ASCompat.coerce(m_vertices[_loc14_], box2D.common.math.B2Vec2)) - _loc6_;
			_loc15_ = ASCompat.toNumber(_loc7_[_loc14_]) < -ASCompat.MIN_FLOAT;
			if (_loc14_ > 0) {
				if (_loc15_) {
					if (!_loc11_) {
						_loc9_ = _loc14_ - 1;
						_loc8_++;
					}
				} else if (_loc11_) {
					_loc10_ = _loc14_ - 1;
					_loc8_++;
				}
			}
			_loc11_ = _loc15_;
		}
		do {
			switch (_loc8_) {
				case 0:
					if (_loc11_) {
						_loc16_ = new B2MassData();
						computeMass(_loc16_, 1);
						c.setV(B2Math.mulX(xf, ASCompat.coerce(_loc16_.center, box2D.common.math.B2Vec2)));
						return ASCompat.toNumberField(_loc16_, "mass");
					}
					return 0;

				case 1:
					if (_loc9_ == -1) {
						_loc9_ = m_vertexCount - 1;
						break;
					}
					_loc10_ = m_vertexCount - 1;
			}
		} while (false);
		_loc12_ = (_loc9_ + 1) % m_vertexCount;
		_loc13_ = (_loc10_ + 1) % m_vertexCount;
		var _loc17_ = (0 - ASCompat.toNumber(_loc7_[_loc9_])) / (ASCompat.toNumber(_loc7_[_loc12_]) - ASCompat.toNumber(_loc7_[_loc9_]));
		var _loc18_ = (0 - ASCompat.toNumber(_loc7_[_loc10_])) / (ASCompat.toNumber(_loc7_[_loc13_]) - ASCompat.toNumber(_loc7_[_loc10_]));
		var _loc19_ = new B2Vec2(ASCompat.toNumberField(m_vertices[_loc9_], "x") * (1 - _loc17_) + ASCompat.toNumberField(m_vertices[_loc12_], "x") * _loc17_,
			ASCompat.toNumberField(m_vertices[_loc9_], "y") * (1 - _loc17_) + ASCompat.toNumberField(m_vertices[_loc12_], "y") * _loc17_);
		var _loc20_ = new B2Vec2(ASCompat.toNumberField(m_vertices[_loc10_], "x") * (1 - _loc18_) + ASCompat.toNumberField(m_vertices[_loc13_], "x") * _loc18_,
			ASCompat.toNumberField(m_vertices[_loc10_], "y") * (1 - _loc18_) + ASCompat.toNumberField(m_vertices[_loc13_], "y") * _loc18_);
		var _loc21_:Float = 0;
		var _loc22_ = new B2Vec2();
		var _loc23_ = ASCompat.coerce(m_vertices[_loc12_], box2D.common.math.B2Vec2);
		_loc14_ = _loc12_;
		while (_loc14_ != _loc13_) {
			_loc14_ = (_loc14_ + 1) % m_vertexCount;
			if (_loc14_ == _loc13_) {
				_loc24_ = _loc20_;
			} else {
				_loc24_ = m_vertices[_loc14_];
			}
			_loc25_ = 0.5 * ((_loc23_.x - _loc19_.x) * (ASCompat.toNumberField(_loc24_, "y") - _loc19_.y)
				- (_loc23_.y - _loc19_.y) * (ASCompat.toNumberField(_loc24_, "x") - _loc19_.x));
			_loc21_ += _loc25_;
			_loc22_.x += _loc25_ * ASCompat.toNumber(_loc19_.x + _loc23_.x + _loc24_.x) / 3;
			_loc22_.y += _loc25_ * ASCompat.toNumber(_loc19_.y + _loc23_.y + _loc24_.y) / 3;
			_loc23_ = ASCompat.coerce(_loc24_, box2D.common.math.B2Vec2);
		}
		_loc22_.multiply(1 / _loc21_);
		c.setV(B2Math.mulX(xf, _loc22_));
		return _loc21_;
	}

	override public function ComputeMass(massData:B2MassData, density:Float) {
		var _loc12_ = 0;
		var _loc13_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc14_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc28_ = Math.NaN;
		if (m_vertexCount == 2) {
			massData.center.x = 0.5 * ASCompat.toNumber(m_vertices[0].x + m_vertices[1].x);
			massData.center.y = 0.5 * ASCompat.toNumber(m_vertices[0].y + m_vertices[1].y);
			massData.mass = 0;
			massData.I = 0;
			return;
		}
		var _loc3_:Float = 0;
		var _loc4_:Float = 0;
		var _loc5_:Float = 0;
		var _loc6_:Float = 0;
		var _loc7_:Float = 0;
		var _loc8_:Float = 0;
		var _loc9_:Float = 0.3333333333333333;
		var _loc10_ = 0;
		var _loc11_ = m_vertexCount;
		while (_loc10_ < _loc11_) {
			_loc12_ = _loc10_++;
			_loc13_ = m_vertices[_loc12_];
			_loc14_ = _loc12_ + 1 < m_vertexCount ? m_vertices[_loc12_ + 1] : m_vertices[0];
			_loc15_ = ASCompat.toNumberField(_loc13_, "x") - _loc7_;
			_loc16_ = ASCompat.toNumberField(_loc13_, "y") - _loc8_;
			_loc17_ = ASCompat.toNumberField(_loc14_, "x") - _loc7_;
			_loc18_ = ASCompat.toNumberField(_loc14_, "y") - _loc8_;
			_loc19_ = _loc15_ * _loc18_ - _loc16_ * _loc17_;
			_loc20_ = 0.5 * _loc19_;
			_loc5_ += _loc20_;
			_loc3_ += _loc20_ * _loc9_ * ASCompat.toNumber(_loc7_ + _loc13_.x + _loc14_.x);
			_loc4_ += _loc20_ * _loc9_ * ASCompat.toNumber(_loc8_ + _loc13_.y + _loc14_.y);
			_loc21_ = _loc7_;
			_loc22_ = _loc8_;
			_loc23_ = _loc15_;
			_loc24_ = _loc16_;
			_loc25_ = _loc17_;
			_loc26_ = _loc18_;
			_loc27_ = _loc9_ * (0.25 * (_loc23_ * _loc23_ + _loc25_ * _loc23_ + _loc25_ * _loc25_) + (_loc21_ * _loc23_ + _loc21_ * _loc25_))
				+ 0.5 * _loc21_ * _loc21_;
			_loc28_ = _loc9_ * (0.25 * (_loc24_ * _loc24_ + _loc26_ * _loc24_ + _loc26_ * _loc26_) + (_loc22_ * _loc24_ + _loc22_ * _loc26_))
				+ 0.5 * _loc22_ * _loc22_;
			_loc6_ += _loc19_ * (_loc27_ + _loc28_);
		}
		massData.mass = density * _loc5_;
		_loc3_ *= 1 / _loc5_;
		_loc4_ *= 1 / _loc5_;
		massData.center.set(_loc3_, _loc4_);
		massData.I = density * _loc6_;
	}

	override public function ComputeAABB(aabb:B2AABB, xf:B2Transform) {
		var _loc11_ = 0;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc3_ = xf.R;
		var _loc4_ = ASCompat.coerce(m_vertices[0], box2D.common.math.B2Vec2);
		var _loc5_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
		var _loc6_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
		var _loc7_ = _loc5_;
		var _loc8_ = _loc6_;
		var _loc9_ = 1;
		var _loc10_ = m_vertexCount;
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc4_ = ASCompat.coerce(m_vertices[_loc11_], box2D.common.math.B2Vec2);
			_loc12_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
			_loc13_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
			if (_loc5_ >= _loc12_) {
				_loc5_ = _loc12_;
			}
			if (_loc6_ >= _loc13_) {
				_loc6_ = _loc13_;
			}
			if (_loc7_ <= _loc12_) {
				_loc7_ = _loc12_;
			}
			if (_loc8_ <= _loc13_) {
				_loc8_ = _loc13_;
			}
		}
		aabb.lowerBound.x = _loc5_ - m_radius;
		aabb.lowerBound.y = _loc6_ - m_radius;
		aabb.upperBound.x = _loc7_ + m_radius;
		aabb.upperBound.y = _loc8_ + m_radius;
	}
}
