package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;
import flash.Boot;

class B2PulleyJoint extends B2Joint {
	public static var b2_minPulleyLength:Float = 2;

	public var m_u2:B2Vec2;

	public var m_u1:B2Vec2;

	public var m_state:Int = 0;

	public var m_ratio:Float = Math.NaN;

	public var m_pulleyMass:Float = Math.NaN;

	public var m_maxLength2:Float = Math.NaN;

	public var m_maxLength1:Float = Math.NaN;

	public var m_localAnchor2:B2Vec2;

	public var m_localAnchor1:B2Vec2;

	public var m_limitState2:Int = 0;

	public var m_limitState1:Int = 0;

	public var m_limitMass2:Float = Math.NaN;

	public var m_limitMass1:Float = Math.NaN;

	public var m_limitImpulse2:Float = Math.NaN;

	public var m_limitImpulse1:Float = Math.NaN;

	public var m_impulse:Float = Math.NaN;

	public var m_groundAnchor2:B2Vec2;

	public var m_groundAnchor1:B2Vec2;

	public var m_ground:B2Body;

	public var m_constant:Float = Math.NaN;

	public function new(def:B2PulleyJointDef = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(def);
			m_groundAnchor1 = new B2Vec2();
			m_groundAnchor2 = new B2Vec2();
			m_localAnchor1 = new B2Vec2();
			m_localAnchor2 = new B2Vec2();
			m_u1 = new B2Vec2();
			m_u2 = new B2Vec2();
			m_ground = m_bodyA.m_world.m_groundBody;
			m_groundAnchor1.x = def.groundAnchorA.x - m_ground.m_xf.position.x;
			m_groundAnchor1.y = def.groundAnchorA.y - m_ground.m_xf.position.y;
			m_groundAnchor2.x = def.groundAnchorB.x - m_ground.m_xf.position.x;
			m_groundAnchor2.y = def.groundAnchorB.y - m_ground.m_xf.position.y;
			m_localAnchor1.setV(def.localAnchorA);
			m_localAnchor2.setV(def.localAnchorB);
			m_ratio = def.ratio;
			m_constant = def.lengthA + m_ratio * def.lengthB;
			m_maxLength1 = B2Math.min(def.maxLengthA, m_constant - m_ratio * B2PulleyJoint.b2_minPulleyLength);
			m_maxLength2 = B2Math.min(def.maxLengthB, (m_constant - B2PulleyJoint.b2_minPulleyLength) / m_ratio);
			m_impulse = 0;
			m_limitImpulse1 = 0;
			m_limitImpulse2 = 0;
		}
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	override public function initVelocityConstraints(step:B2TimeStep) {
		InitVelocityConstraints(step);
	}

	override public function getReactionTorque(inv_dt:Float):Float {
		return GetReactionTorque(inv_dt);
	}

	override public function getReactionForce(inv_dt:Float):B2Vec2 {
		return GetReactionForce(inv_dt);
	}

	public function getRatio():Float {
		return GetRatio();
	}

	public function getLength2():Float {
		return GetLength2();
	}

	public function getLength1():Float {
		return GetLength1();
	}

	public function getGroundAnchorB():B2Vec2 {
		return GetGroundAnchorB();
	}

	public function getGroundAnchorA():B2Vec2 {
		return GetGroundAnchorA();
	}

	override public function getAnchorB():B2Vec2 {
		return GetAnchorB();
	}

	override public function getAnchorA():B2Vec2 {
		return GetAnchorA();
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
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
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = _loc2_.m_xf.R;
		var _loc5_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
		var _loc6_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
		var _loc7_ = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
		_loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
		_loc5_ = _loc7_;
		_loc4_ = _loc3_.m_xf.R;
		var _loc8_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
		var _loc9_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
		_loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
		_loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
		_loc8_ = _loc7_;
		if (m_state == 2) {
			_loc10_ = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc6_;
			_loc11_ = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc5_;
			_loc12_ = _loc3_.m_linearVelocity.x + -_loc3_.m_angularVelocity * _loc9_;
			_loc13_ = _loc3_.m_linearVelocity.y + _loc3_.m_angularVelocity * _loc8_;
			_loc18_ = -(m_u1.x * _loc10_ + m_u1.y * _loc11_) - m_ratio * (m_u2.x * _loc12_ + m_u2.y * _loc13_);
			_loc19_ = m_pulleyMass * -_loc18_;
			_loc20_ = m_impulse;
			m_impulse = B2Math.max(0, m_impulse + _loc19_);
			_loc19_ = m_impulse - _loc20_;
			_loc14_ = -_loc19_ * m_u1.x;
			_loc15_ = -_loc19_ * m_u1.y;
			_loc16_ = -m_ratio * _loc19_ * m_u2.x;
			_loc17_ = -m_ratio * _loc19_ * m_u2.y;
			_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc14_;
			_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc15_;
			_loc2_.m_angularVelocity += _loc2_.m_invI * (_loc5_ * _loc15_ - _loc6_ * _loc14_);
			_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc16_;
			_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc17_;
			_loc3_.m_angularVelocity += _loc3_.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
		}
		if (m_limitState1 == 2) {
			_loc10_ = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc6_;
			_loc11_ = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc5_;
			_loc18_ = -(m_u1.x * _loc10_ + m_u1.y * _loc11_);
			_loc19_ = -m_limitMass1 * _loc18_;
			_loc20_ = m_limitImpulse1;
			m_limitImpulse1 = B2Math.max(0, m_limitImpulse1 + _loc19_);
			_loc19_ = m_limitImpulse1 - _loc20_;
			_loc14_ = -_loc19_ * m_u1.x;
			_loc15_ = -_loc19_ * m_u1.y;
			_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc14_;
			_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc15_;
			_loc2_.m_angularVelocity += _loc2_.m_invI * (_loc5_ * _loc15_ - _loc6_ * _loc14_);
		}
		if (m_limitState2 == 2) {
			_loc12_ = _loc3_.m_linearVelocity.x + -_loc3_.m_angularVelocity * _loc9_;
			_loc13_ = _loc3_.m_linearVelocity.y + _loc3_.m_angularVelocity * _loc8_;
			_loc18_ = -(m_u2.x * _loc12_ + m_u2.y * _loc13_);
			_loc19_ = -m_limitMass2 * _loc18_;
			_loc20_ = m_limitImpulse2;
			m_limitImpulse2 = B2Math.max(0, m_limitImpulse2 + _loc19_);
			_loc19_ = m_limitImpulse2 - _loc20_;
			_loc16_ = -_loc19_ * m_u2.x;
			_loc17_ = -_loc19_ * m_u2.y;
			_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc16_;
			_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc17_;
			_loc3_.m_angularVelocity += _loc3_.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
		}
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		var _loc4_ = ASCompat.dynamicAs(null, B2Mat22);
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
		var _loc23_ = Math.NaN;
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc5_ = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var _loc6_ = m_ground.m_xf.position.y + m_groundAnchor1.y;
		var _loc7_ = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var _loc8_ = m_ground.m_xf.position.y + m_groundAnchor2.y;
		var _loc24_:Float = 0;
		if (m_state == 2) {
			_loc4_ = _loc2_.m_xf.R;
			_loc9_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
			_loc10_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
			_loc23_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc10_;
			_loc10_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc10_;
			_loc9_ = _loc23_;
			_loc4_ = _loc3_.m_xf.R;
			_loc11_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
			_loc12_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
			_loc23_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc11_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc12_;
			_loc12_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc11_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc12_;
			_loc11_ = _loc23_;
			_loc13_ = _loc2_.m_sweep.c.x + _loc9_;
			_loc14_ = _loc2_.m_sweep.c.y + _loc10_;
			_loc15_ = _loc3_.m_sweep.c.x + _loc11_;
			_loc16_ = _loc3_.m_sweep.c.y + _loc12_;
			m_u1.set(_loc13_ - _loc5_, _loc14_ - _loc6_);
			m_u2.set(_loc15_ - _loc7_, _loc16_ - _loc8_);
			_loc17_ = m_u1.length();
			_loc18_ = m_u2.length();
			if (_loc17_ > B2Settings.b2_linearSlop) {
				m_u1.multiply(1 / _loc17_);
			} else {
				m_u1.setZero();
			}
			if (_loc18_ > B2Settings.b2_linearSlop) {
				m_u2.multiply(1 / _loc18_);
			} else {
				m_u2.setZero();
			}
			_loc19_ = m_constant - _loc17_ - m_ratio * _loc18_;
			_loc24_ = B2Math.max(_loc24_, -_loc19_);
			_loc19_ = B2Math.clamp(_loc19_ + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0);
			_loc20_ = -m_pulleyMass * _loc19_;
			_loc13_ = -_loc20_ * m_u1.x;
			_loc14_ = -_loc20_ * m_u1.y;
			_loc15_ = -m_ratio * _loc20_ * m_u2.x;
			_loc16_ = -m_ratio * _loc20_ * m_u2.y;
			_loc2_.m_sweep.c.x += _loc2_.m_invMass * _loc13_;
			_loc2_.m_sweep.c.y += _loc2_.m_invMass * _loc14_;
			_loc2_.m_sweep.a += _loc2_.m_invI * (_loc9_ * _loc14_ - _loc10_ * _loc13_);
			_loc3_.m_sweep.c.x += _loc3_.m_invMass * _loc15_;
			_loc3_.m_sweep.c.y += _loc3_.m_invMass * _loc16_;
			_loc3_.m_sweep.a += _loc3_.m_invI * (_loc11_ * _loc16_ - _loc12_ * _loc15_);
			_loc2_.synchronizeTransform();
			_loc3_.synchronizeTransform();
		}
		if (m_limitState1 == 2) {
			_loc4_ = _loc2_.m_xf.R;
			_loc9_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
			_loc10_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
			_loc23_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc10_;
			_loc10_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc10_;
			_loc9_ = _loc23_;
			_loc13_ = _loc2_.m_sweep.c.x + _loc9_;
			_loc14_ = _loc2_.m_sweep.c.y + _loc10_;
			m_u1.set(_loc13_ - _loc5_, _loc14_ - _loc6_);
			_loc17_ = m_u1.length();
			if (_loc17_ > B2Settings.b2_linearSlop) {
				m_u1.x *= 1 / _loc17_;
				m_u1.y *= 1 / _loc17_;
			} else {
				m_u1.setZero();
			}
			_loc19_ = m_maxLength1 - _loc17_;
			_loc24_ = B2Math.max(_loc24_, -_loc19_);
			_loc19_ = B2Math.clamp(_loc19_ + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0);
			_loc20_ = -m_limitMass1 * _loc19_;
			_loc13_ = -_loc20_ * m_u1.x;
			_loc14_ = -_loc20_ * m_u1.y;
			_loc2_.m_sweep.c.x += _loc2_.m_invMass * _loc13_;
			_loc2_.m_sweep.c.y += _loc2_.m_invMass * _loc14_;
			_loc2_.m_sweep.a += _loc2_.m_invI * (_loc9_ * _loc14_ - _loc10_ * _loc13_);
			_loc2_.synchronizeTransform();
		}
		if (m_limitState2 == 2) {
			_loc4_ = _loc3_.m_xf.R;
			_loc11_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
			_loc12_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
			_loc23_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc11_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc12_;
			_loc12_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc11_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc12_;
			_loc11_ = _loc23_;
			_loc15_ = _loc3_.m_sweep.c.x + _loc11_;
			_loc16_ = _loc3_.m_sweep.c.y + _loc12_;
			m_u2.set(_loc15_ - _loc7_, _loc16_ - _loc8_);
			_loc18_ = m_u2.length();
			if (_loc18_ > B2Settings.b2_linearSlop) {
				m_u2.x *= 1 / _loc18_;
				m_u2.y *= 1 / _loc18_;
			} else {
				m_u2.setZero();
			}
			_loc19_ = m_maxLength2 - _loc18_;
			_loc24_ = B2Math.max(_loc24_, -_loc19_);
			_loc19_ = B2Math.clamp(_loc19_ + B2Settings.b2_linearSlop, -B2Settings.b2_maxLinearCorrection, 0);
			_loc20_ = -m_limitMass2 * _loc19_;
			_loc15_ = -_loc20_ * m_u2.x;
			_loc16_ = -_loc20_ * m_u2.y;
			_loc3_.m_sweep.c.x += _loc3_.m_invMass * _loc15_;
			_loc3_.m_sweep.c.y += _loc3_.m_invMass * _loc16_;
			_loc3_.m_sweep.a += _loc3_.m_invI * (_loc11_ * _loc16_ - _loc12_ * _loc15_);
			_loc3_.synchronizeTransform();
		}
		return _loc24_ < B2Settings.b2_linearSlop;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = _loc2_.m_xf.R;
		var _loc5_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
		var _loc6_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
		var _loc7_ = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
		_loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
		_loc5_ = _loc7_;
		_loc4_ = _loc3_.m_xf.R;
		var _loc8_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
		var _loc9_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
		_loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
		_loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
		_loc8_ = _loc7_;
		var _loc10_ = _loc2_.m_sweep.c.x + _loc5_;
		var _loc11_ = _loc2_.m_sweep.c.y + _loc6_;
		var _loc12_ = _loc3_.m_sweep.c.x + _loc8_;
		var _loc13_ = _loc3_.m_sweep.c.y + _loc9_;
		var _loc14_ = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var _loc15_ = m_ground.m_xf.position.y + m_groundAnchor1.y;
		var _loc16_ = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var _loc17_ = m_ground.m_xf.position.y + m_groundAnchor2.y;
		m_u1.set(_loc10_ - _loc14_, _loc11_ - _loc15_);
		m_u2.set(_loc12_ - _loc16_, _loc13_ - _loc17_);
		var _loc18_ = m_u1.length();
		var _loc19_ = m_u2.length();
		if (_loc18_ > B2Settings.b2_linearSlop) {
			m_u1.multiply(1 / _loc18_);
		} else {
			m_u1.setZero();
		}
		if (_loc19_ > B2Settings.b2_linearSlop) {
			m_u2.multiply(1 / _loc19_);
		} else {
			m_u2.setZero();
		}
		var _loc20_ = m_constant - _loc18_ - m_ratio * _loc19_;
		if (_loc20_ > 0) {
			m_state = 0;
			m_impulse = 0;
		} else {
			m_state = 2;
		}
		if (_loc18_ < m_maxLength1) {
			m_limitState1 = 0;
			m_limitImpulse1 = 0;
		} else {
			m_limitState1 = 2;
		}
		if (_loc19_ < m_maxLength2) {
			m_limitState2 = 0;
			m_limitImpulse2 = 0;
		} else {
			m_limitState2 = 2;
		}
		var _loc21_ = _loc5_ * m_u1.y - _loc6_ * m_u1.x;
		var _loc22_ = _loc8_ * m_u2.y - _loc9_ * m_u2.x;
		m_limitMass1 = _loc2_.m_invMass + _loc2_.m_invI * _loc21_ * _loc21_;
		m_limitMass2 = _loc3_.m_invMass + _loc3_.m_invI * _loc22_ * _loc22_;
		m_pulleyMass = m_limitMass1 + m_ratio * m_ratio * m_limitMass2;
		m_limitMass1 = 1 / m_limitMass1;
		m_limitMass2 = 1 / m_limitMass2;
		m_pulleyMass = 1 / m_pulleyMass;
		if (step.warmStarting) {
			m_impulse *= step.dtRatio;
			m_limitImpulse1 *= step.dtRatio;
			m_limitImpulse2 *= step.dtRatio;
			_loc23_ = (-m_impulse - m_limitImpulse1) * m_u1.x;
			_loc24_ = (-m_impulse - m_limitImpulse1) * m_u1.y;
			_loc25_ = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.x;
			_loc26_ = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.y;
			_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc23_;
			_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc24_;
			_loc2_.m_angularVelocity += _loc2_.m_invI * (_loc5_ * _loc24_ - _loc6_ * _loc23_);
			_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc25_;
			_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc26_;
			_loc3_.m_angularVelocity += _loc3_.m_invI * (_loc8_ * _loc26_ - _loc9_ * _loc25_);
		} else {
			m_impulse = 0;
			m_limitImpulse1 = 0;
			m_limitImpulse2 = 0;
		}
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse * m_u2.x, inv_dt * m_impulse * m_u2.y);
	}

	public function GetRatio():Float {
		return m_ratio;
	}

	public function GetLength2():Float {
		var _loc1_ = m_bodyB.getWorldPoint(m_localAnchor2);
		var _loc2_ = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var _loc3_ = m_ground.m_xf.position.y + m_groundAnchor2.y;
		var _loc4_ = _loc1_.x - _loc2_;
		var _loc5_ = _loc1_.y - _loc3_;
		return Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
	}

	public function GetLength1():Float {
		var _loc1_ = m_bodyA.getWorldPoint(m_localAnchor1);
		var _loc2_ = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var _loc3_ = m_ground.m_xf.position.y + m_groundAnchor1.y;
		var _loc4_ = _loc1_.x - _loc2_;
		var _loc5_ = _loc1_.y - _loc3_;
		return Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
	}

	public function GetGroundAnchorB():B2Vec2 {
		var _loc1_ = m_ground.m_xf.position.copy();
		_loc1_.add(m_groundAnchor2);
		return _loc1_;
	}

	public function GetGroundAnchorA():B2Vec2 {
		var _loc1_ = m_ground.m_xf.position.copy();
		_loc1_.add(m_groundAnchor1);
		return _loc1_;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
}
