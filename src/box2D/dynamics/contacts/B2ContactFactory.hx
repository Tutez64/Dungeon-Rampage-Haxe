package box2D.dynamics.contacts;

import box2D.dynamics.B2Fixture;

class B2ContactFactory {
	public var m_registers:Array<ASAny>;

	public var m_allocator:ASAny;

	public function new(allocator:ASAny = /*undefined*/ null) {
		m_allocator = allocator;
		initializeRegisters();
	}

	public function initializeRegisters() {
		InitializeRegisters();
	}

	public function destroy(contact:B2Contact) {
		Destroy(contact);
	}

	public function create(fixtureA:B2Fixture, fixtureB:B2Fixture):B2Contact {
		return Create(fixtureA, fixtureB);
	}

	public function addType(createFcn:ASAny, destroyFcn:ASAny, type1:Int, type2:Int) {
		AddType(createFcn, destroyFcn, type1, type2);
	}

	public function InitializeRegisters() {
		m_registers = [];
		m_registers[0] = [];
		m_registers[0][0] = new B2ContactRegister();
		m_registers[0][1] = new B2ContactRegister();
		m_registers[0][2] = new B2ContactRegister();
		m_registers[0][3] = new B2ContactRegister();
		m_registers[1] = [];
		m_registers[1][0] = new B2ContactRegister();
		m_registers[1][1] = new B2ContactRegister();
		m_registers[1][2] = new B2ContactRegister();
		m_registers[1][3] = new B2ContactRegister();
		m_registers[2] = [];
		m_registers[2][0] = new B2ContactRegister();
		m_registers[2][1] = new B2ContactRegister();
		m_registers[2][2] = new B2ContactRegister();
		m_registers[2][3] = new B2ContactRegister();
		m_registers[3] = [];
		m_registers[3][0] = new B2ContactRegister();
		m_registers[3][1] = new B2ContactRegister();
		m_registers[3][2] = new B2ContactRegister();
		m_registers[3][3] = new B2ContactRegister();
		addType(B2CircleContact.create, B2CircleContact.destroy, 1, 1);
		addType(B2PolyAndCircleContact.create, B2PolyAndCircleContact.destroy, 2, 1);
		addType(B2PolygonContact.create, B2PolygonContact.destroy, 2, 2);
		addType(B2EdgeAndCircleContact.create, B2EdgeAndCircleContact.destroy, 3, 1);
		addType(B2PolyAndEdgeContact.create, B2PolyAndEdgeContact.destroy, 2, 3);
	}

	public function Destroy(contact:B2Contact) {
		if (contact.m_manifold.m_pointCount > 0) {
			contact.m_fixtureA.m_body.setAwake(true);
			contact.m_fixtureB.m_body.setAwake(true);
		}
		var _loc2_ = contact.m_fixtureA.getType();
		var _loc3_ = contact.m_fixtureB.getType();
		var _loc4_ = ASCompat.coerce(ASCompat.dynGetIndex(m_registers[_loc2_], _loc3_), box2D.dynamics.contacts.B2ContactRegister);
		++_loc4_.poolCount;
		contact.m_next = _loc4_.pool;
		_loc4_.pool = contact;
		contact.reset();
		var _loc5_:ASAny = _loc4_.destroyFcn;
		_loc5_(contact, m_allocator);
	}

	public function Create(fixtureA:B2Fixture, fixtureB:B2Fixture):B2Contact {
		var _loc6_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2Contact);
		var _loc3_ = fixtureA.getType();
		var _loc4_ = fixtureB.getType();
		var _loc5_ = ASCompat.coerce(ASCompat.dynGetIndex(m_registers[_loc3_], _loc4_), box2D.dynamics.contacts.B2ContactRegister);
		if (!_loc5_.primary) {
			_loc5_ = ASCompat.coerce(ASCompat.dynGetIndex(m_registers[_loc4_], _loc3_), box2D.dynamics.contacts.B2ContactRegister);
			_loc6_ = fixtureB;
			fixtureB = fixtureA;
			fixtureA = _loc6_;
		}
		if (_loc5_.pool != null) {
			_loc7_ = _loc5_.pool;
			_loc5_.pool = ASCompat.coerce(_loc7_.m_next, box2D.dynamics.contacts.B2Contact);
			--_loc5_.poolCount;
			_loc7_.reset(fixtureA, fixtureB);
			return ASCompat.coerce(_loc7_, box2D.dynamics.contacts.B2Contact);
		}
		var _loc8_:ASAny = _loc5_.createFcn;
		if (_loc8_ != null) {
			_loc7_ = _loc8_(m_allocator);
			_loc7_.reset(fixtureA, fixtureB);
			return ASCompat.coerce(_loc7_, box2D.dynamics.contacts.B2Contact);
		}
		return null;
	}

	public function AddType(createFcn:ASAny, destroyFcn:ASAny, type1:Int, type2:Int) {
		ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type1], type2), "createFcn", createFcn);
		ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type1], type2), "destroyFcn", destroyFcn);
		ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type1], type2), "primary", true);
		if (type1 != type2) {
			ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type2], type1), "createFcn", createFcn);
			ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type2], type1), "destroyFcn", destroyFcn);
			ASCompat.setProperty(ASCompat.dynGetIndex(m_registers[type2], type1), "primary", false);
		}
	}
}
