package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2TimeStep;

class B2FrictionJoint extends B2Joint {
	public var m_maxTorque:Float = Math.NaN;

	public var m_maxForce:Float = Math.NaN;

	public var m_localAnchorB:B2Vec2;

	public var m_localAnchorA:B2Vec2;

	public var m_linearMass:B2Mat22;

	public var m_linearImpulse:B2Vec2;

	public var m_angularMass:Float = Math.NaN;

	public var m_angularImpulse:Float = Math.NaN;

	public function new(def:B2FrictionJointDef = /*undefined*/ null) {
		super(def);
		m_localAnchorA = new B2Vec2();
		m_localAnchorB = new B2Vec2();
		m_linearMass = new B2Mat22();
		m_linearImpulse = new B2Vec2();
		m_localAnchorA.setV(def.localAnchorA);
		m_localAnchorB.setV(def.localAnchorB);
		m_linearMass.setZero();
		m_angularMass = 0;
		m_linearImpulse.setZero();
		m_angularImpulse = 0;
		m_maxForce = def.maxForce;
		m_maxTorque = def.maxTorque;
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setMaxTorque(torque:Float) {
		SetMaxTorque(torque);
	}

	public function setMaxForce(force:Float) {
		SetMaxForce(force);
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

	public function getMaxTorque():Float {
		return GetMaxTorque();
	}

	public function getMaxForce():Float {
		return GetMaxForce();
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
		var _loc4_ = _loc2_.m_linearVelocity;
		var _loc5_ = _loc2_.m_angularVelocity;
		var _loc6_ = _loc3_.m_linearVelocity;
		var _loc7_ = _loc3_.m_angularVelocity;
		var _loc8_ = _loc2_.m_invMass;
		var _loc9_ = _loc3_.m_invMass;
		var _loc10_ = _loc2_.m_invI;
		var _loc11_ = _loc3_.m_invI;
		var _loc12_ = _loc2_.m_xf.R;
		var _loc13_ = m_localAnchorA.x - _loc2_.m_sweep.localCenter.x;
		var _loc14_ = m_localAnchorA.y - _loc2_.m_sweep.localCenter.y;
		var _loc15_ = _loc12_.col1.x * _loc13_ + _loc12_.col2.x * _loc14_;
		_loc14_ = _loc12_.col1.y * _loc13_ + _loc12_.col2.y * _loc14_;
		_loc13_ = _loc15_;
		_loc12_ = _loc3_.m_xf.R;
		var _loc16_ = m_localAnchorB.x - _loc3_.m_sweep.localCenter.x;
		var _loc17_ = m_localAnchorB.y - _loc3_.m_sweep.localCenter.y;
		_loc15_ = _loc12_.col1.x * _loc16_ + _loc12_.col2.x * _loc17_;
		_loc17_ = _loc12_.col1.y * _loc16_ + _loc12_.col2.y * _loc17_;
		_loc16_ = _loc15_;
		var _loc19_ = _loc7_ - _loc5_;
		var _loc20_ = -m_angularMass * _loc19_;
		var _loc21_ = m_angularImpulse;
		var _loc18_ = step.dt * m_maxTorque;
		m_angularImpulse = B2Math.clamp(m_angularImpulse + _loc20_, -_loc18_, _loc18_);
		_loc20_ = m_angularImpulse - _loc21_;
		_loc5_ -= _loc10_ * _loc20_;
		_loc7_ += _loc11_ * _loc20_;
		_loc19_ = _loc6_.x - _loc7_ * _loc17_ - _loc4_.x + _loc5_ * _loc14_;
		_loc20_ = _loc6_.y + _loc7_ * _loc16_ - _loc4_.y - _loc5_ * _loc13_;
		var _loc22_ = B2Math.mulMV(m_linearMass, new B2Vec2(-_loc19_, -_loc20_));
		var _loc23_ = m_linearImpulse.copy();
		m_linearImpulse.add(_loc22_);
		_loc18_ = step.dt * m_maxForce;
		if (m_linearImpulse.lengthSquared() > _loc18_ * _loc18_) {
			m_linearImpulse.normalize();
			m_linearImpulse.multiply(_loc18_);
		}
		_loc22_ = B2Math.subtractVV(m_linearImpulse, _loc23_);
		_loc4_.x -= _loc8_ * _loc22_.x;
		_loc4_.y -= _loc8_ * _loc22_.y;
		_loc5_ -= _loc10_ * (_loc13_ * _loc22_.y - _loc14_ * _loc22_.x);
		_loc6_.x += _loc9_ * _loc22_.x;
		_loc6_.y += _loc9_ * _loc22_.y;
		_loc7_ += _loc11_ * (_loc16_ * _loc22_.y - _loc17_ * _loc22_.x);
		_loc2_.m_angularVelocity = _loc5_;
		_loc3_.m_angularVelocity = _loc7_;
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		return true;
	}

	public function SetMaxTorque(torque:Float) {
		m_maxTorque = torque;
	}

	public function SetMaxForce(force:Float) {
		m_maxForce = force;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc15_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc2_ = m_bodyA;
		var _loc3_ = m_bodyB;
		var _loc4_ = _loc2_.m_xf.R;
		var _loc5_ = m_localAnchorA.x - _loc2_.m_sweep.localCenter.x;
		var _loc6_ = m_localAnchorA.y - _loc2_.m_sweep.localCenter.y;
		var _loc7_ = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
		_loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
		_loc5_ = _loc7_;
		_loc4_ = _loc3_.m_xf.R;
		var _loc8_ = m_localAnchorB.x - _loc3_.m_sweep.localCenter.x;
		var _loc9_ = m_localAnchorB.y - _loc3_.m_sweep.localCenter.y;
		_loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
		_loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
		_loc8_ = _loc7_;
		var _loc10_ = _loc2_.m_invMass;
		var _loc11_ = _loc3_.m_invMass;
		var _loc12_ = _loc2_.m_invI;
		var _loc13_ = _loc3_.m_invI;
		var _loc14_ = new B2Mat22();
		_loc14_.col1.x = _loc10_ + _loc11_;
		_loc14_.col2.x = 0;
		_loc14_.col1.y = 0;
		_loc14_.col2.y = _loc10_ + _loc11_;
		_loc14_.col1.x += _loc12_ * _loc6_ * _loc6_;
		_loc14_.col2.x += -_loc12_ * _loc5_ * _loc6_;
		_loc14_.col1.y += -_loc12_ * _loc5_ * _loc6_;
		_loc14_.col2.y += _loc12_ * _loc5_ * _loc5_;
		_loc14_.col1.x += _loc13_ * _loc9_ * _loc9_;
		_loc14_.col2.x += -_loc13_ * _loc8_ * _loc9_;
		_loc14_.col1.y += -_loc13_ * _loc8_ * _loc9_;
		_loc14_.col2.y += _loc13_ * _loc8_ * _loc8_;
		_loc14_.getInverse(m_linearMass);
		m_angularMass = _loc12_ + _loc13_;
		if (m_angularMass > 0) {
			m_angularMass = 1 / m_angularMass;
		}
		if (step.warmStarting) {
			m_linearImpulse.x *= step.dtRatio;
			m_linearImpulse.y *= step.dtRatio;
			m_angularImpulse *= step.dtRatio;
			_loc15_ = m_linearImpulse;
			_loc2_.m_linearVelocity.x -= _loc10_ * ASCompat.toNumberField(_loc15_, "x");
			_loc2_.m_linearVelocity.y -= _loc10_ * ASCompat.toNumberField(_loc15_, "y");
			_loc2_.m_angularVelocity -= _loc12_ * (_loc5_ * ASCompat.toNumberField(_loc15_, "y") - _loc6_ * ASCompat.toNumberField(_loc15_, "x")
				+ m_angularImpulse);
			_loc3_.m_linearVelocity.x += _loc11_ * ASCompat.toNumberField(_loc15_, "x");
			_loc3_.m_linearVelocity.y += _loc11_ * ASCompat.toNumberField(_loc15_, "y");
			_loc3_.m_angularVelocity += _loc13_ * (_loc8_ * ASCompat.toNumberField(_loc15_, "y") - _loc9_ * ASCompat.toNumberField(_loc15_, "x")
				+ m_angularImpulse);
		} else {
			m_linearImpulse.setZero();
			m_angularImpulse = 0;
		}
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return inv_dt * m_angularImpulse;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_linearImpulse.x, inv_dt * m_linearImpulse.y);
	}

	public function GetMaxTorque():Float {
		return m_maxTorque;
	}

	public function GetMaxForce():Float {
		return m_maxForce;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchorB);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchorA);
	}
}
