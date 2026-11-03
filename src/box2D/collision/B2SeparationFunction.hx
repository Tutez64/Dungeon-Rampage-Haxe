package box2D.collision;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.collision.B2SeparationFunctionType;
import flash.Boot;

class B2SeparationFunction {
	public var m_type:B2SeparationFunctionType;

	public var m_proxyB:B2DistanceProxy;

	public var m_proxyA:B2DistanceProxy;

	public var m_localPoint:B2Vec2;

	public var m_axis:B2Vec2;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_localPoint = new B2Vec2();
		m_axis = new B2Vec2();
	}

	public function initialize(cache:B2SimplexCache, proxyA:B2DistanceProxy, transformA:B2Transform, proxyB:B2DistanceProxy, transformB:B2Transform) {
		Initialize(cache, proxyA, transformA, proxyB, transformB);
	}

	public function evaluate(transformA:B2Transform, transformB:B2Transform):Float {
		return Evaluate(transformA, transformB);
	}

	public function Initialize(cache:B2SimplexCache, proxyA:B2DistanceProxy, transformA:B2Transform, proxyB:B2DistanceProxy, transformB:B2Transform) {
		var _loc8_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc9_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc11_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc12_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc19_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc20_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc24_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc25_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc26_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc27_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc29_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc30_ = Math.NaN;
		var _loc31_ = Math.NaN;
		var _loc32_ = Math.NaN;
		var _loc33_ = Math.NaN;
		var _loc34_ = Math.NaN;
		m_proxyA = proxyA;
		m_proxyB = proxyB;
		var _loc6_ = cache.count;
		B2Settings.b2Assert(0 < _loc6_ && _loc6_ < 3);
		var _loc7_ = new B2Vec2();
		var _loc10_ = new B2Vec2();
		if (_loc6_ == 1) {
			m_type = B2SeparationFunctionType.POINTS;
			_loc7_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[0]));
			_loc10_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[0]));
			_loc20_ = _loc7_;
			_loc19_ = transformA.R;
			_loc13_ = transformA.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc14_ = transformA.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			_loc20_ = _loc10_;
			_loc19_ = transformB.R;
			_loc15_ = transformB.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc16_ = transformB.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			m_axis.x = _loc15_ - _loc13_;
			m_axis.y = _loc16_ - _loc14_;
			m_axis.normalize();
		} else if (ASCompat.toInt(cache.indexB[0]) == ASCompat.toInt(cache.indexB[1])) {
			m_type = B2SeparationFunctionType.FACE_A;
			_loc8_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[0]));
			_loc9_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[1]));
			_loc10_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[0]));
			m_localPoint.x = 0.5 * ASCompat.toNumber(_loc8_.x + _loc9_.x);
			m_localPoint.y = 0.5 * ASCompat.toNumber(_loc8_.y + _loc9_.y);
			m_axis = B2Math.crossVF(B2Math.subtractVV(_loc9_, _loc8_), 1);
			m_axis.normalize();
			_loc20_ = m_axis;
			_loc19_ = transformA.R;
			_loc17_ = ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
				+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y");
			_loc18_ = ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
				+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y");
			_loc20_ = m_localPoint;
			_loc19_ = transformA.R;
			_loc13_ = transformA.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc14_ = transformA.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			_loc20_ = _loc10_;
			_loc19_ = transformB.R;
			_loc15_ = transformB.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc16_ = transformB.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			_loc21_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
			if (_loc21_ < 0) {
				m_axis.negativeSelf();
			}
		} else if (ASCompat.toInt(cache.indexA[0]) == ASCompat.toInt(cache.indexA[0])) {
			m_type = B2SeparationFunctionType.FACE_B;
			_loc11_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[0]));
			_loc12_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[1]));
			_loc7_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[0]));
			m_localPoint.x = 0.5 * ASCompat.toNumber(_loc11_.x + _loc12_.x);
			m_localPoint.y = 0.5 * ASCompat.toNumber(_loc11_.y + _loc12_.y);
			m_axis = B2Math.crossVF(B2Math.subtractVV(_loc12_, _loc11_), 1);
			m_axis.normalize();
			_loc20_ = m_axis;
			_loc19_ = transformB.R;
			_loc17_ = ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
				+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y");
			_loc18_ = ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
				+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y");
			_loc20_ = m_localPoint;
			_loc19_ = transformB.R;
			_loc15_ = transformB.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc16_ = transformB.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			_loc20_ = _loc7_;
			_loc19_ = transformA.R;
			_loc13_ = transformA.position.x
				+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
			_loc14_ = transformA.position.y
				+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
			_loc21_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
			if (_loc21_ < 0) {
				m_axis.negativeSelf();
			}
		} else {
			_loc8_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[0]));
			_loc9_ = m_proxyA.getVertex(ASCompat.toInt(cache.indexA[1]));
			_loc11_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[0]));
			_loc12_ = m_proxyB.getVertex(ASCompat.toInt(cache.indexB[1]));
			_loc23_ = B2Math.mulX(transformA, _loc7_);
			_loc24_ = B2Math.mulMV(transformA.R, B2Math.subtractVV(_loc9_, _loc8_));
			_loc25_ = B2Math.mulX(transformB, _loc10_);
			_loc26_ = B2Math.mulMV(transformB.R, B2Math.subtractVV(_loc12_, _loc11_));
			_loc27_ = ASCompat.toNumberField(_loc24_, "x") * ASCompat.toNumberField(_loc24_, "x")
				+ ASCompat.toNumberField(_loc24_, "y") * ASCompat.toNumberField(_loc24_, "y");
			_loc28_ = ASCompat.toNumberField(_loc26_, "x") * ASCompat.toNumberField(_loc26_, "x")
				+ ASCompat.toNumberField(_loc26_, "y") * ASCompat.toNumberField(_loc26_, "y");
			_loc29_ = B2Math.subtractVV(_loc26_, _loc24_);
			_loc30_ = ASCompat.toNumberField(_loc24_, "x") * ASCompat.toNumberField(_loc29_, "x")
				+ ASCompat.toNumberField(_loc24_, "y") * ASCompat.toNumberField(_loc29_, "y");
			_loc31_ = ASCompat.toNumberField(_loc26_, "x") * ASCompat.toNumberField(_loc29_, "x")
				+ ASCompat.toNumberField(_loc26_, "y") * ASCompat.toNumberField(_loc29_, "y");
			_loc32_ = ASCompat.toNumberField(_loc24_, "x") * ASCompat.toNumberField(_loc26_, "x")
				+ ASCompat.toNumberField(_loc24_, "y") * ASCompat.toNumberField(_loc26_, "y");
			_loc33_ = _loc27_ * _loc28_ - _loc32_ * _loc32_;
			_loc21_ = 0;
			if (_loc33_ != 0) {
				_loc21_ = B2Math.clamp((_loc32_ * _loc31_ - _loc30_ * _loc28_) / _loc33_, 0, 1);
			}
			_loc34_ = (_loc32_ * _loc21_ + _loc31_) / _loc28_;
			if (_loc34_ < 0) {
				_loc34_ = 0;
				_loc21_ = B2Math.clamp((_loc32_ - _loc30_) / _loc27_, 0, 1);
			}
			_loc7_ = new B2Vec2();
			_loc7_.x = ASCompat.toNumber(_loc8_.x + _loc21_ * (ASCompat.toNumberField(_loc9_, "x") - ASCompat.toNumberField(_loc8_, "x")));
			_loc7_.y = ASCompat.toNumber(_loc8_.y + _loc21_ * (ASCompat.toNumberField(_loc9_, "y") - ASCompat.toNumberField(_loc8_, "y")));
			_loc10_ = new B2Vec2();
			_loc10_.x = ASCompat.toNumber(_loc11_.x + _loc21_ * (ASCompat.toNumberField(_loc12_, "x") - ASCompat.toNumberField(_loc11_, "x")));
			_loc10_.y = ASCompat.toNumber(_loc11_.y + _loc21_ * (ASCompat.toNumberField(_loc12_, "y") - ASCompat.toNumberField(_loc11_, "y")));
			if (_loc21_ == 0 || _loc21_ == 1) {
				m_type = B2SeparationFunctionType.FACE_B;
				m_axis = B2Math.crossVF(B2Math.subtractVV(_loc12_, _loc11_), 1);
				m_axis.normalize();
				m_localPoint = _loc10_;
				_loc20_ = m_axis;
				_loc19_ = transformB.R;
				_loc17_ = ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y");
				_loc18_ = ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y");
				_loc20_ = m_localPoint;
				_loc19_ = transformB.R;
				_loc15_ = transformB.position.x
					+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
				_loc16_ = transformB.position.y
					+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
				_loc20_ = _loc7_;
				_loc19_ = transformA.R;
				_loc13_ = transformA.position.x
					+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
				_loc14_ = transformA.position.y
					+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
				_loc22_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
				if (_loc21_ < 0) {
					m_axis.negativeSelf();
				}
			} else {
				m_type = B2SeparationFunctionType.FACE_A;
				m_axis = B2Math.crossVF(B2Math.subtractVV(_loc9_, _loc8_), 1);
				m_localPoint = _loc7_;
				_loc20_ = m_axis;
				_loc19_ = transformA.R;
				_loc17_ = ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y");
				_loc18_ = ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
					+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y");
				_loc20_ = m_localPoint;
				_loc19_ = transformA.R;
				_loc13_ = transformA.position.x
					+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
				_loc14_ = transformA.position.y
					+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
				_loc20_ = _loc10_;
				_loc19_ = transformB.R;
				_loc15_ = transformB.position.x
					+ (ASCompat.toNumberField(_loc19_.col1, "x") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "x") * ASCompat.toNumberField(_loc20_, "y"));
				_loc16_ = transformB.position.y
					+ (ASCompat.toNumberField(_loc19_.col1, "y") * ASCompat.toNumberField(_loc20_, "x")
						+ ASCompat.toNumberField(_loc19_.col2, "y") * ASCompat.toNumberField(_loc20_, "y"));
				_loc22_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
				if (_loc21_ < 0) {
					m_axis.negativeSelf();
				}
			}
		}
	}

	public function Evaluate(transformA:B2Transform, transformB:B2Transform):Float {
		var _loc3_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc4_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc5_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc6_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc7_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc8_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc9_ = Math.NaN;
		var _loc10_ = ASCompat.dynamicAs(null, B2Vec2);
		switch (m_type.index) {
			case 0:
				_loc3_ = B2Math.mulTMV(transformA.R, m_axis);
				_loc4_ = B2Math.mulTMV(transformB.R, m_axis.getNegative());
				_loc5_ = m_proxyA.getSupportVertex(_loc3_);
				_loc6_ = m_proxyB.getSupportVertex(_loc4_);
				_loc7_ = B2Math.mulX(transformA, _loc5_);
				_loc8_ = B2Math.mulX(transformB, _loc6_);
				return (ASCompat.toNumberField(_loc8_, "x")
					- ASCompat.toNumberField(_loc7_, "x")) * m_axis.x
					+ (ASCompat.toNumberField(_loc8_, "y") - ASCompat.toNumberField(_loc7_, "y")) * m_axis.y;
			case 1:
				_loc10_ = B2Math.mulMV(transformA.R, m_axis);
				_loc7_ = B2Math.mulX(transformA, m_localPoint);
				_loc4_ = B2Math.mulTMV(transformB.R, ASCompat.coerce(_loc10_.getNegative(), box2D.common.math.B2Vec2));
				_loc6_ = m_proxyB.getSupportVertex(_loc4_);
				_loc8_ = B2Math.mulX(transformB, _loc6_);
				return (ASCompat.toNumberField(_loc8_, "x")
					- ASCompat.toNumberField(_loc7_, "x")) * ASCompat.toNumberField(_loc10_, "x")
					+ (ASCompat.toNumberField(_loc8_, "y") - ASCompat.toNumberField(_loc7_, "y")) * ASCompat.toNumberField(_loc10_, "y");
			case 2:
				_loc10_ = B2Math.mulMV(transformB.R, m_axis);
				_loc8_ = B2Math.mulX(transformB, m_localPoint);
				_loc3_ = B2Math.mulTMV(transformA.R, ASCompat.coerce(_loc10_.getNegative(), box2D.common.math.B2Vec2));
				_loc5_ = m_proxyA.getSupportVertex(_loc3_);
				_loc7_ = B2Math.mulX(transformA, _loc5_);
				return (ASCompat.toNumberField(_loc7_, "x")
					- ASCompat.toNumberField(_loc8_, "x")) * ASCompat.toNumberField(_loc10_, "x")
					+ (ASCompat.toNumberField(_loc7_, "y") - ASCompat.toNumberField(_loc8_, "y")) * ASCompat.toNumberField(_loc10_, "y");
			default:
				return ASCompat.toNumber(/*undefined*/ null);
		}
		return Math.NaN;
	}
}
