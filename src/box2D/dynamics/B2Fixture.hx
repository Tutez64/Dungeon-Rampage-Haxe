package box2D.dynamics;

import box2D.collision.IBroadPhase;
import box2D.collision.shapes.B2MassData;
import box2D.collision.shapes.B2Shape;
import box2D.collision.B2AABB;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.contacts.B2Contact;

/*use*/ /*namespace*/ /*b2internal*/ class B2Fixture {
	var m_massData:B2MassData;

	/*b2internal*/
	public var m_aabb:B2AABB;

	/*b2internal*/
	public var m_density:Float = Math.NaN;

	/*b2internal*/
	public var m_next:B2Fixture;

	/*b2internal*/
	public var m_body:B2Body;

	/*b2internal*/
	public var m_shape:B2Shape;

	/*b2internal*/
	public var m_friction:Float = Math.NaN;

	/*b2internal*/
	public var m_restitution:Float = Math.NaN;

	/*b2internal*/
	public var m_proxy:ASAny;

	/*b2internal*/
	public var m_filter:B2FilterData = new B2FilterData();

	/*b2internal*/
	public var m_isSensor:Bool = false;

	/*b2internal*/
	public var m_userData:ASAny;

	public function new() {
		this.m_aabb = new B2AABB();
		this.m_userData = null;
		this.m_body = null;
		this.m_next = null;
		this.m_shape = null;
		this.m_density = 0;
		this.m_friction = 0;
		this.m_restitution = 0;
	}

	public function GetType():Int {
		return this.m_shape.GetType();
	}

	public function GetShape():B2Shape {
		return this.m_shape;
	}

	public function SetSensor(sensor:Bool) {
		var _loc3_:B2Contact = null;
		var _loc4_:B2Fixture = null;
		var _loc5_:B2Fixture = null;
		if (this.m_isSensor == sensor) {
			return;
		}
		this.m_isSensor = sensor;
		if (this.m_body == null) {
			return;
		}
		var _loc2_ = this.m_body.GetContactList();
		while (_loc2_ != null) {
			_loc3_ = _loc2_.contact;
			_loc4_ = _loc3_.GetFixtureA();
			_loc5_ = _loc3_.GetFixtureB();
			if (_loc4_ == this || _loc5_ == this) {
				_loc3_.SetSensor(_loc4_.IsSensor() || _loc5_.IsSensor());
			}
			_loc2_ = _loc2_.next;
		}
	}

	public function IsSensor():Bool {
		return this.m_isSensor;
	}

	public function SetFilterData(filter:B2FilterData) {
		var _loc3_:B2Contact = null;
		var _loc4_:B2Fixture = null;
		var _loc5_:B2Fixture = null;
		this.m_filter = filter.Copy();
		if (this.m_body != null) {
			return;
		}
		var _loc2_ = this.m_body.GetContactList();
		while (_loc2_ != null) {
			_loc3_ = _loc2_.contact;
			_loc4_ = _loc3_.GetFixtureA();
			_loc5_ = _loc3_.GetFixtureB();
			if (_loc4_ == this || _loc5_ == this) {
				_loc3_.FlagForFiltering();
			}
			_loc2_ = _loc2_.next;
		}
	}

	public function GetFilterData():B2FilterData {
		return this.m_filter.Copy();
	}

	public function GetBody():B2Body {
		return this.m_body;
	}

	public function GetNext():B2Fixture {
		return this.m_next;
	}

	public function GetUserData():ASAny {
		return this.m_userData;
	}

	public function SetUserData(data:ASAny) {
		this.m_userData = data;
	}

	public function TestPoint(p:B2Vec2):Bool {
		return this.m_shape.TestPoint(this.m_body.GetTransform(), p);
	}

	public function RayCast(output:B2RayCastOutput, input:B2RayCastInput):Bool {
		return this.m_shape.RayCast(output, input, this.m_body.GetTransform());
	}

	public function GetMassData(massData:B2MassData = null):B2MassData {
		if (massData == null) {
			massData = new B2MassData();
		}
		this.m_shape.ComputeMass(massData, this.m_density);
		return massData;
	}

	public function SetDensity(density:Float) {
		this.m_density = density;
	}

	public function GetDensity():Float {
		return this.m_density;
	}

	public function GetFriction():Float {
		return this.m_friction;
	}

	public function SetFriction(friction:Float) {
		this.m_friction = friction;
	}

	public function GetRestitution():Float {
		return this.m_restitution;
	}

	public function SetRestitution(restitution:Float) {
		this.m_restitution = restitution;
	}

	public function GetAABB():B2AABB {
		return this.m_aabb;
	}

	/*b2internal*/
	public function Create(body:B2Body, xf:B2Transform, def:B2FixtureDef) {
		this.m_userData = def.userData;
		this.m_friction = def.friction;
		this.m_restitution = def.restitution;
		this.m_body = body;
		this.m_next = null;
		this.m_filter = def.filter.Copy();
		this.m_isSensor = def.isSensor;
		this.m_shape = def.shape.Copy();
		this.m_density = def.density;
	}

	/*b2internal*/
	public function Destroy() {
		this.m_shape = null;
	}

	/*b2internal*/
	public function CreateProxy(broadPhase:IBroadPhase, xf:B2Transform) {
		this.m_shape.ComputeAABB(this.m_aabb, xf);
		this.m_proxy = broadPhase.CreateProxy(this.m_aabb, this);
	}

	/*b2internal*/
	public function DestroyProxy(broadPhase:IBroadPhase) {
		if (this.m_proxy == null) {
			return;
		}
		broadPhase.DestroyProxy(this.m_proxy);
		this.m_proxy = null;
	}

	/*b2internal*/
	public function Synchronize(broadPhase:IBroadPhase, transform1:B2Transform, transform2:B2Transform) {
		if (!ASCompat.toBool(this.m_proxy)) {
			return;
		}
		var _loc4_ = new B2AABB();
		var _loc5_ = new B2AABB();
		this.m_shape.ComputeAABB(_loc4_, transform1);
		this.m_shape.ComputeAABB(_loc5_, transform2);
		this.m_aabb._Combine(_loc4_, _loc5_);
		var _loc6_ = B2Math.SubtractVV(transform2.position, transform1.position);
		broadPhase.MoveProxy(this.m_proxy, this.m_aabb, _loc6_);
	}
}
