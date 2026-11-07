package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

class B2MouseJoint extends B2Joint {
	public var m_target:B2Vec2;

	public var m_maxForce:Float = Math.NaN;

	public var m_mass:B2Mat22;

	public var m_localAnchor:B2Vec2;

	public var m_impulse:B2Vec2;

	public var m_gamma:Float = Math.NaN;

	public var m_frequencyHz:Float = Math.NaN;

	public var m_dampingRatio:Float = Math.NaN;

	public var m_beta:Float = Math.NaN;

	public var m_C:B2Vec2;

	public var K2:B2Mat22;

	public var K1:B2Mat22;

	public var K:B2Mat22;

	public function new(def:B2MouseJointDef = /*undefined*/ null) {
		super(def);
		K = new B2Mat22();
		K1 = new B2Mat22();
		K2 = new B2Mat22();
		m_localAnchor = new B2Vec2();
		m_target = new B2Vec2();
		m_impulse = new B2Vec2();
		m_mass = new B2Mat22();
		m_C = new B2Vec2();
		m_target.setV(def.target);
		var _loc2_ = m_target.x - m_bodyB.m_xf.position.x;
		var _loc3_ = m_target.y - m_bodyB.m_xf.position.y;
		var _loc4_ = m_bodyB.m_xf.R;
		m_localAnchor.x = _loc2_ * _loc4_.col1.x + _loc3_ * _loc4_.col1.y;
		m_localAnchor.y = _loc2_ * _loc4_.col2.x + _loc3_ * _loc4_.col2.y;
		m_maxForce = def.maxForce;
		m_impulse.setZero();
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		m_beta = 0;
		m_gamma = 0;
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setTarget(target:B2Vec2) {
		SetTarget(target);
	}

	public function setMaxForce(maxForce:Float) {
		SetMaxForce(maxForce);
	}

	public function setFrequency(hz:Float) {
		SetFrequency(hz);
	}

	public function setDampingRatio(ratio:Float) {
		SetDampingRatio(ratio);
	}

	override public function initVelocityConstraints(step:B2TimeStep) {
		InitVelocityConstraints(step);
	}

	public function getTarget():B2Vec2 {
		return GetTarget();
	}

	override public function getReactionTorque(inv_dt:Float):Float {
		return GetReactionTorque(inv_dt);
	}

	override public function getReactionForce(inv_dt:Float):B2Vec2 {
		return GetReactionForce(inv_dt);
	}

	public function getMaxForce():Float {
		return GetMaxForce();
	}

	public function getFrequency():Float {
		return GetFrequency();
	}

	public function getDampingRatio():Float {
		return GetDampingRatio();
	}

	override public function getAnchorB():B2Vec2 {
		return GetAnchorB();
	}

	override public function getAnchorA():B2Vec2 {
		return GetAnchorA();
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
		var _loc2_ = m_bodyB;
		var _loc3_ = _loc2_.m_xf.R;
		var _loc4_ = m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
		var _loc5_ = m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
		var _loc6_ = _loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_;
		_loc5_ = _loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_;
		_loc4_ = _loc6_;
		var _loc7_ = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc5_;
		var _loc8_ = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc4_;
		_loc3_ = m_mass;
		_loc6_ = _loc7_ + m_beta * m_C.x + m_gamma * m_impulse.x;
		var _loc9_ = _loc8_ + m_beta * m_C.y + m_gamma * m_impulse.y;
		var _loc10_ = -(_loc3_.col1.x * _loc6_ + _loc3_.col2.x * _loc9_);
		var _loc11_ = -(_loc3_.col1.y * _loc6_ + _loc3_.col2.y * _loc9_);
		var _loc12_ = m_impulse.x;
		var _loc13_ = m_impulse.y;
		m_impulse.x += _loc10_;
		m_impulse.y += _loc11_;
		var _loc14_ = step.dt * m_maxForce;
		if (m_impulse.lengthSquared() > _loc14_ * _loc14_) {
			m_impulse.multiply(_loc14_ / m_impulse.length());
		}
		_loc10_ = m_impulse.x - _loc12_;
		_loc11_ = m_impulse.y - _loc13_;
		_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc10_;
		_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc11_;
		_loc2_.m_angularVelocity += _loc2_.m_invI * (_loc4_ * _loc11_ - _loc5_ * _loc10_);
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		return true;
	}

	public function SetTarget(target:B2Vec2) {
		if ((m_bodyB.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
			m_bodyB.setAwake(true);
		}
		m_target = target;
	}

	public function SetMaxForce(maxForce:Float) {
		m_maxForce = maxForce;
	}

	public function SetFrequency(hz:Float) {
		m_frequencyHz = hz;
	}

	public function SetDampingRatio(ratio:Float) {
		m_dampingRatio = ratio;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc2_ = m_bodyB;
		var _loc3_ = _loc2_.getMass();
		var _loc4_ = 2 * Math.PI * m_frequencyHz;
		var _loc5_ = 2 * _loc3_ * m_dampingRatio * _loc4_;
		var _loc6_ = _loc3_ * _loc4_ * _loc4_;
		m_gamma = step.dt * (_loc5_ + step.dt * _loc6_);
		m_gamma = m_gamma != 0 ? 1 / m_gamma : 0;
		m_beta = step.dt * _loc6_ * m_gamma;
		var _loc7_ = _loc2_.m_xf.R;
		var _loc8_ = m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
		var _loc9_ = m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
		var _loc10_ = _loc7_.col1.x * _loc8_ + _loc7_.col2.x * _loc9_;
		_loc9_ = _loc7_.col1.y * _loc8_ + _loc7_.col2.y * _loc9_;
		_loc8_ = _loc10_;
		var _loc11_ = _loc2_.m_invMass;
		var _loc12_ = _loc2_.m_invI;
		K1.col1.x = _loc11_;
		K1.col2.x = 0;
		K1.col1.y = 0;
		K1.col2.y = _loc11_;
		K2.col1.x = _loc12_ * _loc9_ * _loc9_;
		K2.col2.x = -_loc12_ * _loc8_ * _loc9_;
		K2.col1.y = -_loc12_ * _loc8_ * _loc9_;
		K2.col2.y = _loc12_ * _loc8_ * _loc8_;
		K.setM(K1);
		K.addM(K2);
		K.col1.x += m_gamma;
		K.col2.y += m_gamma;
		K.getInverse(m_mass);
		m_C.x = _loc2_.m_sweep.c.x + _loc8_ - m_target.x;
		m_C.y = _loc2_.m_sweep.c.y + _loc9_ - m_target.y;
		_loc2_.m_angularVelocity *= 0.98;
		m_impulse.x *= step.dtRatio;
		m_impulse.y *= step.dtRatio;
		_loc2_.m_linearVelocity.x += _loc11_ * m_impulse.x;
		_loc2_.m_linearVelocity.y += _loc11_ * m_impulse.y;
		_loc2_.m_angularVelocity += _loc12_ * (_loc8_ * m_impulse.y - _loc9_ * m_impulse.x);
	}

	public function GetTarget():B2Vec2 {
		return m_target;
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	public function GetMaxForce():Float {
		return m_maxForce;
	}

	public function GetFrequency():Float {
		return m_frequencyHz;
	}

	public function GetDampingRatio():Float {
		return m_dampingRatio;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_target;
	}
}
