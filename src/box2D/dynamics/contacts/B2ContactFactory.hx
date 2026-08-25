package box2D.dynamics.contacts;

import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.*;

/*use*/ /*namespace*/ /*b2internal*/ class B2ContactFactory {
	var m_registers:Vector<Vector<B2ContactRegister>>;

	var m_allocator:ASAny;

	public function new(allocator:ASAny) {
		this.m_allocator = allocator;
		this.InitializeRegisters();
	}

	/*b2internal*/
	public function AddType(createFcn:ASFunction, destroyFcn:ASFunction, type1:Int, type2:Int) {
		this.m_registers[type1][type2].createFcn = createFcn;
		this.m_registers[type1][type2].destroyFcn = destroyFcn;
		this.m_registers[type1][type2].primary = true;
		if (type1 != type2) {
			this.m_registers[type2][type1].createFcn = createFcn;
			this.m_registers[type2][type1].destroyFcn = destroyFcn;
			this.m_registers[type2][type1].primary = false;
		}
	}

	/*b2internal*/
	public function InitializeRegisters() {
		var _loc2_ = 0;
		this.m_registers = new Vector<Vector<B2ContactRegister>>((B2Shape.e_shapeTypeCount : UInt));
		var _loc1_ = 0;
		while (_loc1_ < B2Shape.e_shapeTypeCount) {
			this.m_registers[_loc1_] = new Vector<B2ContactRegister>((B2Shape.e_shapeTypeCount : UInt));
			_loc2_ = 0;
			while (_loc2_ < B2Shape.e_shapeTypeCount) {
				this.m_registers[_loc1_][_loc2_] = new B2ContactRegister();
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
			_loc1_ = ASCompat.toInt(_loc1_) + 1;
		}
		this.AddType(B2CircleContact.Create, B2CircleContact.Destroy, B2Shape.e_circleShape, B2Shape.e_circleShape);
		this.AddType(B2PolyAndCircleContact.Create, B2PolyAndCircleContact.Destroy, B2Shape.e_polygonShape, B2Shape.e_circleShape);
		this.AddType(B2PolygonContact.Create, B2PolygonContact.Destroy, B2Shape.e_polygonShape, B2Shape.e_polygonShape);
		this.AddType(B2EdgeAndCircleContact.Create, B2EdgeAndCircleContact.Destroy, B2Shape.e_edgeShape, B2Shape.e_circleShape);
		this.AddType(B2PolyAndEdgeContact.Create, B2PolyAndEdgeContact.Destroy, B2Shape.e_polygonShape, B2Shape.e_edgeShape);
	}

	public function Create(fixtureA:B2Fixture, fixtureB:B2Fixture):B2Contact {
		var _loc6_:B2Contact = null;
		var _loc3_ = fixtureA.GetType();
		var _loc4_ = fixtureB.GetType();
		var _loc5_ = this.m_registers[_loc3_][_loc4_];
		if (_loc5_.pool != null) {
			_loc6_ = _loc5_.pool;
			_loc5_.pool = _loc6_.m_next;
			--_loc5_.poolCount;
			_loc6_.Reset(fixtureA, fixtureB);
			return _loc6_;
		}
		var _loc7_ = _loc5_.createFcn;
		if (_loc7_ != null) {
			if (_loc5_.primary) {
				_loc6_ = ASCompat.dynamicAs(_loc7_(this.m_allocator), box2D.dynamics.contacts.B2Contact);
				_loc6_.Reset(fixtureA, fixtureB);
				return _loc6_;
			}
			_loc6_ = ASCompat.dynamicAs(_loc7_(this.m_allocator), box2D.dynamics.contacts.B2Contact);
			_loc6_.Reset(fixtureB, fixtureA);
			return _loc6_;
		}
		return null;
	}

	public function Destroy(contact:B2Contact) {
		if (contact.m_manifold.m_pointCount > 0) {
			contact.m_fixtureA.m_body.SetAwake(true);
			contact.m_fixtureB.m_body.SetAwake(true);
		}
		var _loc2_ = contact.m_fixtureA.GetType();
		var _loc3_ = contact.m_fixtureB.GetType();
		var _loc4_ = this.m_registers[_loc2_][_loc3_];
		++_loc4_.poolCount;
		contact.m_next = _loc4_.pool;
		_loc4_.pool = contact;
		var _loc5_ = _loc4_.destroyFcn;
		_loc5_(contact, this.m_allocator);
	}
}
