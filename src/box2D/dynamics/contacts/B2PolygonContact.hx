package box2D.dynamics.contacts;

import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.B2Collision;
import box2D.dynamics.B2Fixture;

/*use*/ /*namespace*/ /*b2internal*/ class B2PolygonContact extends B2Contact {
	public function new() {
		super();
	}

	public static function Create(allocator:ASAny):B2Contact {
		return new B2PolygonContact();
	}

	public static function Destroy(contact:B2Contact, allocator:ASAny) {}

	public override function Reset(fixtureA:B2Fixture = null, fixtureB:B2Fixture = null) {
		super /*b2internal::*/ .Reset(fixtureA, fixtureB);
	}

	override public function Evaluate() {
		var _loc1_ = m_fixtureA.GetBody();
		var _loc2_ = m_fixtureB.GetBody();
		B2Collision.CollidePolygons(m_manifold, ASCompat.reinterpretAs(m_fixtureA.GetShape(), B2PolygonShape), _loc1_.m_xf,
			ASCompat.reinterpretAs(m_fixtureB.GetShape(), B2PolygonShape), _loc2_.m_xf);
	}
}
