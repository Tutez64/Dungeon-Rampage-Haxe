package box2D.collision;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import flash.Boot;

class B2WorldManifold {
	public var m_points:Array<ASAny>;

	public var m_normal:B2Vec2;

	public function new() {
		var _loc3_ = 0;
		if (Boot.skip_constructor) {
			return;
		}
		m_normal = new B2Vec2();
		m_points = [];
		var _loc1_ = 0;
		var _loc2_ = B2Settings.b2_maxManifoldPoints;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			m_points[_loc3_] = new B2Vec2();
		}
	}

	public function initialize(manifold:B2Manifold, xfA:B2Transform, radiusA:Float, xfB:B2Transform, radiusB:Float) {
		Initialize(manifold, xfA, radiusA, xfB, radiusB);
	}

	public function Initialize(manifold:B2Manifold, xfA:B2Transform, radiusA:Float, xfB:B2Transform, radiusB:Float) {
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc8_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
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
		var _loc26_ = 0;
		var _loc27_ = 0;
		var _loc28_ = 0;
		if (manifold.m_pointCount == 0) {
			return;
		}
		switch (manifold.m_type.index) {
			case 0:
				_loc8_ = xfA.R;
				_loc7_ = manifold.m_localPoint;
				_loc15_ = xfA.position.x
					+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc16_ = xfA.position.y
					+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				_loc8_ = xfB.R;
				_loc7_ = manifold.m_points[0].m_localPoint;
				_loc17_ = xfB.position.x
					+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc18_ = xfB.position.y
					+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				_loc19_ = _loc17_ - _loc15_;
				_loc20_ = _loc18_ - _loc16_;
				_loc21_ = _loc19_ * _loc19_ + _loc20_ * _loc20_;
				if (_loc21_ > ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT) {
					_loc22_ = Math.sqrt(_loc21_);
					m_normal.x = _loc19_ / _loc22_;
					m_normal.y = _loc20_ / _loc22_;
				} else {
					m_normal.x = 1;
					m_normal.y = 0;
				}
				_loc22_ = _loc15_ + radiusA * m_normal.x;
				_loc23_ = _loc16_ + radiusA * m_normal.y;
				_loc24_ = _loc17_ - radiusB * m_normal.x;
				_loc25_ = _loc18_ - radiusB * m_normal.y;
				ASCompat.setProperty(m_points[0], "x", 0.5 * (_loc22_ + _loc24_));
				ASCompat.setProperty(m_points[0], "y", 0.5 * (_loc23_ + _loc25_));

			case 1:
				_loc8_ = xfA.R;
				_loc7_ = manifold.m_localPlaneNormal;
				_loc9_ = ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc10_ = ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				_loc8_ = xfA.R;
				_loc7_ = manifold.m_localPoint;
				_loc11_ = xfA.position.x
					+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc12_ = xfA.position.y
					+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				m_normal.x = _loc9_;
				m_normal.y = _loc10_;
				_loc26_ = 0;
				_loc27_ = manifold.m_pointCount;
				while (_loc26_ < _loc27_) {
					_loc28_ = _loc26_++;
					_loc8_ = xfB.R;
					_loc7_ = manifold.m_points[_loc28_].m_localPoint;
					_loc13_ = xfB.position.x
						+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
						+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
					_loc14_ = xfB.position.y
						+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
						+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
					ASCompat.setProperty(m_points[_loc28_], "x",
						_loc13_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc9_);
					ASCompat.setProperty(m_points[_loc28_], "y",
						_loc14_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc10_);
				}

			case 2:
				_loc8_ = xfB.R;
				_loc7_ = manifold.m_localPlaneNormal;
				_loc9_ = ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc10_ = ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				_loc8_ = xfB.R;
				_loc7_ = manifold.m_localPoint;
				_loc11_ = xfB.position.x
					+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
				_loc12_ = xfB.position.y
					+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
					+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
				m_normal.x = -_loc9_;
				m_normal.y = -_loc10_;
				_loc26_ = 0;
				_loc27_ = manifold.m_pointCount;
				while (_loc26_ < _loc27_) {
					_loc28_ = _loc26_++;
					_loc8_ = xfA.R;
					_loc7_ = manifold.m_points[_loc28_].m_localPoint;
					_loc13_ = xfA.position.x
						+ ASCompat.toNumberField(_loc8_.col1, "x") * ASCompat.toNumberField(_loc7_, "x")
						+ ASCompat.toNumberField(_loc8_.col2, "x") * ASCompat.toNumberField(_loc7_, "y");
					_loc14_ = xfA.position.y
						+ ASCompat.toNumberField(_loc8_.col1, "y") * ASCompat.toNumberField(_loc7_, "x")
						+ ASCompat.toNumberField(_loc8_.col2, "y") * ASCompat.toNumberField(_loc7_, "y");
					ASCompat.setProperty(m_points[_loc28_], "x",
						_loc13_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc9_);
					ASCompat.setProperty(m_points[_loc28_], "y",
						_loc14_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc10_);
				}
		}
	}
}
