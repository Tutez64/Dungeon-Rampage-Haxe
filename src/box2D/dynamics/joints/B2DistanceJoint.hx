package box2D.dynamics.joints;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

/*use*/ /*namespace*/ /*b2internal*/ class B2DistanceJoint extends B2Joint {
	var m_localAnchor1:B2Vec2 = new B2Vec2();

	var m_localAnchor2:B2Vec2 = new B2Vec2();

	var m_u:B2Vec2 = new B2Vec2();

	var m_frequencyHz:Float = Math.NaN;

	var m_dampingRatio:Float = Math.NaN;

	var m_gamma:Float = Math.NaN;

	var m_bias:Float = Math.NaN;

	var m_impulse:Float = Math.NaN;

	var m_mass:Float = Math.NaN;

	var m_length:Float = Math.NaN;

	public function new(def:B2DistanceJointDef) {
		var _loc2_:B2Mat22 = null;
		var _loc3_ = Math.NaN;
		var _loc4_ = Math.NaN;
		super(def);
		this.m_localAnchor1.SetV(def.localAnchorA);
		this.m_localAnchor2.SetV(def.localAnchorB);
		this.m_length = def.length;
		this.m_frequencyHz = def.frequencyHz;
		this.m_dampingRatio = def.dampingRatio;
		this.m_impulse = 0;
		this.m_gamma = 0;
		this.m_bias = 0;
	}

	override public function GetAnchorA():B2Vec2 {
		return m_bodyA.GetWorldPoint(this.m_localAnchor1);
	}

	override public function GetAnchorB():B2Vec2 {
		return m_bodyB.GetWorldPoint(this.m_localAnchor2);
	}

	override public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return new B2Vec2(inv_dt * this.m_impulse * this.m_u.x, inv_dt * this.m_impulse * this.m_u.y);
	}

	override public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	public function GetLength():Float {
		return this.m_length;
	}

	public function SetLength(length:Float) {
		this.m_length = length;
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
		var _loc2_:B2Mat22 = null;
		var _loc3_ = Math.NaN;
		var _loc4_:B2Body = null;
		var _loc5_:B2Body = null;
		var _loc7_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		_loc4_ = m_bodyA;
		_loc5_ = m_bodyB;
		_loc2_ = _loc4_.m_xf.R;
		var _loc6_ = this.m_localAnchor1.x - _loc4_.m_sweep.localCenter.x;
		_loc7_ = this.m_localAnchor1.y - _loc4_.m_sweep.localCenter.y;
		_loc3_ = _loc2_.col1.x * _loc6_ + _loc2_.col2.x * _loc7_;
		_loc7_ = _loc2_.col1.y * _loc6_ + _loc2_.col2.y * _loc7_;
		_loc6_ = _loc3_;
		_loc2_ = _loc5_.m_xf.R;
		var _loc8_ = this.m_localAnchor2.x - _loc5_.m_sweep.localCenter.x;
		_loc9_ = this.m_localAnchor2.y - _loc5_.m_sweep.localCenter.y;
		_loc3_ = _loc2_.col1.x * _loc8_ + _loc2_.col2.x * _loc9_;
		_loc9_ = _loc2_.col1.y * _loc8_ + _loc2_.col2.y * _loc9_;
		_loc8_ = _loc3_;
		this.m_u.x = _loc5_.m_sweep.c.x + _loc8_ - _loc4_.m_sweep.c.x - _loc6_;
		this.m_u.y = _loc5_.m_sweep.c.y + _loc9_ - _loc4_.m_sweep.c.y - _loc7_;
		var _loc10_ = Math.sqrt(this.m_u.x * this.m_u.x + this.m_u.y * this.m_u.y);
		if (_loc10_ > B2Settings.b2_linearSlop) {
			this.m_u.Multiply(1 / _loc10_);
		} else {
			this.m_u.SetZero();
		}
		var _loc11_ = _loc6_ * this.m_u.y - _loc7_ * this.m_u.x;
		var _loc12_ = _loc8_ * this.m_u.y - _loc9_ * this.m_u.x;
		var _loc13_ = _loc4_.m_invMass + _loc4_.m_invI * _loc11_ * _loc11_ + _loc5_.m_invMass + _loc5_.m_invI * _loc12_ * _loc12_;
		this.m_mass = _loc13_ != 0 ? 1 / _loc13_ : 0;
		if (this.m_frequencyHz > 0) {
			_loc14_ = _loc10_ - this.m_length;
			_loc15_ = 2 * Math.PI * this.m_frequencyHz;
			_loc16_ = 2 * this.m_mass * this.m_dampingRatio * _loc15_;
			_loc17_ = this.m_mass * _loc15_ * _loc15_;
			this.m_gamma = step.dt * (_loc16_ + step.dt * _loc17_);
			this.m_gamma = this.m_gamma != 0 ? 1 / this.m_gamma : 0;
			this.m_bias = _loc14_ * step.dt * _loc17_ * this.m_gamma;
			this.m_mass = _loc13_ + this.m_gamma;
			this.m_mass = this.m_mass != 0 ? 1 / this.m_mass : 0;
		}
		if (step.warmStarting) {
			this.m_impulse *= step.dtRatio;
			_loc18_ = this.m_impulse * this.m_u.x;
			_loc19_ = this.m_impulse * this.m_u.y;
			_loc4_.m_linearVelocity.x -= _loc4_.m_invMass * _loc18_;
			_loc4_.m_linearVelocity.y -= _loc4_.m_invMass * _loc19_;
			_loc4_.m_angularVelocity -= _loc4_.m_invI * (_loc6_ * _loc19_ - _loc7_ * _loc18_);
			_loc5_.m_linearVelocity.x += _loc5_.m_invMass * _loc18_;
			_loc5_.m_linearVelocity.y += _loc5_.m_invMass * _loc19_;
			_loc5_.m_angularVelocity += _loc5_.m_invI * (_loc8_ * _loc19_ - _loc9_ * _loc18_);
		} else {
			this.m_impulse = 0;
		}
	}

	override public function SolveVelocityConstraints(step:B2TimeStep) {
		var _loc2_:B2Mat22 = null;
		var _loc3_ = m_bodyA;
		var _loc4_ = m_bodyB;
		_loc2_ = _loc3_.m_xf.R;
		var _loc5_ = this.m_localAnchor1.x - _loc3_.m_sweep.localCenter.x;
		var _loc6_ = this.m_localAnchor1.y - _loc3_.m_sweep.localCenter.y;
		var _loc7_ = _loc2_.col1.x * _loc5_ + _loc2_.col2.x * _loc6_;
		_loc6_ = _loc2_.col1.y * _loc5_ + _loc2_.col2.y * _loc6_;
		_loc5_ = _loc7_;
		_loc2_ = _loc4_.m_xf.R;
		var _loc8_ = this.m_localAnchor2.x - _loc4_.m_sweep.localCenter.x;
		var _loc9_ = this.m_localAnchor2.y - _loc4_.m_sweep.localCenter.y;
		_loc7_ = _loc2_.col1.x * _loc8_ + _loc2_.col2.x * _loc9_;
		_loc9_ = _loc2_.col1.y * _loc8_ + _loc2_.col2.y * _loc9_;
		_loc8_ = _loc7_;
		var _loc10_ = _loc3_.m_linearVelocity.x + -_loc3_.m_angularVelocity * _loc6_;
		var _loc11_ = _loc3_.m_linearVelocity.y + _loc3_.m_angularVelocity * _loc5_;
		var _loc12_ = _loc4_.m_linearVelocity.x + -_loc4_.m_angularVelocity * _loc9_;
		var _loc13_ = _loc4_.m_linearVelocity.y + _loc4_.m_angularVelocity * _loc8_;
		var _loc14_ = this.m_u.x * (_loc12_ - _loc10_) + this.m_u.y * (_loc13_ - _loc11_);
		var _loc15_ = -this.m_mass * (_loc14_ + this.m_bias + this.m_gamma * this.m_impulse);
		this.m_impulse += _loc15_;
		var _loc16_ = _loc15_ * this.m_u.x;
		var _loc17_ = _loc15_ * this.m_u.y;
		_loc3_.m_linearVelocity.x -= _loc3_.m_invMass * _loc16_;
		_loc3_.m_linearVelocity.y -= _loc3_.m_invMass * _loc17_;
		_loc3_.m_angularVelocity -= _loc3_.m_invI * (_loc5_ * _loc17_ - _loc6_ * _loc16_);
		_loc4_.m_linearVelocity.x += _loc4_.m_invMass * _loc16_;
		_loc4_.m_linearVelocity.y += _loc4_.m_invMass * _loc17_;
		_loc4_.m_angularVelocity += _loc4_.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
	}

	override public function SolvePositionConstraints(baumgarte:Float):Bool {
		var _loc2_:B2Mat22 = null;
		if (this.m_frequencyHz > 0) {
			return true;
		}
		var _loc3_ = m_bodyA;
		var _loc4_ = m_bodyB;
		_loc2_ = _loc3_.m_xf.R;
		var _loc5_ = this.m_localAnchor1.x - _loc3_.m_sweep.localCenter.x;
		var _loc6_ = this.m_localAnchor1.y - _loc3_.m_sweep.localCenter.y;
		var _loc7_ = _loc2_.col1.x * _loc5_ + _loc2_.col2.x * _loc6_;
		_loc6_ = _loc2_.col1.y * _loc5_ + _loc2_.col2.y * _loc6_;
		_loc5_ = _loc7_;
		_loc2_ = _loc4_.m_xf.R;
		var _loc8_ = this.m_localAnchor2.x - _loc4_.m_sweep.localCenter.x;
		var _loc9_ = this.m_localAnchor2.y - _loc4_.m_sweep.localCenter.y;
		_loc7_ = _loc2_.col1.x * _loc8_ + _loc2_.col2.x * _loc9_;
		_loc9_ = _loc2_.col1.y * _loc8_ + _loc2_.col2.y * _loc9_;
		_loc8_ = _loc7_;
		var _loc10_ = _loc4_.m_sweep.c.x + _loc8_ - _loc3_.m_sweep.c.x - _loc5_;
		var _loc11_ = _loc4_.m_sweep.c.y + _loc9_ - _loc3_.m_sweep.c.y - _loc6_;
		var _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
		_loc10_ /= _loc12_;
		_loc11_ /= _loc12_;
		var _loc13_ = _loc12_ - this.m_length;
		_loc13_ = B2Math.Clamp(_loc13_, -B2Settings.b2_maxLinearCorrection, B2Settings.b2_maxLinearCorrection);
		var _loc14_ = -this.m_mass * _loc13_;
		this.m_u.Set(_loc10_, _loc11_);
		var _loc15_ = _loc14_ * this.m_u.x;
		var _loc16_ = _loc14_ * this.m_u.y;
		_loc3_.m_sweep.c.x -= _loc3_.m_invMass * _loc15_;
		_loc3_.m_sweep.c.y -= _loc3_.m_invMass * _loc16_;
		_loc3_.m_sweep.a -= _loc3_.m_invI * (_loc5_ * _loc16_ - _loc6_ * _loc15_);
		_loc4_.m_sweep.c.x += _loc4_.m_invMass * _loc15_;
		_loc4_.m_sweep.c.y += _loc4_.m_invMass * _loc16_;
		_loc4_.m_sweep.a += _loc4_.m_invI * (_loc8_ * _loc16_ - _loc9_ * _loc15_);
		_loc3_.SynchronizeTransform();
		_loc4_.SynchronizeTransform();
		return B2Math.Abs(_loc13_) < B2Settings.b2_linearSlop;
	}
}
