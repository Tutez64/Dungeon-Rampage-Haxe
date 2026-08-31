package box2D.dynamics;

/*use*/ /*namespace*/ /*b2internal*/ class B2ContactFilter {
	/*b2internal*/
	public static var b2_defaultFilter:B2ContactFilter = new B2ContactFilter();

	public function new() {}

	public function ShouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
		var _loc3_ = fixtureA.GetFilterData();
		var _loc4_ = fixtureB.GetFilterData();
		if (_loc3_.groupIndex == _loc4_.groupIndex && _loc3_.groupIndex != 0) {
			return _loc3_.groupIndex > 0;
		}
		return ((_loc3_.maskBits : Int) & (_loc4_.categoryBits : Int)) != 0
			&& ((_loc3_.categoryBits : Int) & (_loc4_.maskBits : Int)) != 0;
	}

	public function RayCollide(userData:ASAny, fixture:B2Fixture):Bool {
		if (!ASCompat.toBool(userData)) {
			return true;
		}
		return this.ShouldCollide(ASCompat.dynamicAs(userData, B2Fixture), fixture);
	}
}
