package box2D.dynamics.contacts;

import box2D.collision.shapes.B2Shape;
import box2D.collision.B2ContactID;
import box2D.collision.B2Manifold;
import box2D.collision.B2ManifoldPoint;
import box2D.collision.B2TOIInput;
import box2D.collision.B2TimeOfImpact;
import box2D.collision.B2WorldManifold;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.B2Fixture;
import flash.Boot;

class B2Contact {
	public static var e_sensorFlag:Int = 1;

	public static var e_continuousFlag:Int = 2;

	public static var e_islandFlag:Int = 4;

	public static var e_toiFlag:Int = 8;

	public static var e_touchingFlag:Int = 16;

	public static var e_enabledFlag:Int = 32;

	public static var e_filterFlag:Int = 64;

	public static var s_input:B2TOIInput = new B2TOIInput();

	public var m_toi:Float = Math.NaN;

	public var m_prev:B2Contact;

	public var m_oldManifold:B2Manifold;

	public var m_nodeB:B2ContactEdge;

	public var m_nodeA:B2ContactEdge;

	public var m_next:B2Contact;

	public var m_manifold:B2Manifold;

	public var m_flags:Int = 0;

	public var m_fixtureB:B2Fixture;

	public var m_fixtureA:B2Fixture;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_toi = 0;
		m_flags = 0;
		m_nodeA = new B2ContactEdge();
		m_nodeB = new B2ContactEdge();
		m_manifold = new B2Manifold();
		m_oldManifold = new B2Manifold();
	}

	public function update(listener:B2ContactListener) {
		Update(listener);
	}

	public function setSensor(sensor:Bool) {
		SetSensor(sensor);
	}

	public function setEnabled(flag:Bool) {
		SetEnabled(flag);
	}

	public function reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		Reset(fixtureA, fixtureB);
	}

	public function isTouching():Bool {
		return IsTouching();
	}

	public function isSensor():Bool {
		return IsSensor();
	}

	public function isEnabled():Bool {
		return IsEnabled();
	}

	public function isContinuous():Bool {
		return IsContinuous();
	}

	public function getWorldManifold(worldManifold:B2WorldManifold) {
		GetWorldManifold(worldManifold);
	}

	public function getNext():B2Contact {
		return GetNext();
	}

	public function getManifold():B2Manifold {
		return GetManifold();
	}

	public function getFixtureB():B2Fixture {
		return GetFixtureB();
	}

	public function getFixtureA():B2Fixture {
		return GetFixtureA();
	}

	public function flagForFiltering() {
		FlagForFiltering();
	}

	public function evaluate() {
		Evaluate();
	}

	public function computeTOI(sweepA:B2Sweep, sweepB:B2Sweep):Float {
		return ComputeTOI(sweepA, sweepB);
	}

	public function Update(listener:B2ContactListener) {
		var _loc8_ = ASCompat.dynamicAs(null, B2Shape);
		var _loc9_ = ASCompat.dynamicAs(null, B2Shape);
		var _loc10_ = ASCompat.dynamicAs(null, B2Transform);
		var _loc11_ = ASCompat.dynamicAs(null, B2Transform);
		var _loc12_ = 0;
		var _loc13_ = 0;
		var _loc14_ = 0;
		var _loc15_:ASAny = ASCompat.dynamicAs(null, B2ManifoldPoint);
		var _loc16_:ASAny = ASCompat.dynamicAs(null, B2ContactID);
		var _loc17_ = 0;
		var _loc18_ = 0;
		var _loc19_ = 0;
		var _loc20_:ASAny = ASCompat.dynamicAs(null, B2ManifoldPoint);
		var _loc2_ = m_oldManifold;
		m_oldManifold = m_manifold;
		m_manifold = _loc2_;
		m_flags = m_flags | B2Contact.e_enabledFlag;
		var _loc3_ = false;
		var _loc4_ = (m_flags & B2Contact.e_touchingFlag) == B2Contact.e_touchingFlag;
		var _loc5_ = m_fixtureA.m_body;
		var _loc6_ = m_fixtureB.m_body;
		var _loc7_ = m_fixtureA.m_aabb.testOverlap(m_fixtureB.m_aabb);
		if ((m_flags & B2Contact.e_sensorFlag) != 0) {
			if (_loc7_) {
				_loc8_ = m_fixtureA.getShape();
				_loc9_ = m_fixtureB.getShape();
				_loc10_ = _loc5_.getTransform();
				_loc11_ = _loc6_.getTransform();
				_loc3_ = B2Shape.testOverlap(_loc8_, _loc10_, _loc9_, _loc11_);
			}
			m_manifold.m_pointCount = 0;
		} else {
			if (_loc5_.m_type != B2Body.b2_dynamicBody
				|| (_loc5_.m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag
					|| _loc6_.m_type != B2Body.b2_dynamicBody
					|| (_loc6_.m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag) {
				m_flags = m_flags | B2Contact.e_continuousFlag;
			} else {
				m_flags = m_flags & ~B2Contact.e_continuousFlag;
			}
			if (_loc7_) {
				evaluate();
				_loc3_ = m_manifold.m_pointCount > 0;
				_loc12_ = 0;
				_loc13_ = m_manifold.m_pointCount;
				while (_loc12_ < _loc13_) {
					_loc14_ = _loc12_++;
					_loc15_ = m_manifold.m_points[_loc14_];
					ASCompat.setProperty(_loc15_, "m_normalImpulse", 0);
					ASCompat.setProperty(_loc15_, "m_tangentImpulse", 0);
					_loc16_ = _loc15_.m_id;
					_loc17_ = 0;
					_loc18_ = m_oldManifold.m_pointCount;
					while (_loc17_ < _loc18_) {
						_loc19_ = _loc17_++;
						_loc20_ = m_oldManifold.m_points[_loc19_];
						if (_loc20_.m_id.get_key() == _loc16_.get_key()) {
							ASCompat.setProperty(_loc15_, "m_normalImpulse", _loc20_.m_normalImpulse);
							ASCompat.setProperty(_loc15_, "m_tangentImpulse", _loc20_.m_tangentImpulse);
							break;
						}
					}
				}
			} else {
				m_manifold.m_pointCount = 0;
			}
			if (_loc3_ != _loc4_) {
				_loc5_.setAwake(true);
				_loc6_.setAwake(true);
			}
		}
		if (_loc3_) {
			m_flags = m_flags | B2Contact.e_touchingFlag;
		} else {
			m_flags = m_flags & ~B2Contact.e_touchingFlag;
		}
		if (_loc4_ == false && _loc3_ == true) {
			listener.beginContact(this);
		}
		if (_loc4_ == true && _loc3_ == false) {
			listener.endContact(this);
		}
		if ((m_flags & B2Contact.e_sensorFlag) == 0) {
			listener.preSolve(this, m_oldManifold);
		}
	}

	public function SetSensor(sensor:Bool) {
		if (sensor) {
			m_flags = m_flags | B2Contact.e_sensorFlag;
		} else {
			m_flags = m_flags & ~B2Contact.e_sensorFlag;
		}
	}

	public function SetEnabled(flag:Bool) {
		if (flag) {
			m_flags = m_flags | B2Contact.e_enabledFlag;
		} else {
			m_flags = m_flags & ~B2Contact.e_enabledFlag;
		}
	}

	public function Reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		m_flags = B2Contact.e_enabledFlag;
		if (fixtureA == null || fixtureB == null) {
			m_fixtureA = null;
			m_fixtureB = null;
			return;
		}
		if (fixtureA.isSensor() || fixtureB.isSensor()) {
			m_flags = m_flags | B2Contact.e_sensorFlag;
		}
		var _loc3_ = fixtureA.getBody();
		var _loc4_ = fixtureB.getBody();
		if (_loc3_.m_type != 2
			|| (_loc3_.m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag
				|| _loc4_.m_type != 2
				|| (_loc4_.m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag) {
			m_flags = m_flags | B2Contact.e_continuousFlag;
		}
		m_fixtureA = fixtureA;
		m_fixtureB = fixtureB;
		m_manifold.m_pointCount = 0;
		m_prev = null;
		m_next = null;
		m_nodeA.contact = null;
		m_nodeA.prev = null;
		m_nodeA.next = null;
		m_nodeA.other = null;
		m_nodeB.contact = null;
		m_nodeB.prev = null;
		m_nodeB.next = null;
		m_nodeB.other = null;
	}

	public function IsTouching():Bool {
		return (m_flags & B2Contact.e_touchingFlag) == B2Contact.e_touchingFlag;
	}

	public function IsSensor():Bool {
		return (m_flags & B2Contact.e_sensorFlag) == B2Contact.e_sensorFlag;
	}

	public function IsEnabled():Bool {
		return (m_flags & B2Contact.e_enabledFlag) == B2Contact.e_enabledFlag;
	}

	public function IsContinuous():Bool {
		return (m_flags & B2Contact.e_continuousFlag) == B2Contact.e_continuousFlag;
	}

	public function GetWorldManifold(worldManifold:B2WorldManifold) {
		var _loc2_ = m_fixtureA.getBody();
		var _loc3_ = m_fixtureB.getBody();
		var _loc4_ = m_fixtureA.getShape();
		var _loc5_ = m_fixtureB.getShape();
		worldManifold.initialize(m_manifold, _loc2_.getTransform(), _loc4_.m_radius, _loc3_.getTransform(), _loc5_.m_radius);
	}

	public function GetNext():B2Contact {
		return m_next;
	}

	public function GetManifold():B2Manifold {
		return m_manifold;
	}

	public function GetFixtureB():B2Fixture {
		return m_fixtureB;
	}

	public function GetFixtureA():B2Fixture {
		return m_fixtureA;
	}

	public function FlagForFiltering() {
		m_flags = m_flags | B2Contact.e_filterFlag;
	}

	public function Evaluate() {}

	public function ComputeTOI(sweepA:B2Sweep, sweepB:B2Sweep):Float {
		B2Contact.s_input.proxyA.set(m_fixtureA.getShape());
		B2Contact.s_input.proxyB.set(m_fixtureB.getShape());
		B2Contact.s_input.sweepA = sweepA;
		B2Contact.s_input.sweepB = sweepB;
		B2Contact.s_input.tolerance = B2Settings.b2_linearSlop;
		return B2TimeOfImpact.timeOfImpact(B2Contact.s_input);
	}
}
