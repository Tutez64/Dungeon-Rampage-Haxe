package box2D.dynamics.contacts;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2EdgeShape;
import box2D.collision.B2Manifold;
import box2D.common.math.B2Transform;
import box2D.dynamics.B2Fixture;

/*use*/ /*namespace*/ /*b2internal*/ class B2EdgeAndCircleContact extends B2Contact {
	public function new() {
		super();
	}

	public static function Create(allocator:ASAny):B2Contact {
		return new B2EdgeAndCircleContact();
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {}

	public override function Reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null) {
		super /*b2internal::*/ .Reset(fixtureA, fixtureB);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.GetBody();
		var _loc2_ = m_fixtureB.GetBody();
		this.b2CollideEdgeAndCircle(m_manifold, ASCompat.reinterpretAs(m_fixtureA.GetShape(), B2EdgeShape), _loc1_.m_xf,
			ASCompat.reinterpretAs(m_fixtureB.GetShape(), B2CircleShape), _loc2_.m_xf);
	}

	function b2CollideEdgeAndCircle(manifold:B2Manifold, edge:B2EdgeShape, xf1:B2Transform, circle:B2CircleShape, xf2:B2Transform) {}
}
