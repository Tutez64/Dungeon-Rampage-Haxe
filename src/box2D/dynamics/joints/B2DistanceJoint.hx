package box2D.dynamics.joints;

import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2TimeStep;

class B2DistanceJoint extends B2Joint {
	public var m_u:B2Vec2;

	public var m_mass:Float = Math.NaN;

	public var m_localAnchor2:B2Vec2;

	public var m_localAnchor1:B2Vec2;

	public var m_length:Float = Math.NaN;

	public var m_impulse:Float = Math.NaN;

	public var m_gamma:Float = Math.NaN;

	public var m_frequencyHz:Float = Math.NaN;

	public var m_dampingRatio:Float = Math.NaN;

	public var m_bias:Float = Math.NaN;

	public function new(def:B2DistanceJointDef = /*undefined*/ null) {
		super(def);
		m_localAnchor1 = new B2Vec2();
		m_localAnchor2 = new B2Vec2();
		m_u = new B2Vec2();
		m_localAnchor1.setV(def.localAnchorA);
		m_localAnchor2.setV(def.localAnchorB);
		m_length = def.length;
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		m_impulse = 0;
		m_gamma = 0;
		m_bias = 0;
	}

	override public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	override public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setLength(length:Float) {
		SetLength(length);
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

	override public function getReactionTorque(inv_dt:Float):Float {
		return GetReactionTorque(inv_dt);
	}

	override public function getReactionForce(inv_dt:Float):B2Vec2 {
		return GetReactionForce(inv_dt);
	}

	public function getLength():Float {
		return GetLength();
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
		var _loc10_ = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc6_;
		var _loc11_ = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc5_;
		var _loc12_ = _loc3_.m_linearVelocity.x + -_loc3_.m_angularVelocity * _loc9_;
		var _loc13_ = _loc3_.m_linearVelocity.y + _loc3_.m_angularVelocity * _loc8_;
		var _loc14_ = m_u.x * (_loc12_ - _loc10_) + m_u.y * (_loc13_ - _loc11_);
		var _loc15_ = -m_mass * (_loc14_ + m_bias + m_gamma * m_impulse);
		m_impulse += _loc15_;
		var _loc16_ = _loc15_ * m_u.x;
		var _loc17_ = _loc15_ * m_u.y;
		_loc2_.m_linearVelocity.x -= _loc2_.m_invMass * _loc16_;
		_loc2_.m_linearVelocity.y -= _loc2_.m_invMass * _loc17_;
		_loc2_.m_angularVelocity -= _loc2_.m_invI * (_loc5_ * _loc17_ - _loc6_ * _loc16_);
		_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc16_;
		_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc17_;
		_loc3_.m_angularVelocity += _loc3_.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		if (m_frequencyHz > 0) {
			return true;
		}
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
		var _loc10_ = _loc3_.m_sweep.c.x + _loc8_ - _loc2_.m_sweep.c.x - _loc5_;
		var _loc11_ = _loc3_.m_sweep.c.y + _loc9_ - _loc2_.m_sweep.c.y - _loc6_;
		var _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
		_loc10_ /= _loc12_;
		_loc11_ /= _loc12_;
		var _loc13_ = _loc12_ - m_length;
		_loc13_ = B2Math.clamp(_loc13_, -B2Settings.b2_maxLinearCorrection, B2Settings.b2_maxLinearCorrection);
		var _loc14_ = -m_mass * _loc13_;
		m_u.set(_loc10_, _loc11_);
		var _loc15_ = _loc14_ * m_u.x;
		var _loc16_ = _loc14_ * m_u.y;
		_loc2_.m_sweep.c.x -= _loc2_.m_invMass * _loc15_;
		_loc2_.m_sweep.c.y -= _loc2_.m_invMass * _loc16_;
		_loc2_.m_sweep.a -= _loc2_.m_invI * (_loc5_ * _loc16_ - _loc6_ * _loc15_);
		_loc3_.m_sweep.c.x += _loc3_.m_invMass * _loc15_;
		_loc3_.m_sweep.c.y += _loc3_.m_invMass * _loc16_;
		_loc3_.m_sweep.a += _loc3_.m_invI * (_loc8_ * _loc16_ - _loc9_ * _loc15_);
		_loc2_.synchronizeTransform();
		_loc3_.synchronizeTransform();
		return B2Math.abs(_loc13_) < B2Settings.b2_linearSlop;
	}

	public function SetLength(length:Float) {
		m_length = length;
	}

	public function SetFrequency(hz:Float) {
		m_frequencyHz = hz;
	}

	public function SetDampingRatio(ratio:Float) {
		m_dampingRatio = ratio;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
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
		m_u.x = _loc3_.m_sweep.c.x + _loc8_ - _loc2_.m_sweep.c.x - _loc5_;
		m_u.y = _loc3_.m_sweep.c.y + _loc9_ - _loc2_.m_sweep.c.y - _loc6_;
		var _loc10_ = Math.sqrt(m_u.x * m_u.x + m_u.y * m_u.y);
		if (_loc10_ > B2Settings.b2_linearSlop) {
			m_u.multiply(1 / _loc10_);
		} else {
			m_u.setZero();
		}
		var _loc11_ = _loc5_ * m_u.y - _loc6_ * m_u.x;
		var _loc12_ = _loc8_ * m_u.y - _loc9_ * m_u.x;
		var _loc13_ = _loc2_.m_invMass + _loc2_.m_invI * _loc11_ * _loc11_ + _loc3_.m_invMass + _loc3_.m_invI * _loc12_ * _loc12_;
		m_mass = _loc13_ != 0 ? 1 / _loc13_ : 0;
		if (m_frequencyHz > 0) {
			_loc14_ = _loc10_ - m_length;
			_loc15_ = 2 * Math.PI * m_frequencyHz;
			_loc16_ = 2 * m_mass * m_dampingRatio * _loc15_;
			_loc17_ = m_mass * _loc15_ * _loc15_;
			m_gamma = step.dt * (_loc16_ + step.dt * _loc17_);
			m_gamma = m_gamma != 0 ? 1 / m_gamma : 0;
			m_bias = _loc14_ * step.dt * _loc17_ * m_gamma;
			m_mass = _loc13_ + m_gamma;
			m_mass = m_mass != 0 ? 1 / m_mass : 0;
		}
		if (step.warmStarting) {
			m_impulse *= step.dtRatio;
			_loc14_ = m_impulse * m_u.x;
			_loc15_ = m_impulse * m_u.y;
			_loc2_.m_linearVelocity.x -= _loc2_.m_invMass * _loc14_;
			_loc2_.m_linearVelocity.y -= _loc2_.m_invMass * _loc15_;
			_loc2_.m_angularVelocity -= _loc2_.m_invI * (_loc5_ * _loc15_ - _loc6_ * _loc14_);
			_loc3_.m_linearVelocity.x += _loc3_.m_invMass * _loc14_;
			_loc3_.m_linearVelocity.y += _loc3_.m_invMass * _loc15_;
			_loc3_.m_angularVelocity += _loc3_.m_invI * (_loc8_ * _loc15_ - _loc9_ * _loc14_);
		} else {
			m_impulse = 0;
		}
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse * m_u.x, inv_dt * m_impulse * m_u.y);
	}

	public function GetLength():Float {
		return m_length;
	}

	public function GetFrequency():Float {
		return m_frequencyHz;
	}

	public function GetDampingRatio():Float {
		return m_dampingRatio;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchor2);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchor1);
	}
}
