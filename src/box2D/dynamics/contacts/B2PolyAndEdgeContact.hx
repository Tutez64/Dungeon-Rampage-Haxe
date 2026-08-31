package box2D.dynamics.contacts;

import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.collision.B2Manifold;
import box2D.common.math.B2Transform;
import box2D.common.B2Settings;
import box2D.dynamics.B2Fixture;

/*use*/ /*namespace*/ /*b2internal*/ class B2PolyAndEdgeContact extends B2Contact {
	public function new() {
		super();
	}

	public static function Create(allocator:ASAny):B2Contact {
		return new B2PolyAndEdgeContact();
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {}

	public override function Reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null) {
		super /*b2internal::*/ .Reset(fixtureA, fixtureB);
		B2Settings.b2Assert(fixtureA.GetType() == B2Shape.e_polygonShape);
		B2Settings.b2Assert(fixtureB.GetType() == B2Shape.e_edgeShape);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.GetBody();
		var _loc2_ = m_fixtureB.GetBody();
		this.b2CollidePolyAndEdge(m_manifold, ASCompat.reinterpretAs(m_fixtureA.GetShape(), B2PolygonShape), _loc1_.m_xf,
			ASCompat.reinterpretAs(m_fixtureB.GetShape(), B2EdgeShape), _loc2_.m_xf);
	}

	function b2CollidePolyAndEdge(manifold:B2Manifold, polygon:B2PolygonShape, xf1:B2Transform, edge:B2EdgeShape, xf2:B2Transform) {}
}
