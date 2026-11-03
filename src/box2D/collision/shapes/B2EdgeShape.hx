package box2D.collision.shapes;

import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import flash.Boot;

class B2EdgeShape extends B2Shape {
	public var s_supportVec:B2Vec2;

	public var m_v2:B2Vec2;

	public var m_v1:B2Vec2;

	public var m_prevEdge:B2EdgeShape;

	public var m_normal:B2Vec2;

	public var m_nextEdge:B2EdgeShape;

	public var m_length:Float = Math.NaN;

	public var m_direction:B2Vec2;

	public var m_cornerDir2:B2Vec2;

	public var m_cornerDir1:B2Vec2;

	public var m_cornerConvex2:Bool = false;

	public var m_cornerConvex1:Bool = false;

	public var m_coreV2:B2Vec2;

	public var m_coreV1:B2Vec2;

	public function new(v1:B2Vec2 = /*undefined*/ null, v2:B2Vec2 = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super();
			s_supportVec = new B2Vec2();
			m_v1 = new B2Vec2();
			m_v2 = new B2Vec2();
			m_coreV1 = new B2Vec2();
			m_coreV2 = new B2Vec2();
			m_normal = new B2Vec2();
			m_direction = new B2Vec2();
			m_cornerDir1 = new B2Vec2();
			m_cornerDir2 = new B2Vec2();
			m_type = 3;
			m_prevEdge = null;
			m_nextEdge = null;
			m_v1 = v1;
			m_v2 = v2;
			m_direction.set(m_v2.x - m_v1.x, m_v2.y - m_v1.y);
			m_length = m_direction.normalize();
			m_normal.set(m_direction.y, -m_direction.x);
			m_coreV1.set(-B2Settings.b2_toiSlop * (m_normal.x - m_direction.x)
				+ m_v1.x,
				-B2Settings.b2_toiSlop * (m_normal.y - m_direction.y)
				+ m_v1.y);
			m_coreV2.set(-B2Settings.b2_toiSlop * (m_normal.x + m_direction.x)
				+ m_v2.x,
				-B2Settings.b2_toiSlop * (m_normal.y + m_direction.y)
				+ m_v2.y);
			m_cornerDir1 = m_normal;
			m_cornerDir2.set(-m_normal.x, -m_normal.y);
		}
	}

	override public function testPoint(transform:B2Transform, p:B2Vec2):Bool {
		return TestPoint(transform, p);
	}

	public function support(xf:B2Transform, dX:Float, dY:Float):B2Vec2 {
		return Support(xf, dX, dY);
	}

	public function setPrevEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		SetPrevEdge(edge, core, cornerDir, convex);
	}

	public function setNextEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		SetNextEdge(edge, core, cornerDir, convex);
	}

	override public function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		return RayCast(output, input, transform);
	}

	public function getVertex2():B2Vec2 {
		return GetVertex2();
	}

	public function getVertex1():B2Vec2 {
		return GetVertex1();
	}

	public function getPrevEdge():B2EdgeShape {
		return GetPrevEdge();
	}

	public function getNormalVector():B2Vec2 {
		return GetNormalVector();
	}

	public function getNextEdge():B2EdgeShape {
		return GetNextEdge();
	}

	public function getLength():Float {
		return GetLength();
	}

	public function getFirstVertex(xf:B2Transform):B2Vec2 {
		return GetFirstVertex(xf);
	}

	public function getDirectionVector():B2Vec2 {
		return GetDirectionVector();
	}

	public function getCorner2Vector():B2Vec2 {
		return GetCorner2Vector();
	}

	public function getCorner1Vector():B2Vec2 {
		return GetCorner1Vector();
	}

	public function getCoreVertex2():B2Vec2 {
		return GetCoreVertex2();
	}

	public function getCoreVertex1():B2Vec2 {
		return GetCoreVertex1();
	}

	public function corner2IsConvex():Bool {
		return Corner2IsConvex();
	}

	public function corner1IsConvex():Bool {
		return Corner1IsConvex();
	}

	override public function computeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		return ComputeSubmergedArea(normal, offset, xf, c);
	}

	override public function computeMass(massData:B2MassData, density:Float) {
		ComputeMass(massData, density);
	}

	override public function computeAABB(aabb:B2AABB, transform:B2Transform) {
		ComputeAABB(aabb, transform);
	}

	override public function TestPoint(transform:B2Transform, p:B2Vec2):Bool {
		return false;
	}

	public function Support(xf:B2Transform, dX:Float, dY:Float):B2Vec2 {
		var _loc4_ = xf.R;
		var _loc5_ = xf.position.x + (_loc4_.col1.x * m_coreV1.x + _loc4_.col2.x * m_coreV1.y);
		var _loc6_ = xf.position.y + (_loc4_.col1.y * m_coreV1.x + _loc4_.col2.y * m_coreV1.y);
		var _loc7_ = xf.position.x + (_loc4_.col1.x * m_coreV2.x + _loc4_.col2.x * m_coreV2.y);
		var _loc8_ = xf.position.y + (_loc4_.col1.y * m_coreV2.x + _loc4_.col2.y * m_coreV2.y);
		if (_loc5_ * dX + _loc6_ * dY > _loc7_ * dX + _loc8_ * dY) {
			s_supportVec.x = _loc5_;
			s_supportVec.y = _loc6_;
		} else {
			s_supportVec.x = _loc7_;
			s_supportVec.y = _loc8_;
		}
		return s_supportVec;
	}

	public function SetPrevEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		m_prevEdge = edge;
		m_coreV1 = core;
		m_cornerDir1 = cornerDir;
		m_cornerConvex1 = convex;
	}

	public function SetNextEdge(edge:B2EdgeShape, core:B2Vec2, cornerDir:B2Vec2, convex:Bool) {
		m_nextEdge = edge;
		m_coreV2 = core;
		m_cornerDir2 = cornerDir;
		m_cornerConvex2 = convex;
	}

	override public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc4_ = input.p2.x - input.p1.x;
		var _loc5_ = input.p2.y - input.p1.y;
		var _loc6_ = transform.R;
		var _loc7_ = transform.position.x + (_loc6_.col1.x * m_v1.x + _loc6_.col2.x * m_v1.y);
		var _loc8_ = transform.position.y + (_loc6_.col1.y * m_v1.x + _loc6_.col2.y * m_v1.y);
		var _loc9_ = transform.position.y + (_loc6_.col1.y * m_v2.x + _loc6_.col2.y * m_v2.y) - _loc8_;
		var _loc10_ = -(transform.position.x + (_loc6_.col1.x * m_v2.x + _loc6_.col2.x * m_v2.y) - _loc7_);
		var _loc11_ = 100 * ASCompat.MIN_FLOAT;
		var _loc12_ = -(_loc4_ * _loc9_ + _loc5_ * _loc10_);
		if (_loc12_ > _loc11_) {
			_loc13_ = input.p1.x - _loc7_;
			_loc14_ = input.p1.y - _loc8_;
			_loc15_ = _loc13_ * _loc9_ + _loc14_ * _loc10_;
			if (0 <= _loc15_ && _loc15_ <= input.maxFraction * _loc12_) {
				_loc16_ = -_loc4_ * _loc14_ + _loc5_ * _loc13_;
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

	public function GetVertex2():B2Vec2 {
		return m_v2;
	}

	public function GetVertex1():B2Vec2 {
		return m_v1;
	}

	public function GetPrevEdge():B2EdgeShape {
		return m_prevEdge;
	}

	public function GetNormalVector():B2Vec2 {
		return m_normal;
	}

	public function GetNextEdge():B2EdgeShape {
		return m_nextEdge;
	}

	public function GetLength():Float {
		return m_length;
	}

	public function GetFirstVertex(xf:B2Transform):B2Vec2 {
		var _loc2_ = xf.R;
		return new B2Vec2(xf.position.x + (_loc2_.col1.x * m_coreV1.x + _loc2_.col2.x * m_coreV1.y),
			xf.position.y + (_loc2_.col1.y * m_coreV1.x + _loc2_.col2.y * m_coreV1.y));
	}

	public function GetDirectionVector():B2Vec2 {
		return m_direction;
	}

	public function GetCorner2Vector():B2Vec2 {
		return m_cornerDir2;
	}

	public function GetCorner1Vector():B2Vec2 {
		return m_cornerDir1;
	}

	public function GetCoreVertex2():B2Vec2 {
		return m_coreV2;
	}

	public function GetCoreVertex1():B2Vec2 {
		return m_coreV1;
	}

	public function Corner2IsConvex():Bool {
		return m_cornerConvex2;
	}

	public function Corner1IsConvex():Bool {
		return m_cornerConvex1;
	}

	override public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		var _loc5_ = new B2Vec2(normal.x * offset, normal.y * offset);
		var _loc6_ = B2Math.mulX(xf, m_v1);
		var _loc7_ = B2Math.mulX(xf, m_v2);
		var _loc8_ = B2Math.dot(normal, _loc6_) - offset;
		var _loc9_ = B2Math.dot(normal, _loc7_) - offset;
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

	override public function ComputeMass(massData:B2MassData, density:Float) {
		massData.mass = 0;
		massData.center.setV(m_v1);
		massData.I = 0;
	}

	override public function ComputeAABB(aabb:B2AABB, transform:B2Transform) {
		var _loc3_ = transform.R;
		var _loc4_ = transform.position.x + (_loc3_.col1.x * m_v1.x + _loc3_.col2.x * m_v1.y);
		var _loc5_ = transform.position.y + (_loc3_.col1.y * m_v1.x + _loc3_.col2.y * m_v1.y);
		var _loc6_ = transform.position.x + (_loc3_.col1.x * m_v2.x + _loc3_.col2.x * m_v2.y);
		var _loc7_ = transform.position.y + (_loc3_.col1.y * m_v2.x + _loc3_.col2.y * m_v2.y);
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
}
