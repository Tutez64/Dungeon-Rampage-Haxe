package box2D.collision;

import box2D.common.math.B2Vec2;

class B2ManifoldPoint {
	public var m_tangentImpulse:Float = Math.NaN;

	public var m_normalImpulse:Float = Math.NaN;

	public var m_localPoint:B2Vec2;

	public var m_id:B2ContactID;

	public function new() {
		m_localPoint = new B2Vec2();
		m_id = new B2ContactID();
		reset();
	}

	public function set(m:B2ManifoldPoint) {
		Set(m);
	}

	public function reset() {
		Reset();
	}

	public function Set(m:B2ManifoldPoint) {
		m_localPoint.setV(m.m_localPoint);
		m_normalImpulse = m.m_normalImpulse;
		m_tangentImpulse = m.m_tangentImpulse;
		m_id.set(m.m_id);
	}

	public function Reset() {
		m_localPoint.setZero();
		m_normalImpulse = 0;
		m_tangentImpulse = 0;
		m_id.set_key(0);
	}
}
