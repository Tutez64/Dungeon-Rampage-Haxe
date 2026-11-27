package box2D.dynamics.contacts;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.B2Collision;
import box2D.dynamics.B2Fixture;

class B2CircleContact extends B2Contact {
	public function new() {
		super();
	}

	public static function create(allocator:ASAny):B2Contact {
		return new B2CircleContact();
	}

	public static function destroy(contact:B2Contact, allocator:ASAny) {}

	public static function Create(allocator:ASAny):B2Contact {
		return B2CircleContact.create(allocator);
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {
		B2CircleContact.destroy(contact, allocator);
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
		B2Collision.collideCircles(m_manifold, cast(m_fixtureA.getShape(), B2CircleShape), _loc1_.m_xf, cast(m_fixtureB.getShape(), B2CircleShape),
			_loc2_.m_xf);
	}
}
