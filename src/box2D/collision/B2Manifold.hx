package box2D.collision;

import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.collision.B2ManifoldType;
import flash.Boot;

class B2Manifold {
	public var m_type:B2ManifoldType;

	public var m_points:Array<ASAny>;

	public var m_pointCount:Int = 0;

	public var m_localPoint:B2Vec2;

	public var m_localPlaneNormal:B2Vec2;

	public function new() {
		var _loc3_ = 0;
		if (Boot.skip_constructor) {
			return;
		}
		m_pointCount = 0;
		m_points = [];
		var _loc1_ = 0;
		var _loc2_ = B2Settings.b2_maxManifoldPoints;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			m_points[_loc3_] = new B2ManifoldPoint();
		}
		m_localPlaneNormal = new B2Vec2();
		m_localPoint = new B2Vec2();
	}

	public function set(m:B2Manifold) {
		Set(m);
	}

	public function reset() {
		Reset();
	}

	public function copy():B2Manifold {
		return Copy();
	}

	public function Set(m:B2Manifold) {
		var _loc4_ = 0;
		m_pointCount = m.m_pointCount;
		var _loc2_ = 0;
		var _loc3_ = B2Settings.b2_maxManifoldPoints;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			m_points[_loc4_].set(m.m_points[_loc4_]);
		}
		m_localPlaneNormal.setV(m.m_localPlaneNormal);
		m_localPoint.setV(m.m_localPoint);
		m_type = m.m_type;
	}

	public function Reset() {
		var _loc3_ = 0;
		var _loc1_ = 0;
		var _loc2_ = B2Settings.b2_maxManifoldPoints;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			m_points[_loc3_].reset();
		}
		m_localPlaneNormal.setZero();
		m_localPoint.setZero();
		m_type = B2ManifoldType.CIRCLES;
		m_pointCount = 0;
	}

	public function Copy():B2Manifold {
		var _loc1_ = new B2Manifold();
		_loc1_.set(this);
		return _loc1_;
	}
}
