package box2D.dynamics;

import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.contacts.*;
import box2D.dynamics.controllers.B2Controller;
import box2D.dynamics.controllers.B2ControllerEdge;
import box2D.dynamics.joints.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2World {
	static var m_warmStarting:Bool = false;

	static var m_continuousPhysics:Bool = false;

	static var s_timestep2:B2TimeStep = new B2TimeStep();

	static var s_xf:B2Transform = new B2Transform();

	static var s_backupA:B2Sweep = new B2Sweep();

	static var s_backupB:B2Sweep = new B2Sweep();

	static var s_timestep:B2TimeStep = new B2TimeStep();

	static var s_queue:Vector<B2Body> = new Vector();

	static var s_jointColor:B2Color = new B2Color(0.5, 0.8, 0.8);

	public static inline final e_newFixture = 1;

	public static inline final e_locked = 2;

	var s_stack:Vector<B2Body> = new Vector();

	/*b2internal*/
	public var m_flags:Int = 0;

	/*b2internal*/
	public var m_contactManager:B2ContactManager = new B2ContactManager();

	var m_contactSolver:B2ContactSolver = new B2ContactSolver();

	var m_island:B2Island = new B2Island();

	/*b2internal*/
	public var m_bodyList:B2Body;

	var m_jointList:B2Joint;

	/*b2internal*/
	public var m_contactList:B2Contact;

	var m_bodyCount:Int = 0;

	/*b2internal*/
	public var m_contactCount:Int = 0;

	var m_jointCount:Int = 0;

	var m_controllerList:B2Controller;

	var m_controllerCount:Int = 0;

	var m_gravity:B2Vec2;

	var m_allowSleep:Bool = false;

	/*b2internal*/
	public var m_groundBody:B2Body;

	var m_destructionListener:B2DestructionListener;

	var m_debugDraw:B2DebugDraw;

	var m_inv_dt0:Float = Math.NaN;

	public function new(gravity:B2Vec2, doSleep:Bool) {
		this.m_destructionListener = null;
		this.m_debugDraw = null;
		this.m_bodyList = null;
		this.m_contactList = null;
		this.m_jointList = null;
		this.m_controllerList = null;
		this.m_bodyCount = 0;
		this.m_contactCount = 0;
		this.m_jointCount = 0;
		this.m_controllerCount = 0;
		m_warmStarting = true;
		m_continuousPhysics = true;
		this.m_allowSleep = doSleep;
		this.m_gravity = gravity;
		this.m_inv_dt0 = 0;
		this.m_contactManager.m_world = this;
		var _loc3_ = new B2BodyDef();
		this.m_groundBody = this.CreateBody(_loc3_);
	}

	public function SetDestructionListener(listener:B2DestructionListener) {
		this.m_destructionListener = listener;
	}

	public function SetContactFilter(filter:B2ContactFilter) {
		this.m_contactManager.m_contactFilter = filter;
	}

	public function SetContactListener(listener:B2ContactListener) {
		this.m_contactManager.m_contactListener = listener;
	}

	public function SetDebugDraw(debugDraw:B2DebugDraw) {
		this.m_debugDraw = debugDraw;
	}

	public function SetBroadPhase(broadPhase:IBroadPhase) {
		var _loc4_:B2Fixture = null;
		var _loc2_ = this.m_contactManager.m_broadPhase;
		this.m_contactManager.m_broadPhase = broadPhase;
		var _loc3_ = this.m_bodyList;
		while (_loc3_ != null) {
			_loc4_ = _loc3_.m_fixtureList;
			while (_loc4_ != null) {
				_loc4_.m_proxy = broadPhase.CreateProxy(_loc2_.GetFatAABB(_loc4_.m_proxy), _loc4_);
				_loc4_ = _loc4_.m_next;
			}
			_loc3_ = _loc3_.m_next;
		}
	}

	public function Validate() {
		this.m_contactManager.m_broadPhase.Validate();
	}

	public function GetProxyCount():Int {
		return this.m_contactManager.m_broadPhase.GetProxyCount();
	}

	public function CreateBody(def:B2BodyDef):B2Body {
		if (this.IsLocked() == true) {
			return null;
		}
		var _loc2_ = new B2Body(def, this);
		_loc2_.m_prev = null;
		_loc2_.m_next = this.m_bodyList;
		if (this.m_bodyList != null) {
			this.m_bodyList.m_prev = _loc2_;
		}
		this.m_bodyList = _loc2_;
		++this.m_bodyCount;
		return _loc2_;
	}

	public function DestroyBody(b:B2Body) {
		var _loc6_:B2JointEdge = null;
		var _loc7_:B2ControllerEdge = null;
		var _loc8_:B2ContactEdge = null;
		var _loc9_:B2Fixture = null;
		if (this.IsLocked() == true) {
			return;
		}
		var _loc2_ = b.m_jointList;
		while (_loc2_ != null) {
			_loc6_ = _loc2_;
			_loc2_ = _loc2_.next;
			if (this.m_destructionListener != null) {
				this.m_destructionListener.SayGoodbyeJoint(_loc6_.joint);
			}
			this.DestroyJoint(_loc6_.joint);
		}
		var _loc3_ = b.m_controllerList;
		while (_loc3_ != null) {
			_loc7_ = _loc3_;
			_loc3_ = _loc3_.nextController;
			_loc7_.controller.RemoveBody(b);
		}
		var _loc4_ = b.m_contactList;
		while (_loc4_ != null) {
			_loc8_ = _loc4_;
			_loc4_ = _loc4_.next;
			this.m_contactManager.Destroy(_loc8_.contact);
		}
		b.m_contactList = null;
		var _loc5_ = b.m_fixtureList;
		while (_loc5_ != null) {
			_loc9_ = _loc5_;
			_loc5_ = _loc5_.m_next;
			if (this.m_destructionListener != null) {
				this.m_destructionListener.SayGoodbyeFixture(_loc9_);
			}
			_loc9_.DestroyProxy(this.m_contactManager.m_broadPhase);
			_loc9_.Destroy();
		}
		b.m_fixtureList = null;
		b.m_fixtureCount = 0;
		if (b.m_prev != null) {
			b.m_prev.m_next = b.m_next;
		}
		if (b.m_next != null) {
			b.m_next.m_prev = b.m_prev;
		}
		if (b == this.m_bodyList) {
			this.m_bodyList = b.m_next;
		}
		--this.m_bodyCount;
	}

	public function CreateJoint(def:B2JointDef):B2Joint {
		var _loc5_:B2ContactEdge = null;
		var _loc2_ = B2Joint.Create(def, null);
		_loc2_.m_prev = null;
		_loc2_.m_next = this.m_jointList;
		if (this.m_jointList != null) {
			this.m_jointList.m_prev = _loc2_;
		}
		this.m_jointList = _loc2_;
		++this.m_jointCount;
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
			_loc5_ = _loc4_.GetContactList();
			while (_loc5_ != null) {
				if (_loc5_.other == _loc3_) {
					_loc5_.contact.FlagForFiltering();
				}
				_loc5_ = _loc5_.next;
			}
		}
		return _loc2_;
	}

	public function DestroyJoint(j:B2Joint) {
		var _loc5_:B2ContactEdge = null;
		var _loc2_ = j.m_collideConnected;
		if (j.m_prev != null) {
			j.m_prev.m_next = j.m_next;
		}
		if (j.m_next != null) {
			j.m_next.m_prev = j.m_prev;
		}
		if (j == this.m_jointList) {
			this.m_jointList = j.m_next;
		}
		var _loc3_ = j.m_bodyA;
		var _loc4_ = j.m_bodyB;
		_loc3_.SetAwake(true);
		_loc4_.SetAwake(true);
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
		B2Joint.Destroy(j, null);
		--this.m_jointCount;
		if (_loc2_ == false) {
			_loc5_ = _loc4_.GetContactList();
			while (_loc5_ != null) {
				if (_loc5_.other == _loc3_) {
					_loc5_.contact.FlagForFiltering();
				}
				_loc5_ = _loc5_.next;
			}
		}
	}

	public function AddController(c:B2Controller):B2Controller {
		c.m_next = this.m_controllerList;
		c.m_prev = null;
		this.m_controllerList = c;
		c.m_world = this;
		++this.m_controllerCount;
		return c;
	}

	public function RemoveController(c:B2Controller) {
		if (c.m_prev != null) {
			c.m_prev.m_next = c.m_next;
		}
		if (c.m_next != null) {
			c.m_next.m_prev = c.m_prev;
		}
		if (this.m_controllerList == c) {
			this.m_controllerList = c.m_next;
		}
		--this.m_controllerCount;
	}

	public function CreateController(controller:B2Controller):B2Controller {
		if (controller.m_world != this) {
			throw new Error("Controller can only be a member of one world");
		}
		controller.m_next = this.m_controllerList;
		controller.m_prev = null;
		if (this.m_controllerList != null) {
			this.m_controllerList.m_prev = controller;
		}
		this.m_controllerList = controller;
		++this.m_controllerCount;
		controller.m_world = this;
		return controller;
	}

	public function DestroyController(controller:B2Controller) {
		controller.Clear();
		if (controller.m_next != null) {
			controller.m_next.m_prev = controller.m_prev;
		}
		if (controller.m_prev != null) {
			controller.m_prev.m_next = controller.m_next;
		}
		if (controller == this.m_controllerList) {
			this.m_controllerList = controller.m_next;
		}
		--this.m_controllerCount;
	}

	public function SetWarmStarting(flag:Bool) {
		m_warmStarting = flag;
	}

	public function SetContinuousPhysics(flag:Bool) {
		m_continuousPhysics = flag;
	}

	public function GetBodyCount():Int {
		return this.m_bodyCount;
	}

	public function GetJointCount():Int {
		return this.m_jointCount;
	}

	public function GetContactCount():Int {
		return this.m_contactCount;
	}

	public function SetGravity(gravity:B2Vec2) {
		this.m_gravity = gravity;
	}

	public function GetGravity():B2Vec2 {
		return this.m_gravity;
	}

	public function GetGroundBody():B2Body {
		return this.m_groundBody;
	}

	public function Step(dt:Float, velocityIterations:Int, positionIterations:Int) {
		if ((this.m_flags & e_newFixture) != 0) {
			this.m_contactManager.FindNewContacts();
			this.m_flags = this.m_flags & ~e_newFixture;
		}
		this.m_flags = this.m_flags | e_locked;
		var _loc4_ = s_timestep2;
		_loc4_.dt = dt;
		_loc4_.velocityIterations = velocityIterations;
		_loc4_.positionIterations = positionIterations;
		if (dt > 0) {
			_loc4_.inv_dt = 1 / dt;
		} else {
			_loc4_.inv_dt = 0;
		}
		_loc4_.dtRatio = this.m_inv_dt0 * dt;
		_loc4_.warmStarting = m_warmStarting;
		this.m_contactManager.Collide();
		if (_loc4_.dt > 0) {
			this.Solve(_loc4_);
		}
		if (m_continuousPhysics && _loc4_.dt > 0) {
			this.SolveTOI(_loc4_);
		}
		if (_loc4_.dt > 0) {
			this.m_inv_dt0 = _loc4_.inv_dt;
		}
		this.m_flags = this.m_flags & ~e_locked;
	}

	public function ClearForces() {
		var _loc1_ = this.m_bodyList;
		while (_loc1_ != null) {
			_loc1_.m_force.SetZero();
			_loc1_.m_torque = 0;
			_loc1_ = _loc1_.m_next;
		}
	}

	public function DrawDebugData() {
		var _loc2_ = 0;
		var _loc3_:B2Body = null;
		var _loc4_:B2Fixture = null;
		var _loc5_:B2Shape = null;
		var _loc6_:B2Joint = null;
		var _loc7_:IBroadPhase = null;
		var _loc11_:B2Transform = null;
		var _loc16_:B2Controller = null;
		var _loc17_:B2Contact = null;
		var _loc18_:B2Fixture = null;
		var _loc19_:B2Fixture = null;
		var _loc20_:B2Vec2 = null;
		var _loc21_:B2Vec2 = null;
		var _loc22_:B2AABB = null;
		if (this.m_debugDraw == null) {
			return;
		}
		this.m_debugDraw.m_sprite.graphics.clear();
		var _loc1_ = this.m_debugDraw.GetFlags();
		var _loc8_ = new B2Vec2();
		var _loc9_ = new B2Vec2();
		var _loc10_ = new B2Vec2();
		var _loc12_ = new B2AABB();
		var _loc13_ = new B2AABB();
		var _loc14_:Array<ASAny> = [new B2Vec2(), new B2Vec2(), new B2Vec2(), new B2Vec2()];
		var _loc15_ = new B2Color(0, 0, 0);
		if (((_loc1_ : Int) & (B2DebugDraw.e_shapeBit : Int)) != 0) {
			_loc3_ = this.m_bodyList;
			while (_loc3_ != null) {
				_loc11_ = _loc3_.m_xf;
				_loc4_ = _loc3_.GetFixtureList();
				while (_loc4_ != null) {
					_loc5_ = _loc4_.GetShape();
					if (_loc3_.IsActive() == false) {
						_loc15_.Set(0.5, 0.5, 0.3);
						this.DrawShape(_loc5_, _loc11_, _loc15_);
					} else if (_loc3_.GetType() == B2Body.b2_staticBody) {
						_loc15_.Set(0.5, 0.9, 0.5);
						this.DrawShape(_loc5_, _loc11_, _loc15_);
					} else if (_loc3_.GetType() == B2Body.b2_kinematicBody) {
						_loc15_.Set(0.5, 0.5, 0.9);
						this.DrawShape(_loc5_, _loc11_, _loc15_);
					} else if (_loc3_.IsAwake() == false) {
						_loc15_.Set(0.6, 0.6, 0.6);
						this.DrawShape(_loc5_, _loc11_, _loc15_);
					} else {
						_loc15_.Set(0.9, 0.7, 0.7);
						this.DrawShape(_loc5_, _loc11_, _loc15_);
					}
					_loc4_ = _loc4_.m_next;
				}
				_loc3_ = _loc3_.m_next;
			}
		}
		if (((_loc1_ : Int) & (B2DebugDraw.e_jointBit : Int)) != 0) {
			_loc6_ = this.m_jointList;
			while (_loc6_ != null) {
				this.DrawJoint(_loc6_);
				_loc6_ = _loc6_.m_next;
			}
		}
		if (((_loc1_ : Int) & (B2DebugDraw.e_controllerBit : Int)) != 0) {
			_loc16_ = this.m_controllerList;
			while (_loc16_ != null) {
				_loc16_.Draw(this.m_debugDraw);
				_loc16_ = _loc16_.m_next;
			}
		}
		if (((_loc1_ : Int) & (B2DebugDraw.e_pairBit : Int)) != 0) {
			_loc15_.Set(0.3, 0.9, 0.9);
			_loc17_ = this.m_contactManager.m_contactList;
			while (_loc17_ != null) {
				_loc18_ = _loc17_.GetFixtureA();
				_loc19_ = _loc17_.GetFixtureB();
				_loc20_ = _loc18_.GetAABB().GetCenter();
				_loc21_ = _loc19_.GetAABB().GetCenter();
				this.m_debugDraw.DrawSegment(_loc20_, _loc21_, _loc15_);
				_loc17_ = _loc17_.GetNext();
			}
		}
		if (((_loc1_ : Int) & (B2DebugDraw.e_aabbBit : Int)) != 0) {
			_loc7_ = this.m_contactManager.m_broadPhase;
			_loc14_ = [new B2Vec2(), new B2Vec2(), new B2Vec2(), new B2Vec2()];
			_loc3_ = this.m_bodyList;
			while (_loc3_ != null) {
				if (_loc3_.IsActive() != false) {
					_loc4_ = _loc3_.GetFixtureList();
					while (_loc4_ != null) {
						_loc22_ = _loc7_.GetFatAABB(_loc4_.m_proxy);
						_loc14_[0].Set(_loc22_.lowerBound.x, _loc22_.lowerBound.y);
						_loc14_[1].Set(_loc22_.upperBound.x, _loc22_.lowerBound.y);
						_loc14_[2].Set(_loc22_.upperBound.x, _loc22_.upperBound.y);
						_loc14_[3].Set(_loc22_.lowerBound.x, _loc22_.upperBound.y);
						this.m_debugDraw.DrawPolygon(_loc14_, 4, _loc15_);
						_loc4_ = _loc4_.GetNext();
					}
				}
				_loc3_ = _loc3_.GetNext();
			}
		}
		if (((_loc1_ : Int) & (B2DebugDraw.e_centerOfMassBit : Int)) != 0) {
			_loc3_ = this.m_bodyList;
			while (_loc3_ != null) {
				_loc11_ = s_xf;
				_loc11_.R = _loc3_.m_xf.R;
				_loc11_.position = _loc3_.GetWorldCenter();
				this.m_debugDraw.DrawTransform(_loc11_);
				_loc3_ = _loc3_.m_next;
			}
		}
	}

	public function QueryAABB(callback:ASFunction, aabb:B2AABB) {
		var broadPhase:IBroadPhase = null;
		var WorldQueryWrapper:ASFunction = null;
		WorldQueryWrapper = function(proxy:ASAny):Bool {
			return ASCompat.toBool(callback(broadPhase.GetUserData(proxy)));
		};
		broadPhase = this.m_contactManager.m_broadPhase;
		broadPhase.Query(WorldQueryWrapper, aabb);
	}

	public function QueryShape(callback:ASFunction, shape:B2Shape, transform:B2Transform = null) {
		var aabb:B2AABB;
		var broadPhase:IBroadPhase = null;
		var WorldQueryWrapper:ASFunction = null;
		WorldQueryWrapper = function(proxy:ASAny):Bool {
			var _loc2_ = ASCompat.dynamicAs(broadPhase.GetUserData(proxy), B2Fixture);
			if (B2Shape.TestOverlap(shape, transform, _loc2_.GetShape(), _loc2_.GetBody().GetTransform())) {
				return ASCompat.toBool(callback(_loc2_));
			}
			return true;
		};
		if (transform == null) {
			transform = new B2Transform();
			transform.SetIdentity();
		}
		broadPhase = this.m_contactManager.m_broadPhase;
		aabb = new B2AABB();
		shape.ComputeAABB(aabb, transform);
		broadPhase.Query(WorldQueryWrapper, aabb);
	}

	public function QueryPoint(callback:ASFunction, p:B2Vec2) {
		var broadPhase:IBroadPhase = null;
		var WorldQueryWrapper:ASFunction = null;
		WorldQueryWrapper = function(proxy:ASAny):Bool {
			var _loc2_ = ASCompat.dynamicAs(broadPhase.GetUserData(proxy), B2Fixture);
			if (_loc2_.TestPoint(p)) {
				return ASCompat.toBool(callback(_loc2_));
			}
			return true;
		};
		broadPhase = this.m_contactManager.m_broadPhase;
		var aabb = new B2AABB();
		aabb.lowerBound.Set(p.x - B2Settings.b2_linearSlop, p.y - B2Settings.b2_linearSlop);
		aabb.upperBound.Set(p.x + B2Settings.b2_linearSlop, p.y + B2Settings.b2_linearSlop);
		broadPhase.Query(WorldQueryWrapper, aabb);
	}

	public function RayCast(callback:ASFunction, point1:B2Vec2, point2:B2Vec2) {
		var input:B2RayCastInput;
		var broadPhase:IBroadPhase = null;
		var output:B2RayCastOutput = null;
		var RayCastWrapper:ASFunction = null;
		RayCastWrapper = function(input:B2RayCastInput, proxy:ASAny):Float {
			var _loc6_ = Math.NaN;
			var _loc7_:B2Vec2 = null;
			var _loc3_:ASAny = broadPhase.GetUserData(proxy);
			var _loc4_ = ASCompat.dynamicAs(_loc3_, B2Fixture);
			var _loc5_ = _loc4_.RayCast(output, input);
			if (_loc5_) {
				_loc6_ = output.fraction;
				_loc7_ = new B2Vec2((1 - _loc6_) * point1.x + _loc6_ * point2.x, (1 - _loc6_) * point1.y + _loc6_ * point2.y);
				return ASCompat.toNumber(callback(_loc4_, _loc7_, output.normal, _loc6_));
			}
			return input.maxFraction;
		};
		broadPhase = this.m_contactManager.m_broadPhase;
		output = new B2RayCastOutput();
		input = new B2RayCastInput(point1, point2);
		broadPhase.RayCast(RayCastWrapper, input);
	}

	public function RayCastOne(point1:B2Vec2, point2:B2Vec2):B2Fixture {
		var result:B2Fixture = null;
		var RayCastOneWrapper:ASFunction = null;
		RayCastOneWrapper = function(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float {
			result = fixture;
			return fraction;
		};
		this.RayCast(RayCastOneWrapper, point1, point2);
		return result;
	}

	public function RayCastAll(point1:B2Vec2, point2:B2Vec2):Vector<B2Fixture> {
		var result:Vector<B2Fixture> = null;
		var RayCastAllWrapper:ASFunction = null;
		RayCastAllWrapper = function(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float {
			result[result.length] = fixture;
			return 1;
		};
		result = new Vector<B2Fixture>();
		this.RayCast(RayCastAllWrapper, point1, point2);
		return result;
	}

	public function GetBodyList():B2Body {
		return this.m_bodyList;
	}

	public function GetJointList():B2Joint {
		return this.m_jointList;
	}

	public function GetContactList():B2Contact {
		return this.m_contactList;
	}

	public function IsLocked():Bool {
		return (this.m_flags & e_locked) > 0;
	}

	/*b2internal*/
	public function Solve(step:B2TimeStep) {
		var _loc15_:Float;
		var _loc16_:Float;
		var _loc2_:B2Body = null;
		var _loc10_ = 0;
		var _loc11_ = 0;
		var _loc12_:B2Body = null;
		var _loc13_:B2ContactEdge = null;
		var _loc14_:B2JointEdge = null;
		var _loc3_ = this.m_controllerList;
		while (_loc3_ != null) {
			_loc3_.Step(step);
			_loc3_ = _loc3_.m_next;
		}
		var _loc4_ = this.m_island;
		_loc4_.Initialize(this.m_bodyCount, this.m_contactCount, this.m_jointCount, null, this.m_contactManager.m_contactListener, this.m_contactSolver);
		_loc2_ = this.m_bodyList;
		while (_loc2_ != null) {
			_loc2_.m_flags = ((_loc2_.m_flags & (~(B2Body.e_islandFlag : Int) : UInt):UInt) : UInt);
			_loc2_ = _loc2_.m_next;
		}
		var _loc5_ = this.m_contactList;
		while (_loc5_ != null) {
			_loc5_.m_flags = ((_loc5_.m_flags & (~(B2Contact.e_islandFlag : Int) : UInt):UInt) : UInt);
			_loc5_ = _loc5_.m_next;
		}
		var _loc6_ = this.m_jointList;
		while (_loc6_ != null) {
			_loc6_.m_islandFlag = false;
			_loc6_ = _loc6_.m_next;
		}
		var _loc7_ = this.m_bodyCount;
		var _loc8_ = this.s_stack;
		var _loc9_ = this.m_bodyList;
		while (_loc9_ != null) {
			if (((_loc9_.m_flags : Int) & (B2Body.e_islandFlag : Int)) == 0) {
				if (!(_loc9_.IsAwake() == false || _loc9_.IsActive() == false)) {
					if (_loc9_.GetType() != B2Body.b2_staticBody) {
						_loc4_.Clear();
						_loc10_ = 0;
						_loc8_[Std.int(_loc15_ = ASCompat.toNumber(_loc10_++))] = _loc9_;
						_loc9_.m_flags = ((_loc9_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
						while (_loc10_ > 0) {
							_loc2_ = _loc8_[Std.int(--_loc10_)];
							_loc4_.AddBody(_loc2_);
							if (_loc2_.IsAwake() == false) {
								_loc2_.SetAwake(true);
							}
							if (_loc2_.GetType() != B2Body.b2_staticBody) {
								_loc13_ = _loc2_.m_contactList;
								while (_loc13_ != null) {
									if (((_loc13_.contact.m_flags : Int) & (B2Contact.e_islandFlag : Int)) == 0) {
										if (!(_loc13_.contact.IsSensor() == true
											|| _loc13_.contact.IsEnabled() == false
											|| _loc13_.contact.IsTouching() == false)) {
											_loc4_.AddContact(_loc13_.contact);
											_loc13_.contact.m_flags = ((_loc13_.contact.m_flags | B2Contact.e_islandFlag:UInt) : UInt);
											_loc12_ = _loc13_.other;
											if (((_loc12_.m_flags : Int) & (B2Body.e_islandFlag : Int)) == 0) {
												_loc8_[Std.int(_loc16_ = ASCompat.toNumber(_loc10_++))] = _loc12_;
												_loc12_.m_flags = ((_loc12_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
											}
										}
									}
									_loc13_ = _loc13_.next;
								}
								_loc14_ = _loc2_.m_jointList;
								while (_loc14_ != null) {
									if (_loc14_.joint.m_islandFlag != true) {
										_loc12_ = _loc14_.other;
										if (_loc12_.IsActive() != false) {
											_loc4_.AddJoint(_loc14_.joint);
											_loc14_.joint.m_islandFlag = true;
											if (((_loc12_.m_flags : Int) & (B2Body.e_islandFlag : Int)) == 0) {
												_loc8_[Std.int(_loc16_ = ASCompat.toNumber(_loc10_++))] = _loc12_;
												_loc12_.m_flags = ((_loc12_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
											}
										}
									}
									_loc14_ = _loc14_.next;
								}
							}
						}
						_loc4_.Solve(step, this.m_gravity, this.m_allowSleep);
						_loc11_ = 0;
						while (_loc11_ < _loc4_.m_bodyCount) {
							_loc2_ = _loc4_.m_bodies[_loc11_];
							if (_loc2_.GetType() == B2Body.b2_staticBody) {
								_loc2_.m_flags = ((_loc2_.m_flags & (~(B2Body.e_islandFlag : Int) : UInt):UInt) : UInt);
							}
							_loc11_ = ASCompat.toInt(_loc11_) + 1;
						}
					}
				}
			}
			_loc9_ = _loc9_.m_next;
		}
		_loc11_ = 0;
		while (_loc11_ < _loc8_.length) {
			if (_loc8_[_loc11_] == null) {
				break;
			}
			_loc8_[_loc11_] = null;
			_loc11_ = ASCompat.toInt(_loc11_) + 1;
		}
		_loc2_ = this.m_bodyList;
		while (_loc2_ != null) {
			if (!(_loc2_.IsAwake() == false || _loc2_.IsActive() == false)) {
				if (_loc2_.GetType() != B2Body.b2_staticBody) {
					_loc2_.SynchronizeFixtures();
				}
			}
			_loc2_ = _loc2_.m_next;
		}
		this.m_contactManager.FindNewContacts();
	}

	/*b2internal*/
	public function SolveTOI(step:B2TimeStep) {
		var _loc2_:B2Body = null;
		var _loc3_:B2Fixture = null;
		var _loc4_:B2Fixture = null;
		var _loc5_:B2Body = null;
		var _loc6_:B2Body = null;
		var _loc7_:B2ContactEdge = null;
		var _loc8_:B2Joint = null;
		var _loc11_:B2Contact = null;
		var _loc12_:B2Contact = null;
		var _loc13_ = Math.NaN;
		var _loc14_:B2Body = null;
		var _loc15_ = 0;
		var _loc16_ = 0;
		var _loc17_:B2TimeStep = null;
		var _loc18_ = 0;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_:B2JointEdge = null;
		var _loc22_:B2Body = null;
		var _loc9_ = this.m_island;
		_loc9_.Initialize(this.m_bodyCount, B2Settings.b2_maxTOIContactsPerIsland, B2Settings.b2_maxTOIJointsPerIsland, null,
			this.m_contactManager.m_contactListener, this.m_contactSolver);
		var _loc10_ = s_queue;
		_loc2_ = this.m_bodyList;
		while (_loc2_ != null) {
			_loc2_.m_flags = ((_loc2_.m_flags & (~(B2Body.e_islandFlag : Int) : UInt):UInt) : UInt);
			_loc2_.m_sweep.t0 = 0;
			_loc2_ = _loc2_.m_next;
		}
		_loc11_ = this.m_contactList;
		while (_loc11_ != null) {
			_loc11_.m_flags = ((_loc11_.m_flags & (~((B2Contact.e_toiFlag : Int) | (B2Contact.e_islandFlag : Int)) : UInt):UInt) : UInt);
			_loc11_ = _loc11_.m_next;
		}
		_loc8_ = this.m_jointList;
		while (_loc8_ != null) {
			_loc8_.m_islandFlag = false;
			_loc8_ = _loc8_.m_next;
		}
		while (true) {
			_loc12_ = null;
			_loc13_ = 1;
			_loc11_ = this.m_contactList;
			while (_loc11_ != null) {
				if (!(_loc11_.IsSensor() == true || _loc11_.IsEnabled() == false || _loc11_.IsContinuous() == false)) {
					_loc19_ = 1;
					if (((_loc11_.m_flags : Int) & (B2Contact.e_toiFlag : Int)) != 0) {
						_loc19_ = _loc11_.m_toi;
					} else {
						_loc3_ = _loc11_.m_fixtureA;
						_loc4_ = _loc11_.m_fixtureB;
						_loc5_ = _loc3_.m_body;
						_loc6_ = _loc4_.m_body;
						if ((_loc5_.GetType() != B2Body.b2_dynamicBody || _loc5_.IsAwake() == false)
							&& (_loc6_.GetType() != B2Body.b2_dynamicBody || _loc6_.IsAwake() == false)) {
							_loc11_ = _loc11_.m_next;
							continue;
						}
						_loc20_ = _loc5_.m_sweep.t0;
						if (_loc5_.m_sweep.t0 < _loc6_.m_sweep.t0) {
							_loc20_ = _loc6_.m_sweep.t0;
							_loc5_.m_sweep.Advance(_loc20_);
						} else if (_loc6_.m_sweep.t0 < _loc5_.m_sweep.t0) {
							_loc20_ = _loc5_.m_sweep.t0;
							_loc6_.m_sweep.Advance(_loc20_);
						}
						_loc19_ = _loc11_.ComputeTOI(_loc5_.m_sweep, _loc6_.m_sweep);
						B2Settings.b2Assert(0 <= _loc19_ && _loc19_ <= 1);
						if (_loc19_ > 0 && _loc19_ < 1) {
							_loc19_ = (1 - _loc19_) * _loc20_ + _loc19_;
							if (_loc19_ > 1) {
								_loc19_ = 1;
							}
						}
						_loc11_.m_toi = _loc19_;
						_loc11_.m_flags = ((_loc11_.m_flags | B2Contact.e_toiFlag:UInt) : UInt);
					}
					if (ASCompat.MIN_FLOAT < _loc19_ && _loc19_ < _loc13_) {
						_loc12_ = _loc11_;
						_loc13_ = _loc19_;
					}
				}
				_loc11_ = _loc11_.m_next;
			}
			if (_loc12_ == null || 1 - 100 * ASCompat.MIN_FLOAT < _loc13_) {
				break;
			}
			_loc3_ = _loc12_.m_fixtureA;
			_loc4_ = _loc12_.m_fixtureB;
			_loc5_ = _loc3_.m_body;
			_loc6_ = _loc4_.m_body;
			s_backupA.Set(_loc5_.m_sweep);
			s_backupB.Set(_loc6_.m_sweep);
			_loc5_.Advance(_loc13_);
			_loc6_.Advance(_loc13_);
			_loc12_.Update(this.m_contactManager.m_contactListener);
			_loc12_.m_flags = ((_loc12_.m_flags & (~(B2Contact.e_toiFlag : Int) : UInt):UInt) : UInt);
			if (_loc12_.IsSensor() == true || _loc12_.IsEnabled() == false) {
				_loc5_.m_sweep.Set(s_backupA);
				_loc6_.m_sweep.Set(s_backupB);
				_loc5_.SynchronizeTransform();
				_loc6_.SynchronizeTransform();
			} else if (_loc12_.IsTouching() != false) {
				_loc14_ = _loc5_;
				if (_loc14_.GetType() != B2Body.b2_dynamicBody) {
					_loc14_ = _loc6_;
				}
				_loc9_.Clear();
				_loc15_ = 0;
				_loc16_ = 0;
				_loc10_[ASCompat.toInt(_loc15_ + _loc16_++)] = _loc14_;
				_loc14_.m_flags = ((_loc14_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
				while (_loc16_ > 0) {
					_loc2_ = _loc10_[ASCompat.toInt(_loc15_++)];
					_loc16_ = ASCompat.toInt(_loc16_) - 1;
					_loc9_.AddBody(_loc2_);
					if (_loc2_.IsAwake() == false) {
						_loc2_.SetAwake(true);
					}
					if (_loc2_.GetType() == B2Body.b2_dynamicBody) {
						_loc7_ = _loc2_.m_contactList;
						while (_loc7_ != null) {
							if (_loc9_.m_contactCount == _loc9_.m_contactCapacity) {
								break;
							}
							if (((_loc7_.contact.m_flags : Int) & (B2Contact.e_islandFlag : Int)) == 0) {
								if (!(_loc7_.contact.IsSensor() == true || _loc7_.contact.IsEnabled() == false || _loc7_.contact.IsTouching() == false)) {
									_loc9_.AddContact(_loc7_.contact);
									_loc7_.contact.m_flags = ((_loc7_.contact.m_flags | B2Contact.e_islandFlag:UInt) : UInt);
									_loc22_ = _loc7_.other;
									if (((_loc22_.m_flags : Int) & (B2Body.e_islandFlag : Int)) == 0) {
										if (_loc22_.GetType() != B2Body.b2_staticBody) {
											_loc22_.Advance(_loc13_);
											_loc22_.SetAwake(true);
										}
										_loc10_[ASCompat.toInt(_loc15_ + _loc16_)] = _loc22_;
										_loc16_ = ASCompat.toInt(_loc16_) + 1;
										_loc22_.m_flags = ((_loc22_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
									}
								}
							}
							_loc7_ = _loc7_.next;
						}
						_loc21_ = _loc2_.m_jointList;
						while (_loc21_ != null) {
							if (_loc9_.m_jointCount != _loc9_.m_jointCapacity) {
								if (_loc21_.joint.m_islandFlag != true) {
									_loc22_ = _loc21_.other;
									if (_loc22_.IsActive() != false) {
										_loc9_.AddJoint(_loc21_.joint);
										_loc21_.joint.m_islandFlag = true;
										if (((_loc22_.m_flags : Int) & (B2Body.e_islandFlag : Int)) == 0) {
											if (_loc22_.GetType() != B2Body.b2_staticBody) {
												_loc22_.Advance(_loc13_);
												_loc22_.SetAwake(true);
											}
											_loc10_[ASCompat.toInt(_loc15_ + _loc16_)] = _loc22_;
											_loc16_ = ASCompat.toInt(_loc16_) + 1;
											_loc22_.m_flags = ((_loc22_.m_flags | B2Body.e_islandFlag:UInt) : UInt);
										}
									}
								}
							}
							_loc21_ = _loc21_.next;
						}
					}
				}
				_loc17_ = s_timestep;
				_loc17_.warmStarting = false;
				_loc17_.dt = (1 - _loc13_) * step.dt;
				_loc17_.inv_dt = 1 / _loc17_.dt;
				_loc17_.dtRatio = 0;
				_loc17_.velocityIterations = step.velocityIterations;
				_loc17_.positionIterations = step.positionIterations;
				_loc9_.SolveTOI(_loc17_);
				_loc18_ = 0;
				while (_loc18_ < _loc9_.m_bodyCount) {
					_loc2_ = _loc9_.m_bodies[_loc18_];
					_loc2_.m_flags = ((_loc2_.m_flags & (~(B2Body.e_islandFlag : Int) : UInt):UInt) : UInt);
					if (_loc2_.IsAwake() != false) {
						if (_loc2_.GetType() == B2Body.b2_dynamicBody) {
							_loc2_.SynchronizeFixtures();
							_loc7_ = _loc2_.m_contactList;
							while (_loc7_ != null) {
								_loc7_.contact.m_flags = ((_loc7_.contact.m_flags & (~(B2Contact.e_toiFlag : Int) : UInt):UInt) : UInt);
								_loc7_ = _loc7_.next;
							}
						}
					}
					_loc18_ = ASCompat.toInt(_loc18_) + 1;
				}
				_loc18_ = 0;
				while (_loc18_ < _loc9_.m_contactCount) {
					_loc11_ = _loc9_.m_contacts[_loc18_];
					_loc11_.m_flags = ((_loc11_.m_flags & (~((B2Contact.e_toiFlag : Int) | (B2Contact.e_islandFlag : Int)) : UInt):UInt) : UInt);
					_loc18_ = ASCompat.toInt(_loc18_) + 1;
				}
				_loc18_ = 0;
				while (_loc18_ < _loc9_.m_jointCount) {
					_loc8_ = _loc9_.m_joints[_loc18_];
					_loc8_.m_islandFlag = false;
					_loc18_ = ASCompat.toInt(_loc18_) + 1;
				}
				this.m_contactManager.FindNewContacts();
			}
		}
	}

	/*b2internal*/
	public function DrawJoint(joint:B2Joint) {
		var _loc11_:B2PulleyJoint = null;
		var _loc12_:B2Vec2 = null;
		var _loc13_:B2Vec2 = null;
		var _loc2_ = joint.GetBodyA();
		var _loc3_ = joint.GetBodyB();
		var _loc4_ = _loc2_.m_xf;
		var _loc5_ = _loc3_.m_xf;
		var _loc6_ = _loc4_.position;
		var _loc7_ = _loc5_.position;
		var _loc8_ = joint.GetAnchorA();
		var _loc9_ = joint.GetAnchorB();
		var _loc10_ = s_jointColor;
		switch (joint.m_type) {
			case B2Joint.e_distanceJoint:
				this.m_debugDraw.DrawSegment(_loc8_, _loc9_, _loc10_);

			case B2Joint.e_pulleyJoint:
				_loc11_ = ASCompat.reinterpretAs(joint, B2PulleyJoint);
				_loc12_ = _loc11_.GetGroundAnchorA();
				_loc13_ = _loc11_.GetGroundAnchorB();
				this.m_debugDraw.DrawSegment(_loc12_, _loc8_, _loc10_);
				this.m_debugDraw.DrawSegment(_loc13_, _loc9_, _loc10_);
				this.m_debugDraw.DrawSegment(_loc12_, _loc13_, _loc10_);

			case B2Joint.e_mouseJoint:
				this.m_debugDraw.DrawSegment(_loc8_, _loc9_, _loc10_);

			default:
				if (_loc2_ != this.m_groundBody) {
					this.m_debugDraw.DrawSegment(_loc6_, _loc8_, _loc10_);
				}
				this.m_debugDraw.DrawSegment(_loc8_, _loc9_, _loc10_);
				if (_loc3_ != this.m_groundBody) {
					this.m_debugDraw.DrawSegment(_loc7_, _loc9_, _loc10_);
				}
		}
	}

	/*b2internal*/
	public function DrawShape(shape:B2Shape, xf:B2Transform, color:B2Color) {
		var _loc4_:B2CircleShape = null;
		var _loc5_:B2Vec2 = null;
		var _loc6_ = Math.NaN;
		var _loc7_:B2Vec2 = null;
		var _loc8_ = 0;
		var _loc9_:B2PolygonShape = null;
		var _loc10_ = 0;
		var _loc11_:Vector<B2Vec2> = null;
		var _loc12_:Vector<B2Vec2> = null;
		var _loc13_:B2EdgeShape = null;
		switch (shape.m_type) {
			case B2Shape.e_circleShape:
				_loc4_ = ASCompat.reinterpretAs(shape, B2CircleShape);
				_loc5_ = B2Math.MulX(xf, _loc4_.m_p);
				_loc6_ = _loc4_.m_radius;
				_loc7_ = xf.R.col1;
				this.m_debugDraw.DrawSolidCircle(_loc5_, _loc6_, _loc7_, color);

			case B2Shape.e_polygonShape:
				_loc9_ = ASCompat.reinterpretAs(shape, B2PolygonShape);
				_loc10_ = _loc9_.GetVertexCount();
				_loc11_ = _loc9_.GetVertices();
				_loc12_ = new Vector<B2Vec2>((_loc10_ : UInt));
				_loc8_ = 0;
				while (_loc8_ < _loc10_) {
					_loc12_[_loc8_] = B2Math.MulX(xf, _loc11_[_loc8_]);
					_loc8_ = ASCompat.toInt(_loc8_) + 1;
				}
				this.m_debugDraw.DrawSolidPolygon(_loc12_, _loc10_, color);

			case B2Shape.e_edgeShape:
				_loc13_ = ASCompat.reinterpretAs(shape, B2EdgeShape);
				this.m_debugDraw.DrawSegment(B2Math.MulX(xf, _loc13_.GetVertex1()), B2Math.MulX(xf, _loc13_.GetVertex2()), color);
		}
	}
}
