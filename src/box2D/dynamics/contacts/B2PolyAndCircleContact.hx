package box2D.dynamics.contacts;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.B2Collision;
import box2D.common.B2Settings;
import box2D.dynamics.B2Fixture;
import flash.Boot;

class B2PolyAndCircleContact extends B2Contact {
	public function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}

	public static function create(allocator:ASAny):B2Contact {
		return new B2PolyAndCircleContact();
	}

	public static function destroy(contact:B2Contact, allocator:ASAny) {}

	public static function Create(allocator:ASAny):B2Contact {
		return B2PolyAndCircleContact.create(allocator);
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {
		B2PolyAndCircleContact.destroy(contact, allocator);
	}

	override public function reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		Reset(fixtureA, fixtureB);
	}

	override public function evaluate() {
		Evaluate();
	}

	override public function Reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		super.Reset(fixtureA, fixtureB);
		B2Settings.b2Assert(fixtureA == null || fixtureA.getType() == 2);
		B2Settings.b2Assert(fixtureB == null || fixtureB.getType() == 1);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.m_body;
		var _loc2_ = m_fixtureB.m_body;
		B2Collision.collidePolygonAndCircle(m_manifold, cast(m_fixtureA.getShape(), B2PolygonShape), _loc1_.m_xf, cast(m_fixtureB.getShape(), B2CircleShape),
			_loc2_.m_xf);
	}
}
