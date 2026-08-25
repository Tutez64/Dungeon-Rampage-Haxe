package box2D.dynamics;

import box2D.collision.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.contacts.*;
import box2D.dynamics.joints.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2Island {
	static var s_impulse:B2ContactImpulse = new B2ContactImpulse();

	var m_allocator:ASAny;

	var m_listener:B2ContactListener;

	var m_contactSolver:B2ContactSolver;

	/*b2internal*/
	public var m_bodies:Vector<B2Body>;

	/*b2internal*/
	public var m_contacts:Vector<B2Contact>;

	/*b2internal*/
	public var m_joints:Vector<B2Joint>;

	/*b2internal*/
	public var m_bodyCount:Int = 0;

	/*b2internal*/
	public var m_jointCount:Int = 0;

	/*b2internal*/
	public var m_contactCount:Int = 0;

	var m_bodyCapacity:Int = 0;

	/*b2internal*/
	public var m_contactCapacity:Int = 0;

	/*b2internal*/
	public var m_jointCapacity:Int = 0;

	public function new() {
		this.m_bodies = new Vector<B2Body>();
		this.m_contacts = new Vector<B2Contact>();
		this.m_joints = new Vector<B2Joint>();
	}

	public function Initialize(bodyCapacity:Int, contactCapacity:Int, jointCapacity:Int, allocator:ASAny, listener:B2ContactListener,
			contactSolver:B2ContactSolver) {
		var _loc7_ = 0;
		this.m_bodyCapacity = bodyCapacity;
		this.m_contactCapacity = contactCapacity;
		this.m_jointCapacity = jointCapacity;
		this.m_bodyCount = 0;
		this.m_contactCount = 0;
		this.m_jointCount = 0;
		this.m_allocator = allocator;
		this.m_listener = listener;
		this.m_contactSolver = contactSolver;
		_loc7_ = this.m_bodies.length;
		while (_loc7_ < bodyCapacity) {
			this.m_bodies[_loc7_] = null;
			_loc7_ = ASCompat.toInt(_loc7_) + 1;
		}
		_loc7_ = this.m_contacts.length;
		while (_loc7_ < contactCapacity) {
			this.m_contacts[_loc7_] = null;
			_loc7_ = ASCompat.toInt(_loc7_) + 1;
		}
		_loc7_ = this.m_joints.length;
		while (_loc7_ < jointCapacity) {
			this.m_joints[_loc7_] = null;
			_loc7_ = ASCompat.toInt(_loc7_) + 1;
		}
	}

	public function Clear() {
		this.m_bodyCount = 0;
		this.m_contactCount = 0;
		this.m_jointCount = 0;
	}

	public function Solve(step:B2TimeStep, gravity:B2Vec2, allowSleep:Bool) {
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc6_:B2Body = null;
		var _loc7_:B2Joint = null;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = false;
		var _loc13_ = false;
		var _loc14_ = false;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		_loc4_ = 0;
		while (_loc4_ < this.m_bodyCount) {
			_loc6_ = this.m_bodies[_loc4_];
			if (_loc6_.GetType() == B2Body.b2_dynamicBody) {
				_loc6_.m_linearVelocity.x += step.dt * (gravity.x + _loc6_.m_invMass * _loc6_.m_force.x);
				_loc6_.m_linearVelocity.y += step.dt * (gravity.y + _loc6_.m_invMass * _loc6_.m_force.y);
				_loc6_.m_angularVelocity += step.dt * _loc6_.m_invI * _loc6_.m_torque;
				_loc6_.m_linearVelocity.Multiply(B2Math.Clamp(1 - step.dt * _loc6_.m_linearDamping, 0, 1));
				_loc6_.m_angularVelocity *= B2Math.Clamp(1 - step.dt * _loc6_.m_angularDamping, 0, 1);
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		this.m_contactSolver.Initialize(step, this.m_contacts, this.m_contactCount, this.m_allocator);
		var _loc8_ = this.m_contactSolver;
		_loc8_.InitVelocityConstraints(step);
		_loc4_ = 0;
		while (_loc4_ < this.m_jointCount) {
			_loc7_ = this.m_joints[_loc4_];
			_loc7_.InitVelocityConstraints(step);
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		_loc4_ = 0;
		while (_loc4_ < step.velocityIterations) {
			_loc5_ = 0;
			while (_loc5_ < this.m_jointCount) {
				_loc7_ = this.m_joints[_loc5_];
				_loc7_.SolveVelocityConstraints(step);
				_loc5_ = ASCompat.toInt(_loc5_) + 1;
			}
			_loc8_.SolveVelocityConstraints();
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		_loc4_ = 0;
		while (_loc4_ < this.m_jointCount) {
			_loc7_ = this.m_joints[_loc4_];
			_loc7_.FinalizeVelocityConstraints();
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		_loc8_.FinalizeVelocityConstraints();
		_loc4_ = 0;
		while (_loc4_ < this.m_bodyCount) {
			_loc6_ = this.m_bodies[_loc4_];
			if (_loc6_.GetType() != B2Body.b2_staticBody) {
				_loc9_ = step.dt * _loc6_.m_linearVelocity.x;
				_loc10_ = step.dt * _loc6_.m_linearVelocity.y;
				if (_loc9_ * _loc9_ + _loc10_ * _loc10_ > B2Settings.b2_maxTranslationSquared) {
					_loc6_.m_linearVelocity.Normalize();
					_loc6_.m_linearVelocity.x *= B2Settings.b2_maxTranslation * step.inv_dt;
					_loc6_.m_linearVelocity.y *= B2Settings.b2_maxTranslation * step.inv_dt;
				}
				_loc11_ = step.dt * _loc6_.m_angularVelocity;
				if (_loc11_ * _loc11_ > B2Settings.b2_maxRotationSquared) {
					if (_loc6_.m_angularVelocity < 0) {
						_loc6_.m_angularVelocity = -B2Settings.b2_maxRotation * step.inv_dt;
					} else {
						_loc6_.m_angularVelocity = B2Settings.b2_maxRotation * step.inv_dt;
					}
				}
				_loc6_.m_sweep.c0.SetV(_loc6_.m_sweep.c);
				_loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
				_loc6_.m_sweep.c.x += step.dt * _loc6_.m_linearVelocity.x;
				_loc6_.m_sweep.c.y += step.dt * _loc6_.m_linearVelocity.y;
				_loc6_.m_sweep.a += step.dt * _loc6_.m_angularVelocity;
				_loc6_.SynchronizeTransform();
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		_loc4_ = 0;
		while (_loc4_ < step.positionIterations) {
			_loc12_ = _loc8_.SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
			_loc13_ = true;
			_loc5_ = 0;
			while (_loc5_ < this.m_jointCount) {
				_loc7_ = this.m_joints[_loc5_];
				_loc14_ = _loc7_.SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
				_loc13_ = _loc13_ && _loc14_;
				_loc5_ = ASCompat.toInt(_loc5_) + 1;
			}
			if (_loc12_ && _loc13_) {
				break;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		this.Report(_loc8_.m_constraints);
		if (allowSleep) {
			_loc15_ = ASCompat.MAX_FLOAT;
			_loc16_ = B2Settings.b2_linearSleepTolerance * B2Settings.b2_linearSleepTolerance;
			_loc17_ = B2Settings.b2_angularSleepTolerance * B2Settings.b2_angularSleepTolerance;
			_loc4_ = 0;
			while (_loc4_ < this.m_bodyCount) {
				_loc6_ = this.m_bodies[_loc4_];
				if (_loc6_.GetType() != B2Body.b2_staticBody) {
					if (((_loc6_.m_flags : Int) & (B2Body.e_allowSleepFlag : Int)) == 0) {
						_loc6_.m_sleepTime = 0;
						_loc15_ = 0;
					}
					if (((_loc6_.m_flags : Int) & (B2Body.e_allowSleepFlag : Int)) == 0
						|| _loc6_.m_angularVelocity * _loc6_.m_angularVelocity > _loc17_
						|| B2Math.Dot(_loc6_.m_linearVelocity, _loc6_.m_linearVelocity) > _loc16_) {
						_loc6_.m_sleepTime = 0;
						_loc15_ = 0;
					} else {
						_loc6_.m_sleepTime += step.dt;
						_loc15_ = B2Math.Min(_loc15_, _loc6_.m_sleepTime);
					}
				}
				_loc4_ = ASCompat.toInt(_loc4_) + 1;
			}
			if (_loc15_ >= B2Settings.b2_timeToSleep) {
				_loc4_ = 0;
				while (_loc4_ < this.m_bodyCount) {
					_loc6_ = this.m_bodies[_loc4_];
					_loc6_.SetAwake(false);
					_loc4_ = ASCompat.toInt(_loc4_) + 1;
				}
			}
		}
	}

	public function SolveTOI(subStep:B2TimeStep) {
		var _loc2_ = 0;
		var _loc3_ = 0;
		var _loc6_:B2Body = null;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = false;
		var _loc11_ = false;
		var _loc12_ = false;
		this.m_contactSolver.Initialize(subStep, this.m_contacts, this.m_contactCount, this.m_allocator);
		var _loc4_ = this.m_contactSolver;
		_loc2_ = 0;
		while (_loc2_ < this.m_jointCount) {
			this.m_joints[_loc2_].InitVelocityConstraints(subStep);
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		_loc2_ = 0;
		while (_loc2_ < subStep.velocityIterations) {
			_loc4_.SolveVelocityConstraints();
			_loc3_ = 0;
			while (_loc3_ < this.m_jointCount) {
				this.m_joints[_loc3_].SolveVelocityConstraints(subStep);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		_loc2_ = 0;
		while (_loc2_ < this.m_bodyCount) {
			_loc6_ = this.m_bodies[_loc2_];
			if (_loc6_.GetType() != B2Body.b2_staticBody) {
				_loc7_ = subStep.dt * _loc6_.m_linearVelocity.x;
				_loc8_ = subStep.dt * _loc6_.m_linearVelocity.y;
				if (_loc7_ * _loc7_ + _loc8_ * _loc8_ > B2Settings.b2_maxTranslationSquared) {
					_loc6_.m_linearVelocity.Normalize();
					_loc6_.m_linearVelocity.x *= B2Settings.b2_maxTranslation * subStep.inv_dt;
					_loc6_.m_linearVelocity.y *= B2Settings.b2_maxTranslation * subStep.inv_dt;
				}
				_loc9_ = subStep.dt * _loc6_.m_angularVelocity;
				if (_loc9_ * _loc9_ > B2Settings.b2_maxRotationSquared) {
					if (_loc6_.m_angularVelocity < 0) {
						_loc6_.m_angularVelocity = -B2Settings.b2_maxRotation * subStep.inv_dt;
					} else {
						_loc6_.m_angularVelocity = B2Settings.b2_maxRotation * subStep.inv_dt;
					}
				}
				_loc6_.m_sweep.c0.SetV(_loc6_.m_sweep.c);
				_loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
				_loc6_.m_sweep.c.x += subStep.dt * _loc6_.m_linearVelocity.x;
				_loc6_.m_sweep.c.y += subStep.dt * _loc6_.m_linearVelocity.y;
				_loc6_.m_sweep.a += subStep.dt * _loc6_.m_angularVelocity;
				_loc6_.SynchronizeTransform();
			}
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		var _loc5_:Float = 0.75;
		_loc2_ = 0;
		while (_loc2_ < subStep.positionIterations) {
			_loc10_ = _loc4_.SolvePositionConstraints(_loc5_);
			_loc11_ = true;
			_loc3_ = 0;
			while (_loc3_ < this.m_jointCount) {
				_loc12_ = this.m_joints[_loc3_].SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
				_loc11_ = _loc11_ && _loc12_;
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			if (_loc10_ && _loc11_) {
				break;
			}
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		this.Report(_loc4_.m_constraints);
	}

	public function Report(constraints:Vector<B2ContactConstraint>) {
		var _loc3_:B2Contact = null;
		var _loc4_:B2ContactConstraint = null;
		var _loc5_ = 0;
		if (this.m_listener == null) {
			return;
		}
		var _loc2_ = 0;
		while (_loc2_ < this.m_contactCount) {
			_loc3_ = this.m_contacts[_loc2_];
			_loc4_ = constraints[_loc2_];
			_loc5_ = 0;
			while (_loc5_ < _loc4_.pointCount) {
				s_impulse.normalImpulses[_loc5_] = _loc4_.points[_loc5_].normalImpulse;
				s_impulse.tangentImpulses[_loc5_] = _loc4_.points[_loc5_].tangentImpulse;
				_loc5_ = ASCompat.toInt(_loc5_) + 1;
			}
			this.m_listener.PostSolve(_loc3_, s_impulse);
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}

	public function AddBody(body:B2Body) {
		body.m_islandIndex = this.m_bodyCount;
		this.m_bodies[this.m_bodyCount++] = body;
	}

	public function AddContact(contact:B2Contact) {
		this.m_contacts[this.m_contactCount++] = contact;
	}

	public function AddJoint(joint:B2Joint) {
		this.m_joints[this.m_jointCount++] = joint;
	}
}
