package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Mat33;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Vec3;
import box2D.common.B2Settings;
import box2D.dynamics.B2TimeStep;

class B2RevoluteJoint extends B2Joint {
	public static var tImpulse:B2Vec2 = new B2Vec2();

	public var reduced:B2Vec2;

	public var m_upperAngle:Float = Math.NaN;

	public var m_referenceAngle:Float = Math.NaN;

	public var m_motorSpeed:Float = Math.NaN;

	public var m_motorMass:Float = Math.NaN;

	public var m_motorImpulse:Float = Math.NaN;

	public var m_maxMotorTorque:Float = Math.NaN;

	public var m_mass:B2Mat33;

	public var m_lowerAngle:Float = Math.NaN;

	public var m_localAnchor2:B2Vec2;

	public var m_localAnchor1:B2Vec2;

	public var m_limitState:Int = 0;

	public var m_impulse:B2Vec3;

	public var m_enableMotor:Bool = false;

	public var m_enableLimit:Bool = false;

	public var impulse3:B2Vec3;

	public var impulse2:B2Vec2;

	public var K3:B2Mat22;

	public var K2:B2Mat22;

	public var K1:B2Mat22;

	public var K:B2Mat22;

	public function new(def:B2RevoluteJointDef = /*undefined*/ null) {
		super(def);
		K = new B2Mat22();
		K1 = new B2Mat22();
		K2 = new B2Mat22();
		K3 = new B2Mat22();
		impulse3 = new B2Vec3();
		impulse2 = new B2Vec2();
		reduced = new B2Vec2();
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();
		m_impulse = new B2Vec3();
		m_mass = new B2Mat33();
		m_localAnchor1.setV(def.localAnchorA);
		m_localAnchor2.setV(def.localAnchorB);
		m_referenceAngle = def.referenceAngle;
		m_impulse.setZero();
		m_motorImpulse = 0;
		m_lowerAngle = def.lowerAngle;
		m_upperAngle = def.upperAngle;
		m_maxMotorTorque = def.maxMotorTorque;
		m_motorSpeed = def.motorSpeed;
		m_enableLimit = def.enableLimit;
		m_enableMotor = def.enableMotor;
		m_limitState = 0;
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

	public function setMaxMotorTorque(torque:Float) {
		SetMaxMotorTorque(torque);
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

	public function getMotorTorque():Float {
		return GetMotorTorque();
	}

	public function getMotorSpeed():Float {
		return GetMotorSpeed();
	}

	public function getLowerLimit():Float {
		return GetLowerLimit();
	}

	public function getJointSpeed():Float {
		return GetJointSpeed();
	}

	public function getJointAngle():Float {
		return GetJointAngle();
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
		var _loc4_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc11_ = _loc2_.m_linearVelocity;
		var _loc12_ = _loc2_.m_angularVelocity;
		var _loc13_ = _loc3_.m_linearVelocity;
		var _loc14_ = _loc3_.m_angularVelocity;
		var _loc15_ = _loc2_.m_invMass;
		var _loc16_ = _loc3_.m_invMass;
		var _loc17_ = _loc2_.m_invI;
		var _loc18_ = _loc3_.m_invI;
		if (m_enableMotor && m_limitState != 3) {
			_loc19_ = _loc14_ - _loc12_ - m_motorSpeed;
			_loc20_ = m_motorMass * -_loc19_;
			_loc21_ = m_motorImpulse;
			_loc22_ = step.dt * m_maxMotorTorque;
			m_motorImpulse = B2Math.clamp(m_motorImpulse + _loc20_, -_loc22_, _loc22_);
			_loc20_ = m_motorImpulse - _loc21_;
			_loc12_ -= _loc17_ * _loc20_;
			_loc14_ += _loc18_ * _loc20_;
		}
		if (m_enableLimit && m_limitState != 0) {
			_loc4_ = _loc2_.m_xf.R;
			_loc7_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
			_loc8_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
			_loc5_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc7_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc8_;
			_loc8_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc7_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc8_;
			_loc7_ = _loc5_;
			_loc4_ = _loc3_.m_xf.R;
			_loc9_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
			_loc10_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
			_loc5_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc10_;
			_loc10_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc10_;
			_loc9_ = _loc5_;
			_loc19_ = _loc13_.x + -_loc14_ * _loc10_ - _loc11_.x - -_loc12_ * _loc8_;
			_loc20_ = _loc13_.y + _loc14_ * _loc9_ - _loc11_.y - _loc12_ * _loc7_;
			_loc21_ = _loc14_ - _loc12_;
			m_mass.solve33(impulse3, -_loc19_, -_loc20_, -_loc21_);
			if (m_limitState == 3) {
				m_impulse.add(impulse3);
			} else if (m_limitState == 1) {
				_loc6_ = m_impulse.z + impulse3.z;
				if (_loc6_ < 0) {
					m_mass.solve22(reduced, -_loc19_, -_loc20_);
					impulse3.x = reduced.x;
					impulse3.y = reduced.y;
					impulse3.z = -m_impulse.z;
					m_impulse.x += reduced.x;
					m_impulse.y += reduced.y;
					m_impulse.z = 0;
				}
			} else if (m_limitState == 2) {
				_loc6_ = m_impulse.z + impulse3.z;
				if (_loc6_ > 0) {
					m_mass.solve22(reduced, -_loc19_, -_loc20_);
					impulse3.x = reduced.x;
					impulse3.y = reduced.y;
					impulse3.z = -m_impulse.z;
					m_impulse.x += reduced.x;
					m_impulse.y += reduced.y;
					m_impulse.z = 0;
				}
			}
			_loc11_.x -= _loc15_ * impulse3.x;
			_loc11_.y -= _loc15_ * impulse3.y;
			_loc12_ -= _loc17_ * (_loc7_ * impulse3.y - _loc8_ * impulse3.x + impulse3.z);
			_loc13_.x += _loc16_ * impulse3.x;
			_loc13_.y += _loc16_ * impulse3.y;
			_loc14_ += _loc18_ * (_loc9_ * impulse3.y - _loc10_ * impulse3.x + impulse3.z);
		} else {
			_loc4_ = _loc2_.m_xf.R;
			_loc7_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
			_loc8_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
			_loc5_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc7_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc8_;
			_loc8_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc7_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc8_;
			_loc7_ = _loc5_;
			_loc4_ = _loc3_.m_xf.R;
			_loc9_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
			_loc10_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
			_loc5_ = ASCompat.toNumberField(_loc4_.col1, "x") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "x") * _loc10_;
			_loc10_ = ASCompat.toNumberField(_loc4_.col1, "y") * _loc9_ + ASCompat.toNumberField(_loc4_.col2, "y") * _loc10_;
			_loc9_ = _loc5_;
			_loc19_ = _loc13_.x + -_loc14_ * _loc10_ - _loc11_.x - -_loc12_ * _loc8_;
			_loc20_ = _loc13_.y + _loc14_ * _loc9_ - _loc11_.y - _loc12_ * _loc7_;
			m_mass.solve22(impulse2, -_loc19_, -_loc20_);
			m_impulse.x += impulse2.x;
			m_impulse.y += impulse2.y;
			_loc11_.x -= _loc15_ * impulse2.x;
			_loc11_.y -= _loc15_ * impulse2.y;
			_loc12_ -= _loc17_ * (_loc7_ * impulse2.y - _loc8_ * impulse2.x);
			_loc13_.x += _loc16_ * impulse2.x;
			_loc13_.y += _loc16_ * impulse2.y;
			_loc14_ += _loc18_ * (_loc9_ * impulse2.y - _loc10_ * impulse2.x);
		}
		_loc2_.m_linearVelocity.setV(_loc11_);
		_loc2_.m_angularVelocity = _loc12_;
		_loc3_.m_linearVelocity.setV(_loc13_);
		_loc3_.m_angularVelocity = _loc14_;
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		var _loc3_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc29_ = Math.NaN;
		var _loc5_ = m_bodyA;
		var _loc6_ = m_bodyB;
		var _loc7_:Float = 0;
		var _loc8_:Float = 0;
		if (m_enableLimit && m_limitState != 0) {
			_loc12_ = _loc6_.m_sweep.a - _loc5_.m_sweep.a - m_referenceAngle;
			_loc13_ = 0;
			if (m_limitState == 3) {
				_loc3_ = B2Math.clamp(_loc12_ - m_lowerAngle, -B2Settings.b2_maxAngularCorrection, B2Settings.b2_maxAngularCorrection);
				_loc13_ = -m_motorMass * _loc3_;
				_loc7_ = B2Math.abs(_loc3_);
			} else if (m_limitState == 1) {
				_loc3_ = _loc12_ - m_lowerAngle;
				_loc7_ = -_loc3_;
				_loc3_ = B2Math.clamp(_loc3_ + B2Settings.b2_angularSlop, -B2Settings.b2_maxAngularCorrection, 0);
				_loc13_ = -m_motorMass * _loc3_;
			} else if (m_limitState == 2) {
				_loc3_ = _loc12_ - m_upperAngle;
				_loc7_ = _loc3_;
				_loc3_ = B2Math.clamp(_loc3_ - B2Settings.b2_angularSlop, 0, B2Settings.b2_maxAngularCorrection);
				_loc13_ = -m_motorMass * _loc3_;
			}
			_loc5_.m_sweep.a -= _loc5_.m_invI * _loc13_;
			_loc6_.m_sweep.a += _loc6_.m_invI * _loc13_;
			_loc5_.synchronizeTransform();
			_loc6_.synchronizeTransform();
		}
		var _loc4_ = _loc5_.m_xf.R;
		_loc12_ = m_localAnchor1.x - _loc5_.m_sweep.localCenter.x;
		_loc13_ = m_localAnchor1.y - _loc5_.m_sweep.localCenter.y;
		var _loc9_ = _loc4_.col1.x * _loc12_ + _loc4_.col2.x * _loc13_;
		_loc13_ = _loc4_.col1.y * _loc12_ + _loc4_.col2.y * _loc13_;
		_loc12_ = _loc9_;
		_loc4_ = _loc6_.m_xf.R;
		var _loc14_ = m_localAnchor2.x - _loc6_.m_sweep.localCenter.x;
		var _loc15_ = m_localAnchor2.y - _loc6_.m_sweep.localCenter.y;
		_loc9_ = _loc4_.col1.x * _loc14_ + _loc4_.col2.x * _loc15_;
		_loc15_ = _loc4_.col1.y * _loc14_ + _loc4_.col2.y * _loc15_;
		_loc14_ = _loc9_;
		var _loc16_ = _loc6_.m_sweep.c.x + _loc14_ - _loc5_.m_sweep.c.x - _loc12_;
		var _loc17_ = _loc6_.m_sweep.c.y + _loc15_ - _loc5_.m_sweep.c.y - _loc13_;
		var _loc18_ = _loc16_ * _loc16_ + _loc17_ * _loc17_;
		var _loc19_:Float;
		_loc8_ = _loc19_ = Math.sqrt(_loc18_);
		var _loc20_ = _loc5_.m_invMass;
		var _loc21_ = _loc6_.m_invMass;
		var _loc22_ = _loc5_.m_invI;
		var _loc23_ = _loc6_.m_invI;
		var _loc24_ = 10 * B2Settings.b2_linearSlop;
		if (_loc18_ > _loc24_ * _loc24_) {
			_loc25_ = _loc16_ / _loc19_;
			_loc26_ = _loc17_ / _loc19_;
			_loc27_ = _loc20_ + _loc21_;
			_loc28_ = 1 / _loc27_;
			_loc10_ = _loc28_ * -_loc16_;
			_loc11_ = _loc28_ * -_loc17_;
			_loc29_ = 0.5;
			_loc5_.m_sweep.c.x -= _loc29_ * _loc20_ * _loc10_;
			_loc5_.m_sweep.c.y -= _loc29_ * _loc20_ * _loc11_;
			_loc6_.m_sweep.c.x += _loc29_ * _loc21_ * _loc10_;
			_loc6_.m_sweep.c.y += _loc29_ * _loc21_ * _loc11_;
			_loc16_ = _loc6_.m_sweep.c.x + _loc14_ - _loc5_.m_sweep.c.x - _loc12_;
			_loc17_ = _loc6_.m_sweep.c.y + _loc15_ - _loc5_.m_sweep.c.y - _loc13_;
		}
		K1.col1.x = _loc20_ + _loc21_;
		K1.col2.x = 0;
		K1.col1.y = 0;
		K1.col2.y = _loc20_ + _loc21_;
		K2.col1.x = _loc22_ * _loc13_ * _loc13_;
		K2.col2.x = -_loc22_ * _loc12_ * _loc13_;
		K2.col1.y = -_loc22_ * _loc12_ * _loc13_;
		K2.col2.y = _loc22_ * _loc12_ * _loc12_;
		K3.col1.x = _loc23_ * _loc15_ * _loc15_;
		K3.col2.x = -_loc23_ * _loc14_ * _loc15_;
		K3.col1.y = -_loc23_ * _loc14_ * _loc15_;
		K3.col2.y = _loc23_ * _loc14_ * _loc14_;
		K.setM(K1);
		K.addM(K2);
		K.addM(K3);
		K.solve(B2RevoluteJoint.tImpulse, -_loc16_, -_loc17_);
		_loc10_ = B2RevoluteJoint.tImpulse.x;
		_loc11_ = B2RevoluteJoint.tImpulse.y;
		_loc5_.m_sweep.c.x -= _loc5_.m_invMass * _loc10_;
		_loc5_.m_sweep.c.y -= _loc5_.m_invMass * _loc11_;
		_loc5_.m_sweep.a -= _loc5_.m_invI * (_loc12_ * _loc11_ - _loc13_ * _loc10_);
		_loc6_.m_sweep.c.x += _loc6_.m_invMass * _loc10_;
		_loc6_.m_sweep.c.y += _loc6_.m_invMass * _loc11_;
		_loc6_.m_sweep.a += _loc6_.m_invI * (_loc14_ * _loc11_ - _loc15_ * _loc10_);
		_loc5_.synchronizeTransform();
		_loc6_.synchronizeTransform();
		if (_loc8_ <= B2Settings.b2_linearSlop) {
			return _loc7_ <= B2Settings.b2_angularSlop;
		}
		return false;
	}

	public function SetMotorSpeed(speed:Float) {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		m_motorSpeed = speed;
	}

	public function SetMaxMotorTorque(torque:Float) {
		m_maxMotorTorque = torque;
	}

	public function SetLimits(lower:Float, upper:Float) {
		m_lowerAngle = lower;
		m_upperAngle = upper;
	}

	public function IsMotorEnabled():Bool {
		m_bodyA.setAwake(true);
		m_bodyB.setAwake(true);
		return m_enableMotor;
	}

	public function IsLimitEnabled():Bool {
		return m_enableLimit;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = m_enableMotor || m_enableLimit;
		var _loc5_ = _loc2_.m_xf.R;
		var _loc6_ = m_localAnchor1.x - _loc2_.m_sweep.localCenter.x;
		var _loc7_ = m_localAnchor1.y - _loc2_.m_sweep.localCenter.y;
		var _loc8_ = _loc5_.col1.x * _loc6_ + _loc5_.col2.x * _loc7_;
		_loc7_ = _loc5_.col1.y * _loc6_ + _loc5_.col2.y * _loc7_;
		_loc6_ = _loc8_;
		_loc5_ = _loc3_.m_xf.R;
		var _loc9_ = m_localAnchor2.x - _loc3_.m_sweep.localCenter.x;
		var _loc10_ = m_localAnchor2.y - _loc3_.m_sweep.localCenter.y;
		_loc8_ = _loc5_.col1.x * _loc9_ + _loc5_.col2.x * _loc10_;
		_loc10_ = _loc5_.col1.y * _loc9_ + _loc5_.col2.y * _loc10_;
		_loc9_ = _loc8_;
		var _loc11_ = _loc2_.m_invMass;
		var _loc12_ = _loc3_.m_invMass;
		var _loc13_ = _loc2_.m_invI;
		var _loc14_ = _loc3_.m_invI;
		m_mass.col1.x = _loc11_ + _loc12_ + _loc7_ * _loc7_ * _loc13_ + _loc10_ * _loc10_ * _loc14_;
		m_mass.col2.x = -_loc7_ * _loc6_ * _loc13_ - _loc10_ * _loc9_ * _loc14_;
		m_mass.col3.x = -_loc7_ * _loc13_ - _loc10_ * _loc14_;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = _loc11_ + _loc12_ + _loc6_ * _loc6_ * _loc13_ + _loc9_ * _loc9_ * _loc14_;
		m_mass.col3.y = _loc6_ * _loc13_ + _loc9_ * _loc14_;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = _loc13_ + _loc14_;
		m_motorMass = 1 / (_loc13_ + _loc14_);
		if (m_enableMotor == false) {
			m_motorImpulse = 0;
		}
		if (m_enableLimit) {
			_loc15_ = _loc3_.m_sweep.a - _loc2_.m_sweep.a - m_referenceAngle;
			if (B2Math.abs(m_upperAngle - m_lowerAngle) < 2 * B2Settings.b2_angularSlop) {
				m_limitState = 3;
			} else if (_loc15_ <= m_lowerAngle) {
				if (m_limitState != 1) {
					m_impulse.z = 0;
				}
				m_limitState = 1;
			} else if (_loc15_ >= m_upperAngle) {
				if (m_limitState != 2) {
					m_impulse.z = 0;
				}
				m_limitState = 2;
			} else {
				m_limitState = 0;
				m_impulse.z = 0;
			}
		} else {
			m_limitState = 0;
		}
		if (step.warmStarting) {
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio;
			_loc15_ = m_impulse.x;
			_loc16_ = m_impulse.y;
			_loc2_.m_linearVelocity.x -= _loc11_ * _loc15_;
			_loc2_.m_linearVelocity.y -= _loc11_ * _loc16_;
			_loc2_.m_angularVelocity -= _loc13_ * (_loc6_ * _loc16_ - _loc7_ * _loc15_ + m_motorImpulse + m_impulse.z);
			_loc3_.m_linearVelocity.x += _loc12_ * _loc15_;
			_loc3_.m_linearVelocity.y += _loc12_ * _loc16_;
			_loc3_.m_angularVelocity += _loc14_ * (_loc9_ * _loc16_ - _loc10_ * _loc15_ + m_motorImpulse + m_impulse.z);
		} else {
			m_impulse.setZero();
			m_motorImpulse = 0;
		}
	}

	public function GetUpperLimit():Float {
		return m_upperAngle;
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return inv_dt * m_impulse.z;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	public function GetMotorTorque():Float {
		return m_maxMotorTorque;
	}

	public function GetMotorSpeed():Float {
		return m_motorSpeed;
	}

	public function GetLowerLimit():Float {
		return m_lowerAngle;
	}

	public function GetJointSpeed():Float {
		return m_bodyB.m_angularVelocity - m_bodyA.m_angularVelocity;
	}

	public function GetJointAngle():Float {
		return m_bodyB.m_sweep.a - m_bodyA.m_sweep.a - m_referenceAngle;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}

	public function EnableMotor(flag:Bool) {
		m_enableMotor = flag;
	}

	public function EnableLimit(flag:Bool) {
		m_enableLimit = flag;
	}
}
