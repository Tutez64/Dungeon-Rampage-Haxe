package box2D.dynamics.contacts;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

class B2PositionSolverManifold {
	public static var circlePointA:B2Vec2 = new B2Vec2();

	public static var circlePointB:B2Vec2 = new B2Vec2();

	public var m_separations:Array<ASAny>;

	public var m_points:Array<ASAny>;

	public var m_normal:B2Vec2;

	public function new() {
		var _loc3_ = 0;
		m_normal = new B2Vec2();
		m_separations = [];
		m_points = [];
		var _loc1_ = 0;
		var _loc2_ = B2Settings.b2_maxManifoldPoints;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			m_points[_loc3_] = new B2Vec2();
		}
	}

	public function initialize(cc:B2ContactConstraint) {
		Initialize(cc);
	}

	public function Initialize(cc:B2ContactConstraint) {
		var _loc3_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc5_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc7_ = Math.NaN;
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
		var _loc18_ = 0;
		var _loc19_ = 0;
		B2Settings.b2Assert(cc.pointCount > 0);
		switch (cc.type.index) {
			case 0:
				_loc5_ = cc.bodyA.m_xf.R;
				_loc6_ = cc.localPoint;
				_loc9_ = cc.bodyA.m_xf.position.x
					+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
				_loc10_ = cc.bodyA.m_xf.position.y
					+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
				_loc5_ = cc.bodyB.m_xf.R;
				_loc6_ = cc.points[0].localPoint;
				_loc11_ = cc.bodyB.m_xf.position.x
					+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
				_loc12_ = cc.bodyB.m_xf.position.y
					+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
				_loc13_ = _loc11_ - _loc9_;
				_loc14_ = _loc12_ - _loc10_;
				_loc15_ = _loc13_ * _loc13_ + _loc14_ * _loc14_;
				if (_loc15_ > ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT) {
					_loc16_ = Math.sqrt(_loc15_);
					m_normal.x = _loc13_ / _loc16_;
					m_normal.y = _loc14_ / _loc16_;
				} else {
					m_normal.x = 1;
					m_normal.y = 0;
				}
				ASCompat.setProperty(m_points[0], "x", 0.5 * (_loc9_ + _loc11_));
				ASCompat.setProperty(m_points[0], "y", 0.5 * (_loc10_ + _loc12_));
				m_separations[0] = _loc13_ * m_normal.x + _loc14_ * m_normal.y - cc.radius;

			case 1:
				_loc5_ = cc.bodyA.m_xf.R;
				_loc6_ = cc.localPlaneNormal;
				m_normal.x = ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
					+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y");
				m_normal.y = ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
					+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y");
				_loc5_ = cc.bodyA.m_xf.R;
				_loc6_ = cc.localPoint;
				_loc7_ = cc.bodyA.m_xf.position.x
					+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
				_loc8_ = cc.bodyA.m_xf.position.y
					+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
				_loc5_ = cc.bodyB.m_xf.R;
				_loc17_ = 0;
				_loc18_ = cc.pointCount;
				while (_loc17_ < _loc18_) {
					_loc19_ = _loc17_++;
					_loc6_ = cc.points[_loc19_].localPoint;
					_loc3_ = cc.bodyB.m_xf.position.x
						+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
							+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
					_loc4_ = cc.bodyB.m_xf.position.y
						+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
							+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
					m_separations[_loc19_] = (_loc3_ - _loc7_) * m_normal.x + (_loc4_ - _loc8_) * m_normal.y - cc.radius;
					ASCompat.setProperty(m_points[_loc19_], "x", _loc3_);
					ASCompat.setProperty(m_points[_loc19_], "y", _loc4_);
				}

			case 2:
				_loc5_ = cc.bodyB.m_xf.R;
				_loc6_ = cc.localPlaneNormal;
				m_normal.x = ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
					+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y");
				m_normal.y = ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
					+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y");
				_loc5_ = cc.bodyB.m_xf.R;
				_loc6_ = cc.localPoint;
				_loc7_ = cc.bodyB.m_xf.position.x
					+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
				_loc8_ = cc.bodyB.m_xf.position.y
					+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
						+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
				_loc5_ = cc.bodyA.m_xf.R;
				_loc17_ = 0;
				_loc18_ = cc.pointCount;
				while (_loc17_ < _loc18_) {
					_loc19_ = _loc17_++;
					_loc6_ = cc.points[_loc19_].localPoint;
					_loc3_ = cc.bodyA.m_xf.position.x
						+ (ASCompat.toNumberField(_loc5_.col1, "x") * ASCompat.toNumberField(_loc6_, "x")
							+ ASCompat.toNumberField(_loc5_.col2, "x") * ASCompat.toNumberField(_loc6_, "y"));
					_loc4_ = cc.bodyA.m_xf.position.y
						+ (ASCompat.toNumberField(_loc5_.col1, "y") * ASCompat.toNumberField(_loc6_, "x")
							+ ASCompat.toNumberField(_loc5_.col2, "y") * ASCompat.toNumberField(_loc6_, "y"));
					m_separations[_loc19_] = (_loc3_ - _loc7_) * m_normal.x + (_loc4_ - _loc8_) * m_normal.y - cc.radius;
					m_points[_loc19_].set(_loc3_, _loc4_);
				}
				m_normal.x *= -1;
				m_normal.y *= -1;
		}
	}
}
