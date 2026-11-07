package box2D.dynamics;

class B2ContactFilter {
	public static var b2_defaultFilter:B2ContactFilter = new B2ContactFilter();

	public function new() {}

	public function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
		return ShouldCollide(fixtureA, fixtureB);
	}

	public function rayCollide(userData:ASAny, fixture:B2Fixture):Bool {
		return RayCollide(userData, fixture);
	}

	public function ShouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
		var _loc3_ = fixtureA.getFilterData();
		var _loc4_ = fixtureB.getFilterData();
		if (_loc3_.groupIndex == _loc4_.groupIndex && _loc3_.groupIndex != 0) {
			return _loc3_.groupIndex > 0;
		}
		return (_loc3_.maskBits & _loc4_.categoryBits) != 0 && (_loc3_.categoryBits & _loc4_.maskBits) != 0;
	}

	public function RayCollide(userData:ASAny, fixture:B2Fixture):Bool {
		if (userData == null) {
			return true;
		}
		return shouldCollide(ASCompat.coerce(userData, box2D.dynamics.B2Fixture), fixture);
	}
}
