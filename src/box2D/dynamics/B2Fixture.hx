package box2D.dynamics;

import box2D.collision.IBroadPhase;
import box2D.collision.shapes.B2MassData;
import box2D.collision.shapes.B2Shape;
import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.contacts.B2Contact;
import box2dcompat.Scratch;
import flash.Boot;

class B2Fixture {
	public var m_userData:ASAny;

	public var m_shape:B2Shape;

	public var m_restitution:Float = Math.NaN;

	public var m_proxy:ASAny;

	public var m_next:B2Fixture;

	public var m_massData:B2MassData;

	public var m_isSensor:Bool = false;

	public var m_friction:Float = Math.NaN;

	public var m_filter:B2FilterData;

	public var m_density:Float = Math.NaN;

	public var m_body:B2Body;

	public var m_aabb:B2AABB;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_filter = new B2FilterData();
		m_aabb = new B2AABB();
		m_userData = null;
		m_body = null;
		m_next = null;
		m_shape = null;
		m_density = 0;
		m_friction = 0;
		m_restitution = 0;
	}

	public function testPoint(p:B2Vec2):Bool {
		return TestPoint(p);
	}

	public function synchronize(broadPhase:IBroadPhase, transform1:B2Transform, transform2:B2Transform) {
		Synchronize(broadPhase, transform1, transform2);
	}

	public function setUserData(data:ASAny) {
		SetUserData(data);
	}

	public function setSensor(sensor:Bool) {
		SetSensor(sensor);
	}

	public function setRestitution(restitution:Float) {
		SetRestitution(restitution);
	}

	public function setFriction(friction:Float) {
		SetFriction(friction);
	}

	public function setFilterData(filter:B2FilterData) {
		SetFilterData(filter);
	}

	public function setDensity(density:Float) {
		SetDensity(density);
	}

	public function rayCast(output:B2RayCastOutput, input:B2RayCastInput):Bool {
		return RayCast(output, input);
	}

	public function isSensor():Bool {
		return IsSensor();
	}

	public function getUserData():ASAny {
		return GetUserData();
	}

	public function getType():Int {
		return GetType();
	}

	public function getShape():B2Shape {
		return GetShape();
	}

	public function getRestitution():Float {
		return GetRestitution();
	}

	public function getNext():B2Fixture {
		return GetNext();
	}

	public function getMassData(massData:B2MassData = /*undefined*/ null):B2MassData {
		return GetMassData(massData);
	}

	public function getFriction():Float {
		return GetFriction();
	}

	public function getFilterData():B2FilterData {
		return GetFilterData();
	}

	public function getDensity():Float {
		return GetDensity();
	}

	public function getBody():B2Body {
		return GetBody();
	}

	public function getAABB():B2AABB {
		return GetAABB();
	}

	public function destroyProxy(broadPhase:IBroadPhase) {
		DestroyProxy(broadPhase);
	}

	public function destroy() {
		Destroy();
	}

	public function createProxy(broadPhase:IBroadPhase, xf:B2Transform) {
		CreateProxy(broadPhase, xf);
	}

	public function create(body:B2Body, xf:B2Transform, def:B2FixtureDef) {
		Create(body, xf, def);
	}

	public function TestPoint(p:B2Vec2):Bool {
		return m_shape.testPoint(m_body.getTransform(), p);
	}

	public function Synchronize(broadPhase:IBroadPhase, transform1:B2Transform, transform2:B2Transform) {
		if (m_proxy == null) {
			return;
		}
		var _loc4_ = ASCompat.coerce(Scratch.aabbs[0], box2D.collision.B2AABB);
		var _loc5_ = ASCompat.coerce(Scratch.aabbs[1], box2D.collision.B2AABB);
		m_shape.computeAABB(_loc4_, transform1);
		m_shape.computeAABB(_loc5_, transform2);
		m_aabb.combine(_loc4_, _loc5_);
		var _loc6_ = transform2.position;
		var _loc7_ = transform1.position;
		Scratch.difference.x = _loc6_.x - _loc7_.x;
		Scratch.difference.y = _loc6_.y - _loc7_.y;
		var _loc8_ = Scratch.difference;
		broadPhase.moveProxy(m_proxy, m_aabb, _loc8_);
	}

	public function SetUserData(data:ASAny) {
		m_userData = data;
	}

	public function SetSensor(sensor:Bool) {
		var _loc3_ = ASCompat.dynamicAs(null, B2Contact);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		if (m_isSensor == sensor) {
			return;
		}
		m_isSensor = sensor;
		if (m_body == null) {
			return;
		}
		var _loc2_ = m_body.getContactList();
		while (_loc2_ != null) {
			_loc3_ = _loc2_.contact;
			_loc4_ = _loc3_.getFixtureA();
			_loc5_ = _loc3_.getFixtureB();
			if (_loc4_ == this || _loc5_ == this) {
				_loc3_.setSensor(ASCompat.thisOrDefault(_loc4_.isSensor(), _loc5_.isSensor()));
			}
			_loc2_ = _loc2_.next;
		}
	}

	public function SetRestitution(restitution:Float) {
		m_restitution = restitution;
	}

	public function SetFriction(friction:Float) {
		m_friction = friction;
	}

	public function SetFilterData(filter:B2FilterData) {
		var _loc3_ = ASCompat.dynamicAs(null, B2Contact);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		m_filter = filter.copy();
		if (m_body == null) {
			return;
		}
		var _loc2_ = m_body.getContactList();
		while (_loc2_ != null) {
			_loc3_ = _loc2_.contact;
			_loc4_ = _loc3_.getFixtureA();
			_loc5_ = _loc3_.getFixtureB();
			if (_loc4_ == this || _loc5_ == this) {
				_loc3_.flagForFiltering();
			}
			_loc2_ = _loc2_.next;
		}
	}

	public function SetDensity(density:Float) {
		m_density = density;
	}

	public function RayCast(output:B2RayCastOutput, input:B2RayCastInput):Bool {
		return m_shape.rayCast(output, input, m_body.getTransform());
	}

	public function IsSensor():Bool {
		return m_isSensor;
	}

	public function GetUserData():ASAny {
		return m_userData;
	}

	public function GetType():Int {
		return m_shape.getType();
	}

	public function GetShape():B2Shape {
		return m_shape;
	}

	public function GetRestitution():Float {
		return m_restitution;
	}

	public function GetNext():B2Fixture {
		return m_next;
	}

	public function GetMassData(massData:B2MassData = /*undefined*/ null):B2MassData {
		if (massData == null) {
			massData = new B2MassData();
		}
		m_shape.computeMass(massData, m_density);
		return massData;
	}

	public function GetFriction():Float {
		return m_friction;
	}

	public function GetFilterData():B2FilterData {
		return m_filter.copy();
	}

	public function GetDensity():Float {
		return m_density;
	}

	public function GetBody():B2Body {
		return m_body;
	}

	public function GetAABB():B2AABB {
		return m_aabb;
	}

	public function DestroyProxy(broadPhase:IBroadPhase) {
		if (m_proxy == null) {
			return;
		}
		broadPhase.destroyProxy(m_proxy);
		m_proxy = null;
	}

	public function Destroy() {
		m_shape = null;
	}

	public function CreateProxy(broadPhase:IBroadPhase, xf:B2Transform) {
		m_shape.computeAABB(m_aabb, xf);
		m_proxy = broadPhase.createProxy(m_aabb, this);
	}

	public function Create(body:B2Body, xf:B2Transform, def:B2FixtureDef) {
		m_userData = def.userData;
		m_friction = def.friction;
		m_restitution = def.restitution;
		m_body = body;
		m_next = null;
		m_filter = def.filter.copy();
		m_isSensor = def.isSensor;
		m_shape = def.shape.copy();
		m_density = def.density;
	}
}
