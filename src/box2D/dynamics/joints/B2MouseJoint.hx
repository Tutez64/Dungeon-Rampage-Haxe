package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2TimeStep;

/*use*/ /*namespace*/ /*b2internal*/ class B2MouseJoint extends B2Joint {
	var K:B2Mat22 = new B2Mat22();

	var K1:B2Mat22 = new B2Mat22();

	var K2:B2Mat22 = new B2Mat22();

	var m_localAnchor:B2Vec2 = new B2Vec2();

	var m_target:B2Vec2 = new B2Vec2();

	var m_impulse:B2Vec2 = new B2Vec2();

	var m_mass:B2Mat22 = new B2Mat22();

	var m_C:B2Vec2 = new B2Vec2();

	var m_maxForce:Float = Math.NaN;

	var m_frequencyHz:Float = Math.NaN;

	var m_dampingRatio:Float = Math.NaN;

	var m_beta:Float = Math.NaN;

	var m_gamma:Float = Math.NaN;

	public function new(def:B2MouseJointDef) {
		var _loc2_ = Math.NaN;
		var _loc4_:B2Mat22 = null;
		super(def);
		this.m_target.SetV(def.target);
		_loc2_ = this.m_target.x - /*b2internal::*/ m_bodyB.m_xf.position.x;
		var _loc3_ = this.m_target.y - /*b2internal::*/ m_bodyB.m_xf.position.y;
		_loc4_ = /*b2internal::*/ m_bodyB.m_xf.R;
		this.m_localAnchor.x = _loc2_ * _loc4_.col1.x + _loc3_ * _loc4_.col1.y;
		this.m_localAnchor.y = _loc2_ * _loc4_.col2.x + _loc3_ * _loc4_.col2.y;
		this.m_maxForce = def.maxForce;
		this.m_impulse.SetZero();
		this.m_frequencyHz = def.frequencyHz;
		this.m_dampingRatio = def.dampingRatio;
		this.m_beta = 0;
		this.m_gamma = 0;
	}

	override public function GetAnchorA():B2Vec2 {
		return this.m_target;
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.GetWorldPoint(this.m_localAnchor);
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * this.m_impulse.x, inv_dt * this.m_impulse.y);
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	public function GetTarget():B2Vec2 {
		return this.m_target;
	}

	public function SetTarget(target:B2Vec2) {
		if (m_bodyB.IsAwake() == false) {
			m_bodyB.SetAwake(true);
		}
		this.m_target = target;
	}

	public function GetMaxForce():Float {
		return this.m_maxForce;
	}

	public function SetMaxForce(maxForce:Float) {
		this.m_maxForce = maxForce;
	}

	public function GetFrequency():Float {
		return this.m_frequencyHz;
	}

	public function SetFrequency(hz:Float) {
		this.m_frequencyHz = hz;
	}

	public function GetDampingRatio():Float {
		return this.m_dampingRatio;
	}

	public function SetDampingRatio(ratio:Float) {
		this.m_dampingRatio = ratio;
	}

	override public function InitVelocityConstraints(step:B2TimeStep) {
		var _loc7_:B2Mat22 = null;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc2_ = m_bodyB;
		var _loc3_ = _loc2_.GetMass();
		var _loc4_ = 2 * Math.PI * this.m_frequencyHz;
		var _loc5_ = 2 * _loc3_ * this.m_dampingRatio * _loc4_;
		var _loc6_ = _loc3_ * _loc4_ * _loc4_;
		this.m_gamma = step.dt * (_loc5_ + step.dt * _loc6_);
		this.m_gamma = this.m_gamma != 0 ? 1 / this.m_gamma : 0;
		this.m_beta = step.dt * _loc6_ * this.m_gamma;
		_loc7_ = _loc2_.m_xf.R;
		var _loc8_ = this.m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
		var _loc9_ = this.m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
		var _loc10_ = _loc7_.col1.x * _loc8_ + _loc7_.col2.x * _loc9_;
		_loc9_ = _loc7_.col1.y * _loc8_ + _loc7_.col2.y * _loc9_;
		_loc8_ = _loc10_;
		_loc11_ = _loc2_.m_invMass;
		_loc12_ = _loc2_.m_invI;
		this.K1.col1.x = _loc11_;
		this.K1.col2.x = 0;
		this.K1.col1.y = 0;
		this.K1.col2.y = _loc11_;
		this.K2.col1.x = _loc12_ * _loc9_ * _loc9_;
		this.K2.col2.x = -_loc12_ * _loc8_ * _loc9_;
		this.K2.col1.y = -_loc12_ * _loc8_ * _loc9_;
		this.K2.col2.y = _loc12_ * _loc8_ * _loc8_;
		this.K.SetM(this.K1);
		this.K.AddM(this.K2);
		this.K.col1.x += this.m_gamma;
		this.K.col2.y += this.m_gamma;
		this.K.GetInverse(this.m_mass);
		this.m_C.x = _loc2_.m_sweep.c.x + _loc8_ - this.m_target.x;
		this.m_C.y = _loc2_.m_sweep.c.y + _loc9_ - this.m_target.y;
		_loc2_.m_angularVelocity *= 0.98;
		this.m_impulse.x *= step.dtRatio;
		this.m_impulse.y *= step.dtRatio;
		_loc2_.m_linearVelocity.x += _loc11_ * this.m_impulse.x;
		_loc2_.m_linearVelocity.y += _loc11_ * this.m_impulse.y;
		_loc2_.m_angularVelocity += _loc12_ * (_loc8_ * this.m_impulse.y - _loc9_ * this.m_impulse.x);
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
		var _loc3_:B2Mat22 = null;
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc2_ = m_bodyB;
		_loc3_ = _loc2_.m_xf.R;
		var _loc6_ = this.m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
		var _loc7_ = this.m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
		_loc4_ = _loc3_.col1.x * _loc6_ + _loc3_.col2.x * _loc7_;
		_loc7_ = _loc3_.col1.y * _loc6_ + _loc3_.col2.y * _loc7_;
		_loc6_ = _loc4_;
		var _loc8_ = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc7_;
		var _loc9_ = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc6_;
		_loc3_ = this.m_mass;
		_loc4_ = _loc8_ + this.m_beta * this.m_C.x + this.m_gamma * this.m_impulse.x;
		_loc5_ = _loc9_ + this.m_beta * this.m_C.y + this.m_gamma * this.m_impulse.y;
		var _loc10_ = -(_loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_);
		var _loc11_ = -(_loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_);
		var _loc12_ = this.m_impulse.x;
		var _loc13_ = this.m_impulse.y;
		this.m_impulse.x += _loc10_;
		this.m_impulse.y += _loc11_;
		var _loc14_ = step.dt * this.m_maxForce;
		if (this.m_impulse.LengthSquared() > _loc14_ * _loc14_) {
			this.m_impulse.Multiply(_loc14_ / this.m_impulse.Length());
		}
		_loc10_ = this.m_impulse.x - _loc12_;
		_loc11_ = this.m_impulse.y - _loc13_;
		_loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc10_;
		_loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc11_;
		_loc2_.m_angularVelocity += _loc2_.m_invI * (_loc6_ * _loc11_ - _loc7_ * _loc10_);
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		return true;
	}
}
