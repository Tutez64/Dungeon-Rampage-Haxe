package box2D.dynamics.contacts;

import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.B2Manifold;
import box2D.common.math.B2Transform;
import box2D.common.B2Settings;
import box2D.dynamics.B2Fixture;
import flash.Boot;

class B2PolyAndEdgeContact extends B2Contact {
	public function new() {
		if (!Boot.skip_constructor) {
			super();
		}
	}

	public static function create(allocator:ASAny):B2Contact {
		return new B2PolyAndEdgeContact();
	}

	public static function destroy(contact:B2Contact, allocator:ASAny) {}

	public static function Create(allocator:ASAny):B2Contact {
		return B2PolyAndEdgeContact.create(allocator);
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {
		B2PolyAndEdgeContact.destroy(contact, allocator);
	}

	override public function reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		Reset(fixtureA, fixtureB);
	}

	override public function evaluate() {
		Evaluate();
	}

	public function b2CollidePolyAndEdge(manifold:B2Manifold, polygon:B2PolygonShape, xf1:B2Transform, edge:B2EdgeShape, xf2:B2Transform) {}

	override public function Reset(fixtureA:B2Fixture = /*undefined*/ null, fixtureB:B2Fixture = /*undefined*/ null) {
		super.Reset(fixtureA, fixtureB);
		B2Settings.b2Assert(fixtureA == null || fixtureA.getType() == 2);
		B2Settings.b2Assert(fixtureB == null || fixtureB.getType() == 3);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.getBody();
		var _loc2_ = m_fixtureB.getBody();
		b2CollidePolyAndEdge(m_manifold, cast(m_fixtureA.getShape(), B2PolygonShape), _loc1_.m_xf, cast(m_fixtureB.getShape(), B2EdgeShape), _loc2_.m_xf);
	}
}
