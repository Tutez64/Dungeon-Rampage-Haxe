package box2D.dynamics.joints;

import box2D.common.math.B2Mat33;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Vec3;
import box2D.common.B2Settings;
import box2D.dynamics.B2TimeStep;
import flash.Boot;

class B2WeldJoint extends B2Joint {
	public var m_referenceAngle:Float = Math.NaN;

	public var m_mass:B2Mat33;

	public var m_localAnchorB:B2Vec2;

	public var m_localAnchorA:B2Vec2;

	public var m_impulse:B2Vec3;

	public function new(def:B2WeldJointDef = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(def);
			m_localAnchorA = new B2Vec2();
			m_localAnchorB = new B2Vec2();
			m_impulse = new B2Vec3();
			m_mass = new B2Mat33();
			m_localAnchorA.setV(def.localAnchorA);
			m_localAnchorB.setV(def.localAnchorB);
			m_referenceAngle = def.referenceAngle;
			m_impulse.setZero();
			m_mass = new B2Mat33();
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
		var _loc18_ = _loc6_.x - _loc7_ * _loc17_ - _loc4_.x + _loc5_ * _loc14_;
		var _loc19_ = _loc6_.y + _loc7_ * _loc16_ - _loc4_.y - _loc5_ * _loc13_;
		var _loc20_ = _loc7_ - _loc5_;
		var _loc21_ = new B2Vec3();
		m_mass.solve33(_loc21_, -_loc18_, -_loc19_, -_loc20_);
		m_impulse.add(_loc21_);
		_loc4_.x -= _loc8_ * _loc21_.x;
		_loc4_.y -= _loc8_ * _loc21_.y;
		_loc5_ -= _loc10_ * (_loc13_ * _loc21_.y - _loc14_ * _loc21_.x + _loc21_.z);
		_loc6_.x += _loc9_ * _loc21_.x;
		_loc6_.y += _loc9_ * _loc21_.y;
		_loc7_ += _loc11_ * (_loc16_ * _loc21_.y - _loc17_ * _loc21_.x + _loc21_.z);
		_loc2_.m_angularVelocity = _loc5_;
		_loc3_.m_angularVelocity = _loc7_;
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
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
		var _loc14_ = _loc3_.m_sweep.c.x + _loc8_ - _loc2_.m_sweep.c.x - _loc5_;
		var _loc15_ = _loc3_.m_sweep.c.y + _loc9_ - _loc2_.m_sweep.c.y - _loc6_;
		var _loc16_ = _loc3_.m_sweep.a - _loc2_.m_sweep.a - m_referenceAngle;
		var _loc17_ = 10 * B2Settings.b2_linearSlop;
		var _loc18_ = Math.sqrt(_loc14_ * _loc14_ + _loc15_ * _loc15_);
		var _loc19_ = B2Math.abs(_loc16_);
		if (_loc18_ > _loc17_) {
			_loc12_ *= 1;
			_loc13_ *= 1;
		}
		m_mass.col1.x = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
		m_mass.col2.x = -_loc6_ * _loc5_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
		m_mass.col3.x = -_loc6_ * _loc12_ - _loc9_ * _loc13_;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = _loc10_ + _loc11_ + _loc5_ * _loc5_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
		m_mass.col3.y = _loc5_ * _loc12_ + _loc8_ * _loc13_;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = _loc12_ + _loc13_;
		var _loc20_ = new B2Vec3();
		m_mass.solve33(_loc20_, -_loc14_, -_loc15_, -_loc16_);
		_loc2_.m_sweep.c.x -= _loc10_ * _loc20_.x;
		_loc2_.m_sweep.c.y -= _loc10_ * _loc20_.y;
		_loc2_.m_sweep.a -= _loc12_ * (_loc5_ * _loc20_.y - _loc6_ * _loc20_.x + _loc20_.z);
		_loc3_.m_sweep.c.x += _loc11_ * _loc20_.x;
		_loc3_.m_sweep.c.y += _loc11_ * _loc20_.y;
		_loc3_.m_sweep.a += _loc13_ * (_loc8_ * _loc20_.y - _loc9_ * _loc20_.x + _loc20_.z);
		_loc2_.synchronizeTransform();
		_loc3_.synchronizeTransform();
		if (_loc18_ <= B2Settings.b2_linearSlop) {
			return _loc19_ <= B2Settings.b2_angularSlop;
		}
		return false;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
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
		m_mass.col1.x = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
		m_mass.col2.x = -_loc6_ * _loc5_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
		m_mass.col3.x = -_loc6_ * _loc12_ - _loc9_ * _loc13_;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = _loc10_ + _loc11_ + _loc5_ * _loc5_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
		m_mass.col3.y = _loc5_ * _loc12_ + _loc8_ * _loc13_;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = _loc12_ + _loc13_;
		if (step.warmStarting) {
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_impulse.z *= step.dtRatio;
			_loc2_.m_linearVelocity.x -= _loc10_ * m_impulse.x;
			_loc2_.m_linearVelocity.y -= _loc10_ * m_impulse.y;
			_loc2_.m_angularVelocity -= _loc12_ * (_loc5_ * m_impulse.y - _loc6_ * m_impulse.x + m_impulse.z);
			_loc3_.m_linearVelocity.x += _loc11_ * m_impulse.x;
			_loc3_.m_linearVelocity.y += _loc11_ * m_impulse.y;
			_loc3_.m_angularVelocity += _loc13_ * (_loc8_ * m_impulse.y - _loc9_ * m_impulse.x + m_impulse.z);
		} else {
			m_impulse.setZero();
		}
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return inv_dt * m_impulse.z;
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.getWorldPoint(m_localAnchorB);
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.getWorldPoint(m_localAnchorA);
	}
}
