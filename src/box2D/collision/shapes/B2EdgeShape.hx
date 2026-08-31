package box2D.collision.shapes;

import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

/*use*/ /*namespace*/ /*b2internal*/ class B2EdgeShape extends B2Shape {
	var s_supportVec:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_v1:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_v2:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_coreV1:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_coreV2:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_length:Float = Math.NaN;

	/*b2internal*/
	public var m_normal:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_direction:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_cornerDir1:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_cornerDir2:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_cornerConvex1:Bool = false;

	/*b2internal*/
	public var m_cornerConvex2:Bool = false;

	/*b2internal*/
	public var m_nextEdge:B2EdgeShape;

	/*b2internal*/
	public var m_prevEdge:B2EdgeShape;

	public function new(v1:B2Vec2, v2:B2Vec2) {
		super();
		/*b2internal::*/ m_type = /*b2internal::*/ B2Shape.e_edgeShape;
		this.m_prevEdge = null;
		this.m_nextEdge = null;
		this.m_v1 = v1;
		this.m_v2 = v2;
		this.m_direction.Set(this.m_v2.x - this.m_v1.x, this.m_v2.y - this.m_v1.y);
		this.m_length = this.m_direction.Normalize();
		this.m_normal.Set(this.m_direction.y, -this.m_direction.x);
		this.m_coreV1.Set(-B2Settings.b2_toiSlop * (this.m_normal.x - this.m_direction.x)
			+ this.m_v1.x,
			-B2Settings.b2_toiSlop * (this.m_normal.y - this.m_direction.y)
			+ this.m_v1.y);
		this.m_coreV2.Set(-B2Settings.b2_toiSlop * (this.m_normal.x + this.m_direction.x)
			+ this.m_v2.x,
			-B2Settings.b2_toiSlop * (this.m_normal.y + this.m_direction.y)
			+ this.m_v2.y);
		this.m_cornerDir1 = this.m_normal;
		this.m_cornerDir2.Set(-this.m_normal.x, -this.m_normal.y);
	}

	override public function TestPoint(transform:B2Transform, p:B2Vec2):Bool {
		return false;
	}

	override public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		var _loc4_:B2Mat22 = null;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc5_ = input.p2.x - input.p1.x;
		var _loc6_ = input.p2.y - input.p1.y;
		_loc4_ = transform.R;
		var _loc7_ = transform.position.x + (_loc4_.col1.x * this.m_v1.x + _loc4_.col2.x * this.m_v1.y);
		var _loc8_ = transform.position.y + (_loc4_.col1.y * this.m_v1.x + _loc4_.col2.y * this.m_v1.y);
		var _loc9_ = transform.position.y + (_loc4_.col1.y * this.m_v2.x + _loc4_.col2.y * this.m_v2.y) - _loc8_;
		var _loc10_ = -(transform.position.x + (_loc4_.col1.x * this.m_v2.x + _loc4_.col2.x * this.m_v2.y) - _loc7_);
		var _loc11_ = 100 * ASCompat.MIN_FLOAT;
		var _loc12_ = -(_loc5_ * _loc9_ + _loc6_ * _loc10_);
		if (_loc12_ > _loc11_) {
			_loc13_ = input.p1.x - _loc7_;
			_loc14_ = input.p1.y - _loc8_;
			_loc15_ = _loc13_ * _loc9_ + _loc14_ * _loc10_;
			if (0 <= _loc15_ && _loc15_ <= input.maxFraction * _loc12_) {
				_loc16_ = -_loc5_ * _loc14_ + _loc6_ * _loc13_;
				if (-_loc11_ * _loc12_ <= _loc16_ && _loc16_ <= _loc12_ * (1 + _loc11_)) {
					_loc15_ /= _loc12_;
					output.fraction = _loc15_;
					_loc17_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
					output.normal.x = _loc9_ / _loc17_;
					output.normal.y = _loc10_ / _loc17_;
					return true;
				}
			}
		}
		return false;
	}

	override public function ComputeAABB(aabb:B2AABB, transform:B2Transform) {
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc3_ = transform.R;
		_loc4_ = transform.position.x + (_loc3_.col1.x * this.m_v1.x + _loc3_.col2.x * this.m_v1.y);
		_loc5_ = transform.position.y + (_loc3_.col1.y * this.m_v1.x + _loc3_.col2.y * this.m_v1.y);
		_loc6_ = transform.position.x + (_loc3_.col1.x * this.m_v2.x + _loc3_.col2.x * this.m_v2.y);
		_loc7_ = transform.position.y + (_loc3_.col1.y * this.m_v2.x + _loc3_.col2.y * this.m_v2.y);
		if (_loc4_ < _loc6_) {
			aabb.lowerBound.x = _loc4_;
			aabb.upperBound.x = _loc6_;
		} else {
			aabb.lowerBound.x = _loc6_;
			aabb.upperBound.x = _loc4_;
		}
		if (_loc5_ < _loc7_) {
			aabb.lowerBound.y = _loc5_;
			aabb.upperBound.y = _loc7_;
		} else {
			aabb.lowerBound.y = _loc7_;
			aabb.upperBound.y = _loc5_;
		}
	}

	override public function ComputeMass(massData:B2MassData, density:Float) {
		massData.mass = 0;
		massData.center.SetV(this.m_v1);
		massData.I = 0;
	}

	override public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		var _loc5_ = new B2Vec2(normal.x * offset, normal.y * offset);
		var _loc6_ = B2Math.MulX(xf, this.m_v1);
		var _loc7_ = B2Math.MulX(xf, this.m_v2);
		var _loc8_ = B2Math.Dot(normal, _loc6_) - offset;
		var _loc9_ = B2Math.Dot(normal, _loc7_) - offset;
		if (_loc8_ > 0) {
			if (_loc9_ > 0) {
				return 0;
			}
			_loc6_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
			_loc6_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
		} else if (_loc9_ > 0) {
			_loc7_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
			_loc7_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
		}
		c.x = (_loc5_.x + _loc6_.x + _loc7_.x) / 3;
		c.y = (_loc5_.y + _loc6_.y + _loc7_.y) / 3;
		return 0.5 * ((_loc6_.x - _loc5_.x) * (_loc7_.y - _loc5_.y) - (_loc6_.y - _loc5_.y) * (_loc7_.x - _loc5_.x));
	}

	public function GetLength():Float {
		return this.m_length;
	}

	public function GetVertex1():B2Vec2 {
		return this.m_v1;
	}

	public function GetVertex2():B2Vec2 {
		return this.m_v2;
	}

	public function GetCoreVertex1():B2Vec2 {
		return this.m_coreV1;
	}

	public function GetCoreVertex2():B2Vec2 {
		return this.m_coreV2;
	}

	public function GetNormalVector():B2Vec2 {
		return this.m_normal;
	}

	public function GetDirectionVector():B2Vec2 {
		return this.m_direction;
	}

	public function GetCorner1Vector():B2Vec2 {
		return this.m_cornerDir1;
	}

	public function GetCorner2Vector():B2Vec2 {
		return this.m_cornerDir2;
	}

	public function Corner1IsConvex():Bool {
		return this.m_cornerConvex1;
	}

	public function Corner2IsConvex():Bool {
		return this.m_cornerConvex2;
	}

	public function GetFirstVertex(xf:B2Transform):B2Vec2 {
		var _loc2_ = xf.R;
		return new B2Vec2(xf.position.x + (_loc2_.col1.x * this.m_coreV1.x + _loc2_.col2.x * this.m_coreV1.y),
			xf.position.y + (_loc2_.col1.y * this.m_coreV1.x + _loc2_.col2.y * this.m_coreV1.y));
	}

	public function GetNextEdge():B2EdgeShape {
		return this.m_nextEdge;
	}

	public function GetPrevEdge():B2EdgeShape {
		return this.m_prevEdge;
	}

	public function Support(xf:B2Transform, dX:Float, dY:Float):B2Vec2 {
		var _loc4_ = xf.R;
		var _loc5_ = xf.position.x + (_loc4_.col1.x * this.m_coreV1.x + _loc4_.col2.x * this.m_coreV1.y);
		var _loc6_ = xf.position.y + (_loc4_.col1.y * this.m_coreV1.x + _loc4_.col2.y * this.m_coreV1.y);
		var _loc7_ = xf.position.x + (_loc4_.col1.x * this.m_coreV2.x + _loc4_.col2.x * this.m_coreV2.y);
		var _loc8_ = xf.position.y + (_loc4_.col1.y * this.m_coreV2.x + _loc4_.col2.y * this.m_coreV2.y);
		if (_loc5_ * dX + _loc6_ * dY > _loc7_ * dX + _loc8_ * dY) {
			this.s_supportVec.x = _loc5_;
			this.s_supportVec.y = _loc6_;
		} else {
			this.s_supportVec.x = _loc7_;
			this.s_supportVec.y = _loc8_;
		}
		return this.s_supportVec;
	}

	/*b2internal*/
	public function SetPrevEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		this.m_prevEdge = edge;
		this.m_coreV1 = core;
		this.m_cornerDir1 = cornerDir;
		this.m_cornerConvex1 = convex;
	}

	/*b2internal*/
	public function SetNextEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		this.m_nextEdge = edge;
		this.m_coreV2 = core;
		this.m_cornerDir2 = cornerDir;
		this.m_cornerConvex2 = convex;
	}
}
