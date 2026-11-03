package box2D.dynamics;

import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactConstraint;
import box2D.dynamics.contacts.B2ContactSolver;
import box2D.dynamics.joints.B2Joint;
import box2dcompat.As3Array;
import flash.Boot;

class B2Island {
	public static var s_impulse:B2ContactImpulse = new B2ContactImpulse();

	public var m_listener:B2ContactListener;

	public var m_joints:Array<ASAny>;

	public var m_jointCount:Int = 0;

	public var m_jointCapacity:Int = 0;

	public var m_contacts:Array<ASAny>;

	public var m_contactSolver:B2ContactSolver;

	public var m_contactCount:Int = 0;

	public var m_contactCapacity:Int = 0;

	public var m_bodyCount:Int = 0;

	public var m_bodyCapacity:Int = 0;

	public var m_bodies:Array<ASAny>;

	public var m_allocator:ASAny;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_jointCapacity = 0;
		m_contactCapacity = 0;
		m_bodyCapacity = 0;
		m_contactCount = 0;
		m_jointCount = 0;
		m_bodyCount = 0;
		m_bodies = [];
		m_contacts = [];
		m_joints = [];
	}

	public function solveTOI(subStep:B2TimeStep) {
		SolveTOI(subStep);
	}

	public function solve(step:B2TimeStep, gravity:B2Vec2, allowSleep:Bool) {
		Solve(step, gravity, allowSleep);
	}

	public function report(constraints:Array<ASAny>) {
		var _loc4_ = 0;
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Contact);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc9_ = 0;
		if (m_listener == null) {
			return;
		}
		var _loc2_ = 0;
		var _loc3_ = m_contactCount;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			_loc5_ = m_contacts[_loc4_];
			_loc6_ = constraints[_loc4_];
			_loc7_ = 0;
			_loc8_ = ASCompat.toInt(_loc6_.pointCount);
			while (_loc7_ < _loc8_) {
				_loc9_ = _loc7_++;
				B2Island.s_impulse.normalImpulses[_loc9_] = _loc6_.points[_loc9_].normalImpulse;
				B2Island.s_impulse.tangentImpulses[_loc9_] = _loc6_.points[_loc9_].tangentImpulse;
			}
			m_listener.postSolve(ASCompat.coerce(_loc5_, box2D.dynamics.contacts.B2Contact), B2Island.s_impulse);
		}
	}

	public function initialize(bodyCapacity:Int, contactCapacity:Int, jointCapacity:Int, allocator:ASAny, listener:B2ContactListener,
			contactSolver:B2ContactSolver) {
		Initialize(bodyCapacity, contactCapacity, jointCapacity, allocator, listener, contactSolver);
	}

	public function clear() {
		Clear();
	}

	public function addJoint(joint:B2Joint) {
		AddJoint(joint);
	}

	public function addContact(contact:B2Contact) {
		AddContact(contact);
	}

	public function addBody(body:B2Body) {
		AddBody(body);
	}

	public function SolveTOI(subStep:B2TimeStep) {
		var __tmpAssignObj0:ASAny;
		var __tmpAssignObj1:ASAny;
		var __tmpAssignObj2:ASAny;
		var __tmpAssignObj3:ASAny;
		var __tmpAssignObj4:ASAny;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_ = 0;
		var _loc11_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = false;
		var _loc16_ = false;
		var _loc17_ = false;
		m_contactSolver.initialize(subStep, m_contacts, m_contactCount, m_allocator);
		var _loc4_ = m_contactSolver;
		var _loc5_ = 0;
		var _loc6_ = m_jointCount;
		while (_loc5_ < _loc6_) {
			_loc7_ = _loc5_++;
			m_joints[_loc7_].initVelocityConstraints(subStep);
		}
		_loc5_ = 0;
		_loc6_ = subStep.velocityIterations;
		while (_loc5_ < _loc6_) {
			_loc7_ = _loc5_++;
			_loc4_.solveVelocityConstraints();
			_loc8_ = 0;
			_loc9_ = m_jointCount;
			while (_loc8_ < _loc9_) {
				_loc10_ = _loc8_++;
				m_joints[_loc10_].solveVelocityConstraints(subStep);
			}
		}
		_loc5_ = 0;
		_loc6_ = m_bodyCount;
		while (_loc5_ < _loc6_) {
			_loc7_ = _loc5_++;
			_loc11_ = m_bodies[_loc7_];
			if (ASCompat.toNumberField(_loc11_, "m_type") != 0) {
				_loc12_ = subStep.dt * ASCompat.toNumberField(_loc11_.m_linearVelocity, "x");
				_loc13_ = subStep.dt * ASCompat.toNumberField(_loc11_.m_linearVelocity, "y");
				if (_loc12_ * _loc12_ + _loc13_ * _loc13_ > B2Settings.b2_maxTranslationSquared) {
					_loc11_.m_linearVelocity.normalize();
					__tmpAssignObj0 = _loc11_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj0, "x", __tmpAssignObj0.x * B2Settings.b2_maxTranslation * subStep.inv_dt);
					__tmpAssignObj1 = _loc11_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj1, "y", __tmpAssignObj1.y * B2Settings.b2_maxTranslation * subStep.inv_dt);
				}
				_loc14_ = subStep.dt * ASCompat.toNumberField(_loc11_, "m_angularVelocity");
				if (_loc14_ * _loc14_ > B2Settings.b2_maxRotationSquared) {
					if (ASCompat.toNumberField(_loc11_, "m_angularVelocity") < 0) {
						ASCompat.setProperty(_loc11_, "m_angularVelocity", -B2Settings.b2_maxRotation * subStep.inv_dt);
					} else {
						ASCompat.setProperty(_loc11_, "m_angularVelocity", B2Settings.b2_maxRotation * subStep.inv_dt);
					}
				}
				_loc11_.m_sweep.c0.setV(_loc11_.m_sweep.c);
				ASCompat.setProperty(_loc11_.m_sweep, "a0", _loc11_.m_sweep.a);
				__tmpAssignObj2 = _loc11_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj2, "x", __tmpAssignObj2.x + subStep.dt * ASCompat.toNumberField(_loc11_.m_linearVelocity, "x"));
				__tmpAssignObj3 = _loc11_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj3, "y", __tmpAssignObj3.y + subStep.dt * ASCompat.toNumberField(_loc11_.m_linearVelocity, "y"));
				__tmpAssignObj4 = _loc11_.m_sweep;
				ASCompat.setProperty(__tmpAssignObj4, "a", __tmpAssignObj4.a + subStep.dt * ASCompat.toNumberField(_loc11_, "m_angularVelocity"));
				_loc11_.synchronizeTransform();
			}
		}
		_loc12_ = 0.75;
		_loc5_ = 0;
		_loc6_ = subStep.positionIterations;
		while (_loc5_ < _loc6_) {
			_loc7_ = _loc5_++;
			_loc15_ = _loc4_.solvePositionConstraints(_loc12_);
			_loc16_ = true;
			_loc8_ = 0;
			_loc9_ = m_jointCount;
			while (_loc8_ < _loc9_) {
				_loc10_ = _loc8_++;
				_loc17_ = ASCompat.toBool(m_joints[_loc10_].solvePositionConstraints(B2Settings.b2_contactBaumgarte));
				_loc16_ = _loc16_ && _loc17_;
			}
			if (_loc15_ && _loc16_) {
				break;
			}
		}
		report(_loc4_.m_constraints);
	}

	public function Solve(step:B2TimeStep, gravity:B2Vec2, allowSleep:Bool) {
		var __tmpAssignObj5:ASAny;
		var __tmpAssignObj6:ASAny;
		var __tmpAssignObj7:ASAny;
		var __tmpAssignObj8:ASAny;
		var __tmpAssignObj9:ASAny;
		var __tmpAssignObj10:ASAny;
		var __tmpAssignObj11:ASAny;
		var __tmpAssignObj12:ASAny;
		var __tmpAssignObj13:ASAny;
		var __tmpAssignObj14:ASAny;
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2Joint);
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_ = 0;
		var _loc12_ = 0;
		var _loc13_ = 0;
		var _loc14_ = 0;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = false;
		var _loc19_ = false;
		var _loc20_ = false;
		_loc8_ = 0;
		_loc9_ = m_bodyCount;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc6_ = m_bodies[_loc10_];
			if (ASCompat.toNumberField(_loc6_, "m_type") == 2) {
				__tmpAssignObj5 = _loc6_.m_linearVelocity;
				ASCompat.setProperty(__tmpAssignObj5, "x",
					__tmpAssignObj5.x + step.dt * (ASCompat.toNumberField(_loc6_, "m_gravityScale") * gravity.x
						+ ASCompat.toNumberField(_loc6_, "m_invMass") * ASCompat.toNumberField(_loc6_.m_force, "x")));
				__tmpAssignObj6 = _loc6_.m_linearVelocity;
				ASCompat.setProperty(__tmpAssignObj6, "y",
					__tmpAssignObj6.y + step.dt * (ASCompat.toNumberField(_loc6_, "m_gravityScale") * gravity.y
						+ ASCompat.toNumberField(_loc6_, "m_invMass") * ASCompat.toNumberField(_loc6_.m_force, "y")));
				__tmpAssignObj7 = _loc6_;
				ASCompat.setProperty(__tmpAssignObj7, "m_angularVelocity",
					__tmpAssignObj7.m_angularVelocity + step.dt * ASCompat.toNumberField(_loc6_, "m_invI") * ASCompat.toNumberField(_loc6_, "m_torque"));
				_loc6_.m_linearVelocity.multiply(B2Math.clamp(1 - step.dt * ASCompat.toNumberField(_loc6_, "m_linearDamping"), 0, 1));
				__tmpAssignObj8 = _loc6_;
				ASCompat.setProperty(__tmpAssignObj8, "m_angularVelocity",
					__tmpAssignObj8.m_angularVelocity * B2Math.clamp(1 - step.dt * ASCompat.toNumberField(_loc6_, "m_angularDamping"), 0, 1));
			}
		}
		m_contactSolver.initialize(step, m_contacts, m_contactCount, m_allocator);
		var _loc11_ = m_contactSolver;
		_loc11_.initVelocityConstraints(step);
		_loc8_ = 0;
		_loc9_ = m_jointCount;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc7_ = m_joints[_loc10_];
			_loc7_.initVelocityConstraints(step);
		}
		_loc8_ = 0;
		_loc9_ = step.velocityIterations;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc12_ = 0;
			_loc13_ = m_jointCount;
			while (_loc12_ < _loc13_) {
				_loc14_ = _loc12_++;
				_loc7_ = m_joints[_loc14_];
				_loc7_.solveVelocityConstraints(step);
			}
			_loc11_.solveVelocityConstraints();
		}
		_loc8_ = 0;
		_loc9_ = m_jointCount;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc7_ = m_joints[_loc10_];
			_loc7_.finalizeVelocityConstraints();
		}
		_loc11_.finalizeVelocityConstraints();
		_loc8_ = 0;
		_loc9_ = m_bodyCount;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc6_ = m_bodies[_loc10_];
			if (ASCompat.toNumberField(_loc6_, "m_type") != 0) {
				_loc15_ = step.dt * ASCompat.toNumberField(_loc6_.m_linearVelocity, "x");
				_loc16_ = step.dt * ASCompat.toNumberField(_loc6_.m_linearVelocity, "y");
				if (_loc15_ * _loc15_ + _loc16_ * _loc16_ > B2Settings.b2_maxTranslationSquared) {
					_loc6_.m_linearVelocity.normalize();
					__tmpAssignObj9 = _loc6_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj9, "x", __tmpAssignObj9.x * B2Settings.b2_maxTranslation * step.inv_dt);
					__tmpAssignObj10 = _loc6_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj10, "y", __tmpAssignObj10.y * B2Settings.b2_maxTranslation * step.inv_dt);
				}
				_loc17_ = step.dt * ASCompat.toNumberField(_loc6_, "m_angularVelocity");
				if (_loc17_ * _loc17_ > B2Settings.b2_maxRotationSquared) {
					if (ASCompat.toNumberField(_loc6_, "m_angularVelocity") < 0) {
						ASCompat.setProperty(_loc6_, "m_angularVelocity", -B2Settings.b2_maxRotation * step.inv_dt);
					} else {
						ASCompat.setProperty(_loc6_, "m_angularVelocity", B2Settings.b2_maxRotation * step.inv_dt);
					}
				}
				_loc6_.m_sweep.c0.setV(_loc6_.m_sweep.c);
				ASCompat.setProperty(_loc6_.m_sweep, "a0", _loc6_.m_sweep.a);
				__tmpAssignObj11 = _loc6_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj11, "x", __tmpAssignObj11.x + step.dt * ASCompat.toNumberField(_loc6_.m_linearVelocity, "x"));
				__tmpAssignObj12 = _loc6_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj12, "y", __tmpAssignObj12.y + step.dt * ASCompat.toNumberField(_loc6_.m_linearVelocity, "y"));
				__tmpAssignObj13 = _loc6_.m_sweep;
				ASCompat.setProperty(__tmpAssignObj13, "a", __tmpAssignObj13.a + step.dt * ASCompat.toNumberField(_loc6_, "m_angularVelocity"));
				_loc6_.synchronizeTransform();
			}
		}
		_loc8_ = 0;
		_loc9_ = step.positionIterations;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			_loc18_ = _loc11_.solvePositionConstraints(B2Settings.b2_contactBaumgarte);
			_loc19_ = true;
			_loc12_ = 0;
			_loc13_ = m_jointCount;
			while (_loc12_ < _loc13_) {
				_loc14_ = _loc12_++;
				_loc7_ = m_joints[_loc14_];
				_loc20_ = ASCompat.toBool(_loc7_.solvePositionConstraints(B2Settings.b2_contactBaumgarte));
				_loc19_ = _loc19_ && _loc20_;
			}
			if (_loc18_ && _loc19_) {
				break;
			}
		}
		report(_loc11_.m_constraints);
		if (allowSleep) {
			_loc15_ = ASCompat.MAX_FLOAT;
			_loc16_ = B2Settings.b2_linearSleepTolerance * B2Settings.b2_linearSleepTolerance;
			_loc17_ = B2Settings.b2_angularSleepTolerance * B2Settings.b2_angularSleepTolerance;
			_loc8_ = 0;
			_loc9_ = m_bodyCount;
			while (_loc8_ < _loc9_) {
				_loc10_ = _loc8_++;
				_loc6_ = m_bodies[_loc10_];
				if (ASCompat.toNumberField(_loc6_, "m_type") != 0) {
					if ((ASCompat.toInt(_loc6_.m_flags) & B2Body.e_allowSleepFlag) == 0) {
						ASCompat.setProperty(_loc6_, "m_sleepTime", 0);
						_loc15_ = 0;
					}
					if ((ASCompat.toInt(_loc6_.m_flags) & B2Body.e_allowSleepFlag) == 0
						|| ASCompat.toNumberField(_loc6_, "m_angularVelocity") * ASCompat.toNumberField(_loc6_, "m_angularVelocity") > _loc17_
						|| B2Math.dot(ASCompat.coerce(_loc6_.m_linearVelocity, box2D.common.math.B2Vec2),
							ASCompat.coerce(_loc6_.m_linearVelocity, box2D.common.math.B2Vec2)) > _loc16_) {
						ASCompat.setProperty(_loc6_, "m_sleepTime", 0);
						_loc15_ = 0;
					} else {
						__tmpAssignObj14 = _loc6_;
						ASCompat.setProperty(__tmpAssignObj14, "m_sleepTime", __tmpAssignObj14.m_sleepTime + step.dt);
						_loc15_ = B2Math.min(_loc15_, ASCompat.toNumberField(_loc6_, "m_sleepTime"));
					}
				}
			}
			if (_loc15_ >= B2Settings.b2_timeToSleep) {
				_loc8_ = 0;
				_loc9_ = m_bodyCount;
				while (_loc8_ < _loc9_) {
					_loc10_ = _loc8_++;
					_loc6_ = m_bodies[_loc10_];
					_loc6_.setAwake(false);
				}
			}
		}
	}

	public function Report(constraints:ASAny) {
		report(As3Array.of(constraints));
	}

	public function Initialize(bodyCapacity:Int, contactCapacity:Int, jointCapacity:Int, allocator:ASAny, listener:B2ContactListener,
			contactSolver:B2ContactSolver) {
		var _loc10_ = 0;
		m_bodyCapacity = bodyCapacity;
		m_contactCapacity = contactCapacity;
		m_jointCapacity = jointCapacity;
		m_bodyCount = 0;
		m_contactCount = 0;
		m_jointCount = 0;
		m_allocator = allocator;
		m_listener = listener;
		m_contactSolver = contactSolver;
		var _loc8_ = m_bodies.length;
		var _loc9_ = bodyCapacity;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			m_bodies[_loc10_] = null;
		}
		_loc8_ = m_contacts.length;
		_loc9_ = contactCapacity;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			m_contacts[_loc10_] = null;
		}
		_loc8_ = m_joints.length;
		_loc9_ = jointCapacity;
		while (_loc8_ < _loc9_) {
			_loc10_ = _loc8_++;
			m_joints[_loc10_] = null;
		}
	}

	public function Clear() {
		m_bodyCount = 0;
		m_contactCount = 0;
		m_jointCount = 0;
	}

	public function AddJoint(joint:B2Joint) {
		var _temp_2 = m_joints;
		var _loc2_:Int;
		m_jointCount = (_loc2_ = m_jointCount) + 1;
		_temp_2[_loc2_] = joint;
	}

	public function AddContact(contact:B2Contact) {
		var _temp_2 = m_contacts;
		var _loc2_:Int;
		m_contactCount = (_loc2_ = m_contactCount) + 1;
		_temp_2[_loc2_] = contact;
	}

	public function AddBody(body:B2Body) {
		body.m_islandIndex = m_bodyCount;
		var _temp_2 = m_bodies;
		var _loc2_:Int;
		m_bodyCount = (_loc2_ = m_bodyCount) + 1;
		_temp_2[_loc2_] = body;
	}
}
