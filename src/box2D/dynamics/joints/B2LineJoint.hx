package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2TimeStep;
import flash.Boot;

class B2LineJoint extends B2Joint {
	public var m_upperTranslation:Float = Math.NaN;

	public var m_s2:Float = Math.NaN;

	public var m_s1:Float = Math.NaN;

	public var m_perp:B2Vec2;

	public var m_motorSpeed:Float = Math.NaN;

	public var m_motorMass:Float = Math.NaN;

	public var m_motorImpulse:Float = Math.NaN;

	public var m_maxMotorForce:Float = Math.NaN;

	public var m_lowerTranslation:Float = Math.NaN;

	public var m_localYAxis1:B2Vec2;

	public var m_localXAxis1:B2Vec2;

	public var m_localAnchor2:B2Vec2;

	public var m_localAnchor1:B2Vec2;

	public var m_limitState:Int = 0;

	public var m_impulse:B2Vec2;

	public var m_enableMotor:Bool = false;

	public var m_enableLimit:Bool = false;

	public var m_axis:B2Vec2;

	public var m_a2:Float = Math.NaN;

	public var m_a1:Float = Math.NaN;

	public var m_K:B2Mat22;

	public function new(def:B2LineJointDef = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(def);
			m_localAnchor1 = new B2Vec2();
			m_localAnchor2 = new B2Vec2();
			m_localXAxis1 = new B2Vec2();
			m_localYAxis1 = new B2Vec2();
			m_axis = new B2Vec2();
			m_perp = new B2Vec2();
			m_K = new B2Mat22();
			m_impulse = new B2Vec2();
			m_localAnchor1.setV(def.localAnchorA);
			m_localAnchor2.setV(def.localAnchorB);
			m_localXAxis1.setV(def.localAxisA);
			m_localYAxis1.x = -m_localXAxis1.y;
			m_localYAxis1.y = m_localXAxis1.x;
			m_impulse.setZero();
			m_motorMass = 0;
			m_motorImpulse = 0;
			m_lowerTranslation = def.lowerTranslation;
			m_upperTranslation = def.upperTranslation;
			m_maxMotorForce = def.maxMotorForce;
			m_motorSpeed = def.motorSpeed;
			m_enableLimit = def.enableLimit;
			m_enableMotor = def.enableMotor;
			m_limitState = 0;
			m_axis.setZero();
			m_perp.setZero();
		}
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setMotorSpeed(speed:Float) {
		SetMotorSpeed(speed);
	}

	public function setMaxMotorForce(force:Float) {
		SetMaxMotorForce(force);
	}

	public function setLimits(lower:Float, upper:Float) {
		SetLimits(lower, upper);
	}

	public function isMotorEnabled():Bool {
		return IsMotorEnabled();
	}

	public function isLimitEnabled():Bool {
		return IsLimitEnabled();
	}

	override public function initVelocityConstraints(step:B2TimeStep) {
		InitVelocityConstraints(step);
	}

	public function getUpperLimit():Float {
		return GetUpperLimit();
	}

	override public function getReactionTorque(inv_dt:Float):Float {
		return GetReactionTorque(inv_dt);
	}

	override public function getReactionForce(inv_dt:Float):B2Vec2 {
		return GetReactionForce(inv_dt);
	}

	public function getMotorSpeed():Float {
		return GetMotorSpeed();
	}

	public function getMotorForce():Float {
		return GetMotorForce();
	}

	public function getMaxMotorForce():Float {
		return GetMaxMotorForce();
	}

	public function getLowerLimit():Float {
		return GetLowerLimit();
	}

	public function getJointTranslation():Float {
		return GetJointTranslation();
	}

	public function getJointSpeed():Float {
		return GetJointSpeed();
	}

	override public function getAnchorB():B2Vec2 {
		return GetAnchorB();
	}

	override public function getAnchorA():B2Vec2 {
		return GetAnchorA();
	}

	public function enableMotor(flag:Bool) {
		EnableMotor(flag);
	}

	public function enableLimit(flag:Bool) {
		EnableLimit(flag);
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc17_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = _loc2_.m_linearVelocity;
		var _loc5_ = _loc2_.m_angularVelocity;
		var _loc6_ = _loc3_.m_linearVelocity;
		var _loc7_ = _loc3_.m_angularVelocity;
		if (m_enableMotor && m_limitState != 3) {
			_loc12_ = m_axis.x * (_loc6_.x - _loc4_.x) + m_axis.y * (_loc6_.y - _loc4_.y) + m_a2 * _loc7_ - m_a1 * _loc5_;
			_loc13_ = m_motorMass * (m_motorSpeed - _loc12_);
			_loc14_ = m_motorImpulse;
			_loc15_ = step.dt * m_maxMotorForce;
			m_motorImpulse = B2Math.clamp(m_motorImpulse + _loc13_, -_loc15_, _loc15_);
			_loc13_ = m_motorImpulse - _loc14_;
			_loc8_ = _loc13_ * m_axis.x;
			_loc9_ = _loc13_ * m_axis.y;
			_loc10_ = _loc13_ * m_a1;
			_loc11_ = _loc13_ * m_a2;
			_loc4_.x -= m_invMassA * _loc8_;
			_loc4_.y -= m_invMassA * _loc9_;
			_loc5_ -= m_invIA * _loc10_;
			_loc6_.x += m_invMassB * _loc8_;
			_loc6_.y += m_invMassB * _loc9_;
			_loc7_ += m_invIB * _loc11_;
		}
		_loc12_ = m_perp.x * (_loc6_.x - _loc4_.x) + m_perp.y * (_loc6_.y - _loc4_.y) + m_s2 * _loc7_ - m_s1 * _loc5_;
		if (m_enableLimit && m_limitState != 0) {
			_loc13_ = m_axis.x * (_loc6_.x - _loc4_.x) + m_axis.y * (_loc6_.y - _loc4_.y) + m_a2 * _loc7_ - m_a1 * _loc5_;
			_loc16_ = m_impulse.copy();
			_loc17_ = m_K.solve(new B2Vec2(), -_loc12_, -_loc13_);
			m_impulse.add(_loc17_);
			if (m_limitState == 1) {
				m_impulse.y = B2Math.max(m_impulse.y, 0);
			} else if (m_limitState == 2) {
				m_impulse.y = B2Math.min(m_impulse.y, 0);
			}
			_loc14_ = -_loc12_ - (m_impulse.y - ASCompat.toNumberField(_loc16_, "y")) * m_K.col2.x;
			if (m_K.col1.x != 0) {
				_loc15_ = ASCompat.toNumber(_loc14_ / m_K.col1.x + _loc16_.x);
			} else {
				_loc15_ = ASCompat.toNumberField(_loc16_, "x");
			}
			m_impulse.x = _loc15_;
			ASCompat.setProperty(_loc17_, "x", m_impulse.x - ASCompat.toNumberField(_loc16_, "x"));
			ASCompat.setProperty(_loc17_, "y", m_impulse.y - ASCompat.toNumberField(_loc16_, "y"));
			_loc8_ = ASCompat.toNumberField(_loc17_, "x") * m_perp.x + ASCompat.toNumberField(_loc17_, "y") * m_axis.x;
			_loc9_ = ASCompat.toNumberField(_loc17_, "x") * m_perp.y + ASCompat.toNumberField(_loc17_, "y") * m_axis.y;
			_loc10_ = ASCompat.toNumberField(_loc17_, "x") * m_s1 + ASCompat.toNumberField(_loc17_, "y") * m_a1;
			_loc11_ = ASCompat.toNumberField(_loc17_, "x") * m_s2 + ASCompat.toNumberField(_loc17_, "y") * m_a2;
			_loc4_.x -= m_invMassA * _loc8_;
			_loc4_.y -= m_invMassA * _loc9_;
			_loc5_ -= m_invIA * _loc10_;
			_loc6_.x += m_invMassB * _loc8_;
			_loc6_.y += m_invMassB * _loc9_;
			_loc7_ += m_invIB * _loc11_;
		} else {
			if (m_K.col1.x != 0) {
				_loc13_ = -_loc12_ / m_K.col1.x;
			} else {
				_loc13_ = 0;
			}
			m_impulse.x += _loc13_;
			_loc8_ = _loc13_ * m_perp.x;
			_loc9_ = _loc13_ * m_perp.y;
			_loc10_ = _loc13_ * m_s1;
			_loc11_ = _loc13_ * m_s2;
			_loc4_.x -= m_invMassA * _loc8_;
			_loc4_.y -= m_invMassA * _loc9_;
			_loc5_ -= m_invIA * _loc10_;
			_loc6_.x += m_invMassB * _loc8_;
			_loc6_.y += m_invMassB * _loc9_;
			_loc7_ += m_invIB * _loc11_;
		}
		_loc2_.m_linearVelocity.setV(_loc4_);
		_loc2_.m_angularVelocity = _loc5_;
		_loc3_.m_linearVelocity.setV(_loc6_);
		_loc3_.m_angularVelocity = _loc7_;
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc30_ = Math.NaN;
		var _loc31_ = Math.NaN;
		var _loc4_ = m_bodyA;
		var _loc5_ = m_bodyB;
		var _loc6_ = _loc4_.m_sweep.c;
		var _loc7_ = _loc4_.m_sweep.a;
		var _loc8_ = _loc5_.m_sweep.c;
		var _loc9_ = _loc5_.m_sweep.a;
		var _loc14_:Float = 0;
		var _loc15_:Float = 0;
		var _loc16_ = false;
		var _loc17_:Float = 0;
		var _loc18_ = B2Mat22.fromAngle(_loc7_);
		var _loc19_ = B2Mat22.fromAngle(_loc9_);
		var _loc20_ = _loc18_;
		var _loc21_ = m_localAnchor1.x - m_localCenterA.x;
		var _loc22_ = m_localAnchor1.y - m_localCenterA.y;
		var _loc23_ = _loc20_.col1.x * _loc21_ + _loc20_.col2.x * _loc22_;
		_loc22_ = _loc20_.col1.y * _loc21_ + _loc20_.col2.y * _loc22_;
		_loc21_ = _loc23_;
		_loc20_ = _loc19_;
		var _loc24_ = m_localAnchor2.x - m_localCenterB.x;
		var _loc25_ = m_localAnchor2.y - m_localCenterB.y;
		_loc23_ = _loc20_.col1.x * _loc24_ + _loc20_.col2.x * _loc25_;
		_loc25_ = _loc20_.col1.y * _loc24_ + _loc20_.col2.y * _loc25_;
		_loc24_ = _loc23_;
		var _loc26_ = _loc8_.x + _loc24_ - _loc6_.x - _loc21_;
		var _loc27_ = _loc8_.y + _loc25_ - _loc6_.y - _loc22_;
		if (m_enableLimit) {
			m_axis = B2Math.mulMV(_loc18_, m_localXAxis1);
			m_a1 = (_loc26_ + _loc21_) * m_axis.y - (_loc27_ + _loc22_) * m_axis.x;
			m_a2 = _loc24_ * m_axis.y - _loc25_ * m_axis.x;
			_loc28_ = m_axis.x * _loc26_ + m_axis.y * _loc27_;
			if (B2Math.abs(m_upperTranslation - m_lowerTranslation) < 2 * B2Settings.b2_linearSlop) {
				_loc17_ = B2Math.clamp(_loc28_, -B2Settings.b2_maxLinearCorrection, B2Settings.b2_maxLinearCorrection);
				_loc14_ = B2Math.abs(_loc28_);
				_loc16_ = true;
			} else if (_loc28_ <= m_lowerTranslation) {
				_loc17_ = B2Math.clamp(_loc28_ - m_lowerTranslation + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0);
				_loc14_ = m_lowerTranslation - _loc28_;
				_loc16_ = true;
			} else if (_loc28_ >= m_upperTranslation) {
				_loc17_ = B2Math.clamp(_loc28_ - m_upperTranslation + B2Settings.b2_linearSlop, 0, B2Settings.b2_maxLinearCorrection);
				_loc14_ = _loc28_ - m_upperTranslation;
				_loc16_ = true;
			}
		}
		m_perp = B2Math.mulMV(_loc18_, m_localYAxis1);
		m_s1 = (_loc26_ + _loc21_) * m_perp.y - (_loc27_ + _loc22_) * m_perp.x;
		m_s2 = _loc24_ * m_perp.y - _loc25_ * m_perp.x;
		var _loc29_ = new B2Vec2();
		_loc28_ = m_perp.x * _loc26_ + m_perp.y * _loc27_;
		_loc14_ = B2Math.max(_loc14_, B2Math.abs(_loc28_));
		_loc15_ = 0;
		if (_loc16_) {
			_loc10_ = m_invMassA;
			_loc11_ = m_invMassB;
			_loc12_ = m_invIA;
			_loc13_ = m_invIB;
			m_K.col1.x = _loc10_ + _loc11_ + _loc12_ * m_s1 * m_s1 + _loc13_ * m_s2 * m_s2;
			m_K.col1.y = _loc12_ * m_s1 * m_a1 + _loc13_ * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
			m_K.col2.y = _loc10_ + _loc11_ + _loc12_ * m_a1 * m_a1 + _loc13_ * m_a2 * m_a2;
			m_K.solve(_loc29_, -_loc28_, -_loc17_);
		} else {
			_loc10_ = m_invMassA;
			_loc11_ = m_invMassB;
			_loc12_ = m_invIA;
			_loc13_ = m_invIB;
			_loc30_ = _loc10_ + _loc11_ + _loc12_ * m_s1 * m_s1 + _loc13_ * m_s2 * m_s2;
			if (_loc30_ != 0) {
				_loc31_ = -_loc28_ / _loc30_;
			} else {
				_loc31_ = 0;
			}
			_loc29_.x = _loc31_;
			_loc29_.y = 0;
		}
		_loc30_ = _loc29_.x * m_perp.x + _loc29_.y * m_axis.x;
		_loc31_ = _loc29_.x * m_perp.y + _loc29_.y * m_axis.y;
		var _loc32_ = _loc29_.x * m_s1 + _loc29_.y * m_a1;
		var _loc33_ = _loc29_.x * m_s2 + _loc29_.y * m_a2;
		_loc6_.x -= m_invMassA * _loc30_;
		_loc6_.y -= m_invMassA * _loc31_;
		_loc7_ -= m_invIA * _loc32_;
		_loc8_.x += m_invMassB * _loc30_;
		_loc8_.y += m_invMassB * _loc31_;
		_loc9_ += m_invIB * _loc33_;
		_loc4_.m_sweep.a = _loc7_;
		_loc5_.m_sweep.a = _loc9_;
		_loc4_.synchronizeTransform();
		_loc5_.synchronizeTransform();
		if (_loc14_ <= B2Settings.b2_linearSlop) {
			return _loc15_ <= B2Settings.b2_angularSlop;
		}
		return false;
	}

	public function SetMotorSpeed(speed:Float) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_motorSpeed = speed;
	}

	public function SetMaxMotorForce(force:Float) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_maxMotorForce = force;
	}

	public function SetLimits(lower:Float, upper:Float) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_lowerTranslation = lower;
		m_upperTranslation = upper;
	}

	public function IsMotorEnabled():Bool {
		return m_enableMotor;
	}

	public function IsLimitEnabled():Bool {
		return m_enableLimit;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		m_localCenterA.setV(_loc2_.getLocalCenter());
		m_localCenterB.setV(_loc3_.getLocalCenter());
		var _loc4_ = _loc2_.getTransform();
		var _loc5_ = _loc3_.getTransform();
		var _loc6_ = _loc2_.m_xf.R;
		var _loc7_ = m_localAnchor1.x - m_localCenterA.x;
		var _loc8_ = m_localAnchor1.y - m_localCenterA.y;
		var _loc9_ = _loc6_.col1.x * _loc7_ + _loc6_.col2.x * _loc8_;
		_loc8_ = _loc6_.col1.y * _loc7_ + _loc6_.col2.y * _loc8_;
		_loc7_ = _loc9_;
		_loc6_ = _loc3_.m_xf.R;
		var _loc10_ = m_localAnchor2.x - m_localCenterB.x;
		var _loc11_ = m_localAnchor2.y - m_localCenterB.y;
		_loc9_ = _loc6_.col1.x * _loc10_ + _loc6_.col2.x * _loc11_;
		_loc11_ = _loc6_.col1.y * _loc10_ + _loc6_.col2.y * _loc11_;
		_loc10_ = _loc9_;
		var _loc12_ = _loc3_.m_sweep.c.x + _loc10_ - _loc2_.m_sweep.c.x - _loc7_;
		var _loc13_ = _loc3_.m_sweep.c.y + _loc11_ - _loc2_.m_sweep.c.y - _loc8_;
		m_invMassA = _loc2_.m_invMass;
		m_invMassB = _loc3_.m_invMass;
		m_invIA = _loc2_.m_invI;
		m_invIB = _loc3_.m_invI;
		m_axis.setV(B2Math.mulMV(_loc4_.R, m_localXAxis1));
		m_a1 = (_loc12_ + _loc7_) * m_axis.y - (_loc13_ + _loc8_) * m_axis.x;
		m_a2 = _loc10_ * m_axis.y - _loc11_ * m_axis.x;
		m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2;
		m_motorMass = m_motorMass > ASCompat.MIN_FLOAT ? 1 / m_motorMass : 0;
		m_perp.setV(B2Math.mulMV(_loc4_.R, m_localYAxis1));
		m_s1 = (_loc12_ + _loc7_) * m_perp.y - (_loc13_ + _loc8_) * m_perp.x;
		m_s2 = _loc10_ * m_perp.y - _loc11_ * m_perp.x;
		_loc14_ = m_invMassA;
		_loc15_ = m_invMassB;
		_loc16_ = m_invIA;
		_loc17_ = m_invIB;
		m_K.col1.x = _loc14_ + _loc15_ + _loc16_ * m_s1 * m_s1 + _loc17_ * m_s2 * m_s2;
		m_K.col1.y = _loc16_ * m_s1 * m_a1 + _loc17_ * m_s2 * m_a2;
		m_K.col2.x = m_K.col1.y;
		m_K.col2.y = _loc14_ + _loc15_ + _loc16_ * m_a1 * m_a1 + _loc17_ * m_a2 * m_a2;
		if (m_enableLimit) {
			_loc14_ = m_axis.x * _loc12_ + m_axis.y * _loc13_;
			if (B2Math.abs(m_upperTranslation - m_lowerTranslation) < 2 * B2Settings.b2_linearSlop) {
				m_limitState = 3;
			} else if (_loc14_ <= m_lowerTranslation) {
				if (m_limitState != 1) {
					m_limitState = 1;
					m_impulse.y = 0;
				}
			} else if (_loc14_ >= m_upperTranslation) {
				if (m_limitState != 2) {
					m_limitState = 2;
					m_impulse.y = 0;
				}
			} else {
				m_limitState = 0;
				m_impulse.y = 0;
			}
		} else {
			m_limitState = 0;
		}
		if (m_enableMotor == false) {
			m_motorImpulse = 0;
		}
		if (step.warmStarting) {
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio;
			_loc14_ = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x;
			_loc15_ = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y;
			_loc16_ = m_impulse.x * m_s1 + (m_motorImpulse + m_impulse.y) * m_a1;
			_loc17_ = m_impulse.x * m_s2 + (m_motorImpulse + m_impulse.y) * m_a2;
			_loc2_.m_linearVelocity.x -= m_invMassA * _loc14_;
			_loc2_.m_linearVelocity.y -= m_invMassA * _loc15_;
			_loc2_.m_angularVelocity -= m_invIA * _loc16_;
			_loc3_.m_linearVelocity.x += m_invMassB * _loc14_;
			_loc3_.m_linearVelocity.y += m_invMassB * _loc15_;
			_loc3_.m_angularVelocity += m_invIB * _loc17_;
		} else {
			m_impulse.setZero();
			m_motorImpulse = 0;
		}
	}

	public function GetUpperLimit():Float {
		return m_upperTranslation;
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return inv_dt * m_impulse.y;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x),
			inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y));
	}

	public function GetMotorSpeed():Float {
		return m_motorSpeed;
	}

	public function GetMotorForce():Float {
		return m_motorImpulse;
	}

	public function GetMaxMotorForce():Float {
		return m_maxMotorForce;
	}

	public function GetLowerLimit():Float {
		return m_lowerTranslation;
	}

	public function GetJointTranslation():Float {
		var _loc1_ = m_bodyA;
		var _loc2_ = m_bodyB;
		var _loc4_ = _loc1_.getWorldPoint(m_localAnchor1);
		var _loc5_ = _loc2_.getWorldPoint(m_localAnchor2);
		var _loc6_ = _loc5_.x - _loc4_.x;
		var _loc7_ = _loc5_.y - _loc4_.y;
		var _loc8_ = _loc1_.getWorldVector(m_localXAxis1);
		return _loc8_.x * _loc6_ + _loc8_.y * _loc7_;
	}

	public function GetJointSpeed():Float {
		var _loc1_ = m_bodyA;
		var _loc2_ = m_bodyB;
		var _loc3_ = _loc1_.m_xf.R;
		var _loc4_ = m_localAnchor1.x - _loc1_.m_sweep.localCenter.x;
		var _loc5_ = m_localAnchor1.y - _loc1_.m_sweep.localCenter.y;
		var _loc6_ = _loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_;
		_loc5_ = _loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_;
		_loc4_ = _loc6_;
		_loc3_ = _loc2_.m_xf.R;
		var _loc7_ = m_localAnchor2.x - _loc2_.m_sweep.localCenter.x;
		var _loc8_ = m_localAnchor2.y - _loc2_.m_sweep.localCenter.y;
		_loc6_ = _loc3_.col1.x * _loc7_ + _loc3_.col2.x * _loc8_;
		_loc8_ = _loc3_.col1.y * _loc7_ + _loc3_.col2.y * _loc8_;
		_loc7_ = _loc6_;
		var _loc9_ = _loc1_.m_sweep.c.x + _loc4_;
		var _loc10_ = _loc1_.m_sweep.c.y + _loc5_;
		var _loc11_ = _loc2_.m_sweep.c.x + _loc7_;
		var _loc12_ = _loc2_.m_sweep.c.y + _loc8_;
		var _loc13_ = _loc11_ - _loc9_;
		var _loc14_ = _loc12_ - _loc10_;
		var _loc15_ = _loc1_.getWorldVector(m_localXAxis1);
		var _loc16_ = _loc1_.m_linearVelocity;
		var _loc17_ = _loc2_.m_linearVelocity;
		var _loc18_ = _loc1_.m_angularVelocity;
		var _loc19_ = _loc2_.m_angularVelocity;
		return _loc13_ * (-_loc18_ * _loc15_.y)
			+ _loc14_ * (_loc18_ * _loc15_.x)
			+ (_loc15_.x * (_loc17_.x + -_loc19_ * _loc8_ - _loc16_.x - -_loc18_ * _loc5_)
				+ _loc15_.y * (_loc17_.y + _loc19_ * _loc7_ - _loc16_.y - _loc18_ * _loc4_));
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}

	public function EnableMotor(flag:Bool) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_enableMotor = flag;
	}

	public function EnableLimit(flag:Bool) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_enableLimit = flag;
	}
}
