package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

class B2GearJoint extends B2Joint {
	public var m_revolute2:B2RevoluteJoint;

	public var m_revolute1:B2RevoluteJoint;

	public var m_ratio:Float = Math.NaN;

	public var m_prismatic2:B2PrismaticJoint;

	public var m_prismatic1:B2PrismaticJoint;

	public var m_mass:Float = Math.NaN;

	public var m_localAnchor2:B2Vec2;

	public var m_localAnchor1:B2Vec2;

	public var m_impulse:Float = Math.NaN;

	public var m_groundAnchor2:B2Vec2;

	public var m_groundAnchor1:B2Vec2;

	public var m_ground2:B2Body;

	public var m_ground1:B2Body;

	public var m_constant:Float = Math.NaN;

	public var m_J:B2Jacobian;

	public function new(def:B2GearJointDef = /*undefined*/ null) {
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		super(def);
		m_groundAnchor1 = new B2Vec2();
		m_groundAnchor2 = new B2Vec2();
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();
		m_J = new B2Jacobian();
		var _loc2_ = def.joint1.m_type;
		var _loc3_ = def.joint2.m_type;
		m_revolute1 = null;
		m_prismatic1 = null;
		m_revolute2 = null;
		m_prismatic2 = null;
		m_ground1 = def.joint1.getBodyA();
		m_bodyA = def.joint1.getBodyB();
		if (_loc2_ == 1) {
			m_revolute1 = cast(def.joint1, B2RevoluteJoint);
			m_groundAnchor1.setV(m_revolute1.m_localAnchor1);
			m_localAnchor1.setV(m_revolute1.m_localAnchor2);
			_loc4_ = m_revolute1.getJointAngle();
		} else {
			m_prismatic1 = cast(def.joint1, B2PrismaticJoint);
			m_groundAnchor1.setV(m_prismatic1.m_localAnchor1);
			m_localAnchor1.setV(m_prismatic1.m_localAnchor2);
			_loc4_ = m_prismatic1.getJointTranslation();
		}
		m_ground2 = def.joint2.getBodyA();
		m_bodyB = def.joint2.getBodyB();
		if (_loc3_ == 1) {
			m_revolute2 = cast(def.joint2, B2RevoluteJoint);
			m_groundAnchor2.setV(m_revolute2.m_localAnchor1);
			m_localAnchor2.setV(m_revolute2.m_localAnchor2);
			_loc5_ = m_revolute2.getJointAngle();
		} else {
			m_prismatic2 = cast(def.joint2, B2PrismaticJoint);
			m_groundAnchor2.setV(m_prismatic2.m_localAnchor1);
			m_localAnchor2.setV(m_prismatic2.m_localAnchor2);
			_loc5_ = m_prismatic2.getJointTranslation();
		}
		m_ratio = def.ratio;
		m_constant = _loc4_ + m_ratio * _loc5_;
		m_impulse = 0;
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setRatio(ratio:Float) {
		SetRatio(ratio);
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

	override public function getAnchorB():B2Vec2 {
		return GetAnchorB();
	}

	override public function getAnchorA():B2Vec2 {
		return GetAnchorA();
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = m_J.compute(_loc2_.m_linearVelocity, _loc2_.m_angularVelocity, _loc3_.m_linearVelocity, _loc3_.m_angularVelocity);
		var _loc5_ = -m_mass * _loc4_;
		m_impulse += _loc5_;
		_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc5_ * m_J.linearA.x;
		_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc5_ * m_J.linearA.y;
		_loc2_.m_angularVelocity += _loc2_.m_invI * _loc5_ * m_J.angularA;
		_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc5_ * m_J.linearB.x;
		_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc5_ * m_J.linearB.y;
		_loc3_.m_angularVelocity += _loc3_.m_invI * _loc5_ * m_J.angularB;
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc2_:Float = 0;
		var _loc3_ = m_bodyA;
		var _loc4_ = m_bodyB;
		if (m_revolute1 != null) {
			_loc5_ = m_revolute1.getJointAngle();
		} else {
			_loc5_ = m_prismatic1.getJointTranslation();
		}
		if (m_revolute2 != null) {
			_loc6_ = m_revolute2.getJointAngle();
		} else {
			_loc6_ = m_prismatic2.getJointTranslation();
		}
		var _loc7_ = m_constant - (_loc5_ + m_ratio * _loc6_);
		var _loc8_ = -m_mass * _loc7_;
		_loc3_.m_sweep.c.x += _loc3_.m_invMass * _loc8_ * m_J.linearA.x;
		_loc3_.m_sweep.c.y += _loc3_.m_invMass * _loc8_ * m_J.linearA.y;
		_loc3_.m_sweep.a += _loc3_.m_invI * _loc8_ * m_J.angularA;
		_loc4_.m_sweep.c.x += _loc4_.m_invMass * _loc8_ * m_J.linearB.x;
		_loc4_.m_sweep.c.y += _loc4_.m_invMass * _loc8_ * m_J.linearB.y;
		_loc4_.m_sweep.a += _loc4_.m_invI * _loc8_ * m_J.angularB;
		_loc3_.synchronizeTransform();
		_loc4_.synchronizeTransform();
		return _loc2_ < B2Settings.b2_linearSlop;
	}

	public function SetRatio(ratio:Float) {
		m_ratio = ratio;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = ASCompat.dynamicAs(null, B2Mat22);
		var _loc11_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc2_ = m_ground1;
		var _loc3_ = m_ground2;
		var _loc4_ = m_bodyA;
		var _loc5_ = m_bodyB;
		var _loc14_:Float = 0;
		m_J.setZero();
		if (m_revolute1 != null) {
			m_J.angularA = -1;
			_loc14_ += _loc4_.m_invI;
		} else {
			_loc10_ = _loc2_.m_xf.R;
			_loc11_ = m_prismatic1.m_localXAxis1;
			_loc6_ = ASCompat.toNumberField(_loc10_.col1, "x") * ASCompat.toNumberField(_loc11_, "x")
				+ ASCompat.toNumberField(_loc10_.col2, "x") * ASCompat.toNumberField(_loc11_, "y");
			_loc7_ = ASCompat.toNumberField(_loc10_.col1, "y") * ASCompat.toNumberField(_loc11_, "x")
				+ ASCompat.toNumberField(_loc10_.col2, "y") * ASCompat.toNumberField(_loc11_, "y");
			_loc10_ = _loc4_.m_xf.R;
			_loc8_ = m_localAnchor1.x - _loc4_.m_sweep.localCenter.x;
			_loc9_ = m_localAnchor1.y - _loc4_.m_sweep.localCenter.y;
			_loc13_ = ASCompat.toNumberField(_loc10_.col1, "x") * _loc8_ + ASCompat.toNumberField(_loc10_.col2, "x") * _loc9_;
			_loc9_ = ASCompat.toNumberField(_loc10_.col1, "y") * _loc8_ + ASCompat.toNumberField(_loc10_.col2, "y") * _loc9_;
			_loc8_ = _loc13_;
			_loc12_ = _loc8_ * _loc7_ - _loc9_ * _loc6_;
			m_J.linearA.set(-_loc6_, -_loc7_);
			m_J.angularA = -_loc12_;
			_loc14_ += _loc4_.m_invMass + _loc4_.m_invI * _loc12_ * _loc12_;
		}
		if (m_revolute2 != null) {
			m_J.angularB = -m_ratio;
			_loc14_ += m_ratio * m_ratio * _loc5_.m_invI;
		} else {
			_loc10_ = _loc3_.m_xf.R;
			_loc11_ = m_prismatic2.m_localXAxis1;
			_loc6_ = ASCompat.toNumberField(_loc10_.col1, "x") * ASCompat.toNumberField(_loc11_, "x")
				+ ASCompat.toNumberField(_loc10_.col2, "x") * ASCompat.toNumberField(_loc11_, "y");
			_loc7_ = ASCompat.toNumberField(_loc10_.col1, "y") * ASCompat.toNumberField(_loc11_, "x")
				+ ASCompat.toNumberField(_loc10_.col2, "y") * ASCompat.toNumberField(_loc11_, "y");
			_loc10_ = _loc5_.m_xf.R;
			_loc8_ = m_localAnchor2.x - _loc5_.m_sweep.localCenter.x;
			_loc9_ = m_localAnchor2.y - _loc5_.m_sweep.localCenter.y;
			_loc13_ = ASCompat.toNumberField(_loc10_.col1, "x") * _loc8_ + ASCompat.toNumberField(_loc10_.col2, "x") * _loc9_;
			_loc9_ = ASCompat.toNumberField(_loc10_.col1, "y") * _loc8_ + ASCompat.toNumberField(_loc10_.col2, "y") * _loc9_;
			_loc8_ = _loc13_;
			_loc12_ = _loc8_ * _loc7_ - _loc9_ * _loc6_;
			m_J.linearB.set(-m_ratio * _loc6_, -m_ratio * _loc7_);
			m_J.angularB = -m_ratio * _loc12_;
			_loc14_ += m_ratio * m_ratio * (_loc5_.m_invMass + _loc5_.m_invI * _loc12_ * _loc12_);
		}
		m_mass = _loc14_ > 0 ? 1 / _loc14_ : 0;
		if (step.warmStarting) {
			_loc4_.m_linearVelocity.x += _loc4_.m_invMass * m_impulse * m_J.linearA.x;
			_loc4_.m_linearVelocity.y += _loc4_.m_invMass * m_impulse * m_J.linearA.y;
			_loc4_.m_angularVelocity += _loc4_.m_invI * m_impulse * m_J.angularA;
			_loc5_.m_linearVelocity.x += _loc5_.m_invMass * m_impulse * m_J.linearB.x;
			_loc5_.m_linearVelocity.y += _loc5_.m_invMass * m_impulse * m_J.linearB.y;
			_loc5_.m_angularVelocity += _loc5_.m_invI * m_impulse * m_J.angularB;
		} else {
			m_impulse = 0;
		}
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		var _loc2_ = m_bodyB.m_xf.R;
		var _loc3_ = m_localAnchor1.x - m_bodyB.m_sweep.localCenter.x;
		var _loc4_ = m_localAnchor1.y - m_bodyB.m_sweep.localCenter.y;
		var _loc5_ = _loc2_.col1.x * _loc3_ + _loc2_.col2.x * _loc4_;
		_loc4_ = _loc2_.col1.y * _loc3_ + _loc2_.col2.y * _loc4_;
		_loc3_ = _loc5_;
		var _loc6_ = m_impulse * m_J.linearB.x;
		var _loc7_ = m_impulse * m_J.linearB.y;
		return inv_dt * (m_impulse * m_J.angularB - _loc3_ * _loc7_ + _loc4_ * _loc6_);
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse * m_J.linearB.x, inv_dt * m_impulse * m_J.linearB.y);
	}

	public function GetRatio():Float {
		return m_ratio;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
}
