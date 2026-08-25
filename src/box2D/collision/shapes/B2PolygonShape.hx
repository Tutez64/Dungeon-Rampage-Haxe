package box2D.collision.shapes;

import box2D.collision.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2PolygonShape extends B2Shape {
	static var s_mat:B2Mat22 = new B2Mat22();

	/*b2internal*/
	public var m_centroid:B2Vec2;

	/*b2internal*/
	public var m_vertices:Vector<B2Vec2>;

	/*b2internal*/
	public var m_normals:Vector<B2Vec2>;

	/*b2internal*/
	public var m_vertexCount:Int = 0;

	public function new() {
		super();
		/*b2internal::*/ m_type = /*b2internal::*/ B2Shape.e_polygonShape;
		this.m_centroid = new B2Vec2();
		this.m_vertices = new Vector<B2Vec2>();
		this.m_normals = new Vector<B2Vec2>();
	}

	public static function AsArray(vertices:Array<ASAny>, vertexCount:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.SetAsArray(vertices, vertexCount);
		return _loc3_;
	}

	public static function AsVector(vertices:Vector<B2Vec2>, vertexCount:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.SetAsVector(vertices, vertexCount);
		return _loc3_;
	}

	public static function AsBox(hx:Float, hy:Float):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.SetAsBox(hx, hy);
		return _loc3_;
	}

	public static function AsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = null, angle:Float = 0):B2PolygonShape {
		var _loc5_ = new B2PolygonShape();
		_loc5_.SetAsOrientedBox(hx, hy, center, angle);
		return _loc5_;
	}

	public static function AsEdge(v1:B2Vec2, v2:B2Vec2):B2PolygonShape {
		var _loc3_ = new B2PolygonShape();
		_loc3_.SetAsEdge(v1, v2);
		return _loc3_;
	}

	public static function ComputeCentroid(vs:Vector<B2Vec2>, count:UInt):B2Vec2 {
		var _loc3_:B2Vec2 = null;
		var _loc7_ = Math.NaN;
		var _loc9_:B2Vec2 = null;
		var _loc10_:B2Vec2 = null;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		_loc3_ = new B2Vec2();
		var _loc4_:Float = 0;
		var _loc5_:Float = 0;
		var _loc6_:Float = 0;
		_loc7_ = 1 / 3;
		var _loc8_ = 0;
		while ((_loc8_ : UInt) < count) {
			_loc9_ = vs[_loc8_];
			_loc10_ = ASCompat.toNumber(_loc8_ + 1) < count ? vs[ASCompat.toInt(_loc8_ + 1)] : vs[0];
			_loc11_ = _loc9_.x - _loc5_;
			_loc12_ = _loc9_.y - _loc6_;
			_loc13_ = _loc10_.x - _loc5_;
			_loc14_ = _loc10_.y - _loc6_;
			_loc15_ = _loc11_ * _loc14_ - _loc12_ * _loc13_;
			_loc16_ = 0.5 * _loc15_;
			_loc4_ += _loc16_;
			_loc3_.x += _loc16_ * _loc7_ * (_loc5_ + _loc9_.x + _loc10_.x);
			_loc3_.y += _loc16_ * _loc7_ * (_loc6_ + _loc9_.y + _loc10_.y);
			_loc8_ = ASCompat.toInt(_loc8_) + 1;
		}
		_loc3_.x *= 1 / _loc4_;
		_loc3_.y *= 1 / _loc4_;
		return _loc3_;
	}

	/*b2internal*/
	public static function ComputeOBB(obb:B2OBB, vs:Vector<B2Vec2>, count:Int) {
		var _loc4_ = 0;
		var _loc7_:B2Vec2 = null;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = 0;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_:B2Mat22 = null;
		var _loc5_ = new Vector<B2Vec2>((count + 1 : UInt));
		_loc4_ = 0;
		while (_loc4_ < count) {
			_loc5_[_loc4_] = vs[_loc4_];
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		_loc5_[count] = _loc5_[0];
		var _loc6_:Float = ASCompat.MAX_FLOAT;
		_loc4_ = 1;
		while (_loc4_ <= count) {
			_loc7_ = _loc5_[ASCompat.toInt(_loc4_ - 1)];
			_loc8_ = _loc5_[_loc4_].x - _loc7_.x;
			_loc9_ = _loc5_[_loc4_].y - _loc7_.y;
			_loc10_ = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
			_loc8_ /= _loc10_;
			_loc9_ /= _loc10_;
			_loc11_ = -_loc9_;
			_loc12_ = _loc8_;
			_loc13_ = ASCompat.MAX_FLOAT;
			_loc14_ = ASCompat.MAX_FLOAT;
			_loc15_ = -ASCompat.MAX_FLOAT;
			_loc16_ = -ASCompat.MAX_FLOAT;
			_loc17_ = 0;
			while (_loc17_ < count) {
				_loc19_ = _loc5_[_loc17_].x - _loc7_.x;
				_loc20_ = _loc5_[_loc17_].y - _loc7_.y;
				_loc21_ = _loc8_ * _loc19_ + _loc9_ * _loc20_;
				_loc22_ = _loc11_ * _loc19_ + _loc12_ * _loc20_;
				if (_loc21_ < _loc13_) {
					_loc13_ = _loc21_;
				}
				if (_loc22_ < _loc14_) {
					_loc14_ = _loc22_;
				}
				if (_loc21_ > _loc15_) {
					_loc15_ = _loc21_;
				}
				if (_loc22_ > _loc16_) {
					_loc16_ = _loc22_;
				}
				_loc17_ = ASCompat.toInt(_loc17_) + 1;
			}
			_loc18_ = (_loc15_ - _loc13_) * (_loc16_ - _loc14_);
			if (_loc18_ < 0.95 * _loc6_) {
				_loc6_ = _loc18_;
				obb.R.col1.x = _loc8_;
				obb.R.col1.y = _loc9_;
				obb.R.col2.x = _loc11_;
				obb.R.col2.y = _loc12_;
				_loc23_ = 0.5 * (_loc13_ + _loc15_);
				_loc24_ = 0.5 * (_loc14_ + _loc16_);
				_loc25_ = obb.R;
				obb.center.x = _loc7_.x + (_loc25_.col1.x * _loc23_ + _loc25_.col2.x * _loc24_);
				obb.center.y = _loc7_.y + (_loc25_.col1.y * _loc23_ + _loc25_.col2.y * _loc24_);
				obb.extents.x = 0.5 * (_loc15_ - _loc13_);
				obb.extents.y = 0.5 * (_loc16_ - _loc14_);
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
	}

	override public function Copy():B2Shape {
		var _loc1_ = new B2PolygonShape();
		_loc1_.Set(this);
		return _loc1_;
	}

	override public function Set(other:B2Shape) {
		var _loc2_:B2PolygonShape = null;
		var _loc3_ = 0;
		super.Set(other);
		if (Std.isOfType(other, B2PolygonShape)) {
			_loc2_ = ASCompat.reinterpretAs(other, B2PolygonShape);
			this.m_centroid.SetV(_loc2_.m_centroid);
			this.m_vertexCount = _loc2_.m_vertexCount;
			this.Reserve(this.m_vertexCount);
			_loc3_ = 0;
			while (_loc3_ < this.m_vertexCount) {
				this.m_vertices[_loc3_].SetV(_loc2_.m_vertices[_loc3_]);
				this.m_normals[_loc3_].SetV(_loc2_.m_normals[_loc3_]);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
		}
	}

	public function SetAsArray(vertices:Array<ASAny>, vertexCount:Float = 0) {
		var _loc4_:B2Vec2 = null;
		var _loc3_ = new Vector<B2Vec2>();
		if (checkNullIteratee(vertices))
			for (_tmp_ in vertices) {
				_loc4_ = ASCompat.dynamicAs(_tmp_, box2D.common.math.B2Vec2);
				_loc3_.push(_loc4_);
			}
		this.SetAsVector(_loc3_, vertexCount);
	}

	public function SetAsVector(vertices:Vector<B2Vec2>, vertexCount:Float = 0) {
		var _loc3_ = 0;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc6_:B2Vec2 = null;
		if (vertexCount == 0) {
			vertexCount = vertices.length;
		}
		B2Settings.b2Assert(2 <= vertexCount);
		this.m_vertexCount = Std.int(vertexCount);
		this.Reserve(Std.int(vertexCount));
		_loc3_ = 0;
		while (_loc3_ < this.m_vertexCount) {
			this.m_vertices[_loc3_].SetV(vertices[_loc3_]);
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		_loc3_ = 0;
		while (_loc3_ < this.m_vertexCount) {
			_loc4_ = _loc3_;
			_loc5_ = ASCompat.toNumber(_loc3_ + 1) < this.m_vertexCount ? ASCompat.toInt(_loc3_ + 1) : 0;
			_loc6_ = B2Math.SubtractVV(this.m_vertices[_loc5_], this.m_vertices[_loc4_]);
			B2Settings.b2Assert(_loc6_.LengthSquared() > ASCompat.MIN_FLOAT);
			this.m_normals[_loc3_].SetV(B2Math.CrossVF(_loc6_, 1));
			this.m_normals[_loc3_].Normalize();
			_loc3_ = ASCompat.toInt(_loc3_) + 1;
		}
		this.m_centroid = ComputeCentroid(this.m_vertices, (this.m_vertexCount : UInt));
	}

	public function SetAsBox(hx:Float, hy:Float) {
		this.m_vertexCount = 4;
		this.Reserve(4);
		this.m_vertices[0].Set(-hx, -hy);
		this.m_vertices[1].Set(hx, -hy);
		this.m_vertices[2].Set(hx, hy);
		this.m_vertices[3].Set(-hx, hy);
		this.m_normals[0].Set(0, -1);
		this.m_normals[1].Set(1, 0);
		this.m_normals[2].Set(0, 1);
		this.m_normals[3].Set(-1, 0);
		this.m_centroid.SetZero();
	}

	public function SetAsOrientedBox(hx:Float, hy:Float, center:B2Vec2 = null, angle:Float = 0) {
		this.m_vertexCount = 4;
		this.Reserve(4);
		this.m_vertices[0].Set(-hx, -hy);
		this.m_vertices[1].Set(hx, -hy);
		this.m_vertices[2].Set(hx, hy);
		this.m_vertices[3].Set(-hx, hy);
		this.m_normals[0].Set(0, -1);
		this.m_normals[1].Set(1, 0);
		this.m_normals[2].Set(0, 1);
		this.m_normals[3].Set(-1, 0);
		this.m_centroid = center;
		var _loc5_ = new B2Transform();
		_loc5_.position = center;
		_loc5_.R.Set(angle);
		var _loc6_ = 0;
		while (_loc6_ < this.m_vertexCount) {
			this.m_vertices[_loc6_] = B2Math.MulX(_loc5_, this.m_vertices[_loc6_]);
			this.m_normals[_loc6_] = B2Math.MulMV(_loc5_.R, this.m_normals[_loc6_]);
			_loc6_ = ASCompat.toInt(_loc6_) + 1;
		}
	}

	public function SetAsEdge(v1:B2Vec2, v2:B2Vec2) {
		this.m_vertexCount = 2;
		this.Reserve(2);
		this.m_vertices[0].SetV(v1);
		this.m_vertices[1].SetV(v2);
		this.m_centroid.x = 0.5 * (v1.x + v2.x);
		this.m_centroid.y = 0.5 * (v1.y + v2.y);
		this.m_normals[0] = B2Math.CrossVF(B2Math.SubtractVV(v2, v1), 1);
		this.m_normals[0].Normalize();
		this.m_normals[1].x = -this.m_normals[0].x;
		this.m_normals[1].y = -this.m_normals[0].y;
	}

	override public function TestPoint(xf:B2Transform, p:B2Vec2):Bool {
		var _loc3_:B2Vec2 = null;
		var _loc10_ = Math.NaN;
		var _loc4_ = xf.R;
		var _loc5_ = p.x - xf.position.x;
		var _loc6_ = p.y - xf.position.y;
		var _loc7_ = _loc5_ * _loc4_.col1.x + _loc6_ * _loc4_.col1.y;
		var _loc8_ = _loc5_ * _loc4_.col2.x + _loc6_ * _loc4_.col2.y;
		var _loc9_ = 0;
		while (_loc9_ < this.m_vertexCount) {
			_loc3_ = this.m_vertices[_loc9_];
			_loc5_ = _loc7_ - _loc3_.x;
			_loc6_ = _loc8_ - _loc3_.y;
			_loc3_ = this.m_normals[_loc9_];
			_loc10_ = _loc3_.x * _loc5_ + _loc3_.y * _loc6_;
			if (_loc10_ > 0) {
				return false;
			}
			_loc9_ = ASCompat.toInt(_loc9_) + 1;
		}
		return true;
	}

	override public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc8_:B2Mat22 = null;
		var _loc9_:B2Vec2 = null;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc4_:Float = 0;
		var _loc5_ = input.maxFraction;
		_loc6_ = input.p1.x - transform.position.x;
		_loc7_ = input.p1.y - transform.position.y;
		_loc8_ = transform.R;
		var _loc10_ = _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
		var _loc11_ = _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
		_loc6_ = input.p2.x - transform.position.x;
		_loc7_ = input.p2.y - transform.position.y;
		_loc8_ = transform.R;
		var _loc12_ = _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
		var _loc13_ = _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
		var _loc14_ = _loc12_ - _loc10_;
		var _loc15_ = _loc13_ - _loc11_;
		var _loc16_ = -1;
		var _loc17_ = 0;
		while (_loc17_ < this.m_vertexCount) {
			_loc9_ = this.m_vertices[_loc17_];
			_loc6_ = _loc9_.x - _loc10_;
			_loc7_ = _loc9_.y - _loc11_;
			_loc9_ = this.m_normals[_loc17_];
			_loc18_ = _loc9_.x * _loc6_ + _loc9_.y * _loc7_;
			_loc19_ = _loc9_.x * _loc14_ + _loc9_.y * _loc15_;
			if (_loc19_ == 0) {
				if (_loc18_ < 0) {
					return false;
				}
			} else if (_loc19_ < 0 && _loc18_ < _loc4_ * _loc19_) {
				_loc4_ = _loc18_ / _loc19_;
				_loc16_ = _loc17_;
			} else if (_loc19_ > 0 && _loc18_ < _loc5_ * _loc19_) {
				_loc5_ = _loc18_ / _loc19_;
			}
			if (_loc5_ < _loc4_ - ASCompat.MIN_FLOAT) {
				return false;
			}
			_loc17_ = ASCompat.toInt(_loc17_) + 1;
		}
		if (_loc16_ >= 0) {
			output.fraction = _loc4_;
			_loc8_ = transform.R;
			_loc9_ = this.m_normals[_loc16_];
			output.normal.x = _loc8_.col1.x * _loc9_.x + _loc8_.col2.x * _loc9_.y;
			output.normal.y = _loc8_.col1.y * _loc9_.x + _loc8_.col2.y * _loc9_.y;
			return true;
		}
		return false;
	}

	override public function ComputeAABB(aabb:B2AABB, xf:B2Transform) {
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc3_ = xf.R;
		var _loc4_ = this.m_vertices[0];
		var _loc5_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
		var _loc6_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
		var _loc7_ = _loc5_;
		var _loc8_ = _loc6_;
		var _loc9_ = 1;
		while (_loc9_ < this.m_vertexCount) {
			_loc4_ = this.m_vertices[_loc9_];
			_loc10_ = xf.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
			_loc11_ = xf.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
			_loc5_ = _loc5_ < _loc10_ ? _loc5_ : _loc10_;
			_loc6_ = _loc6_ < _loc11_ ? _loc6_ : _loc11_;
			_loc7_ = _loc7_ > _loc10_ ? _loc7_ : _loc10_;
			_loc8_ = _loc8_ > _loc11_ ? _loc8_ : _loc11_;
			_loc9_ = ASCompat.toInt(_loc9_) + 1;
		}
		aabb.lowerBound.x = _loc5_ - m_radius;
		aabb.lowerBound.y = _loc6_ - m_radius;
		aabb.upperBound.x = _loc7_ + m_radius;
		aabb.upperBound.y = _loc8_ + m_radius;
	}

	override public function ComputeMass(massData:B2MassData, density:Float) {
		var _loc11_:B2Vec2 = null;
		var _loc12_:B2Vec2 = null;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
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
		if (this.m_vertexCount == 2) {
			massData.center.x = 0.5 * (this.m_vertices[0].x + this.m_vertices[1].x);
			massData.center.y = 0.5 * (this.m_vertices[0].y + this.m_vertices[1].y);
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
		var _loc9_ = 1 / 3;
		var _loc10_ = 0;
		while (_loc10_ < this.m_vertexCount) {
			_loc11_ = this.m_vertices[_loc10_];
			_loc12_ = ASCompat.toNumber(_loc10_ + 1) < this.m_vertexCount ? this.m_vertices[ASCompat.toInt(_loc10_ + 1)] : this.m_vertices[0];
			_loc13_ = _loc11_.x - _loc7_;
			_loc14_ = _loc11_.y - _loc8_;
			_loc15_ = _loc12_.x - _loc7_;
			_loc16_ = _loc12_.y - _loc8_;
			_loc17_ = _loc13_ * _loc16_ - _loc14_ * _loc15_;
			_loc18_ = 0.5 * _loc17_;
			_loc5_ += _loc18_;
			_loc3_ += _loc18_ * _loc9_ * (_loc7_ + _loc11_.x + _loc12_.x);
			_loc4_ += _loc18_ * _loc9_ * (_loc8_ + _loc11_.y + _loc12_.y);
			_loc19_ = _loc7_;
			_loc20_ = _loc8_;
			_loc21_ = _loc13_;
			_loc22_ = _loc14_;
			_loc23_ = _loc15_;
			_loc24_ = _loc16_;
			_loc25_ = _loc9_ * (0.25 * (_loc21_ * _loc21_ + _loc23_ * _loc21_ + _loc23_ * _loc23_) + (_loc19_ * _loc21_ + _loc19_ * _loc23_))
				+ 0.5 * _loc19_ * _loc19_;
			_loc26_ = _loc9_ * (0.25 * (_loc22_ * _loc22_ + _loc24_ * _loc22_ + _loc24_ * _loc24_) + (_loc20_ * _loc22_ + _loc20_ * _loc24_))
				+ 0.5 * _loc20_ * _loc20_;
			_loc6_ += _loc17_ * (_loc25_ + _loc26_);
			_loc10_ = ASCompat.toInt(_loc10_) + 1;
		}
		massData.mass = density * _loc5_;
		_loc3_ *= 1 / _loc5_;
		_loc4_ *= 1 / _loc5_;
		massData.center.Set(_loc3_, _loc4_);
		massData.I = density * _loc6_;
	}

	override public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		var _loc12_ = 0;
		var _loc22_:B2Vec2 = null;
		var _loc23_ = false;
		var _loc24_:B2MassData = null;
		var _loc25_ = Math.NaN;
		var _loc5_ = B2Math.MulTMV(xf.R, normal);
		var _loc6_ = offset - B2Math.Dot(normal, xf.position);
		var _loc7_ = new Vector<Float>();
		var _loc8_ = 0;
		var _loc9_ = -1;
		var _loc10_ = -1;
		var _loc11_ = false;
		_loc12_ = 0;
		while (_loc12_ < this.m_vertexCount) {
			_loc7_[_loc12_] = B2Math.Dot(_loc5_, this.m_vertices[_loc12_]) - _loc6_;
			_loc23_ = _loc7_[_loc12_] < -ASCompat.MIN_FLOAT;
			if (_loc12_ > 0) {
				if (_loc23_) {
					if (!_loc11_) {
						_loc9_ = ASCompat.toInt(_loc12_ - 1);
						_loc8_ = ASCompat.toInt(_loc8_) + 1;
					}
				} else if (_loc11_) {
					_loc10_ = ASCompat.toInt(_loc12_ - 1);
					_loc8_ = ASCompat.toInt(_loc8_) + 1;
				}
			}
			_loc11_ = _loc23_;
			_loc12_ = ASCompat.toInt(_loc12_) + 1;
		}
		switch (_loc8_) {
			case 0:
				if (_loc11_) {
					_loc24_ = new B2MassData();
					this.ComputeMass(_loc24_, 1);
					c.SetV(B2Math.MulX(xf, _loc24_.center));
					return _loc24_.mass;
				}
				return 0;

			case 1:
				if (_loc9_ == -1) {
					_loc9_ = this.m_vertexCount - 1;
				} else {
					_loc10_ = this.m_vertexCount - 1;
				}
		}
		var _loc13_ = (_loc9_ + 1) % this.m_vertexCount;
		var _loc14_ = (_loc10_ + 1) % this.m_vertexCount;
		var _loc15_ = (0 - _loc7_[_loc9_]) / (_loc7_[_loc13_] - _loc7_[_loc9_]);
		var _loc16_ = (0 - _loc7_[_loc10_]) / (_loc7_[_loc14_] - _loc7_[_loc10_]);
		var _loc17_ = new B2Vec2(this.m_vertices[_loc9_].x * (1 - _loc15_) + this.m_vertices[_loc13_].x * _loc15_,
			this.m_vertices[_loc9_].y * (1 - _loc15_) + this.m_vertices[_loc13_].y * _loc15_);
		var _loc18_ = new B2Vec2(this.m_vertices[_loc10_].x * (1 - _loc16_) + this.m_vertices[_loc14_].x * _loc16_,
			this.m_vertices[_loc10_].y * (1 - _loc16_) + this.m_vertices[_loc14_].y * _loc16_);
		var _loc19_:Float = 0;
		var _loc20_ = new B2Vec2();
		var _loc21_ = this.m_vertices[_loc13_];
		_loc12_ = _loc13_;
		while (_loc12_ != _loc14_) {
			_loc12_ = ASCompat.toInt(ASCompat.toNumber(_loc12_ + 1) % this.m_vertexCount);
			if (_loc12_ == _loc14_) {
				_loc22_ = _loc18_;
			} else {
				_loc22_ = this.m_vertices[_loc12_];
			}
			_loc25_ = 0.5 * ((_loc21_.x - _loc17_.x) * (_loc22_.y - _loc17_.y) - (_loc21_.y - _loc17_.y) * (_loc22_.x - _loc17_.x));
			_loc19_ += _loc25_;
			_loc20_.x += _loc25_ * (_loc17_.x + _loc21_.x + _loc22_.x) / 3;
			_loc20_.y += _loc25_ * (_loc17_.y + _loc21_.y + _loc22_.y) / 3;
			_loc21_ = _loc22_;
		}
		_loc20_.Multiply(1 / _loc19_);
		c.SetV(B2Math.MulX(xf, _loc20_));
		return _loc19_;
	}

	public function GetVertexCount():Int {
		return this.m_vertexCount;
	}

	public function GetVertices():Vector<B2Vec2> {
		return this.m_vertices;
	}

	public function GetNormals():Vector<B2Vec2> {
		return this.m_normals;
	}

	public function GetSupport(d:B2Vec2):Int {
		var _loc5_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
		var _loc4_ = 1;
		while (_loc4_ < this.m_vertexCount) {
			_loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
			if (_loc5_ > _loc3_) {
				_loc2_ = _loc4_;
				_loc3_ = _loc5_;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc2_;
	}

	public function GetSupportVertex(d:B2Vec2):B2Vec2 {
		var _loc5_ = Math.NaN;
		var _loc2_ = 0;
		var _loc3_ = this.m_vertices[0].x * d.x + this.m_vertices[0].y * d.y;
		var _loc4_ = 1;
		while (_loc4_ < this.m_vertexCount) {
			_loc5_ = this.m_vertices[_loc4_].x * d.x + this.m_vertices[_loc4_].y * d.y;
			if (_loc5_ > _loc3_) {
				_loc2_ = _loc4_;
				_loc3_ = _loc5_;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return this.m_vertices[_loc2_];
	}

	function Validate():Bool {
		return false;
	}

	function Reserve(count:Int) {
		var _loc2_ = this.m_vertices.length;
		while (_loc2_ < count) {
			this.m_vertices[_loc2_] = new B2Vec2();
			this.m_normals[_loc2_] = new B2Vec2();
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}
}
