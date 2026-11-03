package box2D.dynamics.contacts;

import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.B2Collision;
import box2D.dynamics.B2Fixture;
import flash.Boot;

class B2PolygonContact extends B2Contact {
	public function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}

	public static function create(allocator:ASAny):B2Contact {
		return new B2PolygonContact();
	}

	public static function destroy(contact:B2Contact, allocator:ASAny) {}

	public static function Create(allocator:ASAny):B2Contact {
		return B2PolygonContact.create(allocator);
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {
		B2PolygonContact.destroy(contact, allocator);
	}

	override public function reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		Reset(fixtureA, fixtureB);
	}

	override public function evaluate() {
		Evaluate();
	}

	override public function Reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		super.Reset(fixtureA, fixtureB);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.getBody();
		var _loc2_ = m_fixtureB.getBody();
		B2Collision.collidePolygons(m_manifold, cast(m_fixtureA.getShape(), B2PolygonShape), _loc1_.m_xf, cast(m_fixtureB.getShape(), B2PolygonShape),
			_loc2_.m_xf);
	}
}
