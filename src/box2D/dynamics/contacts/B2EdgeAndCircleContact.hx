package box2D.dynamics.contacts;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.B2Manifold;
import box2D.common.math.B2Transform;
import box2D.common.B2Settings;
import box2D.dynamics.B2Fixture;
import flash.Boot;

class B2EdgeAndCircleContact extends B2Contact {
	public function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}

	public static function create(allocator:ASAny):B2Contact {
		return new B2EdgeAndCircleContact();
	}

	public static function destroy(contact:B2Contact, allocator:ASAny) {}

	public static function Create(allocator:ASAny):B2Contact {
		return B2EdgeAndCircleContact.create(allocator);
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {
		B2EdgeAndCircleContact.destroy(contact, allocator);
	}

	override public function reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		Reset(fixtureA, fixtureB);
	}

	override public function evaluate() {
		Evaluate();
	}

	public function b2CollideEdgeAndCircle(manifold:B2Manifold, edge:B2EdgeShape, xf1:B2Transform, circle:B2CircleShape, xf2:B2Transform) {}

	override public function Reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		super.Reset(fixtureA, fixtureB);
		B2Settings.b2Assert(fixtureA == null || fixtureA.getType() == 3);
		B2Settings.b2Assert(fixtureB == null || fixtureA.getType() == 1);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.getBody();
		var _loc2_ = m_fixtureB.getBody();
		b2CollideEdgeAndCircle(m_manifold, cast(m_fixtureA.getShape(), B2EdgeShape), _loc1_.m_xf, cast(m_fixtureB.getShape(), B2CircleShape), _loc2_.m_xf);
	}
}
