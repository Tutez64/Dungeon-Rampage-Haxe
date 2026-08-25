package box2D.dynamics.contacts;

import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2Contact {
	/*b2internal*/
	public static var e_sensorFlag:UInt = (1 : UInt);

	/*b2internal*/
	public static var e_continuousFlag:UInt = (2 : UInt);

	/*b2internal*/
	public static var e_islandFlag:UInt = (4 : UInt);

	/*b2internal*/
	public static var e_toiFlag:UInt = (8 : UInt);

	/*b2internal*/
	public static var e_touchingFlag:UInt = (16 : UInt);

	/*b2internal*/
	public static var e_enabledFlag:UInt = (32 : UInt);

	/*b2internal*/
	public static var e_filterFlag:UInt = (64 : UInt);

	static var s_input:B2TOIInput = new B2TOIInput();

	/*b2internal*/
	public var m_flags:UInt = 0;

	/*b2internal*/
	public var m_prev:B2Contact;

	/*b2internal*/
	public var m_next:B2Contact;

	/*b2internal*/
	public var m_nodeA:B2ContactEdge = new B2ContactEdge();

	/*b2internal*/
	public var m_nodeB:B2ContactEdge = new B2ContactEdge();

	/*b2internal*/
	public var m_fixtureA:B2Fixture;

	/*b2internal*/
	public var m_fixtureB:B2Fixture;

	/*b2internal*/
	public var m_manifold:B2Manifold = new B2Manifold();

	/*b2internal*/
	public var m_oldManifold:B2Manifold = new B2Manifold();

	/*b2internal*/
	public var m_toi:Float = Math.NaN;

	public function new() {}

	public function GetManifold():B2Manifold {
		return this.m_manifold;
	}

	public function GetWorldManifold(worldManifold:B2WorldManifold) {
		var _loc2_ = this.m_fixtureA.GetBody();
		var _loc3_ = this.m_fixtureB.GetBody();
		var _loc4_ = this.m_fixtureA.GetShape();
		var _loc5_ = this.m_fixtureB.GetShape();
		worldManifold.Initialize(this.m_manifold, _loc2_.GetTransform(), _loc4_.m_radius, _loc3_.GetTransform(), _loc5_.m_radius);
	}

	public function IsTouching():Bool {
		return (((this.m_flags : Int) & (e_touchingFlag : Int)) : UInt) == e_touchingFlag;
	}

	public function IsContinuous():Bool {
		return (((this.m_flags : Int) & (e_continuousFlag : Int)) : UInt) == e_continuousFlag;
	}

	public function SetSensor(sensor:Bool) {
		if (sensor) {
			this.m_flags = ((this.m_flags | e_sensorFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_sensorFlag : Int) : UInt):UInt) : UInt);
		}
	}

	public function IsSensor():Bool {
		return (((this.m_flags : Int) & (e_sensorFlag : Int)) : UInt) == e_sensorFlag;
	}

	public function SetEnabled(flag:Bool) {
		if (flag) {
			this.m_flags = ((this.m_flags | e_enabledFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_enabledFlag : Int) : UInt):UInt) : UInt);
		}
	}

	public function IsEnabled():Bool {
		return (((this.m_flags : Int) & (e_enabledFlag : Int)) : UInt) == e_enabledFlag;
	}

	public function GetNext():B2Contact {
		return this.m_next;
	}

	public function GetFixtureA():B2Fixture {
		return this.m_fixtureA;
	}

	public function GetFixtureB():B2Fixture {
		return this.m_fixtureB;
	}

	public function FlagForFiltering() {
		this.m_flags = ((this.m_flags | e_filterFlag:UInt) : UInt);
	}

	/*b2internal*/
	public function Reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null) {
		this.m_flags = e_enabledFlag;
		if (fixtureA == null || fixtureB == null) {
			this.m_fixtureA = null;
			this.m_fixtureB = null;
			return;
		}
		if (fixtureA.IsSensor() || fixtureB.IsSensor()) {
			this.m_flags = ((this.m_flags | e_sensorFlag:UInt) : UInt);
		}
		var _loc3_ = fixtureA.GetBody();
		var _loc4_ = fixtureB.GetBody();
		if (_loc3_.GetType() != B2Body.b2_dynamicBody
			|| _loc3_.IsBullet()
			|| _loc4_.GetType() != B2Body.b2_dynamicBody
			|| _loc4_.IsBullet()) {
			this.m_flags = ((this.m_flags | e_continuousFlag:UInt) : UInt);
		}
		this.m_fixtureA = fixtureA;
		this.m_fixtureB = fixtureB;
		this.m_manifold.m_pointCount = 0;
		this.m_prev = null;
		this.m_next = null;
		this.m_nodeA.contact = null;
		this.m_nodeA.prev = null;
		this.m_nodeA.next = null;
		this.m_nodeA.other = null;
		this.m_nodeB.contact = null;
		this.m_nodeB.prev = null;
		this.m_nodeB.next = null;
		this.m_nodeB.other = null;
	}

	/*b2internal*/
	public function Update(listener:B2ContactListener) {
		var _loc8_:B2Shape = null;
		var _loc9_:B2Shape = null;
		var _loc10_:B2Transform = null;
		var _loc11_:B2Transform = null;
		var _loc12_ = 0;
		var _loc13_:B2ManifoldPoint = null;
		var _loc14_:B2ContactID = null;
		var _loc15_ = 0;
		var _loc16_:B2ManifoldPoint = null;
		var _loc2_ = this.m_oldManifold;
		this.m_oldManifold = this.m_manifold;
		this.m_manifold = _loc2_;
		this.m_flags = ((this.m_flags | e_enabledFlag:UInt) : UInt);
		var _loc3_ = false;
		var _loc4_ = (((this.m_flags : Int) & (e_touchingFlag : Int)) : UInt) == e_touchingFlag;
		var _loc5_ = this.m_fixtureA.m_body;
		var _loc6_ = this.m_fixtureB.m_body;
		var _loc7_ = this.m_fixtureA.m_aabb.TestOverlap(this.m_fixtureB.m_aabb);
		if (((this.m_flags : Int) & (e_sensorFlag : Int)) != 0) {
			if (_loc7_) {
				_loc8_ = this.m_fixtureA.GetShape();
				_loc9_ = this.m_fixtureB.GetShape();
				_loc10_ = _loc5_.GetTransform();
				_loc11_ = _loc6_.GetTransform();
				_loc3_ = B2Shape.TestOverlap(_loc8_, _loc10_, _loc9_, _loc11_);
			}
			this.m_manifold.m_pointCount = 0;
		} else {
			if (_loc5_.GetType() != B2Body.b2_dynamicBody
				|| _loc5_.IsBullet()
				|| _loc6_.GetType() != B2Body.b2_dynamicBody
				|| _loc6_.IsBullet()) {
				this.m_flags = ((this.m_flags | e_continuousFlag:UInt) : UInt);
			} else {
				this.m_flags = ((this.m_flags & (~(e_continuousFlag : Int) : UInt):UInt) : UInt);
			}
			if (_loc7_) {
				this.Evaluate();
				_loc3_ = this.m_manifold.m_pointCount > 0;
				_loc12_ = 0;
				while (_loc12_ < this.m_manifold.m_pointCount) {
					_loc13_ = this.m_manifold.m_points[_loc12_];
					_loc13_.m_normalImpulse = 0;
					_loc13_.m_tangentImpulse = 0;
					_loc14_ = _loc13_.m_id;
					_loc15_ = 0;
					while (_loc15_ < this.m_oldManifold.m_pointCount) {
						_loc16_ = this.m_oldManifold.m_points[_loc15_];
						if (_loc16_.m_id.key == _loc14_.key) {
							_loc13_.m_normalImpulse = _loc16_.m_normalImpulse;
							_loc13_.m_tangentImpulse = _loc16_.m_tangentImpulse;
							break;
						}
						_loc15_ = ASCompat.toInt(_loc15_) + 1;
					}
					_loc12_ = ASCompat.toInt(_loc12_) + 1;
				}
			} else {
				this.m_manifold.m_pointCount = 0;
			}
			if (_loc3_ != _loc4_) {
				_loc5_.SetAwake(true);
				_loc6_.SetAwake(true);
			}
		}
		if (_loc3_) {
			this.m_flags = ((this.m_flags | e_touchingFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_touchingFlag : Int) : UInt):UInt) : UInt);
		}
		if (_loc4_ == false && _loc3_ == true) {
			listener.BeginContact(this);
		}
		if (_loc4_ == true && _loc3_ == false) {
			listener.EndContact(this);
		}
		if (((this.m_flags : Int) & (e_sensorFlag : Int)) == 0) {
			listener.PreSolve(this, this.m_oldManifold);
		}
	}

	/*b2internal*/
	public function Evaluate() {}

	/*b2internal*/
	public function ComputeTOI(sweepA:B2Sweep, sweepB:B2Sweep):Float {
		s_input.proxyA.Set(this.m_fixtureA.GetShape());
		s_input.proxyB.Set(this.m_fixtureB.GetShape());
		s_input.sweepA = sweepA;
		s_input.sweepB = sweepB;
		s_input.tolerance = B2Settings.b2_linearSlop;
		return B2TimeOfImpact.TimeOfImpact(s_input);
	}
}
