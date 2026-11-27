package box2D.dynamics;

import box2D.collision.IBroadPhase;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.collision.B2AABB;
import box2D.collision.B2DynamicTreeBroadPhase;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Math;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Color;
import box2D.common.B2Settings;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.dynamics.contacts.B2ContactSolver;
import box2D.dynamics.controllers.B2Controller;
import box2D.dynamics.controllers.B2ControllerEdge;
import box2D.dynamics.joints.B2Joint;
import box2D.dynamics.joints.B2JointDef;
import box2D.dynamics.joints.B2JointEdge;
import box2D.dynamics.joints.B2PulleyJoint;

class B2World {
	public static var m_warmStarting:Bool = false;

	public static var m_continuousPhysics:Bool = false;

	public static var e_newFixture:Int = 1;

	public static var e_locked:Int = 2;

	public static var s_timestep2:B2TimeStep = new B2TimeStep();

	public static var s_xf:B2Transform = new B2Transform();

	public static var s_backupA:B2Sweep = new B2Sweep();

	public static var s_backupB:B2Sweep = new B2Sweep();

	public static var s_timestep:B2TimeStep = new B2TimeStep();

	public static var s_queue:Array<ASAny>;

	public static var s_jointColor:B2Color = new B2Color(0.5, 0.8, 0.8);

	public var s_stack:Array<ASAny>;

	public var m_jointList:B2Joint;

	public var m_jointCount:Int = 0;

	public var m_island:B2Island;

	public var m_inv_dt0:Float = Math.NaN;

	public var m_groundBody:B2Body;

	public var m_gravity:B2Vec2;

	public var m_flags:Int = 0;

	public var m_destructionListener:B2DestructionListener;

	public var m_debugDraw:B2DebugDraw;

	public var m_controllerList:B2Controller;

	public var m_controllerCount:Int = 0;

	public var m_contactSolver:B2ContactSolver;

	public var m_contactManager:B2ContactManager;

	public var m_contactList:B2Contact;

	public var m_bodyList:B2Body;

	public var m_bodyCount:Int = 0;

	public var m_allowSleep:Bool = false;

	public function new(gravity:B2Vec2 = /*undefined*/ null, doSleep:Bool = false) {
		s_stack = [];
		m_contactManager = new B2ContactManager();
		m_contactSolver = new B2ContactSolver();
		m_island = new B2Island();
		m_destructionListener = null;
		m_debugDraw = null;
		m_bodyList = null;
		m_contactList = null;
		m_jointList = null;
		m_controllerList = null;
		m_bodyCount = 0;
		m_jointCount = 0;
		m_controllerCount = 0;
		B2World.m_warmStarting = true;
		B2World.m_continuousPhysics = true;
		m_allowSleep = doSleep;
		m_gravity = gravity;
		m_inv_dt0 = 0;
		m_flags = 0;
		m_contactManager.m_world = this;
		var _loc3_ = new B2BodyDef();
		m_groundBody = createBody(_loc3_);
	}

	public function validate() {
		Validate();
	}

	public function step(dt:Float, velocityIterations:Int, positionIterations:Int) {
		Step(dt, velocityIterations, positionIterations);
	}

	public function solveTOI(step:B2TimeStep) {
		SolveTOI(step);
	}

	public function solve(step:B2TimeStep) {
		Solve(step);
	}

	public function setWarmStarting(flag:Bool) {
		SetWarmStarting(flag);
	}

	public function setGravity(gravity:B2Vec2) {
		SetGravity(gravity);
	}

	public function setDestructionListener(listener:B2DestructionListener) {
		SetDestructionListener(listener);
	}

	public function setDebugDraw(debugDraw:B2DebugDraw) {
		SetDebugDraw(debugDraw);
	}

	public function setContinuousPhysics(flag:Bool) {
		SetContinuousPhysics(flag);
	}

	public function setContactListener(listener:B2ContactListener) {
		SetContactListener(listener);
	}

	public function setContactFilter(filter:B2ContactFilter) {
		SetContactFilter(filter);
	}

	public function setBroadPhase(broadPhase:IBroadPhase) {
		SetBroadPhase(broadPhase);
	}

	public function removeController(c:B2Controller) {
		RemoveController(c);
	}

	public function rayCastOne(point1:B2Vec2, point2:B2Vec2):B2Fixture {
		return RayCastOne(point1, point2);
	}

	public function rayCastAll(point1:B2Vec2, point2:B2Vec2):Array<ASAny> {
		return RayCastAll(point1, point2);
	}

	public function rayCast(callbackMethod:ASFunction, point1:B2Vec2, point2:B2Vec2) {
		RayCast(callbackMethod, point1, point2);
	}

	public function queryShape(callbackMethod:ASFunction, shape:B2Shape, transform:B2Transform = /*undefined*/ null) {
		QueryShape(callbackMethod, shape, transform);
	}

	public function queryPoint(callbackMethod:ASFunction, p:B2Vec2) {
		QueryPoint(callbackMethod, p);
	}

	public function queryAABB(callbackMethod:ASFunction, aabb:B2AABB) {
		QueryAABB(callbackMethod, aabb);
	}

	public function isLocked():Bool {
		return IsLocked();
	}

	public function getProxyCount():Int {
		return GetProxyCount();
	}

	public function getJointList():B2Joint {
		return GetJointList();
	}

	public function getJointCount():Int {
		return GetJointCount();
	}

	public function getGroundBody():B2Body {
		return GetGroundBody();
	}

	public function getGravity():B2Vec2 {
		return GetGravity();
	}

	public function getContactList():B2Contact {
		return GetContactList();
	}

	public function getContactCount():Int {
		return GetContactCount();
	}

	public function getBodyList():B2Body {
		return GetBodyList();
	}

	public function getBodyCount():Int {
		return GetBodyCount();
	}

	public function drawShape(shape:B2Shape, xf:B2Transform, color:B2Color) {
		DrawShape(shape, xf, color);
	}

	public function drawJoint(joint:B2Joint) {
		DrawJoint(joint);
	}

	public function drawDebugData() {
		DrawDebugData();
	}

	public function destroyJoint(j:B2Joint) {
		DestroyJoint(j);
	}

	public function destroyController(controller:B2Controller) {
		DestroyController(controller);
	}

	public function destroyBody(b:B2Body) {
		DestroyBody(b);
	}

	public function createJoint(def:B2JointDef):B2Joint {
		return CreateJoint(def);
	}

	public function createController(controller:B2Controller):B2Controller {
		return CreateController(controller);
	}

	public function createBody(def:B2BodyDef):B2Body {
		return CreateBody(def);
	}

	public function clearForces() {
		ClearForces();
	}

	public function addController(c:B2Controller):B2Controller {
		return AddController(c);
	}

	public function Validate() {
		m_contactManager.m_broadPhase.validate();
	}

	public function Step(dt:Float, velocityIterations:Int, positionIterations:Int) {
		var _loc4_ = m_contactManager.m_broadPhase;
		var _loc5_ = ASCompat.reinterpretAs(_loc4_, B2DynamicTreeBroadPhase);
		if (_loc5_ != null) {
			_loc5_.endAbandonedQueries();
		}
		if ((m_flags & B2World.e_newFixture) != 0) {
			m_contactManager.findNewContacts();
			m_flags = m_flags & ~B2World.e_newFixture;
		}
		m_flags = m_flags | B2World.e_locked;
		var _loc6_ = B2World.s_timestep2;
		_loc6_.dt = dt;
		_loc6_.velocityIterations = velocityIterations;
		_loc6_.positionIterations = positionIterations;
		if (dt > 0) {
			_loc6_.inv_dt = 1 / dt;
		} else {
			_loc6_.inv_dt = 0;
		}
		_loc6_.dtRatio = m_inv_dt0 * dt;
		_loc6_.warmStarting = B2World.m_warmStarting;
		m_contactManager.collide();
		if (_loc6_.dt > 0) {
			solve(_loc6_);
		}
		if (B2World.m_continuousPhysics && _loc6_.dt > 0) {
			solveTOI(_loc6_);
		}
		if (_loc6_.dt > 0) {
			m_inv_dt0 = _loc6_.inv_dt;
		}
		m_flags = m_flags & ~B2World.e_locked;
	}

	public function SolveTOI(step:B2TimeStep) {
		var __tmpAssignObj15:ASAny;
		var __tmpAssignObj16:ASAny;
		var __tmpAssignObj17:ASAny;
		var __tmpAssignObj18:ASAny;
		var __tmpAssignObj19:ASAny;
		var __tmpAssignObj20:ASAny;
		var _loc2_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc3_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc12_:ASAny = ASCompat.dynamicAs(null, B2Contact);
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc17_ = 0;
		var _loc18_ = 0;
		var _loc19_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc20_:ASAny = ASCompat.dynamicAs(null, B2JointEdge);
		var _loc21_ = ASCompat.dynamicAs(null, B2TimeStep);
		var _loc23_ = 0;
		var _loc24_ = 0;
		var _loc25_ = 0;
		var _loc7_ = m_island;
		_loc7_.initialize(m_bodyCount, B2Settings.b2_maxTOIContactsPerIsland, B2Settings.b2_maxTOIJointsPerIsland, null, m_contactManager.m_contactListener,
			m_contactSolver);
		var _loc8_ = B2World.s_queue;
		var _loc9_ = m_bodyList;
		while (_loc9_ != null) {
			_loc9_.m_flags = _loc9_.m_flags & ~B2Body.e_islandFlag;
			_loc9_.m_sweep.t0 = 0;
			_loc9_ = _loc9_.m_next;
		}
		var _loc10_ = m_contactList;
		while (_loc10_ != null) {
			_loc10_.m_flags = _loc10_.m_flags & ~(B2Contact.e_toiFlag | B2Contact.e_islandFlag);
			_loc10_ = _loc10_.m_next;
		}
		var _loc11_ = m_jointList;
		while (_loc11_ != null) {
			_loc11_.m_islandFlag = false;
			_loc11_ = _loc11_.m_next;
		}
		while (true) {
			_loc12_ = null;
			_loc13_ = 1;
			_loc10_ = m_contactList;
			while (_loc10_ != null) {
				if (_loc10_.isSensor() == true || _loc10_.isEnabled() == false || _loc10_.isContinuous() == false) {
					_loc10_ = _loc10_.m_next;
				} else {
					_loc14_ = 1;
					if ((_loc10_.m_flags & B2Contact.e_toiFlag) != 0) {
						_loc14_ = _loc10_.m_toi;
					} else {
						_loc2_ = _loc10_.m_fixtureA;
						_loc3_ = _loc10_.m_fixtureB;
						_loc4_ = _loc2_.m_body;
						_loc5_ = _loc3_.m_body;
						if ((ASCompat.toNumberField(_loc4_, "m_type") != 2
							|| (ASCompat.toInt(_loc4_.m_flags) & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false)
							&& (ASCompat.toNumberField(_loc5_, "m_type") != 2
								|| (ASCompat.toInt(_loc5_.m_flags) & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false)) {
							_loc10_ = _loc10_.m_next;
							continue;
						}
						_loc15_ = ASCompat.toNumberField(_loc4_.m_sweep, "t0");
						if (_loc4_.m_sweep.t0 < _loc5_.m_sweep.t0) {
							_loc15_ = ASCompat.toNumberField(_loc5_.m_sweep, "t0");
							_loc4_.m_sweep.advance(_loc15_);
						} else if (_loc5_.m_sweep.t0 < _loc4_.m_sweep.t0) {
							_loc15_ = ASCompat.toNumberField(_loc4_.m_sweep, "t0");
							_loc5_.m_sweep.advance(_loc15_);
						}
						_loc14_ = _loc10_.computeTOI(ASCompat.coerce(_loc4_.m_sweep, box2D.common.math.B2Sweep),
							ASCompat.coerce(_loc5_.m_sweep, box2D.common.math.B2Sweep));
						B2Settings.b2Assert(0 <= _loc14_ && _loc14_ <= 1);
						if (_loc14_ > 0 && _loc14_ < 1) {
							_loc14_ = (1 - _loc14_) * _loc15_ + _loc14_;
							if (_loc14_ > 1) {
								_loc14_ = 1;
							}
						}
						_loc10_.m_toi = _loc14_;
						_loc10_.m_flags = _loc10_.m_flags | B2Contact.e_toiFlag;
					}
					if (ASCompat.MIN_FLOAT < _loc14_ && _loc14_ < _loc13_) {
						_loc12_ = _loc10_;
						_loc13_ = _loc14_;
					}
					_loc10_ = _loc10_.m_next;
				}
			}
			if (_loc12_ == null || 1 - 100 * ASCompat.MIN_FLOAT < _loc13_) {
				break;
			}
			_loc2_ = _loc12_.m_fixtureA;
			_loc3_ = _loc12_.m_fixtureB;
			_loc4_ = _loc2_.m_body;
			_loc5_ = _loc3_.m_body;
			B2World.s_backupA.set(ASCompat.coerce(_loc4_.m_sweep, box2D.common.math.B2Sweep));
			B2World.s_backupB.set(ASCompat.coerce(_loc5_.m_sweep, box2D.common.math.B2Sweep));
			_loc4_.advance(_loc13_);
			_loc5_.advance(_loc13_);
			_loc12_.update(m_contactManager.m_contactListener);
			__tmpAssignObj15 = _loc12_;
			ASCompat.setProperty(__tmpAssignObj15, "m_flags", ASCompat.toInt(__tmpAssignObj15.m_flags) & ~B2Contact.e_toiFlag);
			if (_loc12_.isSensor() == true || _loc12_.isEnabled() == false) {
				_loc4_.m_sweep.set(B2World.s_backupA);
				_loc5_.m_sweep.set(B2World.s_backupB);
				_loc4_.synchronizeTransform();
				_loc5_.synchronizeTransform();
			} else if (_loc12_.isTouching() != false) {
				_loc16_ = _loc4_;
				if (ASCompat.toNumberField(_loc16_, "m_type") != 2) {
					_loc16_ = _loc5_;
				}
				_loc7_.clear();
				_loc17_ = 0;
				_loc18_ = 0;
				_loc8_[_loc17_ + _loc18_++] = _loc16_;
				__tmpAssignObj16 = _loc16_;
				ASCompat.setProperty(__tmpAssignObj16, "m_flags", ASCompat.toInt(__tmpAssignObj16.m_flags) | B2Body.e_islandFlag);
				while (_loc18_ > 0) {
					_loc9_ = ASCompat.coerce(_loc8_[_loc17_++], box2D.dynamics.B2Body);
					_loc18_--;
					_loc7_.addBody(_loc9_);
					if ((_loc9_.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
						_loc9_.setAwake(true);
					}
					if (_loc9_.m_type == 2) {
						_loc6_ = _loc9_.m_contactList;
						while (_loc6_ != null) {
							if (_loc7_.m_contactCount == _loc7_.m_contactCapacity) {
								_loc6_ = _loc6_.next;
								break;
							}
							if ((ASCompat.toInt(_loc6_.contact.m_flags) & B2Contact.e_islandFlag) != 0) {
								_loc6_ = _loc6_.next;
							} else if (_loc6_.contact.isSensor() == true || _loc6_.contact.isEnabled() == false || _loc6_.contact.isTouching() == false) {
								_loc6_ = _loc6_.next;
							} else {
								_loc7_.addContact(ASCompat.coerce(_loc6_.contact, box2D.dynamics.contacts.B2Contact));
								__tmpAssignObj17 = _loc6_.contact;
								ASCompat.setProperty(__tmpAssignObj17, "m_flags", ASCompat.toInt(__tmpAssignObj17.m_flags) | B2Contact.e_islandFlag);
								_loc19_ = _loc6_.other;
								if ((ASCompat.toInt(_loc19_.m_flags) & B2Body.e_islandFlag) != 0) {
									_loc6_ = _loc6_.next;
								} else {
									if (ASCompat.toNumberField(_loc19_, "m_type") != 0) {
										_loc19_.advance(_loc13_);
										_loc19_.setAwake(true);
									}
									_loc8_[_loc17_ + _loc18_] = _loc19_;
									_loc18_++;
									__tmpAssignObj18 = _loc19_;
									ASCompat.setProperty(__tmpAssignObj18, "m_flags", ASCompat.toInt(__tmpAssignObj18.m_flags) | B2Body.e_islandFlag);
									_loc6_ = _loc6_.next;
								}
							}
						}
						_loc20_ = _loc9_.m_jointList;
						while (_loc20_ != null) {
							if (_loc7_.m_jointCount == _loc7_.m_jointCapacity) {
								_loc20_ = _loc20_.next;
							} else if (_loc20_.joint.m_islandFlag == true) {
								_loc20_ = _loc20_.next;
							} else {
								_loc19_ = _loc20_.other;
								if ((ASCompat.toInt(_loc19_.m_flags) & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
									_loc20_ = _loc20_.next;
								} else {
									_loc7_.addJoint(ASCompat.coerce(_loc20_.joint, box2D.dynamics.joints.B2Joint));
									ASCompat.setProperty(_loc20_.joint, "m_islandFlag", true);
									if ((ASCompat.toInt(_loc19_.m_flags) & B2Body.e_islandFlag) != 0) {
										_loc20_ = _loc20_.next;
									} else {
										if (ASCompat.toNumberField(_loc19_, "m_type") != 0) {
											_loc19_.advance(_loc13_);
											_loc19_.setAwake(true);
										}
										_loc8_[_loc17_ + _loc18_] = _loc19_;
										_loc18_++;
										__tmpAssignObj19 = _loc19_;
										ASCompat.setProperty(__tmpAssignObj19, "m_flags", ASCompat.toInt(__tmpAssignObj19.m_flags) | B2Body.e_islandFlag);
										_loc20_ = _loc20_.next;
									}
								}
							}
						}
					}
				}
				_loc21_ = B2World.s_timestep;
				ASCompat.setProperty(_loc21_, "warmStarting", false);
				ASCompat.setProperty(_loc21_, "dt", (1 - _loc13_) * step.dt);
				ASCompat.setProperty(_loc21_, "inv_dt", 1 / ASCompat.toNumberField(_loc21_, "dt"));
				ASCompat.setProperty(_loc21_, "dtRatio", 0);
				ASCompat.setProperty(_loc21_, "velocityIterations", step.velocityIterations);
				ASCompat.setProperty(_loc21_, "positionIterations", step.positionIterations);
				_loc7_.solveTOI(_loc21_);
				_loc23_ = 0;
				_loc24_ = _loc7_.m_bodyCount;
				while (_loc23_ < _loc24_) {
					_loc25_ = _loc23_++;
					_loc9_ = ASCompat.coerce(_loc7_.m_bodies[_loc25_], box2D.dynamics.B2Body);
					_loc9_.m_flags = _loc9_.m_flags & ~B2Body.e_islandFlag;
					if ((_loc9_.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag != false) {
						if (_loc9_.m_type == 2) {
							_loc9_.synchronizeFixtures();
							_loc6_ = _loc9_.m_contactList;
							while (_loc6_ != null) {
								__tmpAssignObj20 = _loc6_.contact;
								ASCompat.setProperty(__tmpAssignObj20, "m_flags", ASCompat.toInt(__tmpAssignObj20.m_flags) & ~B2Contact.e_toiFlag);
								_loc6_ = _loc6_.next;
							}
						}
					}
				}
				_loc23_ = 0;
				_loc24_ = _loc7_.m_contactCount;
				while (_loc23_ < _loc24_) {
					_loc25_ = _loc23_++;
					_loc10_ = ASCompat.coerce(_loc7_.m_contacts[_loc25_], box2D.dynamics.contacts.B2Contact);
					_loc10_.m_flags = _loc10_.m_flags & ~(B2Contact.e_toiFlag | B2Contact.e_islandFlag);
				}
				_loc23_ = 0;
				_loc24_ = _loc7_.m_jointCount;
				while (_loc23_ < _loc24_) {
					_loc25_ = _loc23_++;
					_loc11_ = ASCompat.coerce(_loc7_.m_joints[_loc25_], box2D.dynamics.joints.B2Joint);
					_loc11_.m_islandFlag = false;
				}
				m_contactManager.findNewContacts();
			}
		}
	}

	public function Solve(step:B2TimeStep) {
		var __tmpAssignObj21:ASAny;
		var __tmpAssignObj22:ASAny;
		var __tmpAssignObj23:ASAny;
		var _loc10_ = 0;
		var _loc11_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc12_:ASAny = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc13_:ASAny = ASCompat.dynamicAs(null, B2JointEdge);
		var _loc14_ = 0;
		var _loc15_ = 0;
		var _loc16_ = 0;
		var _loc2_ = m_controllerList;
		while (_loc2_ != null) {
			_loc2_.step(step);
			_loc2_ = _loc2_.m_next;
		}
		var _loc3_ = m_island;
		_loc3_.initialize(m_bodyCount, m_contactManager.m_contactCount, m_jointCount, null, m_contactManager.m_contactListener, m_contactSolver);
		var _loc4_ = m_bodyList;
		while (_loc4_ != null) {
			_loc4_.m_flags = _loc4_.m_flags & ~B2Body.e_islandFlag;
			_loc4_ = _loc4_.m_next;
		}
		var _loc5_ = m_contactList;
		while (_loc5_ != null) {
			_loc5_.m_flags = _loc5_.m_flags & ~B2Contact.e_islandFlag;
			_loc5_ = _loc5_.m_next;
		}
		var _loc6_ = m_jointList;
		while (_loc6_ != null) {
			_loc6_.m_islandFlag = false;
			_loc6_ = _loc6_.m_next;
		}
		var _loc7_ = m_bodyCount;
		var _loc8_ = s_stack;
		var _loc9_ = m_bodyList;
		while (_loc9_ != null) {
			if ((_loc9_.m_flags & B2Body.e_islandFlag) != 0) {
				_loc9_ = _loc9_.m_next;
			} else if ((_loc9_.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false
				|| (_loc9_.m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
				_loc9_ = _loc9_.m_next;
			} else if (_loc9_.m_type == 0) {
				_loc9_ = _loc9_.m_next;
			} else {
				_loc3_.clear();
				_loc10_ = 0;
				_loc8_[_loc10_++] = _loc9_;
				_loc9_.m_flags = _loc9_.m_flags | B2Body.e_islandFlag;
				while (_loc10_ > 0) {
					_loc4_ = ASCompat.coerce(_loc8_[--_loc10_], box2D.dynamics.B2Body);
					_loc3_.addBody(_loc4_);
					if ((_loc4_.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
						_loc4_.setAwake(true);
					}
					if (_loc4_.m_type != 0) {
						_loc12_ = _loc4_.m_contactList;
						while (_loc12_ != null) {
							if ((ASCompat.toInt(_loc12_.contact.m_flags) & B2Contact.e_islandFlag) != 0) {
								_loc12_ = _loc12_.next;
							} else if (_loc12_.contact.isSensor() == true
								|| _loc12_.contact.isEnabled() == false
								|| _loc12_.contact.isTouching() == false) {
								_loc12_ = _loc12_.next;
							} else {
								_loc3_.addContact(ASCompat.coerce(_loc12_.contact, box2D.dynamics.contacts.B2Contact));
								__tmpAssignObj21 = _loc12_.contact;
								ASCompat.setProperty(__tmpAssignObj21, "m_flags", ASCompat.toInt(__tmpAssignObj21.m_flags) | B2Contact.e_islandFlag);
								_loc11_ = _loc12_.other;
								if ((ASCompat.toInt(_loc11_.m_flags) & B2Body.e_islandFlag) != 0) {
									_loc12_ = _loc12_.next;
								} else {
									_loc8_[_loc10_++] = _loc11_;
									__tmpAssignObj22 = _loc11_;
									ASCompat.setProperty(__tmpAssignObj22, "m_flags", ASCompat.toInt(__tmpAssignObj22.m_flags) | B2Body.e_islandFlag);
									_loc12_ = _loc12_.next;
								}
							}
						}
						_loc13_ = _loc4_.m_jointList;
						while (_loc13_ != null) {
							if (_loc13_.joint.m_islandFlag == true) {
								_loc13_ = _loc13_.next;
							} else {
								_loc11_ = _loc13_.other;
								if ((ASCompat.toInt(_loc11_.m_flags) & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
									_loc13_ = _loc13_.next;
								} else {
									_loc3_.addJoint(ASCompat.coerce(_loc13_.joint, box2D.dynamics.joints.B2Joint));
									ASCompat.setProperty(_loc13_.joint, "m_islandFlag", true);
									if ((ASCompat.toInt(_loc11_.m_flags) & B2Body.e_islandFlag) != 0) {
										_loc13_ = _loc13_.next;
									} else {
										_loc8_[_loc10_++] = _loc11_;
										__tmpAssignObj23 = _loc11_;
										ASCompat.setProperty(__tmpAssignObj23, "m_flags", ASCompat.toInt(__tmpAssignObj23.m_flags) | B2Body.e_islandFlag);
										_loc13_ = _loc13_.next;
									}
								}
							}
						}
					}
				}
				_loc3_.solve(step, m_gravity, m_allowSleep);
				_loc14_ = 0;
				_loc15_ = _loc3_.m_bodyCount;
				while (_loc14_ < _loc15_) {
					_loc16_ = _loc14_++;
					_loc4_ = ASCompat.coerce(_loc3_.m_bodies[_loc16_], box2D.dynamics.B2Body);
					if (_loc4_.m_type == 0) {
						_loc4_.m_flags = _loc4_.m_flags & ~B2Body.e_islandFlag;
					}
				}
				_loc9_ = _loc9_.m_next;
			}
		}
		_loc10_ = 0;
		_loc14_ = _loc8_.length;
		while (_loc10_ < _loc14_) {
			_loc15_ = _loc10_++;
			if (_loc8_[_loc15_] == null) {
				break;
			}
			_loc8_[_loc15_] = null;
		}
		_loc4_ = m_bodyList;
		while (_loc4_ != null) {
			if ((_loc4_.m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false
				|| (_loc4_.m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
				_loc4_ = _loc4_.m_next;
			} else if (_loc4_.m_type == 0) {
				_loc4_ = _loc4_.m_next;
			} else {
				_loc4_.synchronizeFixtures();
				_loc4_ = _loc4_.m_next;
			}
		}
		m_contactManager.findNewContacts();
	}

	public function SetWarmStarting(flag:Bool) {
		B2World.m_warmStarting = flag;
	}

	public function SetGravity(gravity:B2Vec2) {
		m_gravity = gravity;
	}

	public function SetDestructionListener(listener:B2DestructionListener) {
		m_destructionListener = listener;
	}

	public function SetDebugDraw(debugDraw:B2DebugDraw) {
		m_debugDraw = debugDraw;
	}

	public function SetContinuousPhysics(flag:Bool) {
		B2World.m_continuousPhysics = flag;
	}

	public function SetContactListener(listener:B2ContactListener) {
		m_contactManager.m_contactListener = listener;
	}

	public function SetContactFilter(filter:B2ContactFilter) {
		m_contactManager.m_contactFilter = filter;
	}

	public function SetBroadPhase(broadPhase:IBroadPhase) {
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc2_ = m_contactManager.m_broadPhase;
		m_contactManager.m_broadPhase = broadPhase;
		var _loc3_ = m_bodyList;
		while (_loc3_ != null) {
			_loc4_ = _loc3_.m_fixtureList;
			while (_loc4_ != null) {
				ASCompat.setProperty(_loc4_, "m_proxy", broadPhase.createProxy(_loc2_.getFatAABB(_loc4_.m_proxy), _loc4_));
				_loc4_ = _loc4_.m_next;
			}
			_loc3_ = _loc3_.m_next;
		}
	}

	public function RemoveController(c:B2Controller) {
		if (c.m_prev != null) {
			c.m_prev.m_next = c.m_next;
		}
		if (c.m_next != null) {
			c.m_next.m_prev = c.m_prev;
		}
		if (m_controllerList == c) {
			m_controllerList = c.m_next;
		}
		--m_controllerCount;
	}

	public function RayCastOne(point1:B2Vec2, point2:B2Vec2):B2Fixture {
		var result:B2Fixture = null;
		var rayCastOneWrapper:ASFunction = function(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float {
			result = fixture;
			return fraction;
		};
		rayCast(rayCastOneWrapper, point1, point2);
		return result;
	}

	public function RayCastAll(point1:B2Vec2, point2:B2Vec2):Array<ASAny> {
		var result:Array<ASAny> = [];
		var rayCastAllWrapper:ASFunction = function(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float {
			result[result.length] = fixture;
			return 1;
		};
		rayCast(rayCastAllWrapper, point1, point2);
		return result;
	}

	public function RayCast(callbackMethod:ASFunction, point1:B2Vec2, point2:B2Vec2) {
		var _loc4_:B2RayCastInput;
		var broadPhase = m_contactManager.m_broadPhase;
		var output = new B2RayCastOutput();
		var rayCastWrapper:ASFunction = function(input:B2RayCastInput, proxy:ASAny):Float {
			var _loc6_ = Math.NaN;
			var _loc7_ = ASCompat.dynamicAs(null, B2Vec2);
			var _loc3_:ASAny = broadPhase.getUserData(proxy);
			var _loc4_ = ASCompat.coerce(_loc3_, box2D.dynamics.B2Fixture);
			var _loc5_ = _loc4_.rayCast(output, input);
			if (_loc5_) {
				_loc6_ = output.fraction;
				_loc7_ = new B2Vec2((1 - _loc6_) * point1.x + _loc6_ * point2.x, (1 - _loc6_) * point1.y + _loc6_ * point2.y);
				return ASCompat.toNumber(callbackMethod(_loc4_, _loc7_, output.normal, _loc6_));
			}
			return input.maxFraction;
		};
		_loc4_ = new B2RayCastInput(point1, point2);
		broadPhase.rayCast(rayCastWrapper, _loc4_);
	}

	public function QueryShape(callbackMethod:ASFunction, shape:B2Shape, transform:B2Transform = /*undefined*/ null) {
		var worldQueryWrapper:ASFunction;
		var broadPhase:IBroadPhase;
		if (transform == null) {
			transform = new B2Transform();
			transform.setIdentity();
		}
		broadPhase = m_contactManager.m_broadPhase;
		worldQueryWrapper = function(proxy:ASAny):Bool {
			var _loc2_ = ASCompat.coerce(broadPhase.getUserData(proxy), box2D.dynamics.B2Fixture);
			if (B2Shape.testOverlap(shape, transform, _loc2_.getShape(), _loc2_.getBody().getTransform())) {
				return ASCompat.toBool(callbackMethod(_loc2_));
			}
			return true;
		};
		var _loc4_ = new B2AABB();
		shape.computeAABB(_loc4_, transform);
		broadPhase.query(worldQueryWrapper, _loc4_);
	}

	public function QueryPoint(callbackMethod:ASFunction, p:B2Vec2) {
		var broadPhase = m_contactManager.m_broadPhase;
		var worldQueryWrapper:ASFunction = function(proxy:ASAny):Bool {
			var _loc2_ = ASCompat.coerce(broadPhase.getUserData(proxy), box2D.dynamics.B2Fixture);
			if (_loc2_.testPoint(p)) {
				return ASCompat.toBool(callbackMethod(_loc2_));
			}
			return true;
		};
		var _loc3_ = new B2AABB();
		_loc3_.lowerBound.set(p.x - B2Settings.b2_linearSlop, p.y - B2Settings.b2_linearSlop);
		_loc3_.upperBound.set(p.x + B2Settings.b2_linearSlop, p.y + B2Settings.b2_linearSlop);
		broadPhase.query(worldQueryWrapper, _loc3_);
	}

	public function QueryAABB(callbackMethod:ASFunction, aabb:B2AABB) {
		var broadPhase = m_contactManager.m_broadPhase;
		var worldQueryWrapper:ASFunction = function(proxy:ASAny):Bool {
			return ASCompat.toBool(callbackMethod(broadPhase.getUserData(proxy)));
		};
		broadPhase.query(worldQueryWrapper, aabb);
	}

	public function IsLocked():Bool {
		return (m_flags & B2World.e_locked) > 0;
	}

	public function GetProxyCount():Int {
		return m_contactManager.m_broadPhase.getProxyCount();
	}

	public function GetJointList():B2Joint {
		return m_jointList;
	}

	public function GetJointCount():Int {
		return m_jointCount;
	}

	public function GetGroundBody():B2Body {
		return m_groundBody;
	}

	public function GetGravity():B2Vec2 {
		return m_gravity;
	}

	public function GetContactList():B2Contact {
		return m_contactList;
	}

	public function GetContactCount():Int {
		return m_contactManager.m_contactCount;
	}

	public function GetBodyList():B2Body {
		return m_bodyList;
	}

	public function GetBodyCount():Int {
		return m_bodyCount;
	}

	public function DrawShape(shape:B2Shape, xf:B2Transform, color:B2Color) {
		var _loc4_ = ASCompat.dynamicAs(null, B2CircleShape);
		var _loc5_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc6_ = Math.NaN;
		var _loc7_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc9_ = ASCompat.dynamicAs(null, B2PolygonShape);
		var _loc10_ = 0;
		var _loc11_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc12_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc13_ = 0;
		var _loc14_ = 0;
		var _loc15_ = 0;
		var _loc16_ = ASCompat.dynamicAs(null, B2EdgeShape);
		switch (shape.m_type) {
			case 1:
				_loc4_ = cast(shape, B2CircleShape);
				_loc5_ = B2Math.mulX(xf, ASCompat.coerce(_loc4_.m_p, box2D.common.math.B2Vec2));
				_loc6_ = ASCompat.toNumberField(_loc4_, "m_radius");
				_loc7_ = xf.R.col1;
				m_debugDraw.drawSolidCircle(_loc5_, _loc6_, _loc7_, color);

			case 2:
				_loc9_ = cast(shape, B2PolygonShape);
				_loc10_ = ASCompat.toInt(_loc9_.getVertexCount());
				_loc11_ = _loc9_.getVertices();
				_loc12_ = [];
				_loc13_ = 0;
				_loc14_ = _loc10_;
				while (_loc13_ < _loc14_) {
					_loc15_ = _loc13_++;
					_loc12_[_loc15_] = B2Math.mulX(xf, ASCompat.coerce(_loc11_[_loc15_], box2D.common.math.B2Vec2));
				}
				m_debugDraw.drawSolidPolygon(_loc12_, _loc10_, color);

			case 3:
				_loc16_ = cast(shape, B2EdgeShape);
				m_debugDraw.drawSegment(B2Math.mulX(xf, ASCompat.coerce(_loc16_.getVertex1(), box2D.common.math.B2Vec2)),
					B2Math.mulX(xf, ASCompat.coerce(_loc16_.getVertex2(), box2D.common.math.B2Vec2)), color);
		}
	}

	public function DrawJoint(joint:B2Joint) {
		var _loc11_ = ASCompat.dynamicAs(null, B2PulleyJoint);
		var _loc12_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc13_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc2_ = joint.getBodyA();
		var _loc3_ = joint.getBodyB();
		var _loc4_ = _loc2_.m_xf;
		var _loc5_ = _loc3_.m_xf;
		var _loc6_ = _loc4_.position;
		var _loc7_ = _loc5_.position;
		var _loc8_ = joint.getAnchorA();
		var _loc9_ = joint.getAnchorB();
		var _loc10_ = B2World.s_jointColor;
		switch (joint.m_type) {
			case 3:
				m_debugDraw.drawSegment(_loc8_, _loc9_, _loc10_);

			case 4:
				_loc11_ = cast(joint, B2PulleyJoint);
				_loc12_ = _loc11_.getGroundAnchorA();
				_loc13_ = _loc11_.getGroundAnchorB();
				m_debugDraw.drawSegment(ASCompat.coerce(_loc12_, box2D.common.math.B2Vec2), _loc8_, _loc10_);
				m_debugDraw.drawSegment(ASCompat.coerce(_loc13_, box2D.common.math.B2Vec2), _loc9_, _loc10_);
				m_debugDraw.drawSegment(ASCompat.coerce(_loc12_, box2D.common.math.B2Vec2), ASCompat.coerce(_loc13_, box2D.common.math.B2Vec2), _loc10_);

			case 5:
				m_debugDraw.drawSegment(_loc8_, _loc9_, _loc10_);

			default:
				if (_loc2_ != m_groundBody) {
					m_debugDraw.drawSegment(_loc6_, _loc8_, _loc10_);
				}
				m_debugDraw.drawSegment(_loc8_, _loc9_, _loc10_);
				if (_loc3_ != m_groundBody) {
					m_debugDraw.drawSegment(_loc7_, _loc9_, _loc10_);
				}
		}
	}

	public function DrawDebugData() {
		var _loc3_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Shape);
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2Joint);
		var _loc7_ = ASCompat.dynamicAs(null, IBroadPhase);
		var _loc11_:ASAny = ASCompat.dynamicAs(null, B2Transform);
		var _loc16_:ASAny = ASCompat.dynamicAs(null, B2Controller);
		var _loc17_:ASAny = ASCompat.dynamicAs(null, B2Contact);
		var _loc18_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc19_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc20_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc21_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc22_:ASAny = ASCompat.dynamicAs(null, B2AABB);
		if (m_debugDraw == null) {
			return;
		}
		m_debugDraw.clear();
		var _loc1_ = m_debugDraw.getFlags();
		var _loc8_ = new B2Vec2();
		var _loc9_ = new B2Vec2();
		var _loc10_ = new B2Vec2();
		var _loc12_ = new B2AABB();
		var _loc13_ = new B2AABB();
		var _loc14_:Array<ASAny> = [new B2Vec2(), new B2Vec2(), new B2Vec2(), new B2Vec2()];
		var _loc15_ = new B2Color(0, 0, 0);
		if ((_loc1_ & B2DebugDraw.e_shapeBit) != 0) {
			_loc3_ = m_bodyList;
			while (_loc3_ != null) {
				_loc11_ = _loc3_.m_xf;
				_loc4_ = _loc3_.getFixtureList();
				while (_loc4_ != null) {
					_loc5_ = _loc4_.getShape();
					if ((ASCompat.toInt(_loc3_.m_flags) & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
						_loc15_.set(0.5, 0.5, 0.3);
						drawShape(ASCompat.coerce(_loc5_, box2D.collision.shapes.B2Shape), ASCompat.coerce(_loc11_, box2D.common.math.B2Transform), _loc15_);
					} else if (ASCompat.toNumberField(_loc3_, "m_type") == 0) {
						_loc15_.set(0.5, 0.9, 0.5);
						drawShape(ASCompat.coerce(_loc5_, box2D.collision.shapes.B2Shape), ASCompat.coerce(_loc11_, box2D.common.math.B2Transform), _loc15_);
					} else if (ASCompat.toNumberField(_loc3_, "m_type") == 1) {
						_loc15_.set(0.5, 0.5, 0.9);
						drawShape(ASCompat.coerce(_loc5_, box2D.collision.shapes.B2Shape), ASCompat.coerce(_loc11_, box2D.common.math.B2Transform), _loc15_);
					} else if ((ASCompat.toInt(_loc3_.m_flags) & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
						_loc15_.set(0.6, 0.6, 0.6);
						drawShape(ASCompat.coerce(_loc5_, box2D.collision.shapes.B2Shape), ASCompat.coerce(_loc11_, box2D.common.math.B2Transform), _loc15_);
					} else {
						_loc15_.set(0.9, 0.7, 0.7);
						drawShape(ASCompat.coerce(_loc5_, box2D.collision.shapes.B2Shape), ASCompat.coerce(_loc11_, box2D.common.math.B2Transform), _loc15_);
					}
					_loc4_ = _loc4_.m_next;
				}
				_loc3_ = _loc3_.m_next;
			}
		}
		if ((_loc1_ & B2DebugDraw.e_jointBit) != 0) {
			_loc6_ = m_jointList;
			while (_loc6_ != null) {
				drawJoint(ASCompat.coerce(_loc6_, box2D.dynamics.joints.B2Joint));
				_loc6_ = _loc6_.m_next;
			}
		}
		if ((_loc1_ & B2DebugDraw.e_controllerBit) != 0) {
			_loc16_ = m_controllerList;
			while (_loc16_ != null) {
				_loc16_.draw(m_debugDraw);
				_loc16_ = _loc16_.m_next;
			}
		}
		if ((_loc1_ & B2DebugDraw.e_pairBit) != 0) {
			_loc15_.set(0.3, 0.9, 0.9);
			_loc17_ = m_contactManager.m_contactList;
			while (_loc17_ != null) {
				_loc18_ = _loc17_.getFixtureA();
				_loc19_ = _loc17_.getFixtureB();
				_loc20_ = _loc18_.getAABB().getCenter();
				_loc21_ = _loc19_.getAABB().getCenter();
				m_debugDraw.drawSegment(ASCompat.coerce(_loc20_, box2D.common.math.B2Vec2), ASCompat.coerce(_loc21_, box2D.common.math.B2Vec2), _loc15_);
				_loc17_ = _loc17_.getNext();
			}
		}
		if ((_loc1_ & B2DebugDraw.e_aabbBit) != 0) {
			_loc7_ = m_contactManager.m_broadPhase;
			_loc14_ = [new B2Vec2(), new B2Vec2(), new B2Vec2(), new B2Vec2()];
			_loc3_ = m_bodyList;
			while (_loc3_ != null) {
				if ((ASCompat.toInt(_loc3_.m_flags) & B2Body.e_activeFlag) == B2Body.e_activeFlag == false) {
					_loc3_ = _loc3_.getNext();
				} else {
					_loc4_ = _loc3_.getFixtureList();
					while (_loc4_ != null) {
						_loc22_ = _loc7_.getFatAABB(_loc4_.m_proxy);
						_loc14_[0].set(_loc22_.lowerBound.x, _loc22_.lowerBound.y);
						_loc14_[1].set(_loc22_.upperBound.x, _loc22_.lowerBound.y);
						_loc14_[2].set(_loc22_.upperBound.x, _loc22_.upperBound.y);
						_loc14_[3].set(_loc22_.lowerBound.x, _loc22_.upperBound.y);
						m_debugDraw.drawPolygon(_loc14_, 4, _loc15_);
						_loc4_ = _loc4_.getNext();
					}
					_loc3_ = _loc3_.getNext();
				}
			}
		}
		if ((_loc1_ & B2DebugDraw.e_centerOfMassBit) != 0) {
			_loc3_ = m_bodyList;
			while (_loc3_ != null) {
				_loc11_ = B2World.s_xf;
				ASCompat.setProperty(_loc11_, "R", _loc3_.m_xf.R);
				ASCompat.setProperty(_loc11_, "position", _loc3_.getWorldCenter());
				m_debugDraw.drawTransform(ASCompat.coerce(_loc11_, box2D.common.math.B2Transform));
				_loc3_ = _loc3_.m_next;
			}
		}
	}

	public function DestroyJoint(j:B2Joint) {
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc2_ = j.m_collideConnected;
		if (j.m_prev != null) {
			j.m_prev.m_next = j.m_next;
		}
		if (j.m_next != null) {
			j.m_next.m_prev = j.m_prev;
		}
		if (j == m_jointList) {
			m_jointList = j.m_next;
		}
		var _loc3_ = j.m_bodyA;
		var _loc4_ = j.m_bodyB;
		_loc3_.setAwake(true);
		_loc4_.setAwake(true);
		if (j.m_edgeA.prev != null) {
			j.m_edgeA.prev.next = j.m_edgeA.next;
		}
		if (j.m_edgeA.next != null) {
			j.m_edgeA.next.prev = j.m_edgeA.prev;
		}
		if (j.m_edgeA == _loc3_.m_jointList) {
			_loc3_.m_jointList = j.m_edgeA.next;
		}
		j.m_edgeA.prev = null;
		j.m_edgeA.next = null;
		if (j.m_edgeB.prev != null) {
			j.m_edgeB.prev.next = j.m_edgeB.next;
		}
		if (j.m_edgeB.next != null) {
			j.m_edgeB.next.prev = j.m_edgeB.prev;
		}
		if (j.m_edgeB == _loc4_.m_jointList) {
			_loc4_.m_jointList = j.m_edgeB.next;
		}
		j.m_edgeB.prev = null;
		j.m_edgeB.next = null;
		B2Joint.destroy(j, null);
		--m_jointCount;
		if (_loc2_ == false) {
			_loc5_ = _loc4_.getContactList();
			while (_loc5_ != null) {
				if (_loc5_.other == _loc3_) {
					_loc5_.contact.flagForFiltering();
				}
				_loc5_ = _loc5_.next;
			}
		}
	}

	public function DestroyController(controller:B2Controller) {
		controller.clear();
		if (controller.m_next != null) {
			controller.m_next.m_prev = controller.m_prev;
		}
		if (controller.m_prev != null) {
			controller.m_prev.m_next = controller.m_next;
		}
		if (controller == m_controllerList) {
			m_controllerList = controller.m_next;
		}
		--m_controllerCount;
	}

	public function DestroyBody(b:B2Body) {
		var _loc3_ = ASCompat.dynamicAs(null, B2JointEdge);
		var _loc5_ = ASCompat.dynamicAs(null, B2ControllerEdge);
		var _loc7_ = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc9_ = ASCompat.dynamicAs(null, B2Fixture);
		if (isLocked() == true) {
			return;
		}
		var _loc2_ = b.m_jointList;
		while (_loc2_ != null) {
			_loc3_ = _loc2_;
			_loc2_ = _loc2_.next;
			if (m_destructionListener != null) {
				m_destructionListener.sayGoodbyeJoint(ASCompat.coerce(_loc3_.joint, box2D.dynamics.joints.B2Joint));
			}
			destroyJoint(ASCompat.coerce(_loc3_.joint, box2D.dynamics.joints.B2Joint));
		}
		var _loc4_ = b.m_controllerList;
		while (_loc4_ != null) {
			_loc5_ = _loc4_;
			_loc4_ = _loc4_.nextController;
			_loc5_.controller.removeBody(b);
		}
		var _loc6_ = b.m_contactList;
		while (_loc6_ != null) {
			_loc7_ = _loc6_;
			_loc6_ = _loc6_.next;
			m_contactManager.destroy(ASCompat.coerce(_loc7_.contact, box2D.dynamics.contacts.B2Contact));
		}
		b.m_contactList = null;
		var _loc8_ = b.m_fixtureList;
		while (_loc8_ != null) {
			_loc9_ = _loc8_;
			_loc8_ = _loc8_.m_next;
			if (m_destructionListener != null) {
				m_destructionListener.sayGoodbyeFixture(_loc9_);
			}
			_loc9_.destroyProxy(m_contactManager.m_broadPhase);
			_loc9_.destroy();
		}
		b.m_fixtureList = null;
		b.m_fixtureCount = 0;
		if (b.m_prev != null) {
			b.m_prev.m_next = b.m_next;
		}
		if (b.m_next != null) {
			b.m_next.m_prev = b.m_prev;
		}
		if (b == m_bodyList) {
			m_bodyList = b.m_next;
		}
		--m_bodyCount;
	}

	public function CreateJoint(def:B2JointDef):B2Joint {
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc2_ = B2Joint.create(def, null);
		_loc2_.m_prev = null;
		_loc2_.m_next = m_jointList;
		if (m_jointList != null) {
			m_jointList.m_prev = _loc2_;
		}
		m_jointList = _loc2_;
		++m_jointCount;
		_loc2_.m_edgeA.joint = _loc2_;
		_loc2_.m_edgeA.other = _loc2_.m_bodyB;
		_loc2_.m_edgeA.prev = null;
		_loc2_.m_edgeA.next = _loc2_.m_bodyA.m_jointList;
		if (_loc2_.m_bodyA.m_jointList != null) {
			_loc2_.m_bodyA.m_jointList.prev = _loc2_.m_edgeA;
		}
		_loc2_.m_bodyA.m_jointList = _loc2_.m_edgeA;
		_loc2_.m_edgeB.joint = _loc2_;
		_loc2_.m_edgeB.other = _loc2_.m_bodyA;
		_loc2_.m_edgeB.prev = null;
		_loc2_.m_edgeB.next = _loc2_.m_bodyB.m_jointList;
		if (_loc2_.m_bodyB.m_jointList != null) {
			_loc2_.m_bodyB.m_jointList.prev = _loc2_.m_edgeB;
		}
		_loc2_.m_bodyB.m_jointList = _loc2_.m_edgeB;
		var _loc3_ = def.bodyA;
		var _loc4_ = def.bodyB;
		if (def.collideConnected == false) {
			_loc5_ = _loc4_.getContactList();
			while (_loc5_ != null) {
				if (_loc5_.other == _loc3_) {
					_loc5_.contact.flagForFiltering();
				}
				_loc5_ = _loc5_.next;
			}
		}
		return _loc2_;
	}

	public function CreateController(controller:B2Controller):B2Controller {
		if (controller.m_world != this) {
			throw ASCompat.haxeThrown("Controller can only be a member of one world");
		}
		controller.m_next = m_controllerList;
		controller.m_prev = null;
		if (m_controllerList != null) {
			m_controllerList.m_prev = controller;
		}
		m_controllerList = controller;
		++m_controllerCount;
		controller.m_world = this;
		return controller;
	}

	public function CreateBody(def:B2BodyDef):B2Body {
		if (isLocked() == true) {
			return null;
		}
		var _loc2_ = new B2Body(def, this);
		_loc2_.m_prev = null;
		_loc2_.m_next = m_bodyList;
		if (m_bodyList != null) {
			m_bodyList.m_prev = _loc2_;
		}
		m_bodyList = _loc2_;
		++m_bodyCount;
		return _loc2_;
	}

	public function ClearForces() {
		var _loc1_ = m_bodyList;
		while (_loc1_ != null) {
			_loc1_.m_force.setZero();
			_loc1_.m_torque = 0;
			_loc1_ = _loc1_.m_next;
		}
	}

	public function AddController(c:B2Controller):B2Controller {
		c.m_next = m_controllerList;
		c.m_prev = null;
		m_controllerList = c;
		c.m_world = this;
		++m_controllerCount;
		return c;
	}

	static function __init__() {
		s_queue = [];
	}
}
