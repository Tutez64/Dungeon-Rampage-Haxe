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

/*use*/ /*namespace*/ /*b2internal*/ class B2Body {
	static var s_xf1:B2Transform = new B2Transform();

	/*b2internal*/
	public static var e_islandFlag:UInt = (1 : UInt);

	/*b2internal*/
	public static var e_awakeFlag:UInt = (2 : UInt);

	/*b2internal*/
	public static var e_allowSleepFlag:UInt = (4 : UInt);

	/*b2internal*/
	public static var e_bulletFlag:UInt = (8 : UInt);

	/*b2internal*/
	public static var e_fixedRotationFlag:UInt = (16 : UInt);

	/*b2internal*/
	public static var e_activeFlag:UInt = (32 : UInt);

	public static var b2_staticBody:UInt = (0 : UInt);

	public static var b2_kinematicBody:UInt = (1 : UInt);

	public static var b2_dynamicBody:UInt = (2 : UInt);

	/*b2internal*/
	public var m_flags:UInt = 0;

	/*b2internal*/
	public var m_type:Int = 0;

	/*b2internal*/
	public var m_islandIndex:Int = 0;

	/*b2internal*/
	public var m_xf:B2Transform = new B2Transform();

	/*b2internal*/
	public var m_sweep:B2Sweep = new B2Sweep();

	/*b2internal*/
	public var m_linearVelocity:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_angularVelocity:Float = Math.NaN;

	/*b2internal*/
	public var m_force:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_torque:Float = Math.NaN;

	/*b2internal*/
	public var m_world:B2World;

	/*b2internal*/
	public var m_prev:B2Body;

	/*b2internal*/
	public var m_next:B2Body;

	/*b2internal*/
	public var m_fixtureList:B2Fixture;

	/*b2internal*/
	public var m_fixtureCount:Int = 0;

	/*b2internal*/
	public var m_controllerList:B2ControllerEdge;

	/*b2internal*/
	public var m_controllerCount:Int = 0;

	/*b2internal*/
	public var m_jointList:B2JointEdge;

	/*b2internal*/
	public var m_contactList:B2ContactEdge;

	/*b2internal*/
	public var m_mass:Float = Math.NaN;

	/*b2internal*/
	public var m_invMass:Float = Math.NaN;

	/*b2internal*/
	public var m_I:Float = Math.NaN;

	/*b2internal*/
	public var m_invI:Float = Math.NaN;

	/*b2internal*/
	public var m_inertiaScale:Float = Math.NaN;

	/*b2internal*/
	public var m_linearDamping:Float = Math.NaN;

	/*b2internal*/
	public var m_angularDamping:Float = Math.NaN;

	/*b2internal*/
	public var m_sleepTime:Float = Math.NaN;

	var m_userData:ASAny;

	public function new(bd:B2BodyDef, world:B2World) {
		this.m_flags = (0 : UInt);
		if (bd.bullet) {
			this.m_flags = ((this.m_flags | /*b2internal::*/ e_bulletFlag:UInt) : UInt);
		}
		if (bd.fixedRotation) {
			this.m_flags = ((this.m_flags | /*b2internal::*/ e_fixedRotationFlag:UInt) : UInt);
		}
		if (bd.allowSleep) {
			this.m_flags = ((this.m_flags | /*b2internal::*/ e_allowSleepFlag:UInt) : UInt);
		}
		if (bd.awake) {
			this.m_flags = ((this.m_flags | /*b2internal::*/ e_awakeFlag:UInt) : UInt);
		}
		if (bd.active) {
			this.m_flags = ((this.m_flags | /*b2internal::*/ e_activeFlag:UInt) : UInt);
		}
		this.m_world = world;
		this.m_xf.position.SetV(bd.position);
		this.m_xf.R.Set(bd.angle);
		this.m_sweep.localCenter.SetZero();
		this.m_sweep.t0 = 1;
		this.m_sweep.a0 = this.m_sweep.a = bd.angle;
		var _loc3_ = this.m_xf.R;
		var _loc4_ = this.m_sweep.localCenter;
		this.m_sweep.c.x = _loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y;
		this.m_sweep.c.y = _loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y;
		this.m_sweep.c.x += this.m_xf.position.x;
		this.m_sweep.c.y += this.m_xf.position.y;
		this.m_sweep.c0.SetV(this.m_sweep.c);
		this.m_jointList = null;
		this.m_controllerList = null;
		this.m_contactList = null;
		this.m_controllerCount = 0;
		this.m_prev = null;
		this.m_next = null;
		this.m_linearVelocity.SetV(bd.linearVelocity);
		this.m_angularVelocity = bd.angularVelocity;
		this.m_linearDamping = bd.linearDamping;
		this.m_angularDamping = bd.angularDamping;
		this.m_force.Set(0, 0);
		this.m_torque = 0;
		this.m_sleepTime = 0;
		this.m_type = (bd.type : Int);
		if ((this.m_type : UInt) == b2_dynamicBody) {
			this.m_mass = 1;
			this.m_invMass = 1;
		} else {
			this.m_mass = 0;
			this.m_invMass = 0;
		}
		this.m_I = 0;
		this.m_invI = 0;
		this.m_inertiaScale = bd.inertiaScale;
		this.m_userData = bd.userData;
		this.m_fixtureList = null;
		this.m_fixtureCount = 0;
	}

	function connectEdges(s1:B2EdgeShape, s2:B2EdgeShape, angle1:Float):Float {
		var _loc4_ = Math.atan2(s2.GetDirectionVector().y, s2.GetDirectionVector().x);
		var _loc5_ = Math.tan((_loc4_ - angle1) * 0.5);
		var _loc6_ = B2Math.MulFV(_loc5_, s2.GetDirectionVector());
		_loc6_ = B2Math.SubtractVV(_loc6_, s2.GetNormalVector());
		_loc6_ = B2Math.MulFV(B2Settings.b2_toiSlop, _loc6_);
		_loc6_ = B2Math.AddVV(_loc6_, s2.GetVertex1());
		var _loc7_ = B2Math.AddVV(s1.GetDirectionVector(), s2.GetDirectionVector());
		_loc7_.Normalize();
		var _loc8_ = B2Math.Dot(s1.GetDirectionVector(), s2.GetNormalVector()) > 0;
		s1.SetNextEdge(s2, _loc6_, _loc7_, _loc8_);
		s2.SetPrevEdge(s1, _loc6_, _loc7_, _loc8_);
		return _loc4_;
	}

	public function CreateFixture(def:B2FixtureDef):B2Fixture {
		var _loc3_:IBroadPhase = null;
		if (this.m_world.IsLocked() == true) {
			return null;
		}
		var _loc2_ = new B2Fixture();
		_loc2_.Create(this, this.m_xf, def);
		if (((this.m_flags : Int) & (e_activeFlag : Int)) != 0) {
			_loc3_ = this.m_world.m_contactManager.m_broadPhase;
			_loc2_.CreateProxy(_loc3_, this.m_xf);
		}
		_loc2_.m_next = this.m_fixtureList;
		this.m_fixtureList = _loc2_;
		++this.m_fixtureCount;
		_loc2_.m_body = this;
		if (_loc2_.m_density > 0) {
			this.ResetMassData();
		}
		this.m_world.m_flags = this.m_world.m_flags | B2World.e_newFixture;
		return _loc2_;
	}

	public function CreateFixture2(shape:B2Shape, density:Float = 0):B2Fixture {
		var _loc3_ = new B2FixtureDef();
		_loc3_.shape = shape;
		_loc3_.density = density;
		return this.CreateFixture(_loc3_);
	}

	public function DestroyFixture(fixture:B2Fixture) {
		var _loc6_:B2Contact = null;
		var _loc7_:B2Fixture = null;
		var _loc8_:B2Fixture = null;
		var _loc9_:IBroadPhase = null;
		if (this.m_world.IsLocked() == true) {
			return;
		}
		var _loc2_ = this.m_fixtureList;
		var _loc3_:B2Fixture = null;
		var _loc4_ = false;
		while (_loc2_ != null) {
			if (_loc2_ == fixture) {
				if (_loc3_ != null) {
					_loc3_.m_next = fixture.m_next;
				} else {
					this.m_fixtureList = fixture.m_next;
				}
				_loc4_ = true;
				break;
			}
			_loc3_ = _loc2_;
			_loc2_ = _loc2_.m_next;
		}
		var _loc5_ = this.m_contactList;
		while (_loc5_ != null) {
			_loc6_ = _loc5_.contact;
			_loc5_ = _loc5_.next;
			_loc7_ = _loc6_.GetFixtureA();
			_loc8_ = _loc6_.GetFixtureB();
			if (fixture == _loc7_ || fixture == _loc8_) {
				this.m_world.m_contactManager.Destroy(_loc6_);
			}
		}
		if (((this.m_flags : Int) & (e_activeFlag : Int)) != 0) {
			_loc9_ = this.m_world.m_contactManager.m_broadPhase;
			fixture.DestroyProxy(_loc9_);
		}
		fixture.Destroy();
		fixture.m_body = null;
		fixture.m_next = null;
		--this.m_fixtureCount;
		this.ResetMassData();
	}

	public function SetPositionAndAngle(position:B2Vec2, angle:Float) {
		var _loc3_:B2Fixture = null;
		if (this.m_world.IsLocked() == true) {
			return;
		}
		this.m_xf.R.Set(angle);
		this.m_xf.position.SetV(position);
		var _loc4_ = this.m_xf.R;
		var _loc5_ = this.m_sweep.localCenter;
		this.m_sweep.c.x = _loc4_.col1.x * _loc5_.x + _loc4_.col2.x * _loc5_.y;
		this.m_sweep.c.y = _loc4_.col1.y * _loc5_.x + _loc4_.col2.y * _loc5_.y;
		this.m_sweep.c.x += this.m_xf.position.x;
		this.m_sweep.c.y += this.m_xf.position.y;
		this.m_sweep.c0.SetV(this.m_sweep.c);
		this.m_sweep.a0 = this.m_sweep.a = angle;
		var _loc6_ = this.m_world.m_contactManager.m_broadPhase;
		_loc3_ = this.m_fixtureList;
		while (_loc3_ != null) {
			_loc3_.Synchronize(_loc6_, this.m_xf, this.m_xf);
			_loc3_ = _loc3_.m_next;
		}
		this.m_world.m_contactManager.FindNewContacts();
	}

	public function SetTransform(xf:B2Transform) {
		this.SetPositionAndAngle(xf.position, xf.GetAngle());
	}

	public function GetTransform():B2Transform {
		return this.m_xf;
	}

	public function GetPosition():B2Vec2 {
		return this.m_xf.position;
	}

	public function SetPosition(position:B2Vec2) {
		this.SetPositionAndAngle(position, this.GetAngle());
	}

	public function GetAngle():Float {
		return this.m_sweep.a;
	}

	public function SetAngle(angle:Float) {
		this.SetPositionAndAngle(this.GetPosition(), angle);
	}

	public function GetWorldCenter():B2Vec2 {
		return this.m_sweep.c;
	}

	public function GetLocalCenter():B2Vec2 {
		return this.m_sweep.localCenter;
	}

	public function SetLinearVelocity(v:B2Vec2) {
		if ((this.m_type : UInt) == b2_staticBody) {
			return;
		}
		this.m_linearVelocity.SetV(v);
	}

	public function GetLinearVelocity():B2Vec2 {
		return this.m_linearVelocity;
	}

	public function SetAngularVelocity(omega:Float) {
		if ((this.m_type : UInt) == b2_staticBody) {
			return;
		}
		this.m_angularVelocity = omega;
	}

	public function GetAngularVelocity():Float {
		return this.m_angularVelocity;
	}

	public function GetDefinition():B2BodyDef {
		var _loc1_ = new B2BodyDef();
		_loc1_.type = this.GetType();
		_loc1_.allowSleep = (((this.m_flags : Int) & (e_allowSleepFlag : Int)) : UInt) == e_allowSleepFlag;
		_loc1_.angle = this.GetAngle();
		_loc1_.angularDamping = this.m_angularDamping;
		_loc1_.angularVelocity = this.m_angularVelocity;
		_loc1_.fixedRotation = (((this.m_flags : Int) & (e_fixedRotationFlag : Int)) : UInt) == e_fixedRotationFlag;
		_loc1_.bullet = (((this.m_flags : Int) & (e_bulletFlag : Int)) : UInt) == e_bulletFlag;
		_loc1_.awake = (((this.m_flags : Int) & (e_awakeFlag : Int)) : UInt) == e_awakeFlag;
		_loc1_.linearDamping = this.m_linearDamping;
		_loc1_.linearVelocity.SetV(this.GetLinearVelocity());
		_loc1_.position = this.GetPosition();
		_loc1_.userData = this.GetUserData();
		return _loc1_;
	}

	public function ApplyForce(force:B2Vec2, point:B2Vec2) {
		if ((this.m_type : UInt) != b2_dynamicBody) {
			return;
		}
		if (this.IsAwake() == false) {
			this.SetAwake(true);
		}
		this.m_force.x += force.x;
		this.m_force.y += force.y;
		this.m_torque += (point.x - this.m_sweep.c.x) * force.y - (point.y - this.m_sweep.c.y) * force.x;
	}

	public function ApplyTorque(torque:Float) {
		if ((this.m_type : UInt) != b2_dynamicBody) {
			return;
		}
		if (this.IsAwake() == false) {
			this.SetAwake(true);
		}
		this.m_torque += torque;
	}

	public function ApplyImpulse(impulse:B2Vec2, point:B2Vec2) {
		if ((this.m_type : UInt) != b2_dynamicBody) {
			return;
		}
		if (this.IsAwake() == false) {
			this.SetAwake(true);
		}
		this.m_linearVelocity.x += this.m_invMass * impulse.x;
		this.m_linearVelocity.y += this.m_invMass * impulse.y;
		this.m_angularVelocity += this.m_invI * ((point.x - this.m_sweep.c.x) * impulse.y - (point.y - this.m_sweep.c.y) * impulse.x);
	}

	public function Split(callback:ASFunction):B2Body {
		var _loc7_:B2Fixture = null;
		var _loc13_:B2Fixture = null;
		var _loc2_ = this.GetLinearVelocity().Copy();
		var _loc3_ = this.GetAngularVelocity();
		var _loc4_ = this.GetWorldCenter();
		var _loc5_ = this;
		var _loc6_ = this.m_world.CreateBody(this.GetDefinition());
		var _loc8_ = _loc5_.m_fixtureList;
		while (_loc8_ != null) {
			if (ASCompat.toBool(callback(_loc8_))) {
				_loc13_ = _loc8_.m_next;
				if (_loc7_ != null) {
					_loc7_.m_next = _loc13_;
				} else {
					_loc5_.m_fixtureList = _loc13_;
				}
				--_loc5_.m_fixtureCount;
				_loc8_.m_next = _loc6_.m_fixtureList;
				_loc6_.m_fixtureList = _loc8_;
				++_loc6_.m_fixtureCount;
				_loc8_.m_body = _loc6_;
				_loc8_ = _loc13_;
			} else {
				_loc7_ = _loc8_;
				_loc8_ = _loc8_.m_next;
			}
		}
		_loc5_.ResetMassData();
		_loc6_.ResetMassData();
		var _loc9_ = _loc5_.GetWorldCenter();
		var _loc10_ = _loc6_.GetWorldCenter();
		var _loc11_ = B2Math.AddVV(_loc2_, B2Math.CrossFV(_loc3_, B2Math.SubtractVV(_loc9_, _loc4_)));
		var _loc12_ = B2Math.AddVV(_loc2_, B2Math.CrossFV(_loc3_, B2Math.SubtractVV(_loc10_, _loc4_)));
		_loc5_.SetLinearVelocity(_loc11_);
		_loc6_.SetLinearVelocity(_loc12_);
		_loc5_.SetAngularVelocity(_loc3_);
		_loc6_.SetAngularVelocity(_loc3_);
		_loc5_.SynchronizeFixtures();
		_loc6_.SynchronizeFixtures();
		return _loc6_;
	}

	public function Merge(other:B2Body) {
		var _loc2_:B2Fixture = null;
		var _loc3_:B2Body = null;
		var _loc4_:B2Body = null;
		var _loc11_:B2Fixture = null;
		_loc2_ = other.m_fixtureList;
		while (_loc2_ != null) {
			_loc11_ = _loc2_.m_next;
			--other.m_fixtureCount;
			_loc2_.m_next = this.m_fixtureList;
			this.m_fixtureList = _loc2_;
			++this.m_fixtureCount;
			_loc2_.m_body = _loc4_;
			_loc2_ = _loc11_;
		}
		_loc3_.m_fixtureCount = 0;
		_loc3_ = this;
		_loc4_ = other;
		var _loc5_ = _loc3_.GetWorldCenter();
		var _loc6_ = _loc4_.GetWorldCenter();
		var _loc7_ = _loc3_.GetLinearVelocity().Copy();
		var _loc8_ = _loc4_.GetLinearVelocity().Copy();
		var _loc9_ = _loc3_.GetAngularVelocity();
		var _loc10_ = _loc4_.GetAngularVelocity();
		_loc3_.ResetMassData();
		this.SynchronizeFixtures();
	}

	public function GetMass():Float {
		return this.m_mass;
	}

	public function GetInertia():Float {
		return this.m_I;
	}

	public function GetMassData(data:B2MassData) {
		data.mass = this.m_mass;
		data.I = this.m_I;
		data.center.SetV(this.m_sweep.localCenter);
	}

	public function SetMassData(massData:B2MassData) {
		B2Settings.b2Assert(this.m_world.IsLocked() == false);
		if (this.m_world.IsLocked() == true) {
			return;
		}
		if ((this.m_type : UInt) != b2_dynamicBody) {
			return;
		}
		this.m_invMass = 0;
		this.m_I = 0;
		this.m_invI = 0;
		this.m_mass = massData.mass;
		if (this.m_mass <= 0) {
			this.m_mass = 1;
		}
		this.m_invMass = 1 / this.m_mass;
		if (massData.I > 0 && ((this.m_flags : Int) & (e_fixedRotationFlag : Int)) == 0) {
			this.m_I = massData.I - this.m_mass * (massData.center.x * massData.center.x + massData.center.y * massData.center.y);
			this.m_invI = 1 / this.m_I;
		}
		var _loc2_ = this.m_sweep.c.Copy();
		this.m_sweep.localCenter.SetV(massData.center);
		this.m_sweep.c0.SetV(B2Math.MulX(this.m_xf, this.m_sweep.localCenter));
		this.m_sweep.c.SetV(this.m_sweep.c0);
		this.m_linearVelocity.x += this.m_angularVelocity * -(this.m_sweep.c.y - _loc2_.y);
		this.m_linearVelocity.y += this.m_angularVelocity * (this.m_sweep.c.x - _loc2_.x);
	}

	public function ResetMassData() {
		var _loc4_:B2MassData = null;
		this.m_mass = 0;
		this.m_invMass = 0;
		this.m_I = 0;
		this.m_invI = 0;
		this.m_sweep.localCenter.SetZero();
		if ((this.m_type : UInt) == b2_staticBody || (this.m_type : UInt) == b2_kinematicBody) {
			return;
		}
		var _loc1_ = B2Vec2.Make(0, 0);
		var _loc2_ = this.m_fixtureList;
		while (_loc2_ != null) {
			if (_loc2_.m_density != 0) {
				_loc4_ = _loc2_.GetMassData();
				this.m_mass += _loc4_.mass;
				_loc1_.x += _loc4_.center.x * _loc4_.mass;
				_loc1_.y += _loc4_.center.y * _loc4_.mass;
				this.m_I += _loc4_.I;
			}
			_loc2_ = _loc2_.m_next;
		}
		if (this.m_mass > 0) {
			this.m_invMass = 1 / this.m_mass;
			_loc1_.x *= this.m_invMass;
			_loc1_.y *= this.m_invMass;
		} else {
			this.m_mass = 1;
			this.m_invMass = 1;
		}
		if (this.m_I > 0 && ((this.m_flags : Int) & (e_fixedRotationFlag : Int)) == 0) {
			this.m_I -= this.m_mass * (_loc1_.x * _loc1_.x + _loc1_.y * _loc1_.y);
			this.m_I *= this.m_inertiaScale;
			B2Settings.b2Assert(this.m_I > 0);
			this.m_invI = 1 / this.m_I;
		} else {
			this.m_I = 0;
			this.m_invI = 0;
		}
		var _loc3_ = this.m_sweep.c.Copy();
		this.m_sweep.localCenter.SetV(_loc1_);
		this.m_sweep.c0.SetV(B2Math.MulX(this.m_xf, this.m_sweep.localCenter));
		this.m_sweep.c.SetV(this.m_sweep.c0);
		this.m_linearVelocity.x += this.m_angularVelocity * -(this.m_sweep.c.y - _loc3_.y);
		this.m_linearVelocity.y += this.m_angularVelocity * (this.m_sweep.c.x - _loc3_.x);
	}

	public function GetWorldPoint(localPoint:B2Vec2):B2Vec2 {
		var _loc2_ = this.m_xf.R;
		var _loc3_ = new B2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y, _loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
		_loc3_.x += this.m_xf.position.x;
		_loc3_.y += this.m_xf.position.y;
		return _loc3_;
	}

	public function GetWorldVector(localVector:B2Vec2):B2Vec2 {
		return B2Math.MulMV(this.m_xf.R, localVector);
	}

	public function GetLocalPoint(worldPoint:B2Vec2):B2Vec2 {
		return B2Math.MulXT(this.m_xf, worldPoint);
	}

	public function GetLocalVector(worldVector:B2Vec2):B2Vec2 {
		return B2Math.MulTMV(this.m_xf.R, worldVector);
	}

	public function GetLinearVelocityFromWorldPoint(worldPoint:B2Vec2):B2Vec2 {
		return new B2Vec2(this.m_linearVelocity.x - this.m_angularVelocity * (worldPoint.y - this.m_sweep.c.y),
			this.m_linearVelocity.y + this.m_angularVelocity * (worldPoint.x - this.m_sweep.c.x));
	}

	public function GetLinearVelocityFromLocalPoint(localPoint:B2Vec2):B2Vec2 {
		var _loc2_ = this.m_xf.R;
		var _loc3_ = new B2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y, _loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
		_loc3_.x += this.m_xf.position.x;
		_loc3_.y += this.m_xf.position.y;
		return new B2Vec2(this.m_linearVelocity.x - this.m_angularVelocity * (_loc3_.y - this.m_sweep.c.y),
			this.m_linearVelocity.y + this.m_angularVelocity * (_loc3_.x - this.m_sweep.c.x));
	}

	public function GetLinearDamping():Float {
		return this.m_linearDamping;
	}

	public function SetLinearDamping(linearDamping:Float) {
		this.m_linearDamping = linearDamping;
	}

	public function GetAngularDamping():Float {
		return this.m_angularDamping;
	}

	public function SetAngularDamping(angularDamping:Float) {
		this.m_angularDamping = angularDamping;
	}

	public function SetType(type:UInt) {
		if ((this.m_type : UInt) == type) {
			return;
		}
		this.m_type = (type : Int);
		this.ResetMassData();
		if ((this.m_type : UInt) == b2_staticBody) {
			this.m_linearVelocity.SetZero();
			this.m_angularVelocity = 0;
		}
		this.SetAwake(true);
		this.m_force.SetZero();
		this.m_torque = 0;
		var _loc2_ = this.m_contactList;
		while (_loc2_ != null) {
			_loc2_.contact.FlagForFiltering();
			_loc2_ = _loc2_.next;
		}
	}

	public function GetType():UInt {
		return (this.m_type : UInt);
	}

	public function SetBullet(flag:Bool) {
		if (flag) {
			this.m_flags = ((this.m_flags | e_bulletFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_bulletFlag : Int) : UInt):UInt) : UInt);
		}
	}

	public function IsBullet():Bool {
		return (((this.m_flags : Int) & (e_bulletFlag : Int)) : UInt) == e_bulletFlag;
	}

	public function SetSleepingAllowed(flag:Bool) {
		if (flag) {
			this.m_flags = ((this.m_flags | e_allowSleepFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_allowSleepFlag : Int) : UInt):UInt) : UInt);
			this.SetAwake(true);
		}
	}

	public function SetAwake(flag:Bool) {
		if (flag) {
			this.m_flags = ((this.m_flags | e_awakeFlag:UInt) : UInt);
			this.m_sleepTime = 0;
		} else {
			this.m_flags = ((this.m_flags & (~(e_awakeFlag : Int) : UInt):UInt) : UInt);
			this.m_sleepTime = 0;
			this.m_linearVelocity.SetZero();
			this.m_angularVelocity = 0;
			this.m_force.SetZero();
			this.m_torque = 0;
		}
	}

	public function IsAwake():Bool {
		return (((this.m_flags : Int) & (e_awakeFlag : Int)) : UInt) == e_awakeFlag;
	}

	public function SetFixedRotation(fixed:Bool) {
		if (fixed) {
			this.m_flags = ((this.m_flags | e_fixedRotationFlag:UInt) : UInt);
		} else {
			this.m_flags = ((this.m_flags & (~(e_fixedRotationFlag : Int) : UInt):UInt) : UInt);
		}
		this.ResetMassData();
	}

	public function IsFixedRotation():Bool {
		return (((this.m_flags : Int) & (e_fixedRotationFlag : Int)) : UInt) == e_fixedRotationFlag;
	}

	public function SetActive(flag:Bool) {
		var _loc2_:IBroadPhase = null;
		var _loc3_:B2Fixture = null;
		var _loc4_:B2ContactEdge = null;
		var _loc5_:B2ContactEdge = null;
		if (flag == this.IsActive()) {
			return;
		}
		if (flag) {
			this.m_flags = ((this.m_flags | e_activeFlag:UInt) : UInt);
			_loc2_ = this.m_world.m_contactManager.m_broadPhase;
			_loc3_ = this.m_fixtureList;
			while (_loc3_ != null) {
				_loc3_.CreateProxy(_loc2_, this.m_xf);
				_loc3_ = _loc3_.m_next;
			}
		} else {
			this.m_flags = ((this.m_flags & (~(e_activeFlag : Int) : UInt):UInt) : UInt);
			_loc2_ = this.m_world.m_contactManager.m_broadPhase;
			_loc3_ = this.m_fixtureList;
			while (_loc3_ != null) {
				_loc3_.DestroyProxy(_loc2_);
				_loc3_ = _loc3_.m_next;
			}
			_loc4_ = this.m_contactList;
			while (_loc4_ != null) {
				_loc5_ = _loc4_;
				_loc4_ = _loc4_.next;
				this.m_world.m_contactManager.Destroy(_loc5_.contact);
			}
			this.m_contactList = null;
		}
	}

	public function IsActive():Bool {
		return (((this.m_flags : Int) & (e_activeFlag : Int)) : UInt) == e_activeFlag;
	}

	public function IsSleepingAllowed():Bool {
		return (((this.m_flags : Int) & (e_allowSleepFlag : Int)) : UInt) == e_allowSleepFlag;
	}

	public function GetFixtureList():B2Fixture {
		return this.m_fixtureList;
	}

	public function GetJointList():B2JointEdge {
		return this.m_jointList;
	}

	public function GetControllerList():B2ControllerEdge {
		return this.m_controllerList;
	}

	public function GetContactList():B2ContactEdge {
		return this.m_contactList;
	}

	public function GetNext():B2Body {
		return this.m_next;
	}

	public function GetUserData():ASAny {
		return this.m_userData;
	}

	public function SetUserData(data:ASAny) {
		this.m_userData = data;
	}

	public function GetWorld():B2World {
		return this.m_world;
	}

	/*b2internal*/
	public function SynchronizeFixtures() {
		var _loc4_:B2Fixture = null;
		var _loc1_ = s_xf1;
		_loc1_.R.Set(this.m_sweep.a0);
		var _loc2_ = _loc1_.R;
		var _loc3_ = this.m_sweep.localCenter;
		_loc1_.position.x = this.m_sweep.c0.x - (_loc2_.col1.x * _loc3_.x + _loc2_.col2.x * _loc3_.y);
		_loc1_.position.y = this.m_sweep.c0.y - (_loc2_.col1.y * _loc3_.x + _loc2_.col2.y * _loc3_.y);
		var _loc5_ = this.m_world.m_contactManager.m_broadPhase;
		_loc4_ = this.m_fixtureList;
		while (_loc4_ != null) {
			_loc4_.Synchronize(_loc5_, _loc1_, this.m_xf);
			_loc4_ = _loc4_.m_next;
		}
	}

	/*b2internal*/
	public function SynchronizeTransform() {
		this.m_xf.R.Set(this.m_sweep.a);
		var _loc1_ = this.m_xf.R;
		var _loc2_ = this.m_sweep.localCenter;
		this.m_xf.position.x = this.m_sweep.c.x - (_loc1_.col1.x * _loc2_.x + _loc1_.col2.x * _loc2_.y);
		this.m_xf.position.y = this.m_sweep.c.y - (_loc1_.col1.y * _loc2_.x + _loc1_.col2.y * _loc2_.y);
	}

	/*b2internal*/
	public function ShouldCollide(other:B2Body):Bool {
		if ((this.m_type : UInt) != b2_dynamicBody && (other.m_type : UInt) != b2_dynamicBody) {
			return false;
		}
		var _loc2_ = this.m_jointList;
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

	/*b2internal*/
	public function Advance(t:Float) {
		this.m_sweep.Advance(t);
		this.m_sweep.c.SetV(this.m_sweep.c0);
		this.m_sweep.a = this.m_sweep.a0;
		this.SynchronizeTransform();
	}
}
