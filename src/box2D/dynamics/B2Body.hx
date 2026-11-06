package box2D.dynamics;

import box2D.collision.IBroadPhase;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2MassData;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Math;
import box2D.common.math.B2Sweep;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.dynamics.controllers.B2ControllerEdge;
import box2D.dynamics.joints.B2JointEdge;

class B2Body {
	public static var e_islandFlag:Int = 1;

	public static var e_awakeFlag:Int = 2;

	public static var e_allowSleepFlag:Int = 4;

	public static var e_bulletFlag:Int = 8;

	public static var e_fixedRotationFlag:Int = 16;

	public static var e_activeFlag:Int = 32;

	public static var b2_staticBody:Int = 0;

	public static var b2_kinematicBody:Int = 1;

	public static var b2_dynamicBody:Int = 2;

	public static var s_xf1:B2Transform = new B2Transform();

	public var m_xf:B2Transform;

	public var m_world:B2World;

	public var m_userData:ASAny;

	public var m_type:Int = 0;

	public var m_torque:Float = Math.NaN;

	public var m_sweep:B2Sweep;

	public var m_sleepTime:Float = Math.NaN;

	public var m_prev:B2Body;

	public var m_next:B2Body;

	public var m_mass:Float = Math.NaN;

	public var m_linearVelocity:B2Vec2;

	public var m_linearDamping:Float = Math.NaN;

	public var m_jointList:B2JointEdge;

	public var m_islandIndex:Int = 0;

	public var m_invMass:Float = Math.NaN;

	public var m_invI:Float = Math.NaN;

	public var m_inertiaScale:Float = Math.NaN;

	public var m_gravityScale:Float = Math.NaN;

	public var m_force:B2Vec2;

	public var m_flags:Int = 0;

	public var m_fixtureList:B2Fixture;

	public var m_fixtureCount:Int = 0;

	public var m_controllerList:B2ControllerEdge;

	public var m_controllerCount:Int = 0;

	public var m_contactList:B2ContactEdge;

	public var m_angularVelocity:Float = Math.NaN;

	public var m_angularDamping:Float = Math.NaN;

	public var m_I:Float = Math.NaN;

	public function new(bd:B2BodyDef = /*undefined*/ null, world:B2World = /*undefined*/ null) {
		m_xf = new B2Transform();
		m_sweep = new B2Sweep();
		m_linearVelocity = new B2Vec2();
		m_force = new B2Vec2();
		m_flags = 0;
		if (bd.bullet) {
			m_flags = m_flags | B2Body.e_bulletFlag;
		}
		if (bd.fixedRotation) {
			m_flags = m_flags | B2Body.e_fixedRotationFlag;
		}
		if (bd.allowSleep) {
			m_flags = m_flags | B2Body.e_allowSleepFlag;
		}
		if (bd.awake) {
			m_flags = m_flags | B2Body.e_awakeFlag;
		}
		if (bd.active) {
			m_flags = m_flags | B2Body.e_activeFlag;
		}
		m_world = world;
		m_xf.position.setV(bd.position);
		m_xf.R.set(bd.angle);
		m_sweep.localCenter.setZero();
		m_sweep.t0 = 1;
		m_sweep.a0 = m_sweep.a = bd.angle;
		var _loc4_ = m_xf.R;
		var _loc5_ = m_sweep.localCenter;
		m_sweep.c.x = _loc4_.col1.x * _loc5_.x + _loc4_.col2.x * _loc5_.y;
		m_sweep.c.y = _loc4_.col1.y * _loc5_.x + _loc4_.col2.y * _loc5_.y;
		m_sweep.c.x += m_xf.position.x;
		m_sweep.c.y += m_xf.position.y;
		m_sweep.c0.setV(m_sweep.c);
		m_jointList = null;
		m_controllerList = null;
		m_contactList = null;
		m_controllerCount = 0;
		m_prev = null;
		m_next = null;
		m_linearVelocity.setV(bd.linearVelocity);
		m_angularVelocity = bd.angularVelocity;
		m_linearDamping = bd.linearDamping;
		m_angularDamping = bd.angularDamping;
		m_gravityScale = bd.gravityScale;
		m_force.set(0, 0);
		m_torque = 0;
		m_sleepTime = 0;
		m_type = bd.type;
		if (m_type == 2) {
			m_mass = 1;
			m_invMass = 1;
		} else {
			m_mass = 0;
			m_invMass = 0;
		}
		m_I = 0;
		m_invI = 0;
		m_inertiaScale = bd.inertiaScale;
		m_userData = bd.userData;
		m_fixtureList = null;
		m_fixtureCount = 0;
	}

	public function synchronizeTransform() {
		SynchronizeTransform();
	}

	public function synchronizeFixtures() {
		SynchronizeFixtures();
	}

	public function split(callbackMethod:ASFunction):B2Body {
		return Split(callbackMethod);
	}

	public function shouldCollide(other:B2Body):Bool {
		return ShouldCollide(other);
	}

	public function setUserData(data:ASAny) {
		SetUserData(data);
	}

	public function setType(type:Int) {
		SetType(type);
	}

	public function setTransform(xf:B2Transform) {
		SetTransform(xf);
	}

	public function setSleepingAllowed(flag:Bool) {
		SetSleepingAllowed(flag);
	}

	public function setPositionAndAngle(position:B2Vec2, angle:Float) {
		SetPositionAndAngle(position, angle);
	}

	public function setPosition(position:B2Vec2) {
		SetPosition(position);
	}

	public function setMassData(massData:B2MassData) {
		SetMassData(massData);
	}

	public function setLinearVelocity(v:B2Vec2) {
		SetLinearVelocity(v);
	}

	public function setLinearDamping(linearDamping:Float) {
		SetLinearDamping(linearDamping);
	}

	public function setGravityScale(scale:Float) {
		SetGravityScale(scale);
	}

	public function setFixedRotation(fixed:Bool) {
		SetFixedRotation(fixed);
	}

	public function setBullet(flag:Bool) {
		SetBullet(flag);
	}

	public function setAwake(flag:Bool) {
		SetAwake(flag);
	}

	public function setAngularVelocity(omega:Float) {
		SetAngularVelocity(omega);
	}

	public function setAngularDamping(angularDamping:Float) {
		SetAngularDamping(angularDamping);
	}

	public function setAngle(angle:Float) {
		SetAngle(angle);
	}

	public function setActive(flag:Bool) {
		SetActive(flag);
	}

	public function resetMassData() {
		ResetMassData();
	}

	public function merge(other:B2Body) {
		Merge(other);
	}

	public function isSleepingAllowed():Bool {
		return IsSleepingAllowed();
	}

	public function isFixedRotation():Bool {
		return IsFixedRotation();
	}

	public function isBullet():Bool {
		return (m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag;
	}

	public function isAwake():Bool {
		return (m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag;
	}

	public function isActive():Bool {
		return (m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag;
	}

	public function getWorldVector(localVector:B2Vec2):B2Vec2 {
		return GetWorldVector(localVector);
	}

	public function getWorldPoint(localPoint:B2Vec2):B2Vec2 {
		return GetWorldPoint(localPoint);
	}

	public function getWorldCenter():B2Vec2 {
		return GetWorldCenter();
	}

	public function getWorld():B2World {
		return GetWorld();
	}

	public function getUserData():ASAny {
		return GetUserData();
	}

	public function getType():Int {
		return m_type;
	}

	public function getTransform():B2Transform {
		return GetTransform();
	}

	public function getPosition():B2Vec2 {
		return GetPosition();
	}

	public function getNext():B2Body {
		return GetNext();
	}

	public function getMassData(data:B2MassData) {
		GetMassData(data);
	}

	public function getMass():Float {
		return GetMass();
	}

	public function getLocalVector(worldVector:B2Vec2):B2Vec2 {
		return GetLocalVector(worldVector);
	}

	public function getLocalPoint(worldPoint:B2Vec2):B2Vec2 {
		return GetLocalPoint(worldPoint);
	}

	public function getLocalCenter():B2Vec2 {
		return GetLocalCenter();
	}

	public function getLinearVelocityFromWorldPoint(worldPoint:B2Vec2):B2Vec2 {
		return GetLinearVelocityFromWorldPoint(worldPoint);
	}

	public function getLinearVelocityFromLocalPoint(localPoint:B2Vec2):B2Vec2 {
		return GetLinearVelocityFromLocalPoint(localPoint);
	}

	public function getLinearVelocity():B2Vec2 {
		return GetLinearVelocity();
	}

	public function getLinearDamping():Float {
		return GetLinearDamping();
	}

	public function getJointList():B2JointEdge {
		return GetJointList();
	}

	public function getInertia():Float {
		return GetInertia();
	}

	public function getGravityScale():Float {
		return GetGravityScale();
	}

	public function getFixtureList():B2Fixture {
		return GetFixtureList();
	}

	public function getDefinition():B2BodyDef {
		return GetDefinition();
	}

	public function getControllerList():B2ControllerEdge {
		return GetControllerList();
	}

	public function getContactList():B2ContactEdge {
		return GetContactList();
	}

	public function getAngularVelocity():Float {
		return GetAngularVelocity();
	}

	public function getAngularDamping():Float {
		return GetAngularDamping();
	}

	public function getAngle():Float {
		return GetAngle();
	}

	public function createFixture2(shape:B2Shape, density:Float = 0):B2Fixture {
		return CreateFixture2(shape, density);
	}

	public function createFixture(def:B2FixtureDef):B2Fixture {
		return CreateFixture(def);
	}

	public function connectEdges(s1:B2EdgeShape, s2:B2EdgeShape, angle1:Float):Float {
		var _loc4_ = Math.atan2(s2.getDirectionVector().y, s2.getDirectionVector().x);
		var _loc5_ = Math.tan((_loc4_ - angle1) * 0.5);
		var _loc6_ = B2Math.mulFV(_loc5_, s2.getDirectionVector());
		_loc6_ = B2Math.subtractVV(_loc6_, s2.getNormalVector());
		_loc6_ = B2Math.mulFV(B2Settings.b2_toiSlop, _loc6_);
		_loc6_ = B2Math.addVV(_loc6_, s2.getVertex1());
		var _loc7_ = B2Math.addVV(s1.getDirectionVector(), s2.getDirectionVector());
		_loc7_.normalize();
		var _loc8_ = B2Math.dot(s1.getDirectionVector(), s2.getNormalVector()) > 0;
		s1.setNextEdge(s2, _loc6_, _loc7_, _loc8_);
		s2.setPrevEdge(s1, _loc6_, _loc7_, _loc8_);
		return _loc4_;
	}

	public function applyTorque(torque:Float) {
		ApplyTorque(torque);
	}

	public function applyImpulse(impulse:B2Vec2, point:B2Vec2) {
		ApplyImpulse(impulse, point);
	}

	public function applyForce(force:B2Vec2, point:B2Vec2) {
		ApplyForce(force, point);
	}

	public function advance(t:Float) {
		Advance(t);
	}

	public function SynchronizeTransform() {
		m_xf.R.set(m_sweep.a);
		var _loc1_ = m_xf.R;
		var _loc2_ = m_sweep.localCenter;
		m_xf.position.x = m_sweep.c.x - (_loc1_.col1.x * _loc2_.x + _loc1_.col2.x * _loc2_.y);
		m_xf.position.y = m_sweep.c.y - (_loc1_.col1.y * _loc2_.x + _loc1_.col2.y * _loc2_.y);
	}

	public function SynchronizeFixtures() {
		var _loc1_ = B2Body.s_xf1;
		_loc1_.R.set(m_sweep.a0);
		var _loc2_ = _loc1_.R;
		var _loc3_ = m_sweep.localCenter;
		_loc1_.position.x = m_sweep.c0.x - (_loc2_.col1.x * _loc3_.x + _loc2_.col2.x * _loc3_.y);
		_loc1_.position.y = m_sweep.c0.y - (_loc2_.col1.y * _loc3_.x + _loc2_.col2.y * _loc3_.y);
		var _loc4_ = m_world.m_contactManager.m_broadPhase;
		var _loc5_ = m_fixtureList;
		while (_loc5_ != null) {
			_loc5_.synchronize(_loc4_, _loc1_, m_xf);
			_loc5_ = _loc5_.m_next;
		}
	}

	public function Split(callbackMethod:ASFunction):B2Body {
		var _loc9_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc2_ = getLinearVelocity().copy();
		var _loc3_ = getAngularVelocity();
		var _loc4_ = getWorldCenter();
		var _loc5_ = this;
		var _loc6_ = m_world.createBody(getDefinition());
		var _loc7_:B2Fixture = null;
		var _loc8_ = _loc5_.m_fixtureList;
		while (_loc8_ != null) {
			if (ASCompat.toBool(callbackMethod(_loc8_))) {
				_loc9_ = _loc8_.m_next;
				if (_loc7_ != null) {
					_loc7_.m_next = _loc9_;
				} else {
					_loc5_.m_fixtureList = _loc9_;
				}
				--_loc5_.m_fixtureCount;
				_loc8_.m_next = _loc6_.m_fixtureList;
				_loc6_.m_fixtureList = _loc8_;
				++_loc6_.m_fixtureCount;
				_loc8_.m_body = _loc6_;
				_loc8_ = _loc9_;
			} else {
				_loc7_ = _loc8_;
				_loc8_ = _loc8_.m_next;
			}
		}
		_loc5_.resetMassData();
		_loc6_.resetMassData();
		var _loc10_ = _loc5_.getWorldCenter();
		var _loc11_ = _loc6_.getWorldCenter();
		var _loc12_ = B2Math.addVV(_loc2_, B2Math.crossFV(_loc3_, B2Math.subtractVV(_loc10_, _loc4_)));
		var _loc13_ = B2Math.addVV(_loc2_, B2Math.crossFV(_loc3_, B2Math.subtractVV(_loc11_, _loc4_)));
		_loc5_.setLinearVelocity(_loc12_);
		_loc6_.setLinearVelocity(_loc13_);
		_loc5_.setAngularVelocity(_loc3_);
		_loc6_.setAngularVelocity(_loc3_);
		_loc5_.synchronizeFixtures();
		_loc6_.synchronizeFixtures();
		return _loc6_;
	}

	public function ShouldCollide(other:B2Body):Bool {
		if (m_type != 2 && other.m_type != 2) {
			return false;
		}
		var _loc2_ = m_jointList;
		while (_loc2_ != null) {
			if (_loc2_.other == other) {
				if (_loc2_.joint.m_collideConnected == false) {
					return false;
				}
			}
			_loc2_ = _loc2_.next;
		}
		return true;
	}

	public function SetUserData(data:ASAny) {
		m_userData = data;
	}

	public function SetType(type:Int) {
		if (m_type == type) {
			return;
		}
		m_type = type;
		resetMassData();
		if (m_type == 0) {
			m_linearVelocity.setZero();
			m_angularVelocity = 0;
		}
		setAwake(true);
		m_force.setZero();
		m_torque = 0;
		var _loc2_ = m_contactList;
		while (_loc2_ != null) {
			_loc2_.contact.flagForFiltering();
			_loc2_ = _loc2_.next;
		}
	}

	public function SetTransform(xf:B2Transform) {
		setPositionAndAngle(xf.position, xf.getAngle());
	}

	public function SetSleepingAllowed(flag:Bool) {
		if (flag) {
			m_flags = m_flags | B2Body.e_allowSleepFlag;
		} else {
			m_flags = m_flags & ~B2Body.e_allowSleepFlag;
			setAwake(true);
		}
	}

	public function SetPositionAndAngle(position:B2Vec2, angle:Float) {
		if (m_world.isLocked() == true) {
			return;
		}
		m_xf.R.set(angle);
		m_xf.position.setV(position);
		var _loc3_ = m_xf.R;
		var _loc4_ = m_sweep.localCenter;
		m_sweep.c.x = _loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y;
		m_sweep.c.y = _loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y;
		m_sweep.c.x += m_xf.position.x;
		m_sweep.c.y += m_xf.position.y;
		m_sweep.c0.setV(m_sweep.c);
		m_sweep.a0 = m_sweep.a = angle;
		var _loc6_ = m_world.m_contactManager.m_broadPhase;
		var _loc7_ = m_fixtureList;
		while (_loc7_ != null) {
			_loc7_.synchronize(_loc6_, m_xf, m_xf);
			_loc7_ = _loc7_.m_next;
		}
		m_world.m_contactManager.findNewContacts();
	}

	public function SetPosition(position:B2Vec2) {
		setPositionAndAngle(position, getAngle());
	}

	public function SetMassData(massData:B2MassData) {
		B2Settings.b2Assert(m_world.isLocked() == false);
		if (m_world.isLocked() == true) {
			return;
		}
		if (m_type != 2) {
			return;
		}
		m_invMass = 0;
		m_I = 0;
		m_invI = 0;
		m_mass = massData.mass;
		if (m_mass <= 0) {
			m_mass = 1;
		}
		m_invMass = 1 / m_mass;
		if (massData.I > 0 && (m_flags & B2Body.e_fixedRotationFlag) == 0) {
			m_I = massData.I - m_mass * (massData.center.x * massData.center.x + massData.center.y * massData.center.y);
			m_invI = 1 / m_I;
		}
		var _loc2_ = m_sweep.c.copy();
		m_sweep.localCenter.setV(massData.center);
		m_sweep.c0.setV(B2Math.mulX(m_xf, m_sweep.localCenter));
		m_sweep.c.setV(m_sweep.c0);
		m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - _loc2_.y);
		m_linearVelocity.y += m_angularVelocity * (m_sweep.c.x - _loc2_.x);
	}

	public function SetLinearVelocity(v:B2Vec2) {
		if (m_type == 0) {
			return;
		}
		m_linearVelocity.setV(v);
	}

	public function SetLinearDamping(linearDamping:Float) {
		m_linearDamping = linearDamping;
	}

	public function SetGravityScale(scale:Float) {
		m_gravityScale = scale;
	}

	public function SetFixedRotation(fixed:Bool) {
		if (fixed) {
			m_flags = m_flags | B2Body.e_fixedRotationFlag;
		} else {
			m_flags = m_flags & ~B2Body.e_fixedRotationFlag;
		}
		resetMassData();
	}

	public function SetBullet(flag:Bool) {
		if (flag) {
			m_flags = m_flags | B2Body.e_bulletFlag;
		} else {
			m_flags = m_flags & ~B2Body.e_bulletFlag;
		}
	}

	public function SetAwake(flag:Bool) {
		if (flag) {
			m_flags = m_flags | B2Body.e_awakeFlag;
			m_sleepTime = 0;
		} else {
			m_flags = m_flags & ~B2Body.e_awakeFlag;
			m_sleepTime = 0;
			m_linearVelocity.setZero();
			m_angularVelocity = 0;
			m_force.setZero();
			m_torque = 0;
		}
	}

	public function SetAngularVelocity(omega:Float) {
		if (m_type == 0) {
			return;
		}
		m_angularVelocity = omega;
	}

	public function SetAngularDamping(angularDamping:Float) {
		m_angularDamping = angularDamping;
	}

	public function SetAngle(angle:Float) {
		setPositionAndAngle(getPosition(), angle);
	}

	public function SetActive(flag:Bool) {
		var _loc2_ = ASCompat.dynamicAs(null, IBroadPhase);
		var _loc3_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2ContactEdge);
		var _loc5_ = ASCompat.dynamicAs(null, B2ContactEdge);
		if (flag == ((m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag)) {
			return;
		}
		if (flag) {
			m_flags = m_flags | B2Body.e_activeFlag;
			_loc2_ = m_world.m_contactManager.m_broadPhase;
			_loc3_ = m_fixtureList;
			while (_loc3_ != null) {
				_loc3_.createProxy(_loc2_, m_xf);
				_loc3_ = _loc3_.m_next;
			}
		} else {
			m_flags = m_flags & ~B2Body.e_activeFlag;
			_loc2_ = m_world.m_contactManager.m_broadPhase;
			_loc3_ = m_fixtureList;
			while (_loc3_ != null) {
				_loc3_.destroyProxy(_loc2_);
				_loc3_ = _loc3_.m_next;
			}
			_loc4_ = m_contactList;
			while (_loc4_ != null) {
				_loc5_ = _loc4_;
				_loc4_ = _loc4_.next;
				m_world.m_contactManager.destroy(ASCompat.coerce(_loc5_.contact, box2D.dynamics.contacts.B2Contact));
			}
			m_contactList = null;
		}
	}

	public function ResetMassData() {
		var _loc3_ = ASCompat.dynamicAs(null, B2MassData);
		m_mass = 0;
		m_invMass = 0;
		m_I = 0;
		m_invI = 0;
		m_sweep.localCenter.setZero();
		if (m_type == 0 || m_type == 1) {
			return;
		}
		var _loc1_ = B2Vec2.make(0, 0);
		var _loc2_ = m_fixtureList;
		while (_loc2_ != null) {
			if (_loc2_.m_density == 0) {
				_loc2_ = _loc2_.m_next;
			} else {
				_loc3_ = _loc2_.getMassData();
				m_mass += ASCompat.toNumberField(_loc3_, "mass");
				_loc1_.x += ASCompat.toNumberField(_loc3_.center, "x") * ASCompat.toNumberField(_loc3_, "mass");
				_loc1_.y += ASCompat.toNumberField(_loc3_.center, "y") * ASCompat.toNumberField(_loc3_, "mass");
				m_I += ASCompat.toNumberField(_loc3_, "I");
				_loc2_ = _loc2_.m_next;
			}
		}
		if (m_mass > 0) {
			m_invMass = 1 / m_mass;
			_loc1_.x *= m_invMass;
			_loc1_.y *= m_invMass;
		} else {
			m_mass = 1;
			m_invMass = 1;
		}
		if (m_I > 0 && (m_flags & B2Body.e_fixedRotationFlag) == 0) {
			m_I -= m_mass * (_loc1_.x * _loc1_.x + _loc1_.y * _loc1_.y);
			m_I *= m_inertiaScale;
			B2Settings.b2Assert(m_I > 0);
			m_invI = 1 / m_I;
		} else {
			m_I = 0;
			m_invI = 0;
		}
		var _loc4_ = m_sweep.c.copy();
		m_sweep.localCenter.setV(_loc1_);
		m_sweep.c0.setV(B2Math.mulX(m_xf, m_sweep.localCenter));
		m_sweep.c.setV(m_sweep.c0);
		m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - _loc4_.y);
		m_linearVelocity.y += m_angularVelocity * (m_sweep.c.x - _loc4_.x);
	}

	public function Merge(other:B2Body) {
		var _loc5_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc2_ = other.m_fixtureList;
		var _loc3_ = this;
		var _loc4_ = other;
		while (_loc2_ != null) {
			_loc5_ = _loc2_.m_next;
			--other.m_fixtureCount;
			_loc2_.m_next = m_fixtureList;
			m_fixtureList = _loc2_;
			++m_fixtureCount;
			_loc2_.m_body = _loc4_;
			_loc2_ = _loc5_;
		}
		_loc3_.m_fixtureCount = 0;
		var _loc6_ = _loc3_.getWorldCenter();
		var _loc7_ = _loc4_.getWorldCenter();
		var _loc8_ = _loc3_.getLinearVelocity().copy();
		var _loc9_ = _loc4_.getLinearVelocity().copy();
		var _loc10_ = _loc3_.getAngularVelocity();
		var _loc11_ = _loc4_.getAngularVelocity();
		_loc3_.resetMassData();
		synchronizeFixtures();
	}

	public function IsSleepingAllowed():Bool {
		return (m_flags & B2Body.e_allowSleepFlag) == B2Body.e_allowSleepFlag;
	}

	public function IsFixedRotation():Bool {
		return (m_flags & B2Body.e_fixedRotationFlag) == B2Body.e_fixedRotationFlag;
	}

	public function IsBullet():Bool {
		return (m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag;
	}

	public function IsAwake():Bool {
		return (m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag;
	}

	public function IsActive():Bool {
		return (m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag;
	}

	public function GetWorldVector(localVector:B2Vec2):B2Vec2 {
		return B2Math.mulMV(m_xf.R, localVector);
	}

	public function GetWorldPoint(localPoint:B2Vec2):B2Vec2 {
		var _loc2_ = m_xf.R;
		var _loc3_ = new B2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y, _loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
		_loc3_.x += m_xf.position.x;
		_loc3_.y += m_xf.position.y;
		return _loc3_;
	}

	public function GetWorldCenter():B2Vec2 {
		return m_sweep.c;
	}

	public function GetWorld():B2World {
		return m_world;
	}

	public function GetUserData():ASAny {
		return m_userData;
	}

	public function GetType():Int {
		return m_type;
	}

	public function GetTransform():B2Transform {
		return m_xf;
	}

	public function GetPosition():B2Vec2 {
		return m_xf.position;
	}

	public function GetNext():B2Body {
		return m_next;
	}

	public function GetMassData(data:B2MassData) {
		data.mass = m_mass;
		data.I = m_I;
		data.center.setV(m_sweep.localCenter);
	}

	public function GetMass():Float {
		return m_mass;
	}

	public function GetLocalVector(worldVector:B2Vec2):B2Vec2 {
		return B2Math.mulTMV(m_xf.R, worldVector);
	}

	public function GetLocalPoint(worldPoint:B2Vec2):B2Vec2 {
		return B2Math.mulXT(m_xf, worldPoint);
	}

	public function GetLocalCenter():B2Vec2 {
		return m_sweep.localCenter;
	}

	public function GetLinearVelocityFromWorldPoint(worldPoint:B2Vec2):B2Vec2 {
		return new B2Vec2(m_linearVelocity.x - m_angularVelocity * (worldPoint.y - m_sweep.c.y),
			m_linearVelocity.y + m_angularVelocity * (worldPoint.x - m_sweep.c.x));
	}

	public function GetLinearVelocityFromLocalPoint(localPoint:B2Vec2):B2Vec2 {
		var _loc2_ = m_xf.R;
		var _loc3_ = new B2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y, _loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
		_loc3_.x += m_xf.position.x;
		_loc3_.y += m_xf.position.y;
		return new B2Vec2(m_linearVelocity.x
			- m_angularVelocity * (_loc3_.y - m_sweep.c.y), m_linearVelocity.y
			+ m_angularVelocity * (_loc3_.x - m_sweep.c.x));
	}

	public function GetLinearVelocity():B2Vec2 {
		return m_linearVelocity;
	}

	public function GetLinearDamping():Float {
		return m_linearDamping;
	}

	public function GetJointList():B2JointEdge {
		return m_jointList;
	}

	public function GetInertia():Float {
		return m_I;
	}

	public function GetGravityScale():Float {
		return m_gravityScale;
	}

	public function GetFixtureList():B2Fixture {
		return m_fixtureList;
	}

	public function GetDefinition():B2BodyDef {
		var _loc1_ = new B2BodyDef();
		_loc1_.type = m_type;
		_loc1_.allowSleep = (m_flags & B2Body.e_allowSleepFlag) == B2Body.e_allowSleepFlag;
		_loc1_.angle = getAngle();
		_loc1_.angularDamping = m_angularDamping;
		_loc1_.gravityScale = getGravityScale();
		_loc1_.angularVelocity = m_angularVelocity;
		_loc1_.fixedRotation = (m_flags & B2Body.e_fixedRotationFlag) == B2Body.e_fixedRotationFlag;
		_loc1_.bullet = (m_flags & B2Body.e_bulletFlag) == B2Body.e_bulletFlag;
		_loc1_.awake = (m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag;
		_loc1_.linearDamping = m_linearDamping;
		_loc1_.linearVelocity.setV(getLinearVelocity());
		_loc1_.position = getPosition();
		_loc1_.userData = getUserData();
		return _loc1_;
	}

	public function GetControllerList():B2ControllerEdge {
		return m_controllerList;
	}

	public function GetContactList():B2ContactEdge {
		return m_contactList;
	}

	public function GetAngularVelocity():Float {
		return m_angularVelocity;
	}

	public function GetAngularDamping():Float {
		return m_angularDamping;
	}

	public function GetAngle():Float {
		return m_sweep.a;
	}

	public function DestroyFixture(fixture:B2Fixture) {
		var _loc6_ = ASCompat.dynamicAs(null, B2Contact);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc9_ = ASCompat.dynamicAs(null, IBroadPhase);
		if (m_world.isLocked() == true) {
			return;
		}
		var _loc2_ = m_fixtureList;
		var _loc3_:B2Fixture = null;
		var _loc4_ = false;
		while (_loc2_ != null) {
			if (_loc2_ == fixture) {
				if (_loc3_ != null) {
					_loc3_.m_next = fixture.m_next;
				} else {
					m_fixtureList = fixture.m_next;
				}
				_loc4_ = true;
				break;
			}
			_loc3_ = _loc2_;
			_loc2_ = _loc2_.m_next;
		}
		var _loc5_ = m_contactList;
		while (_loc5_ != null) {
			_loc6_ = _loc5_.contact;
			_loc5_ = _loc5_.next;
			_loc7_ = _loc6_.getFixtureA();
			_loc8_ = _loc6_.getFixtureB();
			if (fixture == _loc7_ || fixture == _loc8_) {
				m_world.m_contactManager.destroy(_loc6_);
			}
		}
		if ((m_flags & B2Body.e_activeFlag) != 0) {
			_loc9_ = m_world.m_contactManager.m_broadPhase;
			fixture.destroyProxy(_loc9_);
		}
		fixture.destroy();
		fixture.m_body = null;
		fixture.m_next = null;
		--m_fixtureCount;
		resetMassData();
	}

	public function CreateFixture2(shape:B2Shape, density:Float = 0):B2Fixture {
		var _loc3_ = new B2FixtureDef();
		_loc3_.shape = shape;
		_loc3_.density = density;
		return createFixture(_loc3_);
	}

	public function CreateFixture(def:B2FixtureDef):B2Fixture {
		var _loc3_ = ASCompat.dynamicAs(null, IBroadPhase);
		if (m_world.isLocked() == true) {
			return null;
		}
		var _loc2_ = new B2Fixture();
		_loc2_.create(this, m_xf, def);
		if ((m_flags & B2Body.e_activeFlag) != 0) {
			_loc3_ = m_world.m_contactManager.m_broadPhase;
			_loc2_.createProxy(_loc3_, m_xf);
		}
		_loc2_.m_next = m_fixtureList;
		m_fixtureList = _loc2_;
		++m_fixtureCount;
		_loc2_.m_body = this;
		if (_loc2_.m_density > 0) {
			resetMassData();
		}
		m_world.m_flags = m_world.m_flags | B2World.e_newFixture;
		return _loc2_;
	}

	public function ApplyTorque(torque:Float) {
		if (m_type != 2) {
			return;
		}
		if ((m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
			setAwake(true);
		}
		m_torque += torque;
	}

	public function ApplyImpulse(impulse:B2Vec2, point:B2Vec2) {
		if (m_type != 2) {
			return;
		}
		if ((m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
			setAwake(true);
		}
		m_linearVelocity.x += m_invMass * impulse.x;
		m_linearVelocity.y += m_invMass * impulse.y;
		m_angularVelocity += m_invI * ((point.x - m_sweep.c.x) * impulse.y - (point.y - m_sweep.c.y) * impulse.x);
	}

	public function ApplyForce(force:B2Vec2, point:B2Vec2) {
		if (m_type != 2) {
			return;
		}
		if ((m_flags & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
			setAwake(true);
		}
		m_force.x += force.x;
		m_force.y += force.y;
		m_torque += (point.x - m_sweep.c.x) * force.y - (point.y - m_sweep.c.y) * force.x;
	}

	public function Advance(t:Float) {
		m_sweep.advance(t);
		m_sweep.c.setV(m_sweep.c0);
		m_sweep.a = m_sweep.a0;
		synchronizeTransform();
	}
}
