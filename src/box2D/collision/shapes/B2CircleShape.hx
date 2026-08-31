package box2D.collision.shapes;

import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

/*use*/ /*namespace*/ /*b2internal*/ class B2CircleShape extends B2Shape {
	/*b2internal*/
	public var m_p:B2Vec2 = new B2Vec2();

	public function new(radius:Float = 0) {
		super();
		/*b2internal::*/ m_type = /*b2internal::*/ B2Shape.e_circleShape;
		/*b2internal::*/ m_radius = radius;
	}

	override public function Copy():B2Shape {
		var _loc1_:B2Shape = new B2CircleShape();
		_loc1_.Set(this);
		return _loc1_;
	}

	override public function Set(other:B2Shape) {
		var _loc2_:B2CircleShape = null;
		super.Set(other);
		if (Std.isOfType(other, B2CircleShape)) {
			_loc2_ = ASCompat.reinterpretAs(other, B2CircleShape);
			this.m_p.SetV(_loc2_.m_p);
		}
	}

	override public function TestPoint(transform:B2Transform, p:B2Vec2):Bool {
		var _loc3_ = transform.R;
		var _loc4_ = transform.position.x + (_loc3_.col1.x * this.m_p.x + _loc3_.col2.x * this.m_p.y);
		var _loc5_ = transform.position.y + (_loc3_.col1.y * this.m_p.x + _loc3_.col2.y * this.m_p.y);
		_loc4_ = p.x - _loc4_;
		_loc5_ = p.y - _loc5_;
		return _loc4_ * _loc4_ + _loc5_ * _loc5_ <= m_radius * m_radius;
	}

	override public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		var _loc8_ = Math.NaN;
		var _loc4_ = transform.R;
		var _loc5_ = transform.position.x + (_loc4_.col1.x * this.m_p.x + _loc4_.col2.x * this.m_p.y);
		var _loc6_ = transform.position.y + (_loc4_.col1.y * this.m_p.x + _loc4_.col2.y * this.m_p.y);
		var _loc7_ = input.p1.x - _loc5_;
		_loc8_ = input.p1.y - _loc6_;
		var _loc9_ = _loc7_ * _loc7_ + _loc8_ * _loc8_ - m_radius * m_radius;
		var _loc10_ = input.p2.x - input.p1.x;
		var _loc11_ = input.p2.y - input.p1.y;
		var _loc12_ = _loc7_ * _loc10_ + _loc8_ * _loc11_;
		var _loc13_ = _loc10_ * _loc10_ + _loc11_ * _loc11_;
		var _loc14_ = _loc12_ * _loc12_ - _loc13_ * _loc9_;
		if (_loc14_ < 0 || _loc13_ < ASCompat.MIN_FLOAT) {
			return false;
		}
		var _loc15_ = -(_loc12_ + Math.sqrt(_loc14_));
		if (0 <= _loc15_ && _loc15_ <= input.maxFraction * _loc13_) {
			_loc15_ /= _loc13_;
			output.fraction = _loc15_;
			output.normal.x = _loc7_ + _loc15_ * _loc10_;
			output.normal.y = _loc8_ + _loc15_ * _loc11_;
			output.normal.Normalize();
			return true;
		}
		return false;
	}

	override public function ComputeAABB(aabb:B2AABB, transform:B2Transform) {
		var _loc3_ = transform.R;
		var _loc4_ = transform.position.x + (_loc3_.col1.x * this.m_p.x + _loc3_.col2.x * this.m_p.y);
		var _loc5_ = transform.position.y + (_loc3_.col1.y * this.m_p.x + _loc3_.col2.y * this.m_p.y);
		aabb.lowerBound.Set(_loc4_ - m_radius, _loc5_ - m_radius);
		aabb.upperBound.Set(_loc4_ + m_radius, _loc5_ + m_radius);
	}

	override public function ComputeMass(massData:B2MassData, density:Float) {
		massData.mass = density * B2Settings.b2_pi * m_radius * m_radius;
		massData.center.SetV(this.m_p);
		massData.I = massData.mass * (0.5 * m_radius * m_radius + (this.m_p.x * this.m_p.x + this.m_p.y * this.m_p.y));
	}

	override public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		var _loc9_ = Math.NaN;
		var _loc5_ = B2Math.MulX(xf, this.m_p);
		var _loc6_ = -(B2Math.Dot(normal, _loc5_) - offset);
		if (_loc6_ < -m_radius + ASCompat.MIN_FLOAT) {
			return 0;
		}
		if (_loc6_ > m_radius) {
			c.SetV(_loc5_);
			return Math.PI * m_radius * m_radius;
		}
		var _loc7_ = m_radius * m_radius;
		var _loc8_ = _loc6_ * _loc6_;
		_loc9_ = _loc7_ * (Math.asin(_loc6_ / m_radius) + Math.PI / 2) + _loc6_ * Math.sqrt(_loc7_ - _loc8_);
		var _loc10_ = -2 / 3 * Math.pow(_loc7_ - _loc8_, 1.5) / _loc9_;
		c.x = _loc5_.x + normal.x * _loc10_;
		c.y = _loc5_.y + normal.y * _loc10_;
		return _loc9_;
	}

	public function GetLocalPosition():B2Vec2 {
		return this.m_p;
	}

	public function SetLocalPosition(position:B2Vec2) {
		this.m_p.SetV(position);
	}

	public function GetRadius():Float {
		return m_radius;
	}

	public function SetRadius(radius:Float) {
		m_radius = radius;
	}
}
